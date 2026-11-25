#!/usr/bin/env python3
"""Full raw identity for parser scratch; not AVR timing or tolerance certification."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('select_native', HERE / 'select_native.py')
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


def directed(mode):
    feed = 'F2' if mode == 'G93' else 'F1000'
    curves = [
        'G5X-10Y1Z-1I-3J4P3Q-2',
        'G5X-10Y-1Z-1P2Q1',
        'X-10Y0Z-1P2Q-1',
        'G5X-10Y2Z-1I-2P3Q-2',
        'G5X-10Y-2Z-1P2Q2',
        'G5.1X-8Y3Z-1I-3J5',
        'G5.1X-6Y-2Z-1I-4J-3',
        'G5X-10Y0Z-1I-3J2P3Q-2',
    ]
    lines = ['G90G21G94G0X0Y0Z0', 'G91' + mode + 'G1' + feed]
    lines += ['*' + command + feed for command in curves]
    lines += ['G94G1X1Y-1Z0F1000', mode + 'G1' + feed,
              '*G5X-10Y0Z-1I-3J4P3Q-4' + feed]
    lines += ['G90G94G0X100Y-40Z2', 'G92X0Y0Z0', 'G91' + mode + 'G1' + feed,
              '*G5X-10Y2Z-1I-3J5P3Q-2' + feed,
              '*G5X-10Y-2Z-1P2Q2' + feed,
              '*G5.1X-8Y3Z-1I-2J4' + feed,
              'G92.1', 'G21G90G94G0X0Y0Z0', 'G20G91' + mode + 'G1' + feed,
              '*G5X-.4Y.1Z-.04I-.12J.16P.12Q-.08' + feed,
              '*G5X-.4Y-.1Z-.04P.08Q.08' + feed,
              '*G5.1X-.3Y.1Z-.04I-.12J.2' + feed,
              'G21G90G94G0X0Y0Z0', 'G91' + mode + 'G1' + feed,
              '*G5X-10Y2I-3J5P3Q-2' + feed,
              '*G5.1X-8Y3I-2J4' + feed]
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reference', required=True, type=Path)
    parser.add_argument('--candidate', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--make', default='make')
    parser.add_argument('--cc', default='gcc')
    args = parser.parse_args()
    checker.controls()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    temporary = out / 'tmp'
    temporary.mkdir()
    env = os.environ.copy()
    for name in ('TMP', 'TEMP', 'TMPDIR'):
        env[name] = str(temporary)
    priority = {'creationflags': subprocess.IDLE_PRIORITY_CLASS} if os.name == 'nt' else {}

    def run(command, label, cwd=out, seconds=120):
        process = subprocess.run(list(map(str, command)), cwd=cwd, env=env,
                                 capture_output=True, timeout=seconds, **priority)
        (out / (label + '.stdout')).write_bytes(process.stdout)
        (out / (label + '.stderr')).write_bytes(process.stderr)
        return process

    def success(command, label, cwd=out, seconds=120):
        process = run(command, label, cwd, seconds)
        checker.require(process.returncode == 0, f'{label}: exit {process.returncode}')
        return process.stdout.decode('ascii')

    result = {'notice': 'Native raw identity only; no AVR timing, stack or tolerance certificate.',
              'controls': '32 negative and two positive controls passed', 'sigma_mm': checker.SIGMA,
              'source': {}, 'corpora': {}, 'vectors': {}}
    result['harness'] = success(['git', '-C', HERE, 'rev-parse', 'HEAD'], 'harness').strip()
    success([args.cc, '--version'], 'compiler')
    success([args.make, '--version'], 'make')
    executables = {}
    variants = (('reference', args.reference, ''), ('scratch-off', args.candidate, ''),
                ('scratch', args.candidate, ' -DBEZIER_PARSER_SCRATCH'))
    for name, source, extra in variants:
        source = source.resolve()
        revision = success(['git', '-C', source, 'rev-parse', 'HEAD'], name + '-revision').strip()
        options = checker.OPTIONS + ' ' + checker.EXTRA['select'] + extra
        (out / (name + '-options.txt')).write_text(options + '\n', encoding='ascii')
        build = out / name
        success([args.make, '-s', '-j1', 'GRBL=' + (source / 'grbl').as_posix(),
                 'BUILD=' + build.as_posix(), 'CC=' + args.cc, 'OPT=' + options,
                 (build / 'select-emit').as_posix(), (build / 'tb').as_posix()],
                name + '-build', HERE.parent / 'host', 180)
        suffix = '.exe' if os.name == 'nt' else ''
        executables[name] = (build / ('select-emit' + suffix), build / ('tb' + suffix))
        result['source'][name] = {'revision': revision, 'options': options,
                                 'executable_sha256': hashlib.sha256(executables[name][0].read_bytes()).hexdigest()}

    for mode in ('G94', 'G93'):
        for corpus, expected in (('ordinary', 33), ('loose', 18), ('directed', 17)):
            input_file = out / f'{corpus}-{mode}.in'
            if corpus == 'loose':
                success([sys.executable, '-I', HERE / 'render.py', HERE / 'loose.in', input_file,
                         '--mode', mode], f'render-{mode}')
            else:
                text = directed(mode) if corpus == 'directed' else checker.ordinary(mode)
                input_file.write_text(text, encoding='ascii')
            lines = input_file.read_text(encoding='ascii').splitlines()
            checker.require(all(len(line) < 80 for line in lines if line and not line.startswith('#')), 'line length')
            commands = [line[1:] for line in lines if line.startswith('*')]
            checker.require(len(commands) == expected, 'corpus count')
            decoded = {}
            for name, (emit, _) in executables.items():
                text = success([emit, input_file], f'{name}-{corpus}-{mode}', seconds=45)
                decoded[name] = checker.decode(text, commands, mode)
                checker.identity(decoded[name], decoded['reference'])
            current = decoded['scratch']
            key = f'{corpus}/{mode}'
            result['corpora'][key] = {'curves': expected, 'targets': sum(len(c['raw']) for c in current),
                                      'identity': 'all five target words, start/net and all 12 summary words',
                                      'max_z_mm': max(c['z_mm'] for c in current),
                                      'over_002': sum(c['z_mm'] > checker.SIGMA for c in current),
                                      'max_g93_relative': max((c['g93_relative'] or 0) for c in current),
                                      'input_sha256': hashlib.sha256(input_file.read_bytes()).hexdigest()}
            print(f'{key}: {expected} curves, scratch and scratch-off full raw identity PASS', flush=True)

    vectors = sorted((HERE.parent / 'host/vectors').glob('*.vec'))
    vector_reference = None
    for name, (_, bench) in executables.items():
        process = run([bench, *vectors], name + '-vectors', HERE.parent / 'host', 90)
        diagnostics = (process.returncode, process.stdout, process.stderr)
        if vector_reference is None:
            vector_reference = diagnostics
        checker.require(diagnostics == vector_reference, name + ': vector diagnostics changed')
        checker.require(process.returncode in (0, 1), name + ': unexpected vector exit')
        result['vectors'][name] = {'exit': process.returncode,
                                   'summary': process.stdout.decode('ascii').splitlines()[-1],
                                   'stdout_sha256': hashlib.sha256(process.stdout).hexdigest(),
                                   'stderr_sha256': hashlib.sha256(process.stderr).hexdigest()}
    (out / 'metrics.json').write_text(json.dumps(result, indent=2) + '\n', encoding='ascii')
    print('Vector diagnostic identity PASS; ' + result['vectors']['scratch']['summary'], flush=True)
    print('Native parser identity PASS; vector failures, if present, are retained, not waived as passing tests.', flush=True)


if __name__ == '__main__':
    main()
