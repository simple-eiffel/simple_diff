# 7S-03-REQUIREMENTS: simple_diff (Retrospective)


**Date**: 2026-01-18

## Requirements Analysis

This documents what requirements gathering would have produced before building simple_diff.

---

## FUNCTIONAL REQUIREMENTS

### Core (MUST Have)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | Compare two strings | Given source/target strings, return structured diff |
| FR-002 | Compare two files | Given file paths, return structured diff with paths |
| FR-003 | Detect identical inputs | Return `is_identical=True` when no differences |
| FR-004 | Generate unified diff | Output matches standard unified diff format |
| FR-005 | Track additions | Count and identify added lines |
| FR-006 | Track deletions | Count and identify removed lines |
| FR-007 | Include context lines | Configurable context around changes |

### Important (SHOULD Have)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-008 | Multiple output formats | Unified, side-by-side, HTML, colored |
| FR-009 | Apply patches | Transform file using diff result |
| FR-010 | Reverse patches | Unapply a patch |
| FR-011 | Dry-run patches | Preview without modification |
| FR-012 | Builder configuration | Fluent API for settings |

### Nice to Have (COULD Have)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-013 | Directory comparison | Recursive file comparison |
| FR-014 | JSON output | Machine-readable format |
| FR-015 | Reject file support | Write failed hunks to .rej |
| FR-016 | Ignore whitespace option | Configurable whitespace handling |
| FR-017 | Ignore case option | Case-insensitive comparison |

### Excluded (WON'T Have)

| ID | Requirement | Reason for Exclusion |
|----|-------------|---------------------|
| FR-X01 | Binary file diff | Different algorithm needed |
| FR-X02 | Three-way merge | Separate library scope |
| FR-X03 | Syntax-aware diff | Language-specific |
| FR-X04 | Word-level diff | Complexity for Phase 1 |

---

## NON-FUNCTIONAL REQUIREMENTS

### Performance

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-P01 | Diff computation time | < 5s for 10K lines | Benchmark test |
| NFR-P02 | Memory usage | < 500MB for 10K lines | Profile |
| NFR-P03 | Output generation | < 1s for any diff | Benchmark test |

### Reliability

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-R01 | No crashes on valid input | 100% |
| NFR-R02 | Graceful error handling | All file errors caught |
| NFR-R03 | Consistent results | Same input → same output |

### Usability

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-U01 | Simple creation | Single `make` call |
| NFR-U02 | Fluent configuration | Builder pattern |
| NFR-U03 | Clear error messages | Descriptive `last_error` |

### Security

| ID | Requirement | Control |
|----|-------------|---------|
| NFR-S01 | No arbitrary code execution | No eval, no shell |
| NFR-S02 | Safe file operations | Path validation |
| NFR-S03 | Memory safety | Void-safe, bounds-checked |

### Compatibility

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-C01 | EiffelStudio 25.x | Compile and run |
| NFR-C02 | Windows/Linux | Cross-platform |
| NFR-C03 | SCOOP | Concurrency-safe |

### Maintainability

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-M01 | Code documentation | All public features |
| NFR-M02 | Contract coverage | 100% public features |
| NFR-M03 | Test coverage | All classes tested |

---

## CONSTRAINTS

### Technical Constraints

| ID | Constraint | Impact |
|----|------------|--------|
| C-T01 | Pure Eiffel only | No C externals |
| C-T02 | EiffelBase dependencies only | No third-party libs |
| C-T03 | Void-safety all | All code void-safe |
| C-T04 | SCOOP concurrency | No shared mutable state |

### Business Constraints

| ID | Constraint | Impact |
|----|------------|--------|
| C-B01 | MIT license | Open source distribution |
| C-B02 | simple_* ecosystem patterns | Naming, structure consistency |
| C-B03 | Phase-based delivery | Incremental releases |

---

## USE CASES

### UC-001: Compare Two Strings

