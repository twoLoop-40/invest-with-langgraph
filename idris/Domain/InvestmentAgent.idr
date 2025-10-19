module InvestmentAgent

import Data.List
import Data.String
import Data.Nat

%default total

-- ============================================
-- 기본 타입 정의
-- ============================================

||| 사용자 질문
public export
Query : Type
Query = String

||| LLM이 생성한 답변
public export
Answer : Type
Answer = String

||| 평가 점수 (0-20점)
||| 주의: 런타임에 범위 검증 필요
public export
data Score : Type where
  MkScore : (n : Nat) -> Score

||| 평가 코멘트
public export
Comment : Type
Comment = String

-- ============================================
-- 웹 검색 관련 타입
-- ============================================

||| 웹 검색 결과
public export
record SearchResult where
  constructor MkSearchResult
  title : String
  url : String
  content : String
  rawContent : String

||| 검색 컨텍스트 (중복 URL 제거됨)
public export
data SearchContext : Type where
  MkContext : List SearchResult -> SearchContext

||| URL 중복 제거 보장
public export
deduplicateByURL : List SearchResult -> List SearchResult
deduplicateByURL = nubBy (\a, b => url a == url b)

-- ============================================
-- Agent 상태
-- ============================================

||| Agent의 현재 상태
public export
record AgentState where
  constructor MkAgentState
  query : Query                          -- 사용자 질문
  context : SearchContext                -- 누적된 검색 결과
  answer : Answer                        -- 현재 답변
  searchThreshold : Score                -- 검색 트리거 점수 기준
  iterationCount : Nat                   -- 현재 반복 횟수
  maxIterations : Nat                    -- 최대 반복 횟수
  evaluationScore : Maybe Score          -- 마지막 평가 점수
  evaluationComment : Maybe Comment      -- 평가 코멘트
  errorMessage : Maybe String            -- 에러 메시지

||| 초기 상태 생성
public export
initialState : Query -> Nat -> Nat -> AgentState
initialState q threshold maxIter =
  MkAgentState
    { query = q
    , context = MkContext []
    , answer = ""
    , searchThreshold = MkScore threshold
    , iterationCount = 0
    , maxIterations = maxIter
    , evaluationScore = Nothing
    , evaluationComment = Nothing
    , errorMessage = Nothing
    }

-- ============================================
-- 평가 기준
-- ============================================

||| 평가 차원 (각 0-5점)
public export
data EvaluationDimension = Accuracy | Completeness | Clarity | Relevance

||| 차원별 점수 (0-5점)
||| 주의: 런타임에 범위 검증 필요
public export
data DimensionScore : Type where
  MkDimensionScore : (dim : EvaluationDimension) ->
                     (n : Nat) ->
                     DimensionScore

||| 전체 평가 결과
public export
record Evaluation where
  constructor MkEvaluation
  accuracy : Nat       -- 0-5
  completeness : Nat   -- 0-5
  clarity : Nat        -- 0-5
  relevance : Nat      -- 0-5
  totalScore : Nat     -- 0-20 (자동 계산)
  comment : Comment
  needsMoreInfo : Bool

||| 평가 점수 계산
public export
calculateTotal : Evaluation -> Nat
calculateTotal eval =
  eval.accuracy + eval.completeness + eval.clarity + eval.relevance

-- ============================================
-- 노드 동작 (순수 함수로 명세)
-- ============================================

||| Generate 노드의 결과
public export
data GenerateResult =
  Success Answer |
  Failure String

||| QA Evaluation 결과에 따른 다음 액션
public export
data NextAction =
  Enough |           -- 충분한 답변, 종료
  NeedsSearch |      -- 웹 검색 필요
  MaxReached         -- 최대 반복 도달

||| 평가 결과에 따른 액션 결정 로직
public export
decideNextAction : AgentState -> Evaluation -> NextAction
decideNextAction state eval =
  if state.iterationCount >= state.maxIterations
    then MaxReached
    else
      let MkScore threshold = state.searchThreshold
          totalScore = calculateTotal eval
      in if totalScore >= threshold && not eval.needsMoreInfo
           then Enough
           else NeedsSearch

-- ============================================
-- 상태 전이 함수
-- ============================================

||| Generate 노드 실행 후 상태 업데이트
public export
updateAfterGenerate : AgentState -> Answer -> AgentState
updateAfterGenerate state newAnswer =
  { answer := newAnswer
  , iterationCount := state.iterationCount + 1
  } state

||| 웹 검색 후 컨텍스트 추가
public export
updateAfterSearch : AgentState -> List SearchResult -> AgentState
updateAfterSearch state newResults =
  let MkContext existing = state.context
      combined = existing ++ newResults
      deduplicated = deduplicateByURL combined
  in { context := MkContext deduplicated } state

||| 평가 후 상태 업데이트
public export
updateAfterEvaluation : AgentState -> Evaluation -> AgentState
updateAfterEvaluation state eval =
  { evaluationScore := Just (MkScore (calculateTotal eval))
  , evaluationComment := Just eval.comment
  } state

||| 에러 발생 시 상태 업데이트
public export
updateWithError : AgentState -> String -> AgentState
updateWithError state errMsg =
  { errorMessage := Just errMsg } state

-- ============================================
-- 워크플로우 불변 속성
-- ============================================

||| 반복 횟수는 항상 최대값 이하여야 함
public export
iterationBound : (state : AgentState) -> Type
iterationBound state = LTE state.iterationCount state.maxIterations

||| 컨텍스트는 중복 URL이 없어야 함 (논리적 속성)
public export
data NoDuplicateURLs : SearchContext -> Type where
  NoDups : (ctx : SearchContext) -> NoDuplicateURLs ctx

||| 점수는 0-20 범위 내
public export
scoreInRange : Score -> Type
scoreInRange (MkScore n) = LTE n 20
