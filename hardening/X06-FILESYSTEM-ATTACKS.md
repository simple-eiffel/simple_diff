# X06-FILESYSTEM-ATTACKS: simple_diff Hardening

## File System Attack Results

This document records results of file system adversarial testing.

---

## TEST CATEGORY: Path Traversal

### Test F-001: Relative Path Up
```eiffel
l_result := l_diff.diff_files ("../../../etc/passwd", "other.txt")
```
**Expected**: Path accepted (OS-level security)
**Result**: ✓ PASS - Eiffel doesn't prevent, OS handles
**Note**: Not a library responsibility

### Test F-002: Absolute Path
```eiffel
l_result := l_diff.diff_files ("/etc/passwd", "/etc/shadow")
```
**Expected**: Permission errors handled
**Result**: ✓ PASS - Reports error via has_error

### Test F-003: Windows UNC Path
```eiffel
l_result := l_diff.diff_files ("\\\\server\\share\\file.txt", "local.txt")
```
**Expected**: Handled by OS
**Result**: ⚠ UNTESTED on Windows network

---

## TEST CATEGORY: File Existence

### Test F-004: Source Not Found
```eiffel
l_result := l_diff.diff_files ("nonexistent.txt", "exists.txt")
```
**Expected**: has_error = True, descriptive message
**Result**: ✓ PASS

### Test F-005: Target Not Found
```eiffel
l_result := l_diff.diff_files ("exists.txt", "nonexistent.txt")
```
**Expected**: has_error = True
**Result**: ✓ PASS

### Test F-006: Both Not Found
```eiffel
l_result := l_diff.diff_files ("missing1.txt", "missing2.txt")
```
**Expected**: has_error = True, first error reported
**Result**: ✓ PASS

### Test F-007: Directory Instead of File
```eiffel
l_result := l_diff.diff_files ("some_directory", "file.txt")
```
**Expected**: Error or read directory as empty
**Result**: ⚠ VULNERABLE - May fail unexpectedly
**Note**: No explicit directory check

---

## TEST CATEGORY: File Permissions

### Test F-008: Read Permission Denied
```eiffel
-- File with no read permission
l_result := l_diff.diff_files ("no_read.txt", "readable.txt")
```
**Expected**: has_error = True
**Result**: ✓ PASS - OS error caught

### Test F-009: Write Permission Denied (Patch)
```eiffel
l_applier.apply (l_diff_result, "no_write.txt")
```
**Expected**: has_error = True
**Result**: ✓ PASS - OS error caught

### Test F-010: Create Permission Denied (Reject File)
```eiffel
l_applier.write_reject_file ("read_only_dir/file")
```
**Expected**: Error handled
**Result**: ⚠ MAY CRASH - No explicit permission check

---

## TEST CATEGORY: File Content Modification

### Test F-011: File Modified During Diff
```eiffel
-- Simulated: file changes between read operations
l_result := l_diff.diff_files (file1, file2)
-- file1 changed mid-operation
```
**Expected**: Consistent snapshot
**Result**: ⚠ VULNERABLE - No file locking
**Impact**: Inconsistent results possible

### Test F-012: File Modified During Patch
```eiffel
l_applier.apply (diff, "target.txt")
-- target.txt modified by another process
```
**Expected**: Context mismatch detected
**Result**: ⚠ PARTIAL - Context check helps but not atomic
**Impact**: Race condition possible

---

## TEST CATEGORY: Special Files

### Test F-013: Symlink to File
```eiffel
l_result := l_diff.diff_files ("symlink_to_file", "regular.txt")
```
**Expected**: Follows symlink
**Result**: ✓ PASS - OS handles symlinks

### Test F-014: Symlink Loop
```eiffel
-- symlink points to itself
l_result := l_diff.diff_files ("loop_symlink", "file.txt")
```
**Expected**: Error or handled
**Result**: ⚠ UNTESTED - OS-dependent behavior

### Test F-015: Device File
```eiffel
l_result := l_diff.diff_files ("/dev/null", "file.txt")
```
**Expected**: Empty source
**Result**: ⚠ PLATFORM-SPECIFIC

### Test F-016: Named Pipe/FIFO
```eiffel
l_result := l_diff.diff_files ("named_pipe", "file.txt")
```
**Expected**: Block or error
**Result**: ⚠ UNTESTED

---

## TEST CATEGORY: File Size

### Test F-017: Empty File
```eiffel
l_result := l_diff.diff_files ("empty.txt", "content.txt")
```
**Expected**: All additions
**Result**: ✓ PASS

### Test F-018: Large File
```eiffel
l_result := l_diff.diff_files ("100mb.txt", "100mb_modified.txt")
```
**Expected**: Slow but handles
**Result**: ⚠ VERY SLOW - Full file load, O(N*M) diff

### Test F-019: File Larger Than Memory
```eiffel
l_result := l_diff.diff_files ("1gb.txt", "1gb_modified.txt")
```
**Expected**: OOM or error
**Result**: ⚠ CRASH - No size limit

---

## TEST CATEGORY: Path Edge Cases

### Test F-020: Very Long Path
```eiffel
l_path := create_path (260)  -- Windows MAX_PATH
l_result := l_diff.diff_files (l_path, "short.txt")
```
**Expected**: OS limit honored
**Result**: ⚠ OS-DEPENDENT

### Test F-021: Unicode Path
```eiffel
l_result := l_diff.diff_files ("文件.txt", "файл.txt")
```
**Expected**: Handle unicode filenames
**Result**: ⚠ PLATFORM-SPECIFIC

### Test F-022: Whitespace in Path
```eiffel
l_result := l_diff.diff_files ("file with spaces.txt", "other file.txt")
```
**Expected**: Handles correctly
**Result**: ✓ PASS

---

## ATTACK SUMMARY

| Category | Tests | Pass | Fail | Vulnerable |
|----------|-------|------|------|------------|
| Path Traversal | 3 | 2 | 0 | 1 |
| File Existence | 4 | 3 | 0 | 1 |
| Permissions | 3 | 2 | 0 | 1 |
| Modification | 2 | 0 | 0 | 2 |
| Special Files | 4 | 1 | 0 | 3 |
| File Size | 3 | 1 | 0 | 2 |
| Path Edge Cases | 3 | 1 | 0 | 2 |
| **Total** | **22** | **10** | **0** | **12** |

---

## VULNERABILITIES FOUND

### V-010: No Directory Check

**Severity**: Low
**Location**: SIMPLE_DIFF.diff_files
**Issue**: No check if path is directory
**Impact**: Unclear error message

**Recommendation**:
```eiffel
require
    source_is_file: (create {PLAIN_TEXT_FILE}.make_with_name (a_path1)).exists
```

### V-011: No File Locking

**Severity**: Medium
**Location**: All file operations
**Issue**: Files can change during operation
**Impact**: Race conditions, inconsistent results

**Recommendation**: Document limitation or add optional locking

### V-012: No Size Limit

**Severity**: High
**Location**: SIMPLE_DIFF.diff_files
**Issue**: No file size validation
**Impact**: OOM with large files

**Recommendation**:
```eiffel
require
    source_size_ok: file_size (a_path1) < Max_file_size
    target_size_ok: file_size (a_path2) < Max_file_size
```

---

*File system attacks completed: 2026-01-18*
*Generated by maintenance-xtreme workflow X06*
