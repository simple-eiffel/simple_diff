# D03-PATTERNS: simple_diff Design Audit

## Design Pattern Analysis

This document audits the design patterns used in simple_diff.

---

## PATTERNS IDENTIFIED

### 1. Facade Pattern ✓

**Location**: SIMPLE_DIFF class
**Purpose**: Unified entry point to library

```
Client
   │
   ▼
┌──────────────┐
│ SIMPLE_DIFF  │ ◄── Facade
│   (facade)   │
└──────┬───────┘
       │
   ┌───┴────┬───────────┬──────────────┐
   ▼        ▼           ▼              ▼
┌──────┐ ┌──────────┐ ┌────────────┐ ┌─────────────┐
│ENGINE│ │ RESULT   │ │ RENDERER   │ │  APPLIER    │
└──────┘ └──────────┘ └────────────┘ └─────────────┘
```

**Assessment**: ✓ Excellent application
- Hides complexity from user
- Provides simple API
- Delegates to specialized classes

---

### 2. Builder Pattern ✓

**Location**: SIMPLE_DIFF configuration methods
**Purpose**: Fluent configuration API

```eiffel
create l_diff.make
l_diff.set_context_lines (5)
      .set_ignore_whitespace (True)
      .set_ignore_case (True)
```

**Implementation**:
```eiffel
set_context_lines (n: INTEGER): like Current
    require
        non_negative: n >= 0
    do
        context_lines := n
        Result := Current
    ensure
        context_set: context_lines = n
        result_is_self: Result = Current
    end
```

**Assessment**: ✓ Good application
- Fluent interface
- Optional configuration
- `like Current` enables inheritance

---

### 3. Composite Pattern ✓

**Location**: DIFF_RESULT → DIFF_HUNK → DIFF_LINE
**Purpose**: Hierarchical result structure

```
DIFF_RESULT
    │
    ├── hunks: LIST [DIFF_HUNK]
    │       │
    │       ├── DIFF_HUNK (1)
    │       │       │
    │       │       └── lines: LIST [DIFF_LINE]
    │       │               ├── DIFF_LINE (context)
    │       │               ├── DIFF_LINE (removed)
    │       │               └── DIFF_LINE (added)
    │       │
    │       └── DIFF_HUNK (2)
    │               └── ...
    │
    └── metadata (paths, etc.)
```

**Assessment**: ✓ Natural fit for domain
- Mirrors conceptual model
- Easy iteration
- Clear ownership

---

### 4. Value Object Pattern ✓

**Location**: DIFF_LINE class
**Purpose**: Immutable line representation

**Characteristics**:
- Created with all data (no setters)
- Identity by value (content + status + positions)
- Can be safely shared

**Assessment**: ⚠ Partial implementation
- No setters (good)
- Equality not overridden (could add)
- Could be more explicit about immutability

---

### 5. Command-Query Separation ✓

**Location**: Throughout codebase
**Purpose**: Clean API semantics

**Commands** (modify state, no return or return Current):
- `add_line`, `add_hunk`
- `set_context_lines` (returns Current for chaining)
- `apply`, `clear_error`

**Queries** (return value, no side effects):
- `is_identical`, `has_changes`
- `hunk_count`, `additions_total`
- `to_unified`, `to_html`

**Assessment**: ✓ Consistently applied

---

## PATTERNS THAT COULD BE APPLIED

### Strategy Pattern (Not Used)

**Location**: DIFF_RENDERER
**Current**: Multiple render methods in one class
**Could Be**:

```
DIFF_RENDERER
    │
    └── strategy: DIFF_FORMAT_STRATEGY
            │
            ├── UNIFIED_FORMAT
            ├── HTML_FORMAT
            ├── SIDE_BY_SIDE_FORMAT
            └── COLORED_FORMAT
```

**Assessment**: ⚠ Not necessary now
- Only 4 formats
- Would add complexity
- Consider if more formats needed

---

### Template Method (Partial)

**Location**: Rendering methods
**Current**: Each render method has similar structure
**Pattern**: Extract common skeleton

```eiffel
deferred class DIFF_FORMAT
feature
    render (result: DIFF_RESULT): STRING
        do
            create Result.make (1000)
            render_header (result, Result)
            across result.hunks as h loop
                render_hunk (h.item, Result)
            end
            render_footer (result, Result)
        end

    render_header (result: DIFF_RESULT; output: STRING) deferred end
    render_hunk (hunk: DIFF_HUNK; output: STRING) deferred end
    render_footer (result: DIFF_RESULT; output: STRING) deferred end
end
```

**Assessment**: ⚠ Could improve extensibility

---

### Factory Method (Not Used)

**Location**: DIFF_LINE creation
**Current**: Direct creation with three procedures
**Could Be**: Factory methods in DIFF_LINE

```eiffel
class DIFF_LINE
feature -- Factory
    context (content: STRING; src, tgt: INTEGER): DIFF_LINE
    added (content: STRING; tgt: INTEGER): DIFF_LINE
    removed (content: STRING; src: INTEGER): DIFF_LINE
```

**Assessment**: ⚠ Minor improvement, not critical

---

## ANTI-PATTERNS DETECTED

### None Critical

The codebase avoids common anti-patterns:

| Anti-Pattern | Status | Notes |
|--------------|--------|-------|
| God Class | ✓ Avoided | Largest is 451 lines |
| Spaghetti Code | ✓ Avoided | Clear structure |
| Copy-Paste | ✓ Avoided | Code reused appropriately |
| Magic Numbers | ⚠ Minor | Status constants could be enum |
| Long Parameter List | ✓ Avoided | Max 3 params |

### Minor Issues

**Issue P-001: Integer Status Constants**

**Location**: DIFF_LINE status constants
**Pattern Violation**: "Replace Type Code with Class"

**Current**:
```eiffel
Status_context: INTEGER = 0
Status_added: INTEGER = 1
Status_removed: INTEGER = 2
```

**Could Be**: Separate classes or enum
**Assessment**: Low priority - constants work fine, invariant validates

---

## OOSC2 PATTERN ALIGNMENT

### Command-Query Separation ✓
Consistently applied throughout.

### Single Choice Principle ⚠
Status handling could be improved:
```eiffel
-- Current: switch in multiple places
inspect status
when Status_context then ...
when Status_added then ...
when Status_removed then ...
```

Consider polymorphism if more statuses added.

### Open-Closed Principle ⚠
- Adding new output format requires modifying DIFF_RENDERER
- Strategy pattern would improve this

### Uniform Access Principle ✓
Features accessible without knowing if attribute or function:
```eiffel
l_result.is_identical  -- Could be attribute or function
l_result.hunk_count    -- Client doesn't care
```

---

## PATTERN SCORE: 88/100

**Patterns Well Applied**:
- Facade (excellent)
- Builder (excellent)
- Composite (excellent)
- Command-Query Separation (excellent)

**Patterns Could Add**:
- Strategy for renderers (medium value)
- Factory methods for lines (low value)

**Anti-Patterns Avoided**:
- No God classes
- No spaghetti code
- Clean structure

---

*Pattern audit completed: 2026-01-18*
*Generated by design-audit workflow D03*
