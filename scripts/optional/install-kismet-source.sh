#!/usr/bin/env bash
# scripts/optional/install-kismet-source.sh — OPT-IN
# Kismet was dropped from Debian bookworm; build it from source instead.
# Run inside the live session:  sudo bash /usr/local/lib/netmask/optional/install-kismet-source.sh
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y --no-install-recommends \
    build-essential cmake git libwebsockets-dev libpcre2-dev libcap-dev \
    libpcap-dev python3 python3-dev protobuf-c-compiler libprotobuf-c-dev \
    libnl-3-dev libnl-genl-3-dev libusb-1.0-0-dev libsensors4-dev \
    libsqlite3-dev python3-setuptools c-ares-dev libcurl4-openssl-dev \
    libjson-c-dev libelf-dev lwipv6-dev libudev-dev g++ || exit 1

git clone --depth 1 https://www.kismetwireless.net/git/kismet.git /tmp/kismet \
    || git clone --depth 1 https://github.com/kismetwireless/kismet.git /tmp/kismet \
    || exit 1
cd /tmp/kismet
./configure --prefix=/usr/local >/dev/null
make -j"$(nproc)" >/dev/null 2>&1
make plugins >/dev/null 2>&1 || true
make install >/dev/null
make suidinstall >/dev/null 2>&1 || true
kismet --version 2>/dev/null && echo "kismet installed"
