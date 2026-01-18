# S07-COMPILED-SPEC: simple_diff

## Formal Specification

This document compiles all extracted specifications into a comprehensive formal specification.

---

## 1. OVERVIEW

### 1.1 Purpose
simple_diff is a text differencing library that computes and represents differences between text sources using the Myers diff algorithm.

### 1.2 Scope
- Compare strings, files, and directories
- Generate diffs in multiple formats (unified, side-by-side, HTML, colored)
- Apply and reverse patches with dry-run support

### 1.3 Target Users
Eiffel developers needing text comparison capabilities.

---

## 2. FUNCTIONAL REQUIREMENTS

### FR-001: String Comparison
**Priority**: MUST
**Description**: Compare two text strings and produce a diff result.
**Input**: Source string, target string
**Output**: DIFF_RESULT containing changes
**Acceptance**:
- Identical strings → `is_identical = True`
- Different strings → `has_changes = True` with hunks

### FR-002: File Comparison
**Priority**: MUST
**Description**: Compare two files by path.
**Input**: Two file paths
**Output**: DIFF_RESULT with paths stored
**Acceptance**:
- Files read and compared as strings
- Missing file → `has_error = True`

### FR-003: Configurable Context
**Priority**: MUST
**Description**: Specify number of context lines around changes.
**Input**: Integer >= 0
**Output**: Hunks include specified context
**Acceptance**:
- Default: 3 lines
- Zero: changes only

### FR-004: Unified Diff Output
**Priority**: MUST
**Description**: Render diff in standard unified format.
**Output**: String with `---`, `+++`, `@@` markers
**Acceptance**:
- Valid unified diff syntax
- Parseable by standard tools

### FR-005: HTML Output
**Priority**: SHOULD
**Description**: Render diff as HTML with styling.
**Output**: Complete HTML document
**Acceptance**:
- CSS classes for coloring
- Escaptes HTML entities

### FR-006: Side-by-Side Output
**Priority**: SHOULD
**Description**: Render diff in two-column format.
**Output**: Formatted string with columns
**Acceptance**:
- Configurable column width
- Visual alignment

### FR-007: Colored Console Output
**Priority**: COULD
**Description**: Render diff with ANSI colors.
**Output**: String with ANSI escape codes
**Acceptance**:
- Red for deletions
- Green for additions

### FR-008: Patch Application
**Priority**: MUST
**Description**: Apply a diff to transform a file.
**Input**: DIFF_RESULT, target file path
**Output**: Modified file
**Acceptance**:
- Context verified before apply
- Rejected hunks tracked

### FR-009: Reverse Patch
**Priority**: SHOULD
**Description**: Unapply a patch (reverse transformation).
**Input**: DIFF_RESULT, target file path
**Output**: File restored to original
**Acceptance**:
- Additions become deletions
- Deletions become additions

### FR-010: Dry Run Mode
**Priority**: SHOULD
**Description**: Preview patch without modification.
**Input**: DIFF_RESULT, content
**Output**: Transformed string (file unchanged)
**Acceptance**:
- No file system changes
- Result returned

### FR-011: Reject File Generation
**Priority**: COULD
**Description**: Write rejected hunks to .rej file.
**Input**: Base path
**Output**: `<path>.rej` file
**Acceptance**:
- Contains failed hunks
- Unified format

### FR-012: Directory Comparison
**Priority**: COULD
**Description**: Compare two directories recursively.
**Input**: Two directory paths
**Output**: Combined DIFF_RESULT
**Acceptance**:
- Recursive traversal
- Per-file results

---

## 3. NON-FUNCTIONAL REQUIREMENTS

### NFR-001: Performance
**Requirement**: Compute diff for files up to 10,000 lines
**Metric**: Complete within 5 seconds on standard hardware
**Constraint**: O(N*M) worst case for Myers algorithm

### NFR-002: Memory
**Requirement**: Handle files without exhausting memory
**Metric**: < 500MB for 10,000 line files
**Constraint**: LCS table is N*M cells

### NFR-003: Void Safety
**Requirement**: All code is void-safe
**Metric**: No void-target calls at runtime
**Validation**: Compiler void-safety checks pass

### NFR-004: SCOOP Compatibility
**Requirement**: Thread-safe for concurrent use
**Metric**: No shared mutable state issues
**Validation**: `concurrency=scoop` compiles

