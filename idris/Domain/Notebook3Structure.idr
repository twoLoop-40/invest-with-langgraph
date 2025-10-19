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
-- Pattern: Theory (markdown) → Code(s)
-- Some sections have multiple code cells (e.g., Section 1 has 2 code cells)
record Section where
  constructor MkSection
  sectionNumber : Nat           -- 1-8
  theoryIdx : CellIndex         -- "### 이론" cell
  codeIndices : List CellIndex  -- Code cell(s) - can be multiple

-- Check ascending order
isAscendingOrder : List PracticeProblem -> Bool
isAscendingOrder [] = True
isAscendingOrder [x] = True
isAscendingOrder (x :: y :: rest) =
  x.problemNumber < y.problemNumber && isAscendingOrder (y :: rest)

-- Notebook 3 structure
-- More complex: Environment → Title → Sections with theory → Practice problems
record Notebook3Structure where
  constructor MkNotebook3
  envHeader : CellIndex                -- ## 환경 설정
  title : CellIndex                    -- # Tool 기반 투자 분석 Agent
  sectionHeaders : List CellIndex      -- ## 1. ..., ## 2. ..., etc
  sections : List Section              -- Sections 1-7 with theory (섹션 8은 없음)
  practiceHeader : CellIndex           -- ## 9. 실습 문제
  practiceProblems : List PracticeProblem  -- Problems 1-10 in ASCENDING order
  divider : CellIndex                  -- ---
  answers : List CellIndex             -- Answer code cells

-- Concrete structure for Notebook 3 (AFTER REORDERING)
-- Now follows markdown → code pattern consistently
notebook3Structure : Notebook3Structure
notebook3Structure = MkNotebook3
  0                              -- ## 환경 설정
  1                              -- # Tool 기반 투자 분석 Agent
  [2, 6, 9, 12, 15, 18, 21, 24]  -- Section headers ## 1-8
  [ MkSection 1 3 [4, 5]         -- Section 1: 이론 (3) → 환경 설정 (4), 도구 임포트 (5)
  , MkSection 2 7 [8]            -- Section 2: 이론 (7) → Agent 생성 (8)
  , MkSection 3 10 [11]          -- Section 3: 이론 (10) → 그래프 시각화 (11)
  , MkSection 4 13 [14]          -- Section 4: 이론 (13) → 헬퍼 함수 (14)
  , MkSection 5 16 [17]          -- Section 5: 이론 (16) → 테스트 1 (17)
  , MkSection 6 19 [20]          -- Section 6: 이론 (19) → 테스트 2 (20)
  , MkSection 7 22 [23]          -- Section 7: 이론 (22) → 테스트 3 (23)
  , MkSection 8 25 [26]          -- Section 8: 이론 (25) → 불변 속성 검증 (26)
  ]
  27                             -- ## 9. 실습 문제
  [ MkProblem 1 28 29            -- Problem 1: 도구 개수 (markdown 28, code 29)
  , MkProblem 2 30 31            -- Problem 2: 도구 이름 (markdown 30, code 31)
  , MkProblem 3 32 33            -- Problem 3: 특정 도구 찾기 (markdown 32, code 33)
  , MkProblem 4 34 35            -- Problem 4: yfinance 주가 (markdown 34, code 35)
  , MkProblem 5 36 37            -- Problem 5: 최고가/최저가 (markdown 36, code 37)
  , MkProblem 6 38 39            -- Problem 6: 이동평균선 (markdown 38, code 39)
  , MkProblem 7 40 41            -- Problem 7: 도구 함수 (markdown 40, code 41)
  , MkProblem 8 42 43            -- Problem 8: @tool 데코레이터 (markdown 42, code 43)
  , MkProblem 9 44 45            -- Problem 9: ToolAgentState (markdown 44, code 45)
  , MkProblem 10 46 47           -- Problem 10: 나만의 질문 (markdown 46, code 47)
  ]
  48                             -- ---
  [49]                           -- Answers: 정답 예시 (49)

-- Validation
isNotebook3Valid : Notebook3Structure -> Bool
isNotebook3Valid nb =
  isAscendingOrder nb.practiceProblems &&
  length nb.sections == 8 &&
  length nb.practiceProblems == 10

-- Code cell comment pattern for Notebook 3
-- Each code cell should have a comment matching its section:
-- Section 1: # 1. 투자 분석 도구 가져오기
-- Section 2: # 2. ReAct Agent 생성
-- ...
-- This ensures markdown-code correspondence
