# Python Utilities

Utility scripts for notebook management and visualization.

## Available Tools

### 1. `reorder_with_associations.py`

**Purpose**: Reorder notebook cells based on Idris CellAssociation specification.

**Usage**:
```bash
python3 python/utils/reorder_with_associations.py
```

**Features**:
- Implements association-based reordering per [CellAssociation.idr](../../idris/Domain/CellAssociation.idr)
- Validates associations (duplicate detection)
- Groups explanation cells with their corresponding code cells
- Outputs: `notebooks/1_generate.ipynb` and `notebooks/2_web_search.ipynb` properly ordered

**Association Maps**:
- Notebook 1: 12 associations (intro + 10 sections + practice)
- Notebook 2: 11 associations (10 sections + practice)

**Algorithm** (from Idris spec):
1. Validate: no duplicate cell indices
2. For each association (in sorted order):
   - Output explanation cell
   - Output associated code cells
3. Output any unassociated cells at end

### 2. `visualize_associations.py`

**Purpose**: Visualize cell associations for notebooks 1 and 2.

**Usage**:
```bash
python3 python/utils/visualize_associations.py
```

**Output**:
- Shows explanation → code mappings
- Displays cell indices and content previews
- Summary statistics

**Example Output**:
```
📝 Cell 2: ## 1. 환경 변수 로드
   └─> 코드 셀: Cell 13: from dotenv import load_dotenv

📝 Cell 3: ## 2. LLM 기본 사용법
   └─> 코드 셀: Cell 14: # 간단한 질문 테스트
...
```

## Idris-First Workflow

All utilities are implementations of formal Idris specifications:

1. **Specification**: [idris/Domain/CellAssociation.idr](../../idris/Domain/CellAssociation.idr)
2. **Validation**: `idris2 --check CellAssociation.idr`
3. **Implementation**: Python scripts in this directory
4. **Verification**: Run scripts and verify output

## Notes

- All utilities use **1-based indexing** in Idris specs (convert to 0-based for Python)
- Association maps are defined in both Idris (specification) and Python (implementation)
- Any changes to associations should be made in Idris first, then reflected in Python
