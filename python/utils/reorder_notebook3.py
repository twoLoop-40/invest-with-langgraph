"""
Reorder Notebook 3 to follow "Markdown → Code" pattern

Current problem: Code cells appear AFTER the next section header
Target: Each section's code should immediately follow its theory markdown

Pattern for each section:
  ## N. Section Header (markdown)
  ### 이론 (markdown)
  # N. Section code (code)
"""

import json
import sys
from pathlib import Path

def reorder_notebook3():
    """Reorder notebook 3 cells to follow markdown → code pattern"""

    notebook_path = Path("notebooks/3_tool_agent.ipynb")

    # Read notebook
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)

    cells = nb['cells']

    print("🔍 Analyzing Notebook 3...")
    print(f"   Current cell count: {len(cells)}")

    # Define correct order based on current analysis
    # Format: (cell_index, description)
    correct_order = [
        # 환경 설정 (special intro section)
        (0, "환경 설정 markdown"),
        (1, "Title header"),

        # Section 1: 투자 분석 도구 가져오기
        (2, "## 1. Section header"),
        (3, "### 이론 (Section 1)"),
        (4, "Code: 환경 설정"),  # setup
        (7, "Code: 도구 임포트"),  # import-tools (currently at index 7!)

        # Section 2: ReAct Agent 생성
        (5, "## 2. Section header"),
        (6, "### 이론 (Section 2)"),
        (10, "Code: Agent 생성"),  # create-agent (currently at index 10!)

        # Section 3: 그래프 구조 시각화
        (8, "## 3. Section header"),
        (9, "### 이론 (Section 3)"),
        (13, "Code: 그래프 시각화"),  # visualize (currently at index 13!)

        # Section 4: Agent 실행 헬퍼 함수
        (11, "## 4. Section header"),
        (12, "### 이론 (Section 4)"),
        (16, "Code: 헬퍼 함수"),  # helper-function (currently at index 16!)

        # Section 5: 테스트 1
        (14, "## 5. Section header"),
        (15, "### 이론 (Section 5)"),
        (19, "Code: 테스트 1"),  # test-simple (currently at index 19!)

        # Section 6: 테스트 2
        (17, "## 6. Section header"),
        (18, "### 이론 (Section 6)"),
        (22, "Code: 테스트 2"),  # test-complex (currently at index 22!)

        # Section 7: 테스트 3
        (20, "## 7. Section header"),
        (21, "### 이론 (Section 7)"),
        (25, "Code: 테스트 3"),  # test-us-stock (currently at index 25!)

        # Section 8: 불변 속성 검증
        (23, "## 8. Section header"),
        (24, "### 이론 (Section 8)"),
        (48, "Code: 불변 속성 검증"),  # verify-invariants (currently at index 48!)

        # Section 9: 실습 문제 (Practice problems - keep as is)
        (26, "## 9. 실습 문제 header"),
        (27, "문제 1 markdown"),
        (28, "문제 1 code"),
        (29, "문제 2 markdown"),
        (30, "문제 2 code"),
        (31, "문제 3 markdown"),
        (32, "문제 3 code"),
        (33, "문제 4 markdown"),
        (34, "문제 4 code"),
        (35, "문제 5 markdown"),
        (36, "문제 5 code"),
        (37, "문제 6 markdown"),
        (38, "문제 6 code"),
        (39, "문제 7 markdown"),
        (40, "문제 7 code"),
        (41, "문제 8 markdown"),
        (42, "문제 8 code"),
        (43, "문제 9 markdown"),
        (44, "문제 9 code"),
        (45, "문제 10 markdown"),
        (46, "문제 10 code"),
        (47, "정답 확인 divider"),
        (49, "정답 예시 code"),
    ]

    # Reorder cells
    new_cells = []
    for idx, desc in correct_order:
        if idx < len(cells):
            new_cells.append(cells[idx])
            print(f"   ✓ {idx:2d} → {len(new_cells)-1:2d}: {desc}")
        else:
            print(f"   ✗ {idx:2d} (out of range): {desc}")

    # Update notebook
    nb['cells'] = new_cells

    # Write back
    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"\n✅ Notebook 3 reordered successfully!")
    print(f"   New cell count: {len(new_cells)}")
    print(f"   Saved to: {notebook_path}")

    # Verify structure
    print("\n🔍 Verifying new structure:")
    for i, cell in enumerate(new_cells[:30]):  # Check first 30 cells
        cell_type = cell['cell_type']
        first_line = ''.join(cell['source'][:1])[:50].strip()
        print(f"   {i:2d}. [{cell_type:4s}] {first_line}")

if __name__ == "__main__":
    reorder_notebook3()
