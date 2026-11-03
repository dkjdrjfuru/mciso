#!/usr/bin/env python3
"""post_build.py — Netmask OS artifact finalizer (optional stage).

Run after the ISO exists (build.sh calls it automatically when present):

    python3 scripts/post_build.py output/netmask-os-hacker.iso

What it does (all optional, non-destructive):
  * renames the ISO to a dated artifact name (if not dated already)
  * writes <iso>.sha256 (idempotent)
  * writes <iso>.sig   (detached GPG armor) when SIGN=1 and a secret key exists
  * emits <iso>.BUILD-INFO.json with sizes, hashes, versions — audit trail

"Obfuscation"/sanitization note: the ISO is a live Debian rootfs; there is
nothing meaningful to obfuscate. What reproducible builds DO need is a
clean, verifiable artifact trail — that is exactly what this produces.
"""
from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


def sha256(path: Path, chunk: int = 1 << 20) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while block := f.read(chunk):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    iso = Path(sys.argv[1]).resolve()
    if not iso.is_file():
        print(f"ERROR: {iso} not found", file=sys.stderr)
        return 1

    outdir = iso.parent
    stamp = dt.datetime.now(dt.UTC).strftime("%Y%m%d")

    # 1) dated name -----------------------------------------------------------
    if f"-{stamp}" not in iso.name:
        dated = outdir / iso.name.replace(".iso", f"-{stamp}.iso")
        shutil.move(iso, dated)
        iso = dated
        print(f"[post_build] renamed -> {iso.name}")

    # 2) sha256 ----------------------------------------------------------------
    digest = sha256(iso)
    (outdir / f"{iso.name}.sha256").write_text(f"{digest}  {iso.name}\n")
    print(f"[post_build] sha256 = {digest}")

    # 3) optional GPG signature -------------------------------------------------
    if os.environ.get("SIGN") == "1":
        gpg = shutil.which("gpg")
        keyid = os.environ.get("GPG_KEY_ID", "")
        if gpg and subprocess.run([gpg, "--list-secret-keys"],
                                  capture_output=True).returncode == 0:
            sig = outdir / f"{iso.name}.sig"
            cmd = [gpg, "--batch", "--yes", "--detach-sign", "--armor"]
            if keyid:
                cmd += ["--local-user", keyid]
            cmd += ["-o", str(sig), str(iso)]
            subprocess.run(cmd, check=True)
            print(f"[post_build] signed -> {sig.name}")
        else:
            print("[post_build] SIGN=1 but no GPG secret key — signature skipped")

    # 4) build-info audit record -------------------------------------------------
    info = {
        "artifact": iso.name,
        "size_bytes": iso.stat().st_size,
        "sha256": digest,
        "built_utc": dt.datetime.now(dt.UTC).isoformat(timespec="seconds"),
        "generator": "netmask-os build.sh (mkosi)",
        "source_revision": subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"], cwd=outdir.parent,
            capture_output=True, text=True).stdout.strip() or "unknown",
    }
    (outdir / f"{iso.name}.BUILD-INFO.json").write_text(
        json.dumps(info, indent=2) + "\n")
    print(f"[post_build] wrote {iso.name}.BUILD-INFO.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
