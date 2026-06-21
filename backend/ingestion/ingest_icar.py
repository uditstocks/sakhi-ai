"""
ingest_icar.py — ICAR PDF ingestion pipeline for Sakhi AI.

Processes agricultural PDF documents from ICAR (Indian Council of Agricultural Research):
1. Extracts text from PDFs
2. Cleans and chunks text into overlapping segments
3. Extracts metadata (crop, disease, keywords)
4. Stores chunks in ChromaDB with embeddings for RAG retrieval

Usage: python ingest_icar.py --folder ./icar_pdfs
"""

import os
import sys
import re   # Used to clean PDF text
import argparse
from pypdf import PdfReader  # Extracts actual text from binary PDF file

# Add backend root to Python path for importing chromadb_module
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

from chromadb_module import add_documents_batch


# ── 1. PDF text extraction ────────────────────────────────────────

def load_pdf(file_path: str) -> str:
    """
    Extracts text from all pages of a PDF file using pypdf.

    Args:
        file_path: Path to the PDF file.

    Returns:
        Concatenated text from all pages, or empty string on error.
    """
    try:
        reader = PdfReader(file_path)  # Open PDF
        full_text = []  # Stores text from every page
        for i, page in enumerate(reader.pages):  # Loop through all pages
            text = page.extract_text()  # Extract text from current page
            if text:
                full_text.append(text)  # Store extracted page text
        return "\n".join(full_text)  # Merge all pages into one large string
    except Exception as e:
        print(f"Error reading PDF {file_path}: {e}")
        return ""



# ── 2. Text cleaning ──────────────────────────────────────────────

def clean_text(text: str) -> str:
    """
    Cleans extracted PDF text by removing headers/footers, page numbers,
    excessive whitespace, and normalizing line breaks.

    Args:
        text: Raw extracted text from PDF.

    Returns:
        Cleaned text with preserved paragraph structure.
    """
    # Remove headers/footers and page number patterns (e.g. Page 1 of 10, Page 5)
    text = re.sub(r'(?i)page\s+\d+(\s+of\s+\d+)?', '', text)
    # Remove multiple consecutive whitespaces and tabs
    text = re.sub(r'[ \t]+', ' ', text)
    # Normalize multiple newlines to double newlines (to preserve paragraphs)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip()




# ── 3. Sentence-aware chunking system ─────────────────────────────

def chunk_text(text: str, chunk_size_tokens: int = 400, overlap_tokens: int = 75) -> list[str]:
    """
    Splits text into overlapping chunks of ~400 tokens with ~75 token overlap.
    Splits on sentence boundaries to preserve agricultural context完整性.
    Approximates tokens as: 1 word = 1.3 tokens.

    Args:
        text: Cleaned text to chunk.
        chunk_size_tokens: Target chunk size in tokens. Default 400.
        overlap_tokens: Overlap between consecutive chunks. Default 75.

    Returns:
        List of text chunks (strings).
    """
    # Regex split on sentence endings (. ? !) followed by spaces
    sentence_endings = re.compile(r'(?<=[.!?])\s+')
    sentences = sentence_endings.split(text)
    
    chunks = []  # Stores final chunks
    current_chunk_sentences = []
    current_chunk_tokens = 0
    
    for sentence in sentences:
        sentence = sentence.strip()  # Remove trailing spaces
        if not sentence:
            continue
        
        # Estimate sentence tokens (words * 1.3)
        sentence_tokens = int(len(sentence.split()) * 1.3)
        
        # If adding this sentence exceeds chunk size, finalize current chunk
        if current_chunk_tokens + sentence_tokens > chunk_size_tokens:
            if current_chunk_sentences:
                chunks.append(" ".join(current_chunk_sentences))
                
                # Backtrack to collect overlap sentences for continuity
                overlap_sentences = []
                overlap_tokens_accumulated = 0
                for s in reversed(current_chunk_sentences):
                    s_tokens = int(len(s.split()) * 1.3)
                    if overlap_tokens_accumulated + s_tokens <= overlap_tokens:
                        overlap_sentences.insert(0, s)
                        overlap_tokens_accumulated += s_tokens
                    else:
                        break
                
                current_chunk_sentences = overlap_sentences
                current_chunk_tokens = overlap_tokens_accumulated
                
        current_chunk_sentences.append(sentence)
        current_chunk_tokens += sentence_tokens
        
    # Append the last chunk
    if current_chunk_sentences:
        chunks.append(" ".join(current_chunk_sentences))
        
    return chunks




