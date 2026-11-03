# 04 — Blockchain RE

> Smart contracts are public bytecode executed by everyone — the most
> reversible software on earth. This lesson: how to read EVM and find
> the classic bug classes.

## The environment

* EVM = stack machine, 256-bit words, opcodes are one byte
* Bytecode on-chain; source often unverified → RE required
* Storage = key/value slots; memory vs storage vs calldata

## Reading bytecode on this OS

```bash
# disassemble EVM hex with pwntools/evm tools — even python suffices:
python3 - <<'EOF'
code = "608060405234801561001057600080fd5b50..."   # your contract
ops = {0x60:"PUSH1",0x01:"STOP",0x50:"POP",0x55:"SSTORE",0x54:"SLOAD",
       0x34:"CALLVALUE",0xf0:"CREATE",0xff:"SELFDESTRUCT"}
i = 0
while i < len(code):
    b = int(code[i:i+2],16)
    name = ops.get(b, f"0x{b:02x}")
    arg = code[i+2:i+4] if name=="PUSH1" else ""
    print(f"{i//2:04x}: {name} {arg}")
    i += 4 if name=="PUSH1" else 2
EOF
```
(For real work: install an EVM decompiler in your venv —
`pip install panoramix-decompiler` / heimdall-rs are the modern picks.)

## The classic vulnerability classes

| Bug | Shape | Famous incident |
|---|---|---|
| Reentrancy | external call before state update | The DAO (2016) |
| Integer overflow | `+=` on uint256 without checks (<0.8.0) | BEC token |
| Access control | missing `onlyOwner` on critical fns | Parity wallet |
| Unchecked return | low-level `call` return ignored | countless |
| Front-running | tx-order-dependent logic | FOMO3D |
| Storage collision (proxy) | upgrade clashes slots | several proxies |

## Workflow for an unverified contract

1. Fetch bytecode (a block explorer API or a local node)
2. Disassemble → identify: storage layout, external call sites,
   ownership checks
3. Decompile (panoramix/heimdall) → reconstruct source
4. Diff against known bug shapes (table above)
5. Validate the finding on a **local fork** (anvil/hardhat in a VM) —
   never on mainnet without authorization and bug bounty scope

## Ethics frame

Bug bounty programs (Immunefi & co) explicitly authorize this research
with rules. Mainnet testing outside scope = fraud, full stop.
