# crackme09 — SOLUTION (hard · 500 pts)

## Goal
Answer `hakuna` then `matata`, waiting ≥ 3 seconds between inputs —
without tripping the timing check while debugging.

## The mechanics
`time(NULL)` wall-clock delta between the two `fgets` calls. It defeats:
* scripted instant answers (decoy flag path)
* debuggers that pause the process (wall clock keeps running — but your
  *input latency* is what is measured, so a human wins trivially)

## The lesson
Timing checks are anti-tamper, not anti-human. Reverse them by reading
the two `time()` calls and what compares the deltas — then simply play
by the rules while you instrument everything else.

```
first : hakuna
(wait 4 seconds — count them, it builds character)
second: matata
flag  : netmask{t1m1ng_1s_a_s1de_channel}
```

## What you learned
* Wall-clock ≠ CPU-clock: `clock()` measures CPU time, `time()` measures
  real time — anti-debug uses the one your tool can't fake easily
* Timing is also an *attack*: the same primitive leaks data via cache
  timing (see tutorials/crypto/03-side-channel.md)
