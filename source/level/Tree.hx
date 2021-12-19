package level;

class Tree extends FlxNestedSprite {
	override public function new(X, Y) {
		super(X, Y);
		this.loadGraphic(AssetPaths.tree_a_sized__png);
		this.flipX = Random.bool();

		// this.color = Random.fromArray([
		// 	FlxColor.ORANGE.getLightened(Random.float(0.5, 0.9)),
		// 	FlxColor.BLUE.getLightened(Random.float(0.8, 1.0)),
		// 	FlxColor.WHITE
		// ]);

		this.height = 70;
		this.width = 70;
		this.centerOffsets();
		this.offset.y = this.frameHeight - height - 40;
		this.offset.x -= 15;
		x += offset.x;
		y += offset.y;

		immovable = true;
		solid = true;
	}
}
