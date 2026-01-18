# S06-DEPENDENCIES: simple_diff

## Dependency Analysis

This document maps all dependencies in simple_diff at library, class, and feature levels.

## Library Dependencies

### Production Dependencies

| Library | Location | Required Classes |
|---------|----------|------------------|
| base | $ISE_LIBRARY/library/base | STRING, ARRAYED_LIST, ARRAY2, PLAIN_TEXT_FILE, etc. |
| time | $ISE_LIBRARY/library/time | (minimal usage) |

### Test-Only Dependencies

| Library | Location | Required Classes |
|---------|----------|------------------|
| simple_testing | $SIMPLE_EIFFEL/simple_testing | TEST_SET_BASE |

### ECF Configuration
```xml
<library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
<library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>
<library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf">
    <condition><custom name="testing" value="true"/></condition>
</library>
```

## Internal Class Dependencies

### Dependency Graph

```
SIMPLE_DIFF
├── DIFF_ENGINE
│   ├── DIFF_RESULT
│   │   └── DIFF_HUNK
│   │       └── DIFF_LINE
│   └── DIFF_LINE (for creation)
├── DIFF_RENDERER
│   ├── DIFF_RESULT (input)
│   ├── DIFF_HUNK (iteration)
│   └── DIFF_LINE (iteration)
├── PATCH_APPLIER
│   ├── DIFF_RESULT (input)
│   ├── DIFF_HUNK (iteration/rejection)
│   └── DIFF_LINE (iteration)
└── DIFF_RESULT (for direct creation)
```

### Dependency Matrix

| Uses → | SD | DE | DR | DH | DL | RN | PA |
|--------|----|----|----|----|----|----|---|
| SIMPLE_DIFF | - | ✓ | ✓ | | | ✓ | ✓ |
| DIFF_ENGINE | | - | ✓ | ✓ | ✓ | | |
| DIFF_RESULT | | | - | ✓ | | | |
| DIFF_HUNK | | | | - | ✓ | | |
| DIFF_LINE | | | | | - | | |
| DIFF_RENDERER | | | ✓ | ✓ | ✓ | - | |
| PATCH_APPLIER | | | ✓ | ✓ | ✓ | | - |

## EiffelBase Dependencies

### STRING Class Usage

| Class | Features Used |
|-------|---------------|
| SIMPLE_DIFF | `make`, `append`, `split` |
| DIFF_ENGINE | `make`, `count`, `item`, `split` |
| DIFF_RESULT | `make`, `append`, `append_integer` |
| DIFF_HUNK | `make`, `append`, `append_integer`, `append_character` |
| DIFF_LINE | `make`, `append`, `append_character`, `count`, `item` |
| DIFF_RENDERER | `make`, `make_filled`, `append`, `substring`, `has_substring` |
| PATCH_APPLIER | `make`, `split`, `same_string`, `starts_with` |

### ARRAYED_LIST Class Usage

| Class | Features Used |
|-------|---------------|
| DIFF_ENGINE | `make`, `extend`, `count`, `item`, `wipe_out` |
| DIFF_RESULT | `make`, `extend`, `count`, `item`, `is_empty` |
| DIFF_HUNK | `make`, `extend`, `count`, `item`, `is_empty`, `last` |
| PATCH_APPLIER | `make`, `extend`, `count`, `item`, `go_i_th`, `remove`, `put_left`, `append` |

### ARRAY2 Class Usage

| Class | Features Used |
|-------|---------------|
| DIFF_ENGINE | `make_filled`, `put`, `item`, `height`, `width` |

### PLAIN_TEXT_FILE Class Usage

| Class | Features Used |
|-------|---------------|
| SIMPLE_DIFF | `make_with_name`, `exists`, `open_read`, `read_stream`, `close` |
| PATCH_APPLIER | `make_with_name`, `make_create_read_write`, `exists`, `open_read`, `read_stream`, `close`, `put_string`, `put_new_line` |

## Feature-Level Dependencies

### SIMPLE_DIFF Features

```eiffel
feature {NONE} -- Internal
    engine: DIFF_ENGINE
        -- Core diff computation

    renderer: DIFF_RENDERER
        -- Output formatting

    applier: PATCH_APPLIER
        -- Patch application
```

