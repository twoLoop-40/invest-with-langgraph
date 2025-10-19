# Idris2 형식 명세 (Formal Specification)

이 디렉토리는 Invest-with-LangGraph 프로젝트의 핵심 로직을 Idris2로 형식화한 명세입니다.

## 파일 구조

- **InvestmentAgent.idr**: Agent 상태, 평가 시스템, 상태 전이 함수
- **Workflow.idr**: LangGraph 워크플로우의 형식적 의미론

## 핵심 개념

### 1. 타입 안전성

```idris
-- 점수는 컴파일 타임에 0-20 범위가 보장됨
data Score : Type where
  MkScore : (n : Nat) -> {auto prf : LTE n 20} -> Score
```

### 2. 상태 전이

모든 상태 변경은 순수 함수로 정의:
- `updateAfterGenerate` - 답변 생성 후
- `updateAfterSearch` - 웹 검색 후
- `updateAfterEvaluation` - 평가 후
- `updateWithError` - 에러 발생 시

### 3. 불변 속성 (Invariants)

- `iterationBound`: 반복 횟수 ≤ maxIterations
- `NoDuplicateURLs`: 검색 결과에 중복 URL 없음
- `MonotonicContext`: 컨텍스트는 단조 증가
- `AlwaysTerminates`: 모든 실행은 유한 시간 내 종료

### 4. 워크플로우 정확성

`NoSearchWhenEnough` 속성:
- 평가 점수가 threshold 이상이고
- 추가 정보가 필요 없으면
- 웹 검색을 실행하지 않음

## Python 구현과의 대응

| Idris 타입 | Python 구현 |
|-----------|-------------|
| `AgentState` | `notebooks/2 web_search.ipynb`의 `AgentState` TypedDict |
| `decideNextAction` | `qa_eval()` 함수의 반환값 로직 |
| `updateAfterSearch` | `web_search()` 함수의 context 누적 로직 |
| `Evaluation` | `EvaledAnswer` Pydantic 모델 |

## 사용 목적

1. **설계 검증**: Python 구현 전에 로직의 정확성 검증
2. **문서화**: 타입으로 시스템 동작 명확히 기술
3. **교육**: 학생들에게 형식 명세의 중요성 교육
4. **테스트 가이드**: Python 테스트 케이스 작성 시 참고

## 컴파일 방법 (옵션)

```bash
# Idris2 설치 (필수 아님, 명세만 제공)
# brew install idris2  # macOS
# apt install idris2   # Ubuntu

# 타입 체크 (옵션)
idris2 --check Domain/InvestmentAgent.idr
idris2 --check Domain/Workflow.idr
```

**주의**: Idris2는 실행 필수가 아닙니다. 이 파일들은 시스템 설계의 청사진 역할만 합니다.
