MidiIn clockIn;
if(!clockIn.open("TB-03")) me.exit();

MidiClock clock(clockIn);

<<< "Let's a go" >>>;
while (true) {
    clock.quarter => now;
    <<< clock.bpm, now >>>;
}
