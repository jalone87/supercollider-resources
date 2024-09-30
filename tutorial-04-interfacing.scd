// *******************
// *** MIDI OUTPUT ***
// *******************
//ep. 18



// enable MIDI Client
// 1. in macos open "Audio MIDI Setup"
// 2. Window -> Midi Studio -> Double click on "IAC Driver" -> check "Device is Online"

// 3. reboot midi
MIDIClient.init;

MIDIClient.destinations; // array of MIDIEndPoint
m = MIDIOut.new(0); // - pass the index of MIDIClient.destinations for the wanted MIDIEndPoint

// note: when using garageband, no need to start SC sever

// params: channel, midi note, how fast you press the key == amp [1-127] (0 is off)
m.latency = 0; // default is 0.2
m.noteOn(0, 60, 30);
m.noteOff(0, 60, 100);

(
r = Routine({
	{
		[35, 49, 56, 63, 66, 73].do{
			arg nn;
			m.noteOn(0, nn, 25);
			0.1.wait;
			m.noteOff(0, nn, 25);
			0.2.wait;
		};
	}.loop ;
}).play;
)

r.stop;

// we must stop all notes, but the `m.stopAll` won't work on all platforms. Better implpement yourself:
(0..127).do{arg n; m.noteOff(0, n);};

// it is possible to hook this to CMD+. hotkey to have it done automatically:
CmdPeriod.add({(0..127).do{arg n; m.noteOff(0, n);};});
// CmdPeriod.add({(0..100).do{arg n; m.control(0, n, 100);};});
CmdPeriod.objects;
CmdPeriod.remove(CmdPeriod.objects[2])

// *** CONTINUOUS CONTROLLER MSG ***

// or cntrl msg or CC message
// a what is generated when a knob or a fade is moved in the device

// channel, control num, value
m.noteOn(0, 60, 100);
m.control(0, 1, 100); // eg in garage band with midi-test.nammd this is the vibrato effect
m.control(0, 1, 0);
// some are defined in midi specs, other are custom for specific DAWs or plugins / receivers


// check https://rfwilmut.net/notes/GBcontrol.html for some examples controls for GarBa
// but garage band is really bad for mapping midi controls
// the following are working
// CC 1 (Modulation Wheel) -> Tremolo (Electric Piano)
// CC 7 (Channel Volume) -> Channel Volume
// CC 10 (Pan)-> Pan (Channel)

// examples
(
r = Routine({
	{
		m.noteOn(0, 30, 60);
		(30, 40..100).do{
			arg val;
			m.control(0, 1, val.postln);
			0.3.wait;
		}
	}.loop;
}).play;
)
// check https://youtu.be/ih2uqOaqb4c?t=1065 for a cooler example.
// sadly it only works with FM8 (native instruments' plugin for logic)


// we can use Patterns, Pb  ind in particular, to generate
// more live/realtime friendly and complex tunes




// *** utils ***

s.boot;
s.reboot;
s.meter;
s.plotTree;

s.quit;

thisProcess.nowExecutingPath;














