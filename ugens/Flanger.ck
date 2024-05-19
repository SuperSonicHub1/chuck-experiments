// https://en.wikipedia.org/wiki/Flanging
public class Flanger extends Chugraph {
    // Delay
    inlet => Delay delay;

    // Mixing and crossfader
    float _mix;
    inlet => Gain dry;
    [inlet, delay] => Mix2 wet;
    [dry, wet] => Mix2 crossfader => outlet;

    // Delay modulator
    dur _delayDur; 
    float _freq;
    SinOsc sin => blackhole;
    .5 => sin.gain;

    Shred shred;

    fun updateDelay() {
        while (true) {
            _delayDur * (sin.last() + .5) => dur delayDurr;
            delayDurr => delay.delay;
            // Originally 20 ms; making it 1 samp doesn't seem
            // to affect performance much
            1::samp => now;
        }
    }

    fun float freq() {
        return _freq;
    }

    fun float freq(float newFreq) {
        newFreq => sin.freq;
        newFreq => _freq;
        return newFreq;
    }

    fun dur delayDur() {
        return _delayDur;
    }

    fun dur delayDur(dur newDur) {
        newDur => _delayDur;
        return newDur;
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
        Flanger(20::ms, 0.5, 0.1);
    }

    fun @construct(dur durBegin, float mixBegin, float freqBegin) {
        delayDur(durBegin);
        mix(mixBegin);
        freq(freqBegin);
        spork ~ updateDelay() @=> shred;
    }

    fun @destruct() {
        shred.exit();
    }
}
