# tools/

## gen_compile_commands.py

Generates `compile_commands.json` (repo root) for clangd/LSP, using only the
python3 standard library - no `bear`, no `compiledb`, no pip installs.

It works by asking `make` itself what it would do: `make -C
grbl/platform/<platform> -nB BUILD=<build> [BOARD=<board>]` prints every
compile recipe line without running the compiler (`-n` = dry run, `-B` =
rebuild everything so no line is skipped as "up to date"). The script parses
those printed lines for compiler invocations and keeps every flag verbatim,
including the `-include gpio.h -include ../common/gpio.h ...` chain each
platform uses for its "invisible porting" (see `grbl/platform/common/gpio.h`)
- clangd needs those to resolve the same headers the real build sees.

Because it only ever runs `make -n`, it works even when the target
toolchain (`arm-none-eabi-gcc`, `avr-gcc`, `riscv64-unknown-elf-gcc`, ...)
isn't installed.

### Usage

```sh
tools/gen_compile_commands.py <platform> [<platform> ...] [options]

  --board BOARD        BOARD make variable (e.g. samd21: megarm|generic)
  --build BUILD         BUILD make variable (default: DEBUG)
  --var KEY=VALUE       extra make variable, repeatable
  --output PATH         output path (default: <repo_root>/compile_commands.json)
  --make PATH            make executable to invoke (default: make)
```

Examples:

```sh
tools/gen_compile_commands.py samd21
tools/gen_compile_commands.py samd21 --board generic
tools/gen_compile_commands.py stm32f103 stm32h523 sg2002       # merge several platforms
tools/gen_compile_commands.py samd21 --var TOOLCHAIN_PATH=/opt/gcc-arm/bin
```

Passing multiple platforms merges their compile commands into one
`compile_commands.json`; when two platforms compile the same core
`grbl/*.c` file (e.g. `stepper.c`), the later platform argument wins for
that file's entry. Files a platform overrides with its own copy (e.g.
samd21's `serial.c`/`nvmem.c`) live at a different path and are never
clobbered by another platform's entry.

`atmega328p` is a special case: it has no `grbl/platform/atmega328p/Makefile`
(that platform builds from the repo-root `Makefile` instead), so
`tools/gen_compile_commands.py atmega328p` falls back to running `make -nB`
there.

### Adding a `compdb` target to another platform's Makefile

`grbl/platform/samd21/Makefile` has a `compdb` target you can copy into any
other `grbl/platform/<platform>/Makefile`:

```make
compdb:
	$(GRBL_DIR)/../tools/gen_compile_commands.py $(PLATFORM_NAME) --build $(BUILD)
```

(add `--board $(BOARD)` too if that Makefile defines a `BOARD` variable).
`$(GRBL_DIR)` is already defined by every platform Makefile as `../..`
relative to that Makefile's directory (i.e. `grbl/`), so
`$(GRBL_DIR)/../tools/...` resolves to `<repo_root>/tools/...` regardless of
how deep the platform directory is nested. Then, from that platform
directory:

```sh
make -C grbl/platform/<platform> compdb
```
