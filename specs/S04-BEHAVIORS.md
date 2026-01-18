# S04-BEHAVIORS: simple_diff

## Behavioral Specifications

This document describes the runtime behaviors observed in simple_diff through test analysis and code inspection.

## SIMPLE_DIFF Behaviors

### B-SD-001: Creation with Defaults
**Trigger**: `create l_diff.make`

**Expected Behavior**:
- `context_lines = 3` (default)
- `ignore_whitespace = False`
- `ignore_case = False`
- Internal engine created
- No error state

**Test Reference**: `test_creation`

### B-SD-002: Builder Pattern Configuration
**Trigger**: `l_diff.set_context_lines(5).set_ignore_whitespace(True)`

**Expected Behavior**:
- Each setter returns `Current` (self)
- Settings accumulate
- Order independent
- Can chain multiple settings

**Test Reference**: `test_facade_builder_pattern`

### B-SD-003: String Diffing
**Trigger**: `l_diff.diff_strings("hello%Nworld", "hello%Nearth")`

**Expected Behavior**:
- Lines split on `%N` (newline)
- Myers algorithm computes LCS
- Result contains hunks for changes
- Context lines included per `context_lines` setting

**Test Reference**: `test_facade_diff_strings`

### B-SD-004: Identical String Detection
**Trigger**: `l_diff.diff_strings("same", "same")`

**Expected Behavior**:
- `Result.is_identical = True`
- `Result.has_changes = False`
- `Result.hunks.is_empty`

**Test Reference**: `test_facade_identical_strings`

### B-SD-005: File Diffing
**Trigger**: `l_diff.diff_files("a.txt", "b.txt")`

**Expected Behavior**:
- Files read from disk
- Content compared as strings
- Paths stored in result
- Error set if file not found

### B-SD-006: Error State
**Trigger**: File operation fails

**Expected Behavior**:
- `has_error = True`
- `last_error` contains message
- Result may be empty/partial
- `clear_error` resets state

---

## DIFF_ENGINE Behaviors

### B-DE-001: LCS Computation
**Trigger**: `engine.compute_diff`

**Expected Behavior**:
- Dynamic programming table computed
- O(N*M) time complexity
- O(N*M) space complexity
- Identifies longest common subsequence

### B-DE-002: Edit Script Generation
**Trigger**: Internal after LCS

**Expected Behavior**:
- Backtrack through DP table
- Generate insert/delete/match operations
- Minimal edit distance path

### B-DE-003: Hunk Building
**Trigger**: Internal after edit script

**Expected Behavior**:
- Changes grouped into contiguous hunks
- Context lines added (per `context_lines`)
- Adjacent hunks merged if context overlaps

### B-DE-004: Identical Sources
**Trigger**: `engine.compute_diff` with equal inputs

**Expected Behavior**:
- LCS equals entire input
- No edit operations
- Empty hunk list
- `Result.is_identical = True`

**Test Reference**: `test_engine_identical_strings`

### B-DE-005: Addition Detection
**Trigger**: Target has lines not in source

**Expected Behavior**:
- Lines marked as `Status_added`
- `target_line_number` set
- `source_line_number = 0`
- Added to hunk

**Test Reference**: `test_engine_addition`

### B-DE-006: Deletion Detection
**Trigger**: Source has lines not in target

**Expected Behavior**:
- Lines marked as `Status_removed`
- `source_line_number` set
- `target_line_number = 0`
- Added to hunk

**Test Reference**: `test_engine_deletion`

---

## DIFF_RESULT Behaviors

### B-DR-001: Empty Result
**Trigger**: `create l_result.make`

**Expected Behavior**:
- `is_identical = True`
- `has_changes = False`
- `hunk_count = 0`
- `line_count = 0`
- No paths set

**Test Reference**: `test_diff_result_empty`

### B-DR-002: Path Assignment
**Trigger**: `make_with_paths("src.txt", "dst.txt")`

