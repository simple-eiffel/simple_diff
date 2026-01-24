# 7S-04-DECISIONS: simple_diff (Retrospective)


**Date**: 2026-01-18

## Key Decisions

This documents the design decisions made during simple_diff development and their rationale.

---

## D-001: Build vs Buy

### Context
Need diff capability for Eiffel ecosystem. Options: build native, wrap external tool, or port existing library.

### Decision
**BUILD** native Eiffel implementation from scratch.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Build native | Full control, DBC, no deps | Higher effort |
| Wrap GNU diff | Low effort | External dependency, no DBC |
| Port difflib | Proven design | Translation effort, sync issues |

### Rationale
- No suitable Eiffel library exists
- External tools break SCOOP and void-safety guarantees
- Myers algorithm well-documented, tractable to implement
- Need full control over API for ecosystem consistency

### Consequences
- Higher initial development effort
- Full ownership of code
- Can evolve independently
- No external dependencies

### Status: DECIDED ✓

---

## D-002: Algorithm Choice

### Context
Multiple diff algorithms exist with different trade-offs.

### Decision
**Myers diff algorithm** (LCS-based, O(ND) complexity).

### Options Considered

| Option | Complexity | Output Quality | Implementation |
|--------|------------|----------------|----------------|
| Myers | O(ND) | Optimal | Moderate |
| Hunt-McIlroy | O(N*M) | Suboptimal | Simpler |
| Patience | O(N log N) | Better semantic | Complex |
| Histogram | O(N*M) | Good semantic | Complex |

### Rationale
- Industry standard (GNU diff, Git)
- Optimal edit distance (minimal changes)
- Well-documented implementation
- Reasonable complexity for typical text files

### Consequences
- O(N*M) space for LCS table (could be improved)
- Optimal output guaranteed
- Compatible with standard diff formats

### Status: DECIDED ✓

---

## D-003: Architecture Pattern

### Context
Need to organize classes for maintainability and usability.

### Decision
**Facade pattern** with SIMPLE_DIFF as entry point, internal engine/renderer/applier.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Single class | Simple | Bloated, hard to maintain |
| Facade + internal | Clean API, separation | More classes |
| Full decomposition | Maximum flexibility | Overly complex |

### Rationale
- Simple API for common use cases
- Internal classes can evolve independently
- Follows simple_* ecosystem pattern
- Balance between usability and maintainability

### Consequences
- Users primarily interact with SIMPLE_DIFF
- Internal classes available for advanced use
- Clear responsibilities per class

### Status: DECIDED ✓

---

## D-004: Data Model

### Context
Need to represent diff results structurally.

### Decision
**Hierarchical model**: DIFF_RESULT → DIFF_HUNK → DIFF_LINE.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Flat list of changes | Simple | Loses structure |
| Hierarchical (chosen) | Natural, standard | More classes |
| Edit script only | Minimal | Not user-friendly |

### Rationale
- Matches conceptual model of diffs
- Standard representation (unified format is hierarchical)
- Easy to iterate and render
- Maps to output formats naturally

### Consequences
- Three data classes needed
- Natural iteration patterns
- Easy format conversion

### Status: DECIDED ✓

---

## D-005: Line Status Representation

### Context
Need to track whether a line is context, added, or removed.

### Decision
**Integer enumeration** with constants (0=context, 1=added, 2=removed).

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Integer enum | Simple, efficient | Less type-safe |
| Separate classes | Type-safe | Overhead |
| Boolean flags | Flexible | Unclear semantics |

### Rationale
- Simple and efficient
- Constants provide named values
- Invariants enforce valid values
- Pattern used elsewhere in Eiffel

### Consequences
- `status` attribute with constrained values
- Boolean queries (`is_context`, etc.) provide nice API
- Invariant ensures valid range

### Status: DECIDED ✓

---

## D-006: Configuration API

### Context
Need way to configure diff options (context lines, whitespace, case).

