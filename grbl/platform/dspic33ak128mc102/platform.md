# dsPIC33AK128MC102 port — THE THIRD ISA FAMILY

Microchip dsPIC33A 32-bit DSC core: neither ARM nor RISC-V. 200 MHz,
dual-precision hardware FPU, motor-control PWM + SCCP, PPS pin remap,
28-pin package — the modern heir to the ATmega328p DIP-28 form factor.
Community hardware reference: MC106 Curiosity (needs its own `boards/`
dir; the shipped `boards/generic` is a paper pinout for the bare chip).

## Status (Phase 6 rolling #2 — Steps 3-6 COMPLETE, 2026-07-26)

- M1: skeleton compiles (toolchain crt0 + linker-synthesized IVT — see
  `platform.c` startup-model banner for why there is no `startup.c`).
- M2: clock 200 MHz (FRC→PLL1, sequence from Microchip's own dsPIC33A
  clock docs — **UNVERIFIED ON SILICON**, no emulator exists) + GPIO
  (LAT/PORT/TRIS/ANSEL/CNPU model, token-paste accessors, critical-
  section-wrapped single-bit writes — see `gpio.h` ATOMICITY note).
- M3: all core `.c` compile.
- **Steps 3-6 (real implementations)**: T1 = stepper timer, SCCP1 =
  pulse-reset (software x8 rescale of the 8-bit overflow-horizon contract
  instead of a hardware /8 prescale — this timer doesn't have one),
  SCCP2 = spindle PWM, UART1 (freshly mined register model — no donor
  port existed for this ISA's UART), NVMEM via ROW PROGRAM into a
  linker-reserved fixed flash address (`__attribute__((address(...)))`,
  link-tested clean against the unmodified vendor `.gld`), GPIO Change
  Notification arm/disarm, real ISR bodies (flag-clear-first, dispatching
  to the core-supplied `__isr_step_impl`/`LIMIT_INT_IRQHandler`/
  `CONTROL_INT_IRQHandler`), real `_delay_us/_delay_ms` via the
  toolchain's own `__delay32`/`libpic30.h`. **`make BUILD=DEBUG` and
  `make BUILD=RELEASE` both build the full ELF+hex and link with ZERO
  `PORT_TODO_*`** (verified: `nm | grep PORT_TODO` empty on both). Sizes:
  RELEASE 41816 B (~41.8KB) code / DEBUG 53220 B (~53.2KB) code (128KB
  flash), RAM ~3.8KB RELEASE (16KB). **These figures are exact and
  reproducible, not approximate** — settled by codegen comparison, not by
  reading the compiler's message text: a RELEASE (`-Os`) build prints
  `Options have been disabled due to restricted license` from `xc-dsc-gcc`
  on every translation unit, and a rebuild of the whole firmware with an
  explicit `-O2` in place of `-Os` produces a BYTE-IDENTICAL 41816 B image
  with zero restriction messages. So the free/unlicensed tier of this
  Microchip compiler silently substitutes `-O2` codegen for `-O3`/`-Os`
  rather than failing loudly or producing a fuzzy result — RELEASE here is
  `-O2`-equivalent codegen, not true `-Os`, but its byte count is exact.
  This is Microchip's own licensing-tier behavior, not this port's install
  recipe: `--LicenseType FreeMode` is the installer's own default (the
  `WorkstationMode`/`NetworkMode` alternatives need an account-bound
  activated license file, not a flag), and Microchip's own bundled manual
  describes the free tier as giving "the basic amount of code optimization"
  vs "increased levels" on PRO. A 60-day free PRO evaluation exists but is
  account-bound, interactive, time-limited, and not CI-scriptable, so it
  isn't a path to a truly-`-Os` automated build — don't re-investigate it.
  (The multi-segment Harvard memory layout — `readelf` shows multiple
  `.text` sections at different program-memory pages — and the lack of a
  `size` tool in xc-dsc are real quirks of this ISA, but they don't affect
  the byte counts above: those come from the same linked `.elf` both
  times.) See CONTRACTS.md §16 items 12-20 for the full register-
  fact writeup, including two specific RM-only gaps (SCCP MOD/CLKSEL/
  TMRPS encodings, PPS OUTPUT function-select codes) that are structurally
  real but numerically UNVERIFIED pending hardware bring-up.
- **FP=DOUBLE is this port's declared default** (native DP FPU — the
  chip class CONTRACTS.md §17.3 was written for): `Makefile` sets
  `FP ?= DOUBLE`, disarms `assert_no_double.sh`, and documents why inline.
  `FP=SINGLE` remains available (bidirectional knob, `boards/generic/
  prelude.h` carries the same SP libm shim as samd21) but is not the
  default and has not been runtime-exercised (no dsPIC33A emulator
  exists).
- NOT in CI yet: unattended toolchain fetch in CI is a separate ledger
  item (PLAN.md).