**Expected Behavior**:
- `source_path = "src.txt"`
- `target_path = "dst.txt"`
- Paths appear in unified output header

**Test Reference**: `test_diff_result_with_hunks`

### B-DR-003: Hunk Accumulation
**Trigger**: `result.add_hunk(hunk)`

**Expected Behavior**:
- Hunk appended to list
- `is_identical` becomes False
- `hunk_count` increments
- Statistics update

### B-DR-004: Statistics Aggregation
**Trigger**: Access `additions_total`, `deletions_total`

**Expected Behavior**:
- Sum across all hunks
- Computed on access (not cached)
- Accurate after hunk changes

---

## DIFF_HUNK Behaviors

### B-DH-001: Hunk Creation
**Trigger**: `create l_hunk.make(5, 7)`

**Expected Behavior**:
- `source_start = 5`
- `target_start = 7`
- `source_count = 0`
- `target_count = 0`
- Empty lines list

**Test Reference**: `test_diff_hunk_creation`

### B-DH-002: Context Line Addition
**Trigger**: `hunk.add_context_line("text", 5, 7)`

**Expected Behavior**:
- Line added with `is_context = True`
- `source_count` increments
- `target_count` increments
- Both line numbers recorded

**Test Reference**: `test_diff_hunk_add_lines`

### B-DH-003: Added Line Addition
**Trigger**: `hunk.add_added_line("new text", 8)`

**Expected Behavior**:
- Line added with `is_added = True`
- `target_count` increments
- `source_count` unchanged
- Only target line number recorded

### B-DH-004: Removed Line Addition
**Trigger**: `hunk.add_removed_line("old text", 6)`

**Expected Behavior**:
- Line added with `is_removed = True`
- `source_count` increments
- `target_count` unchanged
- Only source line number recorded

### B-DH-005: Header Generation
**Trigger**: `hunk.header`

**Expected Behavior**:
- Format: `@@ -source_start,source_count +target_start,target_count @@`
- Example: `@@ -5,3 +7,4 @@`
- Starts with `@@ -`
- Ends with ` @@`

**Test Reference**: `test_diff_hunk_header`

---

## DIFF_LINE Behaviors

### B-DL-001: Context Line
**Trigger**: `create l_line.make_context("text", 5, 5)`

**Expected Behavior**:
- `is_context = True`
- `is_added = False`
- `is_removed = False`
- `prefix_char = ' '` (space)
- Both line numbers valid

**Test Reference**: `test_diff_line_context`

### B-DL-002: Added Line
**Trigger**: `create l_line.make_added("new", 10)`

**Expected Behavior**:
- `is_added = True`
- `is_context = False`
- `is_removed = False`
- `prefix_char = '+'`
- `source_line_number = 0`

**Test Reference**: `test_diff_line_added`

### B-DL-003: Removed Line
**Trigger**: `create l_line.make_removed("old", 7)`

**Expected Behavior**:
- `is_removed = True`
- `is_context = False`
- `is_added = False`
- `prefix_char = '-'`
- `target_line_number = 0`

**Test Reference**: `test_diff_line_removed`

### B-DL-004: String Formatting
**Trigger**: `line.to_string`

**Expected Behavior**:
- Prefix character prepended
- Content follows
- Example: `+new line content`

---

## DIFF_RENDERER Behaviors

### B-RN-001: Unified Format
**Trigger**: `renderer.render_unified(result)`

**Expected Behavior**:
- `--- source_path` header
- `+++ target_path` header
- Hunk headers with @@ markers
- Lines with +/-/space prefixes

**Test Reference**: `test_renderer_unified`

### B-RN-002: HTML Format
**Trigger**: `renderer.render_html(result)`

**Expected Behavior**:
- Full HTML document
- CSS classes for styling
- `.diff-add` for additions (green)
- `.diff-del` for deletions (red)
- `.diff-context` for unchanged

**Test Reference**: `test_renderer_html`

### B-RN-003: Side-by-Side Format
**Trigger**: `renderer.render_side_by_side(result)`

