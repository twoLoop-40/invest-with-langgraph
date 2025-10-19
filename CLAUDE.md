# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational project teaching investment strategy development with LangGraph. Per [spec.yaml](spec.yaml):

**Architecture**: Idris specs → Python implementation
**Format**: Problem-based learning (principles → exercises → executable result → model answers)
**Progress Tracking**: GitHub Projects for student progress monitoring
**Language**: Bilingual (Korean/English) for Korean students

**Current Status**: Tool-based architecture implemented. Idris specs compiled, Python implementation complete with student practice exercises.

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

### Current Architecture (per spec.yaml)

```
idris/Domain/     # Formal specifications (✅ ALL COMPILED)
  ├── InvestmentAgent.idr    # Core agent state & evaluation
  ├── Workflow.idr           # LangGraph workflow semantics
  ├── Tools.idr              # Tool-based architecture (4 investment tools)
  ├── ReActAgent.idr         # ReAct pattern specification
  ├── NotebookStructure.idr  # Notebook cell ordering spec (sequential algorithm)
  └── CellAssociation.idr    # Explanation-code association spec (active)
python/models/    # Python implementations (✅ COMPLETE)
  └── tools.py               # 4 @tool decorated functions + ToolAgentState
python/utils/     # Utility scripts (✅ ACTIVE)
  ├── README.md              # Utils documentation
  ├── reorder_with_associations.py  # Association-based reordering
  └── visualize_associations.py     # Association visualization
python/tests/     # Test suite (NOT CREATED)
notebooks/        # Problem-based exercises (✅ PROPERLY ORDERED)
  ├── 1_generate.ipynb       # Basic: query → answer (12 associations)
  ├── 2_web_search.ipynb     # Advanced: eval loop + web search (11 associations)
  └── 3_tool_agent.ipynb     # ReAct agent with 10 practice problems
```

## File Structure

```
invest-with-langgraph/
├── idris/Domain/
│   ├── InvestmentAgent.idr      # Agent state & evaluation spec
│   ├── Workflow.idr              # LangGraph workflow spec
│   ├── Tools.idr                 # Tool framework spec
│   ├── ReActAgent.idr            # ReAct pattern spec
│   ├── NotebookStructure.idr     # Notebook cell ordering spec (COMPILED ✅)
│   └── CellAssociation.idr       # Explanation-code association spec (COMPILED ✅)
├── python/
│   ├── models/
│   │   └── tools.py              # Investment analysis tools implementation
│   └── utils/
│       ├── README.md             # Utils documentation
│       ├── reorder_with_associations.py  # Association-based reordering (ACTIVE ✅)
│       └── visualize_associations.py     # Association visualization
├── notebooks/
│   ├── 1_generate.ipynb          # Basic: query → answer (3 practice problems)
│   ├── 2_web_search.ipynb        # Advanced: eval loop + web search (10 practice problems)
│   └── 3_tool_agent.ipynb        # ReAct agent with tools (10 practice problems)
├── .env                           # API keys (OPENAI_API_KEY, TAVILY_API_KEY)
├── pyproject.toml                 # uv-based dependencies (Python ≥3.13)
├── uv.lock                        # uv locked versions
├── spec.yaml                      # Project specification
└── CLAUDE.md                      # This file
```

## Utilities

See [python/utils/README.md](python/utils/README.md) for detailed documentation.

### 1. Association-Based Notebook Reordering

**Location**: `python/utils/reorder_with_associations.py`
**Idris Spec**: `idris/Domain/CellAssociation.idr` ✅ COMPILED

**Purpose**: Reorder notebooks 1 & 2 using explicit explanation-code associations defined in Idris specification.

**Usage**:
```bash
python3 python/utils/reorder_with_associations.py
```

**How it works**:
1. Reads association maps from Idris `CellAssociation.idr`
2. Validates: no duplicate indices, all indices in range
3. For each association (sorted order):
   - Output explanation cell
   - Output associated code cells
