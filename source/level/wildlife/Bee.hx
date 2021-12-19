package level.wildlife;

class Bee extends Butterfly {
	override public function new(X, Y, radius) {
		super(X, Y, radius);
		steerSpeed *= 1.5;
		assetPath = AssetPaths.bees_sized__png;
		tileWidth = 35;
		tileHeight = 35;
		flapFps = 12;
		loadGraphic(AssetPaths.bees_sized__png, true, tileWidth, tileHeight);
		animation.add("flap", [0, 1], flapFps, true);

		var scaleFactor = 0.7;
		this.scale.set(scaleFactor, scaleFactor);
		this.updateHitbox();
		speeds = [100, 85, 70];
		this.speed = speeds[0];

		var velocityVector:FlxVector = FlxVector.get(1, 1);
		velocityVector.length = speeds[0];
		maxVelocity.x = Math.abs(velocityVector.x);
		maxVelocity.y = Math.abs(velocityVector.y);
		velocityVector.degrees = Random.float(0, 360);
		velocity.x = velocityVector.x;
		velocity.y = velocityVector.y;
		velocityVector.put();
	}
}
