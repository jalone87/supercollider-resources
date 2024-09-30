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

// ring modulation: takes frequency components in the spectrum and shifts them around
(
x.free;
x = {
	var sig, rmod;
	sig = SoundIn.ar(0!2);
	rmod = sig * SinOsc.ar(700);
	(sig + rmod) * 0.3;
}.play;
)


// remember that in the bus first come the outputs [0,1] and then the inputs [2,(3)]
(
x = {
	var.sig;
	sig = In.ar(2!2); // bus 2, sine 01 and 1 are for output
	Out.ar(0, sig); // bus 0 and 1 automatically. remember this line can also be omitted
}.play;
)




// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;














