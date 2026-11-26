/* Bounded host-only control-flow history for one frozen G94 image. */
#include "sim_interrupts.h"
typedef struct { unsigned from,to,ret,sp,irq; } frame_t;
static frame_t frames[64];
static unsigned depth,unknown,irq_seen,irq_vector,irq_sp,irq_ret,extended;
static unsigned prep_active,prep_sp,prep_ret,rx_question,status_hits;
static unsigned generation,wang_active,wang_returns,wang_done,prep_entries;
static unsigned startup_min=0x8ff,prep_min=0x8ff;
static uint64_t selected,last_send;
typedef struct { uint64_t cycle,next,last; unsigned read,write,off,cmd,index,acks,wait; } input_state_t;
static input_state_t inputs[2048];static unsigned input_count;
static void input_history(avr_t*a,avr_uart_t*u,uint64_t next,unsigned cmd,unsigned index,unsigned wait){
 inputs[input_count++%2048]=(input_state_t){a->cycle,next,last_send,u->input.read,u->input.write,off,cmd,index,acks,wait};
}
static void snapshot(avr_t*a,const char*why);
static void select_anchor(avr_t*a,avr_uart_t*u){
 if(selected||!work||a->pc!=0x71c6||!prep_active||wang_active||wang_done!=generation||!generation||unknown)return;
 unsigned spindle=0,math=0,timer1=0,timer0=0;
 for(unsigned i=0;i<depth;i++){
  if(frames[i].to==0x1c6c)spindle=1;
  if(frames[i].to==0x7870||frames[i].to==0x7872||frames[i].to==0x7894||frames[i].to==0x75f6||frames[i].to==0x796e||frames[i].to==0x793a)math=1;
  if(frames[i].irq==11&&spindle&&math)timer1=1;
  if(frames[i].irq==16&&timer1)timer0=1;
 }
 if(!spindle||!math||!timer0)return;
 selected=a->cycle;uint64_t target=selected-1496;input_state_t*at=NULL;
 unsigned begin=input_count>2048?input_count-2048:0;
 for(unsigned i=begin;i<input_count;i++)if(inputs[i%2048].cycle==target)at=&inputs[i%2048];
 input_state_t*now=&inputs[(input_count-1)%2048];
 unsigned sending_now=ready&&!off&&a->cycle>=now->next&&(!now->wait||acks>=now->wait)&&now->cmd<22;
 unsigned eligible=at&&at->read==at->write&&last_send<target&&!sending_now&&u->cycles_per_byte==1496&&word(a,0xc4)==16&&(a->data[0xc0]&2)&&a->data[0xc2]==6;
 fprintf(trace,"anchor T=%"PRIu64" target=%"PRIu64" eligible=%u exact_history=%u generation=%u returns=%u\n",selected,target,eligible,at!=NULL,generation,wang_returns);
 for(unsigned i=begin;i<input_count;i++){input_state_t*s=&inputs[i%2048];if(s->cycle+8>=target)fprintf(trace,"input-state %"PRIu64" next=%"PRIu64" last=%"PRIu64" fifo=%u/%u off=%u cmd=%u index=%u acks=%u wait=%u\n",s->cycle,s->next,s->last,s->read,s->write,s->off,s->cmd,s->index,s->acks,s->wait);}
 snapshot(a,"selected-anchor");
}
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
  }else{
   if(frames[depth-1].to==0x1ae2){if(!wang_active||ret!=0x3eba)die("Wang return mismatch");wang_active=0;wang_done=generation;wang_returns++;fprintf(trace,"wang-return %"PRIu64" generation=%u sp=%x return=%x\n",(uint64_t)a->cycle,generation,sp,ret);}
   depth--;hist(a,op==0x9518?"reti":"ret",pc,ret,sp);
  }
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
 if(a->pc==0x3e82){if(wang_active)die("driver with active Wang");generation++;}
 if(a->pc==0x1ae2){if(wang_active||return_pc(a,word(a,0x5d))!=0x3eba)die("Wang entry mismatch");wang_active=1;fprintf(trace,"wang-entry %"PRIu64" generation=%u sp=%x\n",(uint64_t)a->cycle,generation,word(a,0x5d));}
 if(a->pc==0x1f00){if(prep_active||wang_active)die("prep nesting mismatch");if(work&&generation&&wang_done!=generation)die("prep before matched Wang return");prep_entries++;prep_active=1;prep_sp=word(a,0x5d);prep_ret=return_pc(a,prep_sp);hist(a,"prep-entry",a->pc,prep_ret,prep_sp);}
 if(a->pc==0x2d56){status_hits++;snapshot(a,"status-body");}
}
static void assert_word(avr_t*a,unsigned pc,unsigned expected){if((unsigned)(a->flash[pc]|a->flash[pc+1]<<8)!=expected)die("phase map opcode mismatch");}
static void phase_map(avr_t*a){
 assert_word(a,0x1f00,0xe3a6); /* Exact candidate ELF map, not a relocation assumption. */
 assert_word(a,0x1ae2,0xe0ac);assert_word(a,0x3e82,0xe0a4);
 assert_word(a,0x3eb6,0x940e);assert_word(a,0x3eb8,0x0d71);
 assert_word(a,0x2d52,0xff10);assert_word(a,0x2d56,0xe08c);
 assert_word(a,0x71c6,0x939f);assert_word(a,0x6e08,0x9320);
 for(unsigned i=1;i<=25;i++){avr_irq_t*q=avr_get_interrupt_irq(a,i);if(q)avr_irq_register_notify(q+AVR_INT_IRQ_RUNNING,entering_irq,a);}
}
