# bend-u64: a 64-bit unsigned integer in pure Bend, backed by one 64-bit word.
# Source: https://github.com/phenomenon0/bend-u64
#
# No compiler change is involved: the runtime word is 64-bit (u64), `Word(64n)`
# is a Base builtin, and U64 is a plain wrapper in the same shape as Base's own
# F64. All operations are width-64 instantiations of Base's width-generic
# `Word.*` layer. The commutation law is instantiated from Base's own generic
# inductive lemma `Word.add_comm(64n, ...)` — the same theorem U32 uses at 32.
#
# Boundaries, stated honestly:
#   - `to_nat` is valid while the value fits a Nat immediate (<= 2^48-1);
#     wider values are legal U64s and compare in word space (`cmp`/`is_*`).
#   - `shl.n`/`shr.n` are bit-at-a-time folds (n small); they are O(n).
#   - No FFI, no intrinsics, no unsafe; checked on stock Bend 2.0.17.
import Base

type U64 is Data:
  U64{data: Word(64n)}

# -- constructors ------------------------------------------------------------

def zero() -> U64:
  U64{Word.zero(64n)}

def one() -> U64:
  U64{Word.inc(64n, Word.zero(64n))}

def max() -> U64:
  U64{Word.not(64n, Word.zero(64n))}

# -- arithmetic --------------------------------------------------------------

def add(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.add(64n, x, y)}

def sub(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.sub(64n, x, y)}

def mul(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.mul(64n, x, y)}

def inc(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.inc(64n, x)}

# -- logic -------------------------------------------------------------------

def and(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.and(64n, x, y)}

def or(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.or(64n, x, y)}

def xor(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.xor(64n, x, y)}

def not(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.not(64n, x)}

# -- shifts (bit-at-a-time; n-fold for the .n forms) -------------------------

def shl(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.shl(64n, x)}

def shr(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.shr(64n, x)}

def shl.n(n: Nat, a: U64) -> U64:
  match n:
    case 0n: a
    case 1n+p: shl.n(p, shl(a))

def shr.n(n: Nat, a: U64) -> U64:
  match n:
    case 0n: a
    case 1n+p: shr.n(p, shr(a))

# -- comparison (word space; no Nat involved) --------------------------------

def cmp.eq(c: Cmp) -> Bool:
  match c:
    case EQ{}: True{}
    case LT{}: False{}
    case GT{}: False{}

def cmp.lt(c: Cmp) -> Bool:
  match c:
    case LT{}: True{}
    case EQ{}: False{}
    case GT{}: False{}

def cmp.gt(c: Cmp) -> Bool:
  match c:
    case GT{}: True{}
    case EQ{}: False{}
    case LT{}: False{}

def cmp(a: U64, b: U64) -> Cmp:
  match a b:
    case U64{x} U64{y}:
      Word.cmp(64n, x, y)

def is_eq(a: U64, b: U64) -> Bool:
  cmp.eq(cmp(a, b))

def is_lt(a: U64, b: U64) -> Bool:
  cmp.lt(cmp(a, b))

def is_gt(a: U64, b: U64) -> Bool:
  cmp.gt(cmp(a, b))

# -- Nat interop (valid while the value fits a Nat immediate, <= 2^48-1) -----

def to_nat(a: U64) -> Nat:
  match a:
    case U64{x}:
      Word.to_nat(64n, x)

# -- the law: width-64 instantiation of Base's generic lemma -----------------

law add_comm:
  for a: U64
  for b: U64
  {add(a, b) == add(b, a) : U64}

def add_comm(a, b):
  match a b:
    case U64{x} U64{y}:
      Equal.cong(Word(64n), U64, w => U64{w}, Word.add(64n, x, y),
        Word.add(64n, y, x), Word.add_comm(64n, x, y))
