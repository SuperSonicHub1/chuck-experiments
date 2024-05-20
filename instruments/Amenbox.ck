// Sample-based instrument designed for live group play.
// Created in spring 2024, refined significantly through
// FaMLE (21M.470) in Q4 2023-24. 

// Effects for the box.
// Having it be a chugraph makes it easy to connect and disconnect samples
// while not worrying about accidentally breaking something.
class AmenboxEffects extends Chugraph {
    inlet => SelfGate gate => Delay delay => LPF lpf => HPF hpf
    => Flanger flan => NRev rev => Dyno dyn => outlet;
    
    5000::ms => delay.max;
    20000 => lpf.freq;
    20 => hpf.freq;
    0 => flan.mix;
    0 => rev.mix;
}

public class Amenbox {
    // TODO: make a sick-ass UI
    //      - get rid of all printfs
    //      - get rid of unnecessary printf vars

    16 => int SLICES;

    MidiIn input;
    MidiClock clock;
    ChopBuf samples[];
    ChopBuf current;
    AmenboxEffects effects;

    fun @construct(MidiIn input_, MidiIn clockIn) {
        input_ @=> input;
        new MidiClock(clockIn) @=> clock;

        // Sample declaration
        // TODO: Move to text file?
        new ChopBuf(me.dir() + "../audio/samples/amen.wav", SLICES, 137.84) @=> ChopBuf amen;
        new ChopBuf(me.dir() + "../audio/samples/stabs.wav", SLICES, 217.49) @=> ChopBuf stabs;
        new ChopBuf(me.dir() + "../audio/samples/ekit.wav", SLICES, 120) @=> ChopBuf ekit;
        new ChopBuf(me.dir() + "../audio/samples/rimhit.wav", SLICES, 127) @=> ChopBuf rimhit;
        [ekit, amen, stabs, rimhit] @=> samples;
        for (0 => int i; i < samples.size(); i++) {
            samples[i].samples() => samples[i].pos;
        }

        samples[0] @=> current;

        // Audio graph
        current => effects => dac;

        clock.bpm() => current.bpm;
    }

    fun switchSample(int i) {
        current =< effects;
        samples[i % samples.size()] @=> current;
        current => effects;
    }

    // Integer references
    IntRef idx(0);
    IntRef glitchy(0);
    IntRef stutterDiv(1);
    IntRef rampUp(0);
    IntRef sampleIdx(0);
    IntRef nudge(0);
    IntRef loopMode(0);
    IntRef loopLeft(0);
    IntRef loopLeftHeld(0);
    IntRef loopRight(SLICES - 1);
    IntRef loopRightHeld(0);

    fun updateRate() {
        while (true) {
            clock.quarter => now;
            clock.bpm() => float bpm => current.bpm;
        }
    }

    fun void handleMidi() {
        MidiMsg msg;
        while (true) {
            input => now;
            while(input.recv(msg)) {
                if (MidiUtil.isNoteOn(msg)) {
                    msg.data2 => int note;
                    // Notes 44-47 are the safe pads
                    if (note == 44) {
                        1 => nudge.i;
                        <<< "nudged up" >>>;
                    } else if (note == 45) {
                        -1 => nudge.i;
                        <<< "nudged down" >>>;
                    }

                    if (note >= 48 && note <= 72) {
                        if (loopMode.i) {
                            loopLeftHeld.i => int ll; 
                            loopRightHeld.i => int lr; 
                            if (!ll) {
                                note % current.slices => loopLeft.i;
                                1 => loopLeftHeld.i;
                            } else if (!lr) {
                                1 => loopRightHeld.i;
                                // TODO: Handle loopRight.i - loopLeft.i < 0
                                if (note % current.slices < loopLeft.i) {
                                    loopLeft.i => loopRight.i;
                                    note % current.slices => loopLeft.i;
                                } else note % current.slices => loopRight.i;
                            }
                        } else {
                            // Account for loop inc
                            (note - 1) % current.slices => int val => idx.i;
                        }
                    }
                }
                else if (MidiUtil.isNoteOff(msg)) {
                    msg.data2 => int note;
                    if (loopMode.i && note >= 48 && note <= 72) {
                        if (note % current.slices == loopLeft.i) {
                            0 => loopLeft.i;
                            0 => loopLeftHeld.i;
                        } else if (note % current.slices == loopRight.i) {
                            SLICES - 1 => loopRight.i;
                            0 => loopRightHeld.i;
                        }
                    }
                }
                else if (MidiUtil.isControlChange(msg)) {
                    // stick y-axis is CC1 by default
                    // (unfortunate, but can be changed in the configuration software)
                    // knobs are CCs 1 to 8
                    if (msg.data2 == 2) {
                        // Account for being out of phase due to MIDI clock
                        clock.beat() => dur beat;
                        MidiUtil.mapCC(msg, 0, 400) $ int * ms
                        => dur duration
                        => effects.delay.delay;
                        <<< "delay.delay:", duration/ms, "ms" >>>;
                    }
                    else if (msg.data2 == 3) {
                        MidiUtil.mapCC(msg) => float val => effects.gate.threshold;
                        <<< "gate.threshold:", val >>>;
                    }
                    else if (msg.data2 == 4) {
                        MidiUtil.mapCC(msg) => float amount;
                        
                        amount => effects.flan.mix;
                        <<< "flan.mix:", amount >>>;
                    }
                    else if (msg.data2 == 5) {
                        MidiUtil.mapCC(msg) => float val => effects.rev.mix;
                        <<< "rev.mix:", val >>>;
                    }
                    else if (msg.data2 == 6) {
                        MidiUtil.mapCC(msg, 20, 20000) => float val
                            => effects.hpf.freq;
                        <<< "hpf.freq:", val >>>;
                    }
                    else if (msg.data2 == 7) {
                        MidiUtil.mapCC(msg, 20, 20000) => float val
                            => effects.lpf.freq;
                        <<< "lpf.freq:", val >>>;
                    }
                    else if (msg.data2 == 8) {
                        Math.pow(2, MidiUtil.mapCC(msg, 0, 4) $ int)
                            $ int => int val => stutterDiv.i;
                        <<< "stutterDiv:", val >>>;
                    }
                    // pads are CCs 20-35
                    // bank A (green): 20-27, bank B (red): 28-35
                    // increasing from left to right,
                    // bottom to top
                    else if (msg.data2 == 20) {
                        (msg.data3 != 0) => int val => glitchy.i;
                        <<< "glitchy:", val >>>;
                    }
                    else if (msg.data2 == 21) {
                        (msg.data3 != 0) => int val => current.reversed;
                        <<< "reversed:", val >>>;
                    }
                    else if (msg.data2 == 22) {
                        (msg.data3 != 0) => int val => rampUp.i;
                        <<< "rampUp:", val >>>;
                    }
                    else if (msg.data2 == 24) {
                        (msg.data3 != 0) ? 0 : 1 => int val => current.op;
                    }
                    else if (msg.data2 == 27) {
                        (msg.data3 != 0) => int val => loopMode.i;
                        if (val == 0) {
                            0 => loopLeft.i;
                            0 => loopLeftHeld.i;
                            SLICES - 1 => loopRight.i;
                            0 => loopRightHeld.i;
                        }
                    }
                    else if (28 <= msg.data2 && msg.data2 <= 31) {
                        (31 - msg.data2) => int ccIdx;
                        (sampleIdx.i & ~(1 << ccIdx)) | ((msg.data3 != 0) << ccIdx) => int val => sampleIdx.i;
                        switchSample(sampleIdx.i);
                    }
                }
                // stick x-axis
                else if (MidiUtil.isPitchBend(msg)) {
                    MidiUtil.mapPitchBend(msg, 0.75, 1.25) => float val
                        => current.pitchBend;
                }
            }
        }
    }

