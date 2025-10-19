module Tools

import Data.List
import Data.String

%default total

-- ============================================
-- Tool 기반 아키텍처 형식 명세
-- ============================================

||| 도구 이름
public export
ToolName : Type
ToolName = String

||| 파라미터 타입 (문자열로 표현)
public export
ParamType : Type
ParamType = String  -- "string", "int", "float", "bool"

||| 도구 파라미터 정의
public export
record ToolParameter where
  constructor MkParam
  name : String
  paramType : ParamType
  description : String
  required : Bool

||| 도구 정의
public export
record Tool where
  constructor MkTool
  name : ToolName
  description : String
  params : List ToolParameter

-- ============================================
-- 구체적인 투자 도구들
-- ============================================

||| 웹 검색 도구
public export
searchWebTool : Tool
searchWebTool = MkTool
  { name = "search_web"
  , description = "웹에서 실시간 정보를 검색합니다"
  , params = [
      MkParam "query" "string" "검색할 쿼리문" True
    ]
  }

||| 주가 조회 도구
public export
getStockPriceTool : Tool
getStockPriceTool = MkTool
  { name = "get_stock_price"
  , description = "특정 주식의 가격 정보를 조회합니다"
  , params = [
      MkParam "ticker" "string" "주식 티커 심볼" True,
      MkParam "period" "string" "조회 기간 (1d, 5d, 1mo, 3mo, 1y)" False
    ]
  }

||| 이동평균 계산 도구
public export
calculateMovingAvgTool : Tool
calculateMovingAvgTool = MkTool
  { name = "calculate_moving_average"
  , description = "주식의 이동평균선을 계산합니다"
  , params = [
      MkParam "ticker" "string" "주식 티커 심볼" True,
      MkParam "window" "int" "이동평균 기간 (일)" False,
      MkParam "period" "string" "데이터 조회 기간" False
    ]
  }

||| 기업 정보 조회 도구
public export
getCompanyInfoTool : Tool
getCompanyInfoTool = MkTool
  { name = "get_company_info"
  , description = "기업의 기본 정보를 조회합니다"
  , params = [
      MkParam "ticker" "string" "주식 티커 심볼" True
    ]
  }

||| 사용 가능한 모든 도구
public export
availableTools : List Tool
availableTools = [
  searchWebTool,
  getStockPriceTool,
  calculateMovingAvgTool,
  getCompanyInfoTool
]

-- ============================================
-- 도구 실행 관련 타입
-- ============================================

||| 도구 호출 ID (고유 식별자)
public export
CallId : Type
CallId = String

||| 파라미터 이름-값 쌍
public export
ArgPair : Type
ArgPair = (String, String)

||| 도구 호출 요청
public export
record ToolCall where
  constructor MkToolCall
  toolName : ToolName
  arguments : List ArgPair
  callId : CallId

||| 도구 실행 결과
public export
data ToolResult : Type where
  Success : String -> ToolResult
  Failure : String -> ToolResult

||| 도구 호출-결과 쌍
public export
record ToolExecution where
  constructor MkExecution
  call : ToolCall
  result : ToolResult

-- ============================================
-- 도구 검증 로직
-- ============================================

||| 도구 이름이 유효한지 확인
public export
isValidToolName : ToolName -> Bool
isValidToolName name = any (\t => t.name == name) availableTools

||| 도구 조회
public export
findTool : ToolName -> Maybe Tool
findTool name = find (\t => t.name == name) availableTools

||| 필수 파라미터 추출
public export
requiredParams : Tool -> List String
requiredParams tool =
  map (\p => p.name) (filter (\p => p.required) tool.params)

||| 제공된 파라미터 이름 추출
public export
providedParamNames : List ArgPair -> List String
providedParamNames args = map fst args

||| 필수 파라미터가 모두 제공되었는지 확인
public export
hasAllRequired : Tool -> List ArgPair -> Bool
hasAllRequired tool args =
  let required = requiredParams tool
      provided = providedParamNames args
  in all (\p => elem p provided) required

||| 도구 호출이 유효한지 검증
public export
isValidToolCall : ToolCall -> Bool
isValidToolCall call =
  case findTool call.toolName of
    Nothing => False
    Just tool => hasAllRequired tool call.arguments

-- ============================================
-- 도구 실행 히스토리
-- ============================================

||| 도구 실행 히스토리
public export
record ToolHistory where
  constructor MkHistory
  executions : List ToolExecution
  totalCalls : Nat

||| 빈 히스토리
public export
emptyHistory : ToolHistory
emptyHistory = MkHistory [] 0

||| 히스토리에 실행 추가
public export
addExecution : ToolHistory -> ToolExecution -> ToolHistory
addExecution hist exec =
  MkHistory
    (hist.executions ++ [exec])
    (hist.totalCalls + 1)

||| 마지막 실행 결과 조회
public export
lastResult : ToolHistory -> Maybe ToolResult
lastResult hist =
  case reverse hist.executions of
    [] => Nothing
    (exec :: _) => Just exec.result

-- ============================================
-- 도구 기반 Agent 상태
-- ============================================

||| Tool 기반 Agent 상태
public export
record ToolAgentState where
  constructor MkToolState
  query : String                    -- 사용자 질문
  toolHistory : ToolHistory         -- 도구 실행 히스토리
  finalAnswer : Maybe String        -- 최종 답변
  maxToolCalls : Nat                -- 최대 도구 호출 횟수
  currentIteration : Nat            -- 현재 반복 횟수

||| 초기 상태 생성
public export
initialToolState : String -> Nat -> ToolAgentState
initialToolState q maxCalls = MkToolState
  { query = q
  , toolHistory = emptyHistory
  , finalAnswer = Nothing
  , maxToolCalls = maxCalls
  , currentIteration = 0
  }

||| 도구를 더 호출할 수 있는지 확인
public export
canCallMoreTools : ToolAgentState -> Bool
canCallMoreTools state =
  state.toolHistory.totalCalls < state.maxToolCalls

-- ============================================
-- 상태 전이 함수
-- ============================================

||| 도구 실행 후 상태 업데이트
public export
updateAfterToolExecution : ToolAgentState -> ToolExecution -> ToolAgentState
updateAfterToolExecution state exec =
  { toolHistory := addExecution state.toolHistory exec
  , currentIteration := state.currentIteration + 1
  } state

||| 최종 답변 설정
public export
setAnswer : ToolAgentState -> String -> ToolAgentState
setAnswer state answer =
  { finalAnswer := Just answer } state

-- ============================================
-- 불변 속성 (Invariants)
-- ============================================

||| 도구 호출 횟수는 최대값 이하
||| 주의: 실제 검증은 Python에서 수행
public export
data ToolCallBound : ToolAgentState -> Type where
  Bounded : (state : ToolAgentState) -> ToolCallBound state

||| 히스토리와 카운터의 일관성
||| 주의: 실제 검증은 Python에서 수행
public export
data HistoryConsistent : ToolAgentState -> Type where
  Consistent : (state : ToolAgentState) -> HistoryConsistent state

||| 모든 도구 호출은 유효함
||| 주의: 실제 검증은 Python에서 수행
public export
data AllCallsValid : ToolAgentState -> Type where
  ValidCalls : (state : ToolAgentState) -> AllCallsValid state
