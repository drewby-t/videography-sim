package level.wildlife;

enum DuckState {
	SWIMMING;
	STOPPED;
}

class Duck extends FlxSprite {
	public var midpoint(default, null):FlxPoint = FlxPoint.get();

	public var thrust:Float = 0;

	var maxThrust:Float = 55;
	var friction:Float = 0.976;
	var thrustTween:FlxTween;

	var pondPoints:Array<FlxPoint> = [
		FlxPoint.get(754, 149),
		FlxPoint.get(526, 74),
		FlxPoint.get(139, 190),
		FlxPoint.get(218, 281),
		FlxPoint.get(416, 165),
		FlxPoint.get(416, 188),
	];

	var swimPointsOn = true;

	var targetPointIndex:Int = 0;

	var state:DuckState = DuckState.STOPPED;

	public var pond:Pond;

	var pointSprites:Array<FlxSprite> = [];

	var bobTween:FlxTween;
	var bobOffset:Float = 0;
	var bobOffsetMax = 4;

	override public function new(pond:Pond) {
		super();

		this.pond = pond;

		this.loadGraphic(AssetPaths.duck_sized__png);

		this.height = Std.int(height * 0.25);
		this.width = Std.int(width * 0.5);
		centerOffsets();
		this.offset.y = frameHeight - height - 12;

		pondPoints = pondPoints.map(point -> {
			return point.add(pond.x, pond.y);
		});

		for (p in pondPoints) {
			var pointSprite:FlxSprite = new FlxSprite(p.x, p.y);
			pointSprite.makeGraphic(2, 2, FlxColor.RED);
			pointSprite.visible = false;
			pointSprites.push(pointSprite);
		}

		var randomStartIndex = Random.int(0, pondPoints.length - 1);
		setPositionByMidpoint(pondPoints[randomStartIndex].x, pondPoints[randomStartIndex].y);
		var currentIndex = randomStartIndex;
		targetPointIndex = currentIndex;
		while (currentIndex == targetPointIndex) {
			targetPointIndex = Random.int(0, pondPoints.length - 1);
		}
		setState(DuckState.SWIMMING);

		bobTween = FlxTween.tween(this, {bobOffset: bobOffsetMax}, 1, {
			ease: FlxEase.quadInOut,
			type: PINGPONG,
			startDelay: Random.float(0, 0.5)
		});
		getMidpoint(midpoint);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		getMidpoint(midpoint);

		if (swimPointsOn) {
			if (state == DuckState.SWIMMING) {
				var targetPoint:FlxPoint = pondPoints[targetPointIndex];
				if (thrustTween == null) {
					thrustTween = FlxTween.tween(this, {thrust: maxThrust}, 2, {ease: FlxEase.quadIn}); // start tween if swimming and no thrust
				}
				if (midpoint.distanceTo(targetPoint) < 32) {
					setState(DuckState.STOPPED);
					thrust = 0;
					if (thrustTween != null) {
						thrustTween.cancel();
					}

					new FlxTimer().start(Random.float(4, 10), (_) -> {
						var currentIndex = targetPointIndex;
						while (currentIndex == targetPointIndex) {
							targetPointIndex = Random.int(0, pondPoints.length - 1);
						}
						setState(DuckState.SWIMMING);
						if (thrustTween != null) {
							thrustTween.cancel();
						}
						thrustTween = FlxTween.tween(this, {thrust: maxThrust}, 2, {ease: FlxEase.quadIn});
					});
				}
				else {
					accelerateTwoards(targetPoint);
				}
			}
			else if (state == DuckState.STOPPED) {
				acceleration.x = 0;
				acceleration.y = 0;
				velocity.x *= friction;
				velocity.y *= friction;
			}
		}
	}

	override public function draw() {
		var oldY = y;
		this.y = oldY + bobOffset;
		super.draw();
		this.y = oldY;
	}

	function setState(state:DuckState) {
		// trace("setState: " + state);
		this.state = state;
	}

	function accelerateTwoards(point:FlxPoint) {
		var targetPoint:FlxPoint = point;
		var vectorFromMidpointToTarget:FlxVector = FlxVector.get(targetPoint.x - midpoint.x, targetPoint.y - midpoint.y);
		vectorFromMidpointToTarget.length = thrust;
		velocity.x = vectorFromMidpointToTarget.x;
		velocity.y = vectorFromMidpointToTarget.y;
		vectorFromMidpointToTarget.put();

		if (velocity.x > 0) {
			this.flipX = true;
		}
		else {
			this.flipX = false;
		}
	}

	public function setPositionByMidpoint(X:Float, Y:Float) {
		this.x = X - this.width / 2;
		this.y = Y - this.height / 2;
	}
}