    fun UI_Text createText(UI_Window window, string text) {
        UI_Text textEl;
        textEl.text(text);
        textEl.wrap(true);
        textEl.mode(UI_Text.MODE_DEFAULT);
        window.add(textEl);
        return textEl;
    }

    fun uiLoop() {
        GG.windowTitle("The Amenbox");

        UI_Window window;
        window.text("Status");

        createText(window, "Muted:") @=> UI_Text mutedText;
        createText(window, "BPM:") @=> UI_Text bpmText;
        createText(window, "Index:") @=> UI_Text indexText;
        createText(window, "Sample:") @=> UI_Text sampleText;
        createText(window, "Pitchbend Factor:") @=> UI_Text pitchbendText;
        createText(window, "Loop:") @=> UI_Text loopText;
        createText(window, "Loop Range:") @=> UI_Text loopRangeText;
        loopRangeText.mode(UI_Text.MODE_BULLET);

        while (true) {
            mutedText.text("Muted:" + !current.op());
            bpmText.text("BPM: " + clock.bpm());
            indexText.text("Index: " + idx.i);
            sampleText.text("Sample: " + current.filePath);
            pitchbendText.text("Pitchbend Factor: " + current.pitchBend());
            loopText.text("Loop: " + loopMode.i);
            loopRangeText.text("Loop Range: [" + loopLeft.i + ", " + loopRight.i + "]");
            GG.nextFrame() => now;
        }
    }

    fun loop() {
        while (true) {
            if (stutterDiv.i > 1) {
                current.stutter(idx.i, clock.beat(), stutterDiv.i, rampUp.i);
            }
            else {
                current.jumpTo(idx.i);
                if (nudge.i != 0) {
                    if (nudge.i == 1) clock.nudgeUp();
                    else /* if (nudge.i == -1) */ clock.nudgeDown();
                    0 => nudge.i;
                    <<< "nudged" >>>;
                } else clock.quarter => now;
                if (glitchy.i) clock.quarter => now;
            }
            if (loopMode.i) {
                loopRight.i + 1 - loopLeft.i => int length;
                idx.i - loopLeft.i => int relPos;
                ((relPos + 1) % length) + loopLeft.i => idx.i;
            } else (idx.i + 1) % current.slices => idx.i;
        }
    }

    fun main() {
        spork ~ updateRate();
        spork ~ handleMidi();
        spork ~ uiLoop();

        while (true) {
            <<< "Waiting for start message..." >>>;
            clock.start => now;
            <<< "Starting!" >>>;
            now => clock.lastQuarter;
            for (0 => int i; i < samples.size(); i++) {
                1 => samples[i].loop;
            }
            0 => idx.i;
            spork ~ loop() @=> Shred shred;
            clock.stop => now;
            <<< "Stopping." >>>;
            for (0 => int i; i < samples.size(); i++) {
                0 => samples[i].loop;
                samples[i].samples() => samples[i].pos;
            }
            shred.exit();
        }
    }
}