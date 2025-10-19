#!/usr/bin/env python3
"""
Fix and verify notebooks 1 and 3 per Idris specifications.

Process:
1. Add section title comments to code cells
2. Reorder cells to match Idris spec
3. Verify structure matches spec
"""
import json
import sys
from typing import Dict, List, Tuple

# Section titles from Idris specs
NOTEBOOK1_SECTIONS = {
    3: "# 1. 환경 변수 로드",
    5: "# 2. LLM 기본 사용법",
    7: "# 3. Agent 상태 정의",
    9: "# 4. StateGraph 생성",
    11: "# 5. 노드 함수 정의",
    13: "# 6. 그래프에 노드 추가",
    15: "# 7. 엣지 연결",
    17: "# 8. 그래프 컴파일",
    19: "# 9. 그래프 시각화",
    21: "# 10. 그래프 실행 테스트",
}

NOTEBOOK3_SECTIONS = {
    4: "# 환경 설정",
    7: "# 2. ReAct Agent 생성",
    10: "# 3. 그래프 구조 시각화",
    13: "# 4. Agent 실행 헬퍼 함수",
    16: "# 5. 테스트 1: 간단한 주가 조회",
    19: "# 6. 테스트 2: 복합 분석",
    22: "# 7. 테스트 3: 미국 주식 분석",
    25: "# 8. 불변 속성 검증 예시",
}

def add_section_comments_to_code(nb_path: str, section_map: Dict[int, str]) -> None:
    """Add section title comments to code cells."""
    with open(nb_path, 'r') as f:
        nb = json.load(f)

    cells = nb['cells']

    for cell_idx, comment in section_map.items():
        if cell_idx >= len(cells):
            continue

        cell = cells[cell_idx]
        if cell['cell_type'] != 'code':
            continue

        source = cell['source']
        if not source:
            continue

        # Ensure source is a list
        if isinstance(source, str):
            source = [source]
            cell['source'] = source

        # Check if comment already exists
        first_line = source[0].strip() if source else ''
        if first_line.startswith('#') and '.' in first_line[:10]:
            # Already has section comment, replace it
            source[0] = comment + '\n'
        else:
            # Add comment at the beginning
            source.insert(0, comment + '\n')

    with open(nb_path, 'w') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"✅ Added section comments to {nb_path.split('/')[-1]}")

def fix_notebook1() -> None:
    """Fix notebook 1 structure per Idris Notebook1Structure."""
    nb_path = 'notebooks/1_generate.ipynb'

    with open(nb_path, 'r') as f:
        nb = json.load(f)

    cells = nb['cells']

    print("\n📒 Fixing Notebook 1...")

    # Current structure has practice problems in wrong order
    # Problem cells: markdown (30, 29, 28) and code (23, 24, 25)
    # Should be: Problem 1 (30, 23), Problem 2 (29, 24), Problem 3 (28, 25)

    # Build correct order
    reordered = []

    # 1. Title + Package + Sections 1-10 (cells 0-21)
    for i in range(22):
        reordered.append(cells[i])

    # 2. Practice header (cell 22)
    reordered.append(cells[22])

    # 3. Practice problems in ascending order (1 → 2 → 3)
    practice_problems = [
        (30, 23),  # Problem 1: ChatOpenAI
        (29, 24),  # Problem 2: 노드 함수
        (28, 25),  # Problem 3: 그래프 실행
    ]

    for md_idx, code_idx in practice_problems:
        reordered.append(cells[md_idx])
        reordered.append(cells[code_idx])

    # 4. Divider (27) + Answers (26) + Empty (31)
    reordered.append(cells[27])
    reordered.append(cells[26])
    if len(cells) > 31:
        reordered.append(cells[31])

    # Clear outputs
    for cell in reordered:
        if cell['cell_type'] == 'code':
            cell['outputs'] = []
            cell['execution_count'] = None

    nb['cells'] = reordered

    with open(nb_path, 'w') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"   ✅ Reordered practice problems (1 → 2 → 3)")
    print(f"   ✅ Total cells: {len(cells)} → {len(reordered)}")

