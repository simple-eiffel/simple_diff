# S01-INVENTORY: simple_diff

## Project Overview

| Attribute | Value |
|-----------|-------|
| Project Name | simple_diff |
| Location | D:\prod\simple_diff |
| ECF | simple_diff.ecf |
| UUID | 2fc42889-b253-44f5-87cf-62873305e79e |
| Version | Phase 1 |
| Status | Core functionality complete (29 tests passing) |

## Purpose Statement

Text differencing library implementing Myers diff algorithm. Compares strings, files, and directories with support for unified diff, side-by-side, HTML output, and patch application.

## Ecosystem Context

Part of the Simple Eiffel ecosystem (simple-eiffel GitHub organization).

## File Inventory

### Source Files (7 classes)

| File | Class | Lines | Purpose |
|------|-------|-------|---------|
| src/simple_diff.e | SIMPLE_DIFF | 387 | Facade - main entry point with builder pattern |
| src/diff_engine.e | DIFF_ENGINE | 382 | Core Myers diff algorithm (LCS-based) |
| src/diff_result.e | DIFF_RESULT | 229 | Contains diff hunks and metadata |
| src/diff_hunk.e | DIFF_HUNK | 215 | Single contiguous change block |
| src/diff_line.e | DIFF_LINE | 155 | Single line with status (context/added/removed) |
| src/diff_renderer.e | DIFF_RENDERER | 364 | Output formatting (unified/side-by-side/HTML/colored) |
| src/patch_applier.e | PATCH_APPLIER | 451 | Patch application with dry-run and reverse support |

### Test Files (2 files)

| File | Class | Tests | Coverage |
|------|-------|-------|----------|
| testing/lib_tests.e | LIB_TESTS | 29 | Full API coverage |
| testing/test_app.e | TEST_APP | - | Test runner |

### Configuration Files

| File | Purpose |
|------|---------|
| simple_diff.ecf | Library and test target configuration |
| README.md | Documentation and API reference |

## Dependencies

### External Libraries

| Library | Source | Purpose |
|---------|--------|---------|
| base | $ISE_LIBRARY | Core Eiffel (STRING, ARRAYED_LIST, etc.) |
| time | $ISE_LIBRARY | Time-related features |

### Test-Only Dependencies

| Library | Source | Purpose |
|---------|--------|---------|
| simple_testing | $SIMPLE_EIFFEL | TEST_SET_BASE for tests |

### No Other Dependencies

The library intentionally has minimal dependencies (EiffelBase only for production code).

## Configuration Settings

| Setting | Value |
|---------|-------|
| void_safety | all |
| concurrency | scoop |
| ECMA compatibility | enabled |

## Class Hierarchy

```
SIMPLE_DIFF (Facade)
├── DIFF_ENGINE (Algorithm)
├── DIFF_RESULT (Data)
│   └── DIFF_HUNK (Data)
│       └── DIFF_LINE (Data)
├── DIFF_RENDERER (Output)
└── PATCH_APPLIER (Operations)
```

## Class Summary

### SIMPLE_DIFF (Facade)
- **Role**: Main entry point, builder pattern API
- **Creation**: `make`
- **Configuration**: `set_context_lines`, `set_ignore_whitespace`, `set_ignore_case`
- **Operations**: `diff_strings`, `diff_files`, `diff_directories`
- **Patch**: `apply_patch`, `apply_patch_dry_run`, `reverse_patch`
- **Error Handling**: `has_error`, `last_error`, `clear_error`
- **Invariants**: `context_lines_non_negative`, `engine_not_void`

### DIFF_ENGINE (Core Algorithm)
- **Role**: Myers diff algorithm implementation
- **Creation**: `make`
- **Input**: `set_source_from_string`, `set_source_from_file`, `set_target_from_string`, `set_target_from_file`
- **Computation**: `compute_diff` → DIFF_RESULT
- **Internal**: `compute_lcs` (longest common subsequence), `compute_edit_script`, `build_hunks`
- **Constants**: `Op_match=0`, `Op_insert=1`, `Op_delete=2`

### DIFF_RESULT (Result Container)
- **Role**: Contains diff operation results
- **Creation**: `make`, `make_with_paths`
- **Status**: `is_identical`, `has_changes`
- **Metrics**: `hunk_count`, `line_count`, `additions_total`, `deletions_total`
- **Output**: `to_unified`, `to_side_by_side`, `to_html`, `to_json`
- **Invariants**: `hunks_not_void`, `identical_means_no_hunks`

