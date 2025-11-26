#!/usr/bin/env python3
"""
Analyze -ffast-math safety for Grbl firmware
Focus on critical float operations in motion control code
"""

import re
import sys
from typing import Dict, List, Tuple
from dataclasses import dataclass
from enum import Enum

class RiskLevel(Enum):
    SAFE = 0        # No observable impact
    LOW = 1         # Minor changes, likely safe
    MEDIUM = 2      # Needs verification
    HIGH = 3        # Careful testing required
    CRITICAL = 4    # Potentially dangerous

@dataclass
class FloatOperation:
    """Represents a floating-point operation"""
    function: str
    operation: str   # add, mul, div, sqrt, etc
    line_num: int
    instruction: str
    risk: RiskLevel = RiskLevel.SAFE

@dataclass
class FunctionAnalysis:
    """Analysis result for a function"""
    name: str
    category: str    # motion_planning, arc, spline, stepper
    baseline_size: int
    optimized_size: int
    size_delta: int
    operations_changed: List[FloatOperation]
    risk_level: RiskLevel
    concerns: List[str]

# Critical functions to analyze
CRITICAL_FUNCTIONS = {
    # Motion planning (planner.c)
    'plan_buffer_line': 'motion_planning',
    'planner_recalculate': 'motion_planning',
    'prep_segment_buffer': 'motion_planning',
    'st_prep_buffer': 'motion_planning',

    # Arc interpolation (motion_control.c)
    'mc_arc': 'arc_interpolation',

    # Spline support (motion_control.c)
    'mc_cubic_b_spline': 'spline',
    'eval_bezier': 'spline',
    'interp': 'spline',
    'dist1': 'spline',

    # Stepper (stepper.c)
    'st_prep_buffer': 'stepper',
    'st_update_plan_block_parameters': 'stepper',

    # System math
    'sqrt': 'math_lib',
    'sin': 'math_lib',
    'cos': 'math_lib',
    'atan2': 'math_lib',
}

# Risky operation patterns
RISKY_PATTERNS = {
    'associative_change': r'(fadd|fsub).*\n.*\1',  # Reordered additions
    'reciprocal_div': r'__divsf3x',                # Division → reciprocal multiplication
    'fma_contraction': r'fmul.*fadd',              # a*b + c might become FMA
    'sqrt_approx': r'__sqrt.*rsqrt',               # Reciprocal sqrt approximation
    'precision_loss': r'fcvt.*rjmp',               # Conversion with precision loss
}

def parse_disassembly(filename: str) -> Dict[str, List[str]]:
    """Parse disassembly file and extract functions"""
    functions = {}
    current_func = None
    current_lines = []

    with open(filename, 'r') as f:
        for line in f:
            # Function start: "00001234 <function_name>:"
            match = re.match(r'^[0-9a-f]+\s+<(.+?)>:', line)
            if match:
                if current_func:
                    functions[current_func] = current_lines
                current_func = match.group(1)
                current_lines = [line]
            elif current_func:
                current_lines.append(line)

    if current_func:
        functions[current_func] = current_lines

    return functions

def extract_float_operations(func_lines: List[str]) -> List[FloatOperation]:
    """Extract all float operations from function"""
    ops = []

    for i, line in enumerate(func_lines):
        # Look for AVR float library calls
        # __mulsf3, __divsf3, __addsf3, __subsf3, __cmpsf2, etc.
        match = re.search(r'call\s+0x[0-9a-f]+\s+<__(\w+sf3?)>', line)
        if match:
            op_name = match.group(1)
            op = FloatOperation(
                function='',
                operation=op_name,
                line_num=i,
                instruction=line.strip()
            )
            ops.append(op)

    return ops