def fix_notebook3() -> None:
    """Fix notebook 3 structure per Idris Notebook3Structure."""
    nb_path = 'notebooks/3_tool_agent.ipynb'

    with open(nb_path, 'r') as f:
        nb = json.load(f)

    cells = nb['cells']

    print("\n📒 Fixing Notebook 3...")

    # Current structure is already mostly correct for main sections
    # But practice problems are in wrong order

    # Build correct order
    reordered = []

    # 1. Environment + Title + Sections 1-8 (cells 0-26)
    for i in range(27):
        reordered.append(cells[i])

    # 2. Practice problems in ascending order (1 → 2 → ... → 10)
    practice_problems = [
        (28, 31),  # Problem 1: 도구 개수
        (29, 33),  # Problem 2: 도구 이름
        (30, 35),  # Problem 3: 특정 도구
        (32, 37),  # Problem 4: yfinance
        (34, 39),  # Problem 5: 최고가/최저가
        (36, 41),  # Problem 6: 이동평균선
        (38, 43),  # Problem 7: 도구 함수
        (40, 45),  # Problem 8: @tool
        (42, 46),  # Problem 9: ToolAgentState
        (44, 47),  # Problem 10: 나만의 질문
    ]

    for md_idx, code_idx in practice_problems:
        reordered.append(cells[md_idx])
        reordered.append(cells[code_idx])

    # 3. Divider (49) + Answers (27, 48)
    reordered.append(cells[49])
    reordered.append(cells[27])  # ToolHistory import
    reordered.append(cells[48])  # 정답 예시

    # Clear outputs
    for cell in reordered:
        if cell['cell_type'] == 'code':
            cell['outputs'] = []
            cell['execution_count'] = None

    nb['cells'] = reordered

    with open(nb_path, 'w') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"   ✅ Reordered practice problems (1 → 2 → ... → 10)")
    print(f"   ✅ Total cells: {len(cells)} → {len(reordered)}")

def verify_notebook_order(nb_num: int, nb_path: str, expected_order: List[str]) -> bool:
    """Verify notebook cell order matches expected."""
    with open(nb_path, 'r') as f:
        nb = json.load(f)

    cells = nb['cells']

    print(f"\n🔍 Verifying Notebook {nb_num}...")

    # Check key cells
    errors = []
    for i, expected_text in enumerate(expected_order):
        if i >= len(cells):
            errors.append(f"Cell {i} missing (expected: {expected_text})")
            continue

        cell = cells[i]
        source = ''.join(cell['source'])

        if expected_text not in source:
            errors.append(f"Cell {i}: Expected '{expected_text}', got '{source[:50]}...'")

    if errors:
        print("   ❌ Verification FAILED:")
        for err in errors[:5]:  # Show first 5 errors
            print(f"      {err}")
        return False
    else:
        print(f"   ✅ Structure matches Idris spec")
        return True

if __name__ == '__main__':
    print("="*80)
    print("Fix and Verify Notebooks 1 & 3 per Idris Specifications")
    print("="*80)

    # Step 1: Add section comments
    print("\n📝 Step 1: Adding section comments to code cells...")
    add_section_comments_to_code('notebooks/1_generate.ipynb', NOTEBOOK1_SECTIONS)
    add_section_comments_to_code('notebooks/3_tool_agent.ipynb', NOTEBOOK3_SECTIONS)

    # Step 2: Fix ordering
    print("\n🔧 Step 2: Fixing cell ordering...")
    fix_notebook1()
    fix_notebook3()

    # Step 3: Verify
    print("\n✅ Step 3: Verification...")

    nb1_ok = verify_notebook_order(1, 'notebooks/1_generate.ipynb', [
        '# LangGraph',  # Title
        '# 패키지',  # Imports
        '## 1. 환경',  # Section 1
        '## 실습 문제',  # Practice header at correct position
    ])

    nb3_ok = verify_notebook_order(3, 'notebooks/3_tool_agent.ipynb', [
        '## 환경 설정',  # Environment
        '# Tool 기반',  # Title
        '## 1. 투자',  # Section 1
        '## 9. 실습 문제',  # Practice header
    ])

    print("\n" + "="*80)
    if nb1_ok and nb3_ok:
        print("✅ SUCCESS: All notebooks fixed and verified!")
        print("="*80)
        sys.exit(0)
    else:
        print("❌ FAILURE: Some notebooks have errors")
        print("="*80)
        sys.exit(1)