4. Output any unassociated cells at end

**Association Maps**:
- Notebook 1: 12 associations (intro + 10 sections + practice)
- Notebook 2: 11 associations (10 sections + practice)

**Example**:
```
Original: [설명1, 설명2, ..., 설명10, 코드1, 코드2, ..., 코드10]
Result:   [설명1, 코드1, 설명2, 코드2, ..., 설명10, 코드10]
```

### 2. Association Visualization

**Location**: `python/utils/visualize_associations.py`

**Purpose**: Visualize explanation → code mappings for debugging and verification.

**Usage**:
```bash
python3 python/utils/visualize_associations.py
```

**Output**:
```
📝 Cell 2: ## 1. 환경 변수 로드
   └─> 코드 셀: Cell 13: from dotenv import load_dotenv
...
📊 Summary: 12 associations, 15 code cells
```

### Idris-First Development Example

This notebook reordering feature demonstrates the complete Idris-first workflow:

1. **Problem**: Notebooks 1 & 2 have all explanations before all code (bad structure)
2. **Investigation**: Analyzed cell structure, created keyword-based mappings
3. **Idris Spec**: Defined `Association`, `AssociationMap`, `ValidAssociationMap` types
4. **Validation**: Added duplicate detection, range checks
5. **Concrete Data**: Included actual association maps in Idris spec
6. **Compilation**: `idris2 --check CellAssociation.idr` ✅
7. **Python Implementation**: Translated Idris spec to Python
8. **Debugging**: Found duplicates → fixed Idris → recompiled → updated Python
9. **Result**: Perfect explanation → code pairing

**Key Insight**: Idris specification acted as single source of truth. All bugs were caught and fixed at specification level before runtime.

## Key Implementation Details

**Notebooks**:
- Run cells sequentially top-to-bottom
- Each notebook has explanation (theory + code explanation) before code cells
- State schema differs between notebooks
- All notebooks include practice problems with fill-in-the-blank exercises

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

## Dependencies (managed by uv)

- `notebook (≥7.4.4)` - Jupyter
- `langchain-openai (≥0.3.27)` - OpenAI integration
- `langgraph (≥0.5.2)` - Graph workflow
- `langchain-tavily (≥0.2.7)` - Web search
- `langchain-community (≥0.3.27)` - Community integrations
- `python-dotenv (≥1.1.1)` - .env loading
- `yfinance (≥0.2.66)` - Yahoo Finance API for stock data

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

**Completed**:
- ✅ Idris specifications (6 files compiled successfully)
  - InvestmentAgent.idr, Workflow.idr, Tools.idr, ReActAgent.idr
  - NotebookStructure.idr, CellAssociation.idr (new!)
- ✅ Tool-based architecture (4 investment tools: search_web, get_stock_price, calculate_moving_average, get_company_info)
- ✅ Python models matching Idris specs (`python/models/tools.py`)
- ✅ Python utilities with Idris specs (`python/utils/`)
- ✅ Student practice exercises (10 progressive fill-in-the-blank problems in notebook 3)
- ✅ Migration to uv package manager (poetry.lock removed)
- ✅ Notebook cell ordering (explanation → code pairs for all notebooks)

**Missing Components**:
- Test suite (`python/tests/`)
- GitHub Projects integration for progress tracking
- Version alignment (spec: 1.0.0, pyproject: 0.1.0)
- Separate exercise/solution notebooks (currently combined)

**Next Steps**:
1. Add property-based tests verifying spec compliance
2. Set up GitHub Project board for student progress tracking
3. Consider splitting notebooks into exercise/solution pairs
4. Update version to 1.0.0 if ready for release

**Recent Achievement**:
Successfully demonstrated Idris-first methodology with notebook reordering:
- Problem identified → Idris spec written → Compiled → Python implemented
- Bugs caught at specification level (duplicate cell indices)
- Result: Perfect explanation-code pairing in all notebooks
