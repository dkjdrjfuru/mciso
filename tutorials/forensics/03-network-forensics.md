# 03 — Network Forensics

> The packet capture is the unbiased witness. Tools here: tshark,
> tcpdump, zeek-style thinking (zeek itself not shipped — workflows are).

## Capture with intent

```bash
tshark -i any -w full.pcapng                     # everything (big)
tcpdump -i eth0 -s 0 -w snap.pcap 'tcp port 443' # targeted ring
tshark -r full.pcapng -z io,stat,60              # 60s traffic histogram
```

## The triage funnel (big PCAP → story)

```bash
tshark -r c.pcapng -q -z conv,tcp | head -30     # conversations by bytes
tshark -r c.pcapng -q -z endpoints,ip            # who talked to whom
tshark -r c.pcapng -Y "dns" -T fields -e dns.qry.name | sort -u   # DNS truth
tshark -r c.pcapng -Y "http.request" -T fields -e http.host -e http.request.uri
```

## What you hunt

| Signal | Filter |
|---|---|
| DNS exfil (long subdomains) | `dns.qry.name contains "-----"` / base32-ish labels |
| Beaconing | `-z io,stat,60` regular bursts to one IP |
| Cleartext creds | `http.authbasic`, `ftp`, `telnet`, `smtp` |
| Suspicious TLS | self-signed CAs, JA3-style fingerprinting (tshark TLS fields) |
| File transfer | `tshark -Y "http or ftp-data" --export-objects http,outdir` |

```bash
tshark -r c.pcapng --export-objects http,/tmp/objs   # carve files from HTTP
tshark -r c.pcapng -Y "tcp.stream eq 12" -z follow,tcp,ascii,12
```

## Following streams (the bread and butter)

```bash
tshark -r c.pcapng -q -z follow,tcp,ascii,0     # stream 0 readable
tshark -r c.pcapng -q -z follow,udp,raw,3
```
"Follow stream" on suspect conversations shows C2 commands, exfil
bodies, protocol structure (feeds reversing/09-3).

## Reassembly gotchas

* `-s 0` on tcpdump or you carve fragments only
* TCP streams split across files → mergecap first
* Encrypted? You still have: SNI, cert chains, sizes/timing (the
  fingerprint channel — see crypto/03)

## Correlate & report

1. Export IOCs (IPs/domains/hashes of carved files) with timestamps
2. Map to hosts from disk/memory forensics (2-way timeline)
3. Annotate the PCAP (editcap -F pcapng comments) or ship extracted
   evidence + your timeline document
