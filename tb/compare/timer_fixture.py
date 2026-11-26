"""Check the Timer1 fixtures against ATmega328P CTC and interrupt semantics.

Datasheet behavior, prescaler 1, CTC with OCR1A as TOP:
- TOP 0 matches on every timer clock; OCF1A is set even while masked and set
  again right after a write-one clear.
- OCF1A stays set while masked; the interrupt is requested as soon as OCIE1A
  is set (Grbl st_wake_up enables the mask after idle matches).
- While the ISR runs with TOP 0, OCF1A is set again, so a second entry follows
  without waiting for a new period.
- Periods are TOP+1 clocks; observed entries jitter by the instruction in
  progress, so periods are checked to ENTRY clocks.
Runs whose every enable saw OCF1A clear must be byte-identical between
pristine and patched simulators.
"""
import json
import sys
from pathlib import Path

ENTRY = 4    # longest fixture instruction in progress at a match
PROMPT = 10  # enable with a set flag: enable store, one instruction, entry


def parse(path):
    e = {'isr': [], 'ocr': [], 'flagged': [], 'mask': [], 'end': None}
    for line in Path(path).read_text().splitlines():
        f = line.split()
        if f[0] == 'isr':
            e['isr'].append(int(f[1]))
        elif f[0] == 'ocr':
            e['ocr'].append((int(f[1]), int(f[2]), int(f[3])))
        elif f[0] == 'flagged':
            e['flagged'].append((int(f[1]), int(f[2])))
        elif f[0] == 'mask':
            e['mask'].append((int(f[1]), int(f[2]), int(f[3]), int(f[4])))
        elif f[0] == 'end':
            e['end'] = (int(f[1]), f[2], f[3])
        else:
            raise SystemExit('unknown row ' + line)
    return e


def enables(e):
    """Mask stores that set OCIE1A, with the OCF1A state seen just before."""
    out, old = [], 0
    for before, after, value, flag in e['mask']:
        if value & 2 and not old & 2:
            out.append((after, flag))
        old = value
    return out


def first_after(isr, cycle):
    return next((c for c in isr if c > cycle), None)


def main(root):
    root = Path(root)
    failures, report = [], {}

    def require(ok, what):
        if not ok:
            failures.append(what)

    def periods(isr, top, what):
        d = [b - a for a, b in zip(isr, isr[1:])]
        require(all(abs(x - (top + 1)) <= ENTRY for x in d), f'{what}: periods {d}')
        return d

    cases = {'top1': 1, 'top99': 99, 'top99-poll': 99, 'wake': 999, 'top0': 0, 'top0-poll': 0}
    for case, top in cases.items():
        p, q = parse(root/f'{case}-pristine.txt'), parse(root/f'{case}-patched.txt')
        same = (root/f'{case}-pristine.txt').read_bytes() == (root/f'{case}-patched.txt').read_bytes()
        flagged_enable = any(flag for _, flag in enables(p)) or not p['isr']
        r = dict(identical=same, enable_with_flag_pristine=[x for x in enables(p)],
                 enable_with_flag_patched=[x for x in enables(q)],
                 isr_pristine=p['isr'], isr_patched=q['isr'], end_pristine=p['end'], end_patched=q['end'])
        if not flagged_enable:
            require(same, f'{case}: pristine and patched differ although no enable saw a set flag')
        require(q['end'][2] == 'hits=4', f'{case}: patched incomplete')
        delays = [(c, flag, first_after(q['isr'], c) - c if first_after(q['isr'], c) else None)
                  for c, flag in enables(q)]
        r['patched_entry_after_enable'] = delays
        r['pristine_entry_after_enable'] = [(c, flag, first_after(p['isr'], c) - c if first_after(p['isr'], c) else None)
                                            for c, flag in enables(p)]
        for c, flag, d in delays:
            if flag:
                require(d is not None and d <= PROMPT, f'{case}: entry {d} cycles after enable with flag set')
        report[case] = r

    q = parse(root/'top1-patched.txt')
    report['top1']['periods'] = periods(q['isr'], 1, 'top1')
    for case in ('top99', 'top99-poll'):
        report[case]['periods'] = periods(parse(root/f'{case}-patched.txt')['isr'], 99, case)

    for case in ('top0', 'top0-poll'):
        p = parse(root/f'{case}-pristine.txt')
        require(not p['isr'] and not p['flagged'], f'{case}: pristine unexpectedly fired')

    e = parse(root/'top0-patched.txt')
    isr, writes = e['isr'], [w for w in e['ocr'] if w[2] == 99]
    require(len(isr) == 4 and len(writes) == 1, 'top0: four entries and one TOP change')
    if len(isr) == 4 and len(writes) == 1:
        w = writes[0][1]
        require(isr[0] < w < isr[1], 'top0: TOP change inside first ISR')
        require(isr[1] - isr[0] < 100, 'top0: latched retrigger missing')
        require(abs(isr[2] - w - 100) <= 1 + ENTRY, 'top0: first nonzero period')
        require(abs(isr[3] - isr[2] - 100) <= ENTRY, 'top0: steady period')
        report['top0'].update(retrigger=isr[1]-isr[0], third_minus_write=isr[2]-w, fourth_minus_third=isr[3]-isr[2])

    e = parse(root/'top0-poll-patched.txt')
    f = e['flagged']
    require([v for _, v in f] == [1, 2], 'top0-poll: masked flag set and set again')
    if len(f) == 2:
        require(f[1][0] - f[0][0] <= 10, 'top0-poll: flag not set again within a few clocks')
        report['top0-poll'].update(flagged=f, reflag=f[1][0]-f[0][0])

    e = parse(root/'top99-poll-patched.txt')
    require([v for _, v in e['flagged']] == [1, 2], 'top99-poll: masked flag set and set again')
    if len(e['flagged']) == 2:
        require(abs(e['flagged'][1][0] - e['flagged'][0][0] - 100) <= ENTRY + 6, 'top99-poll: reflag period')

    e = parse(root/'wake-patched.txt')
    en = enables(e)
    require(len(en) == 2 and en[1][1] == 2, 'wake: second enable saw the idle match flag')
    report['wake']['periods_before_idle'] = periods(e['isr'][:2], 999, 'wake')
    report['failures'] = failures
    print(json.dumps(report, indent=1))
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
