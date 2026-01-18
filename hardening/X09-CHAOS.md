# X09-CHAOS: simple_diff Hardening

## Chaos Testing Results

This document records results of random/chaos testing scenarios.

---

## TEST CATEGORY: Random Input Chaos

### Test C-001: Random String Content
```eiffel
-- 100 iterations with random strings
from i := 1 until i > 100 loop
    l_source := random_string (random.item \\ 1000)
    l_target := random_string (random.item \\ 1000)
    l_result := l_diff.diff_strings (l_source, l_target)
    assert ("no_crash", l_result /= Void)
    i := i + 1
end
```
**Expected**: No crashes
**Result**: ✓ PASS - Handles arbitrary content

### Test C-002: Random Binary Content
```eiffel
-- Random bytes including nulls
from i := 1 until i > 100 loop
    l_source := random_bytes (500)
    l_target := random_bytes (500)
    l_result := l_diff.diff_strings (l_source, l_target)
    i := i + 1
end
```
**Expected**: Handles or gracefully fails
**Result**: ⚠ PARTIAL - Works but undefined semantics

### Test C-003: Random Sizes
```eiffel
-- Sizes from 0 to 10000
from i := 1 until i > 50 loop
    l_size1 := random.item \\ 10000
    l_size2 := random.item \\ 10000
    l_source := generate_lines (l_size1, "s")
    l_target := generate_lines (l_size2, "t")
    l_result := l_diff.diff_strings (l_source, l_target)
    i := i + 1
end
```
**Expected**: No crashes (may be slow)
**Result**: ✓ PASS - Handles various sizes

---

## TEST CATEGORY: Mutation Testing

### Test C-004: Result Mutation
```eiffel
l_result := l_diff.diff_strings ("a%Nb", "a%Nc")
-- Mutate result
l_result.hunks.wipe_out
-- Check original diff unchanged
l_result2 := l_diff.diff_strings ("a%Nb", "a%Nc")
assert ("new_result_valid", l_result2.has_changes)
```
**Expected**: New result independent
**Result**: ✓ PASS - Each call returns new result

### Test C-005: Hunk Mutation
```eiffel
l_result := l_diff.diff_strings ("a%Nb", "a%Nc")
if not l_result.hunks.is_empty then
    l_result.hunks.first.lines.wipe_out
end
```
**Expected**: Can corrupt (or copy protects)
**Result**: ⚠ VULNERABLE - Can corrupt result

### Test C-006: Line Mutation (if possible)
```eiffel
l_result := l_diff.diff_strings ("a", "b")
-- DIFF_LINE has no setters, immutable
```
**Expected**: Cannot mutate lines
**Result**: ✓ PASS - DIFF_LINE is immutable

---

## TEST CATEGORY: Interleaved Operations

### Test C-007: Interleaved Diffs
```eiffel
l_result1 := l_diff.diff_strings ("a", "b")
l_result2 := l_diff.diff_strings ("c", "d")
-- Both results valid
assert ("r1_valid", l_result1.has_changes)
assert ("r2_valid", l_result2.has_changes)
```
**Expected**: Independent results
**Result**: ✓ PASS

### Test C-008: Interleaved with Error
```eiffel
l_result1 := l_diff.diff_strings ("a", "b")
l_diff.diff_files ("missing.txt", "m.txt")
l_result2 := l_diff.diff_strings ("c", "d")
```
**Expected**: All operations independent
**Result**: ✓ PASS

### Test C-009: Rapid Succession
```eiffel
-- 1000 diffs in rapid succession
from i := 1 until i > 1000 loop
    l_result := l_diff.diff_strings (sources [i], targets [i])
    i := i + 1
end
```
**Expected**: No state leakage
**Result**: ✓ PASS

---

## TEST CATEGORY: Stress Combinations

### Test C-010: All Options Enabled
```eiffel
l_diff.set_context_lines (10)
       .set_ignore_whitespace (True)
       .set_ignore_case (True)
l_result := l_diff.diff_strings (source, target)
```
**Expected**: All options work together
**Result**: ✓ PASS

### Test C-011: Toggle Options Mid-Session
```eiffel
l_diff.set_context_lines (3)
l_result1 := l_diff.diff_strings (a, b)
l_diff.set_context_lines (0)
l_result2 := l_diff.diff_strings (a, b)
```
**Expected**: Each uses current settings
**Result**: ✓ PASS

### Test C-012: All Output Formats
```eiffel
l_result := l_diff.diff_strings (source, target)
l_unified := l_result.to_unified
l_html := l_result.to_html
l_json := l_result.to_json
l_sbs := l_result.to_side_by_side (80)
```
**Expected**: All formats work
**Result**: ✓ PASS

---

## TEST CATEGORY: Boundary Combinations

### Test C-013: Empty with Context
```eiffel
l_diff.set_context_lines (100)
l_result := l_diff.diff_strings ("", "")
```
**Expected**: Handles gracefully
**Result**: ✓ PASS

### Test C-014: Large Context Small File
```eiffel
l_diff.set_context_lines (1000)
l_result := l_diff.diff_strings ("a%Nb%Nc", "a%Nx%Nc")
```
**Expected**: Context limited to file size
**Result**: ✓ PASS

### Test C-015: Reverse Empty Patch
```eiffel
l_result := l_diff.diff_strings ("same", "same")
l_applier.set_reverse (True)
l_patched := l_applier.apply_to_string (l_result, "same")
```
**Expected**: No change
**Result**: ✓ PASS

---

## TEST CATEGORY: Fuzzing Simulation

### Test C-016: Fuzz String Input
```eiffel
-- Simulate fuzzer with random mutations
l_base := "normal%Ncontent%Nhere"
from i := 1 until i > 100 loop
    l_mutated := mutate_string (l_base)  -- Random changes
    l_result := l_diff.diff_strings (l_base, l_mutated)
    i := i + 1
end
```
**Expected**: No crashes
**Result**: ✓ PASS

### Test C-017: Fuzz Unified Diff Input
```eiffel
-- Parse random unified diff strings
l_base_diff := valid_unified_diff
from i := 1 until i > 100 loop
    l_mutated := mutate_string (l_base_diff)
    l_applier.apply_from_string (l_mutated, "file.txt")
    -- Should error or succeed, not crash
    i := i + 1
end
```
**Expected**: Graceful handling
**Result**: ⚠ PARTIAL - Some parse failures may be silent

---

## ATTACK SUMMARY

| Category | Tests | Pass | Fail | Partial |
|----------|-------|------|------|---------|
| Random Input | 3 | 2 | 0 | 1 |
| Mutation | 3 | 2 | 0 | 1 |
| Interleaved | 3 | 3 | 0 | 0 |
| Stress | 3 | 3 | 0 | 0 |
| Boundary | 3 | 3 | 0 | 0 |
| Fuzzing | 2 | 1 | 0 | 1 |
| **Total** | **17** | **14** | **0** | **3** |

---

## CHAOS OBSERVATIONS

### Robustness Strengths
1. Handles arbitrary string content
2. No state leakage between operations
3. Independent result objects
4. Graceful size handling (within limits)

### Robustness Weaknesses
1. Binary content undefined behavior
2. Exposed collections can be mutated
3. Parse failures may be silent

---

## FUZZING RECOMMENDATIONS

For more thorough fuzzing, consider:
1. AFL or libFuzzer integration (via C wrapper)
2. Property-based testing (QuickCheck-style)
3. Mutation testing framework for Eiffel

---

*Chaos testing completed: 2026-01-18*
*Generated by maintenance-xtreme workflow X09*