### DIFF_ENGINE Features

```eiffel
feature {NONE} -- Implementation
    source_lines: ARRAYED_LIST [STRING]
    target_lines: ARRAYED_LIST [STRING]

    compute_lcs: ARRAY2 [INTEGER]
        -- LCS dynamic programming table

    build_hunks (ops: ARRAYED_LIST [INTEGER]): ARRAYED_LIST [DIFF_HUNK]
        -- Convert operations to hunks
```

### DIFF_RESULT Features

```eiffel
feature -- Access
    hunks: ARRAYED_LIST [DIFF_HUNK]
        -- Collection of change blocks

    source_path: detachable STRING
    target_path: detachable STRING
```

### DIFF_HUNK Features

```eiffel
feature -- Access
    lines: ARRAYED_LIST [DIFF_LINE]
        -- Lines in this hunk
```

## Inheritance Dependencies

| Class | Inherits From | Purpose |
|-------|---------------|---------|
| LIB_TESTS | TEST_SET_BASE | Test framework |

All other classes inherit from ANY (implicit).

## Export Dependencies

### Feature Export Policies

| Class | Exported To | Features |
|-------|-------------|----------|
| SIMPLE_DIFF | ANY | All public API |
| DIFF_ENGINE | SIMPLE_DIFF | Most features |
| DIFF_RESULT | ANY | Query features |
| DIFF_HUNK | ANY | Query features |
| DIFF_LINE | ANY | All features |
| DIFF_RENDERER | ANY | All features |
| PATCH_APPLIER | ANY | All features |

### Internal Features (NONE export)

| Class | Feature | Purpose |
|-------|---------|---------|
| DIFF_ENGINE | source_lines, target_lines | Internal state |
| DIFF_ENGINE | compute_lcs, compute_edit_script | Algorithm internals |
| DIFF_RENDERER | render_*_line | Line-level helpers |
| PATCH_APPLIER | clear_state, apply_hunks, verify_hunk_context | Implementation |

## Dependency Metrics

| Metric | Value |
|--------|-------|
| External libraries | 2 (base, time) |
| Internal classes | 7 |
| Test classes | 1 |
| Circular dependencies | 0 |
| Max dependency depth | 4 (SD→DE→DR→DH→DL) |

## Dependency Quality Assessment

### Strengths

1. **Minimal external dependencies** - Only EiffelBase required
2. **No circular dependencies** - Clean hierarchy
3. **Clear layering** - Facade → Engine → Data
4. **Good encapsulation** - Internal features properly hidden

### Concerns

1. **Tight coupling** - Engine directly creates data classes
2. **No interfaces** - Concrete class dependencies throughout
3. **Feature export** - Some internal features exposed wider than needed

## Potential Improvements

### Decouple with Interfaces

```eiffel
deferred class DIFF_RESULT_INTERFACE
feature
    is_identical: BOOLEAN deferred end
    has_changes: BOOLEAN deferred end
    hunks: LIST [DIFF_HUNK_INTERFACE] deferred end
end
```

### Factory Pattern for Creation

```eiffel
class DIFF_FACTORY
feature
    new_line_context (...): DIFF_LINE
    new_line_added (...): DIFF_LINE
    new_hunk (...): DIFF_HUNK
    new_result: DIFF_RESULT
end
```

## Build Order

Due to dependencies, classes must compile in this order:

1. DIFF_LINE (no internal dependencies)
2. DIFF_HUNK (depends on DIFF_LINE)
3. DIFF_RESULT (depends on DIFF_HUNK)
4. DIFF_ENGINE (depends on DIFF_RESULT, DIFF_HUNK, DIFF_LINE)
5. DIFF_RENDERER (depends on DIFF_RESULT, DIFF_HUNK, DIFF_LINE)
6. PATCH_APPLIER (depends on DIFF_RESULT, DIFF_HUNK, DIFF_LINE)
7. SIMPLE_DIFF (depends on all above)

## Next Steps

→ S07-COMPILE-SPEC.md

---

*Dependencies analyzed: 2026-01-18*
*Generated by spec-extraction workflow S06*
