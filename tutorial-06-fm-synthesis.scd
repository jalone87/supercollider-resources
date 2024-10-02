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
	s.freqscope;
	// FreqScope.new();

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


// *************************
// *** FM SYNTHESIS pt.2 ***
// *************************
//ep. 21

// fm synthesis creates sidebands components around the carrier frequency

// dB                    carrier
// |                     |
// |                     |
// |                ||   |   ||
// |         |      ||   |   ||      |
// |         |   |  ||   |   ||   |  |
// |         |   |  ||   |   ||   |  |
//  ____________________________________________ Hz

// numbers of sidebands is dependent on the "index of mdulation"


// modulator amp is 0, so index of mudulation is 0. no mmudolator signal. pure 800Hz
{SinOsc.ar(800 + SinOsc.ar(200, mul: 0)) * 0.2!2}.play;

// as the modulator amp increases we get a wider and more complex spectrum
{SinOsc.ar(800 + SinOsc.ar(200, mul:10)) * 0.2!2}.play;
{SinOsc.ar(800 + SinOsc.ar(200, mul:100)) * 0.2!2}.play;
{SinOsc.ar(800 + SinOsc.ar(200, mul:1000)) * 0.2!2}.play;
{SinOsc.ar(800 + SinOsc.ar(200, mul:10000)) * 0.2!2}.play;
// leading to an increase of the index of modulation
// see the Freq Analyzer

// increasing the modulator frequency, the spacing betweeen sidebands increases
{SinOsc.ar(800 + SinOsc.ar(200, mul:400)) * 0.2!2}.play;
// here we will see the additional sidebands at 200, 400, 600; 1000, 1200, 1400...
{SinOsc.ar(800 + SinOsc.ar(300, mul:400)) * 0.2!2}.play;
// here we will see the additional sidebands at 200, 500; 1100, 1400, 1700...


// sidebands that will go into the negative spectrum will actually be "bounced back"
// in the positive, with identical shape but inverted "polarity"
// see https://www.youtube.com/watch?v=dLMSR2Kjq6Y&ab_channel=EliFieldsteel


// using the maouse to explore the change upon variations of the modulator frequency
// we can notice there are spots where the pitch is very clear
{SinOsc.ar(500 + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul: 400)) * 0.2!2}.play;
// this happens when the carrier  and the modulator frequency form a simple ratio
// eg 2:1, 3:1, 3:2, etc
// 5:1
{SinOsc.ar(500 + SinOsc.ar(100, mul: 400)) * 0.2!2}.play;
// 2:1
{SinOsc.ar(500 + SinOsc.ar(250, mul: 400)) * 0.2!2}.play;
// 1:4
{SinOsc.ar(500 + SinOsc.ar(2000, mul: 400)) * 0.2!2}.play;

// incorporating these chanfges into a synthdef
// makign sure we hear the pitch (freq)
(
SynthDef.new(\fm, {
	arg freq=500, mRatio=1, cRatio=1, modAmp=200,
	amp=0.2,  atk=0.01, rel=1, pan=0;
	var car, mod, env;
	// add envelope to end the sound
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:  2);
	mod = SinOsc.ar(freq * mRatio, mul:modAmp);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)


Synth(\fm, [\freq, 440]);
Synth(\fm, [\freq, 880]);
Synth(\fm, [\freq, 60.midicps]);
Synth(\fm, [\freq, 61.midicps]);

// changing the carrier multiplier: spacing of armonics does not change, but the harmonics claster move away
Synth(\fm, [\freq, 60.midicps, \cRatio, 2]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 3]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 10]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 100]);
// non integer ratios give non harmonic sounds (you cant distinguish the pitch)
Synth(\fm, [\freq, 60.midicps, \cRatio, 3.54334]);

// changing the modulator ratio: carriers stays the same; spacing of sidebands increases
Synth(\fm, [\freq, 60.midicps, \cRatio, 1, \mRatio, 2]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 1, \mRatio, 3]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 1, \mRatio, 10]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 1, \mRatio, 100]);

// modifyng both
Synth(\fm, [\freq, 60.midicps, \cRatio, 5, \mRatio, 1]);


// *** index of modulation ***

// index = modulatorAmp / modulatorHz (+1);
// loosely corresponds to the number of audible sidebar pairs in the spectrum
(
SynthDef.new(\fm, {
	// remove the modAmp, replace with index
	arg freq=500, mRatio=1, cRatio=1, index=1,
	amp=0.2,  atk=0.01, rel=1, pan=0;
	var car, mod, env;
	// add envelope to end the sound
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:  2);
	// freq * mRatio, by default makes index = 1,
	// so we can use the index paramas multiplier
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * index);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

// the sound sounds a  bit more open the higher it gets
// the harmonics increase
Synth(\fm, [\freq, 60.midicps, \index, 1]);
Synth(\fm, [\freq, 60.midicps, \index, 2]);
Synth(\fm, [\freq, 60.midicps, \index, 4]);
Synth(\fm, [\freq, 60.midicps, \index, 10]);
Synth(\fm, [\freq, 60.midicps, \index, 100]);








// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;






















