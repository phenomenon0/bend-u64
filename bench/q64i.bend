import Base
import ./i64.bend as I64

def loop.i64(n: Nat, acc: I64.I64) -> I64.I64:
  match n:
    case 0n: acc
    case 1n+p: loop.i64(p, I64.inc(acc))

def main() -> IO(Unit):
  do IO<Unit>:
    a : I64.I64 = loop.i64(10000000n, I64.zero())
    u : Unit <- IO.print(String.append("i64 sum: ", String.append(Nat.show(I64.to_nat(a)), "\n")))
    IO.print("QI64-END\n")
