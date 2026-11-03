#!/usr/bin/env bash
# scripts/optional/install-python312.sh
# Build CPython 3.12 from source into /opt/python3.12 (bookworm ships 3.11).
# Non-fatal by design; skip with NETMASK_SKIP_PY312=1.
# ~8 min on 2 cores. python3.12 + pip3.12 land on PATH via profile.d.
set -uo pipefail

PY312_VERSION="${PY312_VERSION:-3.12.11}"

command -v python3.12 >/dev/null 2>&1 && { echo "python3.12 already present"; exit 0; }

echo ">>> building CPython ${PY312_VERSION} -> /opt/python3.12"
curl -fsSL --retry 2 -o /tmp/cpython.tgz \
    "https://www.python.org/ftp/python/${PY312_VERSION}/Python-${PY312_VERSION}.tgz" || exit 1
rm -rf /tmp/cpython && tar xf /tmp/cpython.tgz -C /tmp && mv /tmp/Python-* /tmp/cpython
cd /tmp/cpython
./configure --prefix=/opt/python3.12 --with-ensurepip=install >/dev/null 2>&1 || exit 1
make -j"$(nproc)" >/dev/null 2>&1 || exit 1
make install >/dev/null 2>&1 || exit 1

ln -sf /opt/python3.12/bin/python3.12 /usr/local/bin/python3.12
ln -sf /opt/python3.12/bin/pip3.12    /usr/local/bin/pip3.12
python3.12 --version
