package;

import file.save.FileSave;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import gif.Gif;
import hscript.Bytes;
import level.Level;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import record.VideoRecorder;
import ui.ParkSignInput;

class PlayState extends FlxState {
	var viewFinder:Viewfinder;
	var recordingDot:FlxSprite;

	var viewFinderWidth = 200.0;
	var viewFinderHeight = 150.0;
	var viewFinderBoderColor = FlxColor.CYAN;
	var viewFinderBorerSize = 4;

	var videoRecorder:VideoRecorder;

	var percentFull:Int = 0;
	var percentFullText:FlxText;

	var level:Level;

	var player:Player;

	var signInputBox:ParkSignInput;

	override public function create() {
		super.create();

		viewFinderWidth *= 1.15;
		viewFinderHeight *= 1.15;

		FlxG.mouse.visible = false;

		// trace if we are using tile or blit render mode
		trace("Using render mode: " + FlxG.renderMethod);

		D.init();

		Globals.cameras.mainCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		Globals.cameras.mainCam.useBgAlphaBlending = true;
		Globals.cameras.mainCam.bgColor = 0xFF80af5a;
		Globals.cameras.mainCam.bgColor = 0xFF328665;
		Globals.cameras.mainCam.antialiasing = true;

		Globals.cameras.ghostCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		Globals.cameras.ghostCam.useBgAlphaBlending = true;
		Globals.cameras.ghostCam.bgColor = FlxColor.TRANSPARENT;
		Globals.cameras.ghostCam.antialiasing = true;

		Globals.cameras.uiCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		Globals.cameras.uiCam.bgColor = FlxColor.TRANSPARENT;
		Globals.cameras.uiCam.useBgAlphaBlending = true;
		Globals.cameras.uiCam.antialiasing = true;

		// Globals.cameras.mainCam.pixelPerfectRender = true;
		// Globals.cameras.ghostCam.pixelPerfectRender = true;

		if (Globals.SHOW_GHOSTS) {
			FlxG.cameras.reset(Globals.cameras.mainCam);
			FlxG.cameras.add(Globals.cameras.ghostCam, false);
			FlxG.cameras.add(Globals.cameras.uiCam, false);
		}
		else {
			FlxG.cameras.reset(Globals.cameras.ghostCam);
			FlxG.cameras.add(Globals.cameras.mainCam, true);
			FlxG.cameras.add(Globals.cameras.uiCam, false);
		}

		viewFinder = new Viewfinder(viewFinderWidth, viewFinderHeight);

		var map = new TiledMap(AssetPaths.untitled__tmx);
		player = new Player(viewFinder);
		player.x = map.fullWidth / 2 - player.width / 2;
		player.y = map.fullHeight / 2 - player.height / 2;

		level = new Level(map, player);

		var recordingDotSize = 12;
		recordingDot = new FlxSprite();
		var gfx = new FlxSprite().makeGraphic(recordingDotSize * 2, recordingDotSize, FlxColor.TRANSPARENT);
		recordingDot.loadGraphic(gfx.pixels, true, recordingDotSize, recordingDotSize);
		FlxSpriteUtil.drawCircle(recordingDot, recordingDotSize / 2, recordingDotSize / 2, recordingDotSize / 2.1, FlxColor.RED);
		recordingDot.animation.add("blink", [0, 1], 2.5, true);
		recordingDot.visible = false;

		level.allObjects.add(player);
		player.x = level.playerStart.x;
		player.y = level.playerStart.y;

		Globals.cameras.mainCam.follow(player, TOPDOWN, 0.05);
		Globals.cameras.mainCam.targetOffset.y = -100;
		Globals.cameras.ghostCam.follow(player, TOPDOWN, 0.05);
		Globals.cameras.ghostCam.targetOffset.y = -100;
		Globals.cameras.mainCam.snapToTarget();
		Globals.cameras.ghostCam.snapToTarget();

		signInputBox = new ParkSignInput();
		signInputBox.screenCenter();
		signInputBox.visible = false;
		signInputBox.onSubmit = (lines:Array<String>) -> {
			level.changeableSign.setText(lines);
			signInputBox.hide();
			Globals.playerInputAllowed = true;
		};

		viewFinder.cameras = [Globals.cameras.uiCam];
		viewFinder.viewFinderOverlay.cameras = [Globals.cameras.uiCam];
		recordingDot.cameras = [Globals.cameras.uiCam];
		level.cameras = [Globals.cameras.mainCam];
		level.ghosts.cameras = [Globals.cameras.ghostCam];
		player.cameras = [Globals.cameras.mainCam];
		player.topHalf.cameras = [Globals.cameras.mainCam];
		signInputBox.cameras = [Globals.cameras.uiCam];

		add(level);
		add(viewFinder);
		add(signInputBox);

		videoRecorder = new VideoRecorder(viewFinder);

		percentFullText = new FlxText(0, 0, 100, "0%");
		percentFullText.setFormat(null, 25, 0xffffffff, "left");
		percentFullText.setPosition(30, 30);
		percentFullText.cameras = [Globals.cameras.uiCam];
		add(percentFullText);

		Globals.cameras.mainCam.zoom = 0.68;
		Globals.cameras.ghostCam.zoom = 0.68;

		FlxG.worldBounds.top = -99999;
		FlxG.worldBounds.left = -99999;
		FlxG.worldBounds.bottom = 99999;
		FlxG.worldBounds.right = 99999;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		FlxG.collide(player, level.allColliders);
		FlxG.collide(level.butterflies, level.graves);

		if (Globals.playerInputAllowed) {
			if (FlxG.mouse.justPressed && player.isHoldingCamera) {
				videoRecorder.startRecording();
			}
			if (FlxG.mouse.justReleased) {
				videoRecorder.stopRecording();
			}
			if (FlxG.keys.justPressed.Q) {
				videoRecorder.convertToGif();
			}
			if (FlxG.keys.justPressed.F) {
				FlxG.fullscreen = !FlxG.fullscreen;
			}
			updatePercentText();

			handleZoom();

			playerInput();

			if (FlxG.keys.justPressed.E) {
				if (level.changeableSign != null) {
					trace("we can do it");
					signInputBox.show();
					videoRecorder.stopRecording();
					player.lowerCamera();
					Globals.playerInputAllowed = false;
				}
			}
		}
	}

