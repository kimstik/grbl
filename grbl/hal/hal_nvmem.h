/*
  hal_nvmem.h - Non-Volatile Memory HAL (EEPROM/Flash)
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

#ifndef HAL_NVMEM_H
#define HAL_NVMEM_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// NVMEM SIZE CONFIGURATION
// ============================================================================

// Total NVMEM size available for GRBL settings
// AVR: 1KB hardware EEPROM
// STM32: Flash emulation (typically 2KB)
// SAMD21: Flash emulation or external EEPROM
// CH32V006: Flash emulation (1-2KB)

#ifndef HAL_NVMEM_SIZE
  #ifdef PLATFORM_AVR_ATMEGA328P
    #define HAL_NVMEM_SIZE  1024  // 1KB hardware EEPROM
  #else
    #define HAL_NVMEM_SIZE  1024  // Default for other platforms
  #endif
#endif

// ============================================================================
// PLATFORM-SPECIFIC IMPLEMENTATIONS
// ============================================================================

#ifdef PLATFORM_AVR_ATMEGA328P
  // ============================================================================
  // AVR IMPLEMENTATION - ZERO OVERHEAD, Direct EEPROM access
  // ============================================================================

  #include <avr/io.h>
  #include <avr/interrupt.h>

  // EEPROM bit compatibility
  #ifndef EEPE
    #define EEPE  EEWE
    #define EEMPE EEMWE
  #endif

  #ifndef EEPM1
    #define EEPM1 5
    #define EEPM0 4
  #endif

  // --------------------------------------------------------------------------
  // READ/WRITE BYTES - Function declarations (implemented in nvmem.c)
  // --------------------------------------------------------------------------

  // Original GRBL eeprom functions - declared here, defined in nvmem.c
  unsigned char eeprom_get_char(unsigned int addr);
  void eeprom_put_char(unsigned int addr, unsigned char new_value);

  // HAL macros map to these functions
  #define HAL_NVMEM_READ_BYTE(addr)        eeprom_get_char(addr)
  #define HAL_NVMEM_WRITE_BYTE(addr, val)  eeprom_put_char(addr, val)

  // --------------------------------------------------------------------------
  // BUFFER OPERATIONS
  // --------------------------------------------------------------------------

  // Read buffer from EEPROM
  static inline void hal_nvmem_read_buffer(uint32_t addr, uint8_t* buffer, uint32_t size) {
    for (uint32_t i = 0; i < size; i++) {
      buffer[i] = HAL_NVMEM_READ_BYTE(addr + i);
    }
  }

  // Write buffer to EEPROM
  static inline void hal_nvmem_write_buffer(uint32_t addr, const uint8_t* buffer, uint32_t size) {
    for (uint32_t i = 0; i < size; i++) {
      HAL_NVMEM_WRITE_BYTE(addr + i, buffer[i]);
    }
  }

  // --------------------------------------------------------------------------
  // UTILITY FUNCTIONS
  // --------------------------------------------------------------------------

  // Initialize NVMEM (no-op for AVR, EEPROM is always ready)
  #define HAL_NVMEM_INIT()  do { } while(0)

  // Commit writes (no-op for AVR, writes are immediate)
  #define HAL_NVMEM_COMMIT()  do { } while(0)

  // Get NVMEM size
  #define HAL_NVMEM_GET_SIZE()  HAL_NVMEM_SIZE

#else
  // ============================================================================
  // OTHER PLATFORMS - Function-based implementations
  // ============================================================================

  /*
    For platforms without hardware EEPROM:
    - STM32: Flash emulation using last pages of flash
    - SAMD21: Flash emulation or external I2C EEPROM
    - CH32V006: Flash emulation

    Implementation in platform-specific hal_impl.c
  */

  // --------------------------------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------------------------------

  void hal_nvmem_init(void);
  #define HAL_NVMEM_INIT()  hal_nvmem_init()

  // --------------------------------------------------------------------------
  // READ/WRITE OPERATIONS
  // --------------------------------------------------------------------------

  uint8_t hal_nvmem_read_byte(uint32_t address);
  void hal_nvmem_write_byte(uint32_t address, uint8_t value);

  #define HAL_NVMEM_READ_BYTE(addr)        hal_nvmem_read_byte(addr)
  #define HAL_NVMEM_WRITE_BYTE(addr, val)  hal_nvmem_write_byte(addr, val)

  // --------------------------------------------------------------------------
  // BUFFER OPERATIONS
  // --------------------------------------------------------------------------

  void hal_nvmem_read_buffer(uint32_t address, uint8_t* buffer, uint32_t size);
  void hal_nvmem_write_buffer(uint32_t address, const uint8_t* buffer, uint32_t size);

  // --------------------------------------------------------------------------
  // UTILITY FUNCTIONS
  // --------------------------------------------------------------------------

  // Commit buffered writes to flash (required for flash-based emulation)
  void hal_nvmem_commit(void);
  #define HAL_NVMEM_COMMIT()  hal_nvmem_commit()

  // Get NVMEM size
  uint32_t hal_nvmem_get_size(void);
  #define HAL_NVMEM_GET_SIZE()  hal_nvmem_get_size()

  // --------------------------------------------------------------------------
  // FLASH EMULATION FUNCTIONS (optional, for platforms using flash)
  // --------------------------------------------------------------------------

  #ifdef HAL_NVMEM_FLASH_EMULATION
    // Erase flash page (required before writing)
    void hal_nvmem_erase_page(uint32_t page_address);

    // Get page size
    uint32_t hal_nvmem_get_page_size(void);

    // Get page address for given NVMEM address
    uint32_t hal_nvmem_get_page_address(uint32_t address);
  #endif

#endif

// ============================================================================
// COMMON NVMEM FUNCTIONS (all platforms)
// ============================================================================

#ifdef PLATFORM_AVR_ATMEGA328P
  // For AVR: eeprom_get_char/eeprom_put_char are macros, function declarations in nvmem.h
  #define eeprom_get_char(addr)         HAL_NVMEM_READ_BYTE(addr)
  #define eeprom_put_char(addr, val)    HAL_NVMEM_WRITE_BYTE(addr, val)
#else
  // For other platforms: declare functions
  void memcpy_from_nvmem_with_checksum(uint8_t *dest, uint32_t source, uint32_t size);
  bool nvmem_write_check(uint32_t destination, uint8_t *source, uint32_t size);

  // Legacy function names (for compatibility)
  #define eeprom_get_char(addr)         HAL_NVMEM_READ_BYTE(addr)
  #define eeprom_put_char(addr, val)    HAL_NVMEM_WRITE_BYTE(addr, val)
#endif

// ============================================================================
// NVMEM MEMORY MAP (GRBL settings storage layout)
// ============================================================================

/*
  GRBL uses NVMEM for:
  - Global settings (steps/mm, max rates, etc.)
  - Coordinate system offsets (G54-G59)
  - Build info string
  - Startup blocks

  Memory layout (from original GRBL):
  Addr  Size  Content
  ----  ----  -------
  0x00  1     GRBL settings version
  0x01  ~110  Global settings structure
  0x70  ~280  Coordinate system data (6 systems × 6 axes × 4 bytes)
  0x188 80    Build info string
  0x1D8 80    Startup block 0
  0x228 80    Startup block 1
*/

#endif // HAL_NVMEM_H
