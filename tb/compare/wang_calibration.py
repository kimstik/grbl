"""Exact calibration map, parity and conservative hazard gates."""
from pathlib import Path
import hashlib,json,re,struct,subprocess,sys,shutil
HASH='0e747a0c99cea41fe033ac93920de5a6a2ad2cc540b1ceedd8848c0d75ca8c11'
def fields(s):return dict(re.findall(r'(\w+)=([^ ]+)',s))
if sys.argv[1]=='prepare':
 src,out=map(Path,sys.argv[2:]);p=src/'candidate/production.elf';assert hashlib.sha256(p.read_bytes()).hexdigest()==HASH
 size=subprocess.check_output(['avr-size',str(p)],text=True);a,b,c=map(int,size.splitlines()[1].split()[:3]);assert a+b<=32256 and b+c==1670
 text=subprocess.check_output(['avr-objdump','-d',str(p)],text=True);ins={}
 for line in text.splitlines():
  m=re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} ){1,4})',line)
  if m:ins[int(m[1],16)]=bytes.fromhex(m[2])
 for pc,op in ((0x1f00,0xe3a6),(0x1ae2,0xe0ac),(0x3e82,0xe0a4),(0x3eb6,0x940e),(0x2d52,0xff10),(0x2d56,0xe08c),(0x71c6,0x939f),(0x6e08,0x9320)):
  assert struct.unpack_from('<H',ins[pc])[0]==op,hex(pc)
 assert ins[0x3eb6]==bytes.fromhex('0e94710d')
 out.mkdir(exist_ok=True);shutil.copyfile(p,out/'g94.elf');(out/'g94-disassembly.txt').write_text(text);(out/'size.txt').write_text(size);(out/'production-sha256.txt').write_text(HASH+'\n')
else:
 root=Path(sys.argv[2]);tr=[]
 for arm in ('observed','blind'):tr.append((root/f'g94-{arm}.trace').read_text().splitlines())
 for suffix in ('uart','events'):assert (root/f'g94-observed.{suffix}').read_bytes()==(root/f'g94-blind.{suffix}').read_bytes()
 assert not any(line.split()[1]=='63' for line in (root/'g94-observed.events').read_text().splitlines())
 def one(lines,prefix):
  v=[x for x in lines if x.startswith(prefix)];assert len(v)==1,(prefix,len(v));return v[0]
 ends=[one(t,'end ') for t in tr];assert ends[0].split(' raw=')[0]==ends[1].split(' raw=')[0];assert 'state=0' in ends[0] and 'commands=22 acks=22' in ends[0]
 cal=[fields(one(t,'calibration ')) for t in tr]
 for k in ('selected','generations','returns','active','unknown','udr','status','prep_entries'):assert cal[0][k]==cal[1][k]
 assert cal[0]['generations']==cal[0]['returns']=='4' and all(cal[0][k]=='0' for k in ('active','unknown','udr','status'))
 anchors=[[s for s in t if s.startswith('anchor ')] for t in tr];assert anchors[0]==anchors[1]
 history=[[s for s in t if s.startswith('input-state ')] for t in tr];assert history[0]==history[1]
 timer=fields(one(tr[0],'timer '));assert one(tr[0],'timer ')==one(tr[1],'timer ')
 known=all(timer[k]=='0' for k in ('missed','near','equal','boundary','prescaler_changes')) and timer['initial_start']=='1' and not any(s.startswith('ocr1a stopped') for s in tr[0])
 eligible=len(anchors[0])==1 and fields(anchors[0][0])['eligible']=='1'
 result=dict(parity=True,end=ends[0],calibration=cal[0],anchor=anchors[0],eligible=eligible,timer=timer,known_hazards_not_observed=known,scope='One baseline, no question byte; model-specific, not production safety')
 (root/'calibration-result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
 assert known,'known timer hazard or ambiguity observed'
 assert eligible,'no eligible first anchor; do not retarget'
