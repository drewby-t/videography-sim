package level;

class Grave extends FlxNestedSprite {
	public static var tileWidth:Int = 0;
	public static var tileHeight:Int = 0;

	override public function new(X, Y, graveType:Int) {
		super(X, Y);
		this.loadGraphic(AssetPaths.graves_sized__png, true, tileWidth, tileHeight);
		animation.frameIndex = graveType;
		// this.flipX = Random.bool();

		this.height *= 0.16;
		this.width *= 0.6;
		this.centerOffsets();
		this.offset.y = this.frameHeight - height - 18;
		x += offset.x + 18; // for some reason i add this bit or things arent centered
		y += offset.y;

		immovable = true;
		solid = true;
	}
}
