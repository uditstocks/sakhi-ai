import os
import re
import argparse
from pypdf import PdfReader
from chromadb_module import add_documents_batch

# =====================================================================
# 1. PDF TEXT EXTRACTION
# =====================================================================
def load_pdf(file_path: str) -> str:
    """Extracts text from all pages of a PDF file using pypdf."""
    try:
        reader = PdfReader(file_path)
        full_text = []
        for i, page in enumerate(reader.pages):
            text = page.extract_text()
            if text:
                full_text.append(text)
        return "\n".join(full_text)
    except Exception as e:
        print(f"Error reading PDF {file_path}: {e}")
        return ""

# =====================================================================
# 2. TEXT CLEANING
# =====================================================================
def clean_text(text: str) -> str:
    """Cleans extracted text by removing footers, excessive whitespace, and page markers."""
    # Remove headers/footers and page number patterns (e.g. Page 1 of 10, Page 5)
    text = re.sub(r'(?i)page\s+\d+(\s+of\s+\d+)?', '', text)
    # Remove multiple consecutive whitespaces and tabs
    text = re.sub(r'[ \t]+', ' ', text)
    # Normalize multiple newlines to double newlines (to preserve paragraphs)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip()

# =====================================================================
# 3. SENTENCE-AWARE CHUNKING SYSTEM
# =====================================================================
def chunk_text(text: str, chunk_size_tokens: int = 400, overlap_tokens: int = 75) -> list[str]:
    """
    Splits text into chunks of 300-500 tokens (defaults to 400) with a 50-100 token overlap (defaults to 75).
    Splits are made on sentence boundaries to preserve agricultural context.
    Approximates tokens as: 1 word = 1.3 tokens.
    """
    # Regex split on sentence endings (. ? !) followed by spaces
    sentence_endings = re.compile(r'(?<=[.!?])\s+')
    sentences = sentence_endings.split(text)
    
    chunks = []
    current_chunk_sentences = []
    current_chunk_tokens = 0
    
    for sentence in sentences:
        sentence = sentence.strip()
        if not sentence:
            continue
        
        # Estimate sentence tokens (words * 1.3)
        sentence_tokens = int(len(sentence.split()) * 1.3)
        
        # If adding this sentence exceeds chunk size, finalize current chunk
        if current_chunk_tokens + sentence_tokens > chunk_size_tokens:
            if current_chunk_sentences:
                chunks.append(" ".join(current_chunk_sentences))
                
                # Backtrack to collect overlap sentences
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

# =====================================================================
# 4. METADATA AUTO-DETECTION
# =====================================================================
def extract_metadata(text: str, filename: str) -> dict:
    """Auto-detects crops, diseases, and tags keywords from chunk content."""
    text_lower = text.lower()
    fn_lower = filename.lower()
    
    # Crops list
    crops = ["wheat", "rice", "maize", "cotton", "potato", "tomato", "soybean"]
    detected_crops = [crop for crop in crops if crop in text_lower or crop in fn_lower]
    crop_type = ", ".join(detected_crops) if detected_crops else "unknown"
    
    # Diseases list
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

# =====================================================================
# 5. MAIN INGESTION LOOP
# =====================================================================
def ingest_folder(folder_path: str):
    """Processes all PDFs in folder_path, chunks them, and stores them in ChromaDB."""
    if not os.path.exists(folder_path):
        print(f"Directory '{folder_path}' does not exist. Creating it.")
        os.makedirs(folder_path, exist_ok=True)
        print(f"Please drop your ICAR PDFs into {folder_path} and rerun.")
        return

    pdf_files = [f for f in os.listdir(folder_path) if f.lower().endswith(".pdf")]
    if not pdf_files:
        print(f"No PDF files found in '{folder_path}'. Please drop some PDFs there.")
        return

    print(f"Found {len(pdf_files)} PDFs in '{folder_path}'. Starting ingestion...")
    
    for filename in pdf_files:
        file_path = os.path.join(folder_path, filename)
        print(f"\nProcessing: {filename}...")
        
        # 1. Load PDF
        raw_text = load_pdf(file_path)
        if not raw_text.strip():
            print(f"Skipping {filename}: No text extracted.")
            continue
            
        # 2. Clean
        cleaned_text = clean_text(raw_text)
        
        # 3. Chunk
        chunks = chunk_text(cleaned_text)
        print(f"-> Generated {len(chunks)} overlapping chunks.")
        
        # 4. Prepare database updates
        doc_ids = []
        texts = []
        metadatas = []
        
        for idx, chunk in enumerate(chunks):
            chunk_id = f"{filename}_chunk_{idx}"
            chunk_metadata = extract_metadata(chunk, filename)
            
            doc_ids.append(chunk_id)
            texts.append(chunk)
            metadatas.append(chunk_metadata)
            
        # 5. Batch Upload (Upsert)
        if doc_ids:
            try:
                add_documents_batch(doc_ids, texts, metadatas)
                print(f"Successfully ingested all {len(doc_ids)} chunks for {filename}.")
            except Exception as e:
                print(f"Error uploading batch to ChromaDB for {filename}: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest ICAR PDFs into ChromaDB.")
    parser.add_argument(
        "--folder", 
        type=str, 
        default="./icar_pdfs", 
        help="Path to folder containing ICAR PDFs (default: ./icar_pdfs)"
    )
    args = parser.parse_args()
    
    ingest_folder(args.folder)
