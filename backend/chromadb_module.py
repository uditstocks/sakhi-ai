import chromadb
from sentence_transformers import SentenceTransformer

# =========================
# MODEL (singleton style)
# =========================
_model = None

def get_model():
    global _model
    if _model is None:
        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model

# =========================
# DB
# =========================
client = chromadb.PersistentClient(path="./chroma_db")

collection = client.get_or_create_collection(
    name="agri_docs"
)

# =========================
# ADD DOCUMENT
# =========================
def add_document(doc_id: str, text: str, metadata: dict = None):

    model = get_model()
    embedding = model.encode(text).tolist()

    collection.add(
        documents=[text],
        ids=[doc_id],
        embeddings=[embedding],
        metadatas=[metadata or {}]
    )

# =========================
# SEARCH (PRODUCTION RAG)
# =========================
def search_documents(query: str, n_results: int = 5):

    model = get_model()
    query_embedding = model.encode(query).tolist()

    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=n_results,
        include=["documents", "distances", "metadatas"]
    )

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
    

    # =========================
    # TOP-K RANKING (PRODUCTION WAY)
    # =========================
    ranked = sorted(
        zip(docs, distances, metadatas),
        key=lambda x: x[1]
    )[:3]

    final_docs = [d[0] for d in ranked]
    final_dist = [d[1] for d in ranked]
    final_meta = [d[2] for d in ranked]

    # =========================
    # CONTEXT BUILDING (LLM OPTIMIZED)
    # =========================
    context = "\n\n".join(
        [f"[DOC {i+1}] {doc}" for i, doc in enumerate(final_docs)]
    )

    return {
        "documents": [final_docs],
        "distances": [final_dist],
        "metadatas": [final_meta],
        "context": context
    }

# =========================
# RESET DB (DEV ONLY)
# =========================
def reset_collection():
    global client, collection

    client.delete_collection("agri_docs")
    collection = client.get_or_create_collection("agri_docs")