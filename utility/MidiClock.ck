// https://chuck.stanford.edu/doc/language/event.html
// https://chuck.stanford.edu/doc/examples/midi/midiout.ck
public class MidiClock {
    MidiIn input;
    Shred shred;

    [120., 120., 120., 120., 120., 120., 120., 120.] @=> float _bpms[];


    0 => int pulses;
    // 24 pulses per quarter note
    24 => int PULSES_PER_QUARTER;
    0 => int quarters;

    time lastQuarter;

    Event quarter;
    Event eighth;
    Event sixteenth;
    Event thirtySecond;
    Event sixtyFourth;
    Event start;
    Event stop;
    Event continue_;
    Event pulse;

    1 => static int QUARTER;
    2 => static int EIGHTH;
    3 => static int SIXTEENTH;
    4 => static int THIRTY_SECOND;
    5 => static int SIXTY_FOURTH;

    fun @construct(MidiIn input) {
        input @=> this.input;
        spork ~ this.listen() @=> shred;
        now => lastQuarter;
    }

    fun @destruct() {
        shred.exit();
    }

    fun float bpm() {
        float sum;
        for (0 => int i; i < _bpms.size(); i++) {
            _bpms[i] +=> sum;
        }
        return sum / _bpms.size();
    }


    fun dur beat() {
        return 1::minute / bpm();
    }

    fun nudgeUp() {
        for (0 => int i; i < 23; i++) pulse => now;
    }
    fun nudgeDown() {
        for (0 => int i; i < 25; i++) pulse => now;
    }

    fun listen() {
        0xF8 => int TIMING_CLOCK;
        0xFA => int START_SEQUENCE;
        0xFB => int CONTINUE_SEQUENCE;
        0xFC => int STOP_SEQUENCE;

        MidiMsg msg;
        now => time t;
        while (true) {
            input => now;
            while (input.recv(msg)) {
                if (msg.data1 == TIMING_CLOCK) {
                    pulse.broadcast();
                    // <<< (now - t) / ms >>>;
                    now => t;
                    pulses++;
                    if (pulses % PULSES_PER_QUARTER == 0) {
                        quarter.broadcast();
                        now => time newLastQuarter;
                        1::minute/(newLastQuarter - lastQuarter) => _bpms[quarters % _bpms.size()];
                        quarters++;
                        newLastQuarter => lastQuarter;
                    }
                    else if (pulses % (PULSES_PER_QUARTER / 2) == 0) {
                        eighth.broadcast();
                    }
                    else if (pulses % (PULSES_PER_QUARTER / 4) == 0) {
                        sixteenth.broadcast();
                    }
                    else if (pulses % (PULSES_PER_QUARTER / 8) == 0) {
                        thirtySecond.broadcast();
                    }
                    else if (pulses % (PULSES_PER_QUARTER / 16) == 0) {
                        sixtyFourth.broadcast();
                    }
                }
                else if (msg.data1 == START_SEQUENCE) {
                    start.broadcast();
                }
                else if (msg.data1 == CONTINUE_SEQUENCE) {
                    continue_.broadcast();
                }
                else if (msg.data1 == STOP_SEQUENCE) {
                    stop.broadcast();
                }
            }
        }
    }
}