module ReActAgent

import Tools
import Data.List

%default total

-- ============================================
-- ReAct 패턴 형식 명세
-- ============================================

||| ReAct 단계: Thought (추론) - Action (행동) - Observation (관찰)
public export
data ReActStep : Type where
  Thought : String -> ReActStep           -- LLM의 추론 과정
  Action : ToolCall -> ReActStep          -- 도구 호출 결정
  Observation : ToolResult -> ReActStep   -- 도구 실행 결과

||| 완전한 ReAct 사이클 (Thought → Action → Observation)
public export
record ReActCycle where
  constructor MkCycle
  thought : String
  action : ToolCall
  observation : ToolResult

||| ReAct 실행 히스토리
public export
data ReActTrace : Type where
  Empty : ReActTrace
  AddStep : ReActStep -> ReActTrace -> ReActTrace

-- ============================================
-- LLM 응답 타입
-- ============================================

||| LLM이 반환할 수 있는 응답 타입
public export
data LLMResponse : Type where
  ||| 도구 호출 요청 (하나 이상)
  ToolCalls : List ToolCall -> LLMResponse
  ||| 최종 텍스트 답변
  TextAnswer : String -> LLMResponse

-- ============================================
-- Agent 노드 정의
-- ============================================

||| Agent 그래프의 노드 타입
public export
data AgentNode : Type where
  LLMNode : AgentNode      -- LLM 추론 노드
  ToolsNode : AgentNode    -- 도구 실행 노드

||| 라우팅 결정
public export
data RouteDecision : Type where
  Continue : RouteDecision   -- 도구 실행 계속
  Finish : RouteDecision     -- 최종 답변 생성됨

||| LLM 응답에 따른 라우팅
public export
routeResponse : LLMResponse -> RouteDecision
routeResponse (ToolCalls _) = Continue
routeResponse (TextAnswer _) = Finish

-- ============================================
-- Prebuilt Agent 명세
-- ============================================

||| LangGraph의 create_react_agent 명세
public export
record PrebuiltReActAgent where
  constructor MkAgent
  tools : List Tool
  systemPrompt : String
  maxIterations : Nat

||| Agent 생성 함수
public export
createAgent : List Tool -> String -> Nat -> PrebuiltReActAgent
createAgent ts prompt maxIter = MkAgent
  { tools = ts
  , systemPrompt = prompt
  , maxIterations = maxIter
  }

-- ============================================
-- Agent 실행 상태
-- ============================================

||| Agent 실행 중 상태
public export
record AgentExecutionState where
  constructor MkExecState
  agent : PrebuiltReActAgent
  query : String
  cycles : List ReActCycle
  currentIter : Nat
  finalAnswer : Maybe String

||| 초기 실행 상태
public export
initialExecState : PrebuiltReActAgent -> String -> AgentExecutionState
initialExecState ag q = MkExecState
  { agent = ag
  , query = q
  , cycles = []
  , currentIter = 0
  , finalAnswer = Nothing
  }

||| 실행 계속 가능 여부
public export
canContinue : AgentExecutionState -> Bool
canContinue state =
  case state.finalAnswer of
    Just _ => False
    Nothing => state.currentIter < state.agent.maxIterations

-- ============================================
-- 상태 전이
-- ============================================

||| ReAct 사이클 추가
public export
addCycle : AgentExecutionState -> ReActCycle -> AgentExecutionState
addCycle state cycle =
  { cycles := state.cycles ++ [cycle]
  , currentIter := state.currentIter + 1
  } state

||| 최종 답변 설정
public export
setFinalAnswer : AgentExecutionState -> String -> AgentExecutionState
setFinalAnswer state answer =
  { finalAnswer := Just answer } state

-- ============================================
-- 스트리밍
-- ============================================

||| 스트리밍 청크 타입
public export
data StreamChunk : Type where
  MessageChunk : String -> StreamChunk
  ToolCallChunk : ToolCall -> StreamChunk
  ToolResultChunk : ToolResult -> StreamChunk
  FinalChunk : String -> StreamChunk

||| 스트리밍 모드
public export
data StreamMode : Type where
  Values : StreamMode     -- 전체 상태 스트림
  Updates : StreamMode    -- 업데이트만 스트림
  Messages : StreamMode   -- 메시지만 스트림

-- ============================================
-- 실행 의미론
-- ============================================

||| Agent 노드 실행 결과
public export
record AgentNodeOutput where
  constructor MkAgentOut
  response : LLMResponse
  state : AgentExecutionState

||| Tools 노드 실행 결과
public export
record ToolsNodeOutput where
  constructor MkToolsOut
  executions : List ToolExecution
  state : AgentExecutionState

||| 실행 사이클
public export
data ExecutionCycle : Type where
  AgentThinking : AgentNodeOutput -> ExecutionCycle
  ToolsExecuting : ToolsNodeOutput -> ExecutionCycle
  Completed : String -> ExecutionCycle

-- ============================================
-- 정확성 속성
-- ============================================

||| 모든 실행은 유한 단계 내 종료
||| 주의: 실제 검증은 Python에서 수행
public export
data TerminatesFinitely : AgentExecutionState -> Type where
  Bounded : (state : AgentExecutionState) -> TerminatesFinitely state

||| ReAct 패턴 준수 (Thought → Action → Observation 순서)
||| 주의: 실제 검증은 Python에서 수행
public export
data FollowsReActPattern : List ReActCycle -> Type where
  ValidPattern : (cycles : List ReActCycle) -> FollowsReActPattern cycles

||| 모든 도구 호출은 유효함
||| 주의: 실제 검증은 Python에서 수행
public export
data AllToolCallsValid : AgentExecutionState -> Type where
  ValidTools : (state : AgentExecutionState) -> AllToolCallsValid state

-- ============================================
-- 도구 확장성
-- ============================================

||| 새 도구 추가 (이전 도구들은 유지)
public export
addTool : PrebuiltReActAgent -> Tool -> PrebuiltReActAgent
addTool agent newTool =
  { tools := agent.tools ++ [newTool] } agent

||| 도구 추가 시 하위 호환성 유지
||| 주의: 실제 검증은 Python에서 수행
public export
data BackwardCompatible : PrebuiltReActAgent -> PrebuiltReActAgent -> Type where
  Compatible : (old : PrebuiltReActAgent) ->
               (new : PrebuiltReActAgent) ->
               BackwardCompatible old new
