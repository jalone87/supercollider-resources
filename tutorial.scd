// *** Followign from Eli Fieldsteel - Supercollider Tutorial
// *** https://www.youtube.com/watch?v=yRzsOOiJ_p4&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC


// **************
// *** SYNTAX ***
// **************

// foo.bar() // Foo is the "receiver" Bar is the "message"
3.cubed // press SHIFT+RETURN to print it in console

// we create a block and can execute it all with CMD+RETURN
(
var number; // local varuable
number = 3.squared;
)

// enviroinment (global) variables. start with tilde
~globalNUmber = 1000;

// create a function in curly braces
{SinOsc.ar;};
x = {SinOsc.ar;};

// Function decclaration
(
z = {
	// first the arguments
	arg freq=440, amp=1;
	// then variable declaration
	var sig;
	// then rest
	sig = SinOsc.ar(freq) * amp
}.play()
)

// a "symbol"
\freq;

// a string
"freq"

// update parameter
z.set(\freq, 330);

// *********************
// *** DOCUMENTATION ***
// *********************

// press SHIT+CMD+D to access documentation
// or with cursor on a class or keyword press CMD+D



// *************
// *** SOUND ***
// *************

{SinOsc.ar;}.play();

// Stop it pressing COMAND + DOT

// create an Synth
x = {SinOsc.ar;};
y = x.play(); // play actually returns a synth

// stop it playiong
y.free;



// ************
// *** UGEN ***
// ************

// UGen or Unit Generators

// oscillator parameters
x = {SinOsc.ar(700, 0.0, 0.125, 0)}.play();
// skip parameters
x = {SinOsc.ar(700, mul: 0.125)}.play();
// same as
x = {SinOsc.ar(700) * 0.125}.play();


// chain ugens

(
z = {
	arg noiseHz = 8;
	var freq, sig, amp;
	//freq = LFNoise0.kr(8, 400, 600); // 8 random values per sec between [-1,1] -> [200,1000]
	// or
	//freq = LFNoise0.kr(8).range(400, 600);
	// frequencies are percieved exponentially. generate log distribution of random freq is better
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1); // LFNoise1 is linearly interpolated. more gentle
	sig = SinOsc.ar(freq) * amp;
}.play;
);

// different hertz everytime we call the function
z.set(\noiseHz, exprand(4, 64));


// the {}.play() aka Function.play syntax is just a shorthand for creating a SynthDef
// SynthDef is a more ffine tuned way to create synthesizers

// recreate z using a SynthDef. This is a random note between 200 and 400 Hz (like a high string on a bass).
(
SynthDef.new(\sineTest, {
	arg noiseHz = 8;
	var freq, sig, amp;
	freq = LFNoise0.kr(noiseHz).exprange(200, 400);
	amp = LFNoise1.kr(12).exprange(0.5, 1);
	sig = SinOsc.ar(freq) * amp;
	// the only difference is that we need to explicitely declare the output
	Out.ar(0, sig) // 0 is the 0th hardware output of the available ones on the machine (eg: 0 left speaker, 1 right speaker)
}).add;
)// add the synth to the audio server. similarly also load/send/store.

// execute the synthdef
x = Synth.new(\sineTest);
x = Synth.new(\sineTest, [\noiseHz, 32]);

x.free;

// ********************
// *** TIME-LIMITED ***
// ********************

// automatically free or end a sound with `doneAction:`

