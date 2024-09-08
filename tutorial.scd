// *** Followign from Eli Fieldsteel - Supercollider Tutorial
// *** https://www.youtube.com/watch?v=yRzsOOiJ_p4&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC


// starts the server // shorthand for Server.local.boot. The local server is stored in the s variable
s.boot;



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





//shows currently active Synths
s.plotTree;

x.free
s.freeAll;
s.quit;










