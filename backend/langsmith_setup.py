"""Load LangSmith env vars from backend/.env before any traced modules import."""

import os

from dotenv import load_dotenv

_module_dir = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(_module_dir, ".env"))

# Project name for @traceable(project_name=...)
LANGSMITH_PROJECT = os.getenv("LANGSMITH_PROJECT", "sakhi-ai")

_tracing_flag = os.getenv("LANGSMITH_TRACING", "").strip().lower()
LANGSMITH_TRACING_ENABLED = _tracing_flag in ("true", "1", "yes", "on")

# LangSmith SDK reads LANGSMITH_*; LangChain integrations still use LANGCHAIN_* aliases.
if LANGSMITH_TRACING_ENABLED:
    os.environ.setdefault("LANGCHAIN_TRACING_V2", "true")

if os.getenv("LANGSMITH_API_KEY"):
    os.environ.setdefault("LANGCHAIN_API_KEY", os.environ["LANGSMITH_API_KEY"])

if LANGSMITH_PROJECT:
    os.environ.setdefault("LANGCHAIN_PROJECT", LANGSMITH_PROJECT)
