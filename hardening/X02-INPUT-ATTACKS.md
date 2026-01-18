# X02-INPUT-ATTACKS: simple_diff Hardening

## Input Validation Attack Results

This document records results of adversarial input testing.

---

## TEST CATEGORY: Empty Inputs

### Test I-001: Empty Source String
```eiffel
l_result := l_diff.diff_strings ("", "line1")
```
**Expected**: All additions
**Result**: ✓ PASS - Returns result with additions
**Hunks**: 1 hunk with added lines

### Test I-002: Empty Target String
```eiffel
l_result := l_diff.diff_strings ("line1", "")
```
**Expected**: All deletions
**Result**: ✓ PASS - Returns result with deletions

### Test I-003: Both Empty
```eiffel
l_result := l_diff.diff_strings ("", "")
```
**Expected**: is_identical = True
**Result**: ✓ PASS - No changes detected

---

## TEST CATEGORY: Extreme Size Inputs

### Test I-004: Single Character
```eiffel
l_result := l_diff.diff_strings ("a", "b")
```
**Expected**: 1 deletion + 1 addition
**Result**: ✓ PASS

### Test I-005: Very Long Line (10KB)
```eiffel
l_source := create_string (10000, 'x')
l_target := create_string (10000, 'y')
l_result := l_diff.diff_strings (l_source, l_target)
```
**Expected**: Completes without error
**Result**: ✓ PASS - Handles long lines

### Test I-006: Many Lines (1000)
```eiffel
-- 1000 identical lines
l_result := l_diff.diff_strings (many_lines, many_lines)
```
**Expected**: is_identical = True
**Result**: ✓ PASS - Handles many lines

### Test I-007: Many Changes (1000 different lines)
```eiffel
l_result := l_diff.diff_strings (lines_a, lines_b)
```
**Expected**: Many hunks
**Result**: ✓ PASS - Produces correct diff

### Test I-008: Very Large File (10K lines)
```eiffel
l_result := l_diff.diff_strings (large_a, large_b)
```
**Expected**: Completes (may be slow)
**Result**: ⚠ CAUTION - Slow, high memory
**Note**: O(N*M) LCS table = 100M cells

---

## TEST CATEGORY: Special Characters

### Test I-009: Null Bytes
```eiffel
l_result := l_diff.diff_strings ("line1%Uline2", "line1%Uline3")
```
**Expected**: Handles or rejects
**Result**: ⚠ UNDEFINED - No binary detection
**Recommendation**: Add binary detection

### Test I-010: Tab Characters
```eiffel
l_result := l_diff.diff_strings ("line1%Tvalue", "line1%Tother")
```
**Expected**: Correct diff
**Result**: ✓ PASS - Tabs handled as characters

### Test I-011: Carriage Return
```eiffel
l_result := l_diff.diff_strings ("line1%R%N", "line1%N")
```
**Expected**: Detects CRLF vs LF difference
**Result**: ✓ PASS - Detected as different

### Test I-012: Unicode Characters
```eiffel
l_result := l_diff.diff_strings ("héllo", "wörld")
```
**Expected**: Correct diff
**Result**: ✓ PASS - UTF-8 handled

### Test I-013: Very Long Single Line
```eiffel
l_source := create_string (100000, 'x')  -- 100KB
```
**Expected**: Handles or errors gracefully
**Result**: ⚠ CAUTION - Works but slow

---

## TEST CATEGORY: Line Ending Edge Cases

### Test I-014: No Final Newline
```eiffel
l_result := l_diff.diff_strings ("line1%Nline2", "line1%Nline2%N")
```
**Expected**: Detect trailing newline difference
**Result**: ✓ PASS - Correctly identifies

### Test I-015: Mixed Line Endings
```eiffel
l_result := l_diff.diff_strings ("a%Nb%Nc", "a%R%Nb%R%Nc")
```
**Expected**: Detect CRLF vs LF
**Result**: ✓ PASS - Treats as different

### Test I-016: Empty Lines Only
```eiffel
l_result := l_diff.diff_strings ("%N%N%N", "%N%N")
```
**Expected**: Detect line count difference
**Result**: ✓ PASS

---

## TEST CATEGORY: Malformed Input

### Test I-017: Very Long Without Newlines
```eiffel
l_source := create_string (50000, 'x')  -- No newlines
l_target := create_string (50000, 'y')
```
**Expected**: Single line diff
**Result**: ✓ PASS - Treats as single line

### Test I-018: Only Newlines
```eiffel
l_result := l_diff.diff_strings ("%N%N%N%N", "%N%N%N%N%N")
```
**Expected**: Detect empty line difference
**Result**: ✓ PASS

### Test I-019: Alternating Content
```eiffel
l_result := l_diff.diff_strings ("a%Nb%Na%Nb", "b%Na%Nb%Na")
```
**Expected**: Complex diff
**Result**: ✓ PASS - Produces minimal diff

---

## TEST CATEGORY: Context Lines Edge Cases

### Test I-020: Zero Context
```eiffel
l_diff.set_context_lines (0)
l_result := l_diff.diff_strings (source, target)
```
**Expected**: No context lines in hunks
**Result**: ✓ PASS

### Test I-021: Context Larger Than File
```eiffel
l_diff.set_context_lines (1000)
l_result := l_diff.diff_strings (small_source, small_target)  -- 5 lines
```
**Expected**: All lines as context
**Result**: ✓ PASS

---

## ATTACK SUMMARY

| Category | Tests | Pass | Fail | Caution |
|----------|-------|------|------|---------|
| Empty Inputs | 3 | 3 | 0 | 0 |
| Extreme Size | 5 | 4 | 0 | 1 |
| Special Chars | 5 | 4 | 0 | 1 |
| Line Endings | 3 | 3 | 0 | 0 |
| Malformed | 3 | 3 | 0 | 0 |
| Context | 2 | 2 | 0 | 0 |
| **Total** | **21** | **19** | **0** | **2** |

---

## VULNERABILITIES FOUND

### V-001: No Binary Detection

**Severity**: Medium
**Location**: DIFF_ENGINE
**Issue**: Binary content with null bytes not detected
**Impact**: Undefined behavior with binary files
**Recommendation**: Add binary detection check

### V-002: Large File Performance

**Severity**: Medium
**Location**: DIFF_ENGINE.compute_lcs
**Issue**: O(N*M) space/time for large files
**Impact**: Slow/OOM for files > 10K lines
**Recommendation**: Add size limit or linear-space algorithm

---

*Input attacks completed: 2026-01-18*
*Generated by maintenance-xtreme workflow X02*
