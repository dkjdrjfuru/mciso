/*
 * crackme11 — expert · self-integrity + rolling XOR (the "final boss")
 * ----------------------------------------------------------------------
 * Tier:   EXPERT (1000 pts)
 * Skill:  tamper detection, data-only attacks, end-to-end methodology
 *
 * Defenses stacked:
 *   1. anti-debug (ptrace / IsDebuggerPresent)
 *   2. self-integrity: FNV-1a over the secret table; a single patched
 *      byte (or a NOP too many) flips it to the decoy path
 *   3. the flag itself is never a string — rolling-key XOR table
 *   4. key check runs through a small state machine
 *
 * Note: a true kernel-mode challenge needs a signed driver (WDK) — see
 * SOLUTION11.md for the kernel-variant design. This one stays userland
 * so it ships on the ISO and runs under Wine.
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#if defined(_WIN32)
#include <windows.h>
static int dbg(void) { return IsDebuggerPresent() != 0; }
#elif defined(__linux__)
#include <sys/ptrace.h>
#include <unistd.h>
static int dbg(void) { return ptrace(PTRACE_TRACEME, 0, 1, 0) == -1; }
#else
static int dbg(void) { return 0; }
#endif

/* enc[i] = flag[i] ^ ((i*167 + 19) & 0xFF) — flag is 31 bytes */
static const unsigned char enc[31] = {
    0x7D, 0xDF, 0x15, 0x65, 0xCE, 0x25, 0x96, 0xDF, 0x20, 0xC1,
    0xEB, 0x2E, 0xD4, 0xE2, 0x6A, 0xBF, 0xF1, 0x1E, 0xB2, 0x13,
    0x72, 0xF5, 0x32, 0x62, 0x8A, 0x01, 0x7D, 0x80, 0x25, 0x87,
    0xD8
};
static const uint32_t enc_hash = 0x557E0C7Du;   /* FNV-1a(enc) */

static uint32_t fnv1a(const unsigned char *p, size_t n) {
    uint32_t h = 0x811C9DC5u;
    for (size_t i = 0; i < n; i++) h = (h ^ p[i]) * 0x01000193u;
    return h;
}

int main(void) {
    char key[64] = {0};
    unsigned char flag[sizeof(enc) + 1] = {0};

    printf("=== crackme11 (final boss) ===\n");
    if (dbg()) {
        printf("[-] debugger. decoy: netmask{y0u_ch34t3d_th3_b0ss}\n");
        return 2;
    }
    if (fnv1a(enc, sizeof(enc)) != enc_hash) {
        printf("[-] integrity violation. the data has been tampered with.\n");
        return 3;
    }

    printf("passphrase: ");
    if (!fgets(key, sizeof(key), stdin)) return 1;
    key[strcspn(key, "\r\n")] = '\0';

    /* state machine: fold the key, compare digest */
    uint32_t acc = 0xC0FFEE;
    for (size_t i = 0; i < strlen(key); i++)
        acc = (acc ^ (unsigned char)key[i]) * 0x01000193u;
    if (acc != 0xCE29E4D1u) {
        printf("\n[-] digest 0x%08X != 0xCE29E4D1\n", acc);
        return 1;
    }

    for (size_t i = 0; i < sizeof(enc); i++)
        flag[i] = enc[i] ^ ((i * 167 + 19) & 0xFF);
    printf("\n[+] integrity OK · digest OK\n");
    printf("[+] flag: %s\n", flag);
    return 0;
}
