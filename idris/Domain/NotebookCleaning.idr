module NotebookCleaning

%default total

-- Cell types in Jupyter notebooks
data CellType = Markdown | Code

-- Cell with content but no output
record CleanCell where
  constructor MkCleanCell
  cellType : CellType
  content : String         -- Source code/markdown text
  cellId : Maybe String    -- Optional cell ID

-- Notebook is a list of cells
Notebook : Type
Notebook = List CleanCell

-- Output cleaning: Remove all outputs from code cells
-- This is necessary before reordering to avoid stale outputs
cleanOutputs : Notebook -> Notebook
cleanOutputs cells = cells  -- Outputs removed at JSON level in Python

-- Cell classification
-- Separate markdown explanation cells from code cells
record CellClassification where
  constructor MkClassification
  markdownCells : List (Nat, CleanCell)  -- (index, cell)
  codeCells : List (Nat, CleanCell)      -- (index, cell)

classifyCells : Notebook -> CellClassification
classifyCells cells = MkClassification [] []  -- Python implements full logic

-- Matching strategy: Find code cell that belongs to each markdown section
-- Strategy 1: Keyword matching (e.g., "## 1. 환경 변수" → "# 환경 변수 로드")
-- Strategy 2: Sequential matching (Nth markdown → Nth code)
-- Strategy 3: Manual specification (for practice problems)

record Match where
  constructor MkMatch
  markdownIndex : Nat
  codeIndices : List Nat   -- One markdown can have multiple code cells

-- Match markdown sections to code cells
-- Returns list of (markdown_idx, [code_idx1, code_idx2, ...])
matchCells : CellClassification -> List Match
matchCells classification = []  -- Python implements matching logic

-- Reorder cells: markdown followed immediately by its code cells
-- Input: original cells, matches
-- Output: reordered cells (markdown → code → markdown → code ...)
reorderCells : Notebook -> List Match -> Notebook
reorderCells originalCells matches =
  -- For each match:
  -- 1. Add markdown cell
  -- 2. Add all associated code cells
  -- 3. Collect unmatched cells at the end
  []  -- Python implements reordering

-- Complete workflow
record NotebookReorderingSpec where
  constructor MkReorderingSpec
  cleanOutputsFirst : Bool           -- Always True
  classificationStrategy : String    -- "automatic" or "manual"
  matchingStrategy : String          -- "keyword", "sequential", or "manual"
  preserveUnmatched : Bool           -- Add unmatched cells at end

-- Default specification for educational notebooks
defaultSpec : NotebookReorderingSpec
defaultSpec = MkReorderingSpec
  True              -- Clean outputs first
  "automatic"       -- Automatic classification
  "sequential"      -- Sequential matching (Nth markdown → Nth code)
  True              -- Preserve unmatched cells
