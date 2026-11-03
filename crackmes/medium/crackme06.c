/*
 * crackme06 — medium · custom encoding
 * --------------------------------------
 * Tier:   MEDIUM (250 pts)
 * Skill:  invert a rolling transform you can't grep for
 *
 * The expected key is stored ENCODED: every byte was shifted by
 * ((index * 7) % 13). The transform runs in the open — invert it.
 */
#include <stdio.h>
#include <string.h>

static const char stored[] = "tpnmaor|co~zgmpd";

int main(void) {
    char buf[64] = {0};

    printf("=== crackme06 (rolling encode) ===\n");
    printf("key: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';

    size_t n = strlen(buf);
    if (n != strlen(stored)) { printf("[-] wrong length\n"); return 1; }

    for (size_t i = 0; i < n; i++) {
        char want = (char)((stored[i] - ((i * 7) % 13)) & 0xFF);
        if (buf[i] != want) { printf("[-] mismatch at byte %zu\n", i); return 1; }
    }

    printf("\n[+] rolling decode complete\n");
    printf("[+] flag: netmask{enc0de_n0t_encrype_either}\n");
    return 0;
}
