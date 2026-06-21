"""
langsmith_setup.py — LangSmith tracing configuration for Sakhi AI.

Must be imported before any traced modules to ensure environment variables
are loaded. Sets up LangSmith/LangChain tracing and project configuration.
"""

import os

from dotenv import load_dotenv

# Load environment variables from backend/.env
_module_dir = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(_module_dir, ".env"))

# Project name used in @traceable decorators for grouping traces
LANGSMITH_PROJECT = os.getenv("LANGSMITH_PROJECT", "sakhi-ai")

# Parse tracing enabled flag — accepts true, 1, yes, on (case-insensitive)
_tracing_flag = os.getenv("LANGSMITH_TRACING", "").strip().lower()
LANGSMITH_TRACING_ENABLED = _tracing_flag in ("true", "1", "yes", "on")

# LangSmith SDK reads LANGSMITH_* env vars; LangChain integrations use LANGCHAIN_* aliases.
# Set both for compatibility across SDK versions.
if LANGSMITH_TRACING_ENABLED:
    os.environ.setdefault("LANGCHAIN_TRACING_V2", "true")

if os.getenv("LANGSMITH_API_KEY"):
    os.environ.setdefault("LANGCHAIN_API_KEY", os.environ["LANGSMITH_API_KEY"])

if LANGSMITH_PROJECT:
    os.environ.setdefault("LANGCHAIN_PROJECT", LANGSMITH_PROJECT)