**Actor**: Developer
**Goal**: Get structured diff between two text strings

**Main Flow**:
1. Developer creates SIMPLE_DIFF instance
2. Developer calls `diff_strings(source, target)`
3. System computes LCS and edit operations
4. System returns DIFF_RESULT with hunks

**Postconditions**:
- Result contains all differences
- `is_identical` accurate

### UC-002: Compare Two Files

**Actor**: Developer
**Goal**: Get diff between two files

**Main Flow**:
1. Developer creates SIMPLE_DIFF instance
2. Developer calls `diff_files(path1, path2)`
3. System reads both files
4. System computes diff
5. System returns DIFF_RESULT with paths

**Extensions**:
- 3a. File not found → Set `has_error`, return empty result

### UC-003: Apply Patch

**Actor**: Developer
**Goal**: Transform file using diff

**Main Flow**:
1. Developer has DIFF_RESULT from previous diff
2. Developer calls `apply_patch(diff, target_path)`
3. System verifies context matches
4. System applies changes
5. System writes modified file

**Extensions**:
- 3a. Context mismatch → Add hunk to rejects, continue
- 4a. Dry run mode → Don't write file

### UC-004: Generate HTML Report

**Actor**: Developer
**Goal**: Create visual diff report

**Main Flow**:
1. Developer has DIFF_RESULT
2. Developer creates DIFF_RENDERER
3. Developer calls `render_html(result)`
4. System generates HTML with CSS styling

**Postconditions**:
- Output is valid HTML
- CSS classes enable styling

---

## DATA REQUIREMENTS

### Input Data

| Data | Type | Constraints |
|------|------|-------------|
| Source text | STRING | Not void |
| Target text | STRING | Not void |
| File path | STRING | Valid path |
| Context lines | INTEGER | >= 0 |

### Output Data

| Data | Type | Description |
|------|------|-------------|
| DIFF_RESULT | Object | Contains hunks |
| DIFF_HUNK | Object | Contiguous changes |
| DIFF_LINE | Object | Single line with status |

### Derived Data

| Data | Derivation |
|------|------------|
| is_identical | hunks.is_empty |
| additions_total | Sum of hunk additions |
| deletions_total | Sum of hunk deletions |

---

## INTERFACE REQUIREMENTS

### API Interface

```eiffel
-- Primary entry point
class SIMPLE_DIFF
    make                            -- Create with defaults
    set_context_lines (n): Current  -- Configure context
    diff_strings (s, t): DIFF_RESULT
    diff_files (p1, p2): DIFF_RESULT
    apply_patch (d, p)
```

### Output Formats

| Format | Method | Use Case |
|--------|--------|----------|
| Unified | to_unified | Standard diff, version control |
| Side-by-side | to_side_by_side | Visual comparison |
| HTML | to_html | Web reports, documentation |
| Colored | render_colored | Terminal display |
| JSON | to_json | API integration |

---

## REQUIREMENT TRACEABILITY

### Implementation Status

| Requirement | Implemented | Tested |
|-------------|-------------|--------|
| FR-001 | ✓ | ✓ |
| FR-002 | ✓ | ✓ |
| FR-003 | ✓ | ✓ |
| FR-004 | ✓ | ✓ |
| FR-005 | ✓ | ✓ |
| FR-006 | ✓ | ✓ |
| FR-007 | ✓ | ✓ |
| FR-008 | ✓ | ✓ |
| FR-009 | ✓ | ✓ |
| FR-010 | ✓ | ✓ |
| FR-011 | ✓ | ✓ |
| FR-012 | ✓ | ✓ |
| FR-013 | ✓ | Partial |
| FR-014 | ✓ | ✓ |
| FR-015 | ✓ | Partial |
| FR-016 | ✓ | Partial |
| FR-017 | ✓ | Partial |

---

*Retrospective requirements analysis: 2026-01-18*
*Generated by deep-research workflow 7S-03*
