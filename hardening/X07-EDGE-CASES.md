# X07-EDGE-CASES: simple_diff Hardening

## Edge Case Attack Results

This document records results of boundary condition testing.

---

## TEST CATEGORY: Boundary Values

### Test E-001: context_lines = 0
```eiffel
l_diff.set_context_lines (0)
l_result := l_diff.diff_strings ("a%Nb%Nc", "a%Nx%Nc")
```
**Expected**: No context lines in hunks
**Result**: ✓ PASS - Changes only

### Test E-002: context_lines = 1
```eiffel
l_diff.set_context_lines (1)
l_result := l_diff.diff_strings ("a%Nb%Nc%Nd%Ne", "a%Nb%Nx%Nd%Ne")
```
**Expected**: 1 line before and after change
**Result**: ✓ PASS

### Test E-003: context_lines = INTEGER.max_value
```eiffel
l_diff.set_context_lines ({INTEGER}.max_value)
```
**Expected**: Handles (all lines as context)
**Result**: ⚠ OVERFLOW RISK - May cause issues in arithmetic

### Test E-004: Line Numbers at Boundary
```eiffel
-- Hunk at line 1
l_result := l_diff.diff_strings ("changed", "modified")
```
**Expected**: source_start = 1, target_start = 1
**Result**: ✓ PASS

### Test E-005: Line Numbers Large
```eiffel
-- Diff at end of large file
l_source := generate_lines (9999, "line_")
l_source.append ("%Nchanged")
l_target := l_source.twin
l_target.replace_substring ("modified", l_target.count - 6, l_target.count)
```
**Expected**: Line numbers correct (10000)
**Result**: ✓ PASS

---

## TEST CATEGORY: Empty Element Cases

### Test E-006: Empty Hunk
```eiffel
-- Identical files = no hunks
l_result := l_diff.diff_strings ("same", "same")
assert ("no_hunks", l_result.hunks.is_empty)
```
**Expected**: hunks.is_empty
**Result**: ✓ PASS

### Test E-007: Empty Line Content
```eiffel
l_result := l_diff.diff_strings ("%N", "%N%N")
```
**Expected**: Diff includes empty lines
**Result**: ✓ PASS - Empty string lines handled

### Test E-008: Single Empty Line
```eiffel
l_result := l_diff.diff_strings ("", "")
```
**Expected**: Identical
**Result**: ✓ PASS

---

## TEST CATEGORY: Overlap Cases

### Test E-009: Adjacent Changes Merge
```eiffel
l_diff.set_context_lines (3)
-- Changes within context distance
l_result := l_diff.diff_strings ("1%N2%N3%N4%N5", "1%Na%Nb%N4%N5")
```
**Expected**: Single merged hunk
**Result**: ✓ PASS - Hunks merge when context overlaps

### Test E-010: Non-Adjacent Changes
```eiffel
l_diff.set_context_lines (1)
-- Changes far apart
l_result := l_diff.diff_strings ("1%N2%N3%N4%N5%N6%N7%N8%N9", "a%N2%N3%N4%N5%N6%N7%N8%Nb")
```
**Expected**: Two separate hunks
**Result**: ✓ PASS

### Test E-011: Overlapping Context
```eiffel
l_diff.set_context_lines (5)
l_result := l_diff.diff_strings ("1%N2%N3%N4%N5%N6", "1%Na%N3%Nb%N5%N6")
```
**Expected**: Context lines shared
**Result**: ✓ PASS

---

## TEST CATEGORY: Status Combinations

### Test E-012: All Additions
```eiffel
l_result := l_diff.diff_strings ("", "a%Nb%Nc")
```
**Expected**: All lines added, no context
**Result**: ✓ PASS

### Test E-013: All Deletions
```eiffel
l_result := l_diff.diff_strings ("a%Nb%Nc", "")
```
**Expected**: All lines removed
**Result**: ✓ PASS

### Test E-014: All Context
```eiffel
l_result := l_diff.diff_strings ("same%Nlines", "same%Nlines")
```
**Expected**: No hunks (identical)
**Result**: ✓ PASS

### Test E-015: Alternating Add/Remove
```eiffel
l_result := l_diff.diff_strings ("a%Nb%Na", "x%Nb%Ny")
```
**Expected**: Properly interleaved
**Result**: ✓ PASS

---

## TEST CATEGORY: Patch Edge Cases

### Test E-016: Patch Empty Diff
```eiffel
l_result := l_diff.diff_strings ("same", "same")
l_applier.apply_to_string (l_result, "same")
```
**Expected**: No changes, returns original
**Result**: ✓ PASS

### Test E-017: Patch First Line
```eiffel
l_result := l_diff.diff_strings ("old%Nrest", "new%Nrest")
l_patched := l_applier.apply_to_string (l_result, "old%Nrest")
```
**Expected**: First line changed
**Result**: ✓ PASS

### Test E-018: Patch Last Line
```eiffel
l_result := l_diff.diff_strings ("start%Nold", "start%Nnew")
l_patched := l_applier.apply_to_string (l_result, "start%Nold")
```
**Expected**: Last line changed
**Result**: ✓ PASS

### Test E-019: Patch All Lines
```eiffel
l_result := l_diff.diff_strings ("a%Nb%Nc", "x%Ny%Nz")
l_patched := l_applier.apply_to_string (l_result, "a%Nb%Nc")
```
**Expected**: Complete replacement
**Result**: ✓ PASS

### Test E-020: Patch Context Mismatch
```eiffel
l_result := l_diff.diff_strings ("ctx%Nold%Nctx", "ctx%Nnew%Nctx")
l_patched := l_applier.apply_to_string (l_result, "different%Nold%Nother")
```
**Expected**: Hunk rejected
**Result**: ✓ PASS - has_rejects = True

---

## TEST CATEGORY: Output Edge Cases

### Test E-021: Unified Empty
```eiffel
l_result := l_diff.diff_strings ("same", "same")
l_unified := l_result.to_unified
```
**Expected**: Headers only, no hunks
**Result**: ✓ PASS

### Test E-022: HTML Empty
```eiffel
l_result := l_diff.diff_strings ("same", "same")
l_html := l_result.to_html
```
**Expected**: Valid HTML, no diff content
**Result**: ✓ PASS

### Test E-023: JSON Empty
```eiffel
l_result := l_diff.diff_strings ("same", "same")
l_json := l_result.to_json
```
**Expected**: Valid JSON with is_identical: true
**Result**: ✓ PASS

---

## ATTACK SUMMARY

| Category | Tests | Pass | Fail | Risk |
|----------|-------|------|------|------|
| Boundary Values | 5 | 4 | 0 | 1 |
| Empty Elements | 3 | 3 | 0 | 0 |
| Overlap Cases | 3 | 3 | 0 | 0 |
| Status Combinations | 4 | 4 | 0 | 0 |
| Patch Edge Cases | 5 | 5 | 0 | 0 |
| Output Edge Cases | 3 | 3 | 0 | 0 |
| **Total** | **23** | **22** | **0** | **1** |

---

## VULNERABILITIES FOUND

### V-013: Integer Overflow Risk

**Severity**: Low
**Location**: context_lines handling
**Issue**: Very large context_lines could overflow
**Impact**: Undefined behavior in edge cases

**Recommendation**:
```eiffel
set_context_lines (n: INTEGER): like Current
    require
        non_negative: n >= 0
        reasonable: n < 10000  -- Add upper bound
```

---

*Edge case attacks completed: 2026-01-18*
*Generated by maintenance-xtreme workflow X07*
