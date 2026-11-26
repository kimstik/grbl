"""Check the Timer1 TOP 0 fixture against ATmega328P CTC semantics.

Expected behavior, prescaler 1, CTC with OCR1A as TOP:
- TOP 0 matches on every timer clock, so OCF1A is set even while masked and
  again right after a write-one clear.
- While the ISR still runs with TOP 0, OCF1A is set again, so a second entry
  follows without waiting for a new period.
- After OCR1A becomes 99 the next match is 100 clocks after the write, within
  one clock of write/clear phase, plus the ordinary interrupt entry latency;
  following periods are exactly 100 clocks.
Controls with nonzero TOP must be byte-identical between pristine and patched.
"""
import json
import sys
from pathlib import Path

ENTRY = (0, 15)  # vector, jump and current-instruction completion bounds in cycles


def parse(path):
    events = {'isr': [], 'ocr': [], 'flagged': [], 'end': None}
    for line in Path(path).read_text().splitlines():
        f = line.split()
        if f[0] == 'isr':
            events['isr'].append(int(f[1]))
        elif f[0] == 'ocr':
            events['ocr'].append((int(f[1]), int(f[2]), int(f[3])))
        elif f[0] == 'flagged':
            events['flagged'].append((int(f[1]), int(f[2])))
        elif f[0] == 'end':
            events['end'] = (int(f[1]), f[2], f[3])
        else:
            raise SystemExit('unknown row ' + line)
    return events


def require(ok, what, failures):
    if not ok:
        failures.append(what)


def main(root):
    root = Path(root)
    failures, report = [], {}
    for case in ('top1', 'top99', 'top99-poll'):
        same = (root/f'{case}-pristine.txt').read_bytes() == (root/f'{case}-patched.txt').read_bytes()
        e = parse(root/f'{case}-patched.txt')
        require(same, f'{case}: pristine and patched differ', failures)
        require(e['end'][2] == 'hits=4', f'{case}: incomplete', failures)
        report[case] = dict(identical=same, isr=e['isr'], end=e['end'])
    d = parse(root/'top99-patched.txt')['isr']
    require([b - a for a, b in zip(d, d[1:])] == [100]*3, 'top99: period differs from 100', failures)

    for case in ('top0', 'top0-poll'):
        p = parse(root/f'{case}-pristine.txt')
        require(not p['isr'] and not p['flagged'], f'{case}: pristine unexpectedly fired', failures)
        report[case + '-pristine'] = dict(isr=p['isr'], flagged=p['flagged'], end=p['end'])

    e = parse(root/'top0-patched.txt')
    isr, writes = e['isr'], [w for w in e['ocr'] if w[2] == 99]
    require(len(isr) == 4 and 'hits=4' in e['end'][2], 'top0: four entries', failures)
    require(len(writes) == 1, 'top0: one TOP change', failures)
    if len(isr) == 4 and writes:
        w = writes[0][1]
        require(isr[0] < w < isr[1], 'top0: TOP change inside first ISR', failures)
        require(isr[1] - isr[0] < 100, 'top0: latched retrigger missing', failures)
        require(100 - 1 + ENTRY[0] <= isr[2] - w <= 100 + 1 + ENTRY[1], 'top0: first nonzero period', failures)
        require(isr[3] - isr[2] == 100, 'top0: steady period', failures)
        report['top0'] = dict(isr=isr, write=writes[0], second_minus_first=isr[1]-isr[0],
                              third_minus_write=isr[2]-w, fourth_minus_third=isr[3]-isr[2])

    e = parse(root/'top0-poll-patched.txt')
    f = e['flagged']
    require([v for _, v in f] == [1, 2], 'poll: masked flag set and set again', failures)
    require(len(e['isr']) == 4, 'poll: four entries after enabling', failures)
    if len(f) == 2 and e['isr']:
        require(f[1][0] - f[0][0] <= 10, 'poll: flag not set again within a few clocks', failures)
        require(0 < e['isr'][0] - f[1][0] <= 30, 'poll: pending entry after enable', failures)
        report['top0-poll'] = dict(flagged=f, isr=e['isr'], reflag=f[1][0]-f[0][0],
                                   first_entry_after_reflag=e['isr'][0]-f[1][0])
    report['failures'] = failures
    print(json.dumps(report, indent=1))
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
