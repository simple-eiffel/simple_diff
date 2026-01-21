# MML Integration - simple_diff

## Overview
Applied X03 Contract Assault with simple_mml on 2025-01-21.

## MML Classes Used
- `MML_SEQUENCE [SIMPLE_DIFF_HUNK]` - Models diff hunks in order
- `MML_SEQUENCE [STRING]` - Models lines within hunks

## Model Queries Added
- `model_hunks: MML_SEQUENCE [SIMPLE_DIFF_HUNK]` - Hunks in diff order
- `model_old_lines: MML_SEQUENCE [STRING]` - Original file lines
- `model_new_lines: MML_SEQUENCE [STRING]` - Modified file lines

## Model-Based Postconditions
| Feature | Postcondition | Purpose |
|---------|---------------|---------|
| `compute_diff` | `hunks_generated: not model_hunks.is_empty or files_identical` | Diff produces hunks |
| `hunk_count` | `consistent_with_model: Result = model_hunks.count` | Count matches model |
| `apply_patch` | `result_matches_new: Result.is_equal (model_new_lines)` | Patch produces new |
| `reverse_patch` | `result_matches_old: Result.is_equal (model_old_lines)` | Reverse produces old |
| `is_empty` | `definition: Result = model_hunks.is_empty` | Empty via model |

## Invariants Added
- `hunks_ordered: across model_hunks as h all h.old_start >= 0 end` - Valid hunk positions

## Bugs Found
None (note: pre-existing simple_reflection errors in test target - core library compiles)

## Test Results
- Compilation: SUCCESS (core library)
- Tests: Test target has pre-existing simple_reflection dependency issues
