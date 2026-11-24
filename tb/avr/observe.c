/* Read-only, host-side observer for an uninstrumented dyn.elf.
 * The AVR ABI and spline state layout below must be checked against each build.
 * Run with --blind as a control: UART bytes, their cycles and final cycle must match.
 * No SRAM, flash, register or peripheral state is written by the observer.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sim_avr.h"
#include "sim_elf.h"
#include "sim_io.h"
#include "avr_uart.h"

#define STATE_MAX 35
#define FREQUENCY 16000000UL

static FILE *events, *uart_out;
static uint64_t uart_bytes;
static uint32_t uart_hash = 2166136261UL;

static void die(const char *what)
{
  fprintf(stderr, "observe: %s\n", what);
  exit(1);
}

static uint32_t hash_byte(uint32_t hash, uint8_t byte)
{
  return (hash ^ byte)*16777619UL;
}

static void uart_byte(struct avr_irq_t *irq, uint32_t value, void *param)
{
  avr_t *avr = param;
  (void)irq;
  if (fputc(value & 255, uart_out) == EOF) { die("UART write failed"); }
  uart_hash = hash_byte(uart_hash, value & 255);
  for (unsigned i = 0; i < 8; i++) {
    uart_hash = hash_byte(uart_hash, (uint64_t)avr->cycle >> (8*i));
  }
  uart_bytes++;
}

static const avr_symbol_t *symbol(const elf_firmware_t *fw, const char *name)
{
  const avr_symbol_t *found = NULL;
  for (uint32_t i = 0; i < fw->symbolcount; i++) {
    if (!strcmp(fw->symbol[i]->symbol, name)) {
      if (found) { die("ambiguous ELF symbol"); }
      found = fw->symbol[i];
    }
  }
  if (!found) { fprintf(stderr, "observe: missing symbol %s\n", name); exit(1); }
  return found;
}

static uint16_t data_address(const avr_t *avr, const avr_symbol_t *s, unsigned size)
{
  if (s->addr < AVR_SEGMENT_OFFSET_DATA ||
      s->addr - AVR_SEGMENT_OFFSET_DATA + size > (uint32_t)avr->ramend + 1 || s->size < size) {
    die("ELF data symbol outside SRAM or too short");
  }
  return s->addr - AVR_SEGMENT_OFFSET_DATA;
}

static uint16_t word(const avr_t *avr, unsigned address)
{
  if (address + 1 > avr->ramend) { die("word outside SRAM"); }
  return avr->data[address] | (uint16_t)avr->data[address + 1] << 8;
}

static uint16_t pointer(const avr_t *avr, unsigned reg, unsigned size)
{
  uint16_t address = word(avr, reg);
  if (address < 0x100 || (uint32_t)address + size > (uint32_t)avr->ramend + 1) {
    die("argument outside SRAM; check the ELF ABI");
  }
  return address;
}

static void raw_floats(const avr_t *avr, unsigned address, unsigned count)
{
  if (address + 4*count > (uint32_t)avr->ramend + 1) { die("float outside SRAM"); }
  for (unsigned i = 0; i < count; i++, address += 4) {
    uint32_t value = word(avr, address) | (uint32_t)word(avr, address + 2) << 16;
    fprintf(events, " %" PRIu32, value);
  }
}

static void state_hex(const uint8_t *state, unsigned size)
{
  fputc(' ', events);
  for (unsigned i = 0; i < size; i++) { fprintf(events, "%02x", state[i]); }
}

typedef struct {
  uint8_t active, before[STATE_MAX];
  uint16_t sp, j, segments;
  uint32_t return_pc;
  uint64_t cycle;
} call_t;

int main(int argc, char **argv)
{
  if (argc < 5 || argc > 6 || (argc == 6 && strcmp(argv[5], "--blind"))) {
    fprintf(stderr, "usage: observe dyn.elf events.txt uart.txt max_cycles [--blind]\n");
    return 2;
  }
  char *end;
  uint64_t limit = strtoull(argv[4], &end, 10);
  if (!limit || *end) { die("invalid cycle limit"); }
  int blind = argc == 6;
  elf_firmware_t fw = {0};
  if (elf_read_firmware(argv[1], &fw)) { die("cannot load ELF"); }
  avr_t *avr = avr_make_mcu_by_name("atmega328p");
  if (!avr || avr_init(avr)) { die("cannot initialize ATmega328P"); }
  avr->frequency = FREQUENCY;
  avr_load_firmware(avr, &fw);
  if (avr->frequency != FREQUENCY || avr->address_size != 2) { die("unexpected MCU clock or return address"); }
  /* This changes host batching, not simulated instruction or interrupt cycles. */
  avr->run_cycle_limit = avr->run_cycle_count = 1;
  avr->sleep = NULL;
  uint32_t flags = 0;
  if (avr_ioctl(avr, AVR_IOCTL_UART_SET_FLAGS('0'), &flags)) { die("cannot configure UART"); }
  events = fopen(argv[2], "wb"); uart_out = fopen(argv[3], "wb");
  if (!events || !uart_out) { die("cannot open output"); }
  avr_irq_t *irq = avr_io_getirq(avr, AVR_IOCTL_UART_GETIRQ('0'), UART_IRQ_OUTPUT);
  if (!irq) { die("cannot find UART output"); }
  avr_irq_register_notify(irq, uart_byte, avr);

  const avr_symbol_t *next = symbol(&fw, "mc_spline_next");
  const avr_symbol_t *plan = symbol(&fw, "plan_buffer_line");
  const avr_symbol_t *z = symbol(&fw, "spline_z");
  if ((z->size != 25 && z->size != 26 && z->size != 29 && z->size != STATE_MAX) ||
      next->addr > avr->flashend || plan->addr > avr->flashend) { die("unsupported spline layout or code address"); }
  uint16_t za = data_address(avr, z, z->size);
  uint16_t prog = data_address(avr, symbol(&fw, "prog"), 1);
  uint16_t pi = data_address(avr, symbol(&fw, "pi"), 2);
  fprintf(events, "meta 1 %lu %u %" PRIu32 " %" PRIu32 " %u %u %u %d\n",
          FREQUENCY, za, next->addr, plan->addr, z->size, prog, pi, blind);
  call_t call = {0};
  uint32_t curve = 0, point = 0;
  uint16_t segments = 0;
  uint64_t calls = 0, points = 0;
  int in_curve = 0;
  while (avr->cycle < limit && avr->state != cpu_Done && avr->state != cpu_Crashed) {
    if (!blind && avr->state == cpu_Running) {
      uint16_t sp = word(avr, R_SPL);
      if (call.active && avr->pc == call.return_pc && sp == call.sp + 2) {
        fprintf(events, "next %" PRIu32 " %u %" PRIu64 " %" PRIu64 " %u %u %u",
                curve, avr->data[prog], call.cycle, (uint64_t)avr->cycle - call.cycle,
                call.j, call.segments, avr->data[24]);
        state_hex(call.before, z->size);
        state_hex(avr->data + za, z->size);
        fputc('\n', events);
        call.active = 0;
      }
      if (avr->pc == next->addr) {
        if (call.active) { die("recursive spline helper or missed return"); }
        if (pointer(avr, 24, z->size) != za) { die("spline argument differs from ELF state"); }
        call.j = word(avr, 20); call.segments = word(avr, 18);
        if (call.segments < 2 || call.segments > 2000 || call.j >= call.segments) {
          die("invalid helper indices; check the ELF ABI");
        }
        if (call.j == 1 && avr->data[za + 24] == 0) {
          if (in_curve) { die("new curve before all prior targets"); }
          in_curve = 1; curve++; point = 0; segments = call.segments;
          fprintf(events, "curve %" PRIu32 " %u %u %" PRIu64 " %u", curve,
                  avr->data[prog], word(avr, pi), (uint64_t)avr->cycle, segments);
          raw_floats(avr, pointer(avr, 16, 12), 3); /* position */
          raw_floats(avr, pointer(avr, 14, 8), 2);  /* first */
          raw_floats(avr, pointer(avr, 12, 8), 2);  /* second */
          raw_floats(avr, pointer(avr, 10, 12), 3); /* target */
          fputc('\n', events);
        }
        if (!in_curve || call.segments != segments) { die("helper outside known curve"); }
        call.sp = sp; call.cycle = avr->cycle;
        call.return_pc = 2*((uint16_t)avr->data[sp + 1] << 8 | avr->data[sp + 2]);
        if (call.return_pc > avr->flashend) { die("invalid return PC; check the ELF ABI"); }
        memcpy(call.before, avr->data + za, z->size);
        call.active = 1; calls++;
      }
      if (avr->pc == plan->addr) {
        uint16_t target = pointer(avr, 24, 12), pl = pointer(avr, 22, 9);
        if (!in_curve) { die("planner call outside known curve"); }
        point++; points++;
        fprintf(events, "point %" PRIu32 " %u %" PRIu32 " %" PRIu64,
                curve, avr->data[prog], point, (uint64_t)avr->cycle);
        raw_floats(avr, target, 3); raw_floats(avr, pl, 1);
        fprintf(events, " %u\n", avr->data[pl + 8]);
        if (point == segments) {
          fprintf(events, "curve_end %" PRIu32 " %" PRIu64 "\n", curve, (uint64_t)avr->cycle);
          in_curve = 0;
        }
      }
    }
    avr_run(avr);
  }
  fprintf(events, "end %" PRIu64 " %d %" PRIu64 " %" PRIu32 " %" PRIu32
          " %" PRIu64 " %" PRIu64 " %d %d\n", (uint64_t)avr->cycle, avr->state,
          uart_bytes, uart_hash, curve, calls, points, in_curve, call.active);
  int ok = avr->state == cpu_Done && (blind || (!in_curve && !call.active && curve && calls && points));
  if (ferror(events) || ferror(uart_out)) { die("output write failed"); }
  if (fclose(events) || fclose(uart_out)) { die("output close failed"); }
  avr_terminate(avr);
  return ok ? 0 : 3;
}
