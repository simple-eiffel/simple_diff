<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_diff

**[Documentation](https://simple-eiffel.github.io/simple_diff/)** | **[GitHub](https://github.com/simple-eiffel/simple_diff)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()
[![Built with simple_codegen](https://img.shields.io/badge/Built_with-simple__codegen-blueviolet.svg)](https://github.com/simple-eiffel/simple_code)

Text differencing library implementing Myers diff algorithm. Compares strings, files, and directories with support for unified diff, side-by-side, HTML output, and patch application.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Phase 1** - Core functionality complete (29 tests passing)

## Overview

`simple_diff` provides a complete text differencing solution for Eiffel applications:

- **Compute diffs** between strings, files, or entire directories
- **Multiple output formats**: unified diff, side-by-side, HTML, colored console
- **Patch application**: apply, reverse, or dry-run patches
- **Builder pattern API** for fluent configuration

## Features

- **Myers Diff Algorithm** - Produces minimal edit scripts via LCS
- **String/File/Directory Diffing** - Compare any text source
- **Multiple Renderers** - Unified, side-by-side, HTML, ANSI colored
- **Patch Operations** - Apply, reverse, dry-run with reject file support
- **Design by Contract** - Full preconditions, postconditions, invariants
- **Void Safe** - Fully void-safe implementation
- **SCOOP Compatible** - Ready for concurrent use

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```bash
export SIMPLE_EIFFEL=D:\prod
```

2. Add to your ECF:
```xml
<library name="simple_diff" location="$SIMPLE_EIFFEL/simple_diff/simple_diff.ecf"/>
```

## Quick Start

### Basic String Diff
```eiffel
local
    l_diff: SIMPLE_DIFF
    l_result: DIFF_RESULT
do
    create l_diff.make
    l_result := l_diff.diff_strings ("hello%Nworld", "hello%Nearth")

    if l_result.has_changes then
        print (l_result.to_unified)  -- Unified diff output
    end
end
```

### File Comparison
```eiffel
local
    l_diff: SIMPLE_DIFF
    l_result: DIFF_RESULT
do
    create l_diff.make
    l_result := l_diff.diff_files ("old_version.txt", "new_version.txt")
    print (l_result.to_html)  -- HTML formatted diff
end
```

### Builder Pattern Configuration
```eiffel
local
    l_diff: SIMPLE_DIFF
do
    create l_diff.make
    l_diff.set_context_lines (5)
         .set_ignore_whitespace (True)
         .set_ignore_case (True)
end
```

### Patch Application
```eiffel
local
    l_diff: SIMPLE_DIFF
    l_result: DIFF_RESULT
do
    create l_diff.make
    l_result := l_diff.diff_files ("old.txt", "new.txt")

    -- Apply patch to another file
    l_diff.apply_patch (l_result, "target.txt")

    -- Or dry-run first
    print (l_diff.apply_patch_dry_run (l_result, "target.txt"))
end
```

## API Reference

### SIMPLE_DIFF (Facade)

| Feature | Description |
|---------|-------------|
| `make` | Create with default settings (3 context lines) |
| `set_context_lines (n)` | Set context lines around changes |
| `set_ignore_whitespace (b)` | Ignore whitespace differences |
| `set_ignore_case (b)` | Ignore case differences |
| `diff_strings (s, t)` | Compare two strings |
| `diff_files (p1, p2)` | Compare two files |
| `diff_directories (d1, d2)` | Compare directories recursively |
| `apply_patch (diff, file)` | Apply a diff to a file |
| `apply_patch_dry_run (diff, file)` | Preview patch result |
| `reverse_patch (diff, file)` | Unapply a patch |

### DIFF_RESULT

| Feature | Description |
|---------|-------------|
| `is_identical` | True if no differences |
| `has_changes` | True if differences exist |
| `hunk_count` | Number of change hunks |
| `additions_total` | Total added lines |
| `deletions_total` | Total deleted lines |
| `to_unified` | Render as unified diff |
| `to_side_by_side (width)` | Render side-by-side |
| `to_html` | Render as HTML |
| `to_json` | Render as JSON |

### Classes

| Class | Purpose |
|-------|---------|
| `SIMPLE_DIFF` | Facade - main entry point |
| `DIFF_ENGINE` | Myers algorithm implementation |
| `DIFF_RESULT` | Contains diff hunks and metadata |
| `DIFF_HUNK` | Single contiguous change block |
| `DIFF_LINE` | Single line with status |
| `DIFF_RENDERER` | Output formatting |
| `PATCH_APPLIER` | Patch application logic |

## Dependencies

- EiffelBase only (no external dependencies)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
