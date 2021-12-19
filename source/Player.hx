package;

class Player extends FlxSprite {
	public var midpoint:FlxPoint = FlxPoint.get();
	public var viewFinderMidpoint:FlxPoint = FlxPoint.get();

	var maxViewPortDistance:Float = 350;
	var squashX = 0.5;

	var viewFinder:Viewfinder;

	public var topHalf:FlxSprite;

	public var isHoldingCamera:Bool = false;

	public var helpText:FlxText;

	public function new(viewFinder:Viewfinder) {
		super();

		this.viewFinder = viewFinder;
		loadGraphic(AssetPaths.cameradude_bottom_sheet__png, true, 160, 300);
		animation.add("walk", [1, 2, 3, 4], 6, true);
		animation.add("idle", [0], 5, true);
		animation.play("idle");
		height = 15;
		width *= 0.4;
		centerOffsets();
		offset.y = frameHeight - height - 15;

		solid = true;

		topHalf = new FlxSprite();
		topHalf.loadGraphic(AssetPaths.cameradude_top_sheet__png, true, 160, 300);
		topHalf.animation.add("down", [0], 4, true);
		topHalf.animation.add("up", [1], 4, true);
		topHalf.height = 15;
		topHalf.width *= 0.4;
		topHalf.centerOffsets();
		topHalf.offset.y = topHalf.frameHeight - topHalf.height - 15;

		topHalf.origin.y = topHalf.frameHeight / 2 - 8;
		this.origin.y = this.frameHeight - 8;

		lowerCamera();
	}

	public function raiseCamera() {
		topHalf.animation.play("up");
		isHoldingCamera = true;
		viewFinder.show();
	}

	public function lowerCamera() {
		topHalf.animation.play("down");
		isHoldingCamera = false;
		viewFinder.hide();
	}

	public function showHelpText(text:String) {
		if (helpText == null) {
			helpText = new FlxText(0, 0, frameWidth * 1.5, text);
			helpText.setFormat(null, 16, FlxColor.WHITE, "center");
			update(0);
		}
		helpText.cameras = [Globals.cameras.uiCam];
		helpText.text = text;
		helpText.visible = true;
	}

	public function hideHelpText() {
		if (helpText != null) {
			helpText.visible = false;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (helpText != null) {
			helpText.update(elapsed);
			var playerScreenPos = getScreenPosition(null, Globals.cameras.mainCam).add(this.width / 2, this.height / 2);
			playerScreenPos.x *= Globals.cameras.mainCam.zoom;
			playerScreenPos.y *= Globals.cameras.mainCam.zoom;
			// helpText.x = playerScreenPos.x + this.width * Globals.cameras.mainCam.zoom / 2 - helpText.width * Globals.cameras.mainCam.zoom / 2;
			helpText.x = playerScreenPos.x;
			helpText.y = playerScreenPos.y + 115;
			playerScreenPos.put();
		}

		topHalf.x = x;
		topHalf.y = y + 2;

		var mouseInUiCam = FlxG.mouse.getPositionInCameraView(Globals.cameras.uiCam);
		viewFinder.x = mouseInUiCam.x;
		viewFinder.y = mouseInUiCam.y;

		mouseInUiCam.put();
		viewFinder.getMidpoint(viewFinderMidpoint);
		this.getScreenPosition(midpoint, Globals.cameras.mainCam);
		midpoint.x += Globals.cameras.mainCam.zoom * this.width / 2;
		midpoint.y += Globals.cameras.mainCam.zoom * this.height / 2 - offset.y + frameHeight / 2; // center around actual midpoint
		// checkViewportPosition();

		mouseInUiCam.put();
	}

	override function draw() {
		super.draw();
		topHalf.draw();
		if (helpText != null && helpText.visible) {
			helpText.draw();
		}
	}

	public function checkViewportPosition() {
		var vectorFromPlayerToViewFinder:FlxVector = FlxVector.get(viewFinderMidpoint.x - midpoint.x, viewFinderMidpoint.y - midpoint.y);
		var distance:Float = vectorFromPlayerToViewFinder.length;
		if (distance > maxViewPortDistance) {
			vectorFromPlayerToViewFinder.length = maxViewPortDistance;
			viewFinder.x = midpoint.x + vectorFromPlayerToViewFinder.x - viewFinder.width / 2;
			viewFinder.y = midpoint.y + vectorFromPlayerToViewFinder.y - viewFinder.height / 2;
		}
	}
}
