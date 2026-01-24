# 7S-06-RISKS: simple_diff (Retrospective)


**Date**: 2026-01-18

## Risk Analysis

This documents the risks identified for simple_diff and their mitigations.

---

## RISK SUMMARY

| Level | Count | IDs |
|-------|-------|-----|
| Critical (H-H) | 1 | R-001 |
| Major (H-M, M-H) | 2 | R-002, R-003 |
| Moderate (M-M) | 3 | R-004, R-005, R-006 |
| Minor | 3 | R-007, R-008, R-009 |

**Overall Risk Level**: MEDIUM
**Proceed Recommendation**: YES WITH CAUTION

---

## CRITICAL RISKS

### R-001: Large File Memory Exhaustion

**Category**: TECHNICAL
**Likelihood**: MEDIUM
**Impact**: HIGH
**Score**: 6 (Critical)

**Description**:
LCS computation requires O(N*M) space for dynamic programming table. For 10K x 10K lines, this is 100M cells = 400MB+ memory. Larger files can exhaust memory.

**Trigger**:
Diffing files with > 10,000 lines each.

**Early Warning Signs**:
- Memory usage spikes during diff
- System slowdown
- Out of memory errors

**Mitigation Strategies**:

| Strategy | Type | Action |
|----------|------|--------|
| Prevention | Limit | Add file size check with error |
| Prevention | Algorithm | Implement linear-space Myers variant |
| Contingency | Recovery | Catch memory error, return error state |
| Acceptance | Document | Document limitation clearly |

**Chosen Mitigation**: Document (Phase 1), Consider linear-space (Phase 2)

**Status**: IDENTIFIED

---

## MAJOR RISKS

### R-002: Algorithm Implementation Bug

**Category**: TECHNICAL
**Likelihood**: MEDIUM
**Impact**: MEDIUM
**Score**: 4 (Major)

**Description**:
Myers algorithm is non-trivial. Implementation bugs could produce incorrect diffs (missing changes, wrong positions).

**Trigger**:
Complex input patterns, edge cases.

**Mitigation Strategies**:

| Strategy | Action |
|----------|--------|
| Prevention | Extensive test suite |
| Prevention | Compare output with GNU diff |
| Detection | Invariant checking in debug |

**Chosen Mitigation**: Extensive testing (29 tests implemented)

**Status**: MITIGATING ✓

---

### R-003: Concurrent File Access Race

**Category**: TECHNICAL
**Likelihood**: LOW
**Impact**: HIGH
**Score**: 4 (Major)

**Description**:
No file locking during patch application. File could be modified by another process between read and write.

**Trigger**:
Multiple processes accessing same file.

**Mitigation Strategies**:

| Strategy | Action |
|----------|--------|
| Prevention | Add file locking |
| Contingency | Detect modification, abort |
| Acceptance | Document as user responsibility |

**Chosen Mitigation**: Document limitation

**Status**: IDENTIFIED

---

## MODERATE RISKS

### R-004: Binary File Handling

**Category**: TECHNICAL
**Likelihood**: MEDIUM
**Impact**: MEDIUM
**Score**: 4 (Moderate)

**Description**:
Library assumes text input. Binary files with null bytes may produce undefined behavior.

**Mitigation**:
Document text-only limitation. Consider adding binary detection.

**Status**: IDENTIFIED

---

### R-005: Line Ending Inconsistency

**Category**: TECHNICAL
**Likelihood**: MEDIUM
**Impact**: LOW
**Score**: 2 (Moderate)

**Description**:
Windows (CRLF) vs Unix (LF) line endings may cause false differences or unexpected behavior.

**Mitigation**:
PATCH_APPLIER strips CR. Document behavior.

**Status**: MITIGATED ✓

---

### R-006: Encoding Issues

**Category**: TECHNICAL
**Likelihood**: LOW
**Impact**: MEDIUM
**Score**: 2 (Moderate)

**Description**:
Non-ASCII characters may behave unexpectedly if encodings don't match.

**Mitigation**:
Document assumption of compatible encodings.

**Status**: IDENTIFIED

---

## MINOR RISKS

### R-007: API Usability

