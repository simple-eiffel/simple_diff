# D02-CONTRACTS: simple_diff Design Audit

## Contract Quality Analysis

This document audits the Design by Contract implementation in simple_diff.

---

## CONTRACT COVERAGE SUMMARY

| Class | Preconditions | Postconditions | Invariants | Score |
|-------|---------------|----------------|------------|-------|
| SIMPLE_DIFF | 8 | 12 | 2 | 95% |
| DIFF_ENGINE | 4 | 8 | 0 | 75% |
| DIFF_RESULT | 4 | 10 | 2 | 90% |
| DIFF_HUNK | 12 | 18 | 4 | 100% |
| DIFF_LINE | 9 | 15 | 5 | 100% |
| DIFF_RENDERER | 4 | 8 | 2 | 85% |
| PATCH_APPLIER | 8 | 12 | 1 | 80% |

**Overall Contract Coverage**: 89%

---

## PRECONDITION ANALYSIS

### Strong Preconditions ✓

```eiffel
-- DIFF_HUNK.make
require
    source_positive: a_source_start >= 1
    target_positive: a_target_start >= 1
```
**Assessment**: Clear, defensive, documents API contract.

```eiffel
-- DIFF_LINE.make_context
require
    content_not_void: a_content /= Void
    source_positive: a_source_line >= 1
    target_positive: a_target_line >= 1
```
**Assessment**: Complete input validation.

### Weak Preconditions ⚠

```eiffel
-- DIFF_ENGINE.compute_diff
require
    source_set: source_lines /= Void
    target_set: target_lines /= Void
```
**Assessment**: Could also check `source_set: not source_lines.is_empty` or document empty behavior.

### Missing Preconditions ⚠

| Method | Missing Check | Impact |
|--------|---------------|--------|
| DIFF_ENGINE.set_source_from_file | file_exists check | Error deferred |
| PATCH_APPLIER.parse_unified_diff | valid_format check | Silent failure |

---

## POSTCONDITION ANALYSIS

### Strong Postconditions ✓

```eiffel
-- DIFF_LINE.prefix_char
ensure
    context_space: is_context implies Result = ' '
    added_plus: is_added implies Result = '+'
    removed_minus: is_removed implies Result = '-'
```
**Assessment**: Complete specification of behavior.

```eiffel
-- DIFF_HUNK.add_context_line
ensure
    line_added: lines.count = old lines.count + 1
    source_count_incremented: source_count = old source_count + 1
    target_count_incremented: target_count = old target_count + 1
```
**Assessment**: Full state change documentation.

### Weak Postconditions ⚠

```eiffel
-- DIFF_ENGINE.compute_diff
ensure
    result_not_void: Result /= Void
    identical_if_same: source_equals_target implies Result.is_identical
```
**Missing**: Could add `changes_detected: not identical_if_same implies Result.has_changes`

### Missing Postconditions ⚠

| Method | Missing Guarantee | Impact |
|--------|-------------------|--------|
| DIFF_ENGINE.compute_lcs | dimensions correct | Internal, low impact |
| PATCH_APPLIER.apply | file_modified or error | User must check has_error |

---

## INVARIANT ANALYSIS

### Strong Invariants ✓

```eiffel
-- DIFF_LINE
invariant
    content_not_void: content /= Void
    valid_status: status >= 0 and status <= 2
    added_has_no_source: is_added implies source_line_number = 0
    removed_has_no_target: is_removed implies target_line_number = 0
    context_has_both: is_context implies (source_line_number >= 1 and target_line_number >= 1)
```
**Assessment**: Excellent! Complete state invariants.

```eiffel
-- DIFF_RESULT
invariant
    hunks_not_void: hunks /= Void
    identical_means_no_hunks: is_identical implies hunks.is_empty
```
**Assessment**: Good semantic invariant.

### Missing Invariants ⚠

| Class | Missing Invariant | Impact |
|-------|-------------------|--------|
| DIFF_ENGINE | source_target_consistency | Low (internal) |
| PATCH_APPLIER | rejected_hunks_valid | Medium |
| DIFF_RENDERER | valid_settings | Low |

