/* cpu_map.h - hosted oracle. Shadows grbl/cpu_map.h (the AVR Uno pin map) the
   same way every non-AVR port does, by sitting earlier on the include path.
   The oracle's own logical pin map lives in prelude.h; everything else falls
   back to the shared non-AVR stub. Part of Grbl / Intelligence assisted / MIT. */

#ifndef GRBL_HOSTED_CPU_MAP_H
#define GRBL_HOSTED_CPU_MAP_H
#include "../../grbl/platform/common/dummy/cpu_map.h"
#endif
