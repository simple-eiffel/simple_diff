# 7S-07-RECOMMENDATION: simple_diff (Retrospective)


**Date**: 2026-01-18

## Executive Summary

**PROJECT**: simple_diff - Text Differencing Library for Eiffel

**PURPOSE**: Provide native Eiffel text comparison with Myers algorithm, multiple output formats, and patch application capabilities.

**RECOMMENDATION**: ✓ PROCEED (Validated)

---

## KEY FINDINGS

1. **Gap in ecosystem**: No native Eiffel diff library existed - building was the right choice
2. **Sound technical foundation**: Myers algorithm is industry standard with optimal output
3. **Good architecture**: Facade pattern, clean separation, full DBC coverage
4. **Successful delivery**: Phase 1 complete with 29 passing tests

---

## KEY RISKS

| Risk | Mitigation | Status |
|------|------------|--------|
| Large file memory | Document limitation, plan linear-space | Documented |
| Algorithm bugs | Extensive test suite | Mitigated |
| Concurrent access | Document user responsibility | Documented |

---

## GO/NO-GO ASSESSMENT

### GO FACTORS (Reasons to Proceed)

+ **Ecosystem need**: No alternative exists in Eiffel
+ **Technical viability**: Algorithm well-understood, implementation tractable
+ **Clear value**: Enables new tools and workflows
+ **Minimal dependencies**: Only EiffelBase required
+ **DBC advantage**: Formal guarantees unique to Eiffel

### NO-GO FACTORS (Concerns)

- Memory limitation for very large files
- No binary file support
- Solo maintainer

### ASSESSMENT SCORECARD

| Factor | Weight | Score | Weighted |
|--------|--------|-------|----------|
| Problem value | 3 | 5 | 15 |
| Solution viability | 3 | 5 | 15 |
| Competitive advantage | 2 | 5 | 10 |
| Risk level | 3 | 4 | 12 |
| Resource availability | 2 | 4 | 8 |
| Strategic fit | 2 | 5 | 10 |
| **Total** | **15** | | **70** |

**SCORE**: 70/75 - **Strong GO**

**Interpretation**:
- 60-75: Strong GO ← We are here
- 45-59: GO with conditions
- 30-44: Proceed with caution
- 15-29: NO-GO

---

## RESEARCH SYNTHESIS

### SCOPE (7S-01)
- **Problem**: Eiffel lacks native diff capability
- **Users**: Library authors, tool builders, test frameworks
- **Success criteria**: Works for text, no deps, correct output, good perf

### LANDSCAPE (7S-02)
- **Alternatives found**: 5 (GNU diff, Git diff, difflib, diff-utils, STRING)
- **Best alternative**: None suitable (all external or wrong language)
- **Our differentiation**: Native Eiffel, DBC, SCOOP-safe

### REQUIREMENTS (7S-03)
- **MUST have**: 7 (string/file diff, unified output, etc.)
- **SHOULD have**: 5 (multiple formats, patch operations)
- **Key NFRs**: Void-safe, SCOOP-compatible, fully contracted

### DECISIONS (7S-04)
- **Build/Buy/Adapt**: BUILD (no suitable alternative)
- **Architecture**: Facade pattern with internal engine/renderer/applier
- **Key trade-offs**: Memory for simplicity (LCS table)

### INNOVATIONS (7S-05)
- **Unique value**: Only native Eiffel diff library
- **Novel approaches**: 7 innovations identified
- **Eiffel advantages**: DBC, void-safety, SCOOP, like Current

### RISKS (7S-06)
- **Critical risks**: 1 (memory for large files)
- **Overall risk level**: MEDIUM
- **Top mitigation**: Document limitations, plan improvements

---

## RECOMMENDATION

### PRIMARY RECOMMENDATION: ✓ VALIDATED (PROCEED was correct)

### RECOMMENDATION STATEMENT

Building simple_diff was the correct decision. The library successfully fills a gap in the Eiffel ecosystem with a well-designed, fully-contracted implementation that follows ecosystem patterns.

### RATIONALE

1. **Problem was real**: No native Eiffel diff library existed
2. **Solution is viable**: Myers algorithm is tractable and standard
3. **Implementation is sound**: Good architecture, full DBC, comprehensive tests
4. **Value is delivered**: Phase 1 complete and functional

### CONDITIONS MET

- [x] Pure Eiffel implementation
- [x] No external dependencies
- [x] Full contract coverage
- [x] SCOOP compatibility
- [x] Comprehensive test suite
- [x] Clear documentation