(
x = {
	var sig, env;
	// Line is one type of linear Envelope __/‾‾‾\__
	// you normally only need only two of the many doneAction parameter values: 0 or 2. 0 is do nothing, 2 is free the synth
	env = Line.kr(1, 0, 1, doneAction: 2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)


(
x = {
	var sig, env;
	// we percieve amplitude exponentially. use an exponential envelope. exp does not work with  0!!!
	env = XLine.kr(1, 0.01, 1, doneAction: 2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

// with normalized amp use XLine, with decibel (see below) use Line (since decibel are already exponential)
(
x = {
	var sig, env;
	env = Line.kr(1, -40, 1, doneAction: 2);
	sig = Pulse.ar(ExpRand(30, 500)) * env.dbamp;
}.play;
)

// conver atmp to db and viceversa
0.5.ampdb;
10.dbamp;


// multiple envelopes/doneActions: only have one 2 on the longest envelop, and 0 on all the others
(
x = {
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 5, doneAction: 2); //5 sec, the longest has 2
	freq = XLine.kr(880, 110, 1, doneAction: 0); // frequency is also exponentially perceived. use XLine
	sig = Pulse.ar(freq) * env;
}.play;
)



// ***************
// *** ENV-GEN ***
// ***************
// ep 4.

// As opposite to Line and XLine EnvGen has a `gate` parameter that can trigger teh envelope and also repeat it.

// first create an Evnvelope. We can visualize the default create with `new` with `plot` method.
Env.new.plot;
// note the times must be levels.count-1, as it's the time between each level.
Env.new(levels: [0,1,0], times: [1,2], curve:'sine').plot;

(
{
	var sig, env;
	// env = EnvGen.kr(Env.new, doneAction: 2);
	// env = EnvGen.kr(Env.new([0,1,0], [1,1], 'lin'), doneAction: 2);
	env = EnvGen.kr(Env.new([0,1,0], [1,3], \sine), doneAction: 2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)


// using own curve points
(
{
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]), // unclear but it seem to work like bizier curves when looking at the plot. with 0 meaning linear
		doneAction: 2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

Env.new( [0, 1, 0.2, 0], [0.5, 1, 2], [-10, -3, 0]).plot;

// using gate to trigger a reset of the envelope
// the gate triggers when the value goes from non-positive to positive (0 and 1 is ok)
(
x = {
	// arg gate = 0
	arg t_gate = 0; // we can use t_gate to automatically reset gate to 0 so we can just set it to 1
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]), t_gate);
	sig = Pulse.ar(LFPulse.kr(8).range(80, 90)) * env;
}.play;
)

x.set(\t_gate, 1); // as long as there is no doneAction and the envelope is not complete we can retrigger it as much as wanted


// ADSR Envelope
// adsr have sustain, which means that the envelope remains on the sustain value until the gate does trigger
(
x = {
	arg gate = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500, 1000)) * env;
}.play;
)

x.set(\gate, 1); // oth 1 the envelope wil start and sustain (and no sense using t_)
x.set(\gate, 0); // on zero it will gradually stop

// note Env.dadsr which is the same but with an initial delay variant

//2 different envelopes sharing the same gate
(
x = {
	arg gate = 0;
	var sig, env, freq;
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	env = EnvGen.kr(Env.adsr, gate, doneAction: 2);
	sig = VarSaw.ar(SinOsc.kr(freq).range(30, 400)) * env;
}.play;
) // they will end together

x.set(\gate, 1);
x.set(\gate, 0);




// *********************
// *** MULTI-CHANNEL ***
// *********************
// ep 5.
// search docs for "Multichannel Expansion"

s.meter; // shows the audio levels for current channels

// following are the same. the array is expanded to the first available channels (0 and 1)
x = { [ SinOsc.ar(300), SinOsc.ar(500) ] }.play;
x = { SinOsc.ar([300, 500]) }.play;

(
x = {
	var sig, amp;
	amp = SinOsc.kr(7).range(0,1);
	// the prevoious osc only has one channel, when multiplied with the sig oscillator, which has 2,
	// the osc with less channels will apply the single one to all the others channel. same as below
	// amp = SinOsc.kr([7, 7]).range(0,1);
	sig = SinOsc.ar([300, 500]);
	sig = sig * amp;
}.play;
)

// Mixing

(
x = {
	var sig, amp;
	// given an arbitrary amount of channel. they useless if we only have 2 speakers
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	//   we create a mixxer that sums them all to a single channel
	// Mix.new(sig) * 0.25; // 0.25 reduces clipping
	//   to bring back to 2 channels
	// [Mix.new(sig), Mix.new(sig)] * 0.25;
	//   or shortly
	// Mix.new(sig).dup(2) * 0.25;
	//   or even shorter
	// Mix.new(sig)!2 * 0.25 ;
	//   if we want to distribute the N channels *differently* to the 2 stereo ones we can use
	Splay.ar(sig) * 0.25;
}.play;
)

// note differences
x = {PinkNoise.ar(0.5)!2}.play; // same outputs both channels
x = {PinkNoise.ar(0.5!2)}.play; // different outputs for channels

x = rrand(50, 1000)!4; // same number filling an array of size 4
x = {rrand(50, 1000)}!4; // in a function, the number is always different. like a callback.

// exprand and rrand will still be evaluated at compile time. outcome is always the same.
// to better use in a signal, use the Ugen
ExpRand(0.2, 12)!8; // see https://www.youtube.com/watch?v=fAXETAyrv8s min11.30 for more info

// beware that in SynthDef the Out already performs expansion.
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	// So if it it finds a multichannel signal, you only need to use the initial channel (0)
	Out.ar(0, sig);
}).add;
)
x = Synth.new(\multi);


