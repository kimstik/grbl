/* Host-only edge and interrupt measurements. No simulated state writes. */
typedef struct { avr_t *a; unsigned axis,level,seen,bootstrap_high; uint64_t rise,count,minimum,maximum; int64_t signed_steps; unsigned hist[4096],wide; } pulse_t;
static pulse_t pulse[3];
static FILE *metrics;
static unsigned settings_metric;
static void pin_seed(pulse_t*p,unsigned level){p->seen=1;p->level=level;p->bootstrap_high=level;}
static uint64_t pending_at[26],last_t1,interval_min=UINT64_MAX,interval_max;
static unsigned pending_valid[26],irq_active[26],max_t1,t1_entries,t1_busy_entries,pending_serial[26];
static uint64_t anchor_end;
static unsigned rt_addr,control_flag,control_clear,status_flag,status_clear;
static void pin_edge(struct avr_irq_t*q,uint32_t v,void*x){
 (void)q;pulse_t*p=x;avr_t*a=p->a;unsigned level=v&1;
 if(!p->seen)die("pin observer not seeded");
 if(level==p->level)return;
 p->level=level;
 if(p->bootstrap_high){if(level)die("bootstrap high transition");fprintf(metrics,"bootstrap-incomplete %"PRIu64" axis=%u\n",(uint64_t)a->cycle,p->axis);p->bootstrap_high=0;if(work)die("initial high pulse crosses workload");return;}
 if(!work)return;
 if((a->data[0x2a]&0x1c)!=0x1c||a->data[settings_metric+0x31]!=0)die("step DDR/inversion edge guard");
 fprintf(metrics,"pin%"PRIu64" axis=%u level=%u dir=%u\n",(uint64_t)a->cycle,p->axis,level,a->data[0x2b]&0xe0);
 if(level){if(p->rise)die("unpaired pulse rise");p->rise=a->cycle;p->count++;p->signed_steps+=(a->data[0x2b]&(1u<<(p->axis+5)))?-1:1;}
 else{if(!p->rise)die("unpaired pulse fall");uint64_t width=a->cycle-p->rise;p->rise=0;if(width<p->minimum)p->minimum=width;if(width>p->maximum)p->maximum=width;if(width<4096)p->hist[width]++;else p->wide++;
  fprintf(metrics,"width %"PRIu64" axis=%u cycles=%"PRIu64"\n",(uint64_t)a->cycle,p->axis,width);
 }
}
static void pending_edge(struct avr_irq_t*q,uint32_t v,void*x){
 avr_t*a=x;unsigned vec=q->irq/AVR_INT_IRQ_COUNT;
 /* q->irq is not a vector identifier; locate the registered vector by pointer. */
 for(vec=1;vec<=25;vec++)if(avr_get_interrupt_irq(a,vec)==q)break;
 if(vec>25)die("pending vector map");
 if(!v){pending_valid[vec]=0;return;}
 if(pending_valid[vec])return; /* A notification is a pending episode, not every overflow. */
 pending_valid[vec]=1;pending_at[vec]=a->cycle;pending_serial[vec]++;
 if(work&&(vec==11||vec==16||vec==4||vec==18))fprintf(metrics,"pending %"PRIu64" vector=%u episode=%u I=%u flag0=%u mask0=%u pc=%x\n",(uint64_t)a->cycle,vec,pending_serial[vec],a->sreg[7],a->data[0x35],a->data[0x6e],a->pc);
}
static void running_edge(struct avr_irq_t*q,uint32_t v,void*x){
 avr_t*a=x;unsigned vec;
 for(vec=1;vec<=25;vec++){avr_irq_t*base=avr_get_interrupt_irq(a,vec);if(base&&base+AVR_INT_IRQ_RUNNING==q)break;}
 if(vec>25)die("running vector map");
 if(v){irq_active[vec]++;if(vec==11){t1_entries++;if(a->data[busy_addr])t1_busy_entries++;if(irq_active[11]>max_t1)max_t1=irq_active[11];if(last_t1&&work){uint64_t d=a->cycle-last_t1;if(d<interval_min)interval_min=d;if(d>interval_max)interval_max=d;}last_t1=a->cycle;}
  if(work&&(vec==11||vec==16||vec==4||vec==18))fprintf(metrics,"vector %"PRIu64" vector=%u pending_valid=%u pending=%"PRIu64" delay=%"PRIu64" depth11=%u return=%x\n",(uint64_t)a->cycle,vec,pending_valid[vec],pending_at[vec],pending_valid[vec]?(uint64_t)a->cycle-pending_at[vec]:0,irq_active[11],return_pc(a,word(a,0x5d)));
 }else{if(!irq_active[vec])die("running IRQ underflow");irq_active[vec]--;}
}
static void metrics_init(avr_t*a,const char*prefix){
 char path[512];snprintf(path,sizeof(path),"%s.metrics",prefix);metrics=fopen(path,"w");if(!metrics)die("metrics file");
 /* Single-threaded pre-execution subscription, then read-only seed. No cycle or
    pin write occurs between subscription and GETSTATE; no notification is forced. */
 for(unsigned i=0;i<3;i++){pulse[i].a=a;pulse[i].axis=i;pulse[i].minimum=UINT64_MAX;avr_irq_register_notify(avr_io_getirq(a,AVR_IOCTL_IOPORT_GETIRQ('D'),IOPORT_IRQ_PIN2+i),pin_edge,&pulse[i]);}
 avr_ioport_state_t pins={0};if(avr_ioctl(a,AVR_IOCTL_IOPORT_GETSTATE('D'),&pins)<0)die("initial pin read");
 for(unsigned i=0;i<3;i++)pin_seed(&pulse[i],(pins.pin>>(i+2))&1);
 fprintf(metrics,"bootstrap cycle=%"PRIu64" pin=%u port=%u ddr=%u\n",(uint64_t)a->cycle,pins.pin,pins.port,pins.ddr);
 for(unsigned i=1;i<=25;i++){avr_irq_t*q=avr_get_interrupt_irq(a,i);if(q){avr_irq_register_notify(q+AVR_INT_IRQ_PENDING,pending_edge,a);avr_irq_register_notify(q+AVR_INT_IRQ_RUNNING,running_edge,a);}}
}
static void metrics_after(avr_t*a,unsigned pc,unsigned oldrt){
 unsigned rt=a->data[rt_addr];
 if(selected){
  if(!control_flag&&!(oldrt&2)&&(rt&2)){control_flag=1;fprintf(metrics,"control-flag %"PRIu64" pc=%x\n",(uint64_t)a->cycle,pc);}
  if(control_flag&&!control_clear&&(oldrt&2)&&!(rt&2)){control_clear=1;fprintf(metrics,"control-consumed %"PRIu64" pc=%x\n",(uint64_t)a->cycle,pc);}
  if(!status_flag&&!(oldrt&1)&&(rt&1)){status_flag=1;fprintf(metrics,"status-flag %"PRIu64" pc=%x\n",(uint64_t)a->cycle,pc);}
  if(status_flag&&!status_clear&&(oldrt&1)&&!(rt&1)){status_clear=1;fprintf(metrics,"status-consumed %"PRIu64" pc=%x\n",(uint64_t)a->cycle,pc);}
  if(!anchor_end&&pc==(candidate?0x71a4u:0x71a2u)){anchor_end=a->cycle;fprintf(metrics,"tail-return %"PRIu64" span=%"PRIu64" I=%u\n",anchor_end,anchor_end-selected,a->sreg[7]);}
 }
 if(work&&(a->data[0xc0]&8))die("UART data overrun");
}
static void metrics_finish(avr_t*a){
 for(unsigned i=0;i<3;i++){pulse_t*p=&pulse[i];if(p->rise)die("unfinished high pulse");fprintf(metrics,"axis %u count=%"PRIu64" signed=%"PRId64" min=%"PRIu64" max=%"PRIu64" wide=%u\n",i,p->count,p->signed_steps,p->minimum,p->maximum,p->wide);for(unsigned j=0;j<4096;j++)if(p->hist[j])fprintf(metrics,"hist axis=%u width=%u count=%u\n",i,j,p->hist[j]);}
 fprintf(metrics,"nest entries=%u busy_entries=%u max_t1=%u interval_min=%"PRIu64" interval_max=%"PRIu64" final_state=%u\n",t1_entries,t1_busy_entries,max_t1,interval_min,interval_max,a->data[sys_addr]);fclose(metrics);
}
