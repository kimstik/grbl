"""Exact image gate and observed/blind external event parity."""
from pathlib import Path
import sys,hashlib,subprocess,re,json,shutil
HASH={'g94':'482c6d098adeeaf4db536b959296b5da3a08a49b2a95ae3fa2f05c1415a00e29','g93':'d0dea7dbd009bed535e54835441528ffdd75be67068e2969b9638cf99950deef'}
if sys.argv[1]=='prepare':
 src,out=map(Path,sys.argv[2:]);out.mkdir(exist_ok=True)
 for mode,digest in HASH.items():
  p=src/f'local-build-{mode}'/'candidate/production.elf'
  assert hashlib.sha256(p.read_bytes()).hexdigest()==digest
  size=subprocess.check_output(['avr-size',str(p)],text=True);a,b,c=map(int,size.splitlines()[1].split()[:3]);assert a+b<=32256 and b+c==1670
  nm=subprocess.check_output(['avr-nm','-n',str(p)],text=True);assert re.search(r'00800786\s+B\s+__bss_end',nm)
  shutil.copyfile(p,out/f'{mode}.elf');(out/f'{mode}.size').write_text(size);(out/f'{mode}.symbols').write_text(nm)
 (out/'provenance.json').write_text(json.dumps(HASH,indent=2))
else:
 root=Path(sys.argv[2]);result={}
 for mode in HASH:
  a=root/f'{mode}-observed';b=root/f'{mode}-blind'
  assert a.with_suffix('.uart').read_bytes()==b.with_suffix('.uart').read_bytes()
  assert a.with_suffix('.events').read_bytes()==b.with_suffix('.events').read_bytes()
  ends=[]
  for p in (a,b):
   text=p.with_suffix('.trace').read_text();end=text.splitlines()[-1];assert end.startswith('end ')
   ends.append(end.split(' raw=')[0]);assert 'state=0' in end and 'commands=22 acks=22' in end
  assert ends[0]==ends[1]
  result[mode]=dict(parity=True,end=a.with_suffix('.trace').read_text().splitlines()[-1],scope='Observed baseline only; not worst-case stack proof; written minimum covers stack pushes, not all local stores')
 (root/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
