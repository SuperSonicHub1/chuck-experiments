/*
 * Implementation of an amplitude-based gate without hysteresis.
 * RESOURCES:
 * - https://www.ableton.com/en/live-manual/11/live-audio-effect-reference/#gate
 * - https://en.wikipedia.org/wiki/Multiplexer
 */
public class SelfGate extends Chugraph {
    inlet => Delay delay => ADSR env => outlet;

    1.5::ms => delay.delay;

    1::ms => env.attackTime;
    100::ms => env.decayTime;
    0 => env.sustainLevel;
    1::ms => env.releaseTime;

    inlet => Abs abs;
    // for good Amen, use .175
    abs => Geq geq(.0) => blackhole;
    // TODO: This guy's a lil' glitchy.
    abs => Leq leq(.0) => blackhole;

    1.5::ms => dur wait;

    spork ~ envTrigger() @=> Shred @ triggerShred;

    fun void envTrigger() {
        while (true) {
            if (geq.last() $ int) 1 => env.keyOn;
            else if (leq.last() $ int) 1 => env.keyOff;
            wait => now;
        } 
    }

    fun @destruct() {
        triggerShred.exit();
    }

    fun float threshold() {
        return geq.rhs();
    }

    fun float threshold(float newThreshold) {
        return geq.rhs(newThreshold);
    }

    fun float hysteresis() {
        return leq.rhs();
    }

    fun float hysteresis(float newHysteresis) {
        return leq.rhs(newHysteresis);
    }

    fun dur lookahead() {
        return delay.delay();
    }

    fun dur lookahead(dur newLookahead) {
        return delay.delay(newLookahead);
    }
}
