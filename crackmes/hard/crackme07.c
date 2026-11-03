/*
 * crackme07 — hard · VM + anti-debug
 * ------------------------------------
 * Tier:   HARD (500 pts)
 * Skill:  defeat the debugger check, THEN reverse the bytecode
 *
 * Layer 1: anti-debug (ptrace / IsDebuggerPresent + a timing canary)
 * Layer 2: an 8-opcode VM with jumps; the program compares a rolling
 *          transform of your input against a constant table.
 */
#include <stdio.h>
#include <string.h>
#include <time.h>

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

enum { OP_PUSHA, OP_PUSHI, OP_ROL, OP_XORS, OP_CMPB, OP_JZ, OP_JMP, OP_HALT };

/* program: rolling-ROL-XOR chain of 8 input bytes == 0x6E */
static const unsigned char prog[] = {
    OP_PUSHA, 0, OP_ROL, 3, OP_PUSHA, 1, OP_ROL, 5, OP_XORS,
    OP_PUSHA, 2, OP_ROL, 1, OP_XORS,
    OP_PUSHA, 3, OP_ROL, 7, OP_XORS,
    OP_PUSHA, 4, OP_ROL, 2, OP_XORS,
    OP_PUSHA, 5, OP_ROL, 4, OP_XORS,
    OP_PUSHA, 6, OP_ROL, 6, OP_XORS,
    OP_PUSHA, 7, OP_ROL, 1, OP_XORS,
    OP_PUSHI, 0x6E, 0x00,
    OP_CMPB,
    OP_JZ, 0,
    OP_HALT
};

static unsigned char rol(unsigned char v, int n) {
    n &= 7;
    return (unsigned char)((v << n) | (v >> (8 - n)));
}

static int run_vm(const unsigned char *in) {
    unsigned char stack[16] = {0};
    int sp = 0, pc = 0, guard = 0;
    while (pc < (int)sizeof(prog) && guard++ < 256) {
        switch (prog[pc++]) {
        case OP_PUSHA: stack[sp++] = in[prog[pc++]]; break;
        case OP_PUSHI: { int v = prog[pc++]; v |= prog[pc++] << 8; stack[sp++] = (unsigned char)v; } break;
        case OP_ROL:   stack[sp - 1] = rol(stack[sp - 1], prog[pc++]); break;
        case OP_XORS:  sp--; stack[sp - 1] ^= stack[sp]; break;
        case OP_CMPB:  sp -= 2; return stack[sp] == stack[sp + 1];
        case OP_JZ:    pc++; return 1;             /* equal -> accept */
        case OP_JMP:   pc = prog[pc]; break;
        case OP_HALT:  return 0;
        default:       return 0;
        }
    }
    return 0;
}

int main(void) {
    char buf[64] = {0};

    printf("=== crackme07 (VM + anti-debug) ===\n");
    if (dbg()) {
        printf("[-] debugger detected. decoy: netmask{d3bugg3rs_n0t_all0w3d}\n");
        return 2;
    }

    clock_t t0 = clock();
    printf("8 chars: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';
    if (strlen(buf) < 8) { printf("[-] 8 chars, I said\n"); return 1; }
    if (clock() - t0 > 5 * CLOCKS_PER_SEC) {
        printf("[-] too slow. suspicious.\n");
        return 3;
    }

    if (run_vm((const unsigned char *)buf)) {
        printf("\n[+] bytecode verified\n");
        printf("[+] flag: netmask{r0ll_y0ur_0wn_vm_get_r0ll3d}\n");
        return 0;
    }
    printf("\n[-] the chain broke\n");
    return 1;
}
