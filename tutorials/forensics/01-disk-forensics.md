# 01 — Disk Forensics

> Every byte tells a story: deleted files, slack space, timestamps.
> Toolchain on this OS: sleuthkit/autopsy, ewf, dc3dd, photorec.

## Imaging (acquire before you analyze)

```bash
dc3dd if=/dev/sdX of=/tmp/evidence.raw hash=sha256 log=/tmp/acq.log
# or with compression + split:
dcfldd if=/dev/sdX bs=64K of=/tmp/ev.img hashwindow=1G md5log=md.txt
# E01 (Expert Witness) format handling:
ewfmount evidence.E01 /mnt/ewf && ls /mnt/ewf
```
**Chain of custody**: hash at acquisition, hash at every transfer, log
everything. Evidence without provenance is worthless.

## Partition & filesystem survey

```bash
mmls evidence.raw                     # partition table (DOS/GPT)
fsstat -o 2048 evidence.raw           # filesystem type/geometry
fsstat evidence.E01                   # ewf tools expose a virtual device
```

## The sleuthkit core loop

```bash
fls -o 2048 -r evidence.raw > files.txt    # recursive file listing (incl. deleted)
icat -o 2048 evidence.raw 42 > file42      # extract inode 42 (even deleted)
istat -o 2048 evidence.raw 42              # inode metadata (MAC times)
ils -o 2048 evidence.raw | head            # inode table (allocated+unallocated)
```

## Deleted-file recovery

* **Metadata intact**: `fls` shows deleted entries → `icat` them out
* **Metadata gone**: carve —
```bash
photorec evidence.raw            # signature carving, interactive
scalpel evidence.raw -o carve/   # config-driven carving
foremost -i evidence.raw -o out/ # another carver, different engine
```
Carving works because deletion rarely erases content — only the index.

## Timeline & artifacts

```bash
mactime -b body.txt -z UTC > timeline.txt   # from fls -m output
# correlate: file MACs, log timestamps, browser history (via icat),
# $MFT on NTFS (analyzeMFT-style parsing), registry hives (reglookup)
```

## Filesystem notes

| FS | Quirk |
|---|---|
| NTFS | $MFT + $UsnJrnl = gold; use ntfs-3g + libvhdi/libvmdk for images |
| ext4 | journal holds recent history; `debugfs`-style analysis |
| FAT/exFAT | exfatprogs here; deletion = index clear (carve) |
| APFS/HFS+ | not on this ISO — analyze on macOS tools |

## VM artifacts checklist

RAM pagefile, hibernation file, event logs, browser profiles,
`/var/log`, shell history, recent docs, thumbnails — mount read-only:

```bash
mount -o ro,loop,offset=$((2048*512)) evidence.raw /mnt/ev
```
