/*
 * crackme04 — medium · anti-debug gate
 * -------------------------------------
 * Tier:   MEDIUM (250 pts)
 * Skill:  defeat IsDebuggerPresent / ptrace checks; patch or bypass
 *
 * The password check never runs if a debugger is attached — you get a
 * decoy instead. Attach gdb and see for yourself, then beat it:
 *   1) patch the check (easy mode)
 *   2) set the right hardware state / LD_PRELOAD a fake (clean mode)
 */
#include <stdio.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
static int being_debugged(void) { return IsDebuggerPresent() != 0; }
#elif defined(__linux__)
#include <sys/ptrace.h>
#include <unistd.h>
static int being_debugged(void) {
    return ptrace(PTRACE_TRACEME, 0, 1, 0) == -1; /* parent already tracing */
}
#else
static int being_debugged(void) { return 0; }
#endif

int main(void) {
    char buf[64] = {0};

    printf("=== crackme04 (anti-debug) ===\n");
    if (being_debugged()) {
        printf("[-] debugger detected. decoy flag: netmask{n0t_lik3_th1s}\n");
        return 2;
    }

    printf("key: ");
    if (!fgets(buf, sizeof(buf), stdin)) return 1;
    buf[strcspn(buf, "\r\n")] = '\0';

    if (strcmp(buf, "ant1ant1debug") == 0) {
        printf("\n[+] clean process, valid key\n");
        printf("[+] flag: netmask{watch3rs_bec0m3_watch3d}\n");
        return 0;
    }
    printf("\n[-] wrong key (and no, you were not debugged — or were you?)\n");
    return 1;
}
