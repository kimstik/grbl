# Reversal leaf static result

Source `ca68df5c04838cd84450ec0a9a174ba1214f61fe`, isolated from fixed24
`500513d26e14e5a16bcdaa6c7976107d6a5f888c`.
CI https://github.com/kimstik/grbl/actions/runs/45858863352 succeeded.
Frozen packages: avr-gcc16.2.0-1, binutils2.47-1, avr-libc2.3.2-4.

The sole firmware change extracts the existing reversal predicate into
`static uint8_t mc_spline_reversal(float *q, float *r)` with noinline,noclone.
The loop tokens, float initialization, e0/e1/e2 evaluation, a/b accumulation and
`a < 0.0f || b < 0.0f` predicate are preserved. Caller still sets todo=m/2 and
returns at the same point. No RT, geometry, state, density or compiler-option change.

## Whole-image and symbol sizes

| Mode | Control flash | Leaf flash | Net change | Control helper | Leaf caller | Predicate | Caller + predicate |
| ---- | ------------: | ---------: | ---------: | -------------: | ----------: | --------: | -----------------: |
| G94  |         32316 |      32346 |        +30 |           1588 |        1236 |       382 |               1618 |
| G93  |         32456 |      32476 |        +20 |           1728 |        1366 |       382 |               1748 |

All images fit32768. Leaf boot32256 deficits are90/220 bytes; control deficits
60/200. Static RAM remains1670, data0. Independent ELF section parsing confirms
sizes; both matched control ELFs are byte-identical to bounded CI45851819455.
The caller shrinks352/362 bytes, but the382-byte callee exceeds that saving.
The helper-pair increase accounts for the whole-image increase. Driver remains
640 bytes and parser7840 bytes. No 200-byte saving was obtained.

## Frames and nested chain

Production disassembly, local frame bytes excluding saved registers/return:

| Mode | Control mc_spline_next | Leaf mc_spline_next | Predicate |
| ---- | --------------------: | -----------------: | --------: |
| G94  |                    68 |                 48 |        20 |
| G93  |                    70 |                 50 |        20 |

Control/candidate caller saves18 registers (r2..r17,Y). Predicate enters shared
prologue at r4, saving16 registers (r4..r17,Y). Each active AVR call adds a2-byte
return address. Thus the helper portion of the active reversal chain is:
G94 control68+18+2=88, leaf48+18+2+20+16+2=106 bytes;
G93 control70+18+2=90, leaf50+18+2+20+16+2=108 bytes.
The extracted leaf adds18 bytes at that point despite a20-byte smaller caller.

These counts exclude deeper floating-point library calls, upstream callers and
interrupts; they are not measured global stack peaks. Parser and spline-driver
local frames remain74 and22 bytes. No production motion/stack measurement was
performed, and no smaller-peak claim follows from the smaller caller.

Useful addresses in leaf G93: predicate0x0402 size0x017e, frame load0x0402=20,
shared prologue entry0x7cf4 (r4); caller0x171e size0x0556, frame load0x171e=50,
shared prologue entry0x7cf0 (r2). Control G93 caller0x15a0 size0x06c0, frame70.

The requested static decision is negative: no net flash gain. The experiment
stops here, retaining branch and artifacts. No runtime/native target identity,
reversal corpus, actual no-Z G93, timing or motion follow-up was run. Source-level
operation identity is not claimed as measured binary output identity. No other
code location was changed to pursue a saving after this result.