	function playerInput() {
		var speed = 320;
		var bearing = FlxVector.get(0, 0);
		if (FlxG.keys.anyPressed([UP, W])) {
			bearing.y = -1;
		}
		else if (FlxG.keys.anyPressed([DOWN, S])) {
			bearing.y = 1;
		}
		if (FlxG.keys.anyPressed([LEFT, A])) {
			bearing.x = -1;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D])) {
			bearing.x = 1;
		}

		var playerTopHalfRotationAmount = 4;
		if (!FlxG.keys.anyPressed([UP, DOWN, LEFT, RIGHT, W, A, S, D])) {
			bearing.x = 0;
			bearing.y = 0;
			player.animation.play("idle");
			player.topHalf.angle = 0;
			// player.angle = 0;
		}
		else {
			player.animation.play("walk");
			if (bearing.x != 0) {
				player.topHalf.angle = FlxMath.signOf(bearing.x) * playerTopHalfRotationAmount;
				// player.angle = FlxMath.signOf(bearing.x) * playerTopHalfRotationAmount;
			}
			else {
				player.topHalf.angle = 0;
				// player.angle = 0;
			}
		}

		if (bearing.x > 0) {
			player.flipX = true;
			player.topHalf.flipX = true;
		}
		if (bearing.x < 0) {
			player.flipX = false;
			player.topHalf.flipX = false;
		}

		bearing.length = speed;
		player.velocity.x = bearing.x;
		player.velocity.y = bearing.y;
		bearing.put();

		if (FlxG.keys.justPressed.SPACE) {
			if (player.isHoldingCamera) {
				player.lowerCamera();
				videoRecorder.stopRecording();
			}
			else {
				player.raiseCamera();
			}
		}
	}

	function handleZoom() {
		var maxZoom = 0.86;
		var minZoom = 0.58;

		var zoomStep = 0.01;
		if (FlxG.mouse.wheel != 0) {
			Globals.cameras.mainCam.zoom += FlxMath.signOf(FlxG.mouse.wheel) * zoomStep;
			Globals.cameras.ghostCam.zoom += FlxMath.signOf(FlxG.mouse.wheel) * zoomStep;
			if (Globals.cameras.mainCam.zoom >= maxZoom) {
				Globals.cameras.mainCam.zoom = maxZoom;
				Globals.cameras.ghostCam.zoom = maxZoom;
			}
			if (Globals.cameras.mainCam.zoom <= minZoom) {
				Globals.cameras.mainCam.zoom = minZoom;
				Globals.cameras.ghostCam.zoom = minZoom;
			}
		}
	}

	function updatePercentText() {
		var newPercentFull = Std.int(videoRecorder.getPercentFull() * 100);
		if (newPercentFull != percentFull) {
			percentFull = newPercentFull;
			percentFullText.text = percentFull + "%";
		}
	}
}

