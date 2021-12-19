package record;

import flixel.util.FlxBitmapDataUtil;
import gif.Gif;
import openfl.display.Bitmap;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

class VideoRecorder extends FlxBasic {
	var recordTimer:FlxTimer;
	var recordFps = 14;

	var scaleFactor:Float = 2;
	var skipFactor:Int = 2;

	var maxSeconds:Float = 30;
	var maxFrames:Int = -1;

	var tape:Tape;

	public var viewFinder:FlxSprite;

	var gif:Gif;

	override public function new(viewFinder:FlxSprite) {
		super();
		maxFrames = Std.int(maxSeconds * recordFps);
		this.viewFinder = viewFinder;

		trace("max Frames", maxFrames);

		this.tape = new Tape(maxFrames);
	}

	function recordFrame() {
		// trace("recordFrame");

		var frame = getViewfinderBitmap();
		var scaledUpFrame:BitmapData = new BitmapData(Std.int(frame.width * scaleFactor), Std.int(frame.height * scaleFactor), true, 0x00000000);
		var m:Matrix = new Matrix();
		m.scale(scaleFactor, scaleFactor);
		scaledUpFrame.draw(frame, m, null, null, null, true);
		tape.addFrameToCurrentRecording(scaledUpFrame);

		// check if we should stop recording because we reached the max frames
		if (tape.getTotalFrames() >= maxFrames) {
			stopRecording();
			endTape();
		}
	}

	public function startRecording() {
		if (tape.isComplete) {
			return; // Don't record if the tape is already complete
		}
		if (recordTimer != null && recordTimer.active) {
			return; // Don't record if we're already recording
		}
		trace("startRecording");
		recordTimer = new FlxTimer().start(1 / recordFps, (_) -> {
			recordFrame();
		}, 0);
	}

	public function stopRecording() {
		if (recordTimer == null) {
			return; // Don't stop if we're not recording
		}
		if (recordTimer != null && !recordTimer.active) {
			return; // don't stop if we are not recording
		}
		trace("stopRecording");
		recordTimer.cancel();
		recordTimer = null;
		tape.endCurrentRecording();
	}

	function endTape() {
		tape.isComplete = true;
	}

	function getViewfinderBitmap():BitmapData {
		var screenShot:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
		var screenGhost:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
		var mat = new Matrix();
		mat.translate(FlxG.width / 2, FlxG.height / 2);

		// var canvasX = -0.5 * Globals.cameras.mainCam.width * (Globals.cameras.mainCam.scaleX - Globals.cameras.mainCam.initialZoom) * FlxG.scaleMode.scale.x;
		// var canvasY = -0.5 * Globals.cameras.mainCam.height * (Globals.cameras.mainCam.scaleY - Globals.cameras.mainCam.initialZoom) * FlxG.scaleMode.scale.y;

		// mat.scale(Globals.cameras.mainCam.zoom, Globals.cameras.mainCam.zoom);
		// mat.translate(canvasX, canvasY);

		@:privateAccess
		screenShot.draw(Globals.cameras.mainCam.flashSprite, mat);
		screenShot.draw(Globals.cameras.ghostCam.flashSprite, mat);

		// var b:Bitmap = new Bitmap(screenShot);

		// var s = new FlxSprite(0, 0, screenShot);
		// s.cameras = [Globals.cameras.uiCam];
		// FlxG.state.add(s);

		var photo:BitmapData = new BitmapData(Std.int(viewFinder.width), Std.int(viewFinder.height), true, FlxColor.TRANSPARENT);
		photo.copyPixels(screenShot, new openfl.geom.Rectangle(viewFinder.x, viewFinder.y, viewFinder.width, viewFinder.height), new openfl.geom.Point(0, 0));
		photo.copyPixels(screenGhost, new openfl.geom.Rectangle(viewFinder.x, viewFinder.y, viewFinder.width, viewFinder.height), new openfl.geom.Point(0, 0),
			null, null, true);
		return photo;
	}

	public function convertToGif() {
		gif = new Gif(Std.int(viewFinder.width * scaleFactor), Std.int(viewFinder.height * scaleFactor), skipFactor / recordFps, -1, 100, skipFactor);

		var frames = tape.getAllFrames();
		for (frame in frames) {
			gif.addFrame(frame);
		}

		gif.save("export.gif");
	}

	public function getPercentFull():Float {
		return tape.getPercentFull();
	}
}

class Tape {
	public var recordings:Array<Recording> = [];

	public var isComplete:Bool = false;

	public var maxFrames:Float = -1;

	public function new(maxFrames:Int) {
		this.maxFrames = maxFrames;
	}

	public function addRecording(recording:Recording) {
		recordings.push(recording);
	}

	public function endCurrentRecording() {
		addRecording(new Recording());
	}

	public function addFrameToCurrentRecording(frame:BitmapData) {
		if (recordings.length == 0) {
			addRecording(new Recording());
		}
		recordings[recordings.length - 1].addFrame(frame);
	}

	function getDurationInSeconds(fps:Float):Float {
		var duration:Float = 0;
		for (i in 0...recordings.length) {
			duration += recordings[i].getDurationInSeconds(fps);
		}
		return duration;
	}

	public function getTotalFrames() {
		var totalFrames = 0;
		for (r in recordings) {
			totalFrames += r.frames.length;
		}
		return totalFrames;
	}

	public function getAllFrames():Array<BitmapData> {
		var frames:Array<BitmapData> = [];
		for (r in recordings) {
			frames = frames.concat(r.frames);
		}
		return frames;
	}

	public function getPercentFull():Float {
		var percent = cast(getTotalFrames(), Float) / maxFrames;
		return percent;
	}
}

class Recording {
	public var frames:Array<BitmapData> = [];

	public function new() {}

	public function addFrame(frame:BitmapData) {
		frames.push(frame);
	}

	public function getDurationInSeconds(fps:Float) {
		return frames.length / fps;
	}
}
