/*
  cpu_map.h - SG2002 CPU/pin mapping stub
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Stub file for compatibility with GRBL's cpu_map.h include
  All pin definitions are in platform.h
*/

#ifndef SG2002_CPU_MAP_H
#define SG2002_CPU_MAP_H

// This file intentionally left minimal
// Pin mappings are defined in platform.h

// Stepper port aliases (for compatibility)
#define STEP_PORT     X_STEP_PORT
#define DIRECTION_PORT X_DIR_PORT

// Limit port alias
#define LIMIT_PIN     X_LIMIT_PORT

// Control port alias
#define CONTROL_PIN   CONTROL_RESET_PORT

#endif // SG2002_CPU_MAP_H
