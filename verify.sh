#!/usr/bin/env bash
# bend-u64 verify: strict check (laws, no holes) on package.bend; demo must
# agree byte-for-byte (empty lines ignored) on interpret, JS and C; then a
# mutation of U64.add must be REFUSED by the strict check.
set -uo pipefail
cd "$(dirname "$0")"
BEND=${BEND_TREE:-$HOME/Documents/Project/bend}
export BEND_NO_TELEMETRY=1
W=$(mktemp -d /tmp/bend-u64.XXXXXX)
trap 'rm -rf -- "$W"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL %s\n' "$1"; }

check_book() { # $1 = entry path; prints ok/refused
  bun -e '
    import * as B from "'"$BEND"'/bend2/bend.ts";
    const book = B.book_nil();
    await B.book_load(book, process.argv[1], "", new Map());
    B.book_valid(book);
    if (book.hols + book.open) { console.error("holes/open: " + (book.hols + book.open)); process.exit(1); }
    console.log("checked");
  ' "$1"
}

cat > "$W/expected" <<'EOF'
ok   wrap: (2^64-1)+1 == 0
ok   roundtrip: ((2^64-1)-1)+1 == 2^64-1
ok   mul wrap: (2^32)^2 == 0 (mod 2^64)
ok   shift: (1<<63)>>63 == 1
ok   cmp: 2^64-1 > 1
ok   logic: ~(max^max) == max
DEMO-END
EOF
sed -i '/^$/d' "$W/expected"

# 1. strict check of the package: laws verify, no holes
if check_book package.bend >/dev/null 2>"$W/check.err"; then ok "strict check: package.bend (laws, no holes)"; else bad "strict check"; head -14 "$W/check.err"; fi

# 2. interpret lane
if timeout 300 bun "$BEND/bend2/main.ts" demo.bend 2>"$W/interp.err" | sed '/^$/d' > "$W/interp" && diff -q "$W/expected" "$W/interp" >/dev/null; then ok "interpret lane"; else bad "interpret lane"; diff "$W/expected" "$W/interp" | head -8; head -6 "$W/interp.err"; fi

# 3. JS lane
if timeout 300 bun "$BEND/bend2/main.ts" demo.bend -o "$W/demo.js" 2>"$W/js.err" && timeout 120 bun "$W/demo.js" | sed '/^$/d' | diff -q "$W/expected" - >/dev/null; then ok "js lane"; else bad "js lane"; head -6 "$W/js.err"; fi

# 4. C lane
if timeout 300 bun "$BEND/bend2/main.ts" demo.bend -o "$W/demo.c" 2>"$W/c.err" && gcc -O2 -w "$W/demo.c" -o "$W/demo" -lm 2>>"$W/c.err" && timeout 120 "$W/demo" | sed '/^$/d' | diff -q "$W/expected" - >/dev/null; then ok "c lane"; else bad "c lane"; head -6 "$W/c.err"; fi

# 5. proof mutation: U64.add's body becomes subtraction; check must REFUSE
mkdir "$W/mut"
cp u64.bend package.bend "$W/mut/"
sed -i 's/U64{Word\.add(64n, x, y)}/U64{Word.sub(64n, x, y)}/' "$W/mut/u64.bend"
if cmp -s u64.bend "$W/mut/u64.bend"; then bad "mutation (sed did not fire)"; else
  if check_book "$W/mut/package.bend" >/dev/null 2>&1; then bad "mutation ACCEPTED (should be refused)"; else ok "mutated impl REFUSED by the checker"; fi
fi

echo
echo "bend-u64 verify: PASS $pass, FAIL $fail"
[ "$fail" -eq 0 ]
