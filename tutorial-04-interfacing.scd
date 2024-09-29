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
	}.loop;
}).play;
)

r.stop;

// *** utils ***

s.boot;
s.reboot;
s.meter;
s.plotTree;

s.quit;

thisProcess.nowExecutingPath;
