module Domain.Workflow

import Domain.InvestmentAgent

%default total

-- ============================================
-- LangGraph 워크플로우 추상화
-- ============================================

||| 그래프 노드 타입
public export
data NodeType = Generate | QAEval | WebSearch | Start | End

||| 노드 간 엣지
public export
data Edge : NodeType -> NodeType -> Type where
  StartToGenerate : Edge Start Generate
  GenerateToEval : Edge Generate QAEval
  EvalToEnd : Edge QAEval End
  EvalToSearch : Edge QAEval WebSearch
  SearchToGenerate : Edge WebSearch Generate

||| 조건부 엣지의 조건
public export
data EdgeCondition = ScoreEnough | ScoreLow | MaxIterReached

||| 그래프 실행 경로
public export
data ExecutionPath : NodeType -> NodeType -> Type where
  Direct : Edge from to -> ExecutionPath from to
  Transitive : Edge from mid -> ExecutionPath mid to -> ExecutionPath from to

-- ============================================
-- 실행 의미론 (Semantics)
-- ============================================

||| 각 노드가 받는 입력과 출력 타입
public export
NodeIO : NodeType -> Type
NodeIO Start = AgentState
NodeIO Generate = AgentState
NodeIO QAEval = (AgentState, Answer)
NodeIO WebSearch = AgentState
NodeIO End = AgentState

||| 노드 실행 결과
public export
data NodeResult : NodeType -> Type where
  GenerateOut : Answer -> NodeResult Generate
  EvalOut : NextAction -> Evaluation -> NodeResult QAEval
  SearchOut : List SearchResult -> NodeResult WebSearch
  EndOut : AgentState -> NodeResult End

-- ============================================
-- 워크플로우 실행 추적
-- ============================================

||| 워크플로우 실행 히스토리
public export
data ExecutionTrace : Type where
  EmptyTrace : ExecutionTrace
  Step : (node : NodeType) ->
         (input : NodeIO node) ->
         (output : NodeResult node) ->
         ExecutionTrace ->
         ExecutionTrace

||| 실행 완료 조건
public export
data Terminated : ExecutionTrace -> Type where
  TerminatedAtEnd : (trace : ExecutionTrace) -> Terminated trace
  TerminatedAtMax : (trace : ExecutionTrace) -> Terminated trace

-- ============================================
-- 워크플로우 정확성 속성
-- ============================================

||| 모든 실행은 유한 시간 내 종료되어야 함
public export
data AlwaysTerminates : AgentState -> Type where
  BoundedIteration : (state : AgentState) ->
                     {auto prf : LTE state.iterationCount state.maxIterations} ->
                     AlwaysTerminates state

||| 컨텍스트는 단조 증가 (검색 결과는 누적만 됨)
public export
data MonotonicContext : AgentState -> AgentState -> Type where
  ContextGrows : (before : AgentState) ->
                 (after : AgentState) ->
                 (prf : isSubset before.context after.context) ->
                 MonotonicContext before after
  where
    -- Context의 부분집합 관계 정의가 필요하지만 여기서는 타입만 선언
    isSubset : SearchContext -> SearchContext -> Bool
    isSubset (MkContext xs) (MkContext ys) =
      all (\x => elem x ys) xs

||| 평가 점수가 threshold 이상이면 검색하지 않음
public export
data NoSearchWhenEnough : AgentState -> Evaluation -> NextAction -> Type where
  HighScoreEnds : (state : AgentState) ->
                  (eval : Evaluation) ->
                  (action : NextAction) ->
                  {auto prf : GTE (calculateTotal eval) (getThreshold state.searchThreshold)} ->
                  {auto notNeeded : eval.needsMoreInfo = False} ->
                  action = Enough ->
                  NoSearchWhenEnough state eval action
  where
    getThreshold : Score -> Nat
    getThreshold (MkScore n) = n
