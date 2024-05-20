MidiIn input;
// Access theremin
if(!input.open("Leapmotion Theremin")) me.exit();

Theremin box(input);
box.main();
