#!/bin/bash
# Test individual optimization flags for AVR-GCC
# Measures flash size impact of each flag individually

export PATH="$HOME/avr-toolchain/avr/bin:$PATH"

MAKEFILE="Makefile"
BASELINE_FLAGS="-Os -flto -ffast-math"

# Array of flags to test
FLAGS=(
    "-fno-inline-small-functions"
    "-Wl,--relax"
    "-mcall-prologues"
    "-fno-split-wide-types"
    "-fno-tree-scev-cprop"
)

DESCRIPTIONS=(
    "Prevent small function inlining"
    "Linker relaxation (AVR-specific)"
    "Share function prologues"
    "Keep 32/64-bit types together"
    "Disable SCEV constant propagation"
)

echo "========================================="
echo "AVR-GCC Optimization Flag Testing"
echo "========================================="
echo ""
echo "Baseline flags: $BASELINE_FLAGS"
echo ""

# Build baseline
echo "Building baseline..."
/usr/bin/make clean > /dev/null 2>&1
/usr/bin/make > /dev/null 2>&1

if [ ! -f "build/main.elf" ]; then
    echo "ERROR: Baseline build failed"
    exit 1
fi

BASELINE_SIZE=$(avr-size --format=berkeley build/main.elf | grep main.elf | awk '{print $1}')
echo "Baseline size: $BASELINE_SIZE bytes"
echo ""

# Create results file
RESULTS_FILE="scratch/audit/flag_test_results.txt"
mkdir -p scratch/audit
echo "Flag Testing Results" > $RESULTS_FILE
echo "===================" >> $RESULTS_FILE
echo "Date: $(date)" >> $RESULTS_FILE
echo "GCC Version: $(avr-gcc --version | head -1)" >> $RESULTS_FILE
echo "Baseline flags: $BASELINE_FLAGS" >> $RESULTS_FILE
echo "Baseline size: $BASELINE_SIZE bytes" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Test each flag individually
for i in "${!FLAGS[@]}"; do
    FLAG="${FLAGS[$i]}"
    DESC="${DESCRIPTIONS[$i]}"

    echo "----------------------------------------"
    echo "Testing: $FLAG"
    echo "Description: $DESC"

    # Backup Makefile
    cp $MAKEFILE ${MAKEFILE}.bak

    # Add flag to Makefile
    sed -i "s|-flto -ffast-math|-flto -ffast-math $FLAG|" $MAKEFILE

    # Build
    /usr/bin/make clean > /dev/null 2>&1
    BUILD_OUTPUT=$(/usr/bin/make 2>&1)
    BUILD_STATUS=$?

    if [ $BUILD_STATUS -ne 0 ]; then
        echo "  Status: FAILED TO BUILD"
        echo "  Error:"
        echo "$BUILD_OUTPUT" | grep -i error

        echo "" >> $RESULTS_FILE
        echo "Flag: $FLAG" >> $RESULTS_FILE
        echo "Description: $DESC" >> $RESULTS_FILE
        echo "Status: BUILD FAILED" >> $RESULTS_FILE

        # Restore Makefile
        mv ${MAKEFILE}.bak $MAKEFILE
        continue
    fi

    # Get size
    NEW_SIZE=$(avr-size --format=berkeley build/main.elf | grep main.elf | awk '{print $1}')
    DIFF=$((BASELINE_SIZE - NEW_SIZE))
    PERCENT=$(awk "BEGIN {printf \"%.2f\", ($DIFF / $BASELINE_SIZE) * 100}")

    echo "  New size: $NEW_SIZE bytes"
    if [ $DIFF -gt 0 ]; then
        echo "  Savings: $DIFF bytes ($PERCENT%)"
    elif [ $DIFF -lt 0 ]; then
        ABS_DIFF=$((NEW_SIZE - BASELINE_SIZE))
        echo "  INCREASE: +$ABS_DIFF bytes"
    else
        echo "  Change: 0 bytes (no effect)"
    fi

    # Log to results file
    echo "" >> $RESULTS_FILE
    echo "Flag: $FLAG" >> $RESULTS_FILE
    echo "Description: $DESC" >> $RESULTS_FILE
    echo "Size: $NEW_SIZE bytes" >> $RESULTS_FILE
    if [ $DIFF -gt 0 ]; then
        echo "Savings: $DIFF bytes ($PERCENT%)" >> $RESULTS_FILE
    elif [ $DIFF -lt 0 ]; then
        ABS_DIFF=$((NEW_SIZE - BASELINE_SIZE))
        echo "INCREASE: +$ABS_DIFF bytes" >> $RESULTS_FILE
    else
        echo "Change: 0 bytes (no effect)" >> $RESULTS_FILE
    fi

    # Restore Makefile
    mv ${MAKEFILE}.bak $MAKEFILE
done

echo ""
echo "========================================="
echo "Testing Complete"
echo "Results saved to: $RESULTS_FILE"
echo "========================================="
echo ""
echo "Summary:"
cat $RESULTS_FILE
