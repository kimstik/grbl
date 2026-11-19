//
// SAMD21_Timer16.cs - 16-bit access shim for Renode's stock SAMD21_Timer.
//
// GRBL's SAMD21 port drives the TC blocks in COUNT16 mode and accesses
// COUNT/CC[] as uint16_t (strh/ldrh) - exactly what real silicon expects.
// Renode's SAMD21_Timer implements the counter block (offsets >= 0x10:
// COUNT at 0x10, CC0 at 0x18, CC1 at 0x1C) only in its IDoubleWordPeripheral
// path, and its [AllowedTranslations(WordToByte)] turns 16-bit accesses into
// BYTE accesses, for which those offsets are undefined - so a 16-bit CC0
// write is silently dropped. Consequences for GRBL: compare0Value stays 0,
// the model never arms its MC0 capture timer, the stepper interrupt (TC3
// MC0) never fires and motion is frozen even with correct firmware.
//
// This subclass adds a native IWordPeripheral implementation: counter-block
// word accesses are forwarded to the DoubleWord path (which handles them),
// everything below 0x10 keeps the byte-register semantics. Native width
// implementations take precedence over AllowedTranslations, so the base
// model's behavior is otherwise unchanged.
//
using Antmicro.Renode.Core;
using Antmicro.Renode.Core.Extensions;
using Antmicro.Renode.Peripherals.Bus;

namespace Antmicro.Renode.Peripherals.Timers
{
    public class SAMD21_Timer16 : SAMD21_Timer, IWordPeripheral, IBytePeripheral
    {
        public SAMD21_Timer16(IMachine machine, ulong baseFrequency) : base(machine, baseFrequency)
        {
        }

        public ushort ReadWord(long offset)
        {
            if(offset >= CounterBlockStart)
            {
                return (ushort)ReadDoubleWord(offset);
            }
            return this.ReadWordUsingByte(offset);
        }

        public void WriteWord(long offset, ushort value)
        {
            if(offset >= CounterBlockStart)
            {
                if(offset == Cc0Offset)
                {
                    cc0Mirror = value;
                }
                WriteDoubleWord(offset, value);
                return;
            }
            this.WriteWordUsingByte(offset, value);
        }

        // Interface re-implementation (base WriteByte is non-virtual): needed
        // to observe INTENSET writes for the CC0==0 bootstrap below.
        public new void WriteByte(long offset, byte value)
        {
            base.WriteByte(offset, value);
            if(offset == CtrlA0Offset && (value & SwrstBit) != 0)
            {
                // CTRLA.SWRST resets the base model (compare0Value -> 0); the
                // mirror must follow or a stale value would suppress the
                // bootstrap kick after a peripheral reset.
                cc0Mirror = 0;
                return;
            }
            if(offset == IntenSetOffset && (value & Mc0Bit) != 0 && cc0Mirror == 0)
            {
                // GRBL semantics inherited from AVR CTC: the stepper wakes by
                // enabling the compare interrupt while the period register is
                // still 0 (top==0 fires immediately on silicon); the FIRST ISR
                // execution programs the real period (CC0). The stock model
                // instead disarms its capture timer when compare==0, so that
                // first interrupt never comes and motion deadlocks. Pulse the
                // IRQ line once: the NVIC latches the edge, the ISR runs,
                // writes CC0 (through WriteWord above) and from then on the
                // model generates MC0 itself.
                //
                // Deliberately one pulse PER ENABLE, not once per lifetime
                // (adversarial review A3): real MFRQ silicon fires MC0
                // continuously while CC0==0 and the interrupt is enabled, so
                // one edge per INTENSET.MC0 write is the minimal faithful
                // subset - bounded (one ISR per enable, NVIC coalesces), and
                // measured in Renode: N enables -> exactly N single ISR
                // entries, zero kicks from firmware-reachable idle churn.
                // A lifetime latch would deadlock a wake->no-segment->idle
                // cycle followed by real motion (latch spent, CC0 still 0,
                // first interrupt never arrives).
                IRQ.Set(true);
                IRQ.Set(false);
            }
        }

        public new byte ReadByte(long offset)
        {
            return base.ReadByte(offset);
        }

        // Machine/peripheral reset: base compare0Value returns to 0, so the
        // mirror must too (subclass re-lists IPeripheral via IWordPeripheral/
        // IBytePeripheral, remapping IPeripheral.Reset to this method).
        public new void Reset()
        {
            base.Reset();
            cc0Mirror = 0;
        }

        // COUNT/CC[] live at 0x10 and above (COUNT16 layout).
        private const long CounterBlockStart = 0x10;
        private const long Cc0Offset = 0x18;
        private const long CtrlA0Offset = 0x00;
        private const long IntenSetOffset = 0x0D;
        private const byte Mc0Bit = 0x10;
        private const byte SwrstBit = 0x01;

        private ushort cc0Mirror;
    }
}
