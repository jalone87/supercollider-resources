
// ****************
// *** PATTERNS ***
// ****************
//ep.10


(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction: 2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 400, inf).trace,
	\atk, Pwhite(2.0, 3.0),
	\rel, Pwhite(5.0, 10.0),
	\amp, Pexprand(0.005, 0.05),
	\pan, Pwhite(-0.8, 0.8),
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(800, 1600, inf).trace,
	\atk, Pwhite(1.0, 2.0),
	\rel, Pwhite(3.0, 5.0),
	\amp, Pexprand(0.005, 0.02),
	\pan, Pwhite(-0.8, 0.8),
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(1600, 3200, inf).trace,
	\atk, Pwhite(0.5, 1.0),
	\rel, Pwhite(2.0, 2.5),
	\amp, Pexprand(0.005, 0.02),
	\pan, Pwhite(-0.8, 0.8),
).play;
)