#!/usr/bin/env bash
# ==============================================================
#  scripts/build-crackmes.sh — compile the crackme challenge pack
#  Runs INSIDE the image (build time). Sources ship in
#  /usr/share/netmask/crackmes/<tier>/crackmeNN.c (vendored from the repo).
#
#  Output per challenge:
#    <tier>/binary/crackmeNN        Linux ELF x86-64 (static)
#    <tier>/binary/crackmeNN.exe    Windows PE x64 (static, via mingw-w64)
#  Solutions stay in <tier>/SOLUTION*.md — no spoilers in the binaries.
# ==============================================================
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

CRACKMES=/usr/share/netmask/crackmes
[ -d "$CRACKMES" ] || { echo "no crackmes dir — skipping"; exit 0; }

apt-get install -y -qq --no-install-recommends gcc mingw-w64 >/dev/null 2>&1 || true

MINGW=""
if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
    MINGW="x86_64-w64-mingw32-gcc"
else
    echo ">>> [crackmes] mingw-w64 unavailable — PE targets will be skipped"
fi

built=0
for c in $(find "$CRACKMES" -name "crackme*.c" | sort); do
    dir="$(dirname "$c")"
    name="$(basename "$c" .c)"
    bindir="$dir/binary"
    mkdir -p "$bindir"

    if gcc -O2 -static -Wall -o "$bindir/$name" "$c" 2>"$bindir/${name}.build.log"; then
        echo "  ELF  ✓ $bindir/$name"
        built=$((built + 1))
    else
        echo "  ELF  ✗ $c (see ${name}.build.log)"
        continue
    fi

    if [ -n "$MINGW" ]; then
        if $MINGW -O2 -static -o "$bindir/$name.exe" "$c" 2>>"$bindir/${name}.build.log"; then
            echo "  PE   ✓ $bindir/$name.exe"
            built=$((built + 1))
        else
            echo "  PE   ✗ $name.exe (see ${name}.build.log)"
        fi
    fi
done

chown -R 1000:1000 "$CRACKMES" 2>/dev/null || true
find "$CRACKMES" -type d -exec chmod 755 {} + 2>/dev/null || true
find "$CRACKMES/binary" -type f -exec chmod 755 {} + 2>/dev/null || true
find "$CRACKMES" -name binary -type d -exec chmod -R 755 {} + 2>/dev/null || true
echo ">>> [crackmes] built $built artifacts under $CRACKMES"
exit 0