**Expected Behavior**:
- Two column layout
- Source on left, target on right
- `|` separator for context
- `<` for removed lines
- `>` for added lines

**Test Reference**: `test_renderer_side_by_side`

### B-RN-004: Colored Console
**Trigger**: `renderer.render_colored(result)`

**Expected Behavior**:
- ANSI escape codes embedded
- Green for additions
- Red for deletions
- Cyan for headers
- Magenta for hunk headers

**Test Reference**: `test_renderer_colored`

---

## PATCH_APPLIER Behaviors

### B-PA-001: Creation
**Trigger**: `create l_applier.make`

**Expected Behavior**:
- `dry_run = False`
- `reverse = False`
- `has_error = False`
- `has_rejects = False`

**Test Reference**: `test_patch_applier_creation`

### B-PA-002: String Patch Application
**Trigger**: `applier.apply_to_string(diff, content)`

**Expected Behavior**:
- Content transformed according to diff
- Returns new string
- Original unchanged
- Rejects tracked if context mismatch

**Test Reference**: `test_patch_apply_to_string`

### B-PA-003: Dry Run Mode
**Trigger**: `applier.set_dry_run(True)`

**Expected Behavior**:
- File not modified
- Result computed
- Rejects still tracked
- Useful for preview

**Test Reference**: `test_patch_applier_dry_run`

### B-PA-004: Reverse Mode
**Trigger**: `applier.set_reverse(True)`

**Expected Behavior**:
- Additions become removals
- Removals become additions
- Effectively unapplies patch

**Test Reference**: `test_patch_applier_reverse`

### B-PA-005: Context Verification
**Trigger**: Internal during apply

**Expected Behavior**:
- Context lines must match file
- Mismatch causes hunk rejection
- Rejected hunks collected
- Partial application possible

### B-PA-006: Reject File Generation
**Trigger**: `applier.write_reject_file("file.txt")`

**Expected Behavior**:
- Creates `file.txt.rej`
- Contains failed hunks in unified format
- Can be manually applied later

---

## Edge Case Behaviors

### B-EC-001: Empty Strings
**Trigger**: `diff_strings("", "")`

**Expected Behavior**:
- `is_identical = True`
- No hunks generated

**Test Reference**: `test_empty_strings`

### B-EC-002: Empty to Content
**Trigger**: `diff_strings("", "content")`

**Expected Behavior**:
- All target lines are additions
- `additions_total = line_count`

**Test Reference**: `test_one_empty_string`

### B-EC-003: Content to Empty
**Trigger**: `diff_strings("content", "")`

**Expected Behavior**:
- All source lines are deletions
- `deletions_total = line_count`

**Test Reference**: `test_one_empty_string`

### B-EC-004: Single Line Change
**Trigger**: `diff_strings("abc", "xyz")`

**Expected Behavior**:
- One hunk with 1 deletion + 1 addition

**Test Reference**: `test_single_line_change`

### B-EC-005: Complex Multi-Line
**Trigger**: Multiple scattered changes

**Expected Behavior**:
- May generate multiple hunks
- Or single merged hunk if close together
- Depends on `context_lines` setting

**Test Reference**: `test_multiline_complex`

---

## Behavior Coverage

| Class | Behaviors Documented | Test Coverage |
|-------|---------------------|---------------|
| SIMPLE_DIFF | 6 | 4 |
| DIFF_ENGINE | 6 | 4 |
| DIFF_RESULT | 4 | 3 |
| DIFF_HUNK | 5 | 3 |
| DIFF_LINE | 4 | 3 |
| DIFF_RENDERER | 4 | 4 |
| PATCH_APPLIER | 6 | 4 |
| Edge Cases | 5 | 5 |
| **Total** | **40** | **30** |

## Next Steps

→ S05-EDGE-CASES.md

---

*Behaviors extracted: 2026-01-18*
*Generated by spec-extraction workflow S04*
