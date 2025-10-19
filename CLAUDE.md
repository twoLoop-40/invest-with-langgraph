# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational project teaching investment strategy development with LangGraph. Per [spec.yaml](spec.yaml):

**Architecture**: Idris specs → Python implementation
**Format**: Problem-based learning (principles → exercises → executable result → model answers)
**Progress Tracking**: GitHub Projects for student progress monitoring
**Language**: Bilingual (Korean/English) for Korean students

**Current Status**: Transitioning to spec.yaml architecture. `idris/Domain/` created with initial specifications.

## Development Workflow

### Critical: Idris-First Development Process

**ALWAYS follow this order**:

1. **Write Idris specification** in `idris/Domain/`
2. **Compile Idris** to verify correctness (`idris2 --check <file>`)
3. **Commit Idris specs** to git
4. **Implement Python** based on Idris specification
5. **Commit Python implementation** to git

**Never write Python before Idris specs are complete and compiled.**

### Commands

```bash
# Idris workflow
idris2 --check idris/Domain/<file>.idr    # Type check specification
idris2 idris/Domain/<file>.idr            # Compile (optional)

# Git workflow (commit at each step)
git add idris/Domain/<file>.idr
git commit -m "Add Idris spec for <feature>"
git add python/models/<file>.py
git commit -m "Implement Python for <feature> per Idris spec"

# Python setup (uv package manager, not Poetry)
uv sync                          # Install dependencies, create .venv
uv run jupyter notebook          # Start Jupyter

# Environment (required)
# Create .env file with:
# OPENAI_API_KEY=sk-proj-...
# TAVILY_API_KEY=tvly-...
```

## Architecture

### Current Implementation (notebooks/)

Self-evaluating LangGraph chatbot with iterative refinement:

1. **Generate** answer (GPT-4o-mini)
2. **Evaluate** quality (0-20 score: accuracy, completeness, clarity, relevance)
3. **Decide**: score ≥ 15 → END | score < 15 → web search → regenerate
4. **Prevent loops**: max_iterations limit (default: 3)

**Key Pattern**: Context accumulation (web search results append, not replace) with URL deduplication.

```python
# State (notebooks/2 web_search.ipynb)
class AgentState(TypedDict):
    query: str                    # User question
    context: List[Dict]           # Accumulated search results
    answer: str                   # Current answer
    search_threshold: int         # Score trigger (default: 15)
    iteration_count: int          # Current iteration
    max_iterations: int           # Loop limit (default: 3)
    evaluation_score: int         # Latest score (0-20)
    evaluation_comment: str       # Feedback
    error: str                    # Error messages
```

**Nodes**: `generate` → `qa_eval` (conditional) → `web_search` → loop
**Tools**: OpenAI GPT-4o-mini, Tavily search (3 results, advanced depth)

### Intended Architecture (spec.yaml)

```
idris/Domain/     # Formal specifications (IN PROGRESS)
  ├── InvestmentAgent.idr  # Core agent state & evaluation
  ├── Workflow.idr         # LangGraph workflow semantics
  ├── Tools.idr            # Tool-based architecture (NEW)
  └── ReActAgent.idr       # ReAct pattern specification (NEW)
python/models/    # Python implementations (NOT CREATED - pending Idris completion)
python/tests/     # Test suite (NOT CREATED)
notebooks/        # Problem-based exercises (EXISTS but not in exercise format)
```

## File Structure

```
invest-with-langgraph/
├── notebooks/
│   ├── 1 generate.ipynb       # Basic: query → answer
│   └── 2 web_search.ipynb     # Advanced: eval loop + web search
├── src/invest_with_langgraph/ # Empty placeholder
├── .env                        # API keys (OPENAI_API_KEY, TAVILY_API_KEY)
├── pyproject.toml              # Dependencies (Python ≥3.13)
├── uv.lock                     # Locked versions
└── spec.yaml                   # Project specification
```

## Key Implementation Details

**Notebooks**: Run cells sequentially top-to-bottom. State schema differs between notebooks.

**Cost Management**:
- GPT-4o-mini: ~$0.5 per 100 queries
- Tavily: 1,000 searches/month free
- Set `max_iterations: 1` for testing

**Common Issues**:
1. Missing `.env` → silent failure (no fallback)
2. Infinite loops → always set `max_iterations`
3. Deprecated `TavilySearchResults` → migrate to `langchain-tavily.TavilySearch`

**Tuning**:
```python
initial_state = {
    'search_threshold': 10,  # Lower = more searches
    'max_iterations': 5,     # More refinement attempts
}
```

## Dependencies

- `notebook (≥7.4.4)` - Jupyter
- `langchain-openai (≥0.3.27)` - OpenAI integration
- `langgraph (≥0.5.2)` - Graph workflow
- `langchain-tavily (≥0.2.7)` - Web search
- `python-dotenv (≥1.1.1)` - .env loading

## Development Rules

### When Adding New Features

1. **Ask before implementing** if design is unclear
2. **Write Idris first**: Define types, functions, invariants
3. **Compile Idris**: Must pass `idris2 --check` before proceeding
4. **Commit Idris**: `git commit -m "Add Idris spec for X"`
5. **Implement Python**: Follow Idris specification exactly
6. **Commit Python**: `git commit -m "Implement X per Idris spec"`
7. **Test**: Verify Python matches Idris properties
8. **Commit tests**: `git commit -m "Add tests for X"`

### When Uncertain

- **DO ask questions** about design decisions
- **DO request clarification** on Idris specification approach
- **DO NOT proceed** with Python if Idris spec is incomplete
- **DO NOT skip** Idris compilation step

## Gap Analysis (Current vs. spec.yaml)

**In Progress**:
- ✅ Idris specifications (initial files created)
- 🔄 Tool-based architecture (Idris spec ready, needs compilation check)

**Missing Components**:
- Problem-based exercise format (separate exercise/solution notebooks)
- Python models matching Idris specs
- Test suite (`python/tests/`)
- GitHub Projects integration for progress tracking
- Version alignment (spec: 1.0.0, pyproject: 0.1.0)

**Next Steps**:
1. Verify Idris compilation for Tools.idr and ReActAgent.idr
2. Implement Python models mirroring Idris specs
3. Add property-based tests verifying spec compliance
4. Split notebooks into exercise/solution pairs
5. Set up GitHub Project board for student progress tracking
