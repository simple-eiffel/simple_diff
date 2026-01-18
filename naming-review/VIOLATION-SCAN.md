# NAMING VIOLATION SCAN: simple_diff

**Date**: 2026-01-18
**Scanned Files**: 11 (7 src + 4 testing)
**Pre-scan Status**: Compiles, 50 tests passing

## Summary

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Class names | 0 | 0 | 0 | 0 | 0 |
| Feature names | 0 | 0 | 0 | 0 | 0 |
| Constant names | 0 | 0 | 1 | 0 | 1 |
| Argument names | 0 | 0 | 0 | 0 | 0 |
| Local names | 0 | 0 | 0 | 0 | 0 |
| Cursor names | 0 | 0 | 1 | 0 | 1 |
| Generic params | 0 | 0 | 0 | 0 | 0 |
| Contract tags | 0 | 0 | 0 | 0 | 0 |
| Tuple labels | 0 | 0 | 0 | 0 | 0 |
| Clause labels | 0 | 0 | 0 | 0 | 0 |
| **TOTAL** | 0 | 0 | 2 | 0 | **2** |

## Assessment

**simple_diff is exceptionally clean.** Only 2 minor violations found.

## Violations

### MEDIUM: Constant Naming

**CONSTANT NAME VIOLATION: SIMPLE_DIFF.version**
- File: src/simple_diff.e:39
- Problem: lowercase constant
- Current: `version: STRING = "1.0.0"`
- Should be: `Version: STRING = "1.0.0"`
- Severity: MEDIUM

### MEDIUM: Loop Cursor Naming

**CURSOR NAME VIOLATION: DIFF_ENGINE.compute_diff cursor i**
- File: src/diff_engine.e:111
- Problem: no ic prefix
- Current: `across 1 |..| source_lines.count as i all`
- Should be: `across 1 |..| source_lines.count as ic all`
- Shadows: No (but convention violation)
- Severity: MEDIUM

## Clean Categories (No Violations)

### Class Names ✓
All 9 classes follow ALL_CAPS convention:
- SIMPLE_DIFF
- DIFF_ENGINE
- DIFF_RESULT
- DIFF_LINE
- DIFF_HUNK
- DIFF_RENDERER
- PATCH_APPLIER
- LIB_TESTS
- ADVERSARIAL_TESTS

### Feature Names ✓
All features use snake_case:
- Commands use verbs: `make`, `set_context_lines`, `apply_patch`, etc.
- Queries use nouns: `context_lines`, `source_path`, `hunk_count`, etc.
- Boolean queries use is_/has_: `is_identical`, `has_changes`, `has_error`, etc.

### Argument Names ✓
All arguments have `a_` prefix:
- `a_source`, `a_target`, `a_count`, `a_value`, etc.

### Local Variable Names ✓
All locals properly named:
- Using `l_` prefix: `l_result`, `l_source`, `l_lines`, etc.
- Simple counters: `i`, `j` (appropriate for loop indices)

### Contract Tags ✓
All contracts have descriptive tags:
- Preconditions: `source_not_void`, `path_not_void`, `non_negative`, etc.
- Postconditions: `result_not_void`, `context_set`, `returns_self`, etc.
- Invariants: `engine_not_void`, `hunks_not_void`, etc.

### TUPLE Labels ✓
No reserved word conflicts:
- `[source_idx: INTEGER; target_idx: INTEGER]`
- `[op: INTEGER; source_idx: INTEGER; target_idx: INTEGER]`
- `[lines: ARRAYED_LIST [STRING]; offset_delta: INTEGER; success: BOOLEAN]`

## Fix Plan

1. Fix `version` → `Version` in SIMPLE_DIFF
2. Fix cursor `i` → `ic` in DIFF_ENGINE postcondition
3. Compile and verify
