# 🤖 Invest with LangGraph

LangGraph를 활용한 AI 기반 주식 투자 어시스턴트입니다. 웹 검색 기능을 통해 실시간 주식 정보를 조회하고, 사용자 질문에 대한 답변을 생성합니다.

## 📋 목차

- [주요 기능](#주요-기능)
- [필수 요구사항](#필수-요구사항)
- [설치 방법](#설치-방법)
- [환경 설정](#환경-설정)
- [사용 방법](#사용-방법)
- [노트북 설명](#노트북-설명)
- [프로젝트 구조](#프로젝트-구조)
- [기술 스택](#기술-스택)
- [문제 해결](#문제-해결)

## ✨ 주요 기능

- **자동 웹 검색**: 답변 품질이 낮을 경우 자동으로 웹 검색 수행
- **반복 개선**: 여러 차례 검색 및 답변 생성을 통한 품질 향상
- **구조화된 평가**: 답변의 정확성, 완전성, 명확성, 관련성을 자동 평가
- **실시간 주가 정보**: Tavily 검색 API를 통한 최신 주식 정보 제공
- **LangGraph 워크플로우**: 상태 기반 그래프 구조로 체계적인 작업 흐름 관리

## 📦 필수 요구사항

- Python 3.13 이상
- [uv](https://docs.astral.sh/uv/) 패키지 매니저
- OpenAI API 키
- Tavily API 키

## 🚀 설치 방법

### 1. uv 설치 (아직 설치하지 않은 경우)

**macOS/Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows:**
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. 프로젝트 클론 및 의존성 설치

```bash
# 프로젝트 클론
git clone <repository-url>
cd invest-with-langgraph

# 의존성 자동 설치 (가상환경 생성 포함)
uv sync
```

`uv sync` 명령어는 다음을 자동으로 수행합니다:
- Python 3.13 가상환경 생성 (`.venv` 디렉토리)
- 모든 필수 패키지 설치
- 프로젝트를 개발 모드로 설치

## ⚙️ 환경 설정

### 1. API 키 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```bash
# OpenAI API 키 (https://platform.openai.com/api-keys)
OPENAI_API_KEY=your-openai-api-key-here

# Tavily API 키 (https://tavily.com/)
TAVILY_API_KEY=your-tavily-api-key-here
```

### 2. API 키 발급 방법

**OpenAI API 키:**
1. [OpenAI Platform](https://platform.openai.com/)에 로그인
2. 우측 상단 계정 메뉴 → "API keys" 클릭
3. "Create new secret key" 버튼 클릭
4. 생성된 키를 복사하여 `.env` 파일에 추가

**Tavily API 키:**
1. [Tavily](https://tavily.com/)에 회가입 및 로그인
2. 대시보드에서 API 키 확인
3. 키를 복사하여 `.env` 파일에 추가

## 📝 사용 방법

### Jupyter Notebook 실행

```bash
# uv를 통해 Jupyter Notebook 실행
uv run jupyter notebook
```

브라우저가 자동으로 열리며, `notebooks/` 디렉토리에서 원하는 노트북을 선택하여 실행할 수 있습니다.

### 명령줄에서 Python 스크립트 실행

```bash
# uv 환경에서 Python 스크립트 실행
uv run python your_script.py
```

### 가상환경 활성화 (선택사항)

가상환경을 직접 활성화하고 싶다면:

```bash
# macOS/Linux
source .venv/bin/activate

# Windows
.venv\Scripts\activate
```

활성화 후에는 `uv run` 없이 직접 명령어를 실행할 수 있습니다:
```bash
jupyter notebook
python your_script.py
```

## 📓 노트북 설명

### 1. `1 generate.ipynb` - 기본 생성 노트북
기본적인 LangGraph 사용법을 다룹니다:
- LLM을 이용한 답변 생성
- State 관리 기초
- 간단한 워크플로우 구성

### 2. `2 web_search.ipynb` - 웹 검색 기반 투자 어시스턴트
고급 기능을 포함한 완전한 투자 어시스턴트:
- **자동 품질 평가**: 답변을 0-20점으로 자동 평가
- **조건부 웹 검색**: 평가 점수가 낮으면 자동으로 웹 검색 실행
- **Context 누적**: 여러 번의 검색 결과를 누적하여 답변 개선
- **무한 루프 방지**: 최대 반복 횟수 설정
- **에러 처리**: 안정적인 실행을 위한 예외 처리

**워크플로우:**
```
START → Generate (답변 생성) → QA Eval (품질 평가)
           ↑                          ↓
           ↓                    (점수 낮음)
       Web Search ←─────────────────┘
           ↓
       (점수 충분 또는 최대 반복) → END
```

**주요 파라미터:**
- `search_threshold`: 웹 검색 실행 기준 점수 (기본값: 15점)
- `max_iterations`: 최대 반복 횟수 (기본값: 3회)

**사용 예시:**
```python
initial_state = {
    'query': '2025년 10월 삼성전자 주식의 현재 주가와 최근 동향을 알려줘',
    'search_threshold': 15,      # 15점 이상이면 충분
    'iteration_count': 0,
    'max_iterations': 3,         # 최대 3번 반복
    'context': [],
    'answer': '',
    'evaluation_score': 0,
    'evaluation_comment': '',
    'error': ''
}

result = graph.invoke(initial_state)
print(result['answer'])
```

## 📁 프로젝트 구조

```
invest-with-langgraph/
├── notebooks/              # Jupyter 노트북 파일
│   ├── 1 generate.ipynb   # 기본 생성 예제
│   └── 2 web_search.ipynb # 웹 검색 투자 어시스턴트
├── src/                    # 소스 코드 (향후 확장용)
│   └── invest_with_langgraph/
│       └── __init__.py
├── .env                    # API 키 설정 (gitignore)
├── .gitignore             # Git 무시 파일 목록
├── pyproject.toml         # 프로젝트 설정 및 의존성
├── uv.lock                # 의존성 잠금 파일
└── README.md              # 프로젝트 설명서
```

## 🛠️ 기술 스택

- **Python 3.13**: 최신 Python 버전
- **uv**: 빠르고 현대적인 Python 패키지 매니저
- **LangChain**: LLM 애플리케이션 프레임워크
- **LangGraph**: 상태 기반 워크플로우 구축
- **OpenAI GPT-4**: 자연어 이해 및 생성
- **Tavily Search API**: 웹 검색 기능
- **Jupyter Notebook**: 대화형 개발 환경

### 주요 의존성

```toml
notebook >= 7.4.4          # Jupyter Notebook
python-dotenv >= 1.1.1     # 환경 변수 관리
langchain-openai >= 0.3.27 # OpenAI 통합
langgraph >= 0.5.2         # 그래프 워크플로우
langchain-community >= 0.3.27  # 커뮤니티 도구
langchain-tavily >= 0.2.7  # Tavily 검색 통합
```

## 🔧 문제 해결

### 문제: `uv: command not found`
**해결:** uv가 설치되지 않았습니다. [설치 방법](#1-uv-설치-아직-설치하지-않은-경우)을 참고하세요.

### 문제: API 키 오류 (`AuthenticationError`)
**해결:**
1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. API 키가 올바르게 입력되었는지 확인
3. OpenAI 계정에 사용 가능한 크레딧이 있는지 확인

### 문제: Jupyter Notebook이 실행되지 않음
**해결:**
```bash
# 의존성 재설치
uv sync --reinstall

# 직접 실행
uv run jupyter notebook
```

### 문제: 모듈을 찾을 수 없음 (`ModuleNotFoundError`)
**해결:**
```bash
# 가상환경이 활성화되었는지 확인
# uv run을 사용하거나 가상환경을 활성화하세요
uv sync  # 의존성 재설치
```

### 문제: 웹 검색 결과가 없음
**해결:**
1. Tavily API 키가 올바른지 확인
2. 인터넷 연결 확인
3. 검색 쿼리를 더 구체적으로 작성

### 문제: 답변 품질이 낮음
**해결:**
- `search_threshold` 값을 낮춰서 더 자주 웹 검색 실행
- `max_iterations` 값을 높여서 더 많은 반복 허용
- 질문을 더 구체적이고 명확하게 작성

## 🤝 기여

이 프로젝트는 개인 학습 및 연구 목적으로 제작되었습니다. 개선 사항이나 버그를 발견하시면 Issue를 등록해주세요.

## 📄 라이선스

이 프로젝트는 학습 및 연구 목적으로 자유롭게 사용할 수 있습니다.

---

**참고:** 이 프로젝트는 투자 조언을 제공하지 않습니다. 모든 투자 결정은 사용자의 책임하에 이루어져야 합니다.
