(
s.quit;
Window.closeAll;

s = Server.local;

ServerOptions.devices; // find the one you want and copy in the next lines
s.options.outDevice_("External Headphones"); // "LG UltraFine Display Audio"
s.options.numOutputBusChannels_(2);
s.options.inDevice_("LG UltraFine Display Audio");
s.options.numInputBusChannels_(2);

s.options.sampleRate_(44100);//(44100);//(48000);//(nil);//
s.options.memSize; // default 8.192KB
s.options.memSize_(2.pow(18)); // around 262 MB
s.newBusAllocators;

ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;


// 2. initialize global vairables ----

~out = 0; // very useful when changing interfaces with multiple outputs
~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath++"samples/";


// 3. define piece-specific functions ---

// automatically deactivate midi notes on CMD+.
CmdPeriod.add({(0..127).do{arg n; m.noteOff(0, n);};});

// function to read sound buffers from a folder
~makeBuffers = {
	b = Dictionary.new;
	PathName(~samplesPath).entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};

~makeBusses = {
	~bus = Dictionary.new;
	// ~bus.add(\reverb -> Bus.audio(s,2));
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	s.bind({
		~mainGrp = Group.new;
		// other groups, for example a reverb
/*		~revverbGrp = Group.new;
		~reverbSynth = Synth.new(
			\reverb,
			[
				\amp, 1,
				\predelay, 0.1,
				//...
			]
		);*/
	});
};

~makeEvents = {
	e = Dictionary.new;
	e.add(\event1 -> {"event1".postln;});
	e.add(\event2 -> {"event2".postln;});
	e.add(\event3 -> {"event3".postln;});

	MIDIdef.cc(\controller, {nil});
};


// 4. register functions with ServerBoot/Quit/Tree ---

ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);


// 5. boot server ---

s.waitForBoot({

	s.sync;

	// 6.a register SynthDefs

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

	s.sync;

	// 6.b register remaining functions

	ServerTree.add(~makeNodes);
	ServerTree.add(~makeEvents);
	s.freeAll;

	s.sync;

	"READY".postln;

});

)


// *** utils ***

s.boot;
s.reboot;
s.meter;
s.plotTree;

s.quit;

thisProcess.nowExecutingPath;
