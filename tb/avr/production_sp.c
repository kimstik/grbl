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
static FILE *uart,*trace,*events;
static uint32_t hash=2166136261u;
static unsigned bytes,acks,ready,off=1,work,rawmin=0x8ff,effmin=0x8ff,pushmin=0x900;
static unsigned wr=0x8ff,we=0x8ff,wp=0x900;
static char line[1024];static unsigned used;
static void die(const char*s){fprintf(stderr,"host: %s\n",s);exit(2);}
static unsigned word(avr_t*a,unsigned p){return a->data[p]|a->data[p+1]<<8;}
static unsigned addr(elf_firmware_t*f,const char*n){for(unsigned i=0;i<f->symbolcount;i++)if(!strcmp(f->symbol[i]->symbol,n))return f->symbol[i]->addr-AVR_SEGMENT_OFFSET_DATA;die(n);return 0;}
static void output(struct avr_irq_t*q,uint32_t v,void*x){(void)q;avr_t*a=x;fputc(v&255,uart);hash=(hash^(v&255))*16777619u;for(int i=0;i<8;i++)hash=(hash^((uint64_t)a->cycle>>(8*i)&255))*16777619u;bytes++;if((v&255)=='\n'){line[used]=0;if(strstr(line,"Grbl "))ready=1;if(!strcmp(line,"ok\r"))acks++;if(work && (strstr(line,"error:")||strstr(line,"ALARM:")))die(line);used=0;}else if(used+1<sizeof(line))line[used++]=v&255;}
static void flow(struct avr_irq_t*q,uint32_t v,void*x){(void)q;off=v?*(unsigned*)x:off;}
static void low(avr_t*a,const char*k,unsigned sp,unsigned pc,unsigned busy){fprintf(trace,"low %s %"PRIu64" pc=%x sp=%x I=%u busy=%u timsk=%u tifr=%u phase=%u chain=unknown\n",k,(uint64_t)a->cycle,pc,sp,a->sreg[7],a->data[busy],a->data[0x6f],a->data[0x36],work);}
int main(int argc,char**argv){
 if(argc!=5)die("ELF mode output-prefix observed|blind");int blind=!strcmp(argv[4],"blind");
 elf_firmware_t fw={0};if(elf_read_firmware(argv[1],&fw))die("ELF");avr_t*a=avr_make_mcu_by_name("atmega328p");if(!a||avr_init(a))die("MCU");a->frequency=16000000;avr_load_firmware(a,&fw);a->run_cycle_limit=a->run_cycle_count=1;a->sleep=NULL;
 unsigned char ee[1024];memset(ee,255,sizeof(ee));avr_eeprom_desc_t ed={.ee=ee,.offset=0,.size=sizeof(ee)};if(avr_ioctl(a,AVR_IOCTL_EEPROM_SET,&ed)<0)die("EEPROM");
 for(char port='B';port<='D';port++){avr_ioport_external_t e={.name=port,.mask=255,.value=255};if(avr_ioctl(a,AVR_IOCTL_IOPORT_SET_EXTERNAL(port),&e)<0)die("pins");}
 char path[512];snprintf(path,sizeof(path),"%s.uart",argv[3]);uart=fopen(path,"wb");snprintf(path,sizeof(path),"%s.trace",argv[3]);trace=fopen(path,"w");snprintf(path,sizeof(path),"%s.events",argv[3]);events=fopen(path,"w");if(!uart||!trace||!events)die("files");
 uint32_t flags=0;avr_ioctl(a,AVR_IOCTL_UART_SET_FLAGS('0'),&flags);avr_irq_t*input=avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_INPUT);static unsigned on=0,stop=1;
 avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUTPUT),output,a);avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUT_XON),flow,&on);avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_UART_GETIRQ('0'),UART_IRQ_OUT_XOFF),flow,&stop);
 unsigned sys=addr(&fw,"sys"),pos=addr(&fw,"sys_position"),bh=addr(&fw,"block_buffer_head"),bt=addr(&fw,"block_buffer_tail"),sh=addr(&fw,"segment_buffer_head"),st=addr(&fw,"segment_buffer_tail"),state=addr(&fw,"st"),busy=addr(&fw,"busy");
 const char*setup[]={"$X\n","$20=0\n","$21=0\n","$22=0\n","$1=25\n","$12=0.002\n","$100=250\n","$101=250\n","$102=250\n","$110=5000\n","$111=5000\n","$112=5000\n","$120=4000\n","$121=4000\n","$122=4000\n","$$\n","G21G90G94\n","M3S500\n"};
 const char*g94[]={"G94G5X10Y0Z-30I3J12P3Q-12F2000\n","G5X20Y0Z-30I3J12P3Q-12F2000\n","G5X30Y0Z-30I3J12P3Q-12F2000\n","G5X40Y0Z-30I3J12P3Q-12F2000\n"};
 const char*g93[]={"G93G5X10Y0Z-30I3J12P3Q-12F120\n","G5X20Y0Z-30I3J12P3Q-12F120\n","G5X30Y0Z-30I3J12P3Q-12F120\n","G5X40Y0Z-30I3J12P3Q-12F120\n"};
 unsigned nsetup=sizeof(setup)/sizeof(*setup),cmd=0,index=0,wait=0;uint64_t next=0,stable=0;int pair=0;unsigned pairpc=0;
 while(a->cycle<640000000ULL && a->state!=cpu_Crashed){
  if(ready && !off && a->cycle>=next && (!wait || acks>=wait)){
   if(cmd<nsetup+4){if(cmd==nsetup&&!index&&!work){work=1;fprintf(trace,"work %"PRIu64"\n",(uint64_t)a->cycle);}
    const char*s=cmd<nsetup?setup[cmd]:(!strcmp(argv[2],"g93")?g93:g94)[cmd-nsetup];unsigned c=(unsigned char)s[index++];fprintf(events,"%"PRIu64" %u\n",(uint64_t)a->cycle,c);avr_raise_irq(input,c);next=a->cycle+1600;if(!s[index]){index=0;cmd++;wait=acks+1;}
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
  avr_run(a);unsigned ns=word(a,0x5d);
  if(!blind){
   if(ns<rawmin){rawmin=ns;low(a,"raw",ns,pc,busy);}if(work&&ns<wr)wr=ns;
   if(pushes){unsigned lowaddr=sp-pushes+1;if(lowaddr<pushmin)pushmin=lowaddr;if(work&&lowaddr<wp)wp=lowaddr;}
   if(pair && outs && io==0x3d){pair=0;(void)pairpc;}
   /* Hardware entry subtracts two in addition to the instruction's own SP effect.
      Vector PC is sufficient here because vector table execution has not begun. */
   if(a->pc>=4 && a->pc<=100 && a->pc%4==0 && ns<sp){unsigned lowaddr=ns+1;if(lowaddr<pushmin)pushmin=lowaddr;if(work&&lowaddr<wp)wp=lowaddr;if(pair){fprintf(trace,"pair_interrupt %x %x %x\n",pc,a->pc,ns);pair=0;}}
   if(!pair){if(ns<effmin){effmin=ns;low(a,"effective",ns,pc,busy);}if(work&&ns<we)we=ns;}
  }
  int32_t xyz[3];for(int i=0;i<3;i++)memcpy(&xyz[i],a->data+pos+4*i,4);
  int drained=cmd==nsetup+4&&acks>=wait&&a->data[sys]==0&&a->data[bh]==a->data[bt]&&a->data[sh]==a->data[st]&&!word(a,state+33)&&!(a->data[0x6f]&2)&&xyz[0]==10000&&xyz[1]==0&&xyz[2]==-7500;
  if(drained){if(!stable)stable=a->cycle;if(a->cycle-stable>=1600000)break;}else stable=0;
 }
 fprintf(trace,"end %"PRIu64" state=%u pc=%x bytes=%u hash=%u commands=%u acks=%u stable=%"PRIu64" raw=%x effective=%x push=%x work_raw=%x work_effective=%x work_push=%x\n",(uint64_t)a->cycle,a->data[sys],a->pc,bytes,hash,cmd,acks,stable,rawmin,effmin,pushmin,wr,we,wp);
 fprintf(trace,"diagnostic frequency=%u cpu=%d I=%u irqstate=%d busy=%u timer=%u/%u counter=%u compare=%u mask=%u flags=%u queues=%u/%u %u/%u exec=%u pos=%u/%u/%u rt=%u\n",a->frequency,a->state,a->sreg[7],a->interrupt_state,a->data[busy],a->data[0x80],a->data[0x81],word(a,0x84),word(a,0x88),a->data[0x6f],a->data[0x36],a->data[bh],a->data[bt],a->data[sh],a->data[st],word(a,state+33),word(a,pos),word(a,pos+4),word(a,pos+8),a->data[addr(&fw,"sys_rt_exec_state")]);
 int ok=stable&&a->cycle<640000000ULL;fclose(uart);fclose(trace);fclose(events);avr_terminate(a);return ok?0:3;
}
