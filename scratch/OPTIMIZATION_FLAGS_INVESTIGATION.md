# AVR-GCC Optimization Flags Investigation Plan

**Date:** 2025-11-26
**GCC Version:** avr-gcc 15.2
**Target:** ATmega328P (Grbl firmware)
**Objective:** Analyze impact and safety of aggressive optimization flags

---

## Executive Summary

**Baseline size:** 30,066 bytes (avr-gcc 15.2)
**Optimized size:** 28,444 bytes (with all flags)
**Savings:** 1,622 bytes (5.4% reduction)

**Flags tested:**
```makefile
COMPILE += -flto                    # Link-Time Optimization
COMPILE += -fno-inline-small-functions
COMPILE += -Wl,--relax              # Linker relaxation
COMPILE += -ffast-math              # ⚠️ DANGEROUS: Fast math
COMPILE += -mcall-prologues         # Share function prologues
COMPILE += -fno-split-wide-types    # Keep 32/64-bit types together
COMPILE += -fno-tree-scev-cprop     # Disable SCEV constant propagation
```

---

## 🎯 Investigation Goals

### Primary Goals
1. **Measure individual flag impact** on code size
2. **Identify code changes** via disassembly diff for each flag
3. **Assess safety** of each optimization for Grbl
4. **Deep dive into -ffast-math** impact on float operations
5. **Provide risk/benefit analysis** for each flag

### Critical Focus Areas for -ffast-math
- **Motion planning** (acceleration, velocity, jerk calculations)
- **Arc interpolation** (G2/G3 trigonometry: sin, cos, atan2, sqrt)
- **Bezier splines** (G5/G5.1 cubic interpolation)
- **Stepper timing** (bresenham algorithm, step rates)
- **Coordinate transformations** (work offsets, tool length)
- **Feed rate calculations** (inverse time, units per minute)

---

## 📋 Investigation Methodology

### Phase 1: Individual Flag Impact Measurement

**Build matrix:**
```
1. Baseline        : -Os only (reference)
2. +flto           : -Os -flto
3. +relax          : -Os -Wl,--relax
4. +no-inline-sf   : -Os -fno-inline-small-functions
5. +fast-math      : -Os -ffast-math ⚠️
6. +call-prologues : -Os -mcall-prologues
7. +no-split-wide  : -Os -fno-split-wide-types
8. +no-scev-cprop  : -Os -fno-tree-scev-cprop
9. All flags       : All combined
```

**For each configuration:**
```bash
# Clean build
make clean
# Modify COMPILE flags
make
# Record size
avr-size --format=berkeley build/main.elf
# Save binary
cp build/main.elf builds/main_<config>.elf
```

**Metrics to collect:**
- Flash size (text + data)
- RAM size (bss)
- Delta from baseline
- Percentage savings

---

### Phase 2: Disassembly Generation

**Generate disassembly for all configurations:**
```bash
for config in baseline flto relax no-inline-sf fast-math call-prologues no-split-wide no-scev-cprop all; do
  avr-objdump -d -S builds/main_${config}.elf > disasm/main_${config}.asm
done
```

**Generate symbol tables:**
```bash
for config in baseline flto relax no-inline-sf fast-math call-prologues no-split-wide no-scev-cprop all; do
  avr-nm -C -S --size-sort builds/main_${config}.elf > symbols/main_${config}.sym
done
```

---

### Phase 3: Diff Analysis

**Compare each optimization vs baseline:**
```bash
# Full diff
diff -u disasm/main_baseline.asm disasm/main_<flag>.asm > diffs/<flag>_vs_baseline.diff

# Function-level changes (find changed functions)
diff disasm/main_baseline.asm disasm/main_<flag>.asm | grep "^[<>].*<.*>:" | cut -d'<' -f2 | cut -d'>' -f1 | sort -u > diffs/<flag>_changed_functions.txt

# Symbol size changes
diff symbols/main_baseline.sym symbols/main_<flag>.sym > diffs/<flag>_symbol_changes.diff
```

**Key areas to analyze:**

1. **Functions that changed size significantly** (±10 bytes)
2. **New/removed function calls**
3. **Changed instruction sequences** (especially for math)
4. **Inlining decisions**
5. **Loop optimizations**
6. **Register allocation changes**

---

### Phase 4: Critical Function Analysis

**Priority 1: Motion Planning (planner.c)**
```c
// Functions to analyze in detail:
- plan_buffer_line()           // Main motion planning
- planner_recalculate()        // Velocity profile
- prep_segment_buffer()        // Step generation
```

**Look for:**
- Float operation reordering
- Precision loss in calculations
- Sqrt/division optimizations
- Acceleration/deceleration math changes

---

**Priority 2: Arc Interpolation (motion_control.c)**
```c
// Functions to analyze:
- mc_arc()                     // G2/G3 implementation
```

**Look for:**
- Trigonometry approximations (sin, cos, atan2)
- Sqrt optimizations
- Radius/center calculations
- Angular step calculations

---