## Known toolchain defects

- **`xc-dsc-nm --print-size` silently drops ~90% of function symbols**
  (found auditing `artifacts/dspic33ak128mc102/*.syms` — it summed to
  ~8.2KB against the 41816B RELEASE binary). Root cause, confirmed via
  `xc-dsc-objdump -t`: xc-dsc-gcc/as only emits an ELF `.size` for a small
  minority of functions (~50-60 of ~210 in this port; libm/vendor-object
  functions mostly, plus a handful of core ones). For the rest the symbol
  table entry has NO size at all — not a printed `0`, an absent field —
  and `nm --print-size` combined with `--size-sort` doesn't list a
  sizeless symbol with a blank/zero size, it omits the row entirely. That
  silently dropped `main`, `protocol_main_loop`, `st_prep_buffer`,
  `gc_execute_line`, and most of the rest of this port's code from the
  tracked artifact, understating it by ~33KB with no visible error.
  Fixed in `tools/build_artifacts.py` (`gen_symbol_map` /
  `_estimate_code_symbols`): for this unit only, symbols nm can't size are
  recovered from `xc-dsc-objdump -t` (addresses) + `-h` (code-section
  bounds) via address-delta-to-next-function, capped at the containing
  section's end. Recovered rows are tagged `objdump addr-delta estimate`
  in the `.syms` file — accurate to within a few bytes (jump-table/padding
  bytes between two functions can land on either neighbour depending on
  scan order) but no longer silently absent. Spot-checked against known
  quantities (see "Known repo-wide dead code on this port" below): the
  estimator reproduces `report_echo_line_received`=40B,
  `delay_us`=108B, `serial_get_{rx,tx}_buffer_count`=28B each,
  `plan_get_block_buffer_count`=28B exactly.
- **No `size` tool ships with XC-DSC** (noted above already): `xc-dsc-nm`
  and `xc-dsc-objdump` exist, `xc-dsc-size` does not.
- **Multi-segment Harvard `.text` layout**: `objdump -h` shows five
  separate `.text`-named output sections plus a dozen more anonymous
  per-translation-unit scratch sections (`/tmp/ccXXXXXX.s.scnN`) at
  disjoint addresses, all CODE-flagged and contiguous with each other in
  the address space. The objdump-fallback code above treats every
  CODE-flagged section (by address range, not by literal `.text` name) as
  one flat function-address space — restricting to sections literally
  named `.text` silently drops most of the binary's real code (confirmed
  empirically: name-only filtering totalled ~8KB of ~42KB actual code).

## Known repo-wide dead code on this port

232B of core-mandated or TU-replacement-mandated code that every
`-ffunction-sections`/`--gc-sections` port strips but this one can't (no
`--gc-sections` on this toolchain, see Makefile): `delay_us` (108B,
`grbl/nuts_bolts.c`, zero callers anywhere in this repo — CORE file,
untouchable), `report_echo_line_received` (40B, `grbl/report.c`, guarded
off by default via `REPORT_ECHO_LINE_RECEIVED` but the function itself is
unconditional — CORE file, untouchable), `plan_get_block_buffer_count`
(28B, `grbl/planner.c`, zero callers — CORE file, untouchable),
`serial_get_rx_buffer_count`/`serial_get_tx_buffer_count` (28B each,
`serial.c` — this port's own TU-replacement file, but CONTRACTS.md §7
requires a TU-replacement to honor the FULL `serial.h` API, which
declares both; every other TU-replacement port (samd21, ch32v006, ch570)
implements them too, unused, for the same reason). None of the four are
removable without either editing an untouchable core file or breaking
the TU-replacement API-completeness contract — this cost is accepted and
documented, not fixed.

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
- **Interrupt nesting is native** (`handlers.c`, `platform.c`): IPCx
  priorities let the pulse-reset IRQ genuinely preempt the stepper IRQ
  (CCT1IP=5 > T1IP=4) — better than the M0+ reference posture.
- **NVMEM window reserved by fixed address, not a custom linker script**
  (`nvmem.c`): `__attribute__((address(0x81F800)))` on a `static const`
  object claims the last 2KB erase page of program flash; link-tested
  clean against the *unmodified* vendor `.gld` — future code growth that
  collides fails the link loudly instead of corrupting silently.
- **PPS is two different verification classes** (`platform.h`): RPn INPUT
  muxing is fully verified (field = literal RPn number); RPn OUTPUT
  muxing uses UNVERIFIED placeholder function-select codes (no
  value-group exists anywhere in the vendored `.atdf` for any `RPORx`
  field — genuinely RM-only, unlike most of this port's other gaps).
- **FP=DOUBLE is this port's declared default** (`Makefile`): native DP
  FPU makes 64-bit float arithmetic native-cost, not soft-float-tax —
  the chip class CONTRACTS.md §17.3 named before this port existed.
