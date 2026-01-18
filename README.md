<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_diff

**[Documentation](https://simple-eiffel.github.io/simple_diff/)** | **[GitHub](https://github.com/simple-eiffel/simple_diff)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()
[![Built with simple_codegen](https://img.shields.io/badge/Built_with-simple__codegen-blueviolet.svg)](https://github.com/simple-eiffel/simple_code)

<!-- TODO: Add one-line description of what this library does -->

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Development** - Initial release

## Overview

<!-- TODO: Describe what this library does and why it's useful -->

## Features

<!-- TODO: List key features as bullet points -->
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

```eiffel
local
    l_obj: SIMPLE_DIFF
do
    create l_obj.make
    -- TODO: Add usage example
end
```

## API Reference

<!-- TODO: Document main features -->

| Feature | Description |
|---------|-------------|
| `make` | Create instance |

## Dependencies

- EiffelBase only (or list other simple_* dependencies)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix