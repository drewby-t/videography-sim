package level.wildlife;

class Butterfly extends FlxSprite {
	var perlinLength = 100;
	var perlinX:BitmapData;

	// var perlinY:BitmapData;
	var speed:Float = 40;
	var steerSpeed:Float = 450;

	var speeds = [50, 35, 20];

	var currentPerlinIndex = 0;

	var startX:Float = 0;
	var startY:Float = 0;

	var radius = 0;

	var followPerlin = true;

	var justFlipped = false;

	var assetPath:String = AssetPaths.butterflies_sized__png;
	var tileWidth:Int = 40;
	var tileHeight:Int = 40;

	var flapFps:Float = 4;

	public function new(startX, startY, radius) {
		super(startX, startY);
		this.radius = radius;
		this.startX = startX;
		this.startY = startY;
		loadGraphic(assetPath, true, tileWidth, tileHeight);
		animation.add("flap", [0, 1], flapFps, true);

		// start flapping at random interval so butterflies dont all flap at the same time
		new FlxTimer().start(Random.float(0, 0.5), (_) -> {
			animation.play("flap");
		});

		perlinX = new BitmapData(perlinLength, perlinLength, false, 0xffffffff);
		// perlinY = new BitmapData(perlinLength, perlinLength, false, 0xffffffff);
		perlinX.perlinNoise(100, 1, 4, Random.int(0, 999999), true, false, 7, true);
		// perlinY.perlinNoise(100, 1, 2, Random.int(0, 999999), true, true, 7, true);

		var velocityVector:FlxVector = FlxVector.get(1, 1);
		velocityVector.length = speeds[0];
		maxVelocity.x = Math.abs(velocityVector.x);
		maxVelocity.y = Math.abs(velocityVector.y);
		velocityVector.degrees = Random.float(0, 360);
		velocity.x = velocityVector.x;
		velocity.y = velocityVector.y;
		velocityVector.put();

		elasticity = 1;

		// height = 100;

		startSpeedTween();
	}

	public function startSpeedTween(tween:FlxTween = null) {
		new FlxTimer().start(Random.float(1, 2), (_) -> {
			var newSpeed:Float = speed;
			while (newSpeed == speed) {
				// get a random speed from speeds
				newSpeed = speeds[Random.int(0, speeds.length - 1)];
			}
			FlxTween.tween(this, {speed: speed}, Random.float(2, 4), {onComplete: startSpeedTween});
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		currentPerlinIndex++;
		if (currentPerlinIndex >= perlinLength * perlinLength) {
			currentPerlinIndex = 0;
		}

		// perlin index as 2d array coords
		var xIndex = currentPerlinIndex % perlinLength;
		var yIndex = Math.floor(currentPerlinIndex / perlinLength);

		var colorX = FlxColor.fromInt(perlinX.getPixel32(xIndex, yIndex));

		var velocityVector:FlxVector = FlxVector.get(velocity.x, velocity.y);
		velocityVector.degrees += Globals.Utils.rerange(colorX.lightness, 0, 1, -1, 1) * steerSpeed * elapsed;
		if (velocityVector.length > maxVelocity.x) {
			velocityVector.length = maxVelocity.x;
		}
		if (isTooFarAwayFromStart()) {
			followPerlin = false;
		}

		if (!followPerlin) {
			var vectorToStart:FlxVector = FlxVector.get(startX - x, startY - y);
			velocityVector.degrees = vectorToStart.degrees;
			vectorToStart.put();
			if (this.distFromStart() < radius * 0.66) {
				followPerlin = true;
			}
		}

		velocity.x = velocityVector.x;
		velocity.y = velocityVector.y;
		// FlxMath.lerp(angle, Globals.Utils.normalizeAngle(velocityVector.degrees), 0.1);
		// this.angle = Globals.Utils.normalizeAngle(velocityVector.degrees - 45 - 180);
		velocityVector.put();
		if (!justFlipped) {
			if (velocity.x > 0) {
				this.flipX = true;
				justFlipped = true;
			}
			if (velocity.x < 0) {
				this.flipX = false;
				justFlipped = true;
			}
		}
		else {
			justFlipped = false;
		}
	}

	public function isTooFarAwayFromStart():Bool {
		var distance = FlxVector.get(startX, startY);
		distance.subtract(x, y);
		var result = distance.length > radius;
		distance.put();
		return result;
	}

	public function distFromStart():Float {
		var distance = FlxVector.get(startX, startY);
		distance.subtract(x, y);
		return distance.length;
	}
}
