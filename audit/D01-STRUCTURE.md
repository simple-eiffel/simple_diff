# D01-STRUCTURE: simple_diff Design Audit

## Structural Analysis

This document analyzes the structural design of simple_diff against OOSC2 principles.

---

## CLASS STRUCTURE OVERVIEW

### Class Count: 7 production + 1 test

| Class | Lines | Responsibilities | SRP Compliance |
|-------|-------|------------------|----------------|
| SIMPLE_DIFF | 387 | Facade, configuration, delegation | ✓ Good |
| DIFF_ENGINE | 382 | Algorithm, computation | ✓ Good |
| DIFF_RESULT | 229 | Data, statistics, output | ⚠ Mixed |
| DIFF_HUNK | 215 | Data, formatting | ✓ Good |
| DIFF_LINE | 155 | Data, formatting | ✓ Good |
| DIFF_RENDERER | 364 | Formatting all outputs | ⚠ Large |
| PATCH_APPLIER | 451 | Patch operations | ⚠ Large |

### Responsibility Assessment

**Well-Separated**:
- SIMPLE_DIFF: Pure facade, delegates everything
- DIFF_ENGINE: Pure algorithm
- DIFF_LINE: Pure data with formatting

**Potentially Overloaded**:
- DIFF_RESULT: Both data holder AND output generator
- DIFF_RENDERER: Four rendering algorithms in one class
- PATCH_APPLIER: Apply, parse, verify all in one

---

## FEATURE CLASSIFICATION

### SIMPLE_DIFF

| Category | Count | Features |
|----------|-------|----------|
| Creation | 1 | make |
| Configuration | 5 | set_context_lines, set_ignore_*, etc |
| Operations | 4 | diff_strings, diff_files, apply_patch, reverse_patch |
| Status | 3 | has_error, last_error, clear_error |
| **Total** | **13** | Appropriate size |

**Assessment**: ✓ Well-structured facade

### DIFF_ENGINE

| Category | Count | Features |
|----------|-------|----------|
| Creation | 1 | make |
| Input | 4 | set_source_*, set_target_* |
| Computation | 1 | compute_diff |
| Internal | 5 | compute_lcs, build_hunks, etc |
| **Total** | **11** | Appropriate size |

**Assessment**: ✓ Focused on single responsibility

### DIFF_RESULT

| Category | Count | Features |
|----------|-------|----------|
| Creation | 2 | make, make_with_paths |
| Data Access | 5 | hunks, source_path, target_path, etc |
| Statistics | 4 | hunk_count, additions_total, etc |
| Output | 4 | to_unified, to_side_by_side, to_html, to_json |
| **Total** | **15** | Slightly overloaded |

**Assessment**: ⚠ Output methods could be in renderer

### DIFF_RENDERER

| Category | Count | Features |
|----------|-------|----------|
| Creation | 1 | make |
| Configuration | 3 | set_tab_width, set_line_width, set_use_color |
| Rendering | 4 | render_unified, render_side_by_side, render_html, render_colored |
| Internal | 5 | render_*_line helpers, html_escape, pad_or_truncate |
| **Total** | **13** | Could split by format |

**Assessment**: ⚠ Consider Strategy pattern for formats

### PATCH_APPLIER

| Category | Count | Features |
|----------|-------|----------|
| Creation | 1 | make |
| Configuration | 2 | set_dry_run, set_reverse |
| Operations | 4 | apply, apply_to_string, apply_from_string, write_reject_file |
| Status | 4 | has_error, last_error, has_rejects, rejected_hunks |
| Internal | 8 | apply_hunks, verify_context, parse_*, etc |
| **Total** | **19** | Largest class |

**Assessment**: ⚠ Parsing could be separate class

---

## INHERITANCE ANALYSIS

### Current Inheritance

```
ANY
├── SIMPLE_DIFF
├── DIFF_ENGINE
├── DIFF_RESULT
├── DIFF_HUNK
├── DIFF_LINE
├── DIFF_RENDERER
└── PATCH_APPLIER

TEST_SET_BASE
└── LIB_TESTS
```

**Assessment**: ✓ Flat hierarchy appropriate for this domain

### Missing Abstractions

| Potential Abstraction | Purpose | Value |
|-----------------------|---------|-------|
| DIFF_FORMAT | Renderer interface | Medium |
| DIFF_LINE_STATUS | Enum class | Low |
| PARSER | Diff parsing | Medium |

---

## COUPLING ANALYSIS

### Afferent Coupling (Who depends on this class)

| Class | Ca | Dependents |
|-------|----|-----------|
| DIFF_LINE | 4 | DIFF_HUNK, DIFF_RENDERER, PATCH_APPLIER, DIFF_ENGINE |
| DIFF_HUNK | 4 | DIFF_RESULT, DIFF_RENDERER, PATCH_APPLIER, DIFF_ENGINE |
| DIFF_RESULT | 4 | SIMPLE_DIFF, DIFF_RENDERER, PATCH_APPLIER, DIFF_ENGINE |
| DIFF_ENGINE | 1 | SIMPLE_DIFF |
| DIFF_RENDERER | 1 | SIMPLE_DIFF |
| PATCH_APPLIER | 1 | SIMPLE_DIFF |

