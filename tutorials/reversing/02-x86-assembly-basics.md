# 02 — x86-64 Assembly Basics

> You cannot read decompilers well without reading the asm they came from.

## The registers that matter

| Register | Role | Caller-saved? |
|---|---|---|
| `rax` | return value, scratch | yes |
| `rdi rsi rdx rcx r8 r9` | argument 1..6 | yes |
| `rsp` / `rbp` | stack pointer / frame | — |
| `rbx rbp r12–r15` | callee-saved locals | no |
| `rip` | instruction pointer (never direct) | — |

Syscall ABI: number in `rax`, args in `rdi/rsi/rdx/r10/r8/r9`, `syscall`.

## The ~20 instructions that cover 95% of RE

```asm
mov  rax, rbx        ; copy
lea  rax, [rbx+8]    ; compute ADDRESS (not load) — strings/structs
add / sub / imul     ; arithmetic
xor  eax, eax        ; idiom: rax = 0
cmp  rax, 0x10       ; set flags
jz / jnz / jg / jl   ; branch on flags
call / ret           ; functions (push/pop return address)
push / pop           ; stack
movzx / movsx        ; widen (unsigned/signed)
shl / shr / sar      ; shifts (sar keeps sign)
test eax, eax        ; idiom: compare to zero
xchg, cdq, cqo       ; sign-extend before idiv
```

## Stack frame of a classic function

```asm
push rbp
mov  rbp, rsp
sub  rsp, 0x30       ; locals
; ... args: rdi=arg1, rsi=arg2 ...
call foo
; return in eax/rax
leave
ret
```

## Reading a disassembly with objdump

```bash
objdump -d -M intel ./crackmes/easy/binary/crackme02 | less
objdump -d --start-address=0x401100 --stop-address=0x401160 -M intel ./bin
```

## Common compiler idioms

* `xor eax,eax` before a call = zero the var
* `lea rdi, [rip+0x2f1a]` = reference a string (PIE binaries)
* `cmp` + two `jz` = `switch` fragments
* `imul` by `0x66666667` then `shr` = compiler-made division by 10

## Practice

```bash
gcc -O0 -o /tmp/t tutorials-assets 2>/dev/null || true
objdump -d crackmes/medium/binary/crackme05 | less   # find the VM dispatch
r2 -d crackmes/easy/binary/crackme01                 # pdf @ main
```

> Next: 03-ghidra-basics — where asm becomes pseudo-C.
