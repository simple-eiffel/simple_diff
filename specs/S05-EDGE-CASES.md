# S05-EDGE-CASES: simple_diff

## Edge Case Analysis

This document identifies edge cases, boundary conditions, and potential failure modes in simple_diff.

## Input Edge Cases

### EC-IN-001: Empty Inputs

| Scenario | Source | Target | Expected |
|----------|--------|--------|----------|
| Both empty | "" | "" | `is_identical = True` |
| Source empty | "" | "line1" | All additions |
| Target empty | "line1" | "" | All deletions |

**Test Coverage**: `test_empty_strings`, `test_one_empty_string`

**Risk Level**: LOW (handled correctly)

### EC-IN-002: Single Character

| Scenario | Source | Target | Expected |
|----------|--------|--------|----------|
| Single identical | "a" | "a" | `is_identical = True` |
| Single different | "a" | "b" | 1 del + 1 add |
| Single to multiple | "a" | "a%Nb" | 1 addition |

**Test Coverage**: Implicit in basic tests

**Risk Level**: LOW

### EC-IN-003: Very Long Lines

| Scenario | Risk | Mitigation |
|----------|------|------------|
| Line > 10KB | Memory pressure | None - relies on STRING |
| Line > 1MB | Potential timeout | None documented |
| Many long lines | O(N*M) explosion | None documented |

**Test Coverage**: NOT TESTED

**Risk Level**: MEDIUM - no explicit length limits

### EC-IN-004: Binary Content

| Scenario | Risk | Mitigation |
|----------|------|------------|
| Null bytes in content | May truncate STRING | None - assumes text |
| High-bit characters | Encoding issues | None - assumes compatible |
| Control characters | Display issues | None documented |

**Test Coverage**: NOT TESTED

**Risk Level**: MEDIUM - no binary detection

### EC-IN-005: Line Endings

| Scenario | Source | Target | Behavior |
|----------|--------|--------|----------|
| Unix (LF) | "a%Nb" | "a%Nb" | Identical |
| Windows (CRLF) | "a%R%Nb" | "a%R%Nb" | Identical (CRLF preserved) |
| Mixed | "a%Nb" | "a%R%Nb" | Different (CRLF vs LF) |

**Test Coverage**: PATCH_APPLIER strips %R

**Risk Level**: LOW - but mixed endings may cause false diffs

---

## Numeric Boundary Cases

### EC-NUM-001: Line Numbers

| Scenario | Value | Constraint | Behavior |
|----------|-------|------------|----------|
| Minimum | 1 | `>= 1` for start | Enforced by precondition |
| Zero | 0 | Invalid for start | Precondition violation |
| Negative | -1 | Invalid | Precondition violation |
| Maximum | INTEGER.max | No upper limit | Could overflow in DP table |

**Risk Level**: LOW for typical use, MEDIUM for huge files

### EC-NUM-002: Context Lines

| Scenario | Value | Behavior |
|----------|-------|----------|
| Zero | 0 | No context, changes only |
| Default | 3 | Standard unified diff |
| Large | 1000 | Excessive memory |
| Negative | -1 | Precondition violation |

**Risk Level**: LOW - precondition guards negative

### EC-NUM-003: Array Dimensions

| Scenario | Risk |
|----------|------|
| LCS table: N*M cells | Memory for large files |
| N=10000, M=10000 | 100M cells = 400MB+ |
| Out of memory | Uncaught exception |

**Risk Level**: HIGH for large files - no size limits

---

## State Edge Cases

### EC-ST-001: Uninitialized Engine

| Scenario | Expected |
|----------|----------|
| `compute_diff` without `set_source` | Precondition violation |
| `compute_diff` without `set_target` | Precondition violation |

**Risk Level**: LOW - contracts protect

### EC-ST-002: Reuse After Error

| Scenario | Expected |
|----------|----------|
| Diff after error | May produce invalid results |
| Apply after error | `clear_state` should be called |

**Risk Level**: MEDIUM - user must remember to clear

### EC-ST-003: Multiple Operations

| Scenario | Expected |
|----------|----------|
| Sequential diffs | Each independent |
| Sequential applies | State accumulates (rejects) |

**Risk Level**: MEDIUM - state management needed

---

## File System Edge Cases

### EC-FS-001: File Access

| Scenario | Behavior |
|----------|----------|
| File not found | `has_error = True`, message set |
| Permission denied | Error (OS-dependent) |
| Directory instead of file | Error |

