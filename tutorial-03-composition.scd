// *******************
// *** COMPOSITION ***
// *******************
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


// *** utils ***

s.boot;
s.reboot;
s.meter;
s.plotTree;

s.quit;