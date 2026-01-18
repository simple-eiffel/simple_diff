# X01-RECONNAISSANCE: simple_diff Hardening

## Attack Surface Analysis

This document maps the attack surface of simple_diff for adversarial testing.

---

## ENTRY POINTS

### Primary Entry Points

| Entry Point | Class | Risk Level |
|-------------|-------|------------|
| `diff_strings (source, target)` | SIMPLE_DIFF | HIGH |
| `diff_files (path1, path2)` | SIMPLE_DIFF | HIGH |
| `diff_directories (dir1, dir2)` | SIMPLE_DIFF | MEDIUM |
| `apply_patch (diff, path)` | SIMPLE_DIFF | HIGH |
| `apply_to_string (diff, content)` | PATCH_APPLIER | MEDIUM |

### Secondary Entry Points

| Entry Point | Class | Risk Level |
|-------------|-------|------------|
| `render_unified (result)` | DIFF_RENDERER | LOW |
| `render_html (result)` | DIFF_RENDERER | MEDIUM |
| `to_json` | DIFF_RESULT | MEDIUM |
| `write_reject_file (path)` | PATCH_APPLIER | MEDIUM |

---

## INPUT VECTORS

### String Inputs

| Vector | Location | Description |
|--------|----------|-------------|
| Empty string | diff_strings | Zero-length input |
| Very long string | diff_strings | Memory pressure |
| Binary content | diff_strings | Null bytes, control chars |
| Unicode | diff_strings | Multi-byte characters |
| Special chars | diff_strings | Newlines, tabs, etc. |
| Malformed lines | diff_strings | Missing newline at end |

### File Path Inputs

| Vector | Location | Description |
|--------|----------|-------------|
| Non-existent path | diff_files | File not found |
| Directory path | diff_files | Not a file |
| Permission denied | diff_files | Cannot read |
| Very long path | diff_files | Path limit |
| Special characters | diff_files | Spaces, unicode |
| Relative path | diff_files | Path resolution |
| Symlink | diff_files | Following links |
| Locked file | apply_patch | Cannot write |

### Configuration Inputs

| Vector | Location | Description |
|--------|----------|-------------|
| Zero context | set_context_lines | Edge case |
| Very large context | set_context_lines | All lines as context |
| Negative (blocked) | set_context_lines | Precondition |

---

## STATE VECTORS

### Error State

| State | Description | Risk |
|-------|-------------|------|
| has_error = True | Previous error not cleared | Accumulated errors |
| rejected_hunks non-empty | Previous rejects | State pollution |

### Configuration State

| State | Description | Risk |
|-------|-------------|------|
| ignore_whitespace = True | Whitespace handling | Unexpected matches |
| ignore_case = True | Case handling | Unexpected matches |
| dry_run = True | No file modification | User confusion |
| reverse = True | Reverse semantics | Confusion |

---

## OUTPUT VECTORS

### Output Consumers

| Output | Consumer | Risk |
|--------|----------|------|
| Unified diff | External tools | Format compliance |
| HTML | Browser | XSS if content not escaped |
| JSON | Parser | JSON compliance |
| ANSI colored | Terminal | Control code injection |

### Output Edge Cases

| Case | Risk |
|------|------|
| Empty diff | Zero hunks |
| Very large diff | Memory/performance |
| Special chars in output | Escaping issues |

---

## RESOURCE VECTORS

### Memory

| Vector | Trigger | Risk |
|--------|---------|------|
| LCS table | Large files | O(N*M) space |
| Result storage | Many hunks | Accumulated objects |
| String building | Large output | String growth |

### File System

| Vector | Trigger | Risk |
|--------|---------|------|
| File read | diff_files | I/O errors |
| File write | apply_patch | I/O errors, permissions |
| Directory scan | diff_directories | Many files |

---

## TIMING VECTORS

| Vector | Trigger | Risk |
|--------|---------|------|
| LCS computation | O(ND) algorithm | Slow for many changes |
| Large file read | Big files | I/O wait |
| Directory traversal | Deep trees | Slow scan |

---

## ATTACK CATEGORIES

### Category 1: Input Validation Attacks
- Empty inputs
- Oversized inputs
- Invalid characters
- Malformed data

### Category 2: State Management Attacks
- Reuse after error
- Configuration confusion
- State pollution

### Category 3: Resource Exhaustion Attacks
- Memory exhaustion
- File handle exhaustion
- Performance degradation

### Category 4: Output Injection Attacks
- HTML injection
- JSON injection
- ANSI injection

### Category 5: File System Attacks
- Path traversal
- Permission issues
- Race conditions

---

## PRIORITY TARGETS

| Target | Priority | Reason |
|--------|----------|--------|
| diff_strings with edge cases | HIGH | Most used entry point |
| diff_files with bad paths | HIGH | File system interaction |
| apply_patch on modified files | HIGH | Write operations |
| render_html with special chars | MEDIUM | Security concern |
| Large file handling | MEDIUM | Resource concern |
| Error state accumulation | MEDIUM | Reliability concern |

---

## TEST PLAN OVERVIEW

1. **X02**: Input validation attacks
2. **X03**: State management attacks
3. **X04**: Resource exhaustion attacks
4. **X05**: Output injection attacks
5. **X06**: File system attacks
6. **X07**: Edge case attacks
7. **X08**: Recovery testing
8. **X09**: Chaos testing
9. **X10**: Verification

---

*Reconnaissance completed: 2026-01-18*
*Generated by maintenance-xtreme workflow X01*
