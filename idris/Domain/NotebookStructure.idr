module NotebookStructure

%default total

-- Cell types in a Jupyter notebook
data CellType = Markdown | Code

Eq CellType where
  Markdown == Markdown = True
  Code == Code = True
  _ == _ = False

-- Cell content classification
data CellContent
  = Header String                    -- Pure header: "## Title" only
  | SectionWithExplanation String    -- "## Title\n\n### 이론\n..." (combined)
  | Explanation String               -- Pure explanation without ## header
  | CodeBlock String                 -- Executable code
  | Other String                     -- Misc markdown

-- A cell with type and content
record Cell where
  constructor MkCell
  cellType : CellType
  content : CellContent

-- Check if cell is a section header (starts with ##)
isSectionHeader : Cell -> Bool
isSectionHeader (MkCell Markdown (Header _)) = True
isSectionHeader (MkCell Markdown (SectionWithExplanation _)) = True
isSectionHeader _ = False

-- Check if cell is an explanation
isExplanation : Cell -> Bool
isExplanation (MkCell Markdown (Explanation _)) = True
isExplanation (MkCell Markdown (SectionWithExplanation _)) = True
isExplanation _ = False

-- Check if cell is code
isCode : Cell -> Bool
isCode (MkCell Code (CodeBlock _)) = True
isCode _ = False

-- A section groups related cells (header + explanation + code)
record Section where
  constructor MkSection
  header : Maybe Cell           -- Optional section header
  explanations : List Cell      -- Explanation cells (markdown)
  codeCells : List Cell         -- Code cells belonging to this section
  otherCells : List Cell        -- Other markdown cells

-- Section association strategy:
-- When parsing a notebook sequentially:
-- 1. Track "current section" (last seen section header/explanation)
-- 2. Code cells belong to the current section
-- 3. When new section starts, previous section is complete
--
-- Example:
--   Cell 1: ## 1. Title\n\n### 이론... (starts Section 1)
--   Cell 2: code                        (belongs to Section 1)
--   Cell 3: ## 2. Next\n\n### 이론...  (starts Section 2, Section 1 complete)
--   Cell 4: code                        (belongs to Section 2)

-- INVARIANT: In a valid section, explanations come before code
-- This is the core property we want to maintain
data ValidSection : Section -> Type where
  MkValidSection : (s : Section)
                -> ValidSection s
  -- Runtime validation (Python will check):
  -- 1. All explanations are markdown
  -- 2. All codeCells are code type
  -- 3. When flattened, explanations appear before codeCells

-- Flatten a section to a list of cells (correct order)
flattenSection : Section -> List Cell
flattenSection s =
  let headerList = case s.header of
                     Nothing => []
                     Just h => [h]
  in headerList ++ s.explanations ++ s.codeCells ++ s.otherCells

-- Notebook is a sequence of sections
record Notebook where
  constructor MkNotebook
  sections : List Section

-- Helper: All elements satisfy property
data All : {0 a : Type} -> (a -> Type) -> List a -> Type where
  AllNil : All p []
  AllCons : {0 x : a} -> {0 xs : List a} -> p x -> All p xs -> All p (x :: xs)

-- INVARIANT: All sections in a valid notebook are valid
data ValidNotebook : Notebook -> Type where
  MkValidNotebook : (nb : Notebook)
                 -> (allValid : All ValidSection nb.sections)
                 -> ValidNotebook nb

-- Flatten notebook to cell list (for output)
flattenNotebook : Notebook -> List Cell
flattenNotebook nb = concat (map flattenSection nb.sections)

-- Cell ordering properties
namespace OrderingRules
  -- Rule 1: Explanation before code within a section
  explanationBeforeCode : (explanations : List Cell)
                       -> (codes : List Cell)
                       -> List Cell
  explanationBeforeCode expl codes = expl ++ codes

  -- Rule 2: Section header comes first
  headerFirst : (header : Maybe Cell)
             -> (rest : List Cell)
             -> List Cell
  headerFirst Nothing rest = rest
  headerFirst (Just h) rest = h :: rest

-- Reordering operation: fix a section to satisfy invariants
reorderSection : Section -> Section
reorderSection s =
  MkSection
    s.header
    s.explanations
    s.codeCells
    s.otherCells
  -- Note: Python implementation will do actual cell classification

-- Reorder entire notebook
reorderNotebook : Notebook -> Notebook
reorderNotebook nb =
  MkNotebook (map reorderSection nb.sections)

-- Sequential section building algorithm (Python implementation)
-- Input: List of cells in original order
-- Output: List of sections with proper code association
--
-- Algorithm:
-- 1. Initialize: currentSection = Nothing, sections = []
-- 2. For each cell:
--    a. If cell is SectionWithExplanation or Header:
--       - Save currentSection to sections (if not Nothing)
--       - Start new section with this cell
--    b. If cell is Code:
--       - Add to currentSection.codeCells
--    c. If cell is Explanation:
--       - Add to currentSection.explanations
--    d. If cell is Other:
--       - Add to currentSection.otherCells
-- 3. Save final currentSection
--
-- This ensures code cells are associated with their preceding section

-- Classification functions (to be implemented in Python)
-- These define how to classify cells from raw notebook data
namespace Classification
  -- Note: Complex string operations will be implemented in Python
  -- Idris spec defines the logic, Python implements the runtime checks

  -- Classify cell content based on markdown text
  -- Python should check (in priority order):
  -- 1. If code type -> CodeBlock
  -- 2. If markdown starts with "##" AND contains explanation subsections
  --    -> SectionWithExplanation
  --    Subsection markers: "### 이론", "### 코드 설명", "### 설명"
  --                        "### theory", "### explanation", "### code explanation"
  --    Example: "## 1. Title\n\n### 이론\nContent..." -> SectionWithExplanation
  -- 3. If markdown starts with "##" (without explanation subsections) -> Header
  -- 4. If markdown contains explanation subsections (without ##) -> Explanation
  -- 5. Otherwise -> Other
  classifyContent : String -> CellType -> CellContent
  classifyContent text Markdown =
    -- Simplified for type checking - Python implements full logic
    Header text  -- Placeholder, Python determines actual classification
  classifyContent text Code = CodeBlock text

-- Example usage (specification)
namespace Example
  -- A valid section structure
  exampleSection : Section
  exampleSection = MkSection
    Nothing
    [MkCell Markdown (SectionWithExplanation "## 1. Generate\n\n### 이론\n기본 체인 학습")]
    [MkCell Code (CodeBlock "def generate(state): ...")]
    []

  -- Verify it's valid (conceptually)
  -- exampleValid : ValidSection exampleSection
  -- exampleValid = MkValidSection exampleSection
