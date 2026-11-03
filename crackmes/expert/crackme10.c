/*
 * crackme10 — expert · TEA cipher gate
 * -------------------------------------
 * Tier:   EXPERT (1000 pts)
 * Skill:  recognise a standard block cipher by its magic constants and
 *         write the decryptor
 *
 * The key schedule you will see: delta 0x9E3779B9, 32 rounds, shifts 4/5,
 * key words at fixed offsets — that is TEA (Tiny Encryption Algorithm).
 * The key is IN the binary. Recognise it, port the cipher, invert it.
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>

static const uint32_t KEY[4] = {
    0x6D74336Eu, 0x5F6B7334u, 0x5F616574u, 0x2179656Bu   /* b"n3tm4sk_tea_key!" */
};

static void tea_encrypt(uint32_t *v0, uint32_t *v1) {
    uint32_t s = 0, d = 0x9E3779B9u;
    for (int i = 0; i < 32; i++) {
        s += d;
        *v0 += ((*v1 << 4) + KEY[0]) ^ (*v1 + s) ^ ((*v1 >> 5) + KEY[1]);
        *v1 += ((*v0 << 4) + KEY[2]) ^ (*v0 + s) ^ ((*v0 >> 5) + KEY[3]);
    }
}

int main(void) {
    char buf[64] = {0};
    uint32_t v0, v1;

    printf("=== crackme10 (TEA) ===\n");
    printf("8-char key: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';
    if (strlen(buf) != 8) { printf("[-] exactly 8 chars\n"); return 1; }

    memcpy(&v0, buf, 4);
    memcpy(&v1, buf + 4, 4);
    tea_encrypt(&v0, &v1);

    if (v0 == 0x0B8AC80Au && v1 == 0x6A5CA0BDu) {
        printf("\n[+] ciphertext matches. you implemented TEA.\n");
        printf("[+] flag: netmask{t1ny_c1ph3r_t1ny_eff0rt}\n");
        return 0;
    }
    printf("\n[-] ciphertext mismatch (0x%08X 0x%08X)\n", v0, v1);
    return 1;
}
