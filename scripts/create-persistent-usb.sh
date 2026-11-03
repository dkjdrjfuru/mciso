#!/usr/bin/env bash
# ==============================================================
#  scripts/create-persistent-usb.sh
#  Write the Netmask OS ISO to a USB stick and add a LUKS2 persistence
#  partition. live-boot auto-detects it on boot (grub default entry has
#  `persistent`) and prompts for the passphrase.
#
#    sudo scripts/create-persistent-usb.sh output/netmask-os-hacker-YYYYMMDD.iso /dev/sdX
#
#  !!! DESTROYS ALL DATA ON <device> !!!
# ==============================================================
set -euo pipefail

ISO="${1:?usage: create-persistent-usb.sh <iso> <device>}"
DEV="${2:?usage: create-persistent-usb.sh <iso> <device>}"
[ -b "$DEV" ] || { echo "not a block device: $DEV" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
[ -f "$ISO" ] || { echo "ISO not found: $ISO" >&2; exit 1; }

ISOSIZE=$(( $(stat -c%s "$ISO") / 1024 + 16 ))   # MiB
PERSIST=${PERSIST_SIZE:-16384}                    # MiB, override: PERSIST_SIZE=32768 ...

echo "device        : $DEV"
echo "iso           : $ISO ($(du -h "$ISO" | cut -f1))"
echo "persistence   : ${PERSIST} MiB (LUKS2, label 'persistence')"
echo
read -rp "THIS WILL DESTROY ALL DATA ON $DEV — type 'DESTROY' to continue: " ok
[ "$ok" = "DESTROY" ] || { echo "aborted"; exit 1; }

echo ">>> dd ISO"
dd if="$ISO" of="$DEV" bs=4M status=progress conv=fsync

echo ">>> partitioning (GPT: persistence after the ISO area)"
PART="${DEV}2"; [[ "$DEV" == *mmcblk* || "$DEV" == *nvme* ]] && PART="${DEV}p2"
START=$(( ISOSIZE + 2 ))
sfdisk --no-reread --force "$DEV" <<EOF
label: gpt
start=${START}MiB, size=${PERSIST}MiB, type=linux
EOF
partprobe "$DEV" && sleep 1

echo ">>> LUKS2 formatting $PART (you will set the passphrase)"
cryptsetup luksFormat --type luks2 --label netmask-persist "$PART"

echo ">>> creating persistence.conf inside the container"
cryptsetup open "$PART" netmask-persist
mkfs.ext4 -L persistence /dev/mapper/netmask-persist
MNT="$(mktemp -d)"
mount /dev/mapper/netmask-persist "$MNT"
echo "/home"        > "$MNT/persistence.conf"
echo "/etc/netmask" >> "$MNT/persistence.conf"
echo "/opt/cases"   >> "$MNT/persistence.conf"
umount "$MNT" && rmdir "$MNT"
cryptsetup close netmask-persist

echo
echo "DONE. Boot the stick via the default GRUB entry — live-boot finds the"
echo "LUKS2 container, asks for the passphrase and overlays /home, /etc/netmask"
echo "and /opt/cases from it."
