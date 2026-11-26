/* Bounded host-only control-flow history for one frozen G94 image. */
#include "sim_interrupts.h"
typedef struct { unsigned from,to,ret,sp,irq; } frame_t;
static frame_t frames[64];
static unsigned depth,unknown,irq_seen,irq_vector,irq_sp,irq_ret,extended;
static unsigned prep_active,prep_sp,prep_ret,rx_question,status_hits;
static char history[32][120];static unsigned history_n;
static void hist(avr_t*a,const char*k,unsigned pc,unsigned dest,unsigned sp){
 snprintf(history[history_n++%32],120,"history %"PRIu64" %s pc=%x dest=%x sp=%x depth=%u",(uint64_t)a->cycle,k,pc,dest,sp,depth);
}
static unsigned return_pc(avr_t*a,unsigned sp){if(sp+2>0x8ff)die("return address range");return 2*((unsigned)a->data[sp+1]<<8|a->data[sp+2]);}
static void snapshot(avr_t*a,const char*why){
 unsigned sp=word(a,0x5d);
 fprintf(trace,"snapshot %"PRIu64" %s pc=%x sp=%x prep=%u unknown=%u depth=%u\n",(uint64_t)a->cycle,why,a->pc,sp,prep_active,unknown,depth);
 if(!extended)return;
 for(unsigned i=0;i<depth;i++)fprintf(trace,"frame %u from=%x to=%x return=%x sp=%x irq=%u\n",i,frames[i].from,frames[i].to,frames[i].ret,frames[i].sp,frames[i].irq);
 for(unsigned i=history_n>32?history_n-32:0;i<history_n;i++)fprintf(trace,"%s\n",history[i%32]);
 fprintf(trace,"registers");for(unsigned i=0;i<32;i++)fprintf(trace," %02x",a->data[i]);fputc('\n',trace);
 fprintf(trace,"stack %x",sp+1);if(sp>=0x100&&sp<=0x8ff)for(unsigned i=sp+1;i<=0x8ff;i++)fprintf(trace," %02x",a->data[i]);fputc('\n',trace);
}
static void entering_irq(struct avr_irq_t*q,uint32_t value,void*param){
 (void)q;avr_t*a=param;if(!value)return;
 if(irq_seen)die("multiple IRQ entries in instruction");
 irq_seen=1;irq_vector=a->pc/4;irq_sp=word(a,0x5d);irq_ret=return_pc(a,irq_sp);
}
static void frame_push(avr_t*a,unsigned from,unsigned to,unsigned ret,unsigned sp,unsigned irq){
 if(depth==64)die("bounded call history exhausted");
 frames[depth++]=(frame_t){from,to,ret,sp,irq};hist(a,irq?"irq":"call",from,to,sp);
}
static unsigned instruction_target(unsigned pc,unsigned op,unsigned next){
 if((op&0xfe0e)==0x940e||(op&0xfe0e)==0x940c)return 2*(next|((op&1)<<16)|((op&0x1f0)<<13));
 int rel=(int)(op&0xfff);if(rel&0x800)rel-=4096;return pc+2+2*rel;
}
static void trace_after(avr_t*a,unsigned pc,unsigned op,unsigned sp,unsigned next,unsigned z,unsigned rdest,unsigned saved_return){
 unsigned resume=irq_seen?irq_ret:a->pc;
 int call=(op&0xfe0e)==0x940e||(op&0xf000)==0xd000||op==0x9509;
 if(call){unsigned ret=pc+((op&0xfe0e)==0x940e?4:2),to=op==0x9509?2*z:instruction_target(pc,op,next);
  if(to==ret){hist(a,"allocation-rcall",pc,to,sp);}else{if(resume!=to){unknown++;hist(a,"unknown-call",pc,resume,sp);}frame_push(a,pc,to,ret,sp,0);}}
 if(op==0x9508||op==0x9518){
  unsigned ret=saved_return; /* Snapshot before RET: a subsequent IRQ may overwrite the bytes. */
  if(!depth||frames[depth-1].ret!=ret||frames[depth-1].sp!=sp+2||!!frames[depth-1].irq!=(op==0x9518)){
   unknown++;hist(a,"unknown-return",pc,ret,sp);
  }else{depth--;hist(a,op==0x9518?"reti":"ret",pc,ret,sp);}
  if(resume!=ret){unknown++;hist(a,"unknown-resume",pc,resume,sp);}
 }
 if(op==0x9519||op==0x9419){unknown++;hist(a,"unsupported-extended-indirect",pc,resume,sp);}
 if((op&0xfe0e)==0x940c||(op&0xf000)==0xc000||op==0x9409){
  /* Jumps, including shared prologues and tail calls, allocate no return frame. */
  if(op==0x9409||(op&0xfe0e)==0x940c)hist(a,"jump-no-frame",pc,resume,sp);
 }
 if(prep_active&&resume==prep_ret&&word(a,0x5d)+(irq_seen?2:0)==prep_sp+2){prep_active=0;hist(a,"prep-return",pc,resume,sp);}
 if(irq_seen){frame_push(a,irq_ret,irq_vector*4,irq_ret,irq_sp+2,irq_vector);if(irq_vector==18&&work)snapshot(a,"rx-entry");irq_seen=0;}
 if((op&0xfe0f)==0x9000&&next==0xc6&&a->data[rdest]=='?'){rx_question++;snapshot(a,"question-udr");}
}
static void trace_before(avr_t*a){
 if(a->pc==0x1d76){if(prep_active)die("recursive prep");prep_active=1;prep_sp=word(a,0x5d);prep_ret=return_pc(a,prep_sp);hist(a,"prep-entry",a->pc,prep_ret,prep_sp);}
 if(a->pc==0x2bcc){status_hits++;snapshot(a,"status-body");}
}
static void assert_word(avr_t*a,unsigned pc,unsigned expected){if((unsigned)(a->flash[pc]|a->flash[pc+1]<<8)!=expected)die("phase map opcode mismatch");}
static void phase_map(avr_t*a){
 assert_word(a,0x1d76,0xe3a6); /* Verified separately against the pinned disassembly. */
 assert_word(a,0x2bc8,0xff10);assert_word(a,0x2bcc,0xe08c);
 assert_word(a,0x71c6,0x939f);assert_word(a,0x6e08,0x9320);
 for(unsigned i=1;i<=25;i++){avr_irq_t*q=avr_get_interrupt_irq(a,i);if(q)avr_irq_register_notify(q+AVR_INT_IRQ_RUNNING,entering_irq,a);}
}
