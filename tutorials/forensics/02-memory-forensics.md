# 02 — Memory Forensics (forensics edition)

> Same tooling as malware/04, different goal: reconstruct *what
> happened* on a box — timeline, user activity, network truth.

## Triage questions memory answers

1. What was actually running (including fileless/malicious)?
2. What was typed (bash/ps history, console buffers)?
3. What connections existed (sockets that have since closed)?
4. What credentials/secrets were resident?

## Linux image workflow (full commands in malware/04)

```bash
vol -f mem.lime linux.psx                 # true process tree
vol -f mem.lime linux.tty_check           # tty activity
vol -f mem.lime linux.bash                # command history
vol -f mem.lime linux.sockstat            # sockets incl. closed
vol -f mem.lime linux.mountinfo
vol -f mem.lime linux.env                 # environment secrets
vol -f mem.lime linux.pagecache.Files --dump   # files still in RAM
```
`pagecache` is underrated: recently-read files recover from RAM even
after deletion on disk (combine with forensics/01 carving!).

## Windows image quick wins

```bash
vol -f mem.raw windows.cmdline
vol -f mem.raw windows.netscan
vol -f mem.raw windows.shimcache          # execution evidence
vol -f mem.raw windows.amcache            # executed binaries
vol -f mem.raw windows.clipboard
vol -f mem.raw windows.dumpfiles --virtaddr 0x...   # pull a binary out
```

## Building the timeline

Merge: memory artifacts (vol/memprocfs) + disk timeline (mactime from
forensics/01) + network (forensics/03) into one UTC-sorted master
timeline. The story emerges at the intersections.

## Acquisition reminders

* Linux: LiME module (build against exact running kernel — headers are
  on this ISO; see malware/04)
* Order matters: memory FIRST (volatile), then disk, then network logs
* Hash everything; note clock skew (NTP offsets) before correlating

## MemProcFS as a second opinion

```bash
memprocfs -device mem.raw -mount /mnt/mem
grep -ri "password" /mnt/mem/pid/ 2>/dev/null | head    # crude but effective
ls /mnt/mem/pid/*/task/*/       # structured per-process views
```
