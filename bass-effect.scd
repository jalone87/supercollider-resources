// PLUG YOUR HEADPHONE! LOWER THE VOLUME!

// *** INIT ***

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

// 2. initialize global vairables ----

~out = 0;
~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath++"samples/";

~accentColor = Color(1, 0.5, 0);
~font = Font("San Francisco");


// 3. define piece-specific functions ---

// automatically deactivate midi notes on CMD+.
//CmdPeriod.add({(0..127).do{arg n; if(m.isNil.not, m.noteOff(0, n));};});

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
	~delBus = Bus.audio(s, 2);
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	s.bind({
		~micGrp = Group.new;
		~delGrp = Group.after(~micGrp);

		// dry sound bypassing effects
		~micSynthDirect = Synth(\audioin, [\in, 0, \out, ~out0], ~micGrp);
		// effects
		~micSynthEffect = Synth(\audioin, [\in, 0, \out, ~delBus], ~micGrp);

		6.do({
			Synth(\delay, [
				\in, ~delBus,
				\out, ~out0,
				\mix, 1, // we already have a dry signal
				\amp, 1/20,
				\delHz, exprand(0.02, 0.08),
				\delMin, exprand(0.05, 0.1),
				\delMax, exprand(0.101, 0.2),
				\decay, rrand(3.0, 6.0),
			], ~delGrp);
		});
	});
};

~makeEvents = {
};


// 4. register functions with ServerBoot/Quit/Tree ---

ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);


// 5. boot server ---

s.waitForBoot({

	s.sync;

	// 6.a register SynthDefs

	SynthDef.new(\audioin, {
		arg in=0, out=0, amp=1;
		var sig;
		sig = SoundIn.ar(in!2) * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\delay, {
		arg in=0, out=0, mix=(-0.5), decay=3, amp=1, delHz=0.25, delMin=0.1, delMax=0.4;
		var sig, delay;
		sig = In.ar(in, 2) * amp; // read from arbitrary bus, using In.ar
		delay = CombL.ar(
			sig,
			0.5,
			//SinOsc.kr([0.32, 0.3]).exprange(0.1, 0.4),
			// we can also add some more flexibility
			SinOsc.kr([delHz, delHz*0.9]).exprange(delMin, delMax),
			decay
		);
		sig = XFade2.ar(sig, delay, mix);
		Out.ar(out, sig);
	}).add;

	s.sync;

	// 6.b register remaining functions

	ServerTree.add(~makeNodes);
	ServerTree.add(~makeEvents);
	s.freeAll;

	s.sync;

	s.meter;
	s.plotTree;
	s.scope;

	"READY".postln;

});



// *** 7. GUI ***

w = Window("Bass Effect", Rect(Window.screenBounds.width -500, 200, 440, 600), false)
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 20@20, 10@10 ));

~reverbLabel = StaticText(w, Rect(20, 50, 150, 30))
.string_("BEWARE YOUR EARS !!!")
.font_(~font, 20)
.align_(\left);

w.view.decorator.nextLine;

~reverbLabel = StaticText(w, Rect(20, 50, 150, 30))
.string_("Reverb")
.font_(~font, 14)
.align_(\left);


~reverbButton = Button(w, Rect(340, 20, 80, 30))
.states_([
	["Disabled", Color.black, Color.gray(0.8)],
	["Enabled", Color.black, ~accentColor]
])
.font_(~font, 18)
.action_({
	arg obj;
	~delGrp.set(\amp, obj.value);
//	if (
//		obj.value == 1, // condition
//		{ // true
//			x = Synth.new(\simplebpf, [
//				\freq, ~slider.value.linexp(0, 1, 100, 4000),
//				\rq, ~knob.value.linexp(0, 1, 1, 100)
//			])
//			.register;
//		},
//		{ // false
//			~delGrp.set(\amp, 0);
//		}
//	)
})
.valueAction_(0);

~slider = Slider(w, Rect(20, 20, 150, 30))
.background_(~accentColor)
.action_({
	arg obj;
	~delGrp.set(\amp, obj.value);

	if(obj.value > 0, {
		~reverbButton.value = 1;
	}, {
		~reverbButton.value = 0;
	})
/*	var cf;
	cf = obj.value.linexp(0, 1, 100, 4000).postln;
	if (
		x.isPlaying, // thanks to register (see Synth.register in button.active_ ) we can observe the node (synth) state
		{ x.set(\freq, cf); } // here we change the synthdef. safely without errors thanks to the guard
	);
	// note it is not calling .valueAction_() not to have the slider and numBox actions call eachother infinitely
	~numberBox.value_(obj.value.linexp(0, 1, 100, 4000));*/
});

)

// *** INIT ***

/*(
SynthDef.new(\audioin, {
	arg in=0, out=0, deltime=0.3, mix=(-0.5), decay=3, amp=1;
	var sig, delay;
	sig = SoundIn.ar(in!2) * amp;
	// DELAY
	// params, signal, max delay time (how much memory allocated), actua delay (must be less than max)
	// delay = DelayL.ar(sig, 0.5, deltime);
	// ECHO
	// to have an echo, we can use similarly CombL that feeds into itself
	delay = CombL.ar(sig, 0.5, deltime, decay);
	// XFade2 does an "equal power crossfade", a bit better than just summing the signals
	sig = XFade2.ar(sig, delay, mix);
	Out.ar(out, sig);
}).add;
)




// REVERB + PITCH SHIFT
// we can use multiple delays
(
~micGrp = Group.new;
~delGrp = Group.after(~micGrp);

// dry sound bypassing delay
~micSynthDirect = Synth(\audioin, [\in, 0, \out, ~out0], ~micGrp);
// this goes to processing
~micSynthEffect = Synth(\audioin, [\in, 0, \out, ~delBus], ~micGrp);
)
(
20.do({
	Synth(\delay, [
		\in, ~delBus,
		\out, ~out0,
		\mix, 1, // we already have a dry signal
		\amp, 1/20,
		\delHz, exprand(0.02, 0.08),
		\delMin, exprand(0.05, 0.1),
		\delMax, exprand(0.101, 0.2),
		\decay, rrand(3.0, 6.0),
	], ~delGrp);
});
)*/

// - note: we hould use a low pass filter to avoid high pitches sss sounds

// - note: we should use an envelope to more gently close the synth

// - note: that DelayL family ugens allocates dinamically memory,
//         going up with delays amount this will very quickly fill up the memsize of the server

// *** utils ***

s.boot;
s.reboot;

s.quit;

thisProcess.nowExecutingPath;