### NFR-005: Contract Coverage
**Requirement**: All public features have contracts
**Metric**: 100% of public features
**Validation**: Assertion monitoring enabled

### NFR-006: Test Coverage
**Requirement**: Comprehensive test suite
**Metric**: All classes tested
**Current**: 29 tests passing

---

## 4. DATA SPECIFICATIONS

### 4.1 DIFF_LINE

```
DIFF_LINE {
    content: STRING [not void]
    status: INTEGER [0..2]
        0 = context (unchanged)
        1 = added (new in target)
        2 = removed (was in source)
    source_line_number: INTEGER [0 for added, >= 1 otherwise]
    target_line_number: INTEGER [0 for removed, >= 1 otherwise]

    INVARIANT:
        status = 1 implies source_line_number = 0
        status = 2 implies target_line_number = 0
        status = 0 implies source_line_number >= 1 and target_line_number >= 1
}
```

### 4.2 DIFF_HUNK

```
DIFF_HUNK {
    source_start: INTEGER [>= 1]
    source_count: INTEGER [>= 0]
    target_start: INTEGER [>= 1]
    target_count: INTEGER [>= 0]
    lines: LIST<DIFF_LINE> [not void]

    INVARIANT:
        source_count = count of (context + removed) lines
        target_count = count of (context + added) lines
}
```

### 4.3 DIFF_RESULT

```
DIFF_RESULT {
    hunks: LIST<DIFF_HUNK> [not void]
    source_path: STRING? [optional]
    target_path: STRING? [optional]

    DERIVED:
        is_identical := hunks.is_empty
        has_changes := not hunks.is_empty
        hunk_count := hunks.count
        additions_total := sum(h.additions_count for h in hunks)
        deletions_total := sum(h.deletions_count for h in hunks)

    INVARIANT:
        is_identical implies hunks.is_empty
}
```

---

## 5. INTERFACE SPECIFICATIONS

### 5.1 SIMPLE_DIFF (Facade)

```
CLASS: SIMPLE_DIFF

CREATION:
    make
        -- Create with default settings
        POSTCONDITION:
            context_lines = 3
            ignore_whitespace = False
            ignore_case = False

CONFIGURATION (Builder Pattern):
    set_context_lines (n: INTEGER): like Current
        PRECONDITION: n >= 0
        POSTCONDITION: context_lines = n; Result = Current

    set_ignore_whitespace (b: BOOLEAN): like Current
        POSTCONDITION: ignore_whitespace = b; Result = Current

    set_ignore_case (b: BOOLEAN): like Current
        POSTCONDITION: ignore_case = b; Result = Current

OPERATIONS:
    diff_strings (source, target: STRING): DIFF_RESULT
        PRECONDITION: source /= Void; target /= Void
        POSTCONDITION: Result /= Void

    diff_files (path1, path2: STRING): DIFF_RESULT
        PRECONDITION: path1 /= Void; path2 /= Void
        POSTCONDITION: Result /= Void

    apply_patch (diff: DIFF_RESULT; path: STRING)
        PRECONDITION: diff /= Void; path /= Void

    reverse_patch (diff: DIFF_RESULT; path: STRING)
        PRECONDITION: diff /= Void; path /= Void

STATUS:
    has_error: BOOLEAN
    last_error: detachable STRING
    clear_error

INVARIANT:
    context_lines >= 0
```

### 5.2 DIFF_RENDERER

```
CLASS: DIFF_RENDERER

CREATION:
    make
        POSTCONDITION:
            tab_width = 4
            line_width = 80
            use_color = False

CONFIGURATION:
    set_tab_width (w: INTEGER)
        PRECONDITION: w >= 1

    set_line_width (w: INTEGER)
        PRECONDITION: w >= 20

    set_use_color (b: BOOLEAN)

RENDERING:
    render_unified (r: DIFF_RESULT): STRING
        PRECONDITION: r /= Void
        POSTCONDITION: Result /= Void

    render_side_by_side (r: DIFF_RESULT): STRING
        PRECONDITION: r /= Void
        POSTCONDITION: Result /= Void

    render_html (r: DIFF_RESULT): STRING
        PRECONDITION: r /= Void
        POSTCONDITION: Result /= Void; Result.has_substring("<html>")

    render_colored (r: DIFF_RESULT): STRING
        PRECONDITION: r /= Void
        POSTCONDITION: Result /= Void
```

