# D04-NAMING: simple_diff Design Audit

## Naming Convention Analysis

This document audits naming conventions in simple_diff against Eiffel standards.

---

## CLASS NAMING

### Assessment: ✓ Excellent

| Class | Convention | Assessment |
|-------|------------|------------|
| SIMPLE_DIFF | UPPER_SNAKE | ✓ Follows simple_* pattern |
| DIFF_ENGINE | UPPER_SNAKE | ✓ Clear purpose |
| DIFF_RESULT | UPPER_SNAKE | ✓ Clear purpose |
| DIFF_HUNK | UPPER_SNAKE | ✓ Domain term |
| DIFF_LINE | UPPER_SNAKE | ✓ Clear purpose |
| DIFF_RENDERER | UPPER_SNAKE | ✓ Clear role |
| PATCH_APPLIER | UPPER_SNAKE | ✓ Clear role |
| LIB_TESTS | UPPER_SNAKE | ✓ Test convention |

**All classes follow Eiffel naming conventions.**

---

## FEATURE NAMING

### Creation Procedures ✓

| Feature | Assessment |
|---------|------------|
| `make` | ✓ Standard Eiffel |
| `make_with_paths` | ✓ Descriptive variant |
| `make_context` | ✓ Descriptive variant |
| `make_added` | ✓ Descriptive variant |
| `make_removed` | ✓ Descriptive variant |

### Query Naming ✓

| Feature | Assessment |
|---------|------------|
| `is_identical` | ✓ Boolean `is_` prefix |
| `is_context` | ✓ Boolean `is_` prefix |
| `is_added` | ✓ Boolean `is_` prefix |
| `is_removed` | ✓ Boolean `is_` prefix |
| `has_changes` | ✓ Boolean `has_` prefix |
| `has_error` | ✓ Boolean `has_` prefix |
| `has_rejects` | ✓ Boolean `has_` prefix |

### Command Naming ✓

| Feature | Assessment |
|---------|------------|
| `add_line` | ✓ Verb + noun |
| `add_hunk` | ✓ Verb + noun |
| `add_context_line` | ✓ Descriptive |
| `add_added_line` | ✓ Descriptive |
| `add_removed_line` | ✓ Descriptive |
| `apply` | ✓ Clear verb |
| `apply_patch` | ✓ Clear action |
| `reverse_patch` | ✓ Clear action |
| `clear_error` | ✓ Clear action |

### Configuration (Builder) Naming ✓

| Feature | Assessment |
|---------|------------|
| `set_context_lines` | ✓ `set_` prefix for setter |
| `set_ignore_whitespace` | ✓ `set_` prefix |
| `set_ignore_case` | ✓ `set_` prefix |
| `set_tab_width` | ✓ `set_` prefix |
| `set_line_width` | ✓ `set_` prefix |
| `set_use_color` | ✓ `set_` prefix |
| `set_dry_run` | ✓ `set_` prefix |
| `set_reverse` | ✓ `set_` prefix |

### Output Methods ✓

| Feature | Assessment |
|---------|------------|
| `to_unified` | ✓ `to_` for conversion |
| `to_side_by_side` | ✓ `to_` for conversion |
| `to_html` | ✓ `to_` for conversion |
| `to_json` | ✓ `to_` for conversion |
| `to_string` | ✓ `to_` for conversion |
| `render_unified` | ✓ Clear action |
| `render_html` | ✓ Clear action |
| `render_colored` | ✓ Clear action |

---

## ATTRIBUTE NAMING

### Public Attributes ✓

| Attribute | Assessment |
|-----------|------------|
| `content` | ✓ Noun |
| `status` | ✓ Noun |
| `source_line_number` | ✓ Descriptive |
| `target_line_number` | ✓ Descriptive |
| `source_start` | ✓ Descriptive |
| `target_start` | ✓ Descriptive |
| `source_count` | ✓ Descriptive |
| `target_count` | ✓ Descriptive |
| `lines` | ✓ Collection noun (plural) |
| `hunks` | ✓ Collection noun (plural) |
| `context_lines` | ✓ Descriptive |
| `ignore_whitespace` | ✓ Boolean attribute |
| `ignore_case` | ✓ Boolean attribute |
| `dry_run` | ✓ Boolean attribute |
| `reverse` | ✓ Boolean attribute |

