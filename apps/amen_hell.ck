1 => int PAN_RANDOM;
2 => int PAN_SINE;

fun float samplesSquished(SndBuf buf) {
    return buf.samples() / buf.rate();
}

fun float samplesUnsquished(SndBuf buf, float samples) {
    return samples * buf.rate();
}

fun void randomPan(Pan2 pan, dur beat) {
    while (true) {
        Math.random2f(-1, 1) => pan.pan;
        1::beat => now;
    }
}

fun void sinePan(Pan2 pan) {
    Math.random2f(0, 2 * Math.PI) => float offset;
    Math.random2f(0.25, 15)::second => dur frequency;
    while (true) {
        Math.sin(now / frequency + offset) => pan.pan;
        50::ms => now;
    }
}

fun void breakbeat(float bpm, int panType) {
    1::minute / bpm => dur beat;

    SndBuf amen => NRev rev => Pan2 pan => dac;
    0.6 => amen.gain;
    me.dir() + "../audio/samples/amen.wav" => amen.read;
    (bpm / 136) => amen.rate;
    0.05 => rev.mix;

    if (panType == PAN_RANDOM) {
        spork ~ randomPan(pan, beat);
    } else if (panType == PAN_SINE) {
        spork ~ sinePan(pan);
    }

    while (true) {
        (Math.randomf() <= 0.1) => int reverse;
        (Math.randomf() <= 0.15) => int doubleTime;
        if (reverse) (-1 * amen.rate()) => amen.rate;
        if (doubleTime) (0.5 * amen.rate()) => amen.rate;

        beat / 1::samp => float samplesPerBeat;
        samplesUnsquished(
            amen,
            Math.random2(
                0,
                (samplesSquished(amen) / samplesPerBeat) $ int
            ) * (samplesPerBeat)
        ) $ int => amen.pos;
        1::beat => now;

        if (reverse) (-1 * amen.rate()) => amen.rate;
        if (doubleTime) (2 * amen.rate()) => amen.rate;
    }
}

// spork ~ breakbeat(320, PAN_SINE);
spork ~ breakbeat(160, PAN_RANDOM);
spork ~ breakbeat(80, PAN_SINE);
spork ~ breakbeat(40, PAN_SINE);

while (true) {
    1::hour => now;
}
