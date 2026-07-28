/*
  segwire.h - SEGX/1 Profile F link framing (the bytes that cross a real wire).

  Part of Grbl / Intelligence assisted / License: MIT

  segframe.h defines WHAT is carried (the canonical little-endian frame bodies,
  SEGMENT-RUNTIME-PLAN.md §3.2). This header defines HOW it is delimited on an
  ordered, reliable, CRC-protected byte link (§3.1 Profile F): the frame
  boundary IS the validity strobe, which is what dissolves the missing-barrier
  landmine at stepper.c's publish store into framing.

    SOF  TAG  LEN  PAYLOAD[LEN]  CRC8
         \___________________/
              CRC covers TAG, LEN and PAYLOAD (not SOF)

  CRC-8, polynomial 0x07, init 0x00, no reflection, no final XOR. Chosen over a
  CRC-16 because every frame here is <= 21 bytes: at that length CRC-8/ATM has
  Hamming distance 4, i.e. it detects every 1-, 2- and 3-bit error and every
  burst up to 8 bits, and it costs one LUT-level XOR tree in fabric.

  SOF is 0xa5 and is NOT byte-stuffed. Resynchronisation after a link glitch is
  by CRC rejection plus the sequence check, not by escaping - a deliberate
  choice, because stuffing makes the frame length data-dependent and a
  fixed-length frame is what lets an executor's receive path be a counter and a
  shift register instead of a state machine with a payload buffer.

  This header is shared verbatim by the host shipper, the Verilated executor
  testbench and any future transport, so the wire cannot drift from the spec by
  one side being edited alone. The RTL (tools/hosted/subjects/rtl/segx_rx.v)
  mirrors the constants as localparams and exports them on o_params, which the
  testbench compares against the values below - a real cross-check, not a
  comment.
*/

#ifndef GRBL_SEGWIRE_H
#define GRBL_SEGWIRE_H

#include <stdint.h>
#include "segframe.h"

#define SEGX_SOF        0xa5u

#define SEGX_TAG_SEG    0x01u   /* payload: SEGX_SEG_WIRE_LEN  (8)  */
#define SEGX_TAG_BLK    0x02u   /* payload: SEGX_BLK_WIRE_LEN  (19) */
#define SEGX_TAG_CFG    0x03u   /* payload: SEGX_CFG_WIRE_LEN  (19) */
#define SEGX_TAG_WAKE   0x04u   /* payload: 1 byte, epoch           */

#define SEGX_CFG_WIRE_LEN 19
#define SEGX_MAX_PAYLOAD  19
#define SEGX_MAX_FRAME    (3 + SEGX_MAX_PAYLOAD + 1)

/* CFG payload (§3.1 CONFIG, the subset an executor needs to step correctly;
   the config-tuple hash and F_TICK are session-level and checked before WAKE). */
#define SEGX_CFG_FLAG_HOMING     0x01u
#define SEGX_CFG_FLAG_PROBE_ARM  0x02u

typedef struct {
  uint8_t  step_invert;      /* $2, pin positions */
  uint8_t  dir_invert;       /* $3, pin positions */
  uint16_t pulse_ticks;      /* $0 in F_TICK clocks */
  uint8_t  flags;            /* SEGX_CFG_FLAG_* */
  uint8_t  homing_lock;      /* pulse mask while homing */
  uint8_t  probe_invert;     /* $6 */
  int32_t  pos[3];           /* POS_SET; legal only HALTED/IDLE (§3.2 CMD) */
} grbl_cfg_frame_t;

static inline void segx_cfg_encode(const grbl_cfg_frame_t *c, uint8_t *w)
{
  w[0] = c->step_invert;
  w[1] = c->dir_invert;
  segx_put16(w + 2, c->pulse_ticks);
  w[4] = c->flags;
  w[5] = c->homing_lock;
  w[6] = c->probe_invert;
  segx_put32(w + 7,  (uint32_t)c->pos[0]);
  segx_put32(w + 11, (uint32_t)c->pos[1]);
  segx_put32(w + 15, (uint32_t)c->pos[2]);
}

static inline void segx_cfg_decode(const uint8_t *w, grbl_cfg_frame_t *c)
{
  c->step_invert = w[0];
  c->dir_invert = w[1];
  c->pulse_ticks = segx_get16(w + 2);
  c->flags = w[4];
  c->homing_lock = w[5];
  c->probe_invert = w[6];
  c->pos[0] = (int32_t)segx_get32(w + 7);
  c->pos[1] = (int32_t)segx_get32(w + 11);
  c->pos[2] = (int32_t)segx_get32(w + 15);
}

/* CRC-8/ATM, bitwise. No table: on the host side this runs 21 times per
   DT_SEGMENT (100/s) and a 256-byte table is a quarter of a percent of the
   ch32v006's flash for nothing. */
static inline uint8_t segx_crc8_byte(uint8_t crc, uint8_t d)
{
  uint8_t i;
  crc ^= d;
  for (i = 0; i < 8; i++) {
    crc = (uint8_t)((crc & 0x80u) ? (((unsigned)crc << 1) ^ 0x07u)
                                  : ((unsigned)crc << 1));
  }
  return crc;
}

static inline uint8_t segx_crc8(const uint8_t *p, uint16_t n)
{
  uint8_t crc = 0;
  while (n--) { crc = segx_crc8_byte(crc, *p++); }
  return crc;
}

/* Serialize one frame into dst (>= SEGX_MAX_FRAME). Returns byte count. */
static inline uint16_t segx_frame_build(uint8_t *dst, uint8_t tag,
                                        const uint8_t *payload, uint8_t len)
{
  uint8_t crc = 0, i;
  dst[0] = (uint8_t)SEGX_SOF;
  dst[1] = tag;
  dst[2] = len;
  crc = segx_crc8_byte(crc, tag);
  crc = segx_crc8_byte(crc, len);
  for (i = 0; i < len; i++) {
    dst[3 + i] = payload[i];
    crc = segx_crc8_byte(crc, payload[i]);
  }
  dst[3 + len] = crc;
  return (uint16_t)(4 + len);
}

/* Executor fault codes (§3.5 R3 FAULT). Reported on the reverse channel and,
   in the Verilated executor, on its fault_o port. First fault wins; the
   executor stops between ticks and never resumes without a WAKE. */
#define SEGX_FAULT_NONE      0
#define SEGX_FAULT_NSTEP0    1   /* §3.6.1 declared divergence from stock     */
#define SEGX_FAULT_CRC       2
#define SEGX_FAULT_SEQ_GAP   3
#define SEGX_FAULT_UNKNOWN_BLK 4 /* SEG referenced a blk_gen never delivered  */
#define SEGX_FAULT_OVERFLOW  5   /* host exceeded the credit window W         */
#define SEGX_FAULT_AMASS     6   /* amass_level > MAX_AMASS_LEVEL             */
#define SEGX_FAULT_BAD_TAG   7
#define SEGX_FAULT_TOO_FAST  8   /* cycles_per_tick below the executor's
                                    pipeline depth; see segx_exec.v's header */
#define SEGX_FAULT_GEN_GAP   9   /* blk_gen did not advance by exactly one:
                                    a BLK frame was lost, or the host shipped a
                                    ring index where a generation belongs      */

#endif /* GRBL_SEGWIRE_H */