### Efferent Coupling (What this class depends on)

| Class | Ce | Dependencies |
|-------|----|--------------|
| SIMPLE_DIFF | 4 | DIFF_ENGINE, DIFF_RESULT, DIFF_RENDERER, PATCH_APPLIER |
| DIFF_ENGINE | 3 | DIFF_RESULT, DIFF_HUNK, DIFF_LINE |
| DIFF_RESULT | 1 | DIFF_HUNK |
| DIFF_HUNK | 1 | DIFF_LINE |
| DIFF_LINE | 0 | (leaf) |
| DIFF_RENDERER | 3 | DIFF_RESULT, DIFF_HUNK, DIFF_LINE |
| PATCH_APPLIER | 3 | DIFF_RESULT, DIFF_HUNK, DIFF_LINE |

### Coupling Assessment

**Stable Classes** (high Ca, low Ce):
- DIFF_LINE: ✓ Excellent stability
- DIFF_HUNK: ✓ Good stability

**Unstable Classes** (low Ca, high Ce):
- SIMPLE_DIFF: ✓ Expected for facade

**Well-Balanced**:
- DIFF_RESULT, DIFF_RENDERER, PATCH_APPLIER: ✓ Moderate coupling

---

## COHESION ANALYSIS

### LCOM (Lack of Cohesion of Methods)

| Class | Cohesion | Assessment |
|-------|----------|------------|
| SIMPLE_DIFF | High | All methods use engine/renderer/applier |
| DIFF_ENGINE | High | All methods work on source/target |
| DIFF_RESULT | Medium | Output methods could be separate |
| DIFF_HUNK | High | All methods work on lines |
| DIFF_LINE | High | All methods work on content/status |
| DIFF_RENDERER | Medium | Four independent rendering algorithms |
| PATCH_APPLIER | Medium | Mix of apply, parse, write |

---

## SMELL DETECTION

### God Class ⚠
None detected. Largest class (PATCH_APPLIER) is 451 lines.

### Feature Envy ⚠
| Location | Description | Severity |
|----------|-------------|----------|
| DIFF_RESULT.to_unified | Accesses DIFF_HUNK repeatedly | Low |
| DIFF_RESULT.to_html | Could use DIFF_RENDERER | Medium |

### Data Class ⚠
| Class | Status | Reason |
|-------|--------|--------|
| DIFF_LINE | Clean | Has behavior (prefix_char, to_string) |
| DIFF_HUNK | Clean | Has behavior (add_line, header) |

### Long Method ⚠
| Method | Lines | Assessment |
|--------|-------|------------|
| DIFF_ENGINE.compute_diff | ~80 | Could extract LCS generation |
| PATCH_APPLIER.apply_single_hunk | ~70 | Complex but cohesive |
| DIFF_RENDERER.render_html | ~50 | Template-like, acceptable |

---

## STRUCTURAL ISSUES FOUND

### Issue S-001: DIFF_RESULT Has Output Methods

**Location**: DIFF_RESULT.to_unified, to_html, etc.
**Problem**: Data class also does presentation
**Impact**: Violates Single Responsibility
**Severity**: Low (works fine, convenience methods)

**Recommendation**: Keep for convenience, delegate to DIFF_RENDERER internally

### Issue S-002: DIFF_RENDERER Monolithic

**Location**: DIFF_RENDERER class
**Problem**: Four rendering algorithms in one class
**Impact**: Hard to extend with new formats
**Severity**: Low (limited formats expected)

**Recommendation**: Consider Strategy pattern if more formats needed

### Issue S-003: PATCH_APPLIER Parsing

**Location**: PATCH_APPLIER.parse_unified_diff
**Problem**: Parsing mixed with application
**Impact**: Hard to reuse parsing separately
**Severity**: Low (parsing is private, internal use)

**Recommendation**: Extract DIFF_PARSER if external parsing needed

---

## STRUCTURAL METRICS

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total classes | 7 | - | ✓ |
| Avg features/class | 13 | < 20 | ✓ |
| Max class size | 451 | < 500 | ✓ |
| Inheritance depth | 1 | < 4 | ✓ |
| Coupling (max) | 4 | < 6 | ✓ |

---

## STRUCTURAL SCORE: 85/100

**Strong Points**:
- Clean facade pattern
- Appropriate class sizes
- Low coupling between modules
- Flat inheritance (appropriate)

**Improvement Areas**:
- DIFF_RESULT output methods
- DIFF_RENDERER could use Strategy
- PATCH_APPLIER parsing could be separate

---

*Structural analysis completed: 2026-01-18*
*Generated by design-audit workflow D01*
