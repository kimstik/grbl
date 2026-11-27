/* Exact production-image UART baseline. Host observations never paint SRAM. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <inttypes.h>
#include "sim_avr.h"
#include "sim_elf.h"
#include "sim_io.h"
#include "avr_uart.h"
#include "avr_eeprom.h"
#include "avr_ioport.h"
#include "avr_timer.h"
static FILE *uart,*trace,*events;
static uint32_t hash=2166136261u;
static unsigned bytes,acks,ready,off=1,work,rawmin=0x8ff,effmin=0x8ff,pushmin=0x900;
static unsigned wr=0x8ff,we=0x8ff,wp=0x900;
static char line[1024];static unsigned used;
static void die(const char*s){fprintf(stderr,"host: %s\n",s);exit(2);}
static unsigned word(avr_t*a,unsigned p){return a->data[p]|a->data[p+1]<<8;}
static unsigned addr(elf_firmware_t*f,const char*n){for(unsigned i=0;i<f->symbolcount;i++)if(!strcmp(f->symbol[i]->symbol,n))return f->symbol[i]->addr-AVR_SEGMENT_OFFSET_DATA;die(n);return 0;}
static void output(struct avr_irq_t*q,uint32_t v,void*x){(void)q;avr_t*a=x;fprintf(trace,"uart-byte %"PRIu64" value=%u\n",(uint64_t)a->cycle,v&255);fputc(v&255,uart);hash=(hash^(v&255))*16777619u;for(int i=0;i<8;i++)hash=(hash^((uint64_t)a->cycle>>(8*i)&255))*16777619u;bytes++;if((v&255)=='\n'){line[used]=0;if(strstr(line,"Grbl "))ready=1;if(!strcmp(line,"ok\r"))acks++;if(work && (strstr(line,"error:")||strstr(line,"ALARM:")))die(line);used=0;}else if(used+1<sizeof(line))line[used++]=v&255;}
static void flow(struct avr_irq_t*q,uint32_t v,void*x){(void)q;off=v?*(unsigned*)x:off;}
static void low(avr_t*a,const char*k,unsigned sp,unsigned pc,unsigned busy){fprintf(trace,"low %s %"PRIu64" pc=%x sp=%x I=%u busy=%u timsk=%u tifr=%u phase=%u chain=unknown\n",k,(uint64_t)a->cycle,pc,sp,a->sreg[7],a->data[busy],a->data[0x6f],a->data[0x36],work);}
static unsigned candidate,sys_addr,busy_addr;
#include "timer1_trace.h"
#include "timer1_metrics.h"
#ifdef TIMER1_SMOKE
static __attribute__((unused))
#endif
int main(int argc,char**argv){
 if(argc!=6)die("ELF g94 output-prefix observed|blind off|on");
 int blind=!strcmp(argv[4],"blind");candidate=!strcmp(argv[5],"on");
 elf_firmware_t fw={0};if(elf_read_firmware(argv[1],&fw))die("ELF");avr_t*a=avr_make_mcu_by_name("atmega328p");if(!a||avr_init(a))die("MCU");a->frequency=16000000;avr_load_firmware(a,&fw);a->run_cycle_limit=a->run_cycle_count=1;a->sleep=NULL;
 unsigned char ee[1024];memset(ee,255,sizeof(ee));avr_eeprom_desc_t ed={.ee=ee,.offset=0,.size=sizeof(ee)};if(avr_ioctl(a,AVR_IOCTL_EEPROM_SET,&ed)<0)die("EEPROM");
 for(char port='B';port<='D';port++){avr_ioport_external_t e={.name=port,.mask=255,.value=255};if(avr_ioctl(a,AVR_IOCTL_IOPORT_SET_EXTERNAL(port),&e)<0)die("pins");}
 char path[512];snprintf(path,sizeof(path),"%s.uart",argv[3]);uart=fopen(path,"wb");snprintf(path,sizeof(path),"%s.trace",argv[3]);trace=fopen(path,"w");snprintf(path,sizeof(path),"%s.events",argv[3]);events=fopen(path,"w");if(!uart||!trace||!events)die("files");
 uint32_t flags=0;avr_ioctl(a,AVR_IOCTL_UART_SET_FLAGS('0'),&flags);avr_irq_t*input=avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_INPUT);static unsigned on=0,stop=1;
 avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUTPUT),output,a);avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUT_XON),flow,&on);avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUT_XOFF),flow,&stop);
 unsigned sys=addr(&fw,"sys"),pos=addr(&fw,"sys_position"),bh=addr(&fw,"block_buffer_head"),bt=addr(&fw,"block_buffer_tail"),sh=addr(&fw,"segment_buffer_head"),st=addr(&fw,"segment_buffer_tail"),state=addr(&fw,"st"),busy=addr(&fw,"busy");
 sys_addr=sys;busy_addr=busy;rt_addr=addr(&fw,"sys_rt_exec_state");settings_metric=addr(&fw,"settings");metrics_init(a,argv[3]);
 avr_irq_t*pc2=avr_io_getirq(a,AVR_IOCTL_IOPORT_GETIRQ('C'),IOPORT_IRQ_PIN2);unsigned released=0;
 const char*setup[]={"$X\n","$20=0\n","$21=0\n","$22=0\n","$1=25\n","$12=0.002\n","$100=250\n","$101=250\n","$102=250\n","$110=5000\n","$111=5000\n","$112=5000\n","$120=4000\n","$121=4000\n","$122=4000\n","$$\n","G21G90G94\n","M3S500\n"};
 const char*g94[]={"G94G5X10Y0Z-30I3J12P3Q-12F2000\n","G5X20Y0Z-30I3J12P3Q-12F2000\n","G5X30Y0Z-30I3J12P3Q-12F2000\n","G5X40Y0Z-30I3J12P3Q-12F2000\n"};
 const char*g93[]={"G93G5X10Y0Z-30I3J12P3Q-12F120\n","G5X20Y0Z-30I3J12P3Q-12F120\n","G5X30Y0Z-30I3J12P3Q-12F120\n","G5X40Y0Z-30I3J12P3Q-12F120\n"};
 unsigned nsetup=sizeof(setup)/sizeof(*setup),cmd=0,index=0,wait=0;uint64_t next=0,stable=0;int pair=0;unsigned pairpc=0;
 /* Read-only Timer1 audit. Before each OCR1A low-byte store (the write that makes the
    simulator reschedule CTC) the counter is taken from the simulator's own timer state,
    not through the TCNT1 read accessor. On hardware a new TOP below the counter misses
    the match and wraps through 0xffff; the simulator does not model that wrap, so such
    a store would make the run unfaithful. The count is taken at the end of the two-cycle
    store, the latest moment the write can land. Prescaler changes are counted because
    the simulator restarts the counter on them and hardware does not. */
 avr_timer_t*t1=0;for(avr_io_t*io=a->io_port;io;io=io->next)if(!strcmp(io->kind,"timer")&&((avr_timer_t*)io)->name=='1')t1=(avr_timer_t*)io;if(!t1)die("timer 1");
 unsigned topw=0,missed=0,near=0,cschanges=0,initialstart=0,boundary=0,equal=0,oldcs=a->data[0x81]&7;long minslack=65536;
 unsigned sent=0;uint64_t ready_cycle=0;
 extended=!blind;phase_map(a);
 avr_uart_t*u0=0;for(avr_io_t*io=a->io_port;io;io=io->next)if(!strcmp(io->kind,"uart")&&((avr_uart_t*)io)->name=='0')u0=(avr_uart_t*)io;if(!u0)die("uart0");
 if(strcmp(argv[2],"g94"))die("phase A is G94 only");
 while(a->cycle<640000000ULL && a->state!=cpu_Crashed){
  trace_before(a);
  input_history(a,u0,next,cmd,index,wait);
  select_anchor(a,u0); /* Identical semantic trigger in observed and blind. */
  if(selected&&!sent){
   if((a->data[0x27]&4)||!(a->data[0x28]&4)||!(a->data[0x26]&4)||!(a->data[0x6c]&4)||!(a->data[0x68]&2))die("PC2 input/pullup/pin-change map guard");
   unsigned settings_addr=addr(&fw,"settings");
   if(a->data[settings_addr+0x31]!=0)die("step inversion guard");
   fprintf(metrics,"configuration %"PRIu64" pulse_us=%u step_invert=%u state=%u pc2=%u ddrC=%u portC=%u pcmsk1=%u pcicr=%u\n",(uint64_t)a->cycle,a->data[settings_addr+0x30],a->data[settings_addr+0x31],a->data[sys],a->data[0x26],a->data[0x27],a->data[0x28],a->data[0x6c],a->data[0x68]);
   snapshot(a,"question-send");fprintf(events,"%"PRIu64" 63\n",(uint64_t)a->cycle);avr_raise_irq(input,'?');
   fprintf(events,"%"PRIu64" pc2=0\n",(uint64_t)a->cycle);avr_raise_irq(pc2,0);
   sent=1;last_send=a->cycle;next=a->cycle+1600;
  }
  if(sent&&!released&&a->cycle>=selected+1600){fprintf(events,"%"PRIu64" pc2=1\n",(uint64_t)a->cycle);avr_raise_irq(pc2,1);released=1;}
  if(ready && !off && a->cycle>=next && (!wait || acks>=wait)){
   if(cmd<nsetup+4){if(cmd==nsetup&&!index&&!work){work=1;fprintf(trace,"work %"PRIu64"\n",(uint64_t)a->cycle);}
    const char*s=cmd<nsetup?setup[cmd]:(!strcmp(argv[2],"g93")?g93:g94)[cmd-nsetup];unsigned c=(unsigned char)s[index++];fprintf(events,"%"PRIu64" %u\n",(uint64_t)a->cycle,c);avr_raise_irq(input,c);last_send=a->cycle;next=a->cycle+1600;if(!s[index]){index=0;cmd++;wait=acks+1;}
   }
  }
  unsigned pc=a->pc,sp=word(a,0x5d),op=a->flash[pc]|a->flash[pc+1]<<8;
  int outs=(op&0xf800)==0xb800;unsigned io=(op&15)|((op>>5)&48);
  if(!blind && outs && io==0x3e){
   if(pair)die("nested SPH write");
   unsigned n=a->flash[pc+2]|a->flash[pc+3]<<8, m=a->flash[pc+4]|a->flash[pc+5]<<8;
   /* Only these exact straight-line SPH/[SREG]/SPL sequences are deferred.
      The raw register minimum remains recorded without filtering. */
   if(!((n&0xf800)==0xb800 && (((n&15)|((n>>5)&48))==0x3d ||
      (((n&15)|((n>>5)&48))==0x3f && (m&0xf800)==0xb800 && ((m&15)|((m>>5)&48))==0x3d))))die("unmapped SP pair");
   pair=1;pairpc=pc;
  }
  unsigned pushes=(op&0xfe0f)==0x920f?1:((op&0xf000)==0xd000 || (op&0xfe0e)==0x940e)?2:0;
  int ocrstore=(op&0xfe0f)==0x9200&&(a->flash[pc+2]|a->flash[pc+3]<<8)==0x88;
  long count=-1;unsigned oldtop=t1->tov_top;uint64_t at=a->cycle;
  if(ocrstore&&t1->tov_cycles)count=(long)(((at+2-t1->tov_base)*((uint64_t)t1->tov_top+1))/t1->tov_cycles);
  unsigned following=a->flash[pc+2]|a->flash[pc+3]<<8,z=word(a,30),rd=(op>>4)&31;
  unsigned saved_return=(op==0x9508||op==0x9518)?return_pc(a,sp):0;
  long startcount=t1->tov_cycles?(long)(((at-t1->tov_base)*((uint64_t)t1->tov_top+1))/t1->tov_cycles):-1;
  unsigned oldrx=a->data[0xc0]&0x80,oldrt=a->data[rt_addr];
  avr_run(a);unsigned ns=word(a,0x5d);
  trace_after(a,pc,op,sp,following,z,rd,saved_return);metrics_after(a,pc,oldrt);
  if(sent&&!ready_cycle&&!oldrx&&(a->data[0xc0]&0x80)){
   ready_cycle=a->cycle;snapshot(a,"rx-ready");
   if(ready_cycle!=selected+1496)die("semantic send readiness mismatch");
  }
  if(ocrstore){unsigned o=word(a,0x88);long slack=(long)o-count;topw++;
   if(count<0)fprintf(trace,"ocr1a stopped cycle=%"PRIu64" pc=%x new=%u\n",at,pc,o);
   else{if(slack<minslack)minslack=slack;
    if(count>(long)oldtop)boundary++;else if(startcount>(long)o)missed++;else if(startcount<=(long)o&&count>=(long)o)equal++;else if(slack<64)near++;
    if(slack<64||count>(long)oldtop)fprintf(trace,"ocr1a cycle=%"PRIu64" pc=%x old_top=%u start=%ld count=%ld new=%u slack=%ld\n",at,pc,oldtop,startcount,count,o,slack);}}
  if((a->data[0x81]&7)!=oldcs){if(!oldcs&&!initialstart&&!work)initialstart++;else cschanges++;fprintf(trace,"prescaler cycle=%"PRIu64" pc=%x cs=%u->%u\n",at,pc,oldcs,a->data[0x81]&7);oldcs=a->data[0x81]&7;}
  if(!blind){
   if(ns<rawmin){rawmin=ns;low(a,"raw",ns,pc,busy);}if(work&&ns<wr)wr=ns;
   if(pushes){unsigned lowaddr=sp-pushes+1;if(lowaddr<pushmin)pushmin=lowaddr;if(work&&lowaddr<wp)wp=lowaddr;}
   if(pair && outs && io==0x3d){pair=0;(void)pairpc;}
   /* Hardware entry subtracts two in addition to the instruction's own SP effect.
      Vector PC is sufficient here because vector table execution has not begun. */
   if(a->pc>=4 && a->pc<=100 && a->pc%4==0 && ns<sp){unsigned lowaddr=ns+1;if(lowaddr<pushmin)pushmin=lowaddr;if(work&&lowaddr<wp)wp=lowaddr;if(pair){fprintf(trace,"pair_interrupt %x %x %x\n",pc,a->pc,ns);pair=0;}}
   if(!pair){if(ns<effmin){effmin=ns;low(a,"effective",ns,pc,busy);if(work)snapshot(a,"effective-low");}if(work&&ns<we){we=ns;snapshot(a,"work-min");}
    if(wang_active&&ns<startup_min){startup_min=ns;snapshot(a,"startup-min");}
    if(prep_active&&ns<prep_min){prep_min=ns;snapshot(a,"prep-min");}}
  }
  int32_t xyz[3];for(int i=0;i<3;i++)memcpy(&xyz[i],a->data+pos+4*i,4);
  int drained=cmd==nsetup+4&&acks>=wait&&a->data[sys]==0&&a->data[bh]==a->data[bt]&&a->data[sh]==a->data[st]&&!word(a,state+33)&&!(a->data[0x6f]&2)&&xyz[0]==10000&&xyz[1]==0&&xyz[2]==-7500;
  if(drained){if(!stable)stable=a->cycle;if(a->cycle-stable>=1600000)break;}else stable=0;
 }
 fprintf(trace,"trial sent=%u ready=%"PRIu64"\n",sent,ready_cycle);
 fprintf(trace,"calibration selected=%"PRIu64" generations=%u returns=%u active=%u unknown=%u udr=%u status=%u prep_entries=%u startup_min=%x prep_min=%x\n",selected,generation,wang_returns,wang_active,unknown,rx_question,status_hits,prep_entries,startup_min,prep_min);
 fprintf(trace,"timer stores=%u missed=%u near=%u equal=%u boundary=%u min_slack=%ld prescaler_changes=%u initial_start=%u\n",topw,missed,near,equal,boundary,minslack,cschanges,initialstart);
 fprintf(trace,"end %"PRIu64" state=%u pc=%x bytes=%u hash=%u commands=%u acks=%u stable=%"PRIu64" raw=%x effective=%x push=%x work_raw=%x work_effective=%x work_push=%x\n",(uint64_t)a->cycle,a->data[sys],a->pc,bytes,hash,cmd,acks,stable,rawmin,effmin,pushmin,wr,we,wp);
 fprintf(trace,"diagnostic frequency=%u cpu=%d I=%u irqstate=%d busy=%u timer=%u/%u counter=%u compare=%u mask=%u flags=%u queues=%u/%u %u/%u exec=%u pos=%u/%u/%u rt=%u\n",a->frequency,a->state,a->sreg[7],a->interrupt_state,a->data[busy],a->data[0x80],a->data[0x81],word(a,0x84),word(a,0x88),a->data[0x6f],a->data[0x36],a->data[bh],a->data[bt],a->data[sh],a->data[st],word(a,state+33),word(a,pos),word(a,pos+4),word(a,pos+8),a->data[addr(&fw,"sys_rt_exec_state")]);
 metrics_finish(a);
 int ok=stable&&a->cycle<640000000ULL&&sent&&released;fclose(uart);fclose(trace);fclose(events);avr_terminate(a);return ok?0:3;
}
