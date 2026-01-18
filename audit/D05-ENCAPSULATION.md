# D05-ENCAPSULATION: simple_diff Design Audit

## Encapsulation Analysis

This document audits information hiding and encapsulation in simple_diff.

---

## EXPORT POLICY ANALYSIS

### SIMPLE_DIFF

| Feature | Export | Assessment |
|---------|--------|------------|
| make | ANY | ✓ Public creation |
| set_* methods | ANY | ✓ Public configuration |
| diff_* methods | ANY | ✓ Public API |
| apply_* methods | ANY | ✓ Public API |
| has_error, last_error | ANY | ✓ Public status |
| engine | NONE | ✓ Hidden implementation |
| renderer | NONE | ✓ Hidden implementation |
| applier | NONE | ✓ Hidden implementation |

**Assessment**: ✓ Excellent encapsulation

### DIFF_ENGINE

| Feature | Export | Assessment |
|---------|--------|------------|
| make | ANY | ✓ Public creation |
| set_* methods | ANY | ⚠ Could restrict to SIMPLE_DIFF |
| compute_diff | ANY | ⚠ Could restrict to SIMPLE_DIFF |
| source_lines | NONE | ✓ Hidden |
| target_lines | NONE | ✓ Hidden |
| compute_lcs | NONE | ✓ Hidden algorithm |
| compute_edit_script | NONE | ✓ Hidden algorithm |
| build_hunks | NONE | ✓ Hidden algorithm |

**Assessment**: ⚠ Consider restricting public features to facade only

### DIFF_RESULT

| Feature | Export | Assessment |
|---------|--------|------------|
| make, make_with_paths | ANY | ✓ Public creation |
| hunks | ANY | ⚠ Exposes internal collection |
| source_path, target_path | ANY | ✓ Public data |
| add_hunk | ANY | ⚠ Should be DIFF_ENGINE only |
| is_identical, has_changes | ANY | ✓ Public queries |
| to_* methods | ANY | ✓ Public output |

**Assessment**: ⚠ `add_hunk` and `hunks` expose too much

### DIFF_HUNK

| Feature | Export | Assessment |
|---------|--------|------------|
| make | ANY | ✓ Public creation |
| lines | ANY | ⚠ Exposes internal collection |
| add_* methods | ANY | ⚠ Should be DIFF_ENGINE only |
| source_start, target_start | ANY | ✓ Public data |
| header, to_string | ANY | ✓ Public output |

**Assessment**: ⚠ Mutation methods exposed too widely

### DIFF_LINE

| Feature | Export | Assessment |
|---------|--------|------------|
| make_* | ANY | ✓ Public creation |
| content, status | ANY | ✓ Public data |
| is_* queries | ANY | ✓ Public status |
| prefix_char, to_string | ANY | ✓ Public output |

**Assessment**: ✓ Good - immutable value object

### DIFF_RENDERER

| Feature | Export | Assessment |
|---------|--------|------------|
| make | ANY | ✓ Public creation |
| set_* methods | ANY | ✓ Public configuration |
| render_* methods | ANY | ✓ Public API |
| render_*_line helpers | NONE | ✓ Hidden implementation |
| html_escape | NONE | ✓ Hidden utility |

**Assessment**: ✓ Good encapsulation

### PATCH_APPLIER

| Feature | Export | Assessment |
|---------|--------|------------|
| make | ANY | ✓ Public creation |
| set_* methods | ANY | ✓ Public configuration |
| apply_* methods | ANY | ✓ Public API |
| write_reject_file | ANY | ✓ Public API |
| has_*, last_error | ANY | ✓ Public status |
| rejected_hunks | ANY | ⚠ Exposes internal collection |
| clear_state | NONE | ✓ Hidden |
| apply_hunks | NONE | ✓ Hidden |
| verify_hunk_context | NONE | ✓ Hidden |
| parse_* | NONE | ✓ Hidden |

**Assessment**: ⚠ `rejected_hunks` exposes collection

---

## ENCAPSULATION ISSUES

