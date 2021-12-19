package;

class Viewfinder extends FlxSprite {
	public var viewFinderOverlay:FlxSprite;

	var overlayOffset = FlxPoint.get(6, 9);

	override public function new(viewFinderWidth, viewFinderHeight) {
		super();
		var finderCol = FlxColor.CYAN;
		finderCol.alphaFloat = 0.2;
		finderCol.saturation *= 0.6;

		makeGraphic(Std.int(viewFinderWidth), Std.int(viewFinderHeight), finderCol);

		drawCorners();

		viewFinderOverlay = new FlxSprite();
		viewFinderOverlay.loadGraphic(AssetPaths.viewfinder_sized__png);
		viewFinderOverlay.scale.set(0.77, 0.77);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (x > FlxG.width - width) {
			x = FlxG.width - width;
		}
		if (y > FlxG.height - height) {
			y = FlxG.height - height;
		}
		if (x < 0) {
			x = 0;
		}
		if (y < 0) {
			y = 0;
		}
		viewFinderOverlay.x = this.x + this.width / 2 - viewFinderOverlay.width / 2;
		viewFinderOverlay.y = this.y + this.height / 2 - viewFinderOverlay.height / 2;
		viewFinderOverlay.x += overlayOffset.x;
		viewFinderOverlay.y += overlayOffset.y;

		// handleZoom();
		// if (FlxG.keys.justPressed.G) {
		// 	trace("scale: " + viewFinderOverlay.scale.x);
		// }
	}

	function drawCorners() {
		var viewFinderWidth = this.width;
		var viewFinderHeight = this.height;
		var paddingX = 15;
		var paddingY = 15;
		var cornerLineLength = viewFinderWidth * 0.12;
		var strokeThickness = 2;
		var strokeColor = FlxColor.WHITE;
		var strokeAlpha = 0.7;
		strokeColor.alphaFloat = strokeAlpha;
		FlxSpriteUtil.drawLine(this, paddingX, paddingY, paddingX + cornerLineLength, paddingY, {
			thickness: strokeThickness,
			color: strokeColor,
		});
		FlxSpriteUtil.drawLine(this, paddingX, paddingY, paddingX, paddingY + cornerLineLength, {
			thickness: strokeThickness,
			color: strokeColor,
		});
		FlxSpriteUtil.drawLine(this, paddingX, viewFinderHeight - paddingY, paddingX + cornerLineLength, viewFinderHeight - paddingY, {
			thickness: strokeThickness,
			color: strokeColor,
		});
		FlxSpriteUtil.drawLine(this, paddingX, viewFinderHeight - paddingY, paddingX, viewFinderHeight - paddingY - cornerLineLength, {
			thickness: strokeThickness,
			color: strokeColor,
		});

		FlxSpriteUtil.drawLine(this, viewFinderWidth - paddingX, paddingY, viewFinderWidth - paddingX - cornerLineLength, paddingY, {
			thickness: strokeThickness,
			color: strokeColor,
		});
		FlxSpriteUtil.drawLine(this, viewFinderWidth - paddingX, paddingY, viewFinderWidth - paddingX, paddingY + cornerLineLength, {
			thickness: strokeThickness,
			color: strokeColor,
		});
		FlxSpriteUtil.drawLine(this, viewFinderWidth
			- paddingX, viewFinderHeight
			- paddingY, viewFinderWidth
			- paddingX
			- cornerLineLength,
			viewFinderHeight
			- paddingY, {
				thickness: strokeThickness,
				color: strokeColor,
			});
		FlxSpriteUtil.drawLine(this, viewFinderWidth
			- paddingX, viewFinderHeight
			- paddingY, viewFinderWidth
			- paddingX,
			viewFinderHeight
			- paddingY
			- cornerLineLength, {
				thickness: strokeThickness,
				color: strokeColor,
			});
	}

	override function draw() {
		super.draw();
		if (viewFinderOverlay.visible) {
			viewFinderOverlay.draw();
		}
	}

	function handleZoom() {
		var maxZoom = 3;
		var minZoom = 0.1;
		var zoomStep = 0.01;
		if (FlxG.mouse.wheel != 0) {
			viewFinderOverlay.scale.x += FlxMath.signOf(FlxG.mouse.wheel) * zoomStep;
			viewFinderOverlay.scale.y += FlxMath.signOf(FlxG.mouse.wheel) * zoomStep;
		}
	}

	public function hide() {
		this.visible = false;
		this.viewFinderOverlay.visible = false;
	}

	public function show() {
		this.visible = true;
		this.viewFinderOverlay.visible = true;
	}
}
