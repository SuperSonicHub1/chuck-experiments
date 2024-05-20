// Not a fan at all of this frustrating indirection…
// ChucK ***needs*** an import scheme.

Machine.add(me.dir() + "utility/init.ck");
// HACK : Ensure all class defs execute
me.yield();
Machine.add(me.dir() + "ugens/init.ck");
me.yield();
Machine.add(me.dir() + "instruments/init.ck");
me.yield();


// Machine.add(me.dir() + "apps/theremin.ck");
// NOTES TO SELF:
// - Clear pads in between playing sessions
// - If loop mode doesn't seem to be working, turn off the arp.
Machine.add(me.dir() + "apps/amenbox.ck");

// Machine.add(me.dir() + "apps/flanger_fun.ck");
// Machine.add(me.dir() + "apps/ugen_experiments.ck"); 
// Machine.add(me.dir() + "apps/clock_test.ck"); 

