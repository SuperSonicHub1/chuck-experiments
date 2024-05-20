// Tools for parsing ChucK's MidiMsgs
// Very useful MIDI in ChucK reference:
// https://chuck.stanford.edu/doc/examples/midi/midiout.ck
public class MidiUtil {
    fun static int getChannel(MidiMsg msg) {
        return msg.data1 & 0x0f;
    }
    
    fun static int isNoteOff(MidiMsg msg) {
        return (msg.data1 & 0xf0) == 0x80;
    }

    fun static int isNoteOn(MidiMsg msg) {
        return (msg.data1 & 0xf0) == 0x90;
    }

    fun static int isControlChange(MidiMsg msg) {
        return (msg.data1 & 0xf0) == 0xB0;
    }

    fun static int isPitchBend(MidiMsg msg) {
        return (msg.data1 & 0xf0) == 0xE0;
    }

    fun static float mapCC(MidiMsg msg, float left, float right) {
        return Math.map2(msg.data3, 0, 127, left, right);
    }

    fun static float mapCC(MidiMsg msg) {
        return mapCC(msg, 0, 1);
    }

    fun static float mapPitchBend(MidiMsg msg, float left, float right) {
        (msg.data3 << 8) | msg.data2 => int raw; 
        return Math.map2(
            raw,
            0, 32639,
            left, right
        );
    }

    fun static float mapPitchBend(MidiMsg msg) {
        return mapPitchBend(msg, -1, 1);
    }
}