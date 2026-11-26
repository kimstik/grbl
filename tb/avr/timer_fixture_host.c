/* Observe Timer1 fixture events without writing emulated state. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include "sim_avr.h"
#include "sim_elf.h"

static void die(const char *s) { fprintf(stderr, "fixture: %s\n", s); exit(2); }

static const avr_symbol_t *sym(elf_firmware_t *f, const char *name)
{
  for (int i = 0; i < f->symbolcount; i++)
    if (!strcmp(f->symbol[i]->symbol, name)) return f->symbol[i];
  die(name);
  return 0;
}

int main(int argc, char **argv)
{
  if (argc != 2) die("usage: timer_fixture_host ELF");
  elf_firmware_t fw = {0};
  if (elf_read_firmware(argv[1], &fw)) die("ELF");
  avr_t *a = avr_make_mcu_by_name("atmega328p");
  if (!a || avr_init(a)) die("MCU");
  a->frequency = 16000000;
  avr_load_firmware(a, &fw);
  a->run_cycle_limit = a->run_cycle_count = 1;
  a->sleep = NULL;
  uint32_t isr = sym(&fw, "__vector_11")->addr;
  unsigned hits = sym(&fw, "hits")->addr - AVR_SEGMENT_OFFSET_DATA;
  unsigned flagged = sym(&fw, "flagged")->addr - AVR_SEGMENT_OFFSET_DATA;
  unsigned ocr = a->data[0x88] | a->data[0x89] << 8, flag = 0;
  uint32_t pc = a->pc;
  while (a->cycle < 2000000 && a->state != cpu_Done && a->state != cpu_Crashed) {
    uint64_t before = a->cycle;
    avr_run(a);
    if (a->pc == isr && pc != isr) printf("isr %" PRIu64 "\n", a->cycle);
    pc = a->pc;
    unsigned o = a->data[0x88] | a->data[0x89] << 8;
    if (o != ocr) printf("ocr %" PRIu64 " %" PRIu64 " %u\n", before, a->cycle, o);
    ocr = o;
    if (a->data[flagged] != flag) printf("flagged %" PRIu64 " %u\n", a->cycle, a->data[flagged]);
    flag = a->data[flagged];
  }
  printf("end %" PRIu64 " state=%d hits=%u\n", a->cycle, a->state, a->data[hits]);
  return 0;
}
