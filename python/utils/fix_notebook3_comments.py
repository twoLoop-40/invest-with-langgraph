#!/usr/bin/env python3
"""
Fix notebook 3 code cell comments to match actual code content.

Problem: Comments are shifted - they don't match the actual code
Solution: Analyze code content and add correct section comments
"""
import json

# Correct mapping based on actual code content analysis
CORRECT_MAPPINGS = {
    4: "# 1. 투자 분석 도구 가져오기 - 환경 설정",  # from dotenv, sys.path
    7: "# 1. 투자 분석 도구 가져오기 - 도구 임포트",  # import sys, AVAILABLE_TOOLS
    10: "# 2. ReAct Agent 생성",  # ChatOpenAI, create_react_agent
    13: "# 3. 그래프 구조 시각화",  # Image, display
    16: "# 4. Agent 실행 헬퍼 함수",  # def run_agent
    19: "# 5. 테스트 1: 간단한 주가 조회",  # result1 = run_agent
    22: "# 6. 테스트 2: 복합 분석",  # result2 = run_agent
    25: "# 7. 테스트 3: 미국 주식 분석",  # result3 = run_agent
}

def fix_notebook3():
    """Fix code cell comments in notebook 3."""
    nb_path = 'notebooks/3_tool_agent.ipynb'

    with open(nb_path, 'r') as f:
        nb = json.load(f)

    cells = nb['cells']

    print("Fixing Notebook 3 code cell comments...")
    print("="*80)

    for cell_idx, correct_comment in CORRECT_MAPPINGS.items():
        if cell_idx >= len(cells):
            continue

        cell = cells[cell_idx]
        if cell['cell_type'] != 'code':
            continue

        source = cell['source']
        if not source:
            continue

        # Replace first line if it's a comment
        if source[0].strip().startswith('#'):
            old_comment = source[0].strip()
            source[0] = correct_comment + '\n'
            print(f"Cell {cell_idx}:")
            print(f"  Old: {old_comment}")
            print(f"  New: {correct_comment}")
        else:
            # Insert comment
            source.insert(0, correct_comment + '\n')
            print(f"Cell {cell_idx}: Added comment: {correct_comment}")

    with open(nb_path, 'w') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print("\n✅ Fixed all code cell comments in notebook 3!")

if __name__ == '__main__':
    fix_notebook3()
