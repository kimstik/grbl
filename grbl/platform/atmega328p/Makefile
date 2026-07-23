#  Shim Makefile so the AVR reference port builds like every other platform:
#      make -C grbl/platform/atmega328p
#  The real build lives in the repo-root Makefile and is intentionally left
#  untouched there to preserve the byte-exact golden build (see
#  grbl/platform/common/chk.py). BUILD= is accepted for CI uniformity but
#  ignored: the reference build has a single flavor (-Os, no LTO).

ROOT = ../../..

# Root Makefile defaults AVR_GCC_PATH to a developer-machine location;
# prefer the avr-gcc found on PATH when one exists (e.g. apt gcc-avr).
AVR_GCC := $(shell command -v avr-gcc 2>/dev/null)
ifneq ($(AVR_GCC),)
  AVR_GCC_PATH ?= $(patsubst %/,%,$(dir $(AVR_GCC)))
endif
ifneq ($(AVR_GCC_PATH),)
  ROOT_ARGS = AVR_GCC_PATH=$(AVR_GCC_PATH)
endif

all:
	mkdir -p $(ROOT)/build
	$(MAKE) -C $(ROOT) $(ROOT_ARGS) all

validate:
	mkdir -p $(ROOT)/build
	$(MAKE) -C $(ROOT) $(ROOT_ARGS) validate

clean:
	$(MAKE) -C $(ROOT) clean

.PHONY: all validate clean