**Priority 3: Bezier Splines (motion_control.c)**
```c
// Functions to analyze:
- eval_bezier()                // De Casteljau's algorithm
- mc_cubic_b_spline()          // Adaptive stepping
- interp()                     // Linear interpolation
```

**Look for:**
- Float precision in curve evaluation
- Associativity changes in polynomial evaluation
- Distance calculations (dist1, dist2)
- Adaptive step size calculations

---

**Priority 4: Stepper Algorithm (stepper.c)**
```c
// Functions to analyze:
- st_prep_buffer()             // Bresenham setup
- ISR(TIMER1_COMPA_vect)       // Step interrupt
```

**Look for:**
- Integer overflow handling
- Fixed-point arithmetic changes
- Timer calculations
- Step rate conversions

---

### Phase 5: Float Operation Deep Dive (-ffast-math)

**What -ffast-math does:**
1. **Assumes no NaN/Inf:** Removes checks for special values
2. **Allows reassociation:** `(a + b) + c` → `a + (b + c)` (can lose precision)
3. **Allows reciprocal:** `x / y` → `x * (1/y)` (faster but less precise)
4. **Unsafe math optimizations:** May violate IEEE 754
5. **No signed zero:** `-0.0 == +0.0` always
6. **No exceptions:** Removes errno handling

**Specific checks for Grbl:**

```bash
# Search for float operations in disassembly
grep -E "(fadd|fsub|fmul|fdiv|fsqrt|fcmp)" disasm/main_baseline.asm > float_ops_baseline.txt
grep -E "(fadd|fsub|fmul|fdiv|fsqrt|fcmp)" disasm/main_fast-math.asm > float_ops_fast-math.txt

# Compare
diff -u float_ops_baseline.txt float_ops_fast-math.txt > float_ops_diff.txt
```

**Manual inspection areas:**

1. **Search for "__mulsf3" → "__mulsf3x"** (reciprocal multiplication)
2. **Check sqrt calls:** `__sqrt` → optimized version
3. **Division sequences:** Look for `rcall __divsf3` changes
4. **Comparison operations:** Check `fcmp` instruction changes

**Test cases to verify:**

```c
// Create test program to verify critical calculations:

// Test 1: Arc radius calculation
float radius = sqrt(x*x + y*y);

// Test 2: Velocity calculation
float velocity = sqrt(2 * acceleration * distance);

// Test 3: Feed rate conversion
float feed_mm_min = feed_rate / 60.0;

// Test 4: Trigonometry
float cos_theta = cos(angle);
float sin_theta = sin(angle);

// Test 5: Bezier evaluation (associativity critical!)
float result = (1-t)*(1-t)*(1-t)*p0 + 3*(1-t)*(1-t)*t*p1 + 3*(1-t)*t*t*p2 + t*t*t*p3;
```

---

### Phase 6: Risk Assessment Framework

**For each flag, evaluate:**

#### Safety Score (0-10)
- **10:** Completely safe, no observable changes
- **7-9:** Minor changes, likely safe
- **4-6:** Moderate risk, needs verification
- **1-3:** High risk, careful testing required
- **0:** Dangerous, not recommended

#### Categories:
1. **Correctness risk:** Can it produce wrong results?
2. **Precision risk:** Can it lose significant precision?
3. **Performance impact:** Speed vs size tradeoff
4. **Portability:** Does it depend on specific hardware?
5. **Debuggability:** Does it make debugging harder?

---

### Phase 7: Validation Tests

**After applying flags, run:**

1. **Unit tests** (if available)
2. **Simulator tests:**
   - G0/G1 linear moves
   - G2/G3 arcs (various radii)
   - G5 cubic splines
   - Feed rate changes
   - Acceleration profiles

3. **Boundary tests:**
   - Very small moves (<0.001mm)
   - Very large moves (>1000mm)
   - Sharp corners (acceleration limits)
   - Minimum/maximum feed rates

4. **Numerical stability tests:**
   - Repetitive motions (cumulative error)
   - Floating point edge cases
   - Coordinate system switches

---

## 📊 Flag-by-Flag Analysis Template

### Flag: -ffast-math

**Description:**
Enable fast floating-point optimizations that may violate IEEE 754.

**Expected savings:** ~XXX bytes (TBD)

**What it does:**
- Enables -fno-math-errno
- Enables -funsafe-math-optimizations
- Enables -ffinite-math-only
- Enables -fno-signed-zeros
- Enables -fno-trapping-math
- Enables -fassociative-math
- Enables -freciprocal-math

**Changed functions:**
```
[To be filled after analysis]
- mc_arc: XX bytes change
- eval_bezier: XX bytes change
- plan_buffer_line: XX bytes change
...
```

**Disassembly changes:**
```
[Include snippets of critical changes]
```

**Risk assessment:**
- Correctness: X/10
- Precision: X/10
- Performance: X/10
- Overall safety: X/10

**Specific concerns:**
- [List specific risky changes found]

**Recommendation:**
- [ ] SAFE - Recommend enabling
- [ ] CONDITIONAL - Safe with testing
- [ ] RISKY - Not recommended
- [ ] DANGEROUS - Do not use

