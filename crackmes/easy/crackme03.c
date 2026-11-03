/*
 * crackme03 — easy · arithmetic gate
 * -----------------------------------
 * Tier:   EASY (100 pts)
 * Skill:  read a chain of transforms in the decompiler, invert it
 *
 * The check is: transform each character, sum it up, compare to a target.
 * Two valid keys exist — the intended one and one "clever" alternative
 * (see what the transform does to 'z'...).
 */
#include <stdio.h>
#include <string.h>

int main(void) {
    char buf[64] = {0};
    int acc = 0;

    printf("=== crackme03 ===\n");
    printf("key: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';

    size_t n = strlen(buf);
    if (n < 4) { printf("[-] too short\n"); return 1; }

    for (size_t i = 0; i < n; i++)
        acc += (buf[i] ^ 0x20) + (int)(i * 2);

    if (acc == 0x1DB) {
        printf("\n[+] sum lands on 0x1DB — access granted\n");
        printf("[+] flag: netmask{c0nstra1nts_have_1nfinite_s0lut10ns}\n");
        return 0;
    }

    printf("\n[-] sum = 0x%X (want 0x1DB)\n", acc);
    return 1;
}
