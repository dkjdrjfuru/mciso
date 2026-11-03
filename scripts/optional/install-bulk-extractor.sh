#!/usr/bin/env bash
# scripts/optional/install-bulk-extractor.sh — OPT-IN
# bulk_extractor was dropped from bookworm; build from source.
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool pkg-config libewf-dev \
    libexpat1-dev libssl-dev zlib1g-dev || exit 1

git clone --depth 1 https://github.com/simsong/bulk_extractor.git /tmp/be || exit 1
cd /tmp/be
. ./bootstrap.sh >/dev/null 2>&1 || ./bootstrap >/dev/null 2>&1
./configure --prefix=/usr/local >/dev/null || exit 1
make -j"$(nproc)" >/dev/null 2>&1
make install >/dev/null
bulk_extractor -V 2>/dev/null | head -1 && echo "bulk_extractor installed"
