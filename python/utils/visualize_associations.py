#!/usr/bin/env python3
"""
Visualize cell associations for notebooks 1 and 2.
Based on Idris CellAssociation specification.
"""
import json

# Association maps from Idris specification (CellAssociation.idr)
# Note: Idris uses 1-based indexing, Python uses 0-based
# Subtract 1 from all indices for Python

NOTEBOOK1_ASSOCIATIONS = {
    1: [12],              # ## 1. 환경 변수 로드
    2: [13],              # ## 2. LLM 기본 사용법
    3: [14],              # ## 3. Agent 상태 정의
    4: [15],              # ## 4. StateGraph 생성
    5: [16],              # ## 5. 노드 함수 정의
    6: [17],              # ## 6. 그래프에 노드 추가
    7: [18],              # ## 7. 엣지 연결
    8: [20],              # ## 8. 그래프 컴파일
    9: [21],              # ## 9. 그래프 시각화
    10: [22],             # ## 10. 그래프 실행 테스트
    19: [23, 24, 25, 26]  # ## 실습 문제
}

NOTEBOOK2_ASSOCIATIONS = {
    1: [11],                                      # ## 1. 환경 변수 로드
    2: [12],                                      # ## 2. LLM 초기화
    3: [13],                                      # ## 3. AgentState 정의
    4: [14],                                      # ## 4. Generate 노드
    5: [15],                                      # ## 5. QA 평가 노드
    6: [16],                                      # ## 6. 웹 검색 노드
    7: [17],                                      # ## 7. 그래프 구성
    8: [19],                                      # ## 8. 그래프 시각화
    9: [20],                                      # ## 9. 실행 테스트
    10: [21],                                     # ## 10. 일반 지식 질문 테스트
    11: [22, 23, 24, 25, 26, 27, 28, 29, 30, 31] # ## 실습 문제
}

def visualize_notebook(notebook_path, associations, notebook_name):
    """Visualize associations for a notebook"""
    with open(notebook_path, 'r') as f:
        nb = json.load(f)

    print(f'\n{"=" * 80}')
    print(f'{notebook_name} - Cell Association Visualization')
    print(f'{"=" * 80}\n')

    # Convert to 0-based indexing
    associations_0based = {k-1: [c-1 for c in v] for k, v in associations.items()}

    for expl_idx, code_indices in sorted(associations_0based.items()):
        # Get explanation cell
        expl_cell = nb['cells'][expl_idx]
        expl_source = ''.join(expl_cell.get('source', []))
        expl_title = expl_source.split('\n')[0][:70]

        print(f'📝 Cell {expl_idx+1}: {expl_title}')
        print(f'   └─> 코드 셀: ', end='')

        for i, code_idx in enumerate(code_indices):
            code_cell = nb['cells'][code_idx]
            code_source = ''.join(code_cell.get('source', []))
            code_first_line = code_source.split('\n')[0][:60]

            if i == 0:
                print(f'Cell {code_idx+1}: {code_first_line}')
            else:
                print(f'       Cell {code_idx+1}: {code_first_line}')
        print()

    # Summary
    total_explanations = len(associations)
    total_code_cells = sum(len(codes) for codes in associations.values())
    print(f'\n📊 Summary:')
    print(f'   - Total associations: {total_explanations}')
    print(f'   - Total mapped code cells: {total_code_cells}')
    print(f'   - Average code cells per explanation: {total_code_cells/total_explanations:.1f}')

if __name__ == '__main__':
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))

    nb1_path = os.path.join(project_root, 'notebooks/1_generate.ipynb')
    nb2_path = os.path.join(project_root, 'notebooks/2_web_search.ipynb')

    visualize_notebook(nb1_path, NOTEBOOK1_ASSOCIATIONS, 'NOTEBOOK 1 (Generate)')
    visualize_notebook(nb2_path, NOTEBOOK2_ASSOCIATIONS, 'NOTEBOOK 2 (Web Search)')

    print(f'\n{"=" * 80}')
    print('✅ Association visualization complete!')
    print(f'{"=" * 80}\n')
