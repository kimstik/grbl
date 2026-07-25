# dsPIC33AK128MC102 port — THE THIRD ISA FAMILY

Microchip dsPIC33A 32-bit DSC core: neither ARM nor RISC-V. 200 MHz,
dual-precision hardware FPU, motor-control PWM + SCCP, PPS pin remap,
28-pin package — the modern heir to the ATmega328p DIP-28 form factor.
Community hardware reference: MC106 Curiosity (needs its own `boards/`
dir; the shipped `boards/generic` is a paper pinout for the bare chip).

## Status (Phase 6 rolling #2, M1–M3 complete)

- M1: skeleton compiles (toolchain crt0 + linker-synthesized IVT — see
  `platform.c` startup-model banner for why there is no `startup.c`).
- M2: clock 200 MHz (FRC→PLL1, sequence from Microchip's own dsPIC33A
  clock docs — **UNVERIFIED ON SILICON**, no emulator exists) + GPIO
  (LAT/PORT/TRIS/ANSEL/CNPU model, token-paste accessors, critical-
  section-wrapped single-bit writes — see `gpio.h` ATOMICITY note).
- M3: all core `.c` compile; `make link` lists exactly the PORT_TODO_*
  symbols for timers/serial/nvmem/handlers (Steps 3–6, next batch).
- NOT in CI yet: unattended toolchain fetch in CI is a separate ledger
  item (PLAN.md).

## Toolchain (verified recipe — PLAN.md Decision Log, EULA owner-approved)

1. XC-DSC v3.30 (83 MB, SHA-256
   `0df20c1a552bf0ce08aa139b9cb1efd71bf65b9d9f37e3982763f4f8738bfa11`):
   `https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc-dsc-v3.30-full-install-linux64-installer.run`
2. Unattended install (trailing `--netservername ""` REQUIRED though
   undocumented):
   ```
   ./xc-dsc-v3.30-full-install-linux64-installer.run --mode unattended \
     --unattendedmodeui none --prefix /opt/xc-dsc --LicenseType FreeMode \
     --ModifyAll 0 --netservername ""
   ```
3. Device Family Pack (Apache-2.0; an `.atpack` is a zip):
   `https://packs.download.microchip.com/Microchip.dsPIC33AK-MC_DFP.1.5.263.atpack`
   → unzip to `/opt/Microchip.dsPIC33AK-MC_DFP.1.5.263` (or set `DFP_PATH`).

Build: `make BUILD=DEBUG|RELEASE [TOOLCHAIN_PATH=…/bin] [DFP_PATH=…]`;
`make link` = linker-as-checklist diagnostic.

Compile pattern (all three parts load-bearing): `-mcpu=33AK128MC102
-mdfp=<dfp>/xc16` **and** `-Wl,--script=<dfp>/.../p33AK128MC102.gld`
(the toolchain's built-in default linker script is 30F-era).

## ISA-specific decisions (details in file headers)

- **DFP headers, not clean-room** (`gpio.h` header): the DFP is
  Apache-2.0 (unlike Atmel/ASF's proprietary headers that forced the
  samd21 clean-room route) and is also the compiler's own `-mdfp` source
  of device truth.
- **Toolchain crt0 + linker-synthesized IVT** (`platform.c` banner):
  dsPIC33A vectors are addresses filled in by the linker from canonical
  ISR names; a hand-written `vector_table[]` would fight the toolchain.
  Clock config runs pre-main via `__attribute__((user_init))`.
- **No memory-barrier instructions exist on this ISA** (`platform.h`):
  single core, no cache, in-order — `__DSB/__DMB` are compiler barriers.
- **AVR SBI atomicity does NOT transfer** (`gpio.h`): `LATx |= bit` is a
  3-instruction RMW at `-Og`/`-Os` (disasm-proven) and there are no
  LATxSET/CLR registers → GPIO_BSET/BCLR are critical-section wrapped.
- **Interrupt nesting is native** (`handlers.c`): IPCx priorities let the
  pulse-reset IRQ genuinely preempt the stepper IRQ (better than the
  M0+ reference posture; Step 3 must set priorities explicitly).