def analyze_function_diff(baseline_func: List[str], optimized_func: List[str],
                          func_name: str) -> FunctionAnalysis:
    """Analyze differences between baseline and optimized function"""

    # Extract operations
    baseline_ops = extract_float_operations(baseline_func)
    optimized_ops = extract_float_operations(optimized_func)

    # Size comparison
    baseline_size = len(baseline_func)
    optimized_size = len(optimized_func)
    size_delta = optimized_size - baseline_size

    # Find changed operations
    changed_ops = []

    # Check for operation type changes
    baseline_op_types = set(op.operation for op in baseline_ops)
    optimized_op_types = set(op.operation for op in optimized_ops)

    new_ops = optimized_op_types - baseline_op_types
    removed_ops = baseline_op_types - optimized_op_types

    concerns = []
    risk = RiskLevel.SAFE

    # Assess risks
    if new_ops:
        concerns.append(f"New operations: {', '.join(new_ops)}")
        risk = max(risk, RiskLevel.LOW)

    if removed_ops:
        concerns.append(f"Removed operations: {', '.join(removed_ops)}")
        risk = max(risk, RiskLevel.LOW)

    # Check for reciprocal division
    if 'divsf3x' in optimized_op_types:
        concerns.append("RISKY: Division converted to reciprocal multiplication")
        risk = max(risk, RiskLevel.HIGH)

    # Check operation count changes
    op_count_change = len(optimized_ops) - len(baseline_ops)
    if op_count_change < -2:
        concerns.append(f"Significant operation reduction: {op_count_change}")
        risk = max(risk, RiskLevel.MEDIUM)

    # Check for instruction reordering (simple heuristic)
    if size_delta != 0 and len(baseline_ops) == len(optimized_ops):
        concerns.append("Instruction reordering detected (same op count, different size)")
        risk = max(risk, RiskLevel.MEDIUM)

    # Special handling for critical functions
    category = CRITICAL_FUNCTIONS.get(func_name, 'other')

    if category in ['motion_planning', 'arc_interpolation', 'spline']:
        if risk >= RiskLevel.MEDIUM:
            risk = RiskLevel.HIGH
            concerns.append(f"CRITICAL FUNCTION: {category}")

    return FunctionAnalysis(
        name=func_name,
        category=category,
        baseline_size=baseline_size,
        optimized_size=optimized_size,
        size_delta=size_delta,
        operations_changed=changed_ops,
        risk_level=risk,
        concerns=concerns
    )

