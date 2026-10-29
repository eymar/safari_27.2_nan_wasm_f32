## Summary

On iOS Safari 27.2 RC and 27.2, calling a Wasm export with an `f32` parameter via a strict-mode JS **tail
call**, from a JS function that was itself **called from Wasm**, delivers `NaN` (`0xffe00000`)
instead of `0.0`/`1.0` when the JS argument is the Int32 `0` or `1`. Other Int32 values (2, 1000,
negatives) and doubles arrive correctly; the same call not in tail position is always correct.
Regression between 27.2 beta and 27.2 RC.

Real-world impact: Kotlin/Wasm https://youtrack.jetbrains.com/issue/CMP-10986/WASM-rendering-only-white-page-on-iOS-27-and-macOS-27-RC#focus=Comments-27-14587015.0-0

## Reproduction

Files:

- `repro.wat`: the module (source of truth).
- `repro.wasm`: `wat2wasm repro.wat -o repro.wasm` (WABT).
- `index.html`: loads `repro.wasm`, runs the test, prints the result.

## Output on iOS 27.2

```
Before warm-up:
  x=0: non-tail call 0x00000000, tail call 0x00000000
  x=1: non-tail call 0x3f800000, tail call 0x3f800000
  x=2: non-tail call 0x40000000, tail call 0x40000000
  x=1000: non-tail call 0x447a0000, tail call 0x447a0000

After 100000 calls:
  x=0: non-tail call 0x00000000, tail call 0xffe00000  <-- WRONG
  x=1: non-tail call 0x3f800000, tail call 0xffe00000  <-- WRONG
  x=2: non-tail call 0x40000000, tail call 0x40000000
  x=1000: non-tail call 0x447a0000, tail call 0x447a0000
```
