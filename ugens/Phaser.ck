// 8-stage (TODO: eventually configurable?) phaser
// WIP 
// https://en.wikipedia.org/wiki/Phaser_(effect)
// https://chuck.stanford.edu/doc/reference/ugens-filters.html#PoleZero
// https://en.wikipedia.org/wiki/All-pass_filter#Digital_implementation
// https://ccrma.stanford.edu/~jos/pasp/Phasing_First_Order_Allpass_Filters.html
public class Phaser extends Chugraph {
    // Phase-shift network with feedback
    Mix2 start;
    inlet => start.left
    => PoleZero allPass1
    => PoleZero allPass2
    => PoleZero allPass3
    => PoleZero allPass4
    => PoleZero allPass5
    => PoleZero allPass6
    => PoleZero allPass7
    => PoleZero allPass8
    => Gain phaseShift => start.right;

    // Mixing and crossfader
    float _mix;
    inlet => Gain dry;
    [inlet, phaseShift] => Mix2 wet;
    [dry, wet] => Mix2 crossfader => outlet;

    // Coefficient modulator
    float _coeff;
    float _freq;
    SinOsc sin => blackhole;
    .5 => sin.gain;

    Shred shred;

    fun updateCoeff() {
        while (true) {
            sin.last() + .5 => float percent;
            (0/8.) + (1/8.)*percent => allPass1.allpass;
            (1/8.) + (1/8.)*percent => allPass2.allpass;
            (2/8.) + (1/8.)*percent => allPass3.allpass;
            (3/8.) + (1/8.)*percent => allPass4.allpass;
            (4/8.) + (1/8.)*percent => allPass5.allpass;
            (5/8.) + (1/8.)*percent => allPass6.allpass;
            (6/8.) + (1/8.)*percent => allPass7.allpass;
            (7/8.) + (1/8.)*percent => allPass8.allpass;
            20::ms => now;
        }
    }

    fun float coeff() {
        return _coeff;
    }

    fun float coeff(float newCoeff) {
        newCoeff => _coeff;
        return newCoeff;
    }

    fun float freq() {
        return _freq;
    }

    fun float freq(float newFreq) {
        newFreq => sin.freq;
        newFreq => _freq;
        return newFreq;
    }

    fun float mix() {
        return _mix;
    }

    // https://en.wikipedia.org/wiki/Fade_(audio_engineering)#Crossfade_shapes
    fun float mix(float newMix) {
        newMix => _mix;
        Math.sqrt(1 - _mix) => dry.gain;
        Math.sqrt(_mix) => wet.gain;
        return _mix;
    }

    fun @construct() {
        Phaser(1, 0.5, 0.5);
    }

    fun @construct(float coeffBegin, float mixBegin, float freqBegin) {
        // TODO: Remove
        // coeff(coeffBegin);
        mix(mixBegin);
        freq(freqBegin);
        spork ~ updateCoeff() @=> shred;
    }

    fun @destruct() {
        shred.exit();
    }
}

SndBuf amen(me.dir() + "../audio/samples/stabs.wav") => Phaser phaser => dac;
true => amen.loop;
0.5 => amen.gain;
<<< "Starting..." >>>;
while (true) {
    1::ms => now;
}