**Category**: SCOPE
**Likelihood**: LOW
**Impact**: LOW
**Score**: 1 (Minor)

**Description**:
Users may find API confusing or miss features.

**Mitigation**:
Comprehensive README with examples.

**Status**: MITIGATED ✓

---

### R-008: Performance Below Expectations

**Category**: TECHNICAL
**Likelihood**: LOW
**Impact**: LOW
**Score**: 1 (Minor)

**Description**:
Diff computation may be slower than expected for typical files.

**Mitigation**:
O(ND) algorithm efficient for typical diffs. Benchmark if needed.

**Status**: ACCEPTED

---

### R-009: Output Format Compliance

**Category**: TECHNICAL
**Likelihood**: LOW
**Impact**: LOW
**Score**: 1 (Minor)

**Description**:
Unified diff output may not perfectly match standard tools.

**Mitigation**:
Test output against GNU diff. Minor variations acceptable.

**Status**: MITIGATED ✓

---

## RISK MATRIX

```
                    IMPACT
               LOW     MEDIUM    HIGH
          ┌─────────┬─────────┬─────────┐
     HIGH │         │ R-002   │         │
          ├─────────┼─────────┼─────────┤
L    MED  │ R-005   │ R-001   │ R-003   │
          │         │ R-004   │         │
          ├─────────┼─────────┼─────────┤
     LOW  │ R-007   │ R-006   │         │
          │ R-008   │         │         │
          │ R-009   │         │         │
          └─────────┴─────────┴─────────┘
```

---

## MITIGATION PLAN

| Risk | Action | When | Status |
|------|--------|------|--------|
| R-001 | Document size limitation | Phase 1 | Done |
| R-001 | Add size check | Phase 2 | Planned |
| R-001 | Linear-space algorithm | Future | Planned |
| R-002 | Test suite | Phase 1 | Done |
| R-003 | Document limitation | Phase 1 | Done |
| R-004 | Binary detection | Phase 2 | Planned |
| R-005 | CR stripping | Phase 1 | Done |
| R-006 | Document assumption | Phase 1 | Done |

---

## CONTINGENCY PLANS

### If R-001 (Memory) Materializes

**Trigger**: Out of memory during diff

**Immediate Actions**:
1. Log file sizes
2. Return error state with message
3. Suggest splitting files

**Recovery**: User should diff smaller segments

---

### If R-002 (Algorithm Bug) Materializes

**Trigger**: Incorrect diff output reported

**Immediate Actions**:
1. Create minimal reproduction
2. Compare with GNU diff output
3. Debug LCS computation

**Recovery**: Patch algorithm, release fix

---

### If R-003 (Race Condition) Materializes

**Trigger**: Corrupted file after patch

**Immediate Actions**:
1. Document incident
2. Check if file was externally modified
3. Restore from backup

**Recovery**: User must ensure exclusive access

---

## INNOVATION RISKS

### I-001: Native Library May Have Bugs

**Innovation**: First native Eiffel diff
**Risk**: No prior implementations to learn from
**Mitigation**: Extensive testing, compare with GNU diff

### I-002: DBC Overhead

**Innovation**: Full contracts
**Risk**: Performance impact in debug builds
**Mitigation**: Contracts off in finalized builds

---

## OVERALL RISK ASSESSMENT

**Risk Profile**:
- 1 critical risk (memory for large files)
- 2 major risks (algorithm bugs, concurrent access)
- 3 moderate risks (binary, encoding, line endings)
- 3 minor risks (usability, performance, format)

**Overall Level**: MEDIUM

**Proceed Recommendation**: YES WITH CAUTION

**Conditions for Proceeding**:
1. ✓ Document large file limitation
2. ✓ Comprehensive test suite
3. ✓ Clear usage examples
4. Plan linear-space algorithm for Phase 2

---

## RISK MONITORING

| Risk | Indicator | Check | Threshold |
|------|-----------|-------|-----------|
| R-001 | Memory usage | Monitor | > 200MB |
| R-002 | Bug reports | GitHub issues | Any |
| R-004 | Binary input reports | Support | Any |

**Risk Review Schedule**: Each phase release

---

*Retrospective risk analysis: 2026-01-18*
*Generated by deep-research workflow 7S-06*
