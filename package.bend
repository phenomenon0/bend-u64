# bend-u64: package entry for BendHub.
# Source: https://github.com/phenomenon0/bend-u64
#
# 64-bit unsigned integers as one Word(64n), with U64.add_comm checked at 64
# by instantiating Base's own generic inductive lemma Word.add_comm(64n, ...).
# Pure Bend: no FFI, no intrinsics, no unsafe, no compiler change.
# Boundaries: to_nat holds while <= 2^48-1; shl.n/shr.n are O(n) folds.
import Base
import ./u64.bend as U64

def zero() -> U64.U64:
  U64.zero()

def one() -> U64.U64:
  U64.one()

def max() -> U64.U64:
  U64.max()

def add(a: U64.U64, b: U64.U64) -> U64.U64:
  U64.add(a, b)

def sub(a: U64.U64, b: U64.U64) -> U64.U64:
  U64.sub(a, b)

def mul(a: U64.U64, b: U64.U64) -> U64.U64:
  U64.mul(a, b)

def inc(a: U64.U64) -> U64.U64:
  U64.inc(a)

def and(a: U64.U64, b: U64.U64) -> U64.U64:
  U64.and(a, b)

def or(a: U64.U64, b: U64.U64) -> U64.U64:
  U64.or(a, b)

def xor(a: U64.U64, b: U64.U64) -> U64.U64:
  U64.xor(a, b)

def not(a: U64.U64) -> U64.U64:
  U64.not(a)

def shl(a: U64.U64) -> U64.U64:
  U64.shl(a)

def shr(a: U64.U64) -> U64.U64:
  U64.shr(a)

def shl_n(a: U64.U64, n: Nat) -> U64.U64:
  U64.shl.n(n, a)

def shr_n(a: U64.U64, n: Nat) -> U64.U64:
  U64.shr.n(n, a)

def cmp(a: U64.U64, b: U64.U64) -> Cmp:
  U64.cmp(a, b)

def is_eq(a: U64.U64, b: U64.U64) -> Bool:
  U64.is_eq(a, b)

def is_lt(a: U64.U64, b: U64.U64) -> Bool:
  U64.is_lt(a, b)

def is_gt(a: U64.U64, b: U64.U64) -> Bool:
  U64.is_gt(a, b)

def to_nat(a: U64.U64) -> Nat:
  U64.to_nat(a)
