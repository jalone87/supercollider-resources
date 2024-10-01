// ********************
// *** FM SYNTHESIS ***
// ********************
//ep. 21



// PLUG YOUR HEADPHONE! LOWER THE VOLUME!

(
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

s.boot;
s.meter;
s.plotTree;
)



// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;














