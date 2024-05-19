SndBuf amen(me.dir() + "../audio/samples/amen.wav") => Flanger flan => dac;
true => amen.loop;
0.6 => amen.gain;

1 => flan.mix;
.1 => flan.freq;
// 20 ms is def the sweet spot
// Higher makes the delay a little too obvious
// Lower doesn't really do much
// 20::ms => flan.delayDur;

// Variable speed
Phasor phasor => blackhole;
0.9 => phasor.gain;
// Setting freq to 1 is how rhythm games
// make death sound effects LOL
// 0.01 is a slow and painful death LOL and then instant restart!
0.01 => phasor.freq;

fun variableRate(SndBuf buf) {
    while (true) {
        (1 - phasor.last()) => buf.rate;
        1::ms => now;
    }
}

// spork ~ variableRate(amen);

<<< "Starting..." >>>;
while (true) {
    1::ms => now;
}