### Issue E-001: Mutable Collection Exposure

**Location**: DIFF_RESULT.hunks, DIFF_HUNK.lines
**Problem**: Returns direct reference to internal collection

```eiffel
hunks: ARRAYED_LIST [DIFF_HUNK]
        -- Lines in this hunk  -- EXPOSED REFERENCE
```

**Risk**: External code could modify internal state

**Mitigation Options**:
1. Return copy: `Result := hunks.twin`
2. Return read-only view: `READABLE_LIST`
3. Accept and document risk (current)

**Severity**: Medium

### Issue E-002: Wide Export of Mutation Methods

**Location**: DIFF_RESULT.add_hunk, DIFF_HUNK.add_*
**Problem**: Anyone can call mutation methods

```eiffel
add_hunk (h: DIFF_HUNK)
        -- Add hunk to result  -- ANY can call
```

**Ideal**: Only DIFF_ENGINE should add hunks

**Mitigation Options**:
1. Export to {DIFF_ENGINE}
2. Use factory pattern
3. Accept and document (current)

**Severity**: Low (internal use pattern clear)

### Issue E-003: DIFF_ENGINE Public API

**Location**: DIFF_ENGINE.set_*, compute_diff
**Problem**: Engine is internal but has public API

**Current Usage**: Only SIMPLE_DIFF uses it
**Risk**: External code could use engine directly

**Mitigation Options**:
1. Export to {SIMPLE_DIFF} only
2. Accept direct use as advanced API
3. Document intended usage

**Severity**: Low

---

## INFORMATION HIDING ASSESSMENT

### Well Hidden ✓

| Information | Location | Status |
|-------------|----------|--------|
| LCS algorithm | DIFF_ENGINE.compute_lcs | NONE export |
| Edit script generation | DIFF_ENGINE | NONE export |
| Hunk building | DIFF_ENGINE | NONE export |
| Line rendering helpers | DIFF_RENDERER | NONE export |
| HTML escaping | DIFF_RENDERER | NONE export |
| Patch application logic | PATCH_APPLIER | NONE export |
| Diff parsing | PATCH_APPLIER | NONE export |

### Could Be Better Hidden ⚠

| Information | Current | Ideal |
|-------------|---------|-------|
| Internal collections | ANY | Copy or read-only |
| Mutation methods | ANY | Creating class only |
| Engine direct access | ANY | Facade only |

---

## DATA INTEGRITY ANALYSIS

### DIFF_LINE ✓

**Integrity**: Strong
- No setters after creation
- Invariants enforce consistency
- Status validated

### DIFF_HUNK ⚠

**Integrity**: Medium
- `lines` exposed, could be modified externally
- Add methods validate but collection exposed

### DIFF_RESULT ⚠

**Integrity**: Medium
- `hunks` exposed, could be modified externally
- `add_hunk` open to any caller

### PATCH_APPLIER ⚠

**Integrity**: Medium
- `rejected_hunks` exposed
- State cleared properly on each operation

---

## DEFENSIVE COPYING

### Current Status

No defensive copying implemented. Collections returned directly.

### Risk Assessment

| Collection | Risk |
|------------|------|
| DIFF_RESULT.hunks | Medium - user could clear/modify |
| DIFF_HUNK.lines | Medium - user could clear/modify |
| PATCH_APPLIER.rejected_hunks | Low - informational |

### Recommendation

For Phase 2, consider:
```eiffel
hunks: LIST [DIFF_HUNK]
        -- Copy of hunks
    do
        create {ARRAYED_LIST [DIFF_HUNK]} Result.make_from_array (internal_hunks.to_array)
    end
```

---

## ENCAPSULATION SCORE: 80/100

**Strong Points**:
- Algorithm details well hidden
- Helper methods properly encapsulated
- Internal attributes protected
- Clear public API surface

**Improvement Areas**:
- Collection exposure (medium priority)
- Mutation method exports (low priority)
- Engine direct access (low priority)

---

*Encapsulation audit completed: 2026-01-18*
*Generated by design-audit workflow D05*
