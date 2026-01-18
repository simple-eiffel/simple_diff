# D06-RECOMMENDATIONS: simple_diff Design Audit

## Improvement Recommendations

This document provides prioritized recommendations based on the design audit.

---

## PRIORITY 1: HIGH (Should Fix)

### R-001: Add DIFF_ENGINE Invariant

**Source**: D02-CONTRACTS
**Issue**: DIFF_ENGINE has no class invariant despite having state
**Impact**: State consistency not formally verified

**Current**:
```eiffel
class DIFF_ENGINE
    -- No invariant
end
```

**Recommended**:
```eiffel
class DIFF_ENGINE
invariant
    context_non_negative: context_lines >= 0
end
```

**Effort**: Low (5 minutes)
**Risk**: None

---

### R-002: Add PATCH_APPLIER Error Invariant

**Source**: D02-CONTRACTS
**Issue**: No invariant linking has_error to last_error
**Impact**: Inconsistent error state possible

**Current**:
```eiffel
invariant
    rejected_hunks_not_void: rejected_hunks /= Void
```

**Recommended**:
```eiffel
invariant
    rejected_hunks_not_void: rejected_hunks /= Void
    error_consistency: has_error = (last_error /= Void)
```

**Effort**: Low (5 minutes)
**Risk**: None

---

### R-003: Strengthen compute_diff Postcondition

**Source**: D02-CONTRACTS
**Issue**: Postcondition doesn't guarantee change detection

**Current**:
```eiffel
ensure
    result_not_void: Result /= Void
    identical_if_same: source_equals_target implies Result.is_identical
```

**Recommended**:
```eiffel
ensure
    result_not_void: Result /= Void
    identical_if_same: source_equals_target implies Result.is_identical
    different_if_different: not source_equals_target implies Result.has_changes
```

**Effort**: Low (10 minutes)
**Risk**: Low - may need helper query

---

## PRIORITY 2: MEDIUM (Consider for Phase 2)

### R-004: Defensive Copying for Collections

**Source**: D05-ENCAPSULATION
**Issue**: Internal collections exposed directly
**Impact**: External code could modify internal state

**Current**:
```eiffel
hunks: ARRAYED_LIST [DIFF_HUNK]
```

**Option A: Copy on access**:
```eiffel
hunks: LIST [DIFF_HUNK]
    do
        create {ARRAYED_LIST [DIFF_HUNK]} Result.make_from_array (internal_hunks.to_array)
    ensure
        result_not_void: Result /= Void
        same_count: Result.count = internal_hunks.count
    end
```

**Option B: Accept and document**:
```eiffel
hunks: ARRAYED_LIST [DIFF_HUNK]
        -- Internal hunk list. Do not modify.
```

**Effort**: Medium (1 hour)
**Risk**: Low - performance impact if many accesses

---

### R-005: Restrict Engine Export

**Source**: D05-ENCAPSULATION
**Issue**: DIFF_ENGINE public but internal

**Current**:
```eiffel
class DIFF_ENGINE
feature -- Access
    compute_diff: DIFF_RESULT
```

**Recommended**:
```eiffel
class DIFF_ENGINE
feature {SIMPLE_DIFF} -- Restricted
    compute_diff: DIFF_RESULT
```

**Effort**: Low (15 minutes)
**Risk**: May break advanced users

---

### R-006: Strategy Pattern for Renderers

**Source**: D03-PATTERNS
**Issue**: Four rendering algorithms in one class
**Impact**: Hard to add new formats

**Current**:
```eiffel
class DIFF_RENDERER
    render_unified (r: DIFF_RESULT): STRING
    render_html (r: DIFF_RESULT): STRING
    render_side_by_side (r: DIFF_RESULT): STRING
    render_colored (r: DIFF_RESULT): STRING
```