// *****************
// *** ITERATION ***
// *****************
// ep.6

// "do" iterates over the array and executes the function
[6, 4, 9.5, 10, 7].do{"hello".postln};
// do returns the receiver (the array) at the end

// iterate over the items
(
[6, 4, 9.5, 10, 7].do{
	arg item;
	item.squared.postln;
};
)

// enumerated
(
[6, 4, 9.5, 10, 7].do{
	arg item, count;
	[count, item.squared].postln;
};
)


// store result
x = Array.newClear(5);
(
[6, 4, 9.5, 10, 7].do{
	arg item, count;
	x[count] = item.squared;
};
)
x.postln;

//or better
(
z = [6, 4, 9.5, 10, 7].collect{
	arg item, count;
	item.squared;
};
)
//or better
z = [6, 4, 9.5, 10, 7].collect(_.squared);

// we can iterate onver integers as well. they are like ranges
5.do{"hi".postln;}


// lets apply to a signal
x = {VarSaw.ar(40!2, 0, 0.05)}.play;

(
SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2, // randomize freq a bit, apply double channel
			0, //no phase
			0.05 // width?
		);
		sum = sum + temp;
	};
	sum = sum * 0.05; // summin 10 signal, scal down to avoid clipping
	Out.ar(0, sum);
}).add;
)

// nice. but the sound is popping at the start
x = Synth.new(\iter);

