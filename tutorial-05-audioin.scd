// ***************
// *** ARDUINO ***
// ***************
//ep. 19
// very cool but skipped

// ****************
// *** AUDIO-IN ***
// ****************
//ep. 20


// PLUG YOUR HEADPHONE! LOWER THE VOLUME!

(
s.quit;
Window.closeAll;

s = Server.local;
ServerOptions.devices.do { arg dev; dev.postln; };
s.options.outDevice_("External Headphones");
s.options.numOutputBusChannels_(2);
s.options.inDevice_("iXR");
s.options.numInputBusChannels_(1);

s.options.sampleRate_(44100);
s.options.memSize_(2.pow(18)); // around 262 MB

ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

~out = 0; // very useful when changing interfaces with multiple outputs
~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath++"samples/";

s.boot;
s.meter;
s.plotTree;
)


// param: hw index
x = {SoundIn.ar(0)!2 }.play;

// In
// remember that in the bus first come the outputs [0,1] and then the inputs [2,(3)]
(
x = {
	var.sig;
	sig = In.ar(2!2); // bus 2, sine 01 and 1 are for output
	Out.ar(0, sig); // bus 0 and 1 automatically. remember this line can also be omitted
}.play;
)

// SoundIn
// ring modulation: takes frequency components in the spectrum and shifts them around
// note: do not use AudioIn, it's deprecated.
(
x.free;
x = {
	var sig, rmod;
	// better to use SoundIn than In since SoundIn automatically picks the In buffers
	// to look at the source code CMD+I
	sig = SoundIn.ar(0!2);
	rmod = sig * SinOsc.ar(700);
	(sig + rmod) * 0.3;
}.play;
)

// Delay & Echo
// - DelayN: non interpolating: fixed delay value
// - DelayL: linear interpolating: non fixed, less cpu power
// - DelayC: cubic interpolating: non fixed, more cpu power, more flexible
(
SynthDef.new(\audioin, {
	arg in=0, out=0, deltime=0.3, mix=(-0.5), decay=3, amp=1;
	var sig, delay;
	sig = SoundIn.ar(in!2) * amp;
	// DELAY
	// params, signal, max delay time (how much memory allocated), actua delay (must be less than max)
	// delay = DelayL.ar(sig, 0.5, deltime);
	// ECHO
	// to have an echo, we can use similarly CombL that feeds into itself
	delay = CombL.ar(sig, 0.5, deltime, decay);
	// XFade2 does an "equal power crossfade", a bit better than just summing the signals
	sig = XFade2.ar(sig, delay, mix);
	Out.ar(out, sig);
}).add;
)

x = Synth(\audioin);
x = Synth(\audioin, [\deltime, 0.3, \mix, 0]);


// PITCH-SHIFTING
// variations in delay cause pitch-shifting effects (slow down and speed up effect)
// united with stereo differences gives a psychedelic-ish effect
(
SynthDef.new(\audioin2, {
	arg in=0, out=0, mix=(-0.5), decay=3, amp=1;
	var sig, delay;
	sig = SoundIn.ar(in!2) * amp;
	delay = CombL.ar(
		sig,
		0.5,
		SinOsc.kr([0.32, 0.3]).exprange(0.1, 0.4), // the array causes stero differences.
		decay);
	sig = XFade2.ar(sig, delay, mix);
	Out.ar(out, sig);
}).add;
)

x = Synth(\audioin2);


// ************************
// *** MOODULARIZATIONS ***
// ************************

// splitting synths in smaller units


// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;