**Recommended**:
```eiffel
deferred class DIFF_FORMAT
feature
    render (r: DIFF_RESULT): STRING deferred end
end

class UNIFIED_FORMAT inherit DIFF_FORMAT ... end
class HTML_FORMAT inherit DIFF_FORMAT ... end
```

**Effort**: High (2-3 hours)
**Risk**: Significant refactoring
**Note**: Only if more formats needed

---

## PRIORITY 3: LOW (Future Consideration)

### R-007: Rename Boolean Attributes

**Source**: D04-NAMING
**Issue**: Some boolean attributes lack is_/has_ prefix

**Current**:
```eiffel
dry_run: BOOLEAN
reverse: BOOLEAN
```

**Recommended**:
```eiffel
is_dry_run: BOOLEAN
is_reversed: BOOLEAN
```

**Effort**: Medium (breaking change)
**Risk**: API change, affects users

---

### R-008: Extract DIFF_PARSER

**Source**: D01-STRUCTURE
**Issue**: Parsing mixed with patch application

**Current**: `PATCH_APPLIER.parse_unified_diff` is private

**Recommended**:
```eiffel
class DIFF_PARSER
feature
    parse_unified (text: STRING): DIFF_RESULT
end
```

**Effort**: Medium (1-2 hours)
**Risk**: Low - isolated change
**Note**: Only if external parsing needed

---

### R-009: Move Output to DIFF_RENDERER

**Source**: D01-STRUCTURE
**Issue**: DIFF_RESULT has `to_*` methods

**Current**:
```eiffel
class DIFF_RESULT
    to_unified: STRING
    to_html: STRING
```

**Recommended**: Keep as convenience, delegate internally
```eiffel
to_unified: STRING
    do
        create {DIFF_RENDERER} l_renderer.make
        Result := l_renderer.render_unified (Current)
    end
```

**Effort**: Low (30 minutes)
**Risk**: None - maintains API

---

### R-010: Add Value Object Semantics to DIFF_LINE

**Source**: D03-PATTERNS
**Issue**: Value object but no equality override

**Recommended**:
```eiffel
class DIFF_LINE
inherit ANY
    redefine
        is_equal
    end
feature
    is_equal (other: like Current): BOOLEAN
        do
            Result := content.same_string (other.content) and
                     status = other.status and
                     source_line_number = other.source_line_number and
                     target_line_number = other.target_line_number
        end
```

**Effort**: Low (20 minutes)
**Risk**: None

---

## RECOMMENDATION SUMMARY

| ID | Priority | Effort | Description |
|----|----------|--------|-------------|
| R-001 | HIGH | Low | Add DIFF_ENGINE invariant |
| R-002 | HIGH | Low | Add PATCH_APPLIER error invariant |
| R-003 | HIGH | Low | Strengthen compute_diff postcondition |
| R-004 | MEDIUM | Medium | Defensive copying for collections |
| R-005 | MEDIUM | Low | Restrict engine export |
| R-006 | MEDIUM | High | Strategy pattern for renderers |
| R-007 | LOW | Medium | Rename boolean attributes |
| R-008 | LOW | Medium | Extract DIFF_PARSER |
| R-009 | LOW | Low | Move output to DIFF_RENDERER |
| R-010 | LOW | Low | Add DIFF_LINE equality |

---

## IMPLEMENTATION PLAN

### Phase 1 Hotfix (Now)
- R-001: Add DIFF_ENGINE invariant
- R-002: Add PATCH_APPLIER error invariant
- R-003: Strengthen compute_diff postcondition

### Phase 2 (Next Release)
- R-004: Defensive copying (evaluate tradeoffs)
- R-005: Restrict engine export
- R-009: Delegate output to renderer

### Future (If Needed)
- R-006: Strategy pattern (only if more formats)
- R-007: Rename booleans (breaking change)
- R-008: Extract parser (if external parsing needed)
- R-010: DIFF_LINE equality

---

*Recommendations compiled: 2026-01-18*
*Generated by design-audit workflow D06*
