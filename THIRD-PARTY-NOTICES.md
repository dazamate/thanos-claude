# Third-party notices

This repo includes material from other projects. Their licenses apply to that material.

## sgaabdu4/claude-code-tips (MIT)

The hooks in `home/dot_claude/hooks/` named `cbm-*`, `bash-ban-raw-tools.sh` and `test-runner-nudge.sh` are adapted from https://github.com/sgaabdu4/claude-code-tips, under this license:

```
MIT License

Copyright (c) 2026 Abid Gafoor

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Vendored installers

The files in `vendor/` are unmodified copies of each project's installer, kept for review and checksum-verified installs:

| File | Project | License |
|---|---|---|
| `vendor/chezmoi-install.sh` | https://github.com/twpayne/chezmoi (v2.73.1) | MIT, Copyright (c) 2018 Tom Payne |
| `vendor/cbm-install.sh` | https://github.com/DeusData/codebase-memory-mcp (v0.12.1) | MIT, Copyright (c) 2025 DeusData |
| `vendor/rtk-install.sh` | https://github.com/rtk-ai/rtk (v1.0.1) | Apache-2.0 |

`home/dot_claude/RTK.md` is the text `rtk init -g` writes (RTK 1.0.1, Apache-2.0).
