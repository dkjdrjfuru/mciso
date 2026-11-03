/*
 * crackme05 — medium · a tiny bytecode VM
 * ----------------------------------------
 * Tier:   MEDIUM (250 pts)
 * Skill:  read a dispatch loop, dump the bytecode, invert the program
 *
 * The key check is not native code: it is a 12-instruction program run by
 * a 4-opcode VM (PUSH/PUSHI, ADD, XOR, CMPEQ). Understand the VM, then
 * either emulate the program in Python or craft input it accepts.
 */
#include <stdio.h>
#include <string.h>

/* opcodes */
enum { OP_PUSHA, OP_PUSHI, OP_ADD, OP_XOR, OP_CMPEQ, OP_HALT };

static const unsigned char prog[] = {
    /* the VM validates: sum(input[0..3] xor 0x37) == 0x101 */
    OP_PUSHA, 0,
    OP_XOR,   0x37,
    OP_PUSHA, 1,
    OP_XOR,   0x37,
    OP_ADD,
    OP_PUSHA, 2,
    OP_XOR,   0x37,
    OP_PUSHA, 3,
    OP_XOR,   0x37,
    OP_ADD,
    OP_ADD,
    OP_PUSHI, 0x01, 0x01,
    OP_CMPEQ,
    OP_HALT
};

static int run_vm(const unsigned char *in) {
    int stack[16] = {0};
    int sp = 0;
    int pc = 0;
    while (pc < (int)sizeof(prog)) {
        switch (prog[pc++]) {
        case OP_PUSHA: stack[sp++] = in[prog[pc++]]; break;
        case OP_PUSHI: { int v = prog[pc++]; v |= prog[pc++] << 8; stack[sp++] = v; } break;
        case OP_ADD:   sp--; stack[sp - 1] += stack[sp]; break;
        case OP_XOR:   stack[sp - 1] ^= prog[pc++]; break;
        case OP_CMPEQ: sp -= 2; return stack[sp] == stack[sp + 1];
        case OP_HALT:  return 0;
        default:       return 0;
        }
    }
    return 0;
}

int main(void) {
    char buf[64] = {0};

    printf("=== crackme05 (VM) ===\n");
    printf("4 chars, please: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';
    if (strlen(buf) < 4) { printf("[-] 4 chars, I said\n"); return 1; }

    if (run_vm((const unsigned char *)buf)) {
        printf("\n[+] the bytecode approves\n");
        printf("[+] flag: netmask{v1rtual_mach1n3s_t3ll_n0_l13s}\n");
        return 0;
    }
    printf("\n[-] bytecode says no\n");
    return 1;
}
