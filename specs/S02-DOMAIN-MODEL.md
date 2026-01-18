# S02-DOMAIN-MODEL: simple_diff

## Domain Overview

The simple_diff library operates in the **text differencing domain**, computing and representing differences between text sources (strings, files, directories).

## Core Domain Concepts

### 1. Diff (Comparison Operation)
The act of comparing two text sources to identify differences.

**Representation**: `DIFF_ENGINE.compute_diff`

**Properties**:
- Has a source (original text)
- Has a target (modified text)
- Produces a result containing changes

### 2. Source/Target
The two inputs to a diff operation.

**Representation**: Implicit in `DIFF_ENGINE` attributes

**Properties**:
- Source: The original/baseline text
- Target: The modified/new text
- Both are decomposed into lines for comparison

### 3. Result
The output of a diff operation containing all identified changes.

**Representation**: `DIFF_RESULT`

**Properties**:
- Collection of hunks (change blocks)
- Metadata (source path, target path)
- Aggregate statistics (additions, deletions)
- Identity status (whether sources are identical)

### 4. Hunk (Change Block)
A contiguous block of changes with surrounding context.

**Representation**: `DIFF_HUNK`

**Properties**:
- Starting position in source
- Starting position in target
- Line counts for source and target
- Collection of lines (context + changes)

### 5. Line
A single line with its change status.

**Representation**: `DIFF_LINE`

**Properties**:
- Content (the text)
- Status (context, added, or removed)
- Position in source (if applicable)
- Position in target (if applicable)

### 6. Line Status (Enumeration)
The state of a line in the diff.

**Representation**: Integer constants in `DIFF_LINE`

**Values**:
- Context (0): Line unchanged, appears in both
- Added (1): Line exists only in target
- Removed (2): Line exists only in source

### 7. Patch
A diff that can be applied to transform source into target.

**Representation**: `DIFF_RESULT` (same as Result, but used for application)

**Operations**:
- Apply (forward): Transform source → target
- Reverse: Transform target → source
- Dry-run: Preview without modification

### 8. Rejection
A hunk that could not be applied due to context mismatch.

**Representation**: `PATCH_APPLIER.rejected_hunks`

**Properties**:
- The failed hunk
- Can be written to .rej file

## Domain Model Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     DIFF OPERATION                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐         ┌──────────┐         ┌──────────┐    │
│  │  SOURCE  │ ─────── │  ENGINE  │ ─────── │  TARGET  │    │
│  │  (text)  │ compare │  (Myers) │ compare │  (text)  │    │
│  └──────────┘         └────┬─────┘         └──────────┘    │
│                            │                                │
│                            ▼                                │
│                     ┌──────────────┐                        │
│                     │    RESULT    │                        │
│                     │ (DIFF_RESULT)│                        │
│                     └──────┬───────┘                        │
│                            │ contains                       │
│                            ▼                                │
│                     ┌──────────────┐                        │
│                     │    HUNKS     │ 1..*                   │
│                     │ (DIFF_HUNK)  │                        │
│                     └──────┬───────┘                        │
│                            │ contains                       │
│                            ▼                                │
│                     ┌──────────────┐                        │
│                     │    LINES     │ 1..*                   │
│                     │ (DIFF_LINE)  │                        │
│                     └──────────────┘                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    PATCH APPLICATION                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐         ┌──────────┐         ┌──────────┐    │
│  │  PATCH   │ ─────── │ APPLIER  │ ─────── │  TARGET  │    │
│  │ (RESULT) │  apply  │          │ modify  │  (file)  │    │
│  └──────────┘         └────┬─────┘         └──────────┘    │
│                            │                                │
│                   ┌────────┴────────┐                       │
│                   ▼                 ▼                       │
│            ┌──────────┐      ┌──────────┐                   │
│            │ SUCCESS  │      │ REJECTS  │                   │
│            │ (applied)│      │ (.rej)   │                   │
│            └──────────┘      └──────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Entity Relationships

### Aggregation
- `DIFF_RESULT` aggregates `DIFF_HUNK` (1:*)
- `DIFF_HUNK` aggregates `DIFF_LINE` (1:*)

### Association
- `SIMPLE_DIFF` → `DIFF_ENGINE` (uses)
- `SIMPLE_DIFF` → `DIFF_RENDERER` (uses)
- `SIMPLE_DIFF` → `PATCH_APPLIER` (uses)
- `DIFF_RENDERER` → `DIFF_RESULT` (transforms)
- `PATCH_APPLIER` → `DIFF_RESULT` (applies)

### Dependency
- All classes depend on EiffelBase (STRING, ARRAYED_LIST, etc.)

## Domain Vocabulary

| Term | Definition | Class |
|------|------------|-------|
| diff | The difference between two texts | - |
| source | The original/baseline text | DIFF_ENGINE |
| target | The modified/new text | DIFF_ENGINE |
| hunk | A contiguous block of changes | DIFF_HUNK |
| context line | An unchanged line providing context | DIFF_LINE |
| added line | A line present only in target | DIFF_LINE |
| removed line | A line present only in source | DIFF_LINE |
| unified format | Standard diff output format | DIFF_RENDERER |
| patch | A diff used to transform files | PATCH_APPLIER |
| reject | A hunk that failed to apply | PATCH_APPLIER |
| dry run | Preview without actual changes | PATCH_APPLIER |

## Invariants (Domain Rules)

### Diff Consistency
1. A diff with no hunks implies identical sources
2. Each hunk contains at least one line
3. Line counts in hunk header match actual lines

### Line Status Rules
1. An added line has no source line number (0)
2. A removed line has no target line number (0)
3. A context line has both source and target line numbers

### Patch Application Rules
1. Context must match for hunk to apply
2. Rejected hunks preserve original order
3. Reverse mode swaps add/remove semantics

## Value Objects vs Entities

### Value Objects (Immutable)
- `DIFF_LINE` - Created once, never modified

### Entities (Mutable)
- `DIFF_HUNK` - Lines added during construction
- `DIFF_RESULT` - Hunks added during computation

### Services
- `DIFF_ENGINE` - Stateless computation
- `DIFF_RENDERER` - Stateless transformation
- `PATCH_APPLIER` - Stateful with error tracking

## Bounded Contexts

### Computation Context
- Responsibility: Compute differences
- Classes: `DIFF_ENGINE`
- Input: Source text, target text
- Output: `DIFF_RESULT`

### Presentation Context
- Responsibility: Format diffs for display
- Classes: `DIFF_RENDERER`
- Input: `DIFF_RESULT`
- Output: Formatted strings (unified, HTML, etc.)

### Application Context
- Responsibility: Apply patches to files
- Classes: `PATCH_APPLIER`
- Input: `DIFF_RESULT`, target file
- Output: Modified file, rejected hunks

### Facade Context
- Responsibility: Unified API for all operations
- Classes: `SIMPLE_DIFF`
- Coordinates all other contexts

## Next Steps

→ S03-CONTRACTS.md

---

*Domain model extracted: 2026-01-18*
*Generated by spec-extraction workflow S02*