**Risk Level**: LOW - errors handled

### EC-FS-002: Path Edge Cases

| Scenario | Risk |
|----------|------|
| Very long path | OS limit may fail |
| Unicode path | Platform-dependent |
| Special characters | May need escaping |
| Relative vs absolute | Should work both |

**Test Coverage**: NOT TESTED

**Risk Level**: MEDIUM - platform variations

### EC-FS-003: Concurrent Access

| Scenario | Risk |
|----------|------|
| File modified during diff | Inconsistent results |
| File locked | Read may fail |
| Race condition on apply | Corruption possible |

**Risk Level**: HIGH - no locking mechanism

---

## Algorithm Edge Cases

### EC-ALG-001: LCS Degenerate Cases

| Scenario | LCS | Result |
|----------|-----|--------|
| No common elements | [] | All del + all add |
| All common | [full] | Identical |
| One common in middle | [1] | Sparse matches |

**Risk Level**: LOW - algorithm handles

### EC-ALG-002: Hunk Merging

| Scenario | Behavior |
|----------|----------|
| Changes within context distance | Single merged hunk |
| Changes beyond context | Separate hunks |
| Overlapping context | Merged |

**Risk Level**: LOW - logic correct

### EC-ALG-003: Patch Context Mismatch

| Scenario | Behavior |
|----------|----------|
| File modified since diff | Context mismatch |
| Similar but not identical | Reject hunk |
| All hunks rejected | Full rejection |

**Test Coverage**: Basic test exists

**Risk Level**: MEDIUM - fuzzy matching not supported

---

## Output Edge Cases

### EC-OUT-001: Format Special Characters

| Scenario | Format | Risk |
|----------|--------|------|
| HTML: `<>&"` in content | HTML | Must escape - HANDLED |
| JSON: `"\` in content | JSON | Must escape - needs verification |
| Unified: `@@` in content | Unified | Could confuse parsers |

**Risk Level**: MEDIUM for JSON escaping

### EC-OUT-002: Side-by-Side Width

| Scenario | Behavior |
|----------|----------|
| Line longer than width/2 | Truncated |
| Width < 20 | Precondition violation |
| Very wide | Works but excessive |

**Risk Level**: LOW - handled by contracts

### EC-OUT-003: ANSI Colors in Non-Terminal

| Scenario | Risk |
|----------|------|
| Output to file | ANSI codes visible as text |
| Non-ANSI terminal | Garbage characters |
| Pipe to another tool | May cause issues |

**Risk Level**: LOW - user controls `use_color`

---

## Resource Edge Cases

### EC-RES-001: Memory Exhaustion

| Scenario | Risk |
|----------|------|
| Very large files | O(N*M) memory |
| Many concurrent diffs | Memory accumulation |
| No explicit limits | Could crash |

**Risk Level**: HIGH - no protection

### EC-RES-002: Performance

| Scenario | Impact |
|----------|--------|
| Large identical files | Full LCS computation still needed |
| Many small differences | Many hunks to process |
| Deep directory tree | Recursive comparison |

**Risk Level**: MEDIUM - no early termination

---

## Summary: Edge Case Risk Matrix

| Category | Cases | HIGH Risk | MEDIUM Risk | LOW Risk |
|----------|-------|-----------|-------------|----------|
| Input | 5 | 0 | 2 | 3 |
| Numeric | 3 | 1 | 0 | 2 |
| State | 3 | 0 | 2 | 1 |
| File System | 3 | 1 | 1 | 1 |
| Algorithm | 3 | 0 | 1 | 2 |
| Output | 3 | 0 | 1 | 2 |
| Resource | 2 | 1 | 1 | 0 |
| **Total** | **22** | **3** | **8** | **11** |

## High-Risk Edge Cases Requiring Attention

1. **EC-NUM-003**: Large file LCS memory (O(N*M))
2. **EC-FS-003**: Concurrent file access (no locking)
3. **EC-RES-001**: Memory exhaustion (no limits)

## Recommended Mitigations

1. Add file size limits with clear error messages
2. Implement linear-space Myers variant for large files
3. Add file locking for apply operations
4. Consider streaming approach for directory diffs
5. Add binary file detection

## Next Steps

→ S06-DEPENDENCIES.md

---

*Edge cases analyzed: 2026-01-18*
*Generated by spec-extraction workflow S05*