### Decision
**Builder pattern** with fluent interface (`set_*: like Current`).

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Constructor params | Simple | Many params, inflexible |
| Builder pattern | Fluent, flexible | More methods |
| Configuration object | Separates concerns | Extra class |

### Rationale
- Fluent API is ergonomic
- Optional configuration natural
- Common pattern in simple_* ecosystem
- Follows Eiffel style (`like Current`)

### Consequences
- Multiple `set_*` methods on SIMPLE_DIFF
- Can chain: `diff.set_context_lines(5).set_ignore_whitespace(True)`
- Defaults work without configuration

### Status: DECIDED ✓

---

## D-007: Error Handling

### Context
Need to handle file not found, patch failures, etc.

### Decision
**has_error/last_error pattern** without exceptions.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Exceptions | Standard | Disrupts flow |
| Error status | Explicit, controllable | Must check |
| Result type | Functional | Not idiomatic Eiffel |

### Rationale
- Follows simple_* ecosystem pattern
- Allows caller to decide how to handle
- Clear API with `has_error`, `last_error`, `clear_error`
- Works well with SCOOP

### Consequences
- Caller must check `has_error` after operations
- Error details in `last_error` string
- Can clear and retry

### Status: DECIDED ✓

---

## D-008: Output Formats

### Context
Need multiple output representations of diffs.

### Decision
**Separate DIFF_RENDERER class** with format-specific methods.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Methods on DIFF_RESULT | Convenient | Bloated class |
| Separate renderer | SRP, extensible | Extra class |
| Strategy pattern | Maximum flexibility | Overkill |

### Rationale
- Single Responsibility Principle
- DIFF_RESULT is data, DIFF_RENDERER is presentation
- Easy to add new formats
- Can configure renderer independently

### Consequences
- DIFF_RESULT has simple `to_*` methods (convenience)
- DIFF_RENDERER has full control methods
- Separation of concerns

### Status: DECIDED ✓

---

## D-009: Patch Application

### Context
Need to apply diffs to transform files.

### Decision
**PATCH_APPLIER class** with dry-run and reverse support.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| On SIMPLE_DIFF | Convenient | Mixing concerns |
| Separate class | SRP, focused | Extra class |
| External tool | Less code | Breaks ecosystem |

### Rationale
- Patch application is distinct from diff computation
- Complex logic deserves dedicated class
- Dry-run and reverse are natural features
- Reject handling needs state

### Consequences
- PATCH_APPLIER manages patch state
- SIMPLE_DIFF delegates to it
- Clear responsibility separation

### Status: DECIDED ✓

---

## D-010: Test Strategy

### Context
Need comprehensive test coverage.

### Decision
**Unit tests per class** with edge case coverage.

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Unit tests | Granular, fast | Many tests |
| Integration tests | Real scenarios | Slower, broader |
| Both | Complete | More effort |

### Rationale
- Unit tests verify each class independently
- Edge cases (empty, single line, etc.) critical
- Fast feedback during development
- Follows simple_* testing patterns

### Consequences
- 29 tests across all classes
- Clear test organization by feature
- Edge cases explicitly tested

### Status: DECIDED ✓

---

## DECISION SUMMARY

| ID | Decision | Chosen | Reversibility |
|----|----------|--------|---------------|
| D-001 | Build vs Buy | BUILD | HARD |
| D-002 | Algorithm | Myers | MEDIUM |
| D-003 | Architecture | Facade | MEDIUM |
| D-004 | Data Model | Hierarchical | MEDIUM |
| D-005 | Line Status | Integer enum | EASY |
| D-006 | Configuration | Builder | EASY |
| D-007 | Error Handling | has_error pattern | EASY |
| D-008 | Output Formats | Separate renderer | EASY |
| D-009 | Patch Application | Separate applier | EASY |
| D-010 | Test Strategy | Unit tests | EASY |

---

*Retrospective decisions analysis: 2026-01-18*
*Generated by deep-research workflow 7S-04*
