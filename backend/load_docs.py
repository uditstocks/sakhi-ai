import os
from chromadb_module import add_document

folder_path = "sample_docs"

for filename in os.listdir(folder_path):

    file_path = os.path.join(folder_path, filename)

    with open(file_path, "r") as file:

        text = file.read()

        add_document(
            doc_id=filename,
            text=text
        )

print("Documents loaded successfully")
