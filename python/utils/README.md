# Python Utilities

Utility scripts for notebook validation and visualization per Idris specifications.

## Active Scripts

### 1. `verify_all_notebooks.py` ⭐

**Purpose**: Comprehensive validation of all 3 notebooks against Idris specifications.

**Usage**:
```bash
python3 python/utils/verify_all_notebooks.py
```

**Validates**:
- **Notebook 1**: 10 sections + 3 practice problems (ascending order 1→2→3)
- **Notebook 2**: 10 sections + 10 practice problems (ascending order 1→10)
- **Notebook 3**: 8 sections + 10 practice problems (ascending order 1→10)

**Checks**:
- Markdown → Code pairing for each section
- Practice problems in ascending order
- Code cells have matching section title comments
- No duplicate cell indices

**Idris Specs**:
- [Notebook1Structure.idr](../../idris/Domain/Notebook1Structure.idr)
- [NotebookStructure2.idr](../../idris/Domain/NotebookStructure2.idr) (notebook 2)
- [Notebook3Structure.idr](../../idris/Domain/Notebook3Structure.idr)

### 2. `reorder_with_associations.py`

**Purpose**: Reorder notebooks 1 & 2 using explicit cell associations.

**Usage**:
```bash
python3 python/utils/reorder_with_associations.py
```

**Algorithm** (from [CellAssociation.idr](../../idris/Domain/CellAssociation.idr)):
1. Validate: no duplicate cell indices
2. For each association (sorted order):
   - Output explanation cell
   - Output associated code cells
3. Output unassociated cells at end

**Note**: This script was used during initial setup. Notebooks are now properly ordered.

### 3. `visualize_associations.py`

**Purpose**: Debug tool to visualize explanation → code mappings.

**Usage**:
```bash
python3 python/utils/visualize_associations.py
```

**Output Example**:
```
📝 Cell 2: ## 1. 환경 변수 로드
   └─> 코드 셀: Cell 13: from dotenv import load_dotenv

📊 Summary: 12 associations, 15 code cells
```

## Idris-First Workflow

**Development Process**:
1. Write Idris specification → `idris/Domain/`
2. Compile: `idris2 --check <spec>.idr`
3. Implement Python per spec → `python/utils/`
4. Verify: Run utility and check output

**Key Principle**:
> All utilities implement formal Idris specifications.
> Any changes to notebook structure must update Idris specs first.

## Current Status

All notebooks are **verified and properly ordered** ✅

To verify anytime:
```bash
python3 python/utils/verify_all_notebooks.py
```
