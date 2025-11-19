/*
  cpu_map.h - Dummy stub for non-AVR platforms
  Part of Grbl

  This is a compatibility stub for platforms that don't use AVR-style
  pin mappings. Each platform defines its pins in platform.h instead.

  This file is only used when a platform doesn't provide its own cpu_map.h.
  AVR platform has its own full cpu_map.h with real pin definitions.
*/

#ifndef cpu_map_h
#define cpu_map_h

// Minimal stubs for AVR-specific macros used in core GRBL code
// Platforms can override these in platform.h before this file is included

#ifndef LIMIT_DDR
  #define LIMIT_DDR     0
#endif

#ifndef LIMIT_PORT
  #define LIMIT_PORT    0
#endif

#ifndef LIMIT_PIN
  #define LIMIT_PIN     0
#endif

#ifndef LIMIT_MASK
  #define LIMIT_MASK    0
#endif

#ifndef LIMIT_PCMSK
  #define LIMIT_PCMSK   0
#endif

#ifndef LIMIT_INT
  #define LIMIT_INT     0
#endif

#ifndef CONTROL_DDR
  #define CONTROL_DDR   0
#endif

#ifndef CONTROL_PORT
  #define CONTROL_PORT  0
#endif

#ifndef CONTROL_PIN
  #define CONTROL_PIN   0
#endif

#ifndef CONTROL_MASK
  #define CONTROL_MASK  0
#endif

#ifndef CONTROL_PCMSK
  #define CONTROL_PCMSK 0
#endif

#ifndef CONTROL_INT
  #define CONTROL_INT   0
#endif

#ifndef PROBE_DDR
  #define PROBE_DDR     0
#endif

#ifndef PROBE_PORT
  #define PROBE_PORT    0
#endif

#ifndef PROBE_PIN
  #define PROBE_PIN     0
#endif

#ifndef PROBE_MASK
  #define PROBE_MASK    0
#endif

// Spindle control (used by spindle_control.c)
#ifndef SPINDLE_ENABLE_DDR
  #define SPINDLE_ENABLE_DDR    0
#endif

#ifndef SPINDLE_ENABLE_PORT
  #define SPINDLE_ENABLE_PORT   0
#endif

#ifndef SPINDLE_ENABLE_BIT
  #define SPINDLE_ENABLE_BIT    0
#endif

#ifndef SPINDLE_DIRECTION_DDR
  #define SPINDLE_DIRECTION_DDR   0
#endif

#ifndef SPINDLE_DIRECTION_PORT
  #define SPINDLE_DIRECTION_PORT  0
#endif

#ifndef SPINDLE_DIRECTION_BIT
  #define SPINDLE_DIRECTION_BIT   0
#endif

#ifndef SPINDLE_PWM_DDR
  #define SPINDLE_PWM_DDR   0
#endif

#ifndef SPINDLE_PWM_PORT
  #define SPINDLE_PWM_PORT  0
#endif

#ifndef SPINDLE_PWM_BIT
  #define SPINDLE_PWM_BIT   0
#endif

// Coolant control (used by coolant_control.c)
#ifndef COOLANT_FLOOD_DDR
  #define COOLANT_FLOOD_DDR   0
#endif

#ifndef COOLANT_FLOOD_PORT
  #define COOLANT_FLOOD_PORT  0
#endif

#ifndef COOLANT_FLOOD_BIT
  #define COOLANT_FLOOD_BIT   0
#endif

#ifndef COOLANT_MIST_DDR
  #define COOLANT_MIST_DDR    0
#endif

#ifndef COOLANT_MIST_PORT
  #define COOLANT_MIST_PORT   0
#endif

#ifndef COOLANT_MIST_BIT
  #define COOLANT_MIST_BIT    0
#endif

#endif // cpu_map_h
