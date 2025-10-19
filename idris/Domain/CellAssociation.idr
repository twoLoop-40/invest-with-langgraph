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

-- Apply association map to reorder cells
-- Input: original cells, association map
-- Output: reordered cells (explanation followed immediately by its code cells)
--
-- Algorithm:
-- 1. For each association:
--    a. Output explanation cell
--    b. Output all associated code cells
-- 2. Output any unassociated cells at the end
--
-- Example transformation:
--   Original: [Expl1, Expl2, Expl3, Code1, Code2, Code3]
--   Map: Expl1->Code1, Expl2->Code2, Expl3->Code3
--   Result:  [Expl1, Code1, Expl2, Code2, Expl3, Code3]

-- Notebook 1 association map (from analysis)
-- Based on keyword matching and sequential order
notebook1Associations : AssociationMap
notebook1Associations = MkAssociationMap
  [ MkAssociation 1 [12]        -- ## 1. 환경 변수 로드 -> from dotenv import load_dotenv
  , MkAssociation 2 [13]        -- ## 2. LLM 기본 사용법 -> 간단한 질문 테스트
  , MkAssociation 3 [14]        -- ## 3. Agent 상태 정의 -> State 생성
  , MkAssociation 4 [15]        -- ## 4. StateGraph 생성 -> from langgraph.graph
  , MkAssociation 5 [16]        -- ## 5. 노드 함수 정의 -> def generate
  , MkAssociation 6 [17]        -- ## 6. 그래프에 노드 추가 -> add_node
  , MkAssociation 7 [18]        -- ## 7. 엣지 연결 -> add_edge
  , MkAssociation 8 [20]        -- ## 8. 그래프 컴파일 -> compile()
  , MkAssociation 9 [21]        -- ## 9. 그래프 시각화 -> draw_mermaid
  , MkAssociation 10 [22]       -- ## 10. 그래프 실행 테스트 -> HumanMessage
  , MkAssociation 19 [23, 24, 25, 26]  -- ## 실습 문제 -> TODO cells
  ]

-- Notebook 2 association map (from analysis)
-- Based on comments in code cells that match section titles
notebook2Associations : AssociationMap
notebook2Associations = MkAssociationMap
  [ MkAssociation 1 [11]        -- ## 1. 환경 변수 로드 -> # 환경 변수 로드
  , MkAssociation 2 [12]        -- ## 2. LLM 초기화 -> # LLM 초기화
  , MkAssociation 3 [13]        -- ## 3. AgentState 정의 -> # State 정의
  , MkAssociation 4 [14]        -- ## 4. Generate 노드 -> # Generate 노드
  , MkAssociation 5 [15]        -- ## 5. QA 평가 노드 -> # QA 평가 노드
  , MkAssociation 6 [16]        -- ## 6. 웹 검색 노드 -> # Web Search 노드
  , MkAssociation 7 [17]        -- ## 7. 그래프 구성 -> # 그래프 구성
  , MkAssociation 8 [19]        -- ## 8. 그래프 시각화 -> # 그래프 시각화
  , MkAssociation 9 [20]        -- ## 9. 실행 테스트 -> # 실행 테스트
  , MkAssociation 10 [21]       -- ## 10. 일반 지식 질문 테스트 -> # 웹 검색 없이도 답변 가능
  , MkAssociation 11 [22, 23, 24, 25, 26, 27, 28, 29, 30, 31]  -- ## 실습 문제 -> TODO cells
  ]
  -- Note: Cell indices are 0-based in implementation
  -- Adjust by -1 when implementing in Python