(
SynthDef.new(\iter2, {
	arg freq = 40; //add freq param
	var temp, sum, env;
	sum = 0;
	env = EnvGen.kr( // add an envelope so we can use it's done action to automatically free the synths
		Env.perc(0.01, 5, 1, -2),
		doneAction: 2
	);
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2, // randomize the phase to diminuish popping
			{ExpRand(0.005, 0.05)}!2 // makes the sound more aggressive?
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

// we can now make a chord
(
Synth.new(\iter2, [\freq:400]);
Synth.new(\iter2, [\freq:300]);
Synth.new(\iter2, [\freq:250]);
Synth.new(\iter2, [\freq:225]);
)

// we can use midi numbers instead of frequenncy
(
Synth.new(\iter2, [\freq:66.midicps]); // F#
Synth.new(\iter2, [\freq:73.midicps]); // C#
Synth.new(\iter2, [\freq:80.midicps]); // G#
Synth.new(\iter2, [\freq:75.midicps]); // D#
)

// we can use do for this as well, but is not reccommended since it's not efficient.
// we risk to loose "sample accuracy"
(
[66, 73, 80, 75].do{
	arg midinote;
	Synth.new(\iter2, [\freq:midinote.midicps]);
}
)

// what we can do is to create a "stack of partials" with a fundamental of 'freq'
// we integrate the iteration counto INTO the audio mmanipulation
(
SynthDef.new(\iter3, {
	arg freq = 200;
	var temp, sum;
	sum = 0;
	10.do {
		arg count;
		temp = SinOsc.ar(freq * (count+1));
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)
x = Synth.new(\iter3);
// there is already a Uge for this: Blip
x = { Blip.ar(200, 10, 0.05) }.play;

// we can create a unique sound by changing the frequencies as we want,
(
SynthDef.new(\iter4, {
	arg freq = 200;
	var temp, sum;
	sum = 0;
	10.do {
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			// for example adding some noise to each frequency, and expading to 2 different channels
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(0.98, 1.02.reciprocal)
		);
		// we can also add variation to the amplitude
		temp = temp* LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)
x = Synth.new(\iter4);
x.set(\freq, 40);


// NOTE: arguments are always of Control type (also an UGen)
// even when passing or definig a default as an integer like
// `arg num=10;
// the compiler actually converts it to num = Control(10).
// this means you cannot iterate over it (in the above example to replace the 10.do{} ),
// since it is not a collection




// ***************************
// *** Server Architecture ***
// ***************************
// ep.7

// Creating an architecture of Oscillator reproducing and processing audio

// Fundamental concepts:

// Nodes -> [Synth, Group]
// Busses -> they pass signals between synths.
// Order of Exxecution -> Order of the nodes on the server

(
SynthDef.new(\blip, {
	arg out; // bus index. always useful. especially since this wont likely be the final output.
	var freq, trig, sig;
	// sound with a freq that jumps randomly between the first 4 partials of the 300Hz fundamental
	freq = LFNoise1.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	// transform soundwave in short blips
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	// expand the signal (pan) to stereo using this intrinsic ugen
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig); // use the bus index
}).add;

SynthDef(\reverb, {
	arg in, out = 0; // default to 0 since we want to hear this sound
	var sig;
	sig = In.ar(in, 2); // uses inut from a bus `in`. must be stereo (2 channels).
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2; //expand to stereo
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\reverb, [\in, 6]);
y = Synth.new(\blip, [\out, 6]);

x.set(\out, 25);
y.set(\in, 25);


// BUS

// In prev example We don't wannt to hardcode the channels (eg: 6 or 25). We can use the Bus object
// and we can store it in a global var.
// s is the server
// 2 is the amount of channels needed. if more than 1, reverBus will actually store an ARRAY of Bus,
// since one Bus is always 1 per channel.
~reverbBus = Bus.audio(s, 2);
~reverbBus.index; // will give the index of the first free bus
// the bus will take care of not using the hardware reserved ones nor any already occupied private one)
x = Synth.new(\reverb, [\in, ~reverbBus.index]);
y = Synth.new(\blip, [\out, ~reverbBus.index]);
// or shorter
x = Synth.new(\reverb, [\in, ~reverbBus]);
y = Synth.new(\blip, [\out, ~reverbBus]);


// ORDER OF EXECUTION

// if ewe swap the order of the synth, no sound is heard!!
y = Synth.new(\blip, [\out, ~reverbBus]);
x = Synth.new(\reverb, [\in, ~reverbBus]);
// the synth are exxecuted in reverse order so the last added is the first in the pipeline
// in this case the reverb would be first, but has no input from the blip, which is executed right after.
// see the
s.plotTree;


// GROUPS

// group of synth or groups

// when instantiating a synth, if no TARGET (3rd param) is passed it will be added
// to the default GROUP (gray square in plotTree)
Synth.new(\blip, nil, nil).add;
// passing the seever also will automatically add the synth to the default group
y = Synth.new(\blip, [\out, ~reverbBus], s);
// the last param 'addAction' tells where to add the synth in the group. we can chang the default \addToHead with
x = Synth.new(\reverb, [\in, ~reverbBus], s, \addToTail);
// now the ordedr we add them does not matter
// even better we can use \addAfter to add the synth after the passed sound source \reverb
x = Synth.new(\reverb, [\in, ~reverbBus], s, \addAfter);


// we can use groups to group sources and effect so that we guarantee he order
~sourceGroup = Group.new;
~fxGroup = Group.after(~sourceGroup);
y = Synth.new(\blip, [\out, ~reverbBus], ~sourceGroup);
x = Synth.new(\reverb, [\in, ~reverbBus], ~fxGroup);

// set on the group will relay the message to all the contained nodes
~aGroup.set(\freq, 20); // won't work, just example



// ***************
// *** BUFFERS ***
// ***************
// ep.8

// used for recorded sounds

// sc file path. see https://stackoverflow.com/a/18938315/691977
p = thisProcess.nowExecutingPath.dirname;
// +/+ is an operator. makes sure paths are concatenatedd correctly.
p = p +/+ "samples/M1F1-int32-AFsp.aif";
~b0 = Buffer.read(s, p);
~b0.play;

// buffer attributes
(
x = {
var numFrames, numChannels, samples;

numFrames = ~b0.numFrames;
numChannels = ~b0.numChannels;

samples = numFrames * numChannels;
};
)
x.value();

~b0.duration;
~b0.sampleRate;

// bufnums -> unique int id of the buffer. automatically assigned
~b0.bufnum;


~b0.zero; // resets the buffer
~b0.read(s, audioFilePath); // we can reuse it still
~b0.free; // deallocates
// or
Buffer.freeAll;



// *************
// *** UTILS ***
// *************

// *** ACTIONS *** //

// starts the server // shorthand for Server.local.boot. The local server is stored in the s variable
s.boot;

s.reboot;


// deallocating
x.free
s.freeAll;
s.quit;


// *** PARAMETERS *** //

// num of available channels
s.options.numAudioBusChannels; //eg 1024

// reserved channels for hardware in/out
s.options.numOutputBusChannels; // typically 2 for stereo (or 8 for dolby). so channel 0 and 1 are for output
s.options.numInputBusChannels; // typically 2 (8 for dolby). so channel 2 and 3 are for input.
// 4 to 1023 are private busses. free to use for utils.

// these values can also be overriden:
s.options.numInputBusChannels = 8; // for example if we have an audio interface. must reboot the server after.


// *** DEBUG *** //

// shows the audio levels for current channels
s.meter;

//shows currently active Synths
s.plotTree;










