import chromadb

client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection("test")

collection.add(
    documents=["Wheat yellow disease is caused by rust fungus"],
    ids=["doc1"]
)

results = collection.query(
    query_texts=["yellow wheat problem"],
    n_results=5,
    include=["documents", "distances"]
)

docs = results["documents"][0]
distances = results["distances"][0]

THRESHOLD = 0.8

filtered = [doc for doc, dist in zip(docs, distances) if dist < THRESHOLD]

print("RAW:", docs)
print("DISTANCES:", distances)
print("FILTERED:", filtered)