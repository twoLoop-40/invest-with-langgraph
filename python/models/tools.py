"""
투자 분석을 위한 도구(Tool) 모음

LangChain Tool 프레임워크를 사용하여 투자 분석에 필요한 도구들을 정의합니다.
"""

from typing import Annotated, List, Dict, Any, Optional
from langchain_core.tools import tool
from langchain_community.tools.tavily_search import TavilySearchResults
import yfinance as yf
from dataclasses import dataclass


# ============================================
# 투자 분석 도구 정의
# ============================================

@tool
def search_web(query: Annotated[str, "검색할 쿼리문"]) -> str:
    """
    웹에서 실시간 정보를 검색합니다.
    주식 뉴스, 시장 동향, 기업 정보 등을 찾을 때 사용하세요.
    """
    tavily = TavilySearchResults(
        max_results=3,
        search_depth="advanced",
        include_answer=True
    )
    results = tavily.invoke(query)

    formatted = []
    for r in results:
        formatted.append(
            f"제목: {r.get('title', 'N/A')}\n"
            f"내용: {r.get('content', 'N/A')}\n"
            f"URL: {r.get('url', 'N/A')}\n"
        )
    return "\n---\n".join(formatted)


@tool
def get_stock_price(
    ticker: Annotated[str, "주식 티커 심볼 (예: 005930.KS for 삼성전자)"],
    period: Annotated[str, "조회 기간 (1d, 5d, 1mo, 3mo, 1y)"] = "1mo"
) -> str:
    """
    특정 주식의 가격 정보를 조회합니다.
    Yahoo Finance를 통해 실시간 주가, 거래량, 변동률 등을 확인합니다.

    한국 주식: 종목코드.KS (예: 005930.KS)
    미국 주식: 티커 심볼 (예: AAPL, TSLA)
    """
    try:
        stock = yf.Ticker(ticker)
        hist = stock.history(period=period)

        if hist.empty:
            return f"티커 '{ticker}'에 대한 데이터를 찾을 수 없습니다."

        latest = hist.iloc[-1]
        info = stock.info

        return f"""
티커: {ticker}
회사명: {info.get('longName', 'N/A')}
현재가: {latest['Close']:.2f}
시가: {latest['Open']:.2f}
고가: {latest['High']:.2f}
저가: {latest['Low']:.2f}
거래량: {latest['Volume']:,.0f}
기간: {period}
조회일: {hist.index[-1].strftime('%Y-%m-%d')}
"""
    except Exception as e:
        return f"주가 조회 중 오류 발생: {str(e)}"


@tool
def calculate_moving_average(
    ticker: Annotated[str, "주식 티커 심볼"],
    window: Annotated[int, "이동평균 기간 (일)"] = 20,
    period: Annotated[str, "데이터 조회 기간"] = "3mo"
) -> str:
    """
    주식의 이동평균선을 계산합니다.
    기술적 분석에 사용되며, 추세를 파악하는 데 도움이 됩니다.
    """
    try:
        stock = yf.Ticker(ticker)
        hist = stock.history(period=period)

        if len(hist) < window:
            return f"데이터가 부족합니다. 최소 {window}일의 데이터가 필요합니다."

        ma = hist['Close'].rolling(window=window).mean()
        latest_price = hist['Close'].iloc[-1]
        latest_ma = ma.iloc[-1]

        signal = "상승 추세" if latest_price > latest_ma else "하락 추세"

        return f"""
티커: {ticker}
{window}일 이동평균: {latest_ma:.2f}
현재가: {latest_price:.2f}
신호: {signal}
괴리율: {((latest_price - latest_ma) / latest_ma * 100):.2f}%
"""
    except Exception as e:
        return f"이동평균 계산 중 오류: {str(e)}"


@tool
def get_company_info(ticker: Annotated[str, "주식 티커 심볼"]) -> str:
    """
    기업의 기본 정보를 조회합니다.
    시가총액, 업종, PER, PBR 등의 재무 지표를 확인할 수 있습니다.
    """
    try:
        stock = yf.Ticker(ticker)
        info = stock.info

        market_cap = info.get('marketCap', 0)
        market_cap_str = f"{market_cap:,}" if market_cap else "N/A"

        return f"""
회사명: {info.get('longName', 'N/A')}
업종: {info.get('sector', 'N/A')}
산업: {info.get('industry', 'N/A')}
시가총액: {market_cap_str}
PER: {info.get('trailingPE', 'N/A')}
PBR: {info.get('priceToBook', 'N/A')}
배당수익률: {info.get('dividendYield', 0) * 100:.2f}%
52주 최고가: {info.get('fiftyTwoWeekHigh', 'N/A')}
52주 최저가: {info.get('fiftyTwoWeekLow', 'N/A')}
웹사이트: {info.get('website', 'N/A')}
"""
    except Exception as e:
        return f"기업 정보 조회 중 오류: {str(e)}"


# ============================================
# 도구 모음
# ============================================

AVAILABLE_TOOLS = [
    search_web,
    get_stock_price,
    calculate_moving_average,
    get_company_info
]


# ============================================
# 도구 검증 함수
# ============================================

def is_valid_tool_name(tool_name: str) -> bool:
    """도구 이름이 유효한지 확인합니다."""
    return any(t.name == tool_name for t in AVAILABLE_TOOLS)


def find_tool(tool_name: str) -> Optional[Any]:
    """도구 이름으로 도구를 찾습니다."""
    for tool in AVAILABLE_TOOLS:
        if tool.name == tool_name:
            return tool
    return None


# ============================================
# 도구 실행 추적
# ============================================

@dataclass
class ToolExecution:
    """도구 실행 기록"""
    tool_name: str
    arguments: Dict[str, Any]
    result: str
    call_id: str


class ToolHistory:
    """도구 실행 히스토리 관리"""

    def __init__(self):
        self.executions: List[ToolExecution] = []
        self.total_calls: int = 0

    def add_execution(self, execution: ToolExecution) -> None:
        """히스토리에 실행 추가"""
        self.executions.append(execution)
        self.total_calls += 1

    def last_result(self) -> Optional[str]:
        """마지막 실행 결과 조회"""
        if not self.executions:
            return None
        return self.executions[-1].result

    def __len__(self) -> int:
        return self.total_calls


# ============================================
# Agent 상태
# ============================================

@dataclass
class ToolAgentState:
    """
    Tool 기반 Agent 상태

    불변 속성 (런타임 검증):
    - tool_history.total_calls <= max_tool_calls
    - len(tool_history.executions) == tool_history.total_calls
    """
    query: str
    tool_history: ToolHistory
    final_answer: Optional[str]
    max_tool_calls: int
    current_iteration: int

    @classmethod
    def initial_state(cls, query: str, max_calls: int) -> 'ToolAgentState':
        """초기 상태 생성"""
        return cls(
            query=query,
            tool_history=ToolHistory(),
            final_answer=None,
            max_tool_calls=max_calls,
            current_iteration=0
        )

    def can_call_more_tools(self) -> bool:
        """도구를 더 호출할 수 있는지 확인"""
        return self.tool_history.total_calls < self.max_tool_calls

    def verify_invariants(self) -> bool:
        """런타임 불변 속성 검증"""
        # 도구 호출 횟수 제한
        if self.tool_history.total_calls > self.max_tool_calls:
            return False

        # 히스토리 일관성
        if len(self.tool_history.executions) != self.tool_history.total_calls:
            return False

        return True
