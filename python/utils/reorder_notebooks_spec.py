#!/usr/bin/env python3
"""
Notebook cell reordering based on Idris NotebookStructure specification.

Implements the formal specification from idris/Domain/NotebookStructure.idr:
- CellType: Markdown | Code
- CellContent: Header | Explanation | CodeBlock | Other
- Section: groups related cells (header + explanations + code + other)
- ValidSection invariant: explanations before code
- ValidNotebook invariant: all sections are valid

Classification rules (from Idris spec):
1. Markdown starting with "##" -> Header
2. Markdown with keywords (이론, 코드 설명, 설명, 학습 목표, theory, explanation) -> Explanation
3. Other markdown -> Other
4. Code cells -> CodeBlock
"""
import json
import os
from enum import Enum
from dataclasses import dataclass
from typing import List, Optional, Dict, Any


class CellType(Enum):
    """Cell types in Jupyter notebook (from Idris spec)"""
    MARKDOWN = "markdown"
    CODE = "code"


class CellContent(Enum):
    """Cell content classification (from Idris spec)"""
    HEADER = "header"
    SECTION_WITH_EXPLANATION = "section_with_explanation"
    EXPLANATION = "explanation"
    CODE_BLOCK = "code_block"
    OTHER = "other"


@dataclass
class Cell:
    """A notebook cell with type and classified content"""
    cell_type: CellType
    content_type: CellContent
    raw_cell: Dict[str, Any]  # Original notebook cell data


@dataclass
class Section:
    """
    A section groups related cells (from Idris spec).
    Invariant: explanations come before code_cells when flattened.
    """
    header: Optional[Cell]
    explanations: List[Cell]
    code_cells: List[Cell]
    other_cells: List[Cell]

    def flatten(self) -> List[Cell]:
        """
        Flatten section to cell list in correct order (from Idris spec).
        Order: header -> explanations -> code_cells -> other_cells
        """
        result = []
        if self.header:
            result.append(self.header)
        result.extend(self.explanations)
        result.extend(self.code_cells)
        result.extend(self.other_cells)
        return result


@dataclass
class Notebook:
    """A notebook is a sequence of sections (from Idris spec)"""
    sections: List[Section]

    def flatten(self) -> List[Cell]:
        """Flatten all sections to cell list"""
        result = []
        for section in self.sections:
            result.extend(section.flatten())
        return result


def get_source_text(cell: Dict[str, Any]) -> str:
    """Extract source text from notebook cell"""
    source = cell.get('source', '')
    if isinstance(source, list):
        return ''.join(source)
    return source


def classify_content(text: str, cell_type: CellType) -> CellContent:
    """
    Classify cell content based on text and type (from Idris spec).

    Rules (priority order):
    1. Code cells -> CodeBlock
    2. Markdown starting with "##" AND containing explanation subsections
       -> SectionWithExplanation
    3. Markdown starting with "##" without explanation -> Header
    4. Markdown with explanation subsections (without ##) -> Explanation
    5. Other markdown -> Other
    """
    if cell_type == CellType.CODE:
        return CellContent.CODE_BLOCK

    # Check for explanation subsection markers
    explanation_keywords = [
        '### 이론', '### 코드 설명', '### 설명',
        '### theory', '### explanation', '### code explanation'
    ]
    has_explanation = any(keyword.lower() in text.lower() for keyword in explanation_keywords)
    starts_with_header = text.startswith('##')

    # Case 2: ## + explanation -> SectionWithExplanation
    if starts_with_header and has_explanation:
        return CellContent.SECTION_WITH_EXPLANATION

    # Case 3: ## without explanation -> Header
    if starts_with_header:
        return CellContent.HEADER

    # Case 4: Explanation without ## -> Explanation
    if has_explanation:
        return CellContent.EXPLANATION

    return CellContent.OTHER


