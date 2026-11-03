# 04 — Mobile Forensics

> Android-first (iOS needs macOS tooling for full work). This OS ships
> apktool, jadx, adb, fastboot, objection — the logical side.

## Two layers of mobile forensics

| Layer | What | Tools |
|---|---|---|
| Logical | files/accounts the OS exposes | adb backup, objection, ADB pull |
| Physical | raw flash image | custom recoveries, chip-off (hardware) |

## Android acquisition (logical, the realistic lab path)

```bash
adb devices                          # device + USB debugging authorized
adb shell 'ls /data/data' 2>/dev/null   # needs root or run-as debuggable app
adb pull /sdcard/Android/data/com.target.app   # app external storage
# app-private data via objection (needs a rooted/test device):
objection -d com.target.app explore
#   then: android hooking list activities / filesystem pull /sqlite
```

## App analysis (the RE side)

```bash
apktool d app.apk -o app_src         # resources + smali
jadx-gui app.apk                     # smali → Java (readable)
apkleaks -f app.apk                  # hardcoded secrets (keys/tokens)
# native libs:
file app_src/lib/arm64-v8a/*.so
ghidra &                             # .so → native RE workflow
```
Look for: hardcoded endpoints, crypto keys (apkleaks), certificate
pinning logic, API auth schemes.

## Data formats you will parse

* SQLite (`*.db`): `sqlite3 messages.db ".tables"` — chat, history
* Shared prefs (XML): settings, tokens
* Protobuf (often): decode with the app's extracted .proto or guess
* Property lists (iOS): plistlib in Python

## Key artifacts checklist (Android)

1. `/data/system/packages.xml` — installed apps + permissions
2. `/data/data/<app>/databases/` — app data (per-app sandbox)
3. `/data/misc/wifi/WifiConfigStore.xml` — AP history
4. `logcat` buffers (`adb logcat -d`) — recent activity
5. Download/DCIM — user content; EXIF (exiftool) = location leaks

## Integrity & reporting

* Hash APK + extracted data; note device model/Android version
* Distinguish *on-device evidence* vs *app-server truth* (wipes lie)
* Mobile acquisitions rarely survive court without documented method —
  write the procedure as you do it
