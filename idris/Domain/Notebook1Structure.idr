module Notebook1Structure

%default total

-- Cell index (0-based)
CellIndex : Type
CellIndex = Nat

-- Practice problem with verified ascending order
record PracticeProblem where
  constructor MkProblem
  problemNumber : Nat        -- Must be 1, 2, 3
  markdownIdx : CellIndex
  codeIdx : CellIndex

-- Check ascending order
isAscendingOrder : List PracticeProblem -> Bool
isAscendingOrder [] = True
isAscendingOrder [x] = True
isAscendingOrder (x :: y :: rest) =
  x.problemNumber < y.problemNumber && isAscendingOrder (y :: rest)

-- Notebook 1 structure
-- Title → Package imports → Sections 1-10 → Practice problems 1-3 → Divider → Answers
record Notebook1Structure where
  constructor MkNotebook1
  title : CellIndex                    -- 0: # LangGraph 기초
  packageImports : CellIndex           -- 1: # 패키지
  sections : List (CellIndex, CellIndex)  -- (markdown, code) pairs for sections 1-10
  practiceHeader : CellIndex           -- ## 실습 문제
  practiceProblems : List PracticeProblem  -- Problems 1-3 in ASCENDING order
  divider : CellIndex                  -- ---
  answers : CellIndex                  -- Answer code

-- Concrete structure for Notebook 1
-- Based on analysis: 10 main sections + 3 practice problems
notebook1Structure : Notebook1Structure
notebook1Structure = MkNotebook1
  0                              -- Title: # LangGraph 기초
  1                              -- Package: # 패키지
  [ (2, 3)                       -- Section 1: ## 1. 환경 변수 로드 → from dotenv
  , (4, 5)                       -- Section 2: ## 2. LLM 기본 사용법 → # 간단한 질문
  , (6, 7)                       -- Section 3: ## 3. Agent 상태 정의 → # State 생성
  , (8, 9)                       -- Section 4: ## 4. StateGraph 생성 → from langgraph
  , (10, 11)                     -- Section 5: ## 5. 노드 함수 정의 → def generate
  , (12, 13)                     -- Section 6: ## 6. 그래프에 노드 추가 → add_node
  , (14, 15)                     -- Section 7: ## 7. 엣지 연결 → START, END
  , (16, 17)                     -- Section 8: ## 8. 그래프 컴파일 → compile()
  , (18, 19)                     -- Section 9: ## 9. 그래프 시각화 → display, Image
  , (20, 21)                     -- Section 10: ## 10. 그래프 실행 → HumanMessage
  ]
  22                             -- Practice header: ## 실습 문제
  [ MkProblem 1 30 23            -- Problem 1: ChatOpenAI로 질문 (현재: markdown 30, code 23)
  , MkProblem 2 29 24            -- Problem 2: 노드 함수 만들기 (현재: markdown 29, code 24)
  , MkProblem 3 28 25            -- Problem 3: 그래프 실행 (현재: markdown 28, code 25)
  ]
  27                             -- Divider: ---
  26                             -- Answers: # 정답 예시

-- Validation
isNotebook1Valid : Notebook1Structure -> Bool
isNotebook1Valid nb =
  isAscendingOrder nb.practiceProblems &&
  length nb.sections == 10 &&
  length nb.practiceProblems == 3

-- Code cell comments mapping
-- Each code cell should have a comment indicating its section
-- Example: Cell 3 → "# 1. 환경 변수 로드"
--          Cell 5 → "# 2. LLM 기본 사용법"
-- This helps maintain correspondence between markdown and code