### DIFF_HUNK (Change Block)
- **Role**: Contiguous block of changes with context
- **Creation**: `make (source_start, target_start)`
- **Content**: `lines: ARRAYED_LIST [DIFF_LINE]`
- **Metrics**: `additions_count`, `deletions_count`, `context_count`
- **Output**: `header` (@@ format), `to_string`
- **Mutation**: `add_line`, `add_context_line`, `add_added_line`, `add_removed_line`

### DIFF_LINE (Line Entry)
- **Role**: Single line with status
- **Creation**: `make_context`, `make_added`, `make_removed`
- **Status**: `is_context`, `is_added`, `is_removed`
- **Data**: `content`, `source_line_number`, `target_line_number`
- **Output**: `prefix_char` (space/+/-), `to_string`
- **Constants**: `Status_context=0`, `Status_added=1`, `Status_removed=2`
- **Invariants**: Line number validity based on status

### DIFF_RENDERER (Output Formatter)
- **Role**: Format diffs for various outputs
- **Creation**: `make`
- **Configuration**: `set_tab_width`, `set_line_width`, `set_use_color`
- **Rendering**: `render_unified`, `render_side_by_side`, `render_html`, `render_colored`
- **ANSI Colors**: `Ansi_reset`, `Ansi_red`, `Ansi_green`, `Ansi_cyan`, `Ansi_magenta`

### PATCH_APPLIER (Patch Operations)
- **Role**: Apply/reverse patches with dry-run support
- **Creation**: `make`
- **Configuration**: `set_dry_run`, `set_reverse`
- **Operations**: `apply`, `apply_to_string`, `apply_from_string`
- **Reject Handling**: `has_rejects`, `rejected_hunks`, `write_reject_file`
- **Error Handling**: `has_error`, `last_error`

## Design Patterns Identified

| Pattern | Location | Implementation |
|---------|----------|----------------|
| Facade | SIMPLE_DIFF | Single entry point hiding complexity |
| Builder | SIMPLE_DIFF | `set_*: like Current` for fluent configuration |
| Value Object | DIFF_LINE | Immutable line representation |
| Composite | DIFF_RESULT → DIFF_HUNK → DIFF_LINE | Hierarchical result structure |

## Contract Coverage

| Class | Preconditions | Postconditions | Invariants |
|-------|---------------|----------------|------------|
| SIMPLE_DIFF | ✓ | ✓ | ✓ (2) |
| DIFF_ENGINE | ✓ | ✓ | ✓ |
| DIFF_RESULT | ✓ | ✓ | ✓ (2) |
| DIFF_HUNK | ✓ | ✓ | ✓ (4) |
| DIFF_LINE | ✓ | ✓ | ✓ (5) |
| DIFF_RENDERER | ✓ | ✓ | ✓ (2) |
| PATCH_APPLIER | ✓ | ✓ | ✓ (1) |

## Test Coverage

| Category | Test Count | Classes Covered |
|----------|------------|-----------------|
| Creation | 4 | SIMPLE_DIFF, DIFF_LINE, DIFF_HUNK, DIFF_RESULT |
| Hunk Operations | 3 | DIFF_HUNK |
| Engine Operations | 4 | DIFF_ENGINE |
| Facade Operations | 3 | SIMPLE_DIFF |
| Rendering | 4 | DIFF_RENDERER, DIFF_RESULT |
| Patch Application | 4 | PATCH_APPLIER |
| Edge Cases | 5 | Various |
| **Total** | **29** | All 7 classes |

## Public API Surface

### Entry Points
- `SIMPLE_DIFF.make` - Primary creation
- `SIMPLE_DIFF.diff_strings (source, target)` - Compare strings
- `SIMPLE_DIFF.diff_files (path1, path2)` - Compare files
- `SIMPLE_DIFF.diff_directories (dir1, dir2)` - Compare directories

### Output Methods
- `DIFF_RESULT.to_unified` - Standard diff format
- `DIFF_RESULT.to_side_by_side (width)` - Column format
- `DIFF_RESULT.to_html` - HTML with CSS
- `DIFF_RESULT.to_json` - JSON format

### Patch Operations
- `SIMPLE_DIFF.apply_patch (diff, file)` - Apply patch
- `SIMPLE_DIFF.apply_patch_dry_run (diff, file)` - Preview
- `SIMPLE_DIFF.reverse_patch (diff, file)` - Unapply

## Known Limitations

1. No binary file detection (assumes text)
2. No encoding handling (assumes compatible strings)
3. Directory diff may be slow on large trees
4. No fuzzy matching for patch context

## Next Steps

→ S02-EXTRACT-DOMAIN-MODEL.md

---

*Inventory completed: 2026-01-18*
*Generated by spec-extraction workflow S01*
