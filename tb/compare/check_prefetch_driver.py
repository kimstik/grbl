"""Compare the real spline drivers with scripted queue, reserve and abort states.

This is a native control-flow check, not evidence about live stepper timing.
"""
import argparse
import os
from pathlib import Path
import re
import subprocess


def require(condition, message):
    if not condition:
        raise ValueError(message)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('baseline', 'prefetch', 'compact'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    host = root / 'tb' / 'host'
    env = os.environ.copy()
    env['TMP'] = env['TEMP'] = str(output)
    priority = {'creationflags': subprocess.IDLE_PRIORITY_CLASS} if os.name == 'nt' else {}
    compiler = env.get('CC', 'gcc')
    version = subprocess.run([compiler, '--version'], check=True, capture_output=True,
                             timeout=10, env=env, **priority)
    (output / 'compiler.txt').write_bytes(version.stdout + version.stderr)
    flags = ['-std=gnu99', '-O2', '-Wall', '-flto', '-ffunction-sections', '-fdata-sections',
             '-fsingle-precision-constant', '-ffast-math', '-DENABLE_CUBIC_SPLINES',
             '-DENABLE_QUADRATIC_SPLINES', '-DBEZIER_Z_TRACE',
             '-DBEZIER_SIGMA=settings.arc_tolerance', '-DBEZIER_Z_LINEAR=3',
             '-DBEZIER_Z_LOOSE', '-DBEZIER_EXACT_INVERSE_TIME']
    results, events = {}, {}
    for name in ('baseline', 'prefetch', 'compact'):
        source = getattr(args, name).resolve() / 'grbl'
        require((source / 'motion_control.c').is_file(), name + ': missing source')
        exe = output / (name + ('.exe' if os.name == 'nt' else ''))
        command = [compiler, *flags, '-I' + str(host), '-I' + str(source),
                   '-include', str(host / 'prelude.h'),
                   '-DMC_SOURCE="' + (source / 'motion_control.c').as_posix() + '"']
        if name != 'baseline':
            command.append('-DBEZIER_Z_PREFETCH')
        command += [str(root / 'tb' / 'compare' / 'prefetch_driver.c'),
                    str(source / 'nuts_bolts.c'), '-Wl,--gc-sections', '-lm', '-o', str(exe)]
        build = subprocess.run(command, cwd=output, env=env, capture_output=True,
                               timeout=90, **priority)
        (output / (name + '-build.txt')).write_bytes(build.stdout + build.stderr)
        require(build.returncode == 0, name + ': build failed; see build log')
        optional = 0
        for abort in (0, 1, 2):
            for strategy in (0, 1, 2):
                key = (name, strategy, abort)
                label = f'{name}-{strategy}-{abort}'
                run = subprocess.run([str(exe), str(strategy), str(abort)], cwd=output,
                                     env=env, capture_output=True, timeout=30, **priority)
                (output / (label + '.txt')).write_bytes(run.stdout)
                (output / (label + '-events.txt')).write_bytes(run.stderr)
                require(run.returncode == 0, label + ': assertion or execution failed')
                require(len(re.findall(rb'^curve ', run.stdout, re.M)) == 20,
                        label + ': incomplete curve set')
                results[key], events[key] = run.stdout, run.stderr
                require(run.stdout == results['baseline', 0, abort],
                        label + ': XYZ/feed/condition/trace bits differ')
                if name == 'compact':
                    require(run.stderr == events['prefetch', strategy, abort],
                            label + ': realtime/planner/reserve event sequence differs')
                if abort == 0:
                    optional += sum(map(int, re.findall(rb' optional(\d+)', run.stderr)))
        require(name == 'baseline' or optional > 0, name + ': no scripted optional work')
        print(name + ': 20 curves x 3 reserve scripts x 3 abort modes verified')
    print('XYZ/feed/condition/trace bits identical; compact and frozen A2 event sequences identical')


if __name__ == '__main__':
    main()