### 5.3 PATCH_APPLIER

```
CLASS: PATCH_APPLIER

CREATION:
    make
        POSTCONDITION:
            dry_run = False
            reverse = False
            rejected_hunks.is_empty
            last_error = Void

CONFIGURATION:
    set_dry_run (b: BOOLEAN)
    set_reverse (b: BOOLEAN)

OPERATIONS:
    apply (diff: DIFF_RESULT; path: STRING)
        PRECONDITION: diff /= Void; path /= Void

    apply_to_string (diff: DIFF_RESULT; content: STRING): STRING
        PRECONDITION: diff /= Void; content /= Void
        POSTCONDITION: Result /= Void

    write_reject_file (path: STRING)
        PRECONDITION: path /= Void; has_rejects

STATUS:
    has_error: BOOLEAN
    last_error: detachable STRING
    has_rejects: BOOLEAN
    rejected_hunks: LIST<DIFF_HUNK>
```

---

## 6. BEHAVIORAL SPECIFICATIONS

### 6.1 Diff Computation

```
BEHAVIOR: compute_diff

INPUT:
    source: LIST<STRING>  -- source lines
    target: LIST<STRING>  -- target lines
    context_lines: INTEGER

ALGORITHM:
    1. Compute LCS table using dynamic programming
    2. Backtrack to generate edit operations (match/insert/delete)
    3. Group consecutive changes into hunks
    4. Add context lines around changes
    5. Merge adjacent hunks if context overlaps

OUTPUT:
    DIFF_RESULT with hunks

PROPERTIES:
    Identical inputs → empty hunks
    Minimal edit distance (Myers algorithm)
    Context lines respected
```

### 6.2 Patch Application

```
BEHAVIOR: apply_patch

INPUT:
    diff: DIFF_RESULT
    content: LIST<STRING>
    reverse: BOOLEAN

ALGORITHM:
    1. For each hunk:
       a. Verify context lines match content
       b. If match:
          - Remove deleted lines (or added if reverse)
          - Insert added lines (or deleted if reverse)
          - Track offset for subsequent hunks
       c. If no match:
          - Add to rejected_hunks
    2. Return modified content

OUTPUT:
    Modified content
    rejected_hunks (if any)

PROPERTIES:
    Context must match exactly
    Offset accumulated across hunks
    Reverse swaps add/delete semantics
```

---

## 7. CONSTRAINTS

### C-001: Eiffel Language
**Type**: Technical
**Constraint**: Must be written in Eiffel
**Impact**: All design patterns use Eiffel idioms

### C-002: SCOOP Compatibility
**Type**: Technical
**Constraint**: Must work with SCOOP concurrency
**Impact**: No global mutable state

### C-003: Void Safety
**Type**: Technical
**Constraint**: All code void-safe
**Impact**: Careful use of detachable types

### C-004: Design by Contract
**Type**: Technical
**Constraint**: All public features have contracts
**Impact**: Explicit preconditions, postconditions, invariants

### C-005: Minimal Dependencies
**Type**: Business
**Constraint**: Only depend on EiffelBase
**Impact**: No external C libraries or third-party code

---

## 8. OPEN QUESTIONS

### OQ-001: Large File Handling
**Question**: How to handle files > 10,000 lines efficiently?
**Options**:
- Linear-space Myers variant
- Streaming approach
- File size limit with error

### OQ-002: Binary Detection
**Question**: Should binary files be detected and rejected?
**Options**:
- Yes: Check for null bytes, reject with error
- No: User responsibility

### OQ-003: Encoding Support
**Question**: How to handle different text encodings?
**Options**:
- Assume UTF-8/ASCII
- Accept encoding parameter
- Auto-detect

---

## 9. GLOSSARY

| Term | Definition |
|------|------------|
| Diff | The difference between two text sources |
| Hunk | A contiguous block of changes with context |
| Context line | An unchanged line providing position reference |
| LCS | Longest Common Subsequence |
| Myers algorithm | Efficient diff algorithm by Eugene Myers |
| Unified format | Standard diff output format |
| Patch | A diff applied to transform files |

---

## 10. REFERENCES

- Myers, Eugene W. "An O(ND) Difference Algorithm and Its Variations" (1986)
- GNU diff manual
- Unified diff format specification

---

*Specification compiled: 2026-01-18*
*Generated by spec-extraction workflow S07*
