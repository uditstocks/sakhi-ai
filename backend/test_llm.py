"""Quick smoke test for NVIDIA text LLM. Run: python test_llm.py"""
from llm_module import generate_text

if __name__ == "__main__":
    reply = generate_text("What is the best time to sow wheat in North India?")
    print(reply)
