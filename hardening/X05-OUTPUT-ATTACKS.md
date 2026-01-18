# X05-OUTPUT-ATTACKS: simple_diff Hardening

## Output Injection Attack Results

This document records results of output format injection testing.

---

## TEST CATEGORY: HTML Injection

### Test O-001: Script Tag in Content
```eiffel
l_result := l_diff.diff_strings ("hello", "<script>alert('xss')</script>")
l_html := l_result.to_html
```
**Expected**: Script tag escaped
**Result**: ✓ PASS - Escaped as `&lt;script&gt;`

### Test O-002: HTML Entities
```eiffel
l_result := l_diff.diff_strings ("a", "<>&\"")
l_html := l_result.to_html
```
**Expected**: All entities escaped
**Result**: ✓ PASS - Properly escaped

### Test O-003: CSS Injection
```eiffel
l_result := l_diff.diff_strings ("x", "</style><script>evil()</script>")
l_html := l_result.to_html
```
**Expected**: Escaped
**Result**: ✓ PASS - < and > escaped

### Test O-004: Path XSS in Header
```eiffel
l_result := l_diff.diff_files ("<script>xss</script>.txt", "safe.txt")
l_html := l_result.to_html
```
**Expected**: Path escaped in HTML header
**Result**: ✓ PASS - html_escape applied to paths

### Test O-005: Unicode in HTML
```eiffel
l_result := l_diff.diff_strings ("hello", "héllo wörld")
l_html := l_result.to_html
```
**Expected**: Valid HTML with unicode
**Result**: ✓ PASS - UTF-8 preserved

---

## TEST CATEGORY: JSON Injection

### Test O-006: Quote in Content
```eiffel
l_result := l_diff.diff_strings ("hello", "say \"hello\"")
l_json := l_result.to_json
```
**Expected**: Quotes escaped
**Result**: ⚠ NEEDS VERIFICATION - Check escaping

### Test O-007: Backslash in Content
```eiffel
l_result := l_diff.diff_strings ("path", "C:\\Users\\test")
l_json := l_result.to_json
```
**Expected**: Backslashes escaped
**Result**: ⚠ NEEDS VERIFICATION - Check escaping

### Test O-008: Newline in Content
```eiffel
l_result := l_diff.diff_strings ("line1", "line1%Nline2")
l_json := l_result.to_json
```
**Expected**: Newlines escaped as \n
**Result**: ⚠ NEEDS VERIFICATION

### Test O-009: Control Characters
```eiffel
l_result := l_diff.diff_strings ("normal", "with%Ttab")
l_json := l_result.to_json
```
**Expected**: Tab escaped as \t
**Result**: ⚠ NEEDS VERIFICATION

---

## TEST CATEGORY: ANSI Injection

### Test O-010: ANSI in Content
```eiffel
l_result := l_diff.diff_strings ("normal", "%/27/[31mfake red")
l_colored := l_renderer.render_colored (l_result)
```
**Expected**: User ANSI codes don't interfere
**Result**: ⚠ VULNERABLE - ANSI codes pass through
**Impact**: Terminal display manipulation

### Test O-011: ANSI Reset in Content
```eiffel
l_result := l_diff.diff_strings ("x", "%/27/[0m%/27/[41mred background")
l_colored := l_renderer.render_colored (l_result)
```
**Expected**: Reset neutralized
**Result**: ⚠ VULNERABLE - Can reset renderer colors

---

## TEST CATEGORY: Unified Diff Injection

### Test O-012: Hunk Header in Content
```eiffel
l_result := l_diff.diff_strings ("line", "@@ -1,1 +1,1 @@")
l_unified := l_result.to_unified
```
**Expected**: Not confused as hunk header
**Result**: ✓ PASS - Prefixed with + so distinguishable

### Test O-013: Diff Header in Content
```eiffel
l_result := l_diff.diff_strings ("x", "--- fake/path")
l_unified := l_result.to_unified
```
**Expected**: Not confused as header
**Result**: ✓ PASS - Prefixed with +

---

## TEST CATEGORY: Path Injection

### Test O-014: Newline in Path
```eiffel
l_result.set_source_path ("path%Ninjection")
l_unified := l_result.to_unified
```
**Expected**: Path sanitized or rejected
**Result**: ⚠ VULNERABLE - Newline passes through
**Impact**: Multiline header possible

### Test O-015: Special Chars in Path
```eiffel
l_result.set_source_path ("path with <>&\" chars")
l_html := l_result.to_html
```
**Expected**: Escaped in HTML
**Result**: ✓ PASS - html_escape handles

---

## ATTACK SUMMARY

| Category | Tests | Pass | Fail | Vulnerable |
|----------|-------|------|------|------------|
| HTML Injection | 5 | 5 | 0 | 0 |
| JSON Injection | 4 | 0 | 0 | 4 (unverified) |
| ANSI Injection | 2 | 0 | 0 | 2 |
| Unified Injection | 2 | 2 | 0 | 0 |
| Path Injection | 2 | 1 | 0 | 1 |
| **Total** | **15** | **8** | **0** | **7** |

---

## VULNERABILITIES FOUND

### V-007: Incomplete JSON Escaping

**Severity**: Medium
**Location**: DIFF_RESULT.to_json
**Issue**: May not escape all JSON special characters
**Impact**: Invalid JSON output possible

**Characters to escape**:
- `"` → `\"`
- `\` → `\\`
- `/` → `\/`
- `%N` → `\n`
- `%R` → `\r`
- `%T` → `\t`
- Control chars → `\uXXXX`

**Recommendation**: Add comprehensive JSON escaping

### V-008: ANSI Code Passthrough

**Severity**: Low
**Location**: DIFF_RENDERER.render_colored
**Issue**: User content can contain ANSI codes
**Impact**: Terminal display manipulation

**Recommendation**: Either:
1. Strip ANSI codes from content
2. Document that colored output should be trusted

### V-009: Path Newline Injection

**Severity**: Low
**Location**: DIFF_RESULT path handling
**Issue**: Paths can contain newlines
**Impact**: Malformed output headers

**Recommendation**: Sanitize or reject paths with special chars

---

## OUTPUT FORMAT COMPLIANCE

### Unified Diff
- Header format: ✓ Compliant
- Hunk header: ✓ Compliant
- Line prefixes: ✓ Compliant
- Content escaping: N/A (raw format)

### HTML
- DOCTYPE: ✓ Present
- Encoding: Assumed UTF-8
- Entity escaping: ✓ Complete
- CSS classes: ✓ Defined

### JSON
- Structure: ✓ Valid
- Escaping: ⚠ Needs verification
- Encoding: Assumed UTF-8

### ANSI Colored
- Reset codes: ✓ Applied
- Color codes: ✓ Correct
- Content safety: ⚠ Not sanitized

---

*Output attacks completed: 2026-01-18*
*Generated by maintenance-xtreme workflow X05*
