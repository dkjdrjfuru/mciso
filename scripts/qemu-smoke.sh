#!/usr/bin/env bash
# ==============================================================
#  scripts/qemu-smoke.sh — boot the ISO in QEMU and take screenshots
#  (used by CI + locally)
#
#    scripts/qemu-smoke.sh output/netmask-os-hacker-YYYYMMDD.iso           # BIOS
#    scripts/qemu-smoke.sh --uefi output/netmask-os-hacker-YYYYMMDD.iso    # OVMF
#
#  Verifies: ISO bootstraps, kernel starts, GRUB + boot messages appear
#  (screendump is not blank). Needs: qemu-system-x86, ovmf (UEFI run).
# ==============================================================
set -euo pipefail

MODE=bios
[ "${1:-}" = "--uefi" ] && { MODE=uefi; shift; }
ISO="${1:?usage: qemu-smoke.sh [--uefi] <iso>}"
WAIT="${NETMASK_SMOKE_WAIT:-75}"
[ -f "$ISO" ] || { echo "ISO not found: $ISO" >&2; exit 1; }

OUT="$(mktemp -d /tmp/netmask-smoke.XXXXXXXX)"
trap 'pkill -f "netmask-smoke-qemu" 2>/dev/null || true; rm -rf "$OUT"' EXIT

QEMU=(qemu-system-x86_64 -m 2048 -smp 2 -name netmask-smoke-qemu
      -cdrom "$ISO" -boot d -display none -monitor stdio -no-reboot)

if [ "$MODE" = "uefi" ]; then
    OVMF="$(ls /usr/share/OVMF/OVMF_CODE.fd /usr/share/ovmf/OVMF.fd 2>/dev/null | head -n1)"
    [ -n "$OVMF" ] || { echo "install ovmf for UEFI smoke tests (apt install ovmf)" >&2; exit 2; }
    QEMU+=(-bios "$OVMF")
fi

echo ">>> smoke test [$MODE]: booting ${ISO##*/} (waiting ${WAIT}s)..."
( sleep "$WAIT"; echo screendump "$OUT/shot.ppm"; sleep 2; echo quit ) \
    | "${QEMU[@]}" >/dev/null 2>&1 || true

[ -f "$OUT/shot.ppm" ] || { echo "SMOKE FAIL: no screenshot (QEMU died?)"; exit 1; }

# non-black check with pure-stdlib PPM parsing
python3 - "$OUT/shot.ppm" <<'EOF'
import sys
p = sys.argv[1]
with open(p, "rb") as f:
    magic = f.readline().strip()
    assert magic == b"P6", f"not a P6 PPM: {magic}"
    line = f.readline()
    while line.startswith(b"#"):
        line = f.readline()
    w, h = map(int, line.split())
    f.readline()
    data = f.read()
    lit = sum(1 for i in range(0, len(data), 3) if data[i:i+3] != b"\x00\x00\x00")
    pct = 100.0 * lit / (w * h)
    print(f"screen {w}x{h}, lit pixels: {pct:.1f}%")
    sys.exit(0 if pct > 0.5 else 1)
EOF
RC=$?
[ $RC -eq 0 ] && echo "SMOKE PASS [$MODE]: display is alive" \
              || echo "SMOKE FAIL [$MODE]: screen is blank"
exit $RC
