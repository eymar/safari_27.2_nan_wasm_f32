;; JS -> Wasm f32 argument becomes NaN after a JS tail call (Safari 27.2 RC).
;;
;; Chain:  Wasm $trigger --calls import--> JS imp(x) --tail call--> Wasm $bitsOf(x: f32)
;;
;; $bitsOf returns the raw bits of its argument, so the page can see exactly what arrived.
;; $trigger keeps 8 i64 values live across the import call. Once $trigger is optimized, they occupy
;; callee-saved registers, including JSC's tag register; the JS->Wasm entry stub for the tail call
;; then reads that stale value (0xfffe000000000002) as numberTagRegister.
(module
  (import "m" "imp" (func $imp (param i32) (result i32)))

  (func (export "bitsOf") (param $x f32) (result i32)
    (i32.reinterpret_f32 (local.get $x)))

  ;; Separate mutable globals, so the compiler cannot merge the values or rebuild them from a constant.
  (global $g0 (mut i64) (i64.const 0xfffe000000000002))
  (global $g1 (mut i64) (i64.const 0xfffe000000000002))
  (global $g2 (mut i64) (i64.const 0xfffe000000000002))
  (global $g3 (mut i64) (i64.const 0xfffe000000000002))
  (global $g4 (mut i64) (i64.const 0xfffe000000000002))
  (global $g5 (mut i64) (i64.const 0xfffe000000000002))
  (global $g6 (mut i64) (i64.const 0xfffe000000000002))
  (global $g7 (mut i64) (i64.const 0xfffe000000000002))

  (func (export "trigger") (param $x i32) (result i32)
    (local $l0 i64) (local $l1 i64) (local $l2 i64) (local $l3 i64) (local $l4 i64) (local $l5 i64) (local $l6 i64) (local $l7 i64)
    ;; Load before the call ...
    (local.set $l0 (global.get $g0))
    (local.set $l1 (global.get $g1))
    (local.set $l2 (global.get $g2))
    (local.set $l3 (global.get $g3))
    (local.set $l4 (global.get $g4))
    (local.set $l5 (global.get $g5))
    (local.set $l6 (global.get $g6))
    (local.set $l7 (global.get $g7))
    (call $imp (local.get $x))
    ;; ... and use after it, so all eight stay live across the call.
    (global.set $g0 (local.get $l0))
    (global.set $g1 (local.get $l1))
    (global.set $g2 (local.get $l2))
    (global.set $g3 (local.get $l3))
    (global.set $g4 (local.get $l4))
    (global.set $g5 (local.get $l5))
    (global.set $g6 (local.get $l6))
    (global.set $g7 (local.get $l7))))
