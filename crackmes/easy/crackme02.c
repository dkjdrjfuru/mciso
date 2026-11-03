/*
 * crackme02 — easy · XOR decoder
 * --------------------------------
 * Tier:   EASY (100 pts)
 * Skill:  recognise a XOR loop in a disassembler, replay it in Python
 *
 * The flag is not stored in cleartext. It is XORed byte-by-byte with a
 * 1-byte key. Find the key and the flag.
 */
#include <stdio.h>
#include <string.h>

static const unsigned char enc[] = {
    0x22, 0x6A, 0x28, 0x05, 0x6B, 0x29, 0x05, 0x34, 0x6A, 0x2E,
    0x05, 0x3F, 0x34, 0x39, 0x28, 0x23, 0x2A, 0x2E, 0x6B, 0x6A,
    0x34, 0x74
};

int main(void) {
    char buf[64] = {0};
    unsigned char out[sizeof(enc)] = {0};
    const unsigned char key = 0x5A;   /* <- find me */

    printf("=== crackme02 ===\n");
    printf("say the magic phrase: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';

    for (size_t i = 0; i < sizeof(enc); i++)
        out[i] = enc[i] ^ key;

    if (strcmp(buf, (const char *)out) == 0) {
        printf("\n[+] decoded: %s\n", out);
        printf("[+] flag: netmask{x0r_1s_n0t_encrypt10n}\n");
        return 0;
    }

    printf("\n[-] nope. the answer is hidden in 22 bytes, masked by one byte.\n");
    return 1;
}
