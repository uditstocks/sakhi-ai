from chromadb_module import add_document

print("Starting ingestion...")

add_document(
    "wheat_rust_1",
    "Wheat yellow rust is caused by Puccinia striiformis. It spreads in cool, humid conditions and reduces yield significantly.",
    {"crop": "wheat", "disease": "rust"}
)

add_document(
    "rice_blast_1",
    "Rice blast is caused by Magnaporthe oryzae fungus. It causes lesions on leaves and reduces grain production.",
    {"crop": "rice", "disease": "blast"}
)

add_document(
    "general_wheat_1",
    "Wheat crop requires well drained soil, proper irrigation and balanced nitrogen fertilization.",
    {"crop": "wheat"}
)

print(" Ingestion completed")