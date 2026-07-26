//
// SAMD21_TCC.cs - minimal register-observability model for the SAMD21 TCC
// (Timer/Counter for Control) block that drives GRBL's spindle PWM output.
//
// BUG #22 context: the RPM->PWM gradient in spindle_control.c was wrong by
// ~258x (a board's config.h declared SPINDLE_PWM_MAX_VALUE=65535 - the AVR
// 16-bit-timer value - against this port's actual 8-bit TCC0 duty domain,
// PER=0xFF). S500 (well inside the linear part of the rpm_min..rpm_max
// range) ended up driving the pin at essentially full duty. The bug
// survived a Renode probe for two independent reasons:
//   1. the probe used M3 S1000, which sits at/above the port's default
//      $30=1000 rpm_max and hits the "rpm >= rpm_max" clamp branch in
//      spindle_compute_pwm_value() - pwm_gradient (where the bug lived) is
//      never evaluated on that path;
//   2. TCC0 was an unmodeled `Tag` in samd21_grbl.repl: reads of CC[0]/PER
//      always returned 0, so no register-level evidence of the wrong duty
//      was even possible, regardless of which S-word was probed.
//
// This class closes reason 2. It is NOT a waveform generator - no
// prescaler countdown, no compare-match edges, no interrupts. Renode ships
// no stock TCC (or TCC-like) peripheral model to subclass (checked: only
// SAMD21_Timer exists, for the plain TC blocks - see SAMD21_Timer16.cs), so
// this is a flat backing store for the TCC register file exactly as GRBL
// sees it (grbl/platform/samd21/samd21.h's `Tcc` struct - all 32-bit
// registers, no COUNT16 width games like the TC blocks have), wide enough
// that CTRLA/WAVE/PER/CC[0..3] faithfully read back whatever firmware wrote
// - which is all the new SPINDLE smoke stage needs: read CC[0] after an
// S-word and compare it against the value spindle_control.c's own formula
// says it should be.
//
// SYNCBUSY (offset 0x0C) always reads 0. Every busy-wait in timer.h's
// PWM_INIT/PWM_ENABLE/PWM_DISABLE/PWM_SET macros polls a SYNCBUSY bit and
// relied on exactly this behavior already, inherited for free from the
// unmodeled Tag's 0-fill. Breaking that would deadlock the existing
// banner/motion/arc smoke stages the moment spindle_init() or PWM_SET runs.
//
using System;
using Antmicro.Renode.Core;
using Antmicro.Renode.Peripherals.Bus;
using Antmicro.Renode.Logging;

namespace Antmicro.Renode.Peripherals.Timers
{
    public class SAMD21_TCC : IDoubleWordPeripheral, IWordPeripheral, IBytePeripheral, IKnownSize
    {
        public SAMD21_TCC(IMachine machine)
        {
            regs = new byte[Size];
        }

        public uint ReadDoubleWord(long offset)
        {
            if (InSyncBusy(offset, 4))
            {
                return 0;
            }
            if (!InRange(offset, 4))
            {
                this.Log(LogLevel.Warning, "SAMD21_TCC: double word read out of range at 0x{0:X}", offset);
                return 0;
            }
            return BitConverter.ToUInt32(regs, (int)offset);
        }

        public void WriteDoubleWord(long offset, uint value)
        {
            if (!InRange(offset, 4))
            {
                this.Log(LogLevel.Warning, "SAMD21_TCC: double word write out of range at 0x{0:X} = 0x{1:X}", offset, value);
                return;
            }
            var bytes = BitConverter.GetBytes(value);
            Array.Copy(bytes, 0, regs, (int)offset, 4);
        }

        public ushort ReadWord(long offset)
        {
            if (InSyncBusy(offset, 2))
            {
                return 0;
            }
            if (!InRange(offset, 2))
            {
                this.Log(LogLevel.Warning, "SAMD21_TCC: word read out of range at 0x{0:X}", offset);
                return 0;
            }
            return BitConverter.ToUInt16(regs, (int)offset);
        }

        public void WriteWord(long offset, ushort value)
        {
            if (!InRange(offset, 2))
            {
                this.Log(LogLevel.Warning, "SAMD21_TCC: word write out of range at 0x{0:X} = 0x{1:X}", offset, value);
                return;
            }
            var bytes = BitConverter.GetBytes(value);
            Array.Copy(bytes, 0, regs, (int)offset, 2);
        }

        public byte ReadByte(long offset)
        {
            if (InSyncBusy(offset, 1))
            {
                return 0;
            }
            if (!InRange(offset, 1))
            {
                this.Log(LogLevel.Warning, "SAMD21_TCC: byte read out of range at 0x{0:X}", offset);
                return 0;
            }
            return regs[offset];
        }

        public void WriteByte(long offset, byte value)
        {
            if (!InRange(offset, 1))
            {
                this.Log(LogLevel.Warning, "SAMD21_TCC: byte write out of range at 0x{0:X} = 0x{1:X}", offset, value);
                return;
            }
            regs[offset] = value;
        }

        public void Reset()
        {
            Array.Clear(regs, 0, regs.Length);
        }

        public long Size => 0x400;

        private bool InRange(long offset, int width)
        {
            return offset >= 0 && offset + width <= regs.Length;
        }

        // SYNCBUSY (0x0C, 4 bytes on this port's Tcc layout) must always
        // read 0 regardless of width - see the file header comment.
        private bool InSyncBusy(long offset, int width)
        {
            return offset < SyncBusyOffset + 4 && offset + width > SyncBusyOffset;
        }

        private const long SyncBusyOffset = 0x0C;
        private readonly byte[] regs;
    }
}
