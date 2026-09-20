import Base
import ./u64.bend as U64

def loop.u64(n: Nat, acc: U64.U64) -> U64.U64:
  match n:
    case 0n: acc
    case 1n+p: loop.u64(p, U64.inc(acc))

def main() -> IO(Unit):
  do IO<Unit>:
    a : U64.U64 = loop.u64(10000000n, U64.zero())
    u : Unit <- IO.print(String.append("u64 sum: ", String.append(Nat.show(U64.to_nat(a)), "\n")))
    IO.print("Q64-END\n")
