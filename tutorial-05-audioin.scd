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
(
SynthDef.new(\audioin, {
	arg in=0, out=0, amp=1;
	var sig;
	sig = SoundIn.ar(in!2) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\delay, {
	arg in=0, out=0, mix=(-0.5), decay=3, amp=1, delHz=0.25, delMin=0.1, delMax=0.4;
	var sig, delay;
	sig = In.ar(in, 2) * amp; // read from arbitrary bus, using In.ar
	delay = CombL.ar(
		sig,
		0.5,
		//SinOsc.kr([0.32, 0.3]).exprange(0.1, 0.4),
		// we can also add some more flexibility
		SinOsc.kr([delHz, delHz*0.9]).exprange(delMin, delMax),
		decay
	);
	sig = XFade2.ar(sig, delay, mix);
	Out.ar(out, sig);
}).add;
)

~delBus = Bus.audio(s, 2);

(
~micGrp = Group.new;
~delGrp = Group.after(~micGrp);

~micSynth = Synth(\audioin, [\in, 0, \out, ~delBus], ~micGrp);
~delSynth = Synth(\delay, [\in, ~delBus, \out, ~out0], ~delGrp);
)

// REVERB + PITCH SHIFT
// we can use multiple delays
(
~micGrp = Group.new;
~delGrp = Group.after(~micGrp);

// dry sound bypassing delay
~micSynthDirect = Synth(\audioin, [\in, 0, \out, ~out0], ~micGrp);
// this goes to processing
~micSynthEffect = Synth(\audioin, [\in, 0, \out, ~delBus], ~micGrp);
)
(
20.do({
	Synth(\delay, [
		\in, ~delBus,
		\out, ~out0,
		\mix, 1, // we already have a dry signal
		\amp, 1/20,
		\delHz, exprand(0.02, 0.08),
		\delMin, exprand(0.05, 0.1),
		\delMax, exprand(0.101, 0.2),
		\decay, rrand(3.0, 6.0),
	], ~delGrp);
});
)

// - note: we hould use a low pass filter to avoid high pitches sss sounds

// - note: we should use an envelope to more gently close the synth

// - note: that DelayL family ugens allocates dinamically memory,
//         going up with delays amount this will very quickly fill up the memsize of the server

// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;














