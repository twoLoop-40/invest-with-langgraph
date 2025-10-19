#!/usr/bin/env python3
"""
Clean and reorder notebooks per Idris NotebookCleaning specification.

Workflow (from Idris spec):
1. Clean outputs (remove all outputs from code cells)
2. Classify cells (markdown vs code)
3. Match cells (sequential: Nth markdown header → Nth code cell)
4. Reorder cells (markdown → code pairs)
"""
import json
import os
from typing import List, Tuple, Dict

def clean_outputs(notebook_path: str) -> None:
    """Remove all outputs from code cells."""
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)

    for cell in nb['cells']:
        if cell['cell_type'] == 'code':
            cell['outputs'] = []
            cell['execution_count'] = None

    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"✅ Cleaned outputs from {os.path.basename(notebook_path)}")


def classify_cells(cells: List[dict]) -> Tuple[List[Tuple[int, dict]], List[Tuple[int, dict]]]:
    """
    Classify cells into markdown and code cells.

    Returns:
        (markdown_cells, code_cells) where each is [(index, cell), ...]
    """
    markdown_cells = [(i, cell) for i, cell in enumerate(cells) if cell['cell_type'] == 'markdown']
    code_cells = [(i, cell) for i, cell in enumerate(cells) if cell['cell_type'] == 'code']

    return markdown_cells, code_cells


def is_header_cell(cell: dict) -> bool:
    """Check if markdown cell is a header (starts with #)."""
    source = ''.join(cell['source'])
    return source.strip().startswith('#')


def is_section_header(cell: dict) -> bool:
    """Check if markdown cell is a major section header (## N.)."""
    source = ''.join(cell['source'])
    lines = source.strip().split('\n')
    if not lines:
        return False
    first_line = lines[0].strip()
    # Match patterns like "## 1. ", "## 2. ", etc.
    return first_line.startswith('##') and '. ' in first_line


def extract_keywords(text: str) -> set:
    """Extract keywords from text (remove common words, numbers, punctuation)."""
    import re
    # Remove markdown syntax, numbers, punctuation
    text = re.sub(r'[#\d\.:\(\)\-]', ' ', text.lower())
    # Split and filter short words
    words = {w.strip() for w in text.split() if len(w.strip()) > 2}
    # Remove common Korean/English stop words
    stop_words = {'the', 'and', 'for', 'with', 'from', 'this', 'that', '개선', '수정', '변경'}
    return words - stop_words


def get_code_cell_title(cell: dict) -> str:
    """Extract title from code cell's first comment line."""
    source = ''.join(cell['source'])
    lines = [line.strip() for line in source.split('\n') if line.strip()]
    if not lines:
        return ''
    first_line = lines[0]
    # Extract comment (# ...)
    if first_line.startswith('#'):
        return first_line[1:].strip()
    return ''


def get_markdown_title(cell: dict) -> str:
    """Extract clean title from markdown header."""
    source = ''.join(cell['source'])
    lines = source.strip().split('\n')
    if not lines:
        return ''
    first_line = lines[0].strip()
    # Remove ## and numbering (e.g., "## 2. LLM 초기화" → "LLM 초기화")
    import re
    title = re.sub(r'^#+\s*\d*\.\s*', '', first_line)
    return title.strip()


