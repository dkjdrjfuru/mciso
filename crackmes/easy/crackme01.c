/*
 * crackme01 — easy · "hello world of RE"
 * ---------------------------------------
 * Tier:   EASY (100 pts)
 * Skill:  strings, static analysis, first look at a disassembler
 * Target: find the password by ANY means (strings, ltrace, Ghidra, ...)
 *
 *   Linux:  ./crackme01
 *   Wine :  wine crackme01.exe
 */
#include <stdio.h>
#include <string.h>

int main(void) {
    char buf[64] = {0};

    printf("=== crackme01 ===\n");
    printf("enter the magic word: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';

    if (strcmp(buf, "n3tm4sk_r0x") == 0) {
        printf("\n[+] access granted\n");
        printf("[+] flag: netmask{you_passed_your_first_strcmp}\n");
        return 0;
    }

    printf("\n[-] wrong. hint: what does `strings` tell you?\n");
    return 1;
}