### Private Attributes ✓

| Attribute | Assessment |
|-----------|------------|
| `engine` | ✓ Noun |
| `renderer` | ✓ Noun (role) |
| `applier` | ✓ Noun (role) |
| `source_lines` | ✓ Descriptive |
| `target_lines` | ✓ Descriptive |

---

## LOCAL VARIABLE NAMING

### Conventions Used ✓

| Pattern | Example | Assessment |
|---------|---------|------------|
| `l_` prefix | `l_diff`, `l_result` | ✓ Standard Eiffel |
| Descriptive | `l_col_width` | ✓ Clear purpose |
| Loop index | `i`, `j` | ✓ Acceptable for simple loops |

### Examples from Code

```eiffel
-- Good: descriptive locals
l_file: PLAIN_TEXT_FILE
l_lines: ARRAYED_LIST [STRING]
l_result_lines: ARRAYED_LIST [STRING]
l_content: STRING
l_hunk: DIFF_HUNK
l_line: DIFF_LINE
```

---

## CONSTANT NAMING

### Assessment: ✓ Good

| Constant | Assessment |
|----------|------------|
| `Status_context` | ✓ Capitalized |
| `Status_added` | ✓ Capitalized |
| `Status_removed` | ✓ Capitalized |
| `Op_match` | ✓ Capitalized |
| `Op_insert` | ✓ Capitalized |
| `Op_delete` | ✓ Capitalized |
| `Ansi_reset` | ✓ Capitalized |
| `Ansi_red` | ✓ Capitalized |
| `Ansi_green` | ✓ Capitalized |

---

## NAMING ISSUES FOUND

### Issue N-001: Inconsistent Boolean Attribute Names

**Location**: Various classes
**Issue**: Some booleans use `is_`/`has_` prefix, some don't

| Attribute | Current | Suggested |
|-----------|---------|-----------|
| `dry_run` | Attribute | Consider `is_dry_run` for consistency |
| `reverse` | Attribute | Consider `is_reversed` |
| `use_color` | Attribute | Consider `uses_color` or `is_colored` |

**Severity**: Low - current names are clear

### Issue N-002: Test Method Names

**Location**: LIB_TESTS
**Issue**: Some test names could be more descriptive

| Current | Suggested |
|---------|-----------|
| `test_creation` | `test_simple_diff_creation_with_defaults` |
| `test_empty_strings` | `test_diff_identical_empty_strings` |

**Severity**: Low - current names are acceptable

---

## DOMAIN VOCABULARY CONSISTENCY

### Diff Domain Terms ✓

| Term | Usage | Consistent |
|------|-------|------------|
| source | Original text | ✓ Throughout |
| target | Modified text | ✓ Throughout |
| hunk | Change block | ✓ Throughout |
| line | Single line | ✓ Throughout |
| context | Unchanged line | ✓ Throughout |
| added | New line | ✓ Throughout |
| removed | Deleted line | ✓ Throughout |
| patch | Applied diff | ✓ Throughout |
| unified | Standard format | ✓ Throughout |

---

## NAMING SCORE: 95/100

**Excellent**:
- Class names follow conventions
- Boolean queries use `is_`/`has_` prefix
- Commands use verb-first naming
- Conversion methods use `to_` prefix
- Setters use `set_` prefix
- Local variables use `l_` prefix
- Constants are capitalized

**Minor Issues**:
- Some boolean attributes could use `is_` prefix
- Test names could be more descriptive

---

*Naming audit completed: 2026-01-18*
*Generated by design-audit workflow D04*