**Suggested Addition for DIFF_ENGINE**:
```eiffel
invariant
    context_non_negative: context_lines >= 0
```

**Suggested Addition for PATCH_APPLIER**:
```eiffel
invariant
    rejected_hunks_not_void: rejected_hunks /= Void
    error_implies_message: has_error implies last_error /= Void
```

---

## CONTRACT QUALITY PATTERNS

### Pattern: Definition Postconditions ✓

```eiffel
is_context: BOOLEAN
    ensure
        definition: Result = (status = Status_context)
```
**Assessment**: Excellent practice - postconditions define query semantics.

### Pattern: Result Guarantees ✓

```eiffel
to_unified: STRING
    ensure
        result_not_void: Result /= Void
```
**Assessment**: Consistent across all functions.

### Pattern: State Change Tracking ✓

```eiffel
add_hunk (h: DIFF_HUNK)
    ensure
        hunk_added: hunks.count = old hunks.count + 1
        hunk_is_last: hunks.last = h
```
**Assessment**: Good use of `old` expression.

---

## CONTRACT ISSUES FOUND

### Issue C-001: DIFF_ENGINE Missing Invariant

**Location**: DIFF_ENGINE class
**Problem**: No class invariant despite having state
**Impact**: State consistency not formally verified
**Severity**: Low

**Recommendation**:
```eiffel
invariant
    context_non_negative: context_lines >= 0
```

### Issue C-002: Weak compute_diff Postcondition

**Location**: DIFF_ENGINE.compute_diff
**Problem**: Doesn't guarantee changes are detected
**Impact**: Caller must verify manually
**Severity**: Low

**Recommendation**: Add semantic postcondition about result properties.

### Issue C-003: PATCH_APPLIER Error Invariant

**Location**: PATCH_APPLIER class
**Problem**: No invariant linking has_error to last_error
**Impact**: Inconsistent state possible
**Severity**: Medium

**Recommendation**:
```eiffel
invariant
    error_consistency: has_error = (last_error /= Void)
```

### Issue C-004: Missing File Preconditions

**Location**: SIMPLE_DIFF.diff_files, PATCH_APPLIER.apply
**Problem**: No file existence preconditions
**Impact**: Error handling instead of prevention
**Severity**: Low (by design - error handling pattern)

---

## CONTRACT STRENGTH ASSESSMENT

### By Class

| Class | Preconditions | Postconditions | Invariants | Overall |
|-------|---------------|----------------|------------|---------|
| DIFF_LINE | Strong | Strong | Excellent | A |
| DIFF_HUNK | Strong | Strong | Strong | A |
| DIFF_RESULT | Good | Strong | Good | A- |
| SIMPLE_DIFF | Good | Strong | Good | B+ |
| DIFF_ENGINE | Adequate | Good | Missing | B |
| DIFF_RENDERER | Adequate | Good | Good | B |
| PATCH_APPLIER | Good | Good | Weak | B |

### Overall Grade: B+ (Good)

---

## CONTRACT RECOMMENDATIONS

### High Priority

1. **Add DIFF_ENGINE invariant** for context_lines
2. **Add PATCH_APPLIER error invariant** for consistency
3. **Strengthen compute_diff postcondition** with semantic guarantee

### Medium Priority

4. **Add dimension postcondition** to compute_lcs
5. **Consider file existence strategy** (precondition vs error handling)

### Low Priority

6. **Add settings invariants** to DIFF_RENDERER
7. **Document empty input behavior** in contracts

---

## CONTRACT SCORE: 89/100

**Strengths**:
- Excellent invariants on data classes (DIFF_LINE, DIFF_HUNK)
- Consistent result guarantees across all functions
- Good use of definition postconditions
- State change tracking with `old` expressions

**Weaknesses**:
- DIFF_ENGINE missing invariant
- PATCH_APPLIER error state not formalized
- Some postconditions could be stronger

---

*Contract audit completed: 2026-01-18*
*Generated by design-audit workflow D02*