class VideoSprite extends FlxSprite {
	var borderWidth = 8;
	var borderColor = FlxColor.GRAY;

	public var video:FlxSprite;

	override public function new(buffer:Array<BitmapData>, fps:Float) {
		super();
		this.makeGraphic(buffer[0].width + borderWidth * 2, buffer[0].height + borderWidth * 2, borderColor);
		video = new FlxSprite();
		var videoSpriteSheet = combineArrayOFBitmapDataIntoSpriteSheet(buffer);
		trace(videoSpriteSheet.width, videoSpriteSheet.height);
		video.loadGraphic(videoSpriteSheet, true, buffer[0].width, buffer[0].height);
		video.animation.add("play", [for (i in 0...Std.int(fps / 2)) 0].concat([for (i in 0...buffer.length) i]), fps, true);
		video.animation.play("play");
	}

	public static function arrayTo2dArray(array, maxItemsPerRow:Int = 10) {
		var result = [];
		var row = [];
		var rowCount = 0;
		for (i in 0...array.length) {
			row.push(array[i]);
			rowCount++;
			if (rowCount == maxItemsPerRow) {
				result.push(row);
				row = [];
				rowCount = 0;
			}
		}
		return result;
	}

	public static function combineArrayOFBitmapDataIntoSpriteSheet(fames:Array<BitmapData>):BitmapData {
		var sheet2d = arrayTo2dArray(fames, 10);
		var sheet = new BitmapData(sheet2d[0].length * sheet2d[0][0].width, sheet2d.length * sheet2d[0][0].height, true, 0x00000000);

		for (i in 0...sheet2d.length) {
			for (j in 0...sheet2d[i].length) {
				sheet.copyPixels(sheet2d[i][j], sheet2d[i][j].rect, new openfl.geom.Point(j * sheet2d[i][j].width, i * sheet2d[i][j].height));
			}
		}

		return sheet;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		video.update(elapsed);
		video.x = this.x + this.width / 2 - video.width / 2;
		video.y = this.y + this.height / 2 - video.height / 2;
	}

	override function draw() {
		super.draw();
		video.draw();
	}
}

class PhotoSprite extends FlxSprite {
	var borderWidth = 5;
	var borderColor = FlxColor.GRAY;

	override public function new(screenShot:BitmapData) {
		super();
		this.makeGraphic(screenShot.width + borderWidth * 2, screenShot.height + borderWidth * 2, borderColor);
		this.pixels.copyPixels(screenShot, screenShot.rect, new openfl.geom.Point(borderWidth, borderWidth));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
