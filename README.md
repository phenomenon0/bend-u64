# bend-u64

**64-bit unsigned integers in pure Bend** — one `Word(64n)`, full-width
arithmetic, and a machine-checked commutation law at width 64. No FFI, no
hardware intrinsics, no `unsafe`, no compiler change.

```bend
import Base
import ./u64.bend as U64

def main() -> IO(Unit):
  do IO<Unit>:
    x : U64.U64 = U64.max()
    y : U64.U64 = U64.inc(x)          # wraps to 0: all 64 bits participate
    u : Unit <- IO.print(String.append(
      match U64.is_eq(y, U64.zero())
        case True{}: "wrap ok"
        case False{}: "wrap FAIL", "\n"))
    IO.print("done\n")
```

## Why it exists

Bend's native integer is `U32`; the runtime word is `u64`, and Base carries a
**width-generic** `Word(n)` layer (`add`, `sub`, `mul`, `and`, `or`, `xor`,
`not`, `shl`, `shr`, `cmp`, `adc`, …) whose **inductive lemma
`Word.add_comm(n, …)` holds at every width**. `U64` is the width-64
instantiation, in the same wrapper shape as Base's own `F64`:

```bend
type U64 is Data:
  U64{data: Word(64n)}
```

- `U64.add_comm` is proved by instantiating `Word.add_comm(64n, x, y)` — the
  same theorem `U32` uses at 32, no new induction.
- All arithmetic is width-64 `Word.*`; carry propagates through all 64 bits
  (`(2^64-1)+1 == 0`, `(2^32)^2 == 0 mod 2^64`).

## Honest boundaries

- `to_nat` is valid while the value fits a Nat immediate (**≤ 2^48−1**); wider
  values are legal `U64`s and compare in word space (`cmp`, `is_eq`, `is_lt`,
  `is_gt`). Comparisons never go through Nat.
- `shl.n` / `shr.n` are bit-at-a-time folds — O(n); the single-bit `shl`/`shr`
  are one `Word` op each.
- No division or formatted printing yet; those are future lanes.
- Checked with Bend 2.0.17. The Bend kernel, Base, compiler, C toolchain and
  CPU are trusted.

## API

`zero one max add sub mul inc and or xor not shl shr shl_n shr_n cmp
is_eq is_lt is_gt to_nat`

## Verify

```sh
./verify.sh          # strict check (laws) + interpret + JS + C + a proof mutation
```

The mutation step proves the law's witness is load-bearing: corrupting the
implementation makes the bundle refuse to check.

## BendHub

```sh
bend package.bend --publish
```

Publishing prints a content hash; import the package as
`import 0x<hash>/package.bend as U64` (proof-checked entry) or
`import 0x<hash>/u64.bend as U64` (implementation only).
