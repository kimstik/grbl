/* Host-only segment-generation observer. No emulated state is written.
 * Publication is observed after the head store; consumption after the tail
 * store. Speed is captured with the published generation, never at empty.
 */
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sim_avr.h"
#include "sim_elf.h"
#include "sim_io.h"
#include "avr_uart.h"

static FILE *events,*uart;
static uint64_t bytes;
static uint32_t hash=2166136261u;
static void fail(const char *s) { fprintf(stderr,"frontier: %s\n",s); exit(2); }
static void receive(struct avr_irq_t *irq,uint32_t value,void *param) {
  avr_t *a=param; (void)irq;
  if(fputc(value&255,uart)==EOF) fail("UART write");
  hash=(hash^(value&255))*16777619u;
  for(unsigned i=0;i<8;i++) hash=(hash^((uint64_t)a->cycle>>(8*i)&255))*16777619u;
  bytes++;
}
static const avr_symbol_t *sym(elf_firmware_t *f,const char *name,unsigned size) {
  const avr_symbol_t *s=NULL;
  for(unsigned i=0;i<f->symbolcount;i++) if(!strcmp(f->symbol[i]->symbol,name)) {
    if(s) fail("ambiguous symbol"); s=f->symbol[i];
  }
  if(!s || (size && s->size!=size)) { fprintf(stderr,"symbol %s expected size %u\n",name,size); fail("symbol layout"); }
  return s;
}
static unsigned data(elf_firmware_t *f,const char *name,unsigned size) {
  unsigned a=sym(f,name,size)->addr;
  if(a<AVR_SEGMENT_OFFSET_DATA || a-AVR_SEGMENT_OFFSET_DATA+size>0x900) fail("SRAM range");
  return a-AVR_SEGMENT_OFFSET_DATA;
}
static unsigned word(avr_t *a,unsigned p) { return a->data[p]|a->data[p+1]<<8; }
static float number(avr_t *a,unsigned p) {
  uint32_t b=word(a,p)|(uint32_t)word(a,p+2)<<16; float v; memcpy(&v,&b,4); return v;
}
typedef struct { uint64_t cycle; unsigned gen,live,steps,ticks,amass; float speed,exit; } slot_t;
int main(int argc,char **argv) {
  if(argc!=5 && argc!=6) fail("usage: frontier ELF map events UART [--blind]");
  int blind=argc==6;
  if(blind && strcmp(argv[5],"--blind")) fail("unknown option");
  unsigned empty_pc;
  FILE *map=fopen(argv[2],"rb");
  if(!map || fscanf(map,"%x",&empty_pc)!=1) fail("PC map");
  fclose(map);
  elf_firmware_t fw={0};
  if(elf_read_firmware(argv[1],&fw)) fail("ELF load");
  avr_t *a=avr_make_mcu_by_name("atmega328p");
  if(!a || avr_init(a)) fail("MCU init");
  a->frequency=16000000; avr_load_firmware(a,&fw);
  a->run_cycle_limit=a->run_cycle_count=1; a->sleep=NULL;
  uint32_t flags=0;
  if(avr_ioctl(a,AVR_IOCTL_UART_SET_FLAGS('0'),&flags)) fail("UART flags");
  events=fopen(argv[3],"wb"); uart=fopen(argv[4],"wb");
  if(!events || !uart) fail("output open");
  avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUTPUT),receive,a);
  unsigned head=data(&fw,"segment_buffer_head",1),tail=data(&fw,"segment_buffer_tail",1);
  unsigned buf=data(&fw,"segment_buffer",42),prep=data(&fw,"prep",48),st=data(&fw,"st",35);
  unsigned bh=data(&fw,"block_buffer_head",1),bt=data(&fw,"block_buffer_tail",1);
  unsigned prog=data(&fw,"prog",1),pi=data(&fw,"pi",2),sys=data(&fw,"sys",0);
  unsigned rt=data(&fw,"sys_rt_exec_state",1);
  unsigned helper=sym(&fw,"mc_spline_next",0)->addr, prepf=sym(&fw,"st_prep_buffer",0)->addr;
  unsigned plan=sym(&fw,"plan_buffer_line",0)->addr, serial=sym(&fw,"serial_read",0)->addr;
  unsigned lp=data(&fw,"lp",2),isr=sym(&fw,"__vector_11",0)->addr;
  slot_t slots[6]={{0}},last={0};
  unsigned oldprog=0,points=0,pubs=0,consumed=0,empties=0,oh=0,ot=0;
  unsigned interrupted=0,helper_active=0,prep_active=0;
  unsigned helper_sp=0,helper_ret=0,prep_sp=0,prep_ret=0;
  uint64_t helper_start=0,prep_start=0;
  fprintf(events,"meta 16000000 %d %x\n",blind,empty_pc);
  while(a->cycle<10000000000ULL && a->state!=cpu_Done && a->state!=cpu_Crashed) {
    unsigned pc=a->pc,p=a->data[prog],h=a->data[head],raw_tail=a->data[tail];
    /* avr-gcc exposes the incremented sentinel 6 before its wrap-to-zero store. */
    unsigned t=raw_tail==6 ? 0 : raw_tail;
    unsigned sp=word(a,0x5d),q=(a->data[bh]+16-a->data[bt])%16;
    if(!blind && a->state==cpu_Running) {
      int detail=p>=37 && p<=40;
      if(p!=oldprog) {
        for(unsigned i=0;i<6;i++) if(slots[i].live) fail("program changed with queued generation");
        points=0; oldprog=p;
        fprintf(events,"program %u %" PRIu64 "\n",p,(uint64_t)a->cycle);
      }
      if(h!=oh) {
        if(h>=6 || h!=(oh+1)%6 || slots[oh].live) fail("publish generation collision");
        unsigned addr=buf+7*oh;
        slot_t s={(uint64_t)a->cycle,slots[oh].gen+1,1,word(a,addr),word(a,addr+2),a->data[addr+5],number(a,prep+23),number(a,prep+31)};
        if(!isfinite(s.speed)||s.speed<0||!isfinite(s.exit)) fail("publication speed");
        slots[oh]=s; pubs++;
        if(detail) fprintf(events,"publish %" PRIu64 " %u %u %u %u %.9g %.9g %u %u %u %u\n",s.cycle,p,oh,s.gen,word(a,pi),s.speed,s.exit,s.steps,s.ticks,s.amass,q);
        oh=h;
      }
      if(t!=ot) {
        if(t>=6 || t!=(ot+1)%6 || !slots[ot].live || word(a,st+33)) fail("consume without publication or nonnull exec_segment");
        last=slots[ot]; slots[ot].live=0; consumed++;
        if(detail) fprintf(events,"consume %" PRIu64 " %u %u %u %.9g\n",(uint64_t)a->cycle,p,ot,last.gen,last.speed);
        ot=t;
      }
      if(pc==empty_pc) {
        if(h!=t || word(a,st+33)||!last.gen) fail("empty frontier mismatch");
        empties++;
        if(detail) fprintf(events,"empty %" PRIu64 " %u %u %u %u %u %u %.9g %.9g %" PRIu64 " %u %u %u %x\n",(uint64_t)a->cycle,p,word(a,pi),points,q,h,t,last.speed,last.exit,last.cycle,a->data[sys],a->data[sys+2],a->data[rt],interrupted);
      }
      if(pc==isr) interrupted=2*((unsigned)a->data[sp+1]<<8|a->data[sp+2]);
      if(detail) {
        if(helper_active && pc==helper_ret && sp==helper_sp+2) {
          fprintf(events,"helper_end %" PRIu64 " %u %" PRIu64 " %u\n",(uint64_t)a->cycle,p,(uint64_t)a->cycle-helper_start,a->data[24]); helper_active=0;
        }
        if(prep_active && pc==prep_ret && sp==prep_sp+2) {
          fprintf(events,"prep_end %" PRIu64 " %u %" PRIu64 " %u %u %u\n",(uint64_t)a->cycle,p,(uint64_t)a->cycle-prep_start,h,t,q); prep_active=0;
        }
        if(pc==helper) {
          if(helper_active) fail("recursive helper"); helper_active=1; helper_start=a->cycle; helper_sp=sp;
          helper_ret=2*((unsigned)a->data[sp+1]<<8|a->data[sp+2]);
          fprintf(events,"helper %" PRIu64 " %u %u %u\n",helper_start,p,word(a,pi),q);
        }
        if(pc==prepf) {
          if(prep_active) fail("recursive prep"); prep_active=1; prep_start=a->cycle; prep_sp=sp;
          prep_ret=2*((unsigned)a->data[sp+1]<<8|a->data[sp+2]);
          fprintf(events,"prep %" PRIu64 " %u %u %u %u\n",prep_start,p,h,t,q);
        }
        if(pc==serial) fprintf(events,"serial %" PRIu64 " %u %u %u\n",(uint64_t)a->cycle,p,word(a,pi),a->data[word(a,lp)]);
      }
      if(pc==plan) { points++; if(detail) fprintf(events,"point %" PRIu64 " %u %u %u %u\n",(uint64_t)a->cycle,p,word(a,pi),points,q); }
    }
    avr_run(a);
  }
  fprintf(events,"end %" PRIu64 " %d %" PRIu64 " %u %u %u %u\n",(uint64_t)a->cycle,a->state,bytes,hash,pubs,consumed,empties);
  int ok=a->state==cpu_Done && (blind || (pubs && pubs==consumed));
  if(ferror(events)||ferror(uart)||fclose(events)||fclose(uart)) fail("output write");
  avr_terminate(a); return ok?0:3;
}
