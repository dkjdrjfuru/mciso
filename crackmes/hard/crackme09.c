/*
 * crackme09 — hard · time-based gate
 * ------------------------------------
 * Tier:   HARD (500 pts)
 * Skill:  recognise an anti-instrumentation timing check and keep your
 *         cool under it
 *
 * Rule of the challenge: the SECOND input must arrive >= 3 seconds after
 * the first. Fast answers get a decoy. Slow but wrong answers fail
 * normally. Debuggers that single-step through the sleep will trip the
 * wall-clock comparison — wall clock, not CPU clock.
 */
#include <stdio.h>
#include <string.h>
#include <time.h>

static void now_str(char *out, size_t n) {
    time_t t = time(NULL);
    struct tm *tm = localtime(&t);
    strftime(out, n, "%H:%M:%S", tm);
}

int main(void) {
    char a[64] = {0}, b[64] = {0};
    char t1[16] = {0};

    printf("=== crackme09 (patience check) ===\n");
    now_str(t1, sizeof(t1));
    printf("first word : ");
    if (!fgets(a, sizeof(a), stdin)) return 1;
    a[strcspn(a, "\r\n")] = '\0';

    long t0 = (long)time(NULL);
    printf("second word (wait >=3s before answering): ");
    if (!fgets(b, sizeof(b), stdin)) return 1;
    b[strcspn(b, "\r\n")] = '\0';
    long dt = (long)time(NULL) - t0;

    if (dt < 3) {
        printf("\n[-] only %lds. instant answers are scripted answers.\n", dt);
        printf("[-] decoy: netmask{t00_f4st_f0r_m3}\n");
        return 2;
    }

    if (strcmp(a, "hakuna") == 0 && strcmp(b, "matata") == 0) {
        char t2[16] = {0};
        now_str(t2, sizeof(t2));
        printf("\n[+] patient AND correct (%s -> %s, %lds)\n", t1, t2, dt);
        printf("[+] flag: netmask{t1m1ng_1s_a_s1de_channel}\n");
        return 0;
    }
    printf("\n[-] words wrong (but your patience was noted)\n");
    return 1;
}
