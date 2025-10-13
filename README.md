# 🤖 Invest with LangGraph

LangGraph를 활용한 AI 기반 주식 투자 어시스턴트입니다. 웹 검색 기능을 통해 실시간 주식 정보를 조회하고, 사용자 질문에 대한 답변을 생성합니다.

> 💡 **초보자를 위한 가이드**: 이 README는 코딩 초보자도 따라할 수 있도록 작성되었습니다. 각 단계를 천천히 따라하세요!

## 📋 목차

- [주요 기능](#주요-기능)
- [시작하기 전에](#시작하기-전에)
- [설치 방법 (단계별 가이드)](#설치-방법-단계별-가이드)
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

## 📦 시작하기 전에

### 필수 요구사항

- **컴퓨터**: Windows, macOS, 또는 Linux
- **Python 3.13 이상** (설치 방법은 아래 참조)
- **인터넷 연결**
- **OpenAI API 키** (신용카드 등록 필요, 유료)
- **Tavily API 키** (무료 체험 가능)

### 예상 소요 시간

- 처음 설치: 약 20-30분
- API 키 발급: 약 10-15분
- **총 소요 시간: 약 30-45분**

## 🚀 설치 방법 (단계별 가이드)

### 📍 Step 0: 터미널(명령 프롬프트) 열기

> 💡 **터미널이란?** 명령어를 입력해서 컴퓨터를 제어하는 프로그램입니다.

**Windows 사용자:**
1. `Windows 키` + `R` 누르기
2. `cmd` 입력하고 엔터
3. 또는 시작 메뉴에서 "명령 프롬프트" 검색

**macOS 사용자:**
1. `Command` + `Space` (Spotlight 검색)
2. "터미널" 입력하고 엔터
3. 또는 응용 프로그램 > 유틸리티 > 터미널

**Linux 사용자:**
1. `Ctrl` + `Alt` + `T`
2. 또는 애플리케이션 메뉴에서 "터미널" 찾기

---

### 📍 Step 1: Git 설치 확인 및 설치

**1-1. Git이 설치되어 있는지 확인:**

터미널에 다음 명령어를 입력하고 엔터를 누르세요:

```bash
git --version
```

**만약 버전 번호가 나오면** (예: `git version 2.39.0`):
- ✅ Git이 이미 설치되어 있습니다. Step 2로 넘어가세요!

**만약 오류가 나오면** (예: `'git'은(는) 내부 또는 외부 명령...`):
- ❌ Git을 설치해야 합니다. 아래 링크에서 다운로드하세요.

**1-2. Git 설치하기 (설치 안 되어 있는 경우만):**

- **Windows**: https://git-scm.com/download/win
  - 다운로드 후 실행, "Next" 연속 클릭하여 기본 설정으로 설치

- **macOS**:
  ```bash
  # 터미널에서 실행
  xcode-select --install
  ```

- **Linux (Ubuntu/Debian)**:
  ```bash
  sudo apt-get update
  sudo apt-get install git
  ```

설치 후 터미널을 **다시 열고** `git --version`으로 확인하세요.

---

### 📍 Step 2: uv 패키지 매니저 설치

> 💡 **uv란?** Python 패키지를 빠르고 쉽게 설치해주는 도구입니다.

**2-1. uv 설치 명령어 실행:**

**macOS/Linux 사용자:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows 사용자 (PowerShell):**
1. 시작 메뉴에서 "PowerShell" 검색
2. "Windows PowerShell" 우클릭 → "관리자 권한으로 실행"
3. 다음 명령어 입력:
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**2-2. 터미널 다시 열기:**
- 설치 후 **터미널을 완전히 닫고 다시 열어야** uv 명령어를 사용할 수 있습니다.

**2-3. 설치 확인:**
```bash
uv --version
```
- 버전이 나오면 성공! (예: `uv 0.7.20`)

---

### 📍 Step 3: 프로젝트 다운로드 (Git Clone)

**3-1. 프로젝트를 저장할 폴더로 이동:**

> 💡 예를 들어, 바탕화면에 프로젝트를 저장하고 싶다면:

**Windows:**
```bash
cd C:\Users\내사용자이름\Desktop
```

**macOS:**
```bash
cd ~/Desktop
```

**Linux:**
```bash
cd ~/Desktop
```

> 📝 **Tip**: `내사용자이름` 부분은 본인의 윈도우 사용자 이름으로 바꾸세요!

**3-2. 프로젝트 다운로드 (Clone):**

터미널에 다음 명령어를 **정확히** 복사해서 붙여넣고 엔터:

```bash
git clone https://github.com/twoLoop-40/invest-with-langgraph.git
```

> 💡 **이 명령어가 하는 일**: GitHub에서 프로젝트 파일을 내 컴퓨터로 복사합니다.

다음과 같은 메시지가 나오면 성공:
```
Cloning into 'invest-with-langgraph'...
remote: Enumerating objects: ...
...
```

**3-3. 프로젝트 폴더로 이동:**

```bash
cd invest-with-langgraph
```

> 💡 **cd란?** "Change Directory"의 약자로, 폴더를 이동하는 명령어입니다.

**3-4. 현재 위치 확인:**

```bash
# Windows
dir

# macOS/Linux
ls
```

다음과 같은 파일들이 보이면 성공:
- `notebooks/`
- `src/`
- `README.md`
- `pyproject.toml`

---

### 📍 Step 4: Python 패키지 설치

**4-1. 모든 필수 패키지 자동 설치:**

```bash
uv sync
```

> 💡 **이 명령어가 하는 일**:
> - Python 3.13 가상환경을 자동으로 생성 (`.venv` 폴더)
> - 프로젝트에 필요한 모든 라이브러리 설치 (약 139개)
> - 시간이 좀 걸릴 수 있습니다 (2-5분 정도)

**설치 중 화면:**
```
Resolved 143 packages in ...
Downloading ...
Installed 139 packages in ...
```

**4-2. 설치 완료 확인:**

```bash
uv run python --version
```

`Python 3.13.X` 같은 버전이 나오면 성공!

---

## ⚙️ 환경 설정

### 📍 Step 5: API 키 발급 및 설정

> ⚠️ **중요**: 이 단계를 건너뛰면 프로그램이 작동하지 않습니다!

#### 5-1. OpenAI API 키 발급

**OpenAI API 키란?** ChatGPT를 사용하기 위한 인증 키입니다.

1. **OpenAI 계정 만들기**
   - https://platform.openai.com/ 접속
   - "Sign up" 클릭하여 회원가입
   - 이메일 인증 완료

2. **API 키 발급**
   - 로그인 후 우측 상단 프로필 아이콘 클릭
   - "API keys" 선택
   - "Create new secret key" 버튼 클릭
   - 이름 입력 (예: "invest-project")
   - **생성된 키를 복사!** (다시 볼 수 없으니 주의)

3. **결제 정보 등록** (필수)
   - 좌측 메뉴에서 "Billing" 선택
   - 신용카드 등록
   - 최소 $5-10 충전 권장
   - 💰 **비용**: GPT-4o-mini 사용 시 매우 저렴 (1,000회 요청에 약 $0.5)

#### 5-2. Tavily API 키 발급

**Tavily API 키란?** 웹 검색 기능을 사용하기 위한 키입니다.

1. https://tavily.com/ 접속
2. "Get API Key" 또는 "Sign Up" 클릭
3. 구글 계정으로 간편 가입
4. 대시보드에서 API 키 확인 및 복사
5. 💰 **비용**: 무료 플랜으로 월 1,000회 검색 가능!

#### 5-3. `.env` 파일 만들기

> 💡 **방법 1: 메모장으로 만들기 (초보자 추천)**

**Windows:**
1. 프로젝트 폴더에서 우클릭 → "새로 만들기" → "텍스트 문서"
2. 파일 이름을 정확히 `.env`로 변경 (확장자 없음!)
3. 메모장으로 열기
4. 아래 내용 복사해서 붙여넣기:

```bash
# OpenAI API 키 (sk-로 시작하는 긴 문자열)
OPENAI_API_KEY=여기에_발급받은_OpenAI_키_붙여넣기

# Tavily API 키 (tvly-로 시작하는 문자열)
TAVILY_API_KEY=여기에_발급받은_Tavily_키_붙여넣기
```

5. `여기에_발급받은_...` 부분을 **실제 API 키**로 바꾸기
6. 저장 후 닫기

**예시 (실제 키는 이것보다 훨씬 깁니다):**
```bash
OPENAI_API_KEY=sk-proj-abcd1234efgh5678
TAVILY_API_KEY=tvly-xyz789abc123
```

> 💡 **방법 2: 터미널로 만들기**

**macOS/Linux:**
```bash
cat > .env << 'EOF'
OPENAI_API_KEY=여기에_발급받은_OpenAI_키_붙여넣기
TAVILY_API_KEY=여기에_발급받은_Tavily_키_붙여넣기
EOF
```

그 후 텍스트 에디터로 `.env` 파일을 열어 키를 수정하세요.

#### 5-4. `.env` 파일 확인

터미널에서 확인:

**Windows:**
```bash
type .env
```

**macOS/Linux:**
```bash
cat .env
```

다음과 같이 표시되어야 합니다:
```
OPENAI_API_KEY=sk-proj-...
TAVILY_API_KEY=tvly-...
```

> ⚠️ **주의사항**:
> - API 키는 **절대 다른 사람과 공유하지 마세요**!
> - GitHub에 올리지 마세요! (`.gitignore`에 이미 포함되어 있음)
> - 키가 유출되면 즉시 OpenAI/Tavily 사이트에서 키를 삭제하세요.

---

## 📝 사용 방법

### 🎉 드디어! Jupyter Notebook 실행하기

**6-1. Jupyter Notebook 시작:**

프로젝트 폴더에서 터미널에 입력:

```bash
uv run jupyter notebook
```

**6-2. 브라우저 자동 실행:**
- 몇 초 후 브라우저가 자동으로 열립니다
- `http://localhost:8888/` 같은 주소가 나타납니다
- Jupyter 파일 목록이 보입니다

> 💡 만약 브라우저가 자동으로 열리지 않으면:
> 1. 터미널에 나타난 URL을 복사 (예: `http://localhost:8888/tree?token=...`)
> 2. 브라우저 주소창에 붙여넣기

**6-3. 노트북 열기:**
1. `notebooks` 폴더 클릭
2. 원하는 노트북 클릭:
   - **초보자**: `1 generate.ipynb` 먼저 해보세요!
   - **고급**: `2 web_search.ipynb`

**6-4. 노트북 실행 방법:**
1. 셀(코드 박스)을 클릭
2. `Shift` + `Enter` 눌러서 실행
3. 위에서부터 순서대로 실행하세요!

**6-5. Jupyter 종료:**
- 터미널에서 `Ctrl` + `C` 두 번 누르기
- 또는 브라우저에서 "Quit" 버튼 클릭

---

### 📚 추가 사용법

#### 가상환경 활성화 (선택사항)

매번 `uv run`을 입력하기 귀찮다면:

**macOS/Linux:**
```bash
source .venv/bin/activate
```

**Windows:**
```bash
.venv\Scripts\activate
```

활성화 후:
```bash
jupyter notebook      # uv run 없이 바로 실행 가능
python script.py      # 스크립트도 바로 실행
```

비활성화:
```bash
deactivate
```

---

## 📓 노트북 설명

### 1️⃣ `1 generate.ipynb` - 기본 생성 노트북

**이 노트북에서 배우는 것:**
- ✅ LangGraph 기본 사용법
- ✅ AI에게 질문하고 답변 받기
- ✅ 상태(State) 관리하기
- ✅ 간단한 워크플로우 만들기

**추천 대상**: LangGraph를 처음 접하는 사람

**예상 소요 시간**: 15-20분

---

### 2️⃣ `2 web_search.ipynb` - 웹 검색 기반 투자 어시스턴트

**이 노트북에서 배우는 것:**
- ✅ 자동 답변 품질 평가 (0-20점)
- ✅ 점수가 낮으면 자동으로 웹 검색
- ✅ 여러 번 검색해서 답변 개선
- ✅ 실시간 주식 정보 조회

**워크플로우 (작동 원리):**
```
1. 질문 입력
   ↓
2. AI가 답변 생성
   ↓
3. 답변 품질 평가 (0-20점)
   ↓
4. 점수가 15점 미만? → 웹 검색 후 다시 답변
   ↓
5. 점수가 15점 이상? → 최종 답변 출력
```

**주요 설정:**
```python
'search_threshold': 15,    # 15점 이상이면 검색 안 함
'max_iterations': 3,       # 최대 3번까지 반복
```

**사용 예시:**

노트북의 마지막 셀에서 질문을 바꿔보세요:

```python
initial_state = {
    'query': '여기에_원하는_질문_입력',  # 이 부분을 수정!
    'search_threshold': 15,
    'iteration_count': 0,
    'max_iterations': 3,
    'context': [],
    'answer': '',
    'evaluation_score': 0,
    'evaluation_comment': '',
    'error': ''
}

result = graph.invoke(initial_state)
print(result['answer'])
```

**질문 예시:**
- "2025년 10월 삼성전자 주가는?"
- "애플 주식 최근 1년 수익률은?"
- "현재 나스닥 지수는?"
- "반도체 업종 전망은?"

**추천 대상**: 1번 노트북을 완료한 사람

**예상 소요 시간**: 30-40분

---

## 📁 프로젝트 구조

```
invest-with-langgraph/
├── 📁 notebooks/              # 실습용 노트북 파일
│   ├── 1 generate.ipynb      # 기본 생성 예제 (초보자용)
│   └── 2 web_search.ipynb    # 웹 검색 어시스턴트 (고급)
│
├── 📁 src/                    # 소스 코드 (나중에 확장 가능)
│   └── invest_with_langgraph/
│       └── __init__.py
│
├── 📁 .venv/                  # 가상환경 (자동 생성, 건드리지 마세요!)
│
├── 📄 .env                    # API 키 저장 (직접 만들어야 함)
├── 📄 .gitignore              # Git이 무시할 파일 목록
├── 📄 pyproject.toml          # 프로젝트 설정
├── 📄 uv.lock                 # 패키지 버전 고정
└── 📄 README.md               # 이 파일!
```

> 💡 **중요**: `.venv/` 폴더와 `uv.lock` 파일은 건드리지 마세요!

---

## 🛠️ 기술 스택

### 사용된 기술들

| 기술 | 설명 | 역할 |
|------|------|------|
| **Python 3.13** | 프로그래밍 언어 | 전체 코드 작성 |
| **uv** | 패키지 매니저 | 라이브러리 설치 및 관리 |
| **LangChain** | LLM 프레임워크 | AI 모델 연결 |
| **LangGraph** | 워크플로우 도구 | 복잡한 AI 로직 구현 |
| **OpenAI GPT-4** | AI 모델 | 답변 생성 |
| **Tavily** | 검색 API | 실시간 웹 검색 |
| **Jupyter Notebook** | 개발 환경 | 대화형 코드 실행 |

### 주요 라이브러리

```
notebook           : Jupyter 노트북
python-dotenv      : 환경 변수 관리
langchain-openai   : OpenAI 연동
langgraph          : 그래프 워크플로우
langchain-community: 추가 도구
langchain-tavily   : 웹 검색
```

---

## 🔧 문제 해결

### ❓ 자주 묻는 질문 (FAQ)

#### Q1: `git: command not found` 오류가 나요

**원인**: Git이 설치되지 않았습니다.

**해결**:
1. [Step 1](#-step-1-git-설치-확인-및-설치)로 돌아가서 Git 설치
2. 터미널 다시 열기
3. `git --version`으로 확인

---

#### Q2: `uv: command not found` 오류가 나요

**원인**: uv가 설치되지 않았거나 PATH에 등록되지 않았습니다.

**해결**:
1. [Step 2](#-step-2-uv-패키지-매니저-설치)로 돌아가서 uv 설치
2. **터미널을 완전히 닫고 다시 열기** (중요!)
3. `uv --version`으로 확인

**그래도 안 되면**:
```bash
# macOS/Linux
source ~/.bashrc
source ~/.zshrc

# Windows (PowerShell 재시작)
```

---

#### Q3: `AuthenticationError` 또는 API 키 오류가 나요

**원인**: API 키가 잘못되었거나 없습니다.

**해결 체크리스트**:
1. ✅ `.env` 파일이 프로젝트 **루트 폴더**에 있나요?
2. ✅ API 키를 **따옴표 없이** 입력했나요?
   ```bash
   # 올바름
   OPENAI_API_KEY=sk-proj-abcd1234

   # 틀림
   OPENAI_API_KEY="sk-proj-abcd1234"
   OPENAI_API_KEY='sk-proj-abcd1234'
   ```
3. ✅ API 키에 **공백이나 줄바꿈**이 없나요?
4. ✅ OpenAI 계정에 **결제 수단이 등록**되어 있나요?
5. ✅ 계정에 **잔액**이 남아있나요?

**확인 방법**:
```bash
# 터미널에서 .env 파일 내용 확인
# Windows
type .env

# macOS/Linux
cat .env
```

---

#### Q4: Jupyter Notebook이 실행되지 않아요

**해결**:

**방법 1: 재설치**
```bash
uv sync --reinstall
uv run jupyter notebook
```

**방법 2: 포트 충돌**
```bash
# 다른 포트로 실행
uv run jupyter notebook --port 8889
```

**방법 3: 브라우저 수동 열기**
1. 터미널에 나타난 URL 복사
2. 브라우저 주소창에 붙여넣기

---

#### Q5: `ModuleNotFoundError` 오류가 나요

**원인**: 패키지가 제대로 설치되지 않았습니다.

**해결**:
```bash
# 1. 가상환경 확인
uv run python -c "import sys; print(sys.executable)"

# 2. 패키지 재설치
uv sync

# 3. 특정 패키지 설치 확인
uv run python -c "import langchain"
```

---

#### Q6: 웹 검색 결과가 없어요

**원인**: Tavily API 키 문제 또는 네트워크 문제

**해결**:
1. `.env` 파일에서 `TAVILY_API_KEY` 확인
2. 인터넷 연결 확인
3. Tavily 무료 할당량(월 1,000회) 확인
4. 검색 쿼리를 더 구체적으로 작성:
   ```python
   # 좋은 예
   'query': '2025년 10월 13일 삼성전자 주가'

   # 나쁜 예
   'query': '주가'
   ```

---

#### Q7: 답변 품질이 너무 낮아요

**해결**:

노트북에서 설정 변경:

```python
# 검색을 더 자주 하도록 threshold 낮추기
'search_threshold': 10,  # 기본값: 15

# 더 많이 반복하도록 설정
'max_iterations': 5,     # 기본값: 3
```

---

#### Q8: 돈이 얼마나 드나요?

**OpenAI (GPT-4o-mini)**:
- 입력: $0.150 per 1M tokens
- 출력: $0.600 per 1M tokens
- 예상 비용: 100회 질문에 약 $0.5-1

**Tavily**:
- 무료: 월 1,000회 검색
- 유료: 월 $29부터 (무제한)

**팁**: 테스트할 때는 `max_iterations`를 1로 설정하면 비용 절약!

---

#### Q9: Windows에서 `.env` 파일 확장자가 `.txt`로 바뀌어요

**해결**:

1. **파일 탐색기 열기**
2. **상단 메뉴에서 "보기" → "파일 확장명" 체크**
3. 파일 이름을 `.env.txt`에서 `.env`로 변경
4. "확장명을 변경하면 파일을 사용하지 못할 수도 있습니다" 경고 → "예" 클릭

---

#### Q10: 프로젝트를 삭제하고 다시 시작하고 싶어요

**완전 삭제 후 재설치**:

```bash
# 1. 프로젝트 폴더 상위로 이동
cd ..

# 2. 프로젝트 폴더 삭제
# Windows
rmdir /s invest-with-langgraph

# macOS/Linux
rm -rf invest-with-langgraph

# 3. 다시 Step 3부터 시작
```

---

### 🆘 그래도 해결이 안 되면?

1. **GitHub Issues**: https://github.com/twoLoop-40/invest-with-langgraph/issues
   - "New Issue" 버튼 클릭
   - 오류 메시지와 상황 자세히 설명
   - 스크린샷 첨부

2. **오류 메시지 검색**:
   - 오류 메시지를 구글에 검색
   - Stack Overflow 확인

3. **관련 문서 확인**:
   - [LangChain 문서](https://python.langchain.com/)
   - [uv 문서](https://docs.astral.sh/uv/)
   - [OpenAI API 문서](https://platform.openai.com/docs/)

---

## 🎓 학습 로드맵

### 초급 (1-2주)

- [ ] Python 기초 문법 복습
- [ ] Jupyter Notebook 사용법 익히기
- [ ] `1 generate.ipynb` 실행해보기
- [ ] 코드 한 줄씩 이해하기

### 중급 (2-4주)

- [ ] LangChain 기본 개념 학습
- [ ] `2 web_search.ipynb` 실행해보기
- [ ] 질문을 바꿔가며 테스트
- [ ] 코드 수정해보기

### 고급 (4주+)

- [ ] LangGraph 그래프 구조 이해
- [ ] 새로운 노드 추가해보기
- [ ] 다른 LLM 모델 연동
- [ ] 자신만의 워크플로우 만들기

---

## 🤝 기여

이 프로젝트는 학습 및 연구 목적으로 제작되었습니다.

**개선 사항이 있다면**:
1. GitHub에서 Fork
2. 수정 후 Pull Request
3. 또는 Issue 등록

---

## 📄 라이선스

이 프로젝트는 학습 및 연구 목적으로 자유롭게 사용할 수 있습니다.

---

## ⚠️ 주의사항

1. **투자 조언 아님**: 이 프로젝트는 **교육 목적**입니다. 실제 투자 결정은 전문가와 상담하세요.
2. **API 비용**: OpenAI API는 **유료**입니다. 사용량을 확인하세요.
3. **보안**: API 키를 **절대 공유하지 마세요**.
4. **책임**: 이 프로젝트 사용으로 인한 손실에 대해 개발자는 책임지지 않습니다.

---

## 📞 연락처

- **GitHub**: https://github.com/twoLoop-40/invest-with-langgraph
- **Issues**: https://github.com/twoLoop-40/invest-with-langgraph/issues

---

**마지막 업데이트**: 2025년 10월

**버전**: 0.1.0

**제작**: twoLoop-40

---

**🎉 성공적인 학습을 기원합니다! 화이팅!**
