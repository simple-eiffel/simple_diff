# D07-REFACTORING: simple_diff Design Audit

## Refactoring Guidance

This document provides detailed refactoring instructions for high-priority recommendations.

---

## REFACTORING 1: Add DIFF_ENGINE Invariant

### Location
`D:\prod\simple_diff\src\diff_engine.e`

### Current Code (end of class)
```eiffel
end -- class DIFF_ENGINE
```

### Target Code
```eiffel
invariant
    context_non_negative: context_lines >= 0

end -- class DIFF_ENGINE
```

### Steps
1. Open `diff_engine.e`
2. Navigate to end of class (before final `end`)
3. Add invariant clause
4. Compile and run tests

### Verification
- [ ] Compiles without errors
- [ ] All tests pass
- [ ] Invariant checked on object creation

---

## REFACTORING 2: Add PATCH_APPLIER Error Invariant

### Location
`D:\prod\simple_diff\src\patch_applier.e`

### Current Code
```eiffel
invariant
    rejected_hunks_not_void: rejected_hunks /= Void

end
```

### Target Code
```eiffel
invariant
    rejected_hunks_not_void: rejected_hunks /= Void
    error_consistency: has_error = (last_error /= Void)

end
```

### Steps
1. Open `patch_applier.e`
2. Navigate to invariant clause
3. Add error_consistency invariant
4. Verify `clear_state` maintains invariant
5. Compile and run tests

### Verification
- [ ] Compiles without errors
- [ ] All tests pass
- [ ] Invariant holds after clear_state
- [ ] Invariant holds after error occurs

### Potential Issue
Check that when `last_error` is set, `has_error` returns True:
```eiffel
has_error: BOOLEAN
    do
        Result := last_error /= Void  -- This should match invariant
    end
```

---

## REFACTORING 3: Strengthen compute_diff Postcondition

### Location
`D:\prod\simple_diff\src\diff_engine.e`

### Current Code
```eiffel
compute_diff: DIFF_RESULT
        -- Compute diff between source and target.
    require
        source_set: source_lines /= Void
        target_set: target_lines /= Void
    do
        -- ... implementation ...
    ensure
        result_not_void: Result /= Void
        identical_if_same: source_equals_target implies Result.is_identical
    end
```

### Target Code
```eiffel
compute_diff: DIFF_RESULT
        -- Compute diff between source and target.
    require
        source_set: source_lines /= Void
        target_set: target_lines /= Void
    do
        -- ... implementation ...
    ensure
        result_not_void: Result /= Void
        identical_if_same: source_equals_target implies Result.is_identical
        different_has_changes: not source_equals_target implies Result.has_changes
    end
```

### Steps
1. Open `diff_engine.e`
2. Add helper query `source_equals_target` if not exists:
```eiffel
feature {NONE} -- Implementation

    source_equals_target: BOOLEAN
            -- Do source and target have identical content?
        local
            i: INTEGER
        do
            if source_lines.count /= target_lines.count then
                Result := False
            else
                Result := True
                from i := 1 until i > source_lines.count or not Result loop
                    Result := source_lines [i].same_string (target_lines [i])
                    i := i + 1
                end
            end
        end
```
3. Add postcondition
4. Compile and run tests

### Verification
- [ ] Compiles without errors
- [ ] All tests pass
- [ ] Postcondition verified with different inputs
- [ ] Postcondition verified with identical inputs

---

## REFACTORING 4: Delegate Output to DIFF_RENDERER (Optional)

### Location
`D:\prod\simple_diff\src\diff_result.e`

### Current Code
```eiffel
to_unified: STRING
        -- Render as unified diff format.
    local
        i: INTEGER
    do
        create Result.make (1000)
        -- ... implementation duplicated from renderer ...
    end
```

### Target Code
```eiffel
to_unified: STRING
        -- Render as unified diff format.
    local
        l_renderer: DIFF_RENDERER
    do
        create l_renderer.make
        Result := l_renderer.render_unified (Current)
    ensure
        result_not_void: Result /= Void
    end
```

### Steps
1. Apply same pattern to `to_html`, `to_side_by_side`
2. Keep `to_json` as-is (not in renderer currently)
3. Compile and run tests

### Verification
- [ ] Output identical to before
- [ ] All tests pass
- [ ] No code duplication

---

## REFACTORING 5: Restrict DIFF_ENGINE Export (Optional)

### Location
`D:\prod\simple_diff\src\diff_engine.e`

### Current Code
```eiffel
feature -- Access

    set_source_from_string (s: STRING)
    set_target_from_string (s: STRING)
    compute_diff: DIFF_RESULT
```

### Target Code
```eiffel
feature {SIMPLE_DIFF} -- Restricted API

    set_source_from_string (s: STRING)
    set_target_from_string (s: STRING)
    compute_diff: DIFF_RESULT
```

### Steps
1. Change export clause from `ANY` to `{SIMPLE_DIFF}`
2. Verify only SIMPLE_DIFF uses these features
3. Compile and run tests

### Verification
- [ ] Compiles without errors
- [ ] All tests pass
- [ ] External code cannot call engine directly

### Breaking Change Warning
This restricts the API. Users who directly used DIFF_ENGINE will be affected.

---

## TEST VERIFICATION CHECKLIST

After each refactoring:

```bash
# Compile
/d/prod/ec.sh -batch -config simple_diff.ecf -target lib_tests -c_compile

# Run tests
./EIFGENs/lib_tests/W_code/lib_tests.exe
```

### Expected Results
- All 29 tests pass
- No new warnings
- Invariants don't fail

---

## ROLLBACK PLAN

If refactoring causes issues:

1. **Git revert**: `git checkout -- src/affected_file.e`
2. **Re-compile**: Full clean compile
3. **Verify**: All tests pass

---

## REFACTORING ORDER

For safety, apply in this order:

1. **R-001** (DIFF_ENGINE invariant) - Isolated, no API change
2. **R-002** (PATCH_APPLIER invariant) - Isolated, no API change
3. **R-003** (compute_diff postcondition) - May need helper query
4. **R-009** (Delegate output) - Internal change only
5. **R-005** (Restrict export) - Breaking change, do last

---

*Refactoring guide completed: 2026-01-18*
*Generated by design-audit workflow D07*
