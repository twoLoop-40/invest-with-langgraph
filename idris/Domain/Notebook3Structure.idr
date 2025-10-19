module Notebook3Structure

%default total

-- Cell index (0-based)
CellIndex : Type
CellIndex = Nat

-- Practice problem
record PracticeProblem where
  constructor MkProblem
  problemNumber : Nat
  markdownIdx : CellIndex
  codeIdx : CellIndex

-- Section with theory and code(s)
-- Pattern for each section:
--   ## N. Section Header (markdown)
--   ### 이론 (markdown with theory explanation)
--   [Code cell 1]
--   [Code cell 2] (optional - only Section 1 has 2 code cells)
--   ... next section
--
-- Section 1 is special: has TWO code cells
--   - Code cell 1: # 1. 투자 분석 도구 가져오기 - 환경 설정 (load_dotenv)
--   - Code cell 2: # 1. 투자 분석 도구 가져오기 - 도구 임포트 (import tools)
-- All other sections (2-8): have ONE code cell each
record Section where
  constructor MkSection
  sectionNumber : Nat           -- 1-8
  theoryIdx : CellIndex         -- "### 이론" cell (theory markdown)
  codeIndices : List CellIndex  -- Code cell(s): [1 cell] for sections 2-8, [2 cells] for section 1

-- Check ascending order
isAscendingOrder : List PracticeProblem -> Bool
isAscendingOrder [] = True
isAscendingOrder [x] = True
isAscendingOrder (x :: y :: rest) =
  x.problemNumber < y.problemNumber && isAscendingOrder (y :: rest)

-- Notebook 3 structure
-- Pattern: Environment → Title → 8 Main Sections → Practice Problems → Answers
--
-- Main Sections (1-8): Each follows "Header → Theory → Code(s)" pattern
--   Section 1: 투자 분석 도구 가져오기 (2 code cells: 환경 설정 + 도구 임포트)
--   Section 2: ReAct Agent 생성 (1 code cell)
--   Section 3: 그래프 구조 시각화 (1 code cell)
--   Section 4: Agent 실행 헬퍼 함수 (1 code cell)
--   Section 5: 테스트 1: 간단한 주가 조회 (1 code cell)
--   Section 6: 테스트 2: 복합 분석 (1 code cell)
--   Section 7: 테스트 3: 미국 주식 분석 (1 code cell)
--   Section 8: 불변 속성 검증 예시 (1 code cell)
--
-- Practice Problems (Section 9): 10 problems, each with markdown + code pair
record Notebook3Structure where
  constructor MkNotebook3
  envHeader : CellIndex                -- Cell 0: ## 환경 설정
  title : CellIndex                    -- Cell 1: # Tool 기반 투자 분석 Agent
  sectionHeaders : List CellIndex      -- Cells 2,6,9,12,15,18,21,24: ## 1-8 headers
  sections : List Section              -- 8 sections with theory + code(s)
  practiceHeader : CellIndex           -- Cell 27: ## 9. 실습 문제
  practiceProblems : List PracticeProblem  -- 10 problems in ASCENDING order (1→10)
  divider : CellIndex                  -- Cell 48: --- (divider before answers)
  answers : List CellIndex             -- Cell 49: 정답 예시 code

-- Concrete structure for Notebook 3 (AFTER REORDERING - 2025-01-19)
-- Follows consistent "markdown → code" pattern throughout
--
-- Total: 51 cells (indices 0-50)
--   Cells 0-1: Environment setup and title
--   Cells 2-27: 8 main sections (headers + theory + code)
--   Cells 28-48: Practice problems section (header + 10 problems)
--   Cells 49-50: Divider and answers
notebook3Structure : Notebook3Structure
notebook3Structure = MkNotebook3
  0                              -- Cell 0: ## 환경 설정
  1                              -- Cell 1: # Tool 기반 투자 분석 Agent (ReAct 패턴)
  [2, 6, 9, 12, 16, 19, 22, 25]  -- Section headers: ## 1-8 (actual indices from notebook)
  [ MkSection 1 3 [4, 5]         -- Section 1 (cells 2-5): 투자 분석 도구 가져오기
                                 --   Cell 2: ## 1. Header
                                 --   Cell 3: ### 이론
                                 --   Cell 4: Code - 환경 설정 (load_dotenv)
                                 --   Cell 5: Code - 도구 임포트 (import AVAILABLE_TOOLS)
  , MkSection 2 7 [8]            -- Section 2 (cells 6-8): ReAct Agent 생성
  , MkSection 3 10 [11]          -- Section 3 (cells 9-11): 그래프 구조 시각화
  , MkSection 4 14 [15]          -- Section 4 (cells 12-15): Agent 실행 헬퍼 함수
                                 --   Note: Has extra markdown at cell 13
  , MkSection 5 17 [18]          -- Section 5 (cells 16-18): 테스트 1
  , MkSection 6 20 [21]          -- Section 6 (cells 19-21): 테스트 2
  , MkSection 7 23 [24]          -- Section 7 (cells 22-24): 테스트 3
  , MkSection 8 26 [27]          -- Section 8 (cells 25-27): 불변 속성 검증
  ]
  28                             -- Cell 28: ## 9. 실습 문제
  [ MkProblem 1 29 30            -- Problem 1 (cells 29-30): 도구 개수 확인
  , MkProblem 2 31 32            -- Problem 2 (cells 31-32): 도구 이름 출력
  , MkProblem 3 33 34            -- Problem 3 (cells 33-34): 특정 도구 찾기
  , MkProblem 4 35 36            -- Problem 4 (cells 35-36): yfinance 주가 가져오기
  , MkProblem 5 37 38            -- Problem 5 (cells 37-38): 최고가/최저가 찾기
  , MkProblem 6 39 40            -- Problem 6 (cells 39-40): 이동평균선 계산
  , MkProblem 7 41 42            -- Problem 7 (cells 41-42): 도구 함수 만들기
  , MkProblem 8 43 44            -- Problem 8 (cells 43-44): @tool 데코레이터
  , MkProblem 9 45 46            -- Problem 9 (cells 45-46): ToolAgentState 사용
  , MkProblem 10 47 48           -- Problem 10 (cells 47-48): 나만의 질문
  ]
  49                             -- Cell 49: --- (divider)
  [50]                           -- Cell 50: 정답 예시 (code)

-- Validation functions
isNotebook3Valid : Notebook3Structure -> Bool
isNotebook3Valid nb =
  -- Practice problems must be in ascending order (1→2→...→10)
  isAscendingOrder nb.practiceProblems &&
  -- Must have exactly 8 main sections
  length nb.sections == 8 &&
  -- Must have exactly 10 practice problems
  length nb.practiceProblems == 10 &&
  -- Section 1 must have 2 code cells, others must have 1
  length (head nb.sections).codeIndices == 2
  where
    head : List Section -> Section
    head (s :: _) = s
    head [] = MkSection 0 0 []  -- Should never happen if length check passes

-- Code cell comment pattern for Notebook 3
-- Each code cell MUST have a comment matching its section number:
--   Section 1 code cells: # 1. 투자 분석 도구 가져오기 - 환경 설정
--                        # 1. 투자 분석 도구 가져오기 - 도구 임포트
--   Section 2 code cell:  # 2. ReAct Agent 생성
--   Section 3 code cell:  # 3. 그래프 구조 시각화
--   ...
-- This ensures clear markdown-code correspondence for students
