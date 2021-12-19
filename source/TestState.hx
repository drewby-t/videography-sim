package;

class TestState extends FlxState {
	var dataFromFile:Dynamic;

	override function create() {
		super.create();

		var s = new FlxSprite();
		s.makeGraphic(100, 100, 0xffffffff);
		s.color = FlxColor.fromRGB(240, 214, 117, 255);

		s.screenCenter();
		add(s);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
