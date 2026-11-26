"""Frozen G94 map checks and one model-specific phase-A result audit."""
import hashlib,json,re,struct,subprocess,sys
from pathlib import Path

def require(ok,msg):
    if not ok: raise AssertionError(msg)

def fields(line): return dict(re.findall(r'(\w+)=([^ ]+)',line))

def mapped(text):
    out={}
    for line in text.splitlines():
        m=re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} ){1,4})',line)
        if m:out[int(m[1],16)]=bytes.fromhex(m[2])
    return out

if sys.argv[1]=='map':
    p=Path(sys.argv[2]); text=p.read_text() if p.suffix=='.txt' else subprocess.check_output(['avr-objdump','-d',str(p)],text=True)
    words=mapped(text)
    for pc,word in ((0x1d76,0xe3a6),(0x2bc8,0xff10),(0x2bcc,0xe08c),(0x71c6,0x939f),(0x6e08,0x9320),(0x6c9e,0x91e0)):
        require(struct.unpack('<H',words[pc][:2])[0]==word,f'map {pc:x}')
    # The host decoder is deliberately limited to 328P 16-bit return PCs.
    def target(pc,op,n):
        if op&0xfe0e in (0x940e,0x940c):return 2*(n|((op&1)<<16)|((op&0x1f0)<<13))
        rel=op&4095;rel=rel-4096 if rel&2048 else rel
        return pc+2+2*rel
    require(target(0x100,0xd000,0)==0x102,'rcall allocation')
    require(target(0x100,0xdffe,0)==0xfe,'rcall negative')
    require(target(0x306a,0x940e,0xebb)==0x1d76,'call prep')
    require(2*((0x12<<8)|0x34)==0x2468,'stack word-PC order')
    print('Frozen map and decoder arithmetic smoke checks passed')
else:
    root=Path(sys.argv[2]);o=root/'g94-observed';b=root/'g94-blind'
    require(hashlib.sha256((root/'g94.elf').read_bytes()).hexdigest()=='482c6d098adeeaf4db536b959296b5da3a08a49b2a95ae3fa2f05c1415a00e29','exact ELF')
    for suffix in ('.uart','.events'):require(o.with_suffix(suffix).read_bytes()==b.with_suffix(suffix).read_bytes(),'parity '+suffix)
    traces=[p.with_suffix('.trace').read_text().splitlines() for p in (o,b)]
    end=[[x for x in t if x.startswith('end ')] for t in traces];require(all(len(x)==1 for x in end),'end count')
    require(end[0][0].split(' raw=')[0]==end[1][0].split(' raw=')[0],'end parity')
    require('state=0' in end[0][0] and 'commands=22 acks=22' in end[0][0],'completion')
    phase=[fields(next(x for x in t if x.startswith('phase '))) for t in traces]
    require(phase[0]==phase[1],'phase parity')
    require(all(phase[0][k]=='1' for k in ('sent','udr','status')),'one question and status')
    timer=fields(next(x for x in traces[0] if x.startswith('timer ')))
    known=all(timer[k]=='0' for k in ('missed','near','equal','boundary','prescaler_changes')) and timer['initial_start']=='1' and not any(x.startswith('ocr1a stopped') for x in traces[0])
    markers=[x for x in traces[0] if x.startswith('snapshot ') and any(k in x for k in ('question-send','question-udr','status-body','rx-ready','effective-low'))]
    statuses=[x for x in o.with_suffix('.uart').read_text().splitlines() if x.startswith('<')]
    require(len(statuses)==1,'one UART status frame')
    result=dict(parity=True,ci_scope='Single model-specific G94 phase; not physical UART timing or worst-case safety',end=end[0][0],phase=phase[0],known_hazards_not_observed=known,timer=timer,markers=markers,status=statuses)
    (root/'phase-result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
    require(known,'known timer hazard or ambiguity observed')
    require(phase[0]['unknown']=='0','unresolved chain: keep diagnostic, do not claim unwind success')
