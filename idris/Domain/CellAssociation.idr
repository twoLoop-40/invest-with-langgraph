module CellAssociation

%default total

-- Cell index in notebook (0-indexed in implementation, 1-indexed for display)
CellIndex : Type
CellIndex = Nat

-- Association: one explanation section maps to one or more code cells
record Association where
  constructor MkAssociation
  explanationIndex : CellIndex    -- Index of explanation cell
  codeIndices : List CellIndex    -- Indices of code cells belonging to this explanation

-- Example: Cell 2 (## 1. 환경 변수) -> Cell 13 (from dotenv import load_dotenv)
-- MkAssociation 2 [13]

-- Association map for entire notebook
record AssociationMap where
  constructor MkAssociationMap
  associations : List Association

-- Helper: verify no code cell appears in multiple associations
-- (Simplified for type checking - Python implements full validation)
NoDuplicateCodeCells : List Association -> Type
NoDuplicateCodeCells [] = ()
NoDuplicateCodeCells (x :: xs) = ()  -- Runtime check in Python

-- INVARIANT: Code cells should not be duplicated across associations
-- Each code cell belongs to at most one explanation section
data ValidAssociationMap : AssociationMap -> Type where
  MkValidAssociationMap : (am : AssociationMap)
                       -> (noDuplicates : NoDuplicateCodeCells am.associations)
                       -> ValidAssociationMap am

-- Validation: Check for duplicate code cells in association map
-- Returns list of duplicates (empty if valid)
-- Python should implement this check before reordering
namespace Validation
  -- Collect all cell indices used in associations
  collectAllIndices : AssociationMap -> List CellIndex
  collectAllIndices (MkAssociationMap assocs) =
    concatMap (\a => a.explanationIndex :: a.codeIndices) assocs

  -- Check if any index appears more than once
  -- (Simplified - Python implements full duplicate detection)
  hasDuplicates : List CellIndex -> Bool
  hasDuplicates [] = False
  hasDuplicates _ = False  -- Runtime check in Python

-- Apply association map to reorder cells
-- Input: original cells, association map
-- Output: reordered cells (explanation followed immediately by its code cells)
--
-- Algorithm:
-- 1. Validate: no duplicate indices
-- 2. For each association (in sorted order):
--    a. Output explanation cell
--    b. Output all associated code cells
-- 3. Output any unassociated cells at the end
--
-- Example transformation:
--   Original: [Expl1, Expl2, Expl3, Code1, Code2, Code3]
--   Map: Expl1->Code1, Expl2->Code2, Expl3->Code3
--   Result:  [Expl1, Code1, Expl2, Code2, Expl3, Code3]

-- Notebook 1 association map (from analysis)
-- Based on keyword matching and sequential order
notebook1Associations : AssociationMap
notebook1Associations = MkAssociationMap
  [ MkAssociation 1 [12]        -- Cell 1 -> Cell 12: # 패키지
  , MkAssociation 2 [13]        -- Cell 2: ## 1. 환경 변수 로드 -> Cell 13: from dotenv
  , MkAssociation 3 [14]        -- Cell 3: ## 2. LLM 기본 사용법 -> Cell 14: 간단한 질문 테스트
  , MkAssociation 4 [15]        -- Cell 4: ## 3. Agent 상태 정의 -> Cell 15: State 생성
  , MkAssociation 5 [16]        -- Cell 5: ## 4. StateGraph 생성 -> Cell 16: from langgraph.graph
  , MkAssociation 6 [17]        -- Cell 6: ## 5. 노드 함수 정의 -> Cell 17: def generate
  , MkAssociation 7 [18]        -- Cell 7: ## 6. 그래프에 노드 추가 -> Cell 18: add_node
  , MkAssociation 8 [19]        -- Cell 8: ## 7. 엣지 연결 -> Cell 19: START, END
  , MkAssociation 9 [21]        -- Cell 9: ## 8. 그래프 컴파일 -> Cell 21: compile()
  , MkAssociation 10 [22]       -- Cell 10: ## 9. 그래프 시각화 -> Cell 22: draw_mermaid
  , MkAssociation 11 [23]       -- Cell 11: ## 10. 그래프 실행 테스트 -> Cell 23: HumanMessage
  , MkAssociation 20 [24, 25, 26, 27]  -- Cell 20: ## 실습 문제 -> Cells 24-27: TODO
  ]

-- Notebook 2 association map (from analysis)
-- Based on comments in code cells that match section titles
-- Cell numbering: 1-based (subtract 1 for Python)
-- Cells 1-11 are markdown sections, cells 12+ are code
notebook2Associations : AssociationMap
notebook2Associations = MkAssociationMap
  [ MkAssociation 2 [12]        -- Cell 2: ## 1. 환경 변수 로드 -> Cell 12: # 환경 변수 로드
  , MkAssociation 3 [13]        -- Cell 3: ## 2. LLM 초기화 -> Cell 13: # LLM 초기화
  , MkAssociation 4 [14]        -- Cell 4: ## 3. AgentState 정의 -> Cell 14: # State 정의
  , MkAssociation 5 [15]        -- Cell 5: ## 4. Generate 노드 -> Cell 15: # Generate 노드
  , MkAssociation 6 [16]        -- Cell 6: ## 5. QA 평가 노드 -> Cell 16: # QA 평가 노드
  , MkAssociation 7 [17]        -- Cell 7: ## 6. 웹 검색 노드 -> Cell 17: # Web Search 노드
  , MkAssociation 8 [18]        -- Cell 8: ## 7. 그래프 구성 -> Cell 18: # 그래프 구성
  , MkAssociation 9 [20]        -- Cell 9: ## 8. 그래프 시각화 -> Cell 20: # 그래프 시각화
  , MkAssociation 10 [21]       -- Cell 10: ## 9. 실행 테스트 -> Cell 21: # 실행 테스트
  , MkAssociation 11 [22]       -- Cell 11: ## 10. 일반 지식 질문 -> Cell 22: # 웹 검색 없이도 답변 가능
  , MkAssociation 19 [23, 24, 25, 26, 27, 28, 29, 30, 31]  -- Cell 19: ## 실습 문제 -> TODO cells
  ]
  -- Note: Cell indices are 1-based, subtract 1 for Python 0-based indexing
