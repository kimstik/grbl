#!/bin/bash
#
# AVR ATmega328p HAL Binary Verification Script
# ============================================
#
# This script verifies that the GRBL HAL implementation produces
# a 100% binary-identical build to the original GRBL for AVR ATmega328p.
#
# REQUIREMENTS:
# - avr-gcc (GCC) 9.x (tested with 9.2.0, 9.3.0, 9.4.0)
# - GNU Make
# - md5sum or md5 utility
#
# EXPECTED RESULTS:
# - Binary size: 30,640 bytes
# - grbl.hex MD5: 79af184e67b27defd27a39309ac53563
# - .text section MD5: 6134ac924a80e22a31ffb83643b5add1
#
# If verification fails, the HAL macros may have been modified incorrectly.

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "GRBL HAL AVR ATmega328p Binary Verification"
echo "================================================"
echo ""

# Check for required tools
if ! command -v avr-gcc &> /dev/null; then
    echo -e "${RED}ERROR: avr-gcc not found${NC}"
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo -e "${RED}ERROR: make not found${NC}"
    exit 1
fi

# Detect md5 command
if command -v md5sum &> /dev/null; then
    MD5_CMD="md5sum"
elif command -v md5 &> /dev/null; then
    MD5_CMD="md5 -r"
else
    echo -e "${RED}ERROR: Neither md5sum nor md5 command found${NC}"
    exit 1
fi

# Check compiler version
echo -n "Checking compiler version... "
GCC_VERSION=$(avr-gcc --version | head -n1)
echo "$GCC_VERSION"

if [[ ! "$GCC_VERSION" =~ 9\. ]]; then
    echo -e "${YELLOW}WARNING: Expected avr-gcc 9.x, found different version${NC}"
    echo -e "${YELLOW}Binary match may fail with different compiler versions${NC}"
    echo ""
fi

# Clean and build
echo "Building GRBL..."
make clean > /dev/null 2>&1
make -j$(nproc) 2>&1 | grep -E "(text|data|bss|dec)" || true
echo ""

# Check if build succeeded
if [ ! -f grbl.hex ]; then
    echo -e "${RED}ERROR: Build failed - grbl.hex not found${NC}"
    exit 1
fi

if [ ! -f build/main.elf ]; then
    echo -e "${RED}ERROR: Build failed - build/main.elf not found${NC}"
    exit 1
fi

# Verify binary size
echo "Verifying binary size..."
ACTUAL_SIZE=$(avr-size --format=berkeley build/main.elf | tail -n1 | awk '{print $1+$2}')
EXPECTED_SIZE=30640

if [ "$ACTUAL_SIZE" -eq "$EXPECTED_SIZE" ]; then
    echo -e "${GREEN}✓ Binary size: $ACTUAL_SIZE bytes (MATCH)${NC}"
else
    echo -e "${RED}✗ Binary size: $ACTUAL_SIZE bytes (expected $EXPECTED_SIZE)${NC}"
    echo -e "${RED}VERIFICATION FAILED${NC}"
    exit 1
fi

# Verify grbl.hex MD5
echo "Verifying grbl.hex MD5..."
ACTUAL_HEX_MD5=$($MD5_CMD grbl.hex | awk '{print $1}')
EXPECTED_HEX_MD5="79af184e67b27defd27a39309ac53563"

if [ "$ACTUAL_HEX_MD5" = "$EXPECTED_HEX_MD5" ]; then
    echo -e "${GREEN}✓ grbl.hex MD5: $ACTUAL_HEX_MD5 (MATCH)${NC}"
else
    echo -e "${RED}✗ grbl.hex MD5: $ACTUAL_HEX_MD5${NC}"
    echo -e "${RED}  Expected:     $EXPECTED_HEX_MD5${NC}"
    echo -e "${RED}VERIFICATION FAILED${NC}"
    exit 1
fi

# Verify .text section MD5
echo "Verifying .text section MD5..."
avr-objcopy -O binary -j .text build/main.elf /tmp/grbl_text.bin
ACTUAL_TEXT_MD5=$($MD5_CMD /tmp/grbl_text.bin | awk '{print $1}')
EXPECTED_TEXT_MD5="6134ac924a80e22a31ffb83643b5add1"
rm -f /tmp/grbl_text.bin

if [ "$ACTUAL_TEXT_MD5" = "$EXPECTED_TEXT_MD5" ]; then
    echo -e "${GREEN}✓ .text section MD5: $ACTUAL_TEXT_MD5 (MATCH)${NC}"
else
    echo -e "${RED}✗ .text section MD5: $ACTUAL_TEXT_MD5${NC}"
    echo -e "${RED}  Expected:          $EXPECTED_TEXT_MD5${NC}"
    echo -e "${RED}VERIFICATION FAILED${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}ALL CHECKS PASSED - 100% BINARY MATCH!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "The HAL implementation produces byte-for-byte identical"
echo "binary to the original GRBL. Zero-overhead abstraction confirmed."