---

## 🔬 Expected Deliverables

### 1. Size Impact Report
Table showing size savings per flag:
```
| Flag                      | Flash | Savings | % Reduction |
|---------------------------|-------|---------|-------------|
| Baseline                  | 30066 |       0 |      0.00%  |
| -flto                     | XXXXX |    XXXX |      X.XX%  |
| -Wl,--relax               | XXXXX |    XXXX |      X.XX%  |
| -fno-inline-small-functions| XXXXX |    XXXX |      X.XX%  |
| -ffast-math ⚠️            | XXXXX |    XXXX |      X.XX%  |
| -mcall-prologues          | XXXXX |    XXXX |      X.XX%  |
| -fno-split-wide-types     | XXXXX |    XXXX |      X.XX%  |
| -fno-tree-scev-cprop      | XXXXX |    XXXX |      X.XX%  |
| All combined              | 28444 |    1622 |      5.40%  |
```

### 2. Changed Functions List
For each flag, list all functions with changed code and size delta.

### 3. Critical Code Analysis
Detailed analysis of -ffast-math impact on:
- Motion planning math
- Arc interpolation trigonometry
- Spline Bezier evaluation
- Stepper calculations

### 4. Disassembly Diffs
Annotated diffs highlighting risky changes.

### 5. Risk Matrix
```
| Flag            | Safety | Savings | Recommendation |
|-----------------|--------|---------|----------------|
| -flto           |   9/10 | ~XXX B  | ✅ Safe        |
| -Wl,--relax     |  10/10 | ~XXX B  | ✅ Safe        |
| -ffast-math ⚠️  |   ?/10 | ~XXX B  | ⚠️ Verify     |
...
```

### 6. Final Recommendation
Recommend safe combination of flags with maximum size savings and acceptable risk.

---

## 🛠️ Tools Required

- `avr-gcc 15.2` - Compiler
- `avr-objdump` - Disassembler
- `avr-nm` - Symbol table viewer
- `avr-size` - Size reporter
- `diff` - Comparison tool
- `grep/sed/awk` - Text processing
- Python/bash scripts for automation

---

## 📅 Timeline Estimate

1. **Setup & individual builds:** 1 hour
2. **Disassembly generation:** 30 minutes
3. **Diff analysis:** 2-3 hours
4. **Critical function analysis:** 3-4 hours
5. **Float operation deep dive:** 2-3 hours
6. **Risk assessment:** 1-2 hours
7. **Documentation:** 2 hours

**Total:** ~12-16 hours of detailed analysis

---

## ⚠️ Known Risks of -ffast-math

**Mathematical correctness issues:**
1. **Associativity changes:** `(a + b) + c ≠ a + (b + c)` for floats
   - Can accumulate errors in loops
   - Critical for Bezier polynomial evaluation

2. **Reciprocal multiplication:** `a / b → a * (1/b)`
   - Introduces additional rounding error
   - Can affect arc radius calculations

3. **NaN/Inf handling removed:**
   - Division by zero won't set errno
   - May produce undefined behavior

4. **Contraction:** `a * b + c → fma(a, b, c)`
   - Can be more OR less accurate
   - Changes numerical behavior

**Grbl-specific concerns:**
- **Motion planning:** Velocity/acceleration math must be precise
- **Position accuracy:** Cumulative errors in coordinates
- **Arc quality:** Trigonometry approximations affect smoothness
- **Spline accuracy:** Bezier evaluation very sensitive to associativity

---

## 📝 Investigation Log Template

```markdown
### Flag: -ffast-math
**Date:** YYYY-MM-DD
**Investigator:** [Name]

#### Size Impact
- Baseline: 30066 bytes
- With flag: XXXXX bytes
- Savings: XXX bytes (X.X%)

#### Changed Functions Count
- Total functions changed: XX
- Functions with >10 byte change: XX
- New functions introduced: XX
- Functions removed: XX

#### Top 10 Changed Functions
1. function_name: +XX bytes
2. function_name: -XX bytes
...

#### Critical Findings
1. [Finding 1]: Description + risk level
2. [Finding 2]: Description + risk level
...

#### Test Results
- [ ] Simulator tests passed
- [ ] Numerical accuracy verified
- [ ] Edge cases handled correctly

#### Decision
- [X] APPROVED / [ ] REJECTED / [ ] NEEDS MORE TESTING
**Rationale:** [Explanation]
```

---

## 🎯 Success Criteria

Investigation is complete when:
- [ ] All 8 flags analyzed individually
- [ ] Size impact measured for each
- [ ] Disassembly diffs generated and reviewed
- [ ] Critical functions analyzed in detail
- [ ] Float operations impact assessed
- [ ] Risk matrix completed
- [ ] Validation tests passed
- [ ] Final recommendation provided with justification

---

**Next Steps:**
1. Run Phase 1: Build matrix with individual flags
2. Collect size metrics
3. Generate disassemblies
4. Begin diff analysis starting with -ffast-math

---

**END OF INVESTIGATION PLAN**
