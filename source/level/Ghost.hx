package level;

import flixel.graphics.FlxGraphic;
import openfl.display.Bitmap;
import openfl.geom.ColorTransform;

class Ghost extends FlxNestedSprite {
	public static var tileWidth:Int = 184;
	public static var tileHeight:Int = 324;

	public static var ghostVisibility:Float = 0.5;

	var floatTween:FlxTween;
	var floatDist:Float = 20;
	var floatFrequency:Float = 1.5;

	var floatDelay:Float = Random.float(0.1, 0.5);
	var floaties:FlxTypedGroup<GhostFloatie>;

	override public function new(X, Y, ghostType) {
		super(X, Y);

		this.loadGraphic(Globals.Utils.getColorModifiedBitmapData(AssetPaths.will_o_wisp_sized__png, Ghost.ghostVisibility, FlxColor.WHITE), true, tileWidth,
			tileHeight);
		animation.frameIndex = ghostType;
		this.flipX = Random.bool();

		// this.alpha = 0.5;

		if (!Std.isOfType(this, GhostFloatie)) {
			this.scale.set(0.5, 0.5);
			this.updateHitbox();

			this.height *= 0.4;
			this.width *= 0.6;
			this.centerOffsets();
			// this.offset.y = this.frameHeight - height - 40;
			x += offset.x;
			y += offset.y;

			immovable = true;
			solid = true;

			new FlxTimer().start(floatDelay, (_) -> {
				floatTween = FlxTween.tween(this, {y: y - floatDist}, floatFrequency, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
			});
		}

		floaties = new FlxTypedGroup<GhostFloatie>();

		if (Std.isOfType(this, GhostFloatie)) {
			return;
		}
		var f1 = new GhostFloatie(x - 60, y + Random.float(20, 40), 0, Random.float(0.0, 0.15));
		var f2 = new GhostFloatie(x + width, y + Random.float(30, 50), 1, Random.float(0.9, 1.2));
		floaties.add(f1);
		floaties.add(f2);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (floaties.cameras != cameras) {
			floaties.cameras = cameras;
		}

		floaties.update(elapsed);
	}

	override function draw() {
		floaties.draw();
		super.draw();
	}
}

class GhostFloatie extends Ghost {
	public static var tileWidth:Int = 99;
	public static var tileHeight:Int = 99;

	override public function new(X, Y, floatieType, delay) {
		super(X, Y, 0);

		this.loadGraphic(Globals.Utils.getColorModifiedBitmapData(AssetPaths.ghost_floaties_sized__png, Ghost.ghostVisibility, FlxColor.WHITE), true,
			tileWidth, tileHeight);
		animation.frameIndex = floatieType;
		this.flipX = Random.bool();

		var scaleFactor = Random.float(0.4, 0.55);
		this.scale.set(scaleFactor, scaleFactor);
		this.updateHitbox();

		immovable = true;
		solid = true;

		angularVelocity = Random.float(20, 40);
		floatDist = Random.int(60, 100);
		floatFrequency = 3.5;
		floatDelay = delay;

		new FlxTimer().start(floatDelay, (_) -> {
			floatTween = FlxTween.tween(this, {y: y - floatDist}, floatFrequency, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
		});
	}
}
