fun void cosRate(SndBuf buf) {
    while (true) {
        0.2 * Math.cos(now / 5::second) + 0.8 => buf.rate;
        50::ms => now;
    }
}

fun void expRate(SndBuf buf) {
    while (true) {
        0.1 * Math.exp(-(now / 5::second) + 5) + 1.176 => buf.rate;
        <<< buf.rate() >>>;
        50::ms => now;
    }
}

SndBuf amen => dac;
1 => amen.loop;
me.dir() + "audio/amen.wav" => amen.read;

spork ~ expRate(amen);

while (true) {
    1::hour => now;
}
