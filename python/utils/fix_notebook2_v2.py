#!/usr/bin/env python3
"""
Fix notebook 2 with proper cell ordering.

Strategy:
1. Main sections (1-10): markdown → code pairs
2. Practice problems header
3. Practice problems (1-10): markdown → code pairs in ascending order
4. Divider (---)
5. Answer examples
"""
import json

notebook_path = 'notebooks/2_web_search.ipynb'

with open(notebook_path, 'r') as f:
    nb = json.load(f)

cells = nb['cells']

# Analyze cells
print("분석 중...")
for i, cell in enumerate(cells):
    source = ''.join(cell['source'])
    first_line = source.strip().split('\n')[0][:70] if source else ''
    if '문제' in first_line or 'TODO' in first_line[:30]:
        cell_type = '📝' if cell['cell_type'] == 'markdown' else '💻'
        print(f'{i:2}. {cell_type} {first_line}')

print("\n올바른 순서로 재배열합니다...")

# Define correct order
reordered = []

# 1. Title and main sections (0-20)
for i in range(21):  # Cells 0-20: Title + sections 1-10
    reordered.append(cells[i])

# 2. Practice problems header (cell 21)
reordered.append(cells[21])  # ## 10. 실습 문제

# 3. Practice problems in order (1-10)
# Correct mapping based on problem descriptions and TODO content
problem_order = [
    (42, 22),  # 문제 1: AgentState 타입 이해 → TODO: AgentState 필드 출력
    (40, 23),  # 문제 2: State 생성 → TODO: 초기 상태 생성
    (38, 43),  # 문제 3: LLM 답변 → TODO: 주식 투자란 답변
    (37, 24),  # 문제 4: Pydantic 구조화 → TODO: EvaledAnswer 생성
    (35, 41),  # 문제 5: 평가 점수 → TODO: 점수에 따라 행동
    (33, 39),  # 문제 6: 조건부 로직 → TODO: 최대 반복 횟수
    (32, 25),  # 문제 7: Tavily API → TODO: 삼성전자 검색
    (31, 36),  # 문제 8: Context 누적 → TODO: Context 누적 로직
    (30, 34),  # 문제 9: StateGraph 노드 → TODO: StateGraph 생성
    (29, 26),  # 문제 10: 워크플로우 → TODO: 나만의 질문
]

for md_idx, code_idx in problem_order:
    reordered.append(cells[md_idx])
    reordered.append(cells[code_idx])

# 4. Divider (---)
reordered.append(cells[28])

# 5. Answer examples (cell 27)
reordered.append(cells[27])

# 6. Any remaining cells
placed = set(range(21)) | {21, 28, 27}
for md_idx, code_idx in problem_order:
    placed.add(md_idx)
    placed.add(code_idx)

for i in range(len(cells)):
    if i not in placed:
        reordered.append(cells[i])
        print(f"⚠️  Adding unplaced cell {i}")

# Clear outputs
for cell in reordered:
    if cell['cell_type'] == 'code':
        cell['outputs'] = []
        cell['execution_count'] = None

nb['cells'] = reordered

with open(notebook_path, 'w') as f:
    json.dump(nb, f, ensure_ascii=False, indent=1)

print(f"\n✅ Fixed notebook 2 order!")
print(f"   Total cells: {len(cells)} → {len(reordered)}")

# Show first 25 and practice problems
print("\n메인 섹션 (First 22 cells):")
for i in range(min(22, len(reordered))):
    cell = reordered[i]
    cell_type = cell['cell_type']
    source = ''.join(cell['source'])
    first_line = source.strip().split('\n')[0][:70] if source else ''
    marker = '📝' if cell_type == 'markdown' else '💻'
    print(f'{i+1:2}. {marker} {first_line}')

print("\n실습 문제 섹션 (Cells 22-43):")
for i in range(21, min(43, len(reordered))):
    cell = reordered[i]
    cell_type = cell['cell_type']
    source = ''.join(cell['source'])
    first_line = source.strip().split('\n')[0][:70] if source else ''
    marker = '📝' if cell_type == 'markdown' else '💻'
    print(f'{i+1:2}. {marker} {first_line}')
