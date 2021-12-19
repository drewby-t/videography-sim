package level;

class Pond extends FlxNestedSprite {
	override public function new(X, Y) {
		super(X, Y);
		loadGraphic(AssetPaths.pond_sized__png);
	}
}
