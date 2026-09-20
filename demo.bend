import Base
import ./u64.bend as U64

# The demo: six word-space checks, no Nat above 2^48, identical output on
# every lane (interpret, JS, C). Prints ok/FAIL lines and DEMO-END.

def maxv() -> U64.U64:
  U64.max()

def onev() -> U64.U64:
  U64.one()

def zerov() -> U64.U64:
  U64.zero()

def p32v() -> U64.U64:
  U64.shl.n(32n, U64.one())

def t1() -> Bool:
  U64.is_eq(U64.inc(maxv()), zerov())

def t2() -> Bool:
  U64.is_eq(U64.inc(U64.sub(maxv(), onev())), maxv())

def t3() -> Bool:
  U64.is_eq(U64.mul(p32v(), p32v()), zerov())

def t4() -> Bool:
  U64.is_eq(U64.shr.n(63n, U64.shl.n(63n, onev())), onev())

def t5() -> Bool:
  U64.is_gt(maxv(), onev())

def t6() -> Bool:
  U64.is_eq(U64.not(U64.xor(maxv(), maxv())), maxv())

def pass(b: Bool, msg: String) -> String:
  match b:
    case True{}: String.append("ok   ", msg)
    case False{}: String.append("FAIL ", msg)

def line(b: Bool, msg: String) -> IO(Unit):
  IO.print(String.append(pass(b, msg), "\n"))

def main() -> IO(Unit):
  do IO<Unit>:
    a : Unit <- line(t1(), "wrap: (2^64-1)+1 == 0")
    b : Unit <- line(t2(), "roundtrip: ((2^64-1)-1)+1 == 2^64-1")
    c : Unit <- line(t3(), "mul wrap: (2^32)^2 == 0 (mod 2^64)")
    d : Unit <- line(t4(), "shift: (1<<63)>>63 == 1")
    e : Unit <- line(t5(), "cmp: 2^64-1 > 1")
    f : Unit <- line(t6(), "logic: ~(max^max) == max")
    IO.print("DEMO-END\n")