def parse_cell(raw_cell: Dict[str, Any]) -> Cell:
    """Parse raw notebook cell into typed Cell"""
    cell_type_str = raw_cell.get('cell_type', 'code')
    cell_type = CellType.MARKDOWN if cell_type_str == 'markdown' else CellType.CODE

    text = get_source_text(raw_cell)
    content_type = classify_content(text, cell_type)

    return Cell(cell_type=cell_type, content_type=content_type, raw_cell=raw_cell)


def group_into_sections(cells: List[Cell]) -> List[Section]:
    """
    Group cells into sections using sequential algorithm (from Idris spec).

    Algorithm:
    1. Track current section as we process cells sequentially
    2. Code cells belong to the current (preceding) section
    3. New section header completes previous section
    """
    sections = []
    current_section = {
        'header': None,
        'explanations': [],
        'code_cells': [],
        'other_cells': []
    }

    for cell in cells:
        # Check if this cell starts a new section
        is_section_start = (
            cell.content_type == CellContent.HEADER or
            cell.content_type == CellContent.SECTION_WITH_EXPLANATION
        )

        if is_section_start:
            # Save previous section if it has content
            if (current_section['header'] or
                current_section['explanations'] or
                current_section['code_cells'] or
                current_section['other_cells']):
                sections.append(Section(
                    header=current_section['header'],
                    explanations=current_section['explanations'],
                    code_cells=current_section['code_cells'],
                    other_cells=current_section['other_cells']
                ))

            # Start new section
            current_section = {
                'header': None,
                'explanations': [],
                'code_cells': [],
                'other_cells': []
            }

            # Classify the section-starting cell
            if cell.content_type == CellContent.HEADER:
                current_section['header'] = cell
            else:  # SECTION_WITH_EXPLANATION
                current_section['explanations'].append(cell)

        elif cell.content_type == CellContent.CODE_BLOCK:
            current_section['code_cells'].append(cell)

        elif cell.content_type == CellContent.EXPLANATION:
            current_section['explanations'].append(cell)

        else:  # OTHER
            current_section['other_cells'].append(cell)

    # Save final section
    if (current_section['header'] or
        current_section['explanations'] or
        current_section['code_cells'] or
        current_section['other_cells']):
        sections.append(Section(
            header=current_section['header'],
            explanations=current_section['explanations'],
            code_cells=current_section['code_cells'],
            other_cells=current_section['other_cells']
        ))

    return sections


def reorder_notebook_from_spec(notebook_path: str) -> None:
    """
    Reorder notebook based on Idris NotebookStructure specification.

    Process:
    1. Parse notebook cells
    2. Group into sections
    3. Flatten sections (which automatically orders: explanation before code)
    4. Write back to file
    """
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb_data = json.load(f)

    # Parse all cells
    cells = [parse_cell(raw_cell) for raw_cell in nb_data['cells']]

    # Group into sections
    sections = group_into_sections(cells)

    # Create notebook structure
    notebook = Notebook(sections=sections)

    # Flatten to get reordered cells
    reordered_cells = notebook.flatten()

    # Extract raw cells in new order
    nb_data['cells'] = [cell.raw_cell for cell in reordered_cells]

    # Write back
    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb_data, f, ensure_ascii=False, indent=1)

    print(f"✅ Reordered {notebook_path}")
    print(f"   Sections: {len(sections)}")
    for i, section in enumerate(sections, 1):
        header_text = get_source_text(section.header.raw_cell)[:50] if section.header else "(no header)"
        print(f"   Section {i}: {len(section.explanations)} explanations, {len(section.code_cells)} code cells - {header_text}")


if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))

    notebooks = [
        os.path.join(project_root, 'notebooks/1_generate.ipynb'),
        os.path.join(project_root, 'notebooks/2_web_search.ipynb'),
        os.path.join(project_root, 'notebooks/3_tool_agent.ipynb')
    ]

    for nb_path in notebooks:
        if os.path.exists(nb_path):
            reorder_notebook_from_spec(nb_path)
        else:
            print(f"⚠️ File not found: {nb_path}")

    print("\n✅ All notebooks reordered per Idris specification!")
