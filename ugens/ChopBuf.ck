// Based on https://github.com/vscomputer/chuck-examples/blob/0f6ada6e3fe055f3dd7fdb4875993141ec2b647b/23-subclasses/chopBuffer.ck
// Most rights reserved by Clint Hoagland.
public class ChopBuf extends SndBuf
{
    int slices;
    float baseBpm;
    string filePath;
    float _bpm;
    0 => int _reversed;
    1. => float _pitchBend;

    fun @construct(string filePath, int slices, float baseBpm) {
        SndBuf(filePath);
        filePath => this.filePath;
        slices => this.slices;
        baseBpm => this.baseBpm;
        baseBpm => this.bpm;
    }

    fun float baseRate() {
        return _bpm / baseBpm;
    }

    fun updateRate() {
        this.baseRate() * Math.pow(-1, _reversed) * _pitchBend => this.rate;
    }

    fun int reversed() {
        return _reversed;
    }

    fun int reversed(int newReversed) {
        newReversed => _reversed;
        this.updateRate();
        return _reversed;
    }

    fun float pitchBend() {
        return _pitchBend;
    }

    fun float pitchBend(float newPitchBend) {
        newPitchBend => _pitchBend;
        this.updateRate();
        return _pitchBend;
    }

    fun float bpm() {
        return _bpm;
    }

    fun float bpm(float newBpm) {
        newBpm => _bpm;
        this.updateRate();
        return newBpm;
    }

    function void jumpTo(int sliceChoice) {
        this.samples() / slices * (sliceChoice - _reversed) => this.pos;
    }

    function void cutBreak(int sliceChoice, dur duration)
    {
        jumpTo(sliceChoice);
        duration => now;
    }

    // Replicating a cool bug where I accidentally waited twice in
    // row, resulting in doubling the beat! 
    function void cutBreakGlitchy(int sliceChoice, dur duration)
    {
        cutBreak(sliceChoice, 2::duration);
    }

    // TODO: Convert to MidiClock events
    function void stutter(int sliceChoice, dur duration, int divisor, int rampUp)
    {
        if (rampUp) spork ~ volumeRamp(duration, divisor);
        for(0 => int i; i < divisor; i++)
        {
            cutBreak(sliceChoice, duration / divisor);                
        }
    }

    function void volumeRamp(dur duration, int divisor)
    {
        duration / divisor => dur durationSlice;
        this.gain() - (this.gain() / 8 ) => float rampHeight;
        this.gain() / 8 => this.gain;
        for(0 => int i; i < divisor; i++)
        {
            this.gain() + (rampHeight / divisor) => this.gain;
            durationSlice => now;
        }
    }
}