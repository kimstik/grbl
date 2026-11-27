/* Synthetic host observer checks, never executes AVR firmware. */
#define TIMER1_SMOKE
#define main observer_main
#include "timer1_tail.c"
#undef main
#include <assert.h>
int main(void){
 avr_t a={0};unsigned char data[0x900]={0};a.data=data;trace=tmpfile();metrics=tmpfile();assert(trace&&metrics);
 sys_addr=0x100;busy_addr=0x101;rt_addr=0x102;work=ready=1;off=0;a.pc=0x715a;a.cycle=2000;data[sys_addr]=8;data[busy_addr]=1;data[0x2b]=4;data[0x45]=2;data[0xc4]=16;data[0xc0]=2;data[0xc2]=6;data[0x5d]=0xff;data[0x5e]=8;
 avr_uart_t u={0};u.cycles_per_byte=1496;input_history(&a,&u,2100,18,0,1);select_anchor(&a,&u);assert(selected==2000);
 a.cycle=2100;select_anchor(&a,&u);assert(selected==2000);
 settings_metric=0x200;data[0x2a]=0x1c;
 pulse_t p={.a=&a,.axis=0,.minimum=UINT64_MAX};pin_seed(&p,0);
 /* No initial notification: the first callback is the real rising edge. */
 pin_edge(NULL,1,&p);a.cycle+=160;pin_edge(NULL,0,&p);assert(p.count==1&&p.hist[160]==1&&p.signed_steps==1);
 pin_edge(NULL,0,&p);pin_edge(NULL,0,&p);a.cycle+=100;pin_edge(NULL,1,&p);a.cycle+=161;pin_edge(NULL,0,&p);assert(p.count==2&&p.hist[161]==1&&!p.rise);
 pulse_t high={.a=&a,.axis=1,.minimum=UINT64_MAX};pin_seed(&high,1);work=0;pin_edge(NULL,1,&high);pin_edge(NULL,0,&high);assert(!high.count&&!high.rise&&!high.bootstrap_high);work=1;
 /* Return followed by an interrupt must match saved pre-RET address. */
 data[0x5d]=0xfd;data[0x8fe]=0x1f;data[0x8ff]=0x5d;a.pc=0x1ae2;generation=1;trace_after(&a,0x3eb6,0x940e,0x8ff,0x0d71,0,0,0);trace_before(&a);assert(depth==1&&wang_active);
 irq_seen=1;irq_ret=0x3eba;irq_sp=0x8fd;irq_vector=11;a.pc=44;trace_after(&a,0x7b90,0x9508,0x8fd,0,0,0,0x3eba);assert(!wang_active&&wang_returns==1&&!unknown);
 puts("synthetic semantic anchor, edge widths, and return/IRQ decoder checks passed");fclose(trace);fclose(metrics);return 0;
}
