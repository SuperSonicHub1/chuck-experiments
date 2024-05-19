// https://en.wikipedia.org/wiki/Multiplexer
// DOESN'T WORK
// TODO: This is pretty awkward. Is there such a thing
// as a multi-input Chugen?
// class Multiplexer extends Chugen {
//     UGen A;
//     UGen B;


//     fun @construct(UGen A, UGen B) {
//         A => this.A;
//         B => this.B;
//     }

//     fun float tick(float in) {
//         <<< A.last(), B.last() >>>;
//         if (in >= 0.95) return B.last();
//         else return A.last();
//     }
// }

/* fun void multiplexer() {
    SinOsc osc1 => dac;
    SinOsc osc2 => blackhole;
    440 => osc1.freq;
    1000 => osc2.freq;
    Step step(0) => Multiplexer mux(osc1, osc2) => dac;
    <<< "A" >>>;
    5::second => now;
    <<< "B" >>>;
    1 => step.next;
    5::second => now;
} */

fun void absTest() {
    SinOsc osc => Abs abs => dac => WvOut wav => blackhole;
    me.dir() + "../audio/samples/abs-ugen.wav" => wav.wavFilename;

    440 => osc.freq;
    0.2 => osc.gain;

    -1 => abs.op;
    5::second => now;

    1 => abs.op;
    5::second => now;
}

fun void geqTest() {
    SinOsc osc => dac => WvOut wav => blackhole;
    osc => Leq ugen(.5) => blackhole;

    440 => osc.freq;
    0.1 => osc.gain;

    repeat (1000) {
        <<< osc.last(), ugen.last() >>>;
        1::ms => now;
    }
}

fun void gate() {
    SinOsc osc => ADSR env => Dyno dynOsc => dac;
    440 => osc.freq;
    0.7 => osc.gain;
    (100::ms, 500::ms, 0, 1::ms) => env.set;

    SndBuf amen => Dyno dynAmen => dac;
    amen => Abs abs => Geq ugen(.3) => blackhole;
    1 => amen.loop;
    me.dir() + "../audio/samples/amen.wav" => amen.read;

    repeat (1::minute / 1.5::ms) {
        if (ugen.last() $ int) 1 => env.keyOn;
        1.5::ms => now;
    }
}

// Implementation of an amplitude-based gate without hysteresis.
fun void amenSelfGate() {
    1.5::ms => dur lookahead;

    SndBuf amen => Delay delay => ADSR env => NRev rev => Dyno dynAmen => dac;
    me.dir() + "../audio/samples/amen.wav" => amen.read;
    1 => amen.loop;
    1.17 => amen.rate;
    
    (1::ms, 100::ms, 0, 1::ms) => env.set;
    
    lookahead => delay.delay;

    0.1 => rev.mix;
    // -1 => rev.op;

    amen => Abs abs => Geq geq(.175) => blackhole;

    while (true) {
        if (geq.last() $ int) 1 => env.keyOn;
        lookahead => now;
    }
}



fun void amenSelfGateChugraph() {
    SndBuf amen => SelfGate gate => NRev rev => Dyno dynAmen => dac;
    me.dir() + "../audio/samples/amen.wav" => amen.read;
    1 => amen.loop;
    1.17 => amen.rate;
    
    0.1 => rev.mix;

    while (true) {
        1::hour => now;
    }
}



amenSelfGateChugraph();
