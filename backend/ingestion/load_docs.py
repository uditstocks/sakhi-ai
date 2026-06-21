"""
load_docs.py — Simple document loader for Sakhi AI.

Reads text files from the sample_docs/ folder and adds them to ChromaDB.
Used for quick testing with plain text documents (not PDFs).
"""

import os
import sys

# Add backend root to Python path for importing chromadb_module
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

from chromadb_module import add_document

folder_path = os.path.join(_backend_root, "data", "sample_docs")

# Iterate through all files in the sample_docs folder
for filename in os.listdir(folder_path):

    file_path = os.path.join(folder_path, filename)

    with open(file_path, "r") as file:

        text = file.read()

        # Add each file as a document to ChromaDB
        add_document(
            doc_id=filename,
            text=text
        )

print("Documents loaded successfully")
