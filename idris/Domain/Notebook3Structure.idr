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

-- Section with theory and code
-- Pattern: Theory (markdown) → Code
record Section where
  constructor MkSection
  sectionNumber : Nat           -- 1-8
  theoryIdx : CellIndex         -- "### 이론" cell
  codeIdx : CellIndex           -- Code cell

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

-- Concrete structure for Notebook 3
-- Current analysis shows complex interleaving - needs reordering
notebook3Structure : Notebook3Structure
notebook3Structure = MkNotebook3
  0                              -- ## 환경 설정
  1                              -- # Tool 기반 투자 분석 Agent
  [2, 5, 8, 11, 14, 17, 20, 23]  -- Section headers ## 1-8
  [ MkSection 1 3 4              -- Section 1: 이론 (3) → 환경 변수 로드 (4)
  , MkSection 2 6 7              -- Section 2: 이론 (6) → import sys (7)
  , MkSection 3 9 10             -- Section 3: 이론 (9) → ChatOpenAI (10)
  , MkSection 4 12 13            -- Section 4: 이론 (12) → display, Image (13)
  , MkSection 5 15 16            -- Section 5: 이론 (15) → def run_agent (16)
  , MkSection 6 18 19            -- Section 6: 이론 (18) → result1 (19)
  , MkSection 7 21 22            -- Section 7: 이론 (21) → result2 (22)
  , MkSection 8 24 25            -- Section 8: 이론 (24) → result3 (25)
  ]
  26                             -- ## 9. 실습 문제
  [ MkProblem 1 28 31            -- Problem 1: 도구 개수 (markdown 28, code 31)
  , MkProblem 2 29 33            -- Problem 2: 도구 이름 (markdown 29, code 33)
  , MkProblem 3 30 35            -- Problem 3: 특정 도구 찾기 (markdown 30, code 35)
  , MkProblem 4 32 37            -- Problem 4: yfinance 주가 (markdown 32, code 37)
  , MkProblem 5 34 39            -- Problem 5: 최고가/최저가 (markdown 34, code 39)
  , MkProblem 6 36 41            -- Problem 6: 이동평균선 (markdown 36, code 41)
  , MkProblem 7 38 43            -- Problem 7: 도구 함수 (markdown 38, code 43)
  , MkProblem 8 40 45            -- Problem 8: @tool 데코레이터 (markdown 40, code 45)
  , MkProblem 9 42 46            -- Problem 9: ToolAgentState (markdown 42, code 46)
  , MkProblem 10 44 47           -- Problem 10: 나만의 질문 (markdown 44, code 47)
  ]
  49                             -- ---
  [27, 48]                       -- Answers: ToolHistory import (27), 정답 예시 (48)

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
