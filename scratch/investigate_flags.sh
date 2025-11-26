#!/bin/bash
#
# Automated investigation of AVR-GCC optimization flags
# Measures individual and combined impact on code size
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILDS_DIR="builds"
DISASM_DIR="disasm"
SYMBOLS_DIR="symbols"
DIFFS_DIR="diffs"
RESULTS_FILE="optimization_results.txt"

# Create directories
mkdir -p ${BUILDS_DIR} ${DISASM_DIR} ${SYMBOLS_DIR} ${DIFFS_DIR}

echo -e "${BLUE}=== AVR-GCC Optimization Flags Investigation ===${NC}"
echo ""

# Flag configurations
# Format: "config_name:flags"
CONFIGS=(
    "baseline:-Os"
    "lto:-Os -flto"
    "relax:-Os -Wl,--relax"
    "no-inline-sf:-Os -fno-inline-small-functions"
    "fast-math:-Os -ffast-math"
    "call-prologues:-Os -mcall-prologues"
    "no-split-wide:-Os -fno-split-wide-types"
    "no-scev-cprop:-Os -fno-tree-scev-cprop"
    "all:-Os -flto -fno-inline-small-functions -Wl,--relax -ffast-math -mcall-prologues -fno-split-wide-types -fno-tree-scev-cprop"
)

# Function to build with specific flags
build_config() {
    local config_name=$1
    local flags=$2

    echo -e "${YELLOW}Building: ${config_name}${NC}"
    echo "  Flags: ${flags}"

    # Clean
    make clean > /dev/null 2>&1 || true

    # Build with flags
    # Note: You need to modify Makefile to use $EXTRA_CFLAGS
    # Or temporarily patch COMPILE variable
    EXTRA_CFLAGS="${flags}" make 2>&1 | grep -E "(error|warning)" || true

    if [ ! -f build/main.elf ]; then
        echo -e "${RED}  Build FAILED${NC}"
        return 1
    fi

    # Save binary
    cp build/main.elf ${BUILDS_DIR}/main_${config_name}.elf

    # Get size
    local size_output=$(avr-size --format=berkeley ${BUILDS_DIR}/main_${config_name}.elf | tail -1)
    local text=$(echo ${size_output} | awk '{print $1}')
    local data=$(echo ${size_output} | awk '{print $2}')
    local bss=$(echo ${size_output} | awk '{print $3}')
    local flash=$((text + data))

    echo -e "${GREEN}  Flash: ${flash} bytes (text: ${text}, data: ${data})${NC}"
    echo -e "${GREEN}  RAM:   ${bss} bytes${NC}"

    # Save to results
    echo "${config_name}:${flash}:${bss}:${flags}" >> ${RESULTS_FILE}

    return 0
}

# Function to generate disassembly
generate_disasm() {
    local config_name=$1

    echo -e "${YELLOW}Generating disassembly: ${config_name}${NC}"

    if [ ! -f ${BUILDS_DIR}/main_${config_name}.elf ]; then
        echo -e "${RED}  ELF file not found${NC}"
        return 1
    fi

    # Disassembly
    avr-objdump -d -S ${BUILDS_DIR}/main_${config_name}.elf > ${DISASM_DIR}/main_${config_name}.asm

    # Symbol table
    avr-nm -C -S --size-sort ${BUILDS_DIR}/main_${config_name}.elf > ${SYMBOLS_DIR}/main_${config_name}.sym

    echo -e "${GREEN}  Disassembly saved${NC}"

    return 0
}

# Function to analyze diff against baseline
analyze_diff() {
    local config_name=$1

    if [ "${config_name}" = "baseline" ]; then
        return 0
    fi

    echo -e "${YELLOW}Analyzing diff: ${config_name} vs baseline${NC}"

    # Full diff
    diff -u ${DISASM_DIR}/main_baseline.asm ${DISASM_DIR}/main_${config_name}.asm > ${DIFFS_DIR}/${config_name}_vs_baseline.diff || true

    # Extract changed functions
    diff ${DISASM_DIR}/main_baseline.asm ${DISASM_DIR}/main_${config_name}.asm | \
        grep "^[<>].*<.*>:" | \
        cut -d'<' -f2 | \
        cut -d'>' -f1 | \
        sort -u > ${DIFFS_DIR}/${config_name}_changed_functions.txt || true

    local changed_count=$(wc -l < ${DIFFS_DIR}/${config_name}_changed_functions.txt)
    echo -e "${GREEN}  Changed functions: ${changed_count}${NC}"

    # Symbol size diff
    diff ${SYMBOLS_DIR}/main_baseline.sym ${SYMBOLS_DIR}/main_${config_name}.sym > ${DIFFS_DIR}/${config_name}_symbol_changes.diff || true

    return 0
}

