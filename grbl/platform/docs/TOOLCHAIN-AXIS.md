# Toolchain Axis (`TC=gcc|clang`) — Recon Findings and Design

Status: RECON, not landed. No `common/toolchain/*.mk` files exist yet. This
document is the output of a probe session (2026-07-26): measure what clang
actually does to this tree before proposing to build anything on top of it.
Numbers below are measured, not estimated — build logs live in the probe
session's scratch dir, cited inline where useful, not committed (a probe
does not leave build litter in the tree).

## 0. Why this axis at all

Not to replace gcc. avr-gcc 7.3.0 defines the golden AVR MD5 by construction
— there is no "better" compiler for that target, only a different one. The
value of a second compiler is a second, independently-implemented set of
diagnostics and a second, independently-implemented LTO — this project has
been bitten twice (BUG #21: LTO deleted an unreferenced vector table; BUG
#23: LTO deleted an unreachable init chain) by exactly the class of failure
where "the compiler quietly removed something real" and only adversarial
review caught it. A second LTO implementation is a structurally different
chance to catch the third instance of that class before a user does.

## 1. Availability (measured this session)

- `clang` 18.1.3 (Ubuntu), `lld`/`ld.lld` 18.1.3, `llvm-nm`/`llvm-objcopy`/
  `llvm-objdump`/`llvm-size`/`llvm-ar`/`llvm-readelf` all present at
  `/usr/bin`. `clang --print-targets` includes `arm`, `arm64`, `arm64_32`,
  `armeb` — no `avr` target (AVR backend was removed from upstream LLVM;
  `clang --target=avr` still works because Ubuntu's clang package links an
  AVR backend some distros keep — do not assume this is portable to every
  clang install; it happened to be present here).
- `arm-none-eabi-gcc` 13.2.1 (Debian/Ubuntu package), sysroot resolved via
  `-print-sysroot`/`-print-file-name=`: headers at
  `/usr/lib/arm-none-eabi/include`, per-multilib libs under
  `/usr/lib/arm-none-eabi/newlib/<multilib>/` (libc/libm) and
  `/usr/lib/gcc/arm-none-eabi/13.2.1/<multilib>/` (libgcc). clang needs both
  `-L` paths explicitly (its own multilib autodetection does not know this
  gcc's layout) plus `--sysroot=/usr/lib/arm-none-eabi` for headers.
- `avr-gcc` 7.3.0 at `/usr/bin` (matches the golden-MD5 toolchain exactly —
  confirmed by rebuilding `make -C grbl/platform/atmega328p` — no wait,
  atmega328p is exempt from the platform Makefile pattern; confirmed via
  root `Makefile`'s own `make validate`, MD5 `79af184e67b27defd27a39309ac53563`,
  unchanged throughout this session).
- RISC-V (`riscv64-unknown-elf-gcc`) and XC-DSC (`/opt/xc-dsc`) toolchains
  also present but not exercised by this probe — the recon target was one
  representative ARM port per the brief; RISC-V/dsPIC clang cross-compilation
  is a follow-up, not covered here.

## 2. Can clang build one ARM port? (stm32f411, chosen over samd21 — one
board, no per-board `config.h` selection, fewer moving parts)

**Compiles and links: yes**, with caveats below. Built RELEASE by hand
(no Makefile plumbing landed — see §6) mirroring `common/stm32/common.mk`'s
real flag set:
`--target=arm-none-eabi -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16
-mfloat-abi=hard --sysroot=/usr/lib/arm-none-eabi -Os -flto=thin`, linked
with `-fuse-ld=lld` against the two `-L` paths above.

**Two real, load-bearing problems found, one blocking, one already fixed
(and now committed, unrelated to this axis):**

1. **BLOCKING: clang has no equivalent to `-fsingle-precision-constant`.**
   Checked `clang --help` and `clang -cc1 --help` for every flag with
   "single-precision"/"excess-precision"/"fp-eval" in the name —
   `-cl-single-precision-constant` exists but is OpenCL-only (rejected for
   plain C); `-fexcess-precision=`/`-ffp-eval-method=` control evaluation
   width for already-typed expressions, not the type of a bare literal.
   GCC's flag exists specifically to keep unsuffixed floating literals
   `float` instead of promoting to `double` — the entire FP=SINGLE
   contract (CONTRACTS.md §17) that keeps every non-AVR port AVR-faithful
   (avr-gcc's `double==float`) depends on it. Without it, ordinary mixed
   float/literal expressions throughout `planner.c`/`stepper.c`/
   `motion_control.c`/`gcode.c` silently promote through double, and
   `tools/assert_no_double.sh` (run with `llvm-nm`, works fine
   mechanically) **FAILS**: 23 distinct `__aeabi_d*`/`__*df2`/`__*df3`
   double-precision soft-float symbols get linked in, none of which exist
   in the gcc build. This is not a missing feature that can be worked
   around by a prelude macro trick — the existing SP-libm call-site
   mapping (`sqrt(x)` → `sqrtf(x)` etc., already in every port's
   `prelude.h`) only rewrites named function calls, not bare arithmetic
   between a `float` and an unsuffixed literal.
   **Consequence for the axis**: any clang build of an FP=SINGLE port is,
   today, silently an FP=DOUBLE-semantics build wearing an FP=SINGLE
   label — larger code, slower (soft double math on an SP-only FPU), and
   a real behavioral deviation from the AVR-faithful semantic this project
   otherwise polices with a hard post-link assert. This is the single
   fact that should decide the scope question (see §8).

2. **Real (now fixed, independent of this axis): `stm32f411/script.ld`'s
   `.bss`/`.stack`/`.heap` output sections have no `(NOLOAD)` marker.**
   GNU ld infers `SHT_NOBITS` for an output section whose only content is
   a location-counter advance (no input sections assigned); `ld.lld` does
   NOT make the same inference and emits real, file-backed `SHT_PROGBITS`
   for exactly the same script — `readelf -l` on the two linkers' outputs
   for the identical script shows GNU ld splitting `.bss`/`.stack`/`.heap`
   into three `PT_LOAD` segments with `FileSiz=0`, while lld merges them
   into one segment with `FileSiz==MemSiz`. Consequence:
   `objcopy -O binary` on the lld-linked ELF produced a **402 MB** `.bin`
   (padding the address gap between FLASH at `0x08000000` and the
   RAM-resident heap section lld treated as loadable) instead of ~26 KB.
   Fix verified: adding `(NOLOAD)` to the three output section headers
   (a standards-compliant linker-script directive both GNU ld and lld
   honor identically) restores the expected `.bin` size and `readelf -l`
   segment layout under lld, with **zero effect** on the GNU ld/gcc build
   (confirmed: identical section layout before/after the `(NOLOAD)` edit
   when linked with GNU `ld`). **This is a portable, safe fix, independent
   of the TC axis decision** — every port's `script.ld`/linker script that
   defines `.bss`/`.stack`/`.heap` this way should get the same
   `(NOLOAD)` annotation regardless of whether `TC=clang` ever lands,
   since it's zero-cost under gcc and prevents a silent multi-hundred-MB
   `.bin` the moment anyone tries lld for any reason (a debug session, a
   different distro's toolchain, anything). Not applied to any port's real
   `script.ld` in this session — recorded here as a ready-to-land,
   separately-reviewable one-liner, not bundled into this doc-only probe.

**Size comparison** (both `-Os -flto`/`-flto=thin`, `FP=SINGLE` requested
on both sides — clang's number is therefore not a fair fully-SINGLE
comparison per finding 1 above, but is the number you get with today's
flags):
| | gcc (LTO) | clang (ThinLTO) |
|---|---|---|
| `.text` | 26132 | 37220 |
| `.data` | 80 | 296 |
| `.bss` | 129968 | 129752 |
| `assert_no_double.sh` | PASS | **FAIL** (23 DP symbols) |

The clang `.text` delta (+11 KB, +43%) is dominated by the DP soft-float
library pulled in by finding 1, not by clang being a worse optimizer per
se — not a clean apples-to-apples number until finding 1 has an answer.

**Boot sanity**: with the `(NOLOAD)` fix applied, `common/boot_check.sh`
(BUG #21 ratchet) and `common/init_check.sh` (BUG #23 ratchet) both PASS
on the clang/ThinLTO binary via `llvm-nm` — vector table at `0x08000000`,
`Reset_Handler`/`hal_system_init`/`hal_clock_config`/`hal_gpio_init` all
defined and reachable. `llvm-nm` and `llvm-objcopy` read gcc-built ELFs
without incident (tested directly: `llvm-nm build/grbl_stm32f411.elf`
lists the same symbols GNU `nm` does) — no tool-compatibility gap on
either side of the pairing (gcc ELF + llvm-nm, clang ELF + GNU nm both
work; not required for a landing decision but confirms the "swap NM per
toolchain" plumbing in §4 has no hidden mismatch to design around).

## 3. Core-diagnostic catalogue (the important deliverable)

Complete list of what clang emits on **core** files (`grbl/*.c`, outside
`grbl/platform/`) — never on port files, since those already differ and are
expected to. No core file was edited to silence anything. Two targets
tested: ARM (stm32f411's flags, `-Os -flto=thin`) and AVR (syntax-only pass
with the golden Makefile's flags, `-Os -mmcu=atmega328p`).

### ARM target, core-file diagnostics

| File:line | Diagnostic | Judgement |
|---|---|---|
| `stepper.c:1015` | `-Winteger-overflow`: `TICKS_PER_MICROSECOND*1000000*60` overflows `int`, folds to `1465032704` | **Real, not noise.** gcc's `-Woverflow` already flags the identical line (verified: it was sitting in `ci/warn_baseline_stm32{f103,f411,h523}.txt` as accepted debt) — this is BUG #18's exact class (F_CPU needs a `UL` suffix; already fixed on samd21/ch32v006's own Makefiles) **never rolled out to `common/stm32/common.mk`**, which still has plain `-DF_CPU=$(CLOCK)` with no suffix. Live, currently-shipping, on stm32f103/f411/h523/hc32f460 (every port sharing that common.mk). Flagged here, **not fixed in this session** — out of scope for a toolchain-axis probe, a one-line Makefile fix (`$(CLOCK)UL`) for whoever picks it up next. |
| `settings.c:339` | `-Wconstant-conversion`: `get_limit_pin_mask()` truncates `1<<Z_LIMIT_BIT` (1024→0) for a `uint8_t` return | **Real — this is BUG #26** (fixed this session, see PLAN.md/CONTRACTS.md). gcc's `-Woverflow` had already caught the identical line on all three affected ports; both were sitting in the accepted warning baseline unexamined. The value clang added here was not a fact gcc lacked, it was a sharper diagnostic name prompting someone to actually trace the consequence. |
| `settings.c:26` | `-Wduplicate-decl-specifier`: `const __flash settings_t defaults` — `__flash` expands to `const` on this port's prelude for non-AVR, giving `const const` | Noise. Redundant qualifier, zero behavioral effect, gcc doesn't warn on it by default (no GCC-equivalent warning flag in `-Wall -Wextra`). |
| `nvmem.c:127,149` | `-Wint-in-bool-context`: `(checksum << 1) \|\| (checksum >> 7)` | Noise — already known, already in every port's baseline, already documented as deliberate (CONTRACTS.md §10.4: "Never fix the AVR `\|\|`" — this is the upstream-grbl checksum quirk preserved for byte-golden AVR). |
| `motion_control.c:206` | `-Wunused-parameter`: `cycle_mask` | Noise — already in every port's baseline. |
| `motion_control.c:109` | `-Wabsolute-value`: `fabsf()` given an argument clang infers as `double` | **Symptom of finding 1 (§2), not an independent bug** — the argument is only `double`-typed because of the missing `-fsingle-precision-constant` promoting an unsuffixed literal earlier in the same expression. Disappears once §2's blocker has an answer. |
| `gcode.c`/`report.c`/`system.c` fallthrough warnings | `-Wimplicit-fallthrough=` | Noise — already in every port's baseline, intentional fallthrough with a comment, same as gcc's identical warning. |
| **Hard errors on core code** | **none** | clang compiles every core `.c` file at `-Os` with zero errors, ARM target. |

### AVR target, core-file diagnostics (syntax-only pass, real Makefile flags
plus `-D_AVR_WDT_H_` — see below for why)

| File:line | Diagnostic | Judgement |
|---|---|---|
| `grbl.h:32` → `<avr/wdt.h>` | **HARD ERROR**, not a warning: `value '64' out of range for constraint 'I'` (×2, inside `wdt_enable`/`wdt_disable`) | **Headline finding for AVR.** avr-libc's `wdt.h` selects between an I/O-space inline-asm form (`"I"` constraint, 0–63) and a memory-mapped form via a **runtime** `if (_SFR_IO_REG_P(...))` — a compile-time-constant condition GCC folds and dead-code-eliminates before ever validating the untaken branch's asm constraints. clang validates inline-asm operand constraints in both branches before/independent of that dead-branch elimination, so the untaken branch (which targets I/O space registers, not applicable to `WDTCSR`'s actual address on atmega328p) fails to compile even though it can never execute. **Confirmed this is unconditional, not an `-Os`-only artifact**: re-ran at `-Os` explicitly (the hypothesis in the original brief) — identical failure, ruling out "only broken with optimization off." **Nothing in `grbl/` or `grbl/platform/atmega328p/` calls any `wdt_*` function** (grepped `grbl/*.c grbl/*.h` outside `platform/` — zero hits; CONTRACTS.md §9 already states "no platform implements this family"), so the remedy is a flags-layer one: `-D_AVR_WDT_H_` pre-defines avr-libc's own include guard, skipping the header's body entirely before `grbl.h`'s unconditional `#include <avr/wdt.h>` is reached. Verified: with that one define, all 17 core `.c` files pass `-fsyntax-only` with **zero errors**. This is exactly the kind of flags-layer-only, core-file-untouched remedy CONTRACTS.md's core-purity rule (§4 below) requires. |
| `report.c` (55 lines) | `-Wunknown-attributes`: `unknown attribute '__progmem__' ignored` (`PSTR()` macro → avr-libc's `PROGMEM` → `__attribute__((__progmem__))`) | **Headline finding, functionally severe, not cosmetic.** Verified directly (small isolated test file, not just the warning text): a `const char __attribute__((progmem))` variable, compiled with clang for AVR, lands as an ordinary `R` (rodata) symbol with an **undefined reference to `__do_copy_data`** pulled in — i.e., clang silently drops the attribute and the object falls back to avr-gcc's ordinary Harvard-architecture behavior for `const`: copied from flash to RAM at startup by crt0's data-init loop, not left resident in flash and read back via `LPM`. The GNU named-address-space spelling (`const __flash char x[]`) fares **worse**: it compiles with **no diagnostic at all** and the same wrong placement — clang accepts the syntax and silently discards its meaning. Consequence for a real Tier-1 AVR build: `report.c`'s ~50 status/error `PSTR()` strings plus `settings.c`'s entire default-settings table (`const __flash settings_t defaults`) would all get copied into SRAM at boot instead of staying in flash — on a chip with **2 KB total RAM**, this does not merely waste space, it is very likely a silent RAM overflow with no link-time error (AVR linkers here have no `script.ld`-style `MEMORY{}`/`ASSERT` region enforcement the way the ARM ports do) — exactly the "compiles, links, boots wrong" class this project exists to catch, except the failure mode here is baked into the target's language-extension support, not LTO. This alone is close to disqualifying for AVR (see §8). |
| `stepper.c:326,496`, `serial.c:94,130`, `system.c:64`, `limits.c:107` | `-Wunknown-attributes`: `unknown attribute 'externally_visible' ignored` (ISR macro's `__INTR_ATTRS`) | **Checked, confirmed noise, not a defect.** `externally_visible` is a GCC whole-program-optimization visibility hint; separately verified that the co-occurring `signal` attribute (the one that actually matters — it controls whether the AVR backend emits interrupt-correct prologue/epilogue and `reti` instead of `ret`) **is** recognized by clang: compiled an isolated `ISR(...)` body and inspected the emitted assembly directly — full register/SREG save-restore and a trailing `reti`, byte-for-byte the shape an AVR ISR needs. `externally_visible` being silently ignored has no calling-convention consequence. |
| **Hard errors on core code, unconditional (not `-Os`-dependent), other than `wdt.h`** | **none found** | All 17 core `.c` files pass `-fsyntax-only` once the one wdt.h workaround is applied. |

## 4. ThinLTO differential (stm32f411, `-flto=thin` vs. gcc's `-flto`)

**No BUG #21/#23-class regression found.** `vector_table`, `Reset_Handler`,
`hal_system_init`, `hal_clock_config`, `hal_gpio_init` all present and
reachable in the ThinLTO build (`init_check.sh`/`boot_check.sh` both PASS,
§2). This is expected, not a coincidence: the mitigations those two bugs'
fixes landed (`__attribute__((used))` plus an address-taken reference in
`Reset_Handler`, and a real call from `Reset_Handler` into the init chain)
are portable C mechanisms, not GCC-specific pragmas — so they hold under a
structurally different LTO implementation too. That is itself a useful
negative result: the FIX for BUG #21/#23 was done right the first time
(compiler-portable, not GCC-whisperer tricks), which a second LTO
implementation now corroborates rather than merely assumes.

**One difference found, investigated, confirmed benign**: a straight `nm`
symbol-name diff between the gcc and clang RELEASE ELFs shows ~40 names
present in gcc's output absent from clang's — nearly all of them the
board's unused peripheral IRQ vectors (`ADC_IRQHandler`,
`DMA1_Stream*_IRQHandler`, etc.), each declared
`__attribute__((weak, alias("Default_Handler")))`. clang's LTO resolves
the alias directly to `Default_Handler`'s address at the vector-table's
one use site and does not bother emitting a separate named symbol table
entry for the now-redundant alias name — gcc's LTO keeps the alias name.
**Verified this is a naming artifact, not lost code**: dumped the raw
vector table bytes at `0x08000000` and confirmed the slot for, e.g.,
`ADC_IRQHandler` (array index 34) contains `Default_Handler`'s real
address with the Thumb bit set — the code that runs is identical, only
the debug-visible name for the alias is gone. Also observed: several
internal `static` variables (`block_buffer`, `segment_buffer_head`, `pl`,
`prep`, etc.) lose their names in the clang/ThinLTO symbol table entirely
— expected LTO internalization behavior for locals with no external
reference once whole-program visibility resolves them, not a size or
placement difference (confirmed via the `.bss`/`.data` size table in §2,
once the `(NOLOAD)` fix is applied, sizes track close to 1:1 modulo the
DP-soft-float delta already explained).

**Conclusion: ThinLTO did not find a new instance of the class it was
brought in to find, on this port, this session.** Worth stating plainly
since a negative result here is exactly as valid a probe outcome as a
positive one.

## 5. Layer design (for when/if this lands)

Three layers, cleanly separated so a port's Makefile never has an `ifeq
($(TC),...)` chain:

- **Layer 1 — port semantic** (unchanged, in each port's own Makefile):
  the port declares *what* it wants — `-Os`-class size optimization, no
  double precision, LTO on, freestanding. It does not know or care which
  compiler realizes those wants.
- **Layer 2 — toolchain dialect** (`common/toolchain/gcc.mk`,
  `common/toolchain/clang.mk`, new, not yet written): *how* a given
  compiler spells layer 1's wants — `-Os` vs. `-Oz` (clang's smaller-but-
  slower size level, worth trying if the axis ever lands), `-flto` vs.
  `-flto=thin`, and critically the `CC`/`NM`/`OBJCOPY`/`OBJDUMP`/`SIZE`
  binary names the existing ratchets (`assert_no_double.sh`,
  `init_check.sh`, `boot_check.sh`) already take as parameters — no
  ratchet script needs to change, they already accept the tool name as an
  argument (confirmed this session: `llvm-nm` drops into both scripts'
  existing `nm`-argument slot with zero script changes).
- **Layer 3 — target dialect** (per-port, e.g.
  `stm32f411/Makefile`): `-mcpu=`/`-mfpu=` are identical strings for gcc
  and clang on ARM (confirmed — same flag spelling both toolchains, this
  session's build used the port's real `CPU`/`FPU` Makefile variables
  unchanged). Where a *genuine* per-(platform × compiler) difference
  exists — and after this session there is at least one real candidate,
  §2 finding 1's SP-libm mapping might need a clang-specific prelude
  variant — the naming convention is `EXTRA_CFLAGS_$(TC)` (e.g.
  `EXTRA_CFLAGS_clang`), appended once by layer 2, never an `ifeq` chain
  in the port file.

`TC ?= gcc` in every port's Makefile (or wherever layer 2 is included)
keeps every existing build path byte-identical by default — nothing about
today's `make` invocations changes unless `TC=clang` is passed explicitly.

## 6. Per-port toolchain support (measured/inferred this session)

| Port | `TOOLCHAINS_SUPPORTED` | Why |
|---|---|---|
| `atmega328p` | **gcc only, forever** | Golden MD5 is *defined* by avr-gcc 7.3.0's exact codegen — there is no "clang matches" question to ask, byte-identity to a specific compiler's output IS the spec. Independent of that: clang's AVR target has a hard compile error in avr-libc's `wdt.h` (unconditional, §3) and — more seriously — no working PROGMEM/`__flash` support at all (§3), which for an 18-string-plus-a-settings-table 2 KB-RAM target is close to disqualifying even ignoring the golden-MD5 question. |
| `dspic33ak128mc102` | **XC-DSC only** | Different ISA family entirely (dsPIC33A), no LLVM backend exists for it. Not a clang candidate under any flag combination. |
| `stm32f103`/`stm32f411`/`stm32h523`/`hc32f460` (ARM Cortex-M, FP=SINGLE) | **gcc only, until §2 finding 1 has an answer** | Compiles and links today; `assert_no_double.sh` FAILS because clang has no `-fsingle-precision-constant` equivalent — landing `TC=clang` for these as-is would mean either accepting a silent FP=SINGLE→FP=DOUBLE semantic regression under clang specifically, or disarming the assert for `TC=clang` (which defeats the ratchet's entire purpose for exactly the builds it exists to protect against). Not recommended until one of: (a) a real workaround for the literal-promotion problem is found (unlikely — this is upstream LLVM's decision, not a flag gap), or (b) the port declares FP=DOUBLE under `TC=clang` explicitly and everyone accepts clang verification only ever exercises the DOUBLE-semantics code path, which is a materially weaker verification than what gcc gets. |
| `dspic33ak128mc102`-adjacent native-DOUBLE ports (none landed yet) | n/a | A future FP=DOUBLE-by-design ARM/RISC-V port would not hit finding 1 at all — worth remembering this blocker is FP=SINGLE-specific, not universal. |
| `samd21`, `ch32v006`, `ch570` | **untested this session, same FP=SINGLE blocker expected** | Not built with clang this session (time-boxed to one representative port per the brief) — but all three declare FP=SINGLE the same way stm32f411 does, so §2 finding 1 almost certainly reproduces identically. Should not be assumed fixed without actually building them. |
| `sg2002` | n/a | Design-complete, implementation-deferred (PLAN.md Phase 6) — no code exists to build with either compiler yet. |

**Overall recommendation for this axis's scope, given the data above:
none of the ten ports currently pass a clean `TC=clang` build against the
FP=SINGLE ratchet.** See §8.

## 7. `artifacts/` stays keyed to ONE canonical toolchain (gcc)

`artifacts/` is the release/observability surface (PLAN.md's "track build
artifacts in git" decision) — it must have one unambiguous byte-identity
target per unit or the staleness ratchet (`tools/build_artifacts.py
check`) cannot state a single fact about whether a given commit's
artifact is fresh. clang is a **verification axis**, not a **release
axis**: nothing under `artifacts/` should ever be produced by
`TC=clang`, regardless of whether the axis lands. This needs to be an
explicit, written rule (not just current practice) the moment `TC=clang`
exists as an option at all, because the failure mode is not hypothetical
— `tools/build_artifacts.py build` has no `--toolchain` flag today, and
the very first person who runs it after a `TC` default gets flipped
locally, or who adds `--toolchain=clang` "just to try it," silently
produces a same-named artifact file the manifest cannot distinguish from
a gcc build. The rule this document proposes: `tools/build_artifacts.py`
should refuse (loud error, not silent) to record any `TC` other than the
per-unit canonical one into `artifacts/`, the same way it already refuses
a stale manifest today.

## 8. Warn baselines must be keyed per-toolchain

`ci/warn_baseline_<port>.txt` today implicitly means "gcc's warning set."
The moment clang builds anything, its warning vocabulary is different
enough (different names for overlapping diagnostics, entirely new
categories like `-Wconstant-conversion` with no gcc equivalent, as §3
shows) that reusing the same baseline file either floods the ratchet with
every one of clang's differently-worded restatements of already-accepted
gcc warnings, or — worse — silently accepts clang-only new warnings
because the ratchet was never asked to distinguish. Proposed convention:
`ci/warn_baseline_<port>.<tc>.txt` (e.g.
`ci/warn_baseline_stm32f411.gcc.txt`, `ci/warn_baseline_stm32f411.clang.txt`),
with `ci/warn_ratchet.py` taking the toolchain as an explicit argument
(same pattern as the NM-binary argument it already takes) rather than
inferring it. This session's own core-diagnostic catalogue (§3) is a
worked example of why this matters: several of clang's diagnostics on the
exact same lines gcc already flagged use different `-W` names entirely
(`-Wconstant-conversion` vs. gcc's `-Woverflow`, both on
`settings.c:339`) — a single shared baseline file would treat these as
two different warnings needing two different accept-lines for the same
fact, defeating the "one line per real thing" design the ratchet already
has for gcc alone.

## 9. Core-purity rule — proposed CONTRACTS.md wording

A diagnostic on frozen core code is never fixed by editing core — only
suppressed at the flags/prelude layer, or accepted in a baseline. This
session found several concrete instances of exactly that choice already
being made correctly by the existing project (the `nvmem.c` `||`
quirk, CONTRACTS.md §10.4: "Never fix the AVR `||`") — the rule below
generalizes that precedent explicitly for the toolchain axis, since
clang will surface core-code diagnostics gcc's baseline never had reason
to record.

Proposed section (append at CONTRACTS.md's end per its own numbering
convention — `## §NEW.`, integrator assigns the real number; slug below
is the permanent citation target):

```
<a id="core-purity-under-a-second-toolchain"></a>
## §NEW. Core-purity rule for a second toolchain (placeholder number — integrator assigns the final one; cite this slug, not a number, from elsewhere)

grbl/ (outside grbl/platform/) is byte-for-byte frozen — written for
avr-gcc 7.3.0 in 2011, golden-MD5-gated, and never edited to satisfy any
tool. A second compiler will emit diagnostics on core files a
single-compiler baseline never had reason to record; that is the entire
point of running one. When that happens:

1. NEVER edit a grbl/ core file to silence a diagnostic, on any
   toolchain, for any reason. Not even a redundant-qualifier or
   dead-code-branch fix. The byte-golden AVR invariant is the project's
   central thesis; a "harmless cleanup" on core is not exempt from it
   just because it was clang, not gcc, that found the spot.
2. A diagnostic on core code is handled at exactly one of two layers:
   (a) the flags/prelude layer, if a compiler flag or a pre-processor
   define can make the diagnostic legitimately not apply (example this
   session: `-D_AVR_WDT_H_` skips an unused, uncallable avr-libc header
   whose untaken branch clang validates differently than gcc — a
   flags-layer fact about the header, not a claim about core); or
   (b) accepted into that toolchain's own warn baseline
   (ci/warn_baseline_<port>.<tc>.txt, see the toolchain-axis doc) if
   there is no legitimate flag-layer suppression and the diagnostic is
   judged noise, with the judgement written down at the point of
   acceptance, not silently absorbed.
3. If a diagnostic on core code cannot be handled either way — it is a
   genuine hard error with no flags-layer bypass, and it is not
   noise — that toolchain does not support that port. Record it as a
   TOOLCHAINS_SUPPORTED exclusion (toolchain-axis doc), not as a TODO to
   eventually silence.
4. A hard ERROR (not warning) on core code under a toolchain being
   evaluated is a headline finding, not routine baseline noise — report
   it prominently the moment it's found (this session: avr-libc's
   wdt.h "value out of range for constraint" under clang, handled per
   rule 2(a) since a flags-layer bypass existed; had none existed, rule 3
   would have applied and AVR would already be gcc-only for this reason
   alone, independent of the golden-MD5 argument that also applies).
```

## 10. CI cost, honestly

Not a 10-port × 2-toolchain × 2-flavor cartesian product (40 rows). One
representative per ISA family as a separate matrix leg is the honest
shape:
- ARM Cortex-M family: one port (stm32f411 is already the recon target;
  keep it as the representative rather than re-picking).
- RISC-V family: one port (ch32v006 or ch570 — not tested this session).
- AVR: **not a clang leg at all** — §6/§3 already answer this one, no CI
  minutes should be spent re-asking it per push.
- dsPIC: **not a clang leg** — no LLVM backend exists for the ISA.

That is a 2-row addition (ARM-representative × clang, RISC-V-representative
× clang) to whatever the gcc matrix already is, run as a separate,
clearly-labeled "toolchain verification" leg — not blocking (report-only,
same posture as the provenance workflow), since a clang failure means
"clang found something or clang itself has a gap," neither of which
should block a gcc-verified release the way a real gcc regression would.

## 11. Recommendation

**Do not land the `TC=gcc|clang` plumbing yet.** Every port tested or
reasoned about this session fails the FP=SINGLE ratchet under clang for
a fundamental (not flag-gap) reason — clang has never implemented an
equivalent to `-fsingle-precision-constant`, and that is not something a
prelude trick or a Makefile flag can route around, because it changes the
*type* GRBL core's own unsuffixed floating-point literals get, throughout
`planner.c`/`stepper.c`/`gcode.c`/`motion_control.c`. Landing the axis
today would mean either (a) a `TC=clang` that silently runs every
FP=SINGLE port as FP=DOUBLE with no visible label change, defeating the
whole reason FP=SINGLE exists, or (b) disarming `assert_no_double.sh` for
clang specifically, which converts the project's own hard-won correctness
ratchet into a toolchain-flag-shaped hole.

That said, this was not a wasted probe — it produced:
- A real, safety-relevant bug (BUG #26) found by the clang diagnostic
  pass and independently confirmed real by gcc's own already-emitted (and
  previously dismissed) warning — fixed and committed this session,
  entirely separate from whether the axis ever lands.
- A real, portable linker-script fix (`(NOLOAD)` on `.bss`/`.stack`/
  `.heap`) that benefits every future lld user regardless of this axis's
  fate — not yet applied to any port's real `script.ld` (out of scope for
  a doc-only probe; a one-line follow-up).
- A concrete, falsifiable answer on AVR (`wdt.h` hard error, worked around;
  PROGMEM/`__flash` entirely unsupported, not workable) that settles the
  "could AVR ever join this axis" question independent of the golden-MD5
  argument that already settled it.
- A confirmed-negative ThinLTO differential — clang's LTO does not
  reproduce BUG #21/#23's class on this port, because the fix for both
  was done in a compiler-portable way the first time.

If the FP=SINGLE blocker ever gets a real answer (upstream LLVM support,
or a project decision to accept FP=DOUBLE-under-clang as a documented,
labeled deviation rather than a silent one), stm32f411 is the cheapest
port to revisit first — it is already the recon target, its `script.ld`
fix is known, and its core-diagnostic catalogue (§3) is already complete.
Until then: **the honest scope of this axis today is zero ports**, and
that is a valid, useful answer for the owner to rule on, not a failure of
the probe.
