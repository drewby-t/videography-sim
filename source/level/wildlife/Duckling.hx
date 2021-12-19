package level.wildlife;

import level.wildlife.Duck.DuckState;

class Duckling extends Duck {
	public var maxDistanceToParent:Float = 80;

	public var parent:Duck;

	var targetPoint:FlxPoint;
	var target:FlxSprite;

	override public function new(parent:Duck, tint:FlxColor = FlxColor.WHITE) {
		super(parent.pond);

		this.parent = parent;

		this.loadGraphic(Globals.Utils.getColorModifiedBitmapData(AssetPaths.duckling_sized__png, 1, tint));

		this.height = Std.int(frameHeight * 0.4);
		this.width = Std.int(frameWidth * 0.5);
		centerOffsets();
		this.offset.y = frameHeight - height - 8;

		setState(DuckState.SWIMMING);

		thrust = parent.maxThrust * 0.72;
		friction = 0.98;
		swimPointsOn = false;

		target = new FlxSprite(0, 0);
		target.makeGraphic(4, 4, FlxColor.RED);
		getMidpoint(midpoint);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		getMidpoint(midpoint);

		if (midpoint.distanceTo(parent.midpoint) > maxDistanceToParent) {
			setState(DuckState.SWIMMING);
		}
		else {
			setState(DuckState.STOPPED);
		}

		if (state == DuckState.SWIMMING) {
			accelerateTwoards(parent.midpoint);
		}
		else if (state == DuckState.STOPPED) {
			acceleration.x = 0;
			acceleration.y = 0;

			velocity.x *= friction;
			velocity.y *= friction;
		}

		target.x = parent.midpoint.x - target.width / 2;
		target.y = parent.midpoint.y - target.height / 2;
	}

	override function draw() {
		super.draw();
		// target.draw();
	}
}
