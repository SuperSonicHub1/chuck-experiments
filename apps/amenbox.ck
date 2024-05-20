MidiIn input;
// Access input
if(!input.open("Amenbox")) me.exit();
// if(!input.open("MPKmini2")) me.exit();

MidiIn clockIn;
// Access clock
// "USB Uno MIDI Interface", "TB-03", "TR-06", "USB MIDI Interface", "Elektron Model:Samples" for FaMLE
// "Clock" for personal
if(!clockIn.open("Clock")) me.exit();


Amenbox box(input, clockIn);
box.main();