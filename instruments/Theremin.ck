public class Theremin {
    60 => static int BASE_NOTE;

    SinOsc waves[5] => ADSR envs[5] => dac;

    MidiIn input;
    fun @construct(MidiIn input) {
        input @=> this.input;
        for (SinOsc osc: waves) osc.gain(0.4);
        for (ADSR env: envs) env.set(200::ms, 0.5::second, 0.8, 1::second);
    }

    fun main() {
        MidiMsg msg;
        <<< "Starting..." >>>;
        while (true) {
            input => now;
            while (input.recv(msg)) {
                if (MidiUtil.isNoteOn(msg)) {
                    <<< "note on:", msg.data2 - BASE_NOTE >>>;
                    envs[msg.data2 - BASE_NOTE].keyOn();
                }
                else if (MidiUtil.isNoteOff(msg)) {
                    <<< "note off:", msg.data2 - BASE_NOTE >>>;
                    envs[msg.data2 - BASE_NOTE].keyOff();
                }
                else if (MidiUtil.isPitchBend(msg)) {
                    // <<< "pitchbend: ", MidiUtil.getChannel(msg), MidiUtil.mapPitchBend(msg, 50, 80) >>>;
                    MidiUtil.mapPitchBend(msg, 50, 80)
                        => Std.mtof
                        => waves[MidiUtil.getChannel(msg)].freq;
                }
            }
        }
    }
}
