#!/usr/bin/env python3
"""
Reorder notebook cells to place explanation markdown cells before code cells.
This improves readability for students.

Current structure: code -> explanation
Target structure: explanation -> code
"""
import json
import sys

def get_source_text(cell):
    """Get source text from cell (handles both string and list formats)"""
    source = cell.get('source', '')
    if isinstance(source, list):
        return ''.join(source)
    return source

def reorder_notebook(notebook_path):
    """Reorder cells so explanations come before code"""
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)

    cells = nb['cells']
    reordered = []

    i = 0
    while i < len(cells):
        cell = cells[i]

        # Check if this is a code cell followed by markdown explanation
        if cell['cell_type'] == 'code' and i + 1 < len(cells):
            next_cell = cells[i + 1]

            # Check if next cell is explanation (markdown starting with ##)
            if next_cell['cell_type'] == 'markdown':
                next_source = get_source_text(next_cell)
                if next_source.startswith('##'):
                    # Swap: put explanation before code
                    reordered.append(next_cell)
                    reordered.append(cell)
                    i += 2  # Skip both cells
                    continue

        # No special handling needed - keep cell as is
        reordered.append(cell)
        i += 1

    nb['cells'] = reordered

    # Write back
    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb, f, ensure_ascii=False, indent=1)

    print(f"✅ Reordered {notebook_path}")

if __name__ == '__main__':
    import os

    # Get project root directory (2 levels up from this script)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))

    notebooks = [
        os.path.join(project_root, 'notebooks/1_generate.ipynb'),
        os.path.join(project_root, 'notebooks/2_web_search.ipynb'),
        os.path.join(project_root, 'notebooks/3_tool_agent.ipynb')
    ]

    for nb_path in notebooks:
        if os.path.exists(nb_path):
            reorder_notebook(nb_path)
        else:
            print(f"⚠️ File not found: {nb_path}")

    print("\n✅ All notebooks reordered successfully!")