### ALTERNATIVES RECONSIDERED

| Alternative | Why Still Not Chosen |
|-------------|---------------------|
| Wrap GNU diff | Breaks ecosystem (no DBC, external process) |
| Port difflib | Translation maintenance burden |
| No diff library | Ecosystem incomplete |

---

## IMPLEMENTATION ROADMAP

### Phase 1: Foundation ✓ COMPLETE
- **Status**: DONE
- **Deliverables**:
  - [x] Myers diff algorithm
  - [x] String/file comparison
  - [x] Multiple output formats
  - [x] Patch application
  - [x] 29 tests passing

### Phase 2: Extended Features
- **Status**: PLANNED
- **Deliverables**:
  - [ ] Binary file detection
  - [ ] File size limits with clear errors
  - [ ] Enhanced directory diffing
  - [ ] Performance benchmarks

### Phase 3: Advanced Algorithms
- **Status**: FUTURE
- **Deliverables**:
  - [ ] Linear-space Myers variant
  - [ ] Patience diff algorithm
  - [ ] Word-level diff

### ROADMAP VISUALIZATION

```
Phase 1: Foundation    Phase 2: Extended     Phase 3: Advanced
├──────────────────────┼─────────────────────┼──────────────────┤
|████████████████████||                   ||                |
├──────────────────────┼─────────────────────┼──────────────────┤
Milestone: 29 tests    Milestone: Limits    Milestone: New algos
Status: COMPLETE       Status: PLANNED      Status: FUTURE
```

---

## IMMEDIATE NEXT STEPS

### 1. Document Large File Limitation
**Owner**: Developer
**Output**: README update with size guidance

### 2. Add Binary Detection
**Owner**: Developer
**Output**: Error when binary content detected

### 3. Performance Benchmarks
**Owner**: Developer
**Output**: Benchmark test suite

---

## RESOURCE REQUIREMENTS

### PEOPLE
- **Role**: Eiffel Developer
- **Skills**: Algorithms, DBC, SCOOP
- **Effort**: Available as needed

### TOOLS
- **EiffelStudio 25.x**: Development environment
- **simple_testing**: Test framework
- **Git**: Version control

### DEPENDENCIES
- **EiffelBase**: Core library (available)
- **simple_testing**: Tests only (available)

---

## SUCCESS METRICS

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Tests passing | 100% | 100% | ✓ |
| Classes with contracts | 100% | 100% | ✓ |
| Output formats | 4+ | 5 | ✓ |
| External dependencies | 0 | 0 | ✓ |
| SCOOP compatible | Yes | Yes | ✓ |

### CHECKPOINTS

- **Phase 1**: ✓ Complete - 29 tests, all classes
- **Phase 2**: Add limits, binary detection
- **Phase 3**: Alternative algorithms

---

## CONCLUSION

**simple_diff was the right project to build.** The research retrospective validates all major decisions:

1. ✓ BUILD decision correct (no alternative existed)
2. ✓ Myers algorithm appropriate (standard, optimal)
3. ✓ Architecture sound (facade, separation of concerns)
4. ✓ DBC coverage complete (formal guarantees)
5. ✓ Tests comprehensive (29 passing)

The library successfully fills a gap in the Eiffel ecosystem with a well-designed implementation that follows ecosystem patterns and provides unique value through Design by Contract.

**Phase 1 is complete. Proceed with Phase 2 when resources allow.**

---

## APPENDIX REFERENCES

### Research Documents
- 7S-01-SCOPE.md - Problem and scope definition
- 7S-02-LANDSCAPE.md - Alternative analysis
- 7S-03-REQUIREMENTS.md - Requirements specification
- 7S-04-DECISIONS.md - Design decisions
- 7S-05-INNOVATIONS.md - Innovation analysis
- 7S-06-RISKS.md - Risk assessment

### Specification Documents
- specs/S01-INVENTORY.md - Project inventory
- specs/S02-DOMAIN-MODEL.md - Domain model
- specs/S03-CONTRACTS.md - Contract catalog
- specs/S04-BEHAVIORS.md - Behavioral specs
- specs/S05-EDGE-CASES.md - Edge case analysis
- specs/S06-DEPENDENCIES.md - Dependency mapping
- specs/S07-COMPILED-SPEC.md - Formal specification
- specs/S08-VALIDATION.md - Validation report

---

*Research completed: 2026-01-18*
*Ready for: Design-Audit workflow (D01-D08)*
