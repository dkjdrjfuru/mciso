/*
 * crackme08 — hard · obfuscated control flow
 * -------------------------------------------
 * Tier:   HARD (500 pts)
 * Skill:  survive an opaque-predicate dispatcher without going insane
 *
 * No straight-line check here: a state-machine dispatcher walks you
 * through interleaved real and decoy states. Opaque predicates
 * (x*(x+1) % 2 == 0 — always true) send your decompiler into the weeds.
 * Strategy: trace, don't read. Or defuse the predicates and re-decompile.
 */
#include <stdio.h>
#include <string.h>

static int state = 0;
static unsigned acc = 0x1337;

static void step(char c) {
    unsigned x = (unsigned char)c;
    /* opaque predicate: always true (n*(n+1) is always even) */
    unsigned n = acc & 0xFFFF;
    int opaque = ((n * (n + 1)) % 2 == 0);
    (void)opaque;

    switch (state) {
    case 0: acc = (acc ^ x) * 31 + 7; state = opaque ? 2 : 9; break;
    case 2: acc = (acc + x) * 33;     state = opaque ? 5 : 1; break;
    case 9: acc = (acc + x) * 3;      state = 4; break;   /* decoy */
    case 5: acc = (acc ^ x) + 0x9E37; state = opaque ? 7 : 0; break;
    case 1: acc = acc * 7 ^ x;        state = 3; break;   /* decoy */
    case 7: acc = (acc + x) * 17;     state = 8; break;
    case 4: acc = acc ^ x;            state = 5; break;   /* decoy */
    case 8: acc = (acc ^ x) * 31 + 11; state = 6; break;
    case 3: acc = (acc + x) * 13;     state = 8; break;   /* decoy */
    default: break;
    }
}

int main(void) {
    char buf[64] = {0};

    printf("=== crackme08 (control-flow soup) ===\n");
    printf("key: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';
    if (strlen(buf) != 6) { printf("[-] exactly 6 chars\n"); return 1; }

    state = 0; acc = 0x1337;
    for (size_t i = 0; i < strlen(buf); i++) step(buf[i]);

    if (acc == 0x2A5F0B1Eu) {
        printf("\n[+] you walked the real path through the soup\n");
        printf("[+] flag: netmask{0paque_pr3dic4tes_st1ll_us3_cmp}\n");
        return 0;
    }
    printf("\n[-] acc = 0x%08X (want 0x2A5F0B1E)\n", acc);
    return 1;
}
