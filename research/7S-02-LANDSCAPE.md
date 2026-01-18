# 7S-02-LANDSCAPE: simple_diff (Retrospective)

## Landscape Analysis

This documents what landscape research would have revealed before building simple_diff.

---

## EXISTING SOLUTIONS

### 1. GNU diff (Command Line)

| Aspect | Assessment |
|--------|------------|
| **Approach** | C implementation, command-line tool |
| **Algorithm** | Myers diff (same as ours) |
| **Output** | Unified, context, side-by-side |
| **Strengths** | Battle-tested, standard, fast |
| **Weaknesses** | External process, no Eiffel integration |
| **Fit**: 30% | Requires shell execution, parsing |

### 2. Git diff

| Aspect | Assessment |
|--------|------------|
| **Approach** | Part of Git, rich features |
| **Algorithm** | Myers with patience, histogram variants |
| **Output** | Multiple formats, colorized |
| **Strengths** | Excellent output, word-diff |
| **Weaknesses** | Requires Git, overkill for simple diffing |
| **Fit**: 20% | Too heavy, external dependency |

### 3. Python difflib

| Aspect | Assessment |
|--------|------------|
| **Approach** | Standard library, pure Python |
| **Algorithm** | Ratcliff/Obershelp (different from Myers) |
| **Output** | Unified, HTML, context |
| **Strengths** | Well-designed API, good documentation |
| **Weaknesses** | Python-specific, not Eiffel |
| **Fit**: N/A | Different language |

### 4. Java diff-utils

| Aspect | Assessment |
|--------|------------|
| **Approach** | Java library, Apache license |
| **Algorithm** | Myers with extensions |
| **Output** | Programmatic, multiple formats |
| **Strengths** | Good API design, patch support |
| **Weaknesses** | JVM-specific |
| **Fit**: N/A | Different language |

### 5. EiffelBase STRING.same_string

| Aspect | Assessment |
|--------|------------|
| **Approach** | Built-in string comparison |
| **Algorithm** | Character-by-character equality |
| **Output** | Boolean only |
| **Strengths** | Available, fast |
| **Weaknesses** | No diff, just equals |
| **Fit**: 5% | Insufficient for diffing |

---

## COMPARATIVE ANALYSIS

### Feature Matrix

| Feature | GNU diff | Git diff | difflib | simple_diff |
|---------|----------|----------|---------|-------------|
| String diff | ✓ | ✓ | ✓ | ✓ |
| File diff | ✓ | ✓ | ✓ | ✓ |
| Directory diff | ✓ | ✓ | Limited | ✓ |
| Unified format | ✓ | ✓ | ✓ | ✓ |
| Side-by-side | ✓ | ✓ | ✓ | ✓ |
| HTML output | External | External | ✓ | ✓ |
| Colored output | ✓ | ✓ | ✓ | ✓ |
| Patch apply | patch cmd | git apply | ✓ | ✓ |
| Programmatic API | ✗ | ✗ | ✓ | ✓ |
| DBC contracts | ✗ | ✗ | ✗ | ✓ |
| Eiffel native | ✗ | ✗ | ✗ | ✓ |

### Gap Analysis

| Gap | Impact | simple_diff Solution |
|-----|--------|---------------------|
| No Eiffel diff library | Must shell out | Native implementation |
| No DBC guarantees | Runtime errors | Full contract coverage |
| External process overhead | Performance | In-process computation |
| Parsing external output | Fragile | Structured DIFF_RESULT |

---

## ALGORITHM LANDSCAPE

### Myers Diff Algorithm (Chosen)

| Aspect | Assessment |
|--------|------------|
| **Complexity** | O(ND) where D is edit distance |
| **Space** | O(N*M) for standard, O(N) for linear-space variant |
| **Quality** | Optimal (minimal edits) |
| **Maturity** | Standard since 1986 |

### Alternatives Considered

| Algorithm | Pros | Cons | Decision |
|-----------|------|------|----------|
| Hunt-McIlroy | Simpler | Slower | Rejected |
| Patience | Better semantic diffs | More complex | Future option |
| Histogram | Git's default | More complex | Future option |
| Ratcliff/Obershelp | Good for fuzzy | Not optimal | Rejected |

### Why Myers Was Chosen

1. **Industry standard** - GNU diff, Git use it
2. **Optimal output** - Minimal edit distance guaranteed
3. **Well understood** - Extensive documentation
4. **Reasonable complexity** - O(ND) practical for text

---

## BUILD VS BUY ANALYSIS

### Option A: Build from Scratch

| Factor | Assessment |
|--------|------------|
| Effort | High (algorithm implementation) |
| Control | Full |
| Customization | Full |
| Risk | Algorithm bugs |
| Maintenance | Owner responsibility |

### Option B: Wrap External Tool

| Factor | Assessment |
|--------|------------|
| Effort | Low (shell wrapper) |
| Control | Limited |
| Customization | Limited to tool features |
| Risk | External dependency |
| Maintenance | External tool updates |

### Option C: Port Existing Library

| Factor | Assessment |
|--------|------------|
| Effort | Medium (translation) |
| Control | Moderate |
| Customization | Moderate |
| Risk | Translation bugs |
| Maintenance | Keeping in sync |

### Decision: BUILD

**Rationale**:
1. No suitable Eiffel library exists
2. External tools break ecosystem design (no DBC, SCOOP issues)
3. Algorithm is well-documented, implementation tractable
4. Full control over API design

---

## INSPIRATION SOURCES

### API Design Inspiration

| Source | Inspiration Taken |
|--------|-------------------|
| Python difflib | Clean API, HtmlDiff concept |
| Java diff-utils | Patch class design |
| GNU diff | Output format compliance |
| Ruby Diffy | Builder pattern for options |

### Architecture Inspiration

| Source | Inspiration Taken |
|--------|-------------------|
| OOSC2 | Facade pattern, DBC |
| simple_* ecosystem | Naming, structure |
| EiffelBase | Collection patterns |

---

## TECHNOLOGY LANDSCAPE

### Relevant Eiffel Features

| Feature | Usage |
|---------|-------|
| ARRAYED_LIST | Line collections |
| ARRAY2 | LCS table |
| STRING | Content handling |
| PLAIN_TEXT_FILE | File I/O |
| Design by Contract | All classes |
| Void Safety | All code |

### No External Technology Needed

The entire solution uses only EiffelBase, validating the "no external dependencies" constraint.

---

## RETROSPECTIVE VALIDATION

### Landscape Assessment Was Accurate

✓ No Eiffel diff library existed - BUILD was correct
✓ Myers algorithm was right choice - standard, optimal
✓ API design drew from best practices - Python difflib influence clear
✓ External tools rejected - correct for ecosystem consistency

### Opportunities Identified

Future versions could add:
- Patience diff algorithm (better semantic diffs)
- Word-level diff (not just lines)
- Fuzzy matching for patch context

---

*Retrospective landscape analysis: 2026-01-18*
*Generated by deep-research workflow 7S-02*
