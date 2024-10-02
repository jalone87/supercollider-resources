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







// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;






















