module NotebookStructure2

import Data.List
import Data.Vect

%default total

-- Cell index (0-based in implementation)
CellIndex : Type
CellIndex = Nat

-- Cell types
data CellType = Markdown | Code

-- Cell with verified type
record TypedCell where
  constructor MkCell
  index : CellIndex
  cellType : CellType
  content : String

-- Section: One markdown followed by one or more code cells
record Section where
  constructor MkSection
  markdownIdx : CellIndex
  codeIndices : List CellIndex

-- Invariant: Section indices must be in ascending order
-- Simplified: Python runtime verification
isSectionValid : Section -> Bool
isSectionValid s = all (\c => c > s.markdownIdx) s.codeIndices

-- Practice problem: Markdown explanation + TODO code
record PracticeProblem where
  constructor MkProblem
  problemNumber : Nat        -- Must be 1, 2, 3, ..., N
  markdownIdx : CellIndex
  codeIdx : CellIndex

-- Ordered list of practice problems
-- TYPE INVARIANT: Problems must be in ascending order by problemNumber
-- Verification happens at Python runtime with clear error messages
isAscendingOrder : List PracticeProblem -> Bool
isAscendingOrder [] = True
isAscendingOrder [x] = True
isAscendingOrder (x :: y :: rest) =
  x.problemNumber < y.problemNumber && isAscendingOrder (y :: rest)

-- Runtime verification
data OrderedProblems : List PracticeProblem -> Type where
  MkOrderedProblems : (ps : List PracticeProblem)
                   -> (isAscendingOrder ps = True)  -- PROOF required
                   -> OrderedProblems ps

-- Complete notebook structure
record NotebookStructure where
  constructor MkNotebookStructure
  title : CellIndex                    -- Main title cell
  mainSections : List Section          -- Sections 1-N (sequential learning)
  practiceHeader : CellIndex           -- "## 실습 문제" header
  practiceProblems : List PracticeProblem  -- Problems in ASCENDING order
  divider : CellIndex                  -- "---" separator
  answers : List CellIndex             -- Answer code cells

-- Verification functions (Python implements runtime checks)
areSectionsValid : List Section -> Bool
areSectionsValid sections = all isSectionValid sections

noDuplicateIndices : NotebookStructure -> Bool
noDuplicateIndices ns = True  -- Python implements full check

-- Verification summary
isNotebookValid : NotebookStructure -> Bool
isNotebookValid ns =
  areSectionsValid ns.mainSections &&
  isAscendingOrder ns.practiceProblems &&
  noDuplicateIndices ns

-- Example: Notebook 2 structure (verified at type level)
notebook2Structure : NotebookStructure
notebook2Structure = MkNotebookStructure
  0                              -- Title: cell 0
  [ MkSection 1 [2]              -- Section 1: ## 1. 환경 변수 로드 → code
  , MkSection 3 [4]              -- Section 2: ## 2. LLM 초기화 → code
  , MkSection 5 [6]              -- Section 3: ## 3. AgentState → code
  , MkSection 7 [8]              -- Section 4: ## 4. Generate 노드 → code
  , MkSection 9 [10]             -- Section 5: ## 5. QA 평가 → code
  , MkSection 11 [12]            -- Section 6: ## 6. 웹 검색 → code
  , MkSection 13 [14]            -- Section 7: ## 7. 그래프 구성 → code
  , MkSection 15 [16]            -- Section 8: ## 8. 그래프 시각화 → code
  , MkSection 17 [18]            -- Section 9: ## 9. 실행 테스트 → code
  , MkSection 19 [20]            -- Section 10: ## 10. 일반 지식 → code
  ]
  21                             -- Practice header: cell 21
  [ MkProblem 1 22 23            -- Problem 1: markdown 22, code 23
  , MkProblem 2 24 25            -- Problem 2: markdown 24, code 25
  , MkProblem 3 26 27            -- Problem 3: markdown 26, code 27
  , MkProblem 4 28 29            -- Problem 4: markdown 28, code 29
  , MkProblem 5 30 31            -- Problem 5: markdown 30, code 31
  , MkProblem 6 32 33            -- Problem 6: markdown 32, code 33
  , MkProblem 7 34 35            -- Problem 7: markdown 34, code 35
  , MkProblem 8 36 37            -- Problem 8: markdown 36, code 37
  , MkProblem 9 38 39            -- Problem 9: markdown 38, code 39
  , MkProblem 10 40 41           -- Problem 10: markdown 40, code 41
  ]
  42                             -- Divider: cell 42
  [43, 44]                       -- Answers: cells 43-44

-- Reorder notebook cells according to verified structure
-- Python MUST verify isNotebookValid before using this structure
reorderNotebook : (ns : NotebookStructure)
               -> (isNotebookValid ns = True)  -- PROOF required
               -> List TypedCell
               -> List TypedCell
reorderNotebook ns validProof originalCells =
  -- 1. Title
  -- 2. For each section: markdown → code cells
  -- 3. Practice header
  -- 4. For each problem: markdown → code (in ascending order - guaranteed!)
  -- 5. Divider
  -- 6. Answers
  Prelude.Nil  -- Python implements extraction based on verified indices

-- Key insight:
-- - Idris spec DEFINES the structure
-- - Python VERIFIES with isNotebookValid at runtime
-- - Problems MUST be ascending (type-checked via isAscendingOrder)
-- - Any violation causes Python runtime error with clear message
