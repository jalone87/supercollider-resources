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

// params: channel, midi note, how fast you press the key == amp [1-127] (0 is off)
m.noteOn(0, 60, 30);
m.noteOff(0, 60, 100);


// *** utils ***

s.boot;
s.reboot;
s.meter;
s.plotTree;

s.quit;

thisProcess.nowExecutingPath;
