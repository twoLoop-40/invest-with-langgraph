#!/usr/bin/env python3
"""
Fix notebook 2 order based on manual analysis.
"""
import json

notebook_path = 'notebooks/2_web_search.ipynb'

with open(notebook_path, 'r') as f:
    nb = json.load(f)

cells = nb['cells']

# Define correct order (0-indexed)
correct_order = [
    29,  # Title: # 웹 검색 기반 주식 투자 챗봇
    30,  # ## 1. 환경 변수 로드
    0,   # Code: # 환경 변수 로드
    2,   # ## 2. LLM 초기화
    4,   # Code: # LLM 초기화
    6,   # ## 3. AgentState 정의
    8,   # Code: # State 정의
    10,  # ## 4. Generate 노드
    12,  # Code: # Generate 노드
    14,  # ## 5. QA 평가 노드
    16,  # Code: # QA 평가 노드
    18,  # ## 6. 웹 검색 노드
    1,   # Code: # Web Search 노드
    3,   # ## 7. 그래프 구성
    5,   # Code: # 그래프 구성
    7,   # ## 8. 그래프 시각화
    9,   # Code: # 그래프 시각화
    11,  # ## 9. 실행 테스트
    13,  # Code: # 실행 테스트
    20,  # ## 10. 일반 지식 질문 테스트
    15,  # Code: # 웹 검색 없이도 답변 가능
    17,  # ## 10. 실습 문제
    # Practice problems...
]

# Add remaining cells (practice problem cells)
placed = set(correct_order)
for i in range(len(cells)):
    if i not in placed:
        correct_order.append(i)

# Reorder
reordered_cells = [cells[i] for i in correct_order]

# Clear outputs
for cell in reordered_cells:
    if cell['cell_type'] == 'code':
        cell['outputs'] = []
        cell['execution_count'] = None

nb['cells'] = reordered_cells

with open(notebook_path, 'w') as f:
    json.dump(nb, f, ensure_ascii=False, indent=1)

print(f"✅ Fixed notebook 2 order!")
print(f"   Total cells: {len(cells)}")
print(f"   Reordered cells: {len(reordered_cells)}")

# Show first 25
print("\nFirst 25 cells:")
for i in range(min(25, len(reordered_cells))):
    cell = reordered_cells[i]
    cell_type = cell['cell_type']
    source = ''.join(cell['source'])
    first_line = source.strip().split('\n')[0][:70] if source else ''
    marker = '📝' if cell_type == 'markdown' else '💻'
    print(f'{i+1:2}. {marker} {first_line}')