# ── 4. Metadata extraction ────────────────────────────────────────

def extract_metadata(text: str, filename: str) -> dict:
    """
    Auto-detects crops, diseases, and keyword tags from chunk content.
    Used for fast metadata-based filtering during RAG retrieval.

    Args:
        text: The chunk text to analyze.
        filename: Source PDF filename for source tracking.

    Returns:
        Dictionary with crop_type, disease, and boolean keyword tags.
    """
    text_lower = text.lower()
    fn_lower = filename.lower()
    
    # Detect crops mentioned in the text
    crops = ["wheat", "rice", "maize", "cotton", "potato", "tomato", "soybean"]
    detected_crops = [crop for crop in crops if crop in text_lower or crop in fn_lower]
    crop_type = ", ".join(detected_crops) if detected_crops else "unknown"
    
    # Detect diseases mentioned in the text
    diseases = ["rust", "blast", "blight", "rot", "wilt", "leaf curl", "bollworm", "virus"]
    detected_diseases = [disease for disease in diseases if disease in text_lower or disease in fn_lower]
    disease_type = ", ".join(detected_diseases) if detected_diseases else "none"
    
    # Keyword indicators (stored as boolean for fast metadata indexing)
    metadata = {
        "source": filename,
        "crop_type": crop_type,
        "disease": disease_type,
        "tag_wheat": "wheat" in detected_crops,
        "tag_rice": "rice" in detected_crops,
        "tag_maize": "maize" in detected_crops,
        "tag_disease": len(detected_diseases) > 0 or "disease" in text_lower,
        "tag_fertilizer": any(kw in text_lower for kw in ["fertilizer", "nitrogen", "potash", "urea", "manure"]),
        "tag_irrigation": any(kw in text_lower for kw in ["irrigation", "water", "flooding", "drainage", "canal"]),
    }
    
    return metadata




# ── 5. Folder ingestion ───────────────────────────────────────────

def ingest_folder(folder_path: str):
    """
    Processes all PDFs in a folder: extracts text, cleans, chunks,
    extracts metadata, and batch-uploads to ChromaDB.

    Args:
        folder_path: Path to folder containing ICAR PDF files.
    """
    if not os.path.exists(folder_path):
        print(f"Directory '{folder_path}' does not exist. Creating it.")
        os.makedirs(folder_path, exist_ok=True)
        print(f"Please drop your ICAR PDFs into {folder_path} and rerun.")
        return
    
    # Find all PDF files in the folder
    pdf_files = [f for f in os.listdir(folder_path) if f.lower().endswith(".pdf")]
    if not pdf_files:
        print(f"No PDF files found in '{folder_path}'. Please drop some PDFs there.")
        return

    print(f"Found {len(pdf_files)} PDFs in '{folder_path}'. Starting ingestion...")
    
    # Process each PDF file
    for filename in pdf_files:
        file_path = os.path.join(folder_path, filename)
        print(f"\nProcessing: {filename}...")
        
        # Step 1: Load PDF text
        raw_text = load_pdf(file_path)
        if not raw_text.strip():
            print(f"Skipping {filename}: No text extracted.")
            continue
            
        # Step 2: Clean the extracted text
        cleaned_text = clean_text(raw_text)
        
        # Step 3: Split into overlapping chunks
        chunks = chunk_text(cleaned_text)
        print(f"-> Generated {len(chunks)} overlapping chunks.")
        
        # Step 4: Prepare batch data (IDs, texts, metadata)
        doc_ids = []
        texts = []
        metadatas = []
        
        for idx, chunk in enumerate(chunks):
            chunk_id = f"{filename}_chunk_{idx}"
            chunk_metadata = extract_metadata(chunk, filename)
            
            doc_ids.append(chunk_id)
            texts.append(chunk)
            metadatas.append(chunk_metadata)
            
        # Step 5: Batch upload all chunks to ChromaDB
        if doc_ids:
            try:
                add_documents_batch(doc_ids, texts, metadatas)
                print(f"Successfully ingested all {len(doc_ids)} chunks for {filename}.")
            except Exception as e:
                print(f"Error uploading batch to ChromaDB for {filename}: {e}")


# ── Main entry point ──────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest ICAR PDFs into ChromaDB.")
    parser.add_argument(
        "--folder",
        type=str,
        default=os.path.join(_backend_root, "data", "icar_pdfs"),
        help="Path to folder containing ICAR PDFs (default: backend/data/icar_pdfs)"
    )
    args = parser.parse_args()
    
    ingest_folder(args.folder)