def generate_report(analyses: List[FunctionAnalysis], output_file: str):
    """Generate markdown report"""

    with open(output_file, 'w') as f:
        f.write("# -ffast-math Safety Analysis Report\n\n")
        f.write(f"**Generated:** {__import__('datetime').datetime.now()}\n\n")
        f.write("---\n\n")

        # Summary statistics
        total = len(analyses)
        by_risk = {level: sum(1 for a in analyses if a.risk_level == level)
                   for level in RiskLevel}

        f.write("## Summary\n\n")
        f.write(f"- **Total functions analyzed:** {total}\n")
        f.write(f"- **Safe:** {by_risk[RiskLevel.SAFE]}\n")
        f.write(f"- **Low risk:** {by_risk[RiskLevel.LOW]}\n")
        f.write(f"- **Medium risk:** {by_risk[RiskLevel.MEDIUM]}\n")
        f.write(f"- **High risk:** {by_risk[RiskLevel.HIGH]}\n")
        f.write(f"- **Critical risk:** {by_risk[RiskLevel.CRITICAL]}\n\n")

        # Critical functions
        critical_analyses = [a for a in analyses if a.name in CRITICAL_FUNCTIONS]

        if critical_analyses:
            f.write("## Critical Functions\n\n")
            f.write("| Function | Category | Size Δ | Risk | Concerns |\n")
            f.write("|----------|----------|--------|------|----------|\n")

            for a in sorted(critical_analyses, key=lambda x: x.risk_level.value, reverse=True):
                concerns_str = "; ".join(a.concerns) if a.concerns else "None"
                f.write(f"| `{a.name}` | {a.category} | {a.size_delta:+d} | "
                       f"{a.risk_level.name} | {concerns_str} |\n")
            f.write("\n")

        # High risk functions
        high_risk = [a for a in analyses if a.risk_level.value >= RiskLevel.HIGH.value]

        if high_risk:
            f.write("## ⚠️ High Risk Functions - Detailed Analysis\n\n")

            for a in high_risk:
                f.write(f"### {a.name}\n\n")
                f.write(f"- **Category:** {a.category}\n")
                f.write(f"- **Risk Level:** {a.risk_level.name}\n")
                f.write(f"- **Size change:** {a.size_delta:+d} bytes\n")
                f.write(f"- **Baseline size:** {a.baseline_size} bytes\n")
                f.write(f"- **Optimized size:** {a.optimized_size} bytes\n\n")

                if a.concerns:
                    f.write("**Concerns:**\n")
                    for concern in a.concerns:
                        f.write(f"- {concern}\n")
                    f.write("\n")

                f.write("**Recommendation:** Manual review required\n\n")
                f.write("---\n\n")

        # Recommendations
        f.write("## Recommendations\n\n")

        if by_risk[RiskLevel.CRITICAL] > 0:
            f.write("⛔ **DO NOT USE -ffast-math**\n\n")
            f.write("Critical safety issues detected in essential functions.\n\n")
        elif by_risk[RiskLevel.HIGH] > 0:
            f.write("⚠️ **USE WITH EXTREME CAUTION**\n\n")
            f.write("High-risk changes detected. Extensive testing required:\n")
            f.write("- Full motion test suite\n")
            f.write("- Arc interpolation validation\n")
            f.write("- Spline accuracy verification\n")
            f.write("- Long-term positional accuracy testing\n\n")
        elif by_risk[RiskLevel.MEDIUM] > 0:
            f.write("⚠️ **CONDITIONAL USE**\n\n")
            f.write("Medium-risk changes detected. Recommended testing:\n")
            f.write("- Basic motion tests\n")
            f.write("- Arc and spline validation\n")
            f.write("- Numerical accuracy spot checks\n\n")
        else:
            f.write("✅ **LIKELY SAFE**\n\n")
            f.write("No high-risk changes detected. Still recommended:\n")
            f.write("- Basic validation testing\n")
            f.write("- Monitor for unexpected behavior\n\n")

        # Testing checklist
        f.write("## Testing Checklist\n\n")
        f.write("- [ ] Linear motion (G0/G1) accuracy test\n")
        f.write("- [ ] Arc interpolation (G2/G3) - various radii\n")
        f.write("- [ ] Cubic spline (G5) - smooth curves\n")
        f.write("- [ ] Quadratic spline (G5.1) - parabolic curves\n")
        f.write("- [ ] Feed rate accuracy verification\n")
        f.write("- [ ] Acceleration profile validation\n")
        f.write("- [ ] Position accuracy over 1000+ moves\n")
        f.write("- [ ] Boundary conditions (tiny/huge moves)\n")
        f.write("- [ ] Sharp corners and direction changes\n")
        f.write("- [ ] Coordinate system transformations\n\n")

def main():
    if len(sys.argv) < 3:
        print("Usage: analyze_float_safety.py <baseline_disasm> <optimized_disasm> [output_report]")
        sys.exit(1)

    baseline_file = sys.argv[1]
    optimized_file = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else "fast_math_safety_report.md"

    print("Parsing baseline disassembly...")
    baseline_funcs = parse_disassembly(baseline_file)

    print("Parsing optimized disassembly...")
    optimized_funcs = parse_disassembly(optimized_file)

    print("Analyzing differences...")
    analyses = []

    # Analyze all critical functions
    for func_name in CRITICAL_FUNCTIONS.keys():
        if func_name in baseline_funcs and func_name in optimized_funcs:
            analysis = analyze_function_diff(
                baseline_funcs[func_name],
                optimized_funcs[func_name],
                func_name
            )
            analyses.append(analysis)

            risk_symbol = {
                RiskLevel.SAFE: "✅",
                RiskLevel.LOW: "⚠️",
                RiskLevel.MEDIUM: "⚠️",
                RiskLevel.HIGH: "🔴",
                RiskLevel.CRITICAL: "🛑"
            }[analysis.risk_level]

            print(f"  {risk_symbol} {func_name}: {analysis.risk_level.name} "
                  f"(Δ {analysis.size_delta:+d} bytes)")

    print(f"\nGenerating report: {output_file}")
    generate_report(analyses, output_file)

    print("Done!")

    # Exit code based on highest risk found
    max_risk = max((a.risk_level.value for a in analyses), default=0)
    sys.exit(min(max_risk, 3))  # Cap at 3 for shell compatibility

if __name__ == '__main__':
    main()
