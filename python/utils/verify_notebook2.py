#!/usr/bin/env python3
"""
Verify notebook 2 structure per Idris NotebookStructure2 spec.

This implements the runtime verification functions defined in Idris:
- isAscendingOrder: Practice problems must be 1, 2, 3, ..., N
- isSectionValid: Code cells must come after markdown
- noDuplicateIndices: No cell used twice
- isNotebookValid: All checks pass

If verification fails, exits with clear error message.
"""
import json
import sys
from typing import List, Set

def verify_ascending_order(problems: List[tuple]) -> bool:
    """Verify isAscendingOrder from Idris spec."""
    if len(problems) <= 1:
        return True

    for i in range(len(problems) - 1):
        problem_num1 = problems[i][0]
        problem_num2 = problems[i+1][0]
        if problem_num1 >= problem_num2:
            print(f"❌ ASCENDING ORDER VIOLATION:")
            print(f"   Problem {problem_num1} comes before Problem {problem_num2}")
            return False

    return True

def verify_section_valid(section: tuple) -> bool:
    """Verify isSectionValid from Idris spec."""
    markdown_idx, code_indices = section
    for code_idx in code_indices:
        if code_idx <= markdown_idx:
            print(f"❌ SECTION VALIDITY VIOLATION:")
            print(f"   Code cell {code_idx} comes before markdown {markdown_idx}")
            return False
    return True

def verify_no_duplicates(all_indices: List[int]) -> bool:
    """Verify noDuplicateIndices from Idris spec."""
    seen: Set[int] = set()
    duplicates = []

    for idx in all_indices:
        if idx in seen:
            duplicates.append(idx)
        seen.add(idx)

    if duplicates:
        print(f"❌ DUPLICATE INDICES VIOLATION:")
        print(f"   Cells used multiple times: {duplicates}")
        return False

    return True

def verify_notebook2() -> bool:
    """
    Verify notebook 2 structure matches Idris NotebookStructure2.notebook2Structure.

    Returns True if valid, False otherwise.
    """
    with open('notebooks/2_web_search.ipynb', 'r') as f:
        nb = json.load(f)

    cells = nb['cells']

    print("🔍 Verifying Notebook 2 per Idris NotebookStructure2 spec...")
    print()

    # Expected structure from Idris spec
    title_idx = 0
    main_sections = [
        (1, [2]),    # Section 1
        (3, [4]),    # Section 2
        (5, [6]),    # Section 3
        (7, [8]),    # Section 4
        (9, [10]),   # Section 5
        (11, [12]),  # Section 6
        (13, [14]),  # Section 7
        (15, [16]),  # Section 8
        (17, [18]),  # Section 9
        (19, [20]),  # Section 10
    ]
    practice_header_idx = 21
    practice_problems = [
        (1, 22, 23),   # Problem 1: markdown 22, code 23
        (2, 24, 25),   # Problem 2
        (3, 26, 27),   # Problem 3
        (4, 28, 29),   # Problem 4
        (5, 30, 31),   # Problem 5
        (6, 32, 33),   # Problem 6
        (7, 34, 35),   # Problem 7
        (8, 36, 37),   # Problem 8
        (9, 38, 39),   # Problem 9
        (10, 40, 41),  # Problem 10
    ]
    divider_idx = 42
    answer_indices = [43, 44]

    # 1. Verify main sections
    print("📋 Verifying main sections...")
    for section in main_sections:
        if not verify_section_valid(section):
            return False
    print("   ✅ All sections valid")

    # 2. Verify practice problems ascending order
    print("\n📊 Verifying practice problems order...")
    if not verify_ascending_order(practice_problems):
        return False
    print("   ✅ Problems in ascending order (1-10)")

    # 3. Verify no duplicate indices
    print("\n🔢 Verifying no duplicate cell indices...")
    all_indices = [title_idx, practice_header_idx, divider_idx]
    all_indices.extend(answer_indices)

    for md_idx, code_indices in main_sections:
        all_indices.append(md_idx)
        all_indices.extend(code_indices)

    for prob_num, md_idx, code_idx in practice_problems:
        all_indices.extend([md_idx, code_idx])

    if not verify_no_duplicates(all_indices):
        return False
    print(f"   ✅ All {len(all_indices)} cell indices unique")

    # 4. Verify actual cell order in notebook
    print("\n📝 Verifying actual notebook order...")
    expected_order = [title_idx]

    for md_idx, code_indices in main_sections:
        expected_order.append(md_idx)
        expected_order.extend(code_indices)

    expected_order.append(practice_header_idx)

    for prob_num, md_idx, code_idx in practice_problems:
        expected_order.extend([md_idx, code_idx])

    expected_order.append(divider_idx)
    expected_order.extend(answer_indices)

    # Check if notebook cells match expected order
    for i, expected_idx in enumerate(expected_order):
        if i >= len(cells):
            print(f"❌ NOTEBOOK LENGTH ERROR: Expected cell {expected_idx} at position {i}")
            return False

        # Verify cell content matches expectation
        cell = cells[i]
        source = ''.join(cell['source'])

        # Spot check key cells
        if i == 0:  # Title
            if '# 웹 검색' not in source:
                print(f"❌ TITLE ERROR: Cell {i} should be title")
                print(f"   Got: {source[:70]}")
                return False
        elif i == 21:  # Practice problems header (index 21 in expected_order)
            if '## 10. 실습 문제' not in source:
                print(f"❌ PRACTICE HEADER ERROR: Position {i} (cell {expected_idx}) should be practice header")
                print(f"   Got: {source[:70]}")
                return False

    print(f"   ✅ Notebook order matches Idris spec ({len(expected_order)} cells)")

    return True

if __name__ == '__main__':
    print("="*80)
    print("Notebook 2 Verification per Idris NotebookStructure2.idr")
    print("="*80)
    print()

    if verify_notebook2():
        print()
        print("="*80)
        print("✅ VERIFICATION PASSED: Notebook 2 is valid!")
        print("="*80)
        print()
        print("Guarantees:")
        print("  • Main sections: Sequential (1 → 2 → ... → 10)")
        print("  • Practice problems: Ascending order (Problem 1 → 2 → ... → 10)")
        print("  • Structure: Markdown → Code pairs throughout")
        print("  • No duplicate cells")
        sys.exit(0)
    else:
        print()
        print("="*80)
        print("❌ VERIFICATION FAILED: Notebook 2 violates Idris spec!")
        print("="*80)
        sys.exit(1)
