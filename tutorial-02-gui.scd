// ***********
// *** GUI ***
// ***********
//ep. 14

s.boot;
s.quit;

w = Window.new;
// w.alwaysOnTop = true;
// all variables have a builder function version which returns self, so one can concatenate functions.
// see "Syntax Shortcut" with CMD+D
w.alwaysOnTop_(true);

GUI.current;
w.bounds; // reference frame: BOTTOM-left


// creates a new window
(

Window.closeAll;
w = Window.new(
	"A GUI!",
	Rect.new(
		Window.screenBounds.width -500, 200, // positions it bottm right
		400, 400 // squared size
	)
);
w.front;
w.alwaysOnTop_(true);

// no need for "new"
~slider = Slider(w.view, Rect.new(20, 20, 150, 30)); // reference frame for view is TOP-left
~slider.action_({
	arg val;
	("Slider value changed"+val.value).postln;
});

// styling
~slider.background_(Color(1, 0.5, 0))
//.background_(Color.magenta(0.5)); // standard colors provided. function interpolate with black
.knobColor_(Color(1, 0.5, 0))
.thumbSize_(40);
)

// lists all child views
w.view.children;

~slider.enabled_(true);

~slider.value = 0.5; // will not execute action
// we can set the value AND perform the connected action (see the console)
~slider.valueAction_(0.2);


// *************************************************
// *** CONNECTING GUI AND AUDIO + VIEWS SHOWCASE ***
// *************************************************


(
// simple band pass filter
SynthDef.new(\simplebpf, {
	arg freq=400, rq=0.2; // rq is the "quality" of the filter
	var sig;
	sig = PinkNoise.ar(1!2);
	// lag interpolates the signal to avoid pops sounds when the slider jumps
	// tpp much and the sound lags. too little and the sound pops
	sig = BPF.ar(
		sig,
		freq.lag(0.5),
		rq.lag(0.5), // quality of the filter.  >is this the "size" of thebandwidth of the filter?<
		1/rq.sqrt.lag(0.5)); // incorporate rq in the mul, since chning the filters changes the amp, this compensates.
	Out.ar(0, sig);
}).add;

// the gui
Window.closeAll;
w = Window("Band Pass Filter", Rect(Window.screenBounds.width -500, 200, 440, 600), false)
.front
.alwaysOnTop_(true);

~accentColor = Color(1, 0.5, 0);
~font = Font("San Francisco");

// slider for the filter frequency parameter
~slider = Slider(w, Rect(20, 20, 150, 30))
.background_(~accentColor)
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0, 1, 100, 4000).postln;
	if (
		x.isPlaying, // thanks to register (see Synth.register in button.active_ ) we can observe the node (synth) state
		{ x.set(\freq, cf); } // here we change the synthdef. safely without errors thanks to the guard
	);
	// note it is not calling .valueAction_() not to have the slider and numBox actions call eachother infinitely
	~numberBox.value_(obj.value.linexp(0, 1, 100, 4000));
});

~freqLabel = StaticText(w, Rect(20, 50, 150, 30))
.string_("Frequency")
.font_(~font, 14)
.align_(\left);

// label for the frequency
~numberBox = NumberBox(w,  Rect(190, 20, 80, 30))
.value_(100) // same initial value of slider
.clipLo_(100)
.clipHi_(4000)
.font_(~font, 16)
.decimals_(2)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(100, 4000, 0, 1));
});

// knob for the filter quality parameter
~knob = Knob(w,  Rect(290, 20, 30, 30))
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0, 1, 1, 100).reciprocal;
	if (
		x.isPlaying,
		{ x.set(\rq, qual); }
	)
});

~button = Button(w, Rect(340, 20, 80, 30))
.states_([ // we can have N states. each a member of an array
	["Disabled", Color.black, Color.gray(0.8)], // each state is another array, state, foregraound, bg color
	["Enabled", Color.black, ~accentColor]
])
.font_(~font, 18)
.action_({
	arg obj;
	if (
		obj.value == 1, // condition
		{ // true
			// start sound
			x = Synth.new(\simplebpf, [
				// initializes the synth with the initial value of gui elements
				\freq, ~slider.value.linexp(0, 1, 100, 4000),
				\rq, ~knob.value.linexp(0, 1, 1, 100)
			])
			// register with NodeWatcher so we can check in the action if the synth is playing to avoid errors
			.register;
		},
		{ // false
			x.free;
		}
	)
});


// *** other commonly used GUI elements ***

PopUpMenu(w, Rect(20, 90, 120, 30))
.items_(["", "one", "two", "three"]);

RangeSlider(w, Rect(20, 140, 120, 30));

MultiSliderView(w, Rect(160, 140, 120, 80))
.size_(9);

TextField(w, Rect(20, 190, 120, 30));

TextView(w, Rect(20, 240, 120, 120));

Slider2D(w, Rect(160, 240, 120, 120));


~soundFileView = SoundFileView(w, Rect(20, 400, 400, 60));
~soundFile = SoundFile.new;
~soundFile .openRead(thisProcess.nowExecutingPath.dirname +/+ "samples/M1F1-int32-AFsp.aif");
~soundFile .inspect;
~soundFileView.soundfile = ~soundFile;
~soundFileView.read(0, ~soundFile.numFrames);
~soundFileView.timeCursorOn = true;
~soundFileView.timeCursorColor = Color.red;
~soundFileView.timeCursorPosition = 2050;
~soundFileView.drawsWaveForm = true;
~soundFileView.gridOn = true;
~soundFileView.gridResolution = 0.2;


LevelIndicator(w, Rect(20, 480, 10, 60))
.value = 0.2;
LevelIndicator(w, Rect(50, 480, 10, 60))
.value = 0.9;
LevelIndicator(w, Rect(80, 480, 10, 60))
.value = 0.7;

)




// *****************************
// *** DECORATOR: FlowLayout ***
// *****************************

(
Window.closeAll;

w = Window("Flow Layout", Rect(Window.screenBounds.width -500, 200, 400, 400))
.front
.alwaysOnTop_(true);


/*w.view.decorator_(FlowLayout(
	w.bounds, // bounds
	Point(20, 20), // margins
	Point(10, 10) // spacing
));*/
// or faster
w.view.decorator_(FlowLayout(w.bounds, 20@20, 10@10 ));

Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 80@80);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);
Knob(w, 40@40);

// force new line
w.view.decorator.nextLine;
w.view.decorator.nextLine;
20.do{ Knob(w, 40@40) };


// iteration
w.view.children.collect(_.value_(rrand(0.0, 1.0)));

)

// if elements are removed with
w.view.children.collect(_.remove);
// then then next added objects will continue from the last position.
Knob(w, 40@40);
//to reset to the beginning:
w.view.decorator.reset;
Knob(w, 40@40);



// ********************
// *** NESTED VIEWS ***
// ********************

// CompositeView is a continer for group of views
(
Window.closeAll;
w = Window("CompositeView", Rect(750, 50, 500, 500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(4, {
	arg view;
	view = CompositeView(w, 200@200)
	.background_(Color.rand);

	view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
});

Array.fill(5, {Slider(c[0], 30@150)});
Array.fill(8, {Knob(c[1], 40@40)});
)
c[0].children[2].value_(0.5);
c[1].children.collect(_.value_(0.75));



~slider.remove;
w.close;
Window.closeAll;
