# Function to extract float operations
extract_float_ops() {
    local config_name=$1

    echo -e "${YELLOW}Extracting float operations: ${config_name}${NC}"

    grep -E "(mul|div|add|sub|cmp)sf3" ${DISASM_DIR}/main_${config_name}.asm > ${DIFFS_DIR}/${config_name}_float_ops.txt || true

    local float_count=$(wc -l < ${DIFFS_DIR}/${config_name}_float_ops.txt)
    echo -e "${GREEN}  Float operations: ${float_count}${NC}"

    return 0
}

# Main execution
echo -e "${BLUE}Phase 1: Building all configurations${NC}"
echo ""

# Clear results file
> ${RESULTS_FILE}

for config in "${CONFIGS[@]}"; do
    IFS=':' read -r name flags <<< "$config"
    build_config "${name}" "${flags}"
    echo ""
done

echo ""
echo -e "${BLUE}Phase 2: Generating disassemblies${NC}"
echo ""

for config in "${CONFIGS[@]}"; do
    IFS=':' read -r name flags <<< "$config"
    generate_disasm "${name}"
done

echo ""
echo -e "${BLUE}Phase 3: Analyzing diffs${NC}"
echo ""

for config in "${CONFIGS[@]}"; do
    IFS=':' read -r name flags <<< "$config"
    analyze_diff "${name}"
done

echo ""
echo -e "${BLUE}Phase 4: Extracting float operations${NC}"
echo ""

extract_float_ops "baseline"
extract_float_ops "fast-math"

# Compare float operations
echo ""
echo -e "${YELLOW}Comparing float operations: baseline vs fast-math${NC}"
diff -u ${DIFFS_DIR}/baseline_float_ops.txt ${DIFFS_DIR}/fast-math_float_ops.txt > ${DIFFS_DIR}/fast-math_float_changes.diff || true
echo -e "${GREEN}  Diff saved to: ${DIFFS_DIR}/fast-math_float_changes.diff${NC}"

echo ""
echo -e "${BLUE}=== Results Summary ===${NC}"
echo ""

# Read baseline for comparison
baseline_flash=$(grep "^baseline:" ${RESULTS_FILE} | cut -d':' -f2)
echo "Baseline flash: ${baseline_flash} bytes"
echo ""

printf "%-20s %10s %10s %10s\n" "Configuration" "Flash (B)" "Savings" "% Saved"
printf "%-20s %10s %10s %10s\n" "--------------------" "----------" "----------" "----------"

while IFS=':' read -r name flash ram flags; do
    savings=$((baseline_flash - flash))
    if [ ${baseline_flash} -ne 0 ]; then
        percent=$(awk "BEGIN {printf \"%.2f\", ($savings * 100.0 / $baseline_flash)}")
    else
        percent="0.00"
    fi

    printf "%-20s %10d %10d %9s%%\n" "${name}" "${flash}" "${savings}" "${percent}"
done < ${RESULTS_FILE}

echo ""
echo -e "${GREEN}Investigation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review disassembly diffs in ${DIFFS_DIR}/"
echo "2. Analyze changed functions for each flag"
echo "3. Focus on ${DIFFS_DIR}/fast-math_* files for safety analysis"
echo "4. Check ${DIFFS_DIR}/*_changed_functions.txt for impacted functions"
echo ""
echo "Critical files to review:"
echo "  - ${DIFFS_DIR}/fast-math_vs_baseline.diff (full changes)"
echo "  - ${DIFFS_DIR}/fast-math_changed_functions.txt (affected functions)"
echo "  - ${DIFFS_DIR}/fast-math_float_changes.diff (float operation changes)"
