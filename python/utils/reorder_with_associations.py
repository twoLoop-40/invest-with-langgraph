#!/usr/bin/env python3
"""
Reorder notebooks using association maps from Idris CellAssociation spec.

Algorithm (from Idris specification):
1. For each association (explanation → code cells):
   a. Output explanation cell
   b. Output all associated code cells
2. Output any unassociated cells at the end

Example transformation:
  Original: [Expl1, Expl2, Expl3, Code1, Code2, Code3]
  Map: Expl1→Code1, Expl2→Code2, Expl3→Code3
  Result:  [Expl1, Code1, Expl2, Code2, Expl3, Code3]
"""
import json
import os
from typing import Dict, List

# Association maps from Idris CellAssociation.idr
# NOTE: Convert to 0-based indexing for Python

NOTEBOOK1_ASSOCIATIONS = {
    1: [12],              # Cell 1 -> Cell 12
    2: [13],              # Cell 2: ## 1. 환경 변수 로드
    3: [14],              # Cell 3: ## 2. LLM 기본 사용법
    4: [15],              # Cell 4: ## 3. Agent 상태 정의
    5: [16],              # Cell 5: ## 4. StateGraph 생성
    6: [17],              # Cell 6: ## 5. 노드 함수 정의
    7: [18],              # Cell 7: ## 6. 그래프에 노드 추가
    8: [19],              # Cell 8: ## 7. 엣지 연결
    9: [21],              # Cell 9: ## 8. 그래프 컴파일
    10: [22],             # Cell 10: ## 9. 그래프 시각화
    11: [23],             # Cell 11: ## 10. 그래프 실행 테스트
    20: [24, 25, 26, 27]  # Cell 20: ## 실습 문제
}

NOTEBOOK2_ASSOCIATIONS = {
    2: [12],                                      # Cell 2: ## 1. 환경 변수 로드
    3: [13],                                      # Cell 3: ## 2. LLM 초기화
    4: [14],                                      # Cell 4: ## 3. AgentState 정의
    5: [15],                                      # Cell 5: ## 4. Generate 노드
    6: [16],                                      # Cell 6: ## 5. QA 평가 노드
    7: [17],                                      # Cell 7: ## 6. 웹 검색 노드
    8: [18],                                      # Cell 8: ## 7. 그래프 구성
    9: [20],                                      # Cell 9: ## 8. 그래프 시각화
    10: [21],                                     # Cell 10: ## 9. 실행 테스트
    11: [22],                                     # Cell 11: ## 10. 일반 지식 질문
    19: [23, 24, 25, 26, 27, 28, 29, 30, 31]     # Cell 19: ## 실습 문제
}


def validate_associations(associations: Dict[int, List[int]], total_cells: int) -> None:
    """
    Validate association map (from Idris Validation namespace).

    Checks:
    1. No duplicate indices
    2. All indices are within valid range
    """
    all_indices = []
    for expl_idx, code_indices in associations.items():
        all_indices.append(expl_idx)
        all_indices.extend(code_indices)

    # Convert to 0-based
    all_indices_0based = [i - 1 for i in all_indices]

    # Check duplicates
    seen = set()
    duplicates = []
    for idx in all_indices_0based:
        if idx in seen:
            duplicates.append(idx + 1)  # Back to 1-based for display
        seen.add(idx)

    if duplicates:
        print(f"⚠️  Warning: Duplicate indices found: {duplicates}")

    # Check range
    out_of_range = [i + 1 for i in all_indices_0based if i < 0 or i >= total_cells]
    if out_of_range:
        print(f"⚠️  Warning: Out of range indices: {out_of_range} (total cells: {total_cells})")


def reorder_notebook_with_associations(notebook_path: str, associations: Dict[int, List[int]]) -> None:
    """
    Reorder notebook using association map (from Idris CellAssociation spec).

    Args:
        notebook_path: Path to notebook file
        associations: Map from explanation cell index (1-based) to code cell indices (1-based)
    """
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)

    cells = nb['cells']
    total_cells = len(cells)

    # Validate associations (from Idris Validation namespace)
    print(f"📋 Validating associations for {os.path.basename(notebook_path)}...")
    validate_associations(associations, total_cells)

    # Convert to 0-based indexing
    associations_0based = {k-1: [c-1 for c in v] for k, v in associations.items()}

    # Track which cells have been placed
    placed_indices = set()

    # Build reordered cell list
    reordered_cells = []

    # Step 1: Process associations in order
    for expl_idx in sorted(associations_0based.keys()):
        code_indices = associations_0based[expl_idx]

        # Add explanation cell
        reordered_cells.append(cells[expl_idx])
        placed_indices.add(expl_idx)

        # Add associated code cells
        for code_idx in code_indices:
            if code_idx < total_cells:
                reordered_cells.append(cells[code_idx])
                placed_indices.add(code_idx)

    # Step 2: Add any unassociated cells at the end
    for i, cell in enumerate(cells):
        if i not in placed_indices:
            reordered_cells.append(cell)
            placed_indices.add(i)

    # Verify we didn't lose any cells
    assert len(reordered_cells) == total_cells, \
        f"Cell count mismatch: {len(reordered_cells)} != {total_cells}"

    # Write back
    nb['cells'] = reordered_cells

    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"✅ Reordered {notebook_path}")
    print(f"   Associations applied: {len(associations)}")
    print(f"   Total cells: {total_cells}")
    print(f"   Placed cells: {len(placed_indices)}")


if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))

    nb1_path = os.path.join(project_root, 'notebooks/1_generate.ipynb')
    nb2_path = os.path.join(project_root, 'notebooks/2_web_search.ipynb')

    print("=== Reordering notebooks with association maps ===\n")

    reorder_notebook_with_associations(nb1_path, NOTEBOOK1_ASSOCIATIONS)
    print()
    reorder_notebook_with_associations(nb2_path, NOTEBOOK2_ASSOCIATIONS)

    print("\n✅ All notebooks reordered per Idris CellAssociation specification!")
