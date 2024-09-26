// ************************
// *** COMPOSITION pt.1 ***
// ************************
//ep. 15


// bandpass-filter saw-tooth wave synth
(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;
	// to shape amp of sound during time
	env = EnvGen.kr(Env([0,1,1,0], [atk,sus,rel], [c1,0,c2]), doneAction: 2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)

Synth(\bpfsaw);


// to create a more interesting sound we use iteration
(
[58, 65, 68, 73].midicps.do{
	arg f;
	Synth(
		\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
			\cf, f* exprand(1,12),
			\rq, exprand(0.01, 0.5),
		]
	)
}
)

// we can also use scale. a full list is available here
Scale.directory;

(
(1..6).choose.do{ // choose a random value between 1 and 6
	arg f;
	Synth(
		\bpfsaw,
		[
			// degrees return an array from Scale object
			// 60 is to play a phrigian in C (6 0midi = 4C), convert to hz and choose a random value
			\freq, (Scale.phrygian.degrees+60).midicps.choose.postln,
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5),
		]
	)
};
)


// Improving the synth



// bandpass-filter saw-tooth wave synth
(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, detune=0.2,  cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0], [atk,sus,rel], [c1,0,c2]), doneAction: 2);
	// de-tuning the root frequency, so to give characcter to the wave
	sig = Saw.ar(freq * LFNoise1.kr(0.5, detune).midiratio);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)

Synth(\bpfsaw);

// This synth can be further elaborate to the following one
// NOTE: explanation is between minute ~10.00 and 20.00 of https://www.youtube.com/watch?v=lGs7JOOVjag&ab_channel=EliFieldsteel
(
SynthDef(\bpfsaw2, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, detune=0.2, pan=0,
	cfhzmin=0.1, cfhzmax=0.3, cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
	lsf=200, ldb=0, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{
			LFNoise1.kr(
				LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
			).exprange(cfmin, cfmax)
		}!2,
		{
			LFNoise1.kr(0.1).exprange(rqmin, rqmax)
		}!2
	);
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

// more complex pattern based on \bpfsaw2
(
Pbind(
	\instrument, \bpfsaw2,
	\dur, 2,
	// sequence of notes
	\midinote, Pseq([54, 61, 56], 1),
	\detune, 0.08,
	\cfmin, 100,
	\cfmax, 1500,
	\atk, 1,
	\ldb, 6,
	\amp, 0.2,
	\out, 0
).play;
)

// more complex pattern based on \bpfsaw2 with chords
(
~chords = Pbind(
	\instrument, \bpfsaw2,
	\dur, 5,
	// sequence of CHORDS (array of array)
	\midinote, Pxrand([ // random from collection without repeating
		[23, 35, 54, 63, 64],
		[45, 52, 54, 59, 61, 64],
		[28, 40, 47, 56, 59, 63],
		[42, 52, 57, 61, 63],
	], inf), // with inf we convert all the parameters to a non-finite pattern. so we keep a reference to the Pbind to stop it.
	\detune, 0.08,
	\cfmin, 100,
	\cfmax, 1500,
	\atk, 2,
	\rel, 8,
	\ldb, 6,
	\amp, 0.2,
	\out, 0
).play;
)

// more complex pattern based on \bpfsaw2 with chords
(
~chords = Pbind(
	\instrument, \bpfsaw2,
	\dur, Pwhite(4.5, 7.0, inf),
	// sequence of CHORDS (array of array)
	\midinote, Pxrand([ // random from collection without repeating
		[23, 35, 54, 63, 64],
		[45, 52, 54, 59, 61, 64],
		[28, 40, 47, 56, 59, 63],
		[42, 52, 57, 61, 63],
	], inf), // with inf we convert all the parameters to a non-finite pattern. so we keep a reference to the Pbind to stop it.
	\detune, Pexprand(0.05, 0.2, inf),
	\cfmin, 20,
	\cfmax, 400,
	\rqmin, Pexprand(0.01, 0.15, inf),
	\atk, Pwhite(2.0, 2.5, inf),
	\rel, Pwhite(6.5, 10.0, inf),
	\ldb, 6,
	\amp, 0.2,
	\out, 0
).play;
)

// we can use the same synth to generate completely different sounds
(
Synth.new(
	\bpfsaw2,
	[
		\freq, 128, // -> try gradulaly going down till 1/2/4, under 20Hz, when rythm become pitch
		\atk, 0,
	]
);
)

// we can use this to gene
(
~marimba = Pbind(
	\instrument, \bpfsaw2,
	\dur, Prand([1, 0.5], inf),
	\freq, Prand([1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
	\detune, Pwhite(0, 0.1, inf),
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5, 1, 2, 4], inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008, 1,025, inf),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 0.2,
	\out, 0,
).play;
)


// ************************
// *** COMPOSITION pt.2 ***
// ************************
// ep.16
// https://www.youtube.com/watch?v=oR4VZy2LJ60&ab_channel=EliFieldsteel



// *** utils ***

s.boot;
s.reboot;
s.meter;
s.plotTree;

s.quit;