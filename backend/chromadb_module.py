"""
chromadb_module.py — ChromaDB vector store module for Sakhi AI.

Provides document storage and semantic search using ChromaDB
with sentence-transformers embeddings (all-MiniLM-L6-v2).
Used for RAG (Retrieval-Augmented Generation) to ground LLM responses
in ICAR agricultural documents.
"""

import chromadb
from sentence_transformers import SentenceTransformer

# Singleton pattern — load embedding model only once to avoid reloading on every query
_model = None

def get_model():
    """
    Returns the singleton SentenceTransformer embedding model.
    Creates it on first call, reuses it on subsequent calls.
    """
    global _model
    if _model is None:
        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model


# ChromaDB persistent storage initialization
client = chromadb.PersistentClient(path="./chroma_db")

# Create or retrieve the agricultural documents collection
collection = client.get_or_create_collection(
    name="agri_docs"
)



# ── Adding documents ──────────────────────────────────────────────

def add_document(doc_id: str, text: str, metadata: dict = None):
    """
    Adds a single document to the ChromaDB collection.
    Computes embedding and upserts the document with its metadata.

    Args:
        doc_id: Unique identifier for the document.
        text: The document text content.
        metadata: Optional dictionary of metadata (crop, disease, etc.).
    """
    model = get_model()
    embedding = model.encode(text).tolist()

    collection.upsert(
        documents=[text],
        ids=[doc_id],
        embeddings=[embedding],
        metadatas=[metadata or {}]
    )


def add_documents_batch(doc_ids: list[str], texts: list[str], metadatas: list[dict] = None):
    """
    Adds multiple documents to ChromaDB in a single batch operation.
    More efficient than adding documents one by one.

    Args:
        doc_ids: List of unique document identifiers.
        texts: List of document text contents.
        metadatas: Optional list of metadata dictionaries.
    """
    if not doc_ids or not texts:
        return
    
    model = get_model()
    # Batch encode the texts for higher performance
    embeddings = model.encode(texts).tolist()
    
    collection.upsert(
        documents=texts,
        ids=doc_ids,
        embeddings=embeddings,
        metadatas=metadatas or [{} for _ in texts]
    )
# ── Search documents ──────────────────────────────────────────────

def search_documents(query: str, n_results: int = 5):
    """
    Searches ChromaDB for documents semantically similar to the query.
    Returns top 3 results ranked by distance (smaller = more relevant).

    Args:
        query: The search query text.
        n_results: Number of initial results to retrieve from ChromaDB. Default 5.

    Returns:
        Dictionary with 'documents', 'distances', 'metadatas', and 'context' keys.
        'context' is a formatted string of the top results for LLM consumption.
    """
    model = get_model()
    # Encode query into embedding vector for similarity search
    query_embedding = model.encode(query).tolist()

    # ChromaDB finds nearest vectors by cosine distance
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=n_results,
        include=["documents", "distances", "metadatas"]
    )

    # Extract results from nested list structure
    docs = (results.get("documents") or [[]])[0]
    distances = (results.get("distances") or [[]])[0]
    metadatas = (results.get("metadatas") or [[]])[0]

    if not docs:
        return {
            "documents": [[]],
            "distances": [[]],
            "metadatas": [[]],
            "context": "No relevant agricultural data found."
        }

    # Top-k ranking — sort by distance (smaller distance = more relevant)
    ranked = sorted(
        zip(docs, distances, metadatas),
        key=lambda x: x[1]
    )[:3]

    # No relevant results after filtering
    if not ranked:
        return {
            "documents": [[]],
            "distances": [[]],
            "metadatas": [[]],
            "context": "No relevant agricultural data found."
        }

    # Split ranked tuples back into separate lists
    final_docs = [d[0] for d in ranked]
    final_dist = [d[1] for d in ranked]
    final_meta = [d[2] for d in ranked]

    # Build context string — formatted for LLM consumption
    context = "\n\n".join(
        [f"[DOC {i+1}] {doc}" for i, doc in enumerate(final_docs)]
    )

    return {
        "documents": [final_docs],
        "distances": [final_dist],
        "metadatas": [final_meta],
        "context": context
    }


# ── Reset collection ──────────────────────────────────────────────

def reset_collection():
    """
    Deletes and recreates the agri_docs collection.
    Used to clear all stored documents and start fresh.
    """
    global client, collection

    client.delete_collection("agri_docs")
    collection = client.get_or_create_collection("agri_docs")