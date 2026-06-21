"""
ingest.py — Basic document ingestion script for Sakhi AI.

Adds sample agricultural documents to ChromaDB for RAG retrieval.
Used for initial testing and seeding the vector database.
"""

import os
import sys

# Add backend root to Python path for importing chromadb_module
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

from chromadb_module import add_document

print("Starting ingestion...")

# Sample document: wheat disease information
add_document(
    "wheat_rust_1",
    "Wheat yellow rust is caused by Puccinia striiformis. It spreads in cool, humid conditions and reduces yield significantly.",
    {"crop": "wheat", "disease": "rust"}
)

# Sample document: rice disease information
add_document(
    "rice_blast_1",
    "Rice blast is caused by Magnaporthe oryzae fungus. It causes lesions on leaves and reduces grain production.",
    {"crop": "rice", "disease": "blast"}
)

# Sample document: general wheat farming advice
add_document(
    "general_wheat_1",
    "Wheat crop requires well drained soil, proper irrigation and balanced nitrogen fertilization.",
    {"crop": "wheat"}
)

print(" Ingestion completed")