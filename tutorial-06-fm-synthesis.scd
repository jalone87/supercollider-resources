// PLUG YOUR HEADPHONE! LOWER THE VOLUME!

(

"-- PREPARING".postln;

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

s.waitForBoot({
	s.sync;

	s.meter;
	s.plotTree;
	s.scope;
	FreqScope.new;

	s.sync;

	"-- READY".postln;
});
)



// ********************
// *** FM SYNTHESIS ***
// ********************
//ep. 21

// the output signal of one oscillator (the modulator)
// is used to offset the frequency of another oscillator (the carrier)

// lets create a carrier oscillator and frequency
{SinOsc.ar(500) * 0.2!2}.play;

// add an audio rate oscillator. the modulator.
{SinOsc.ar(500 + SinOsc.ar(1)) * 0.2!2}.play;
// tone fluctuates between 499 and 500 Hz

{SinOsc.ar(500 + SinOsc.ar(1, mul: 400)) * 0.2!2}.play;
// tone fluctuates between 100 and 900 Hz

// increase modulator frequency
{SinOsc.ar(500 + SinOsc.ar(20, mul: 400)) * 0.2!2}.play;


// lets connect the frequency to the mouse x
{SinOsc.ar(500 + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul: 400)) * 0.2!2}.play;

// increase complexity
{SinOsc.ar(MouseY.kr(200, 5000, 1).poll + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul: 400)) * 0.2!2}.play;

// add noise to the multiplier
(
{
	SinOsc.ar(
		MouseY.kr(200, 5000, 1).poll
		+ SinOsc.ar(
			MouseX.kr(1, 2000, 1).poll,
			mul: LFNoise0.kr(8).range(20, 10000)
		)
	) * 0.2!2;
}.play;
)

// convert to synthdef
(
SynthDef.new(\fm, {
	arg carHz=500, modHz=100, modAmp=200, atk=0.01, rel=1, amp=0.2, pan=0;
	var car, mod, env;
	// add envelope to end the sound
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:  2);
	mod = SinOsc.ar(modHz, mul:modAmp);
	car = SinOsc.ar(carHz + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

(
Synth(\fm, [
	\carHz, exprand(20, 10000),
	\modHz, exprand(20, 10000),
	\modAmp, rrand(0, 10000), //db is already log
	\amp, exprand(0.1, 0.5),
	\atk, exprand(0.001, 0.05),
	\rel, exprand(0.05, 1.2),
	\pan, rrand(-1.0, 1.0),
]);
)

// introduce a pattern
(
p = Pbind(
	\instrument, \fm,
	\dur, Prand([1/4], inf),
	// use the pattern equivalent objects to generate ran or the random value will be a constant
	\carHz, Pexprand(20, 400),
	\modHz, Pexprand(20, 400),
	\modAmp, Pwhite(0, 400),
	\amp, Pexprand(0.1, 0.5),
	\atk, Pexprand(0.001, 0.05),
	\rel, Pexprand(0.5, 2),
	\pan, Pwhite(-1.0, 1.0),
).play;
q = Pbind(
	\instrument, \fm,
	\dur, Prand([1/4], inf),
	\carHz, Pexprand(800, 1600),
	\modHz, Pexprand(800, 1600),
	\modAmp, Pwhite(800, 1600),
	\amp, Pexprand(0.1, 0.5),
	\atk, Pexprand(0.001, 0.05),
	\rel, Pexprand(0.5, 2),
	\pan, Pwhite(-1.0, 1.0),
).play;
)

// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;






