def match_cells_by_keyword(markdown_cells: List[Tuple[int, dict]],
                           code_cells: List[Tuple[int, dict]]) -> List[Dict]:
    """
    Match markdown headers to code cells using keyword matching.

    Strategy:
    1. Extract title from each markdown header (## N. Title)
    2. Extract title from each code cell's first comment (# Title)
    3. Match by keyword overlap
    4. Return matches in logical order
    """
    matches = []

    # Find title cell (single # header)
    title_cells = [(idx, cell) for idx, cell in markdown_cells if is_header_cell(cell) and not is_section_header(cell)]
    if title_cells:
        source = ''.join(title_cells[0][1]['source'])
        if source.strip().startswith('# ') and not source.strip().startswith('##'):
            matches.append({'markdown_idx': title_cells[0][0], 'code_indices': []})

    # Get section headers only
    section_headers = [(idx, cell) for idx, cell in markdown_cells if is_section_header(cell)]

    # For each section header, find matching code cell(s)
    for md_idx, md_cell in section_headers:
        md_title = get_markdown_title(md_cell)
        md_keywords = extract_keywords(md_title)

        matched_code_indices = []

        # Find code cells with overlapping keywords
        for code_idx, code_cell in code_cells:
            code_title = get_code_cell_title(code_cell)
            code_keywords = extract_keywords(code_title)

            # Check keyword overlap
            overlap = md_keywords & code_keywords
            if overlap:
                matched_code_indices.append(code_idx)

        # If no keyword match, try sequential matching as fallback
        if not matched_code_indices:
            # Find next unmatched code cell
            used_code_indices = set()
            for m in matches:
                used_code_indices.update(m['code_indices'])

            for code_idx, _ in code_cells:
                if code_idx not in used_code_indices:
                    matched_code_indices = [code_idx]
                    break

        matches.append({'markdown_idx': md_idx, 'code_indices': matched_code_indices})

    return matches


def reorder_cells(cells: List[dict], matches: List[Dict]) -> List[dict]:
    """
    Reorder cells based on matches.

    Args:
        cells: Original cell list
        matches: List of {markdown_idx: int, code_indices: [int, ...]}

    Returns:
        Reordered cells (markdown → code → markdown → code ...)
    """
    reordered = []
    placed_indices = set()

    # Apply matches in order
    for match in matches:
        md_idx = match['markdown_idx']
        code_indices = match['code_indices']

        # Add markdown cell
        if md_idx < len(cells):
            reordered.append(cells[md_idx])
            placed_indices.add(md_idx)

        # Add code cells
        for code_idx in code_indices:
            if code_idx < len(cells):
                reordered.append(cells[code_idx])
                placed_indices.add(code_idx)

    # Add unmatched cells at the end
    for i, cell in enumerate(cells):
        if i not in placed_indices:
            reordered.append(cell)
            placed_indices.add(i)

    return reordered


def clean_and_reorder_notebook(notebook_path: str) -> None:
    """
    Complete workflow: clean outputs, classify, match, and reorder.
    """
    # Step 1: Clean outputs
    clean_outputs(notebook_path)

    # Step 2: Load notebook
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)

    cells = nb['cells']

    # Step 3: Classify cells
    markdown_cells, code_cells = classify_cells(cells)
    print(f"  📊 Classification: {len(markdown_cells)} markdown, {len(code_cells)} code")

    # Step 4: Match cells by keyword
    matches = match_cells_by_keyword(markdown_cells, code_cells)
    print(f"  🔗 Matches: {len(matches)} associations")

    # Debug: Print matches
    for match in matches[:5]:  # Show first 5
        md_idx = match['markdown_idx']
        code_indices = match['code_indices']
        md_title = get_markdown_title(cells[md_idx])
        print(f"      '{md_title}' → {len(code_indices)} code cell(s)")

    # Step 5: Reorder cells
    reordered_cells = reorder_cells(cells, matches)

    # Step 6: Write back
    nb['cells'] = reordered_cells

    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"✅ Reordered {os.path.basename(notebook_path)}")
    print(f"   Total cells: {len(cells)} → {len(reordered_cells)}")


if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))

    notebooks = [
        os.path.join(project_root, 'notebooks/1_generate.ipynb'),
        os.path.join(project_root, 'notebooks/2_web_search.ipynb'),
        os.path.join(project_root, 'notebooks/3_tool_agent.ipynb'),
    ]

    print("=== Cleaning and Reordering Notebooks (per Idris NotebookCleaning spec) ===\n")

    for nb_path in notebooks:
        if os.path.exists(nb_path):
            print(f"📒 Processing {os.path.basename(nb_path)}...")
            clean_and_reorder_notebook(nb_path)
            print()
        else:
            print(f"⚠️  Skipping {os.path.basename(nb_path)} (not found)")

    print("✅ All notebooks cleaned and reordered!")
