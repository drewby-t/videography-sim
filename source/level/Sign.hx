package level;

class Sign extends FlxSprite {
	var lines:Array<Array<LetterTile>> = [];

	var letterSpacing:Float = 3;
	var lineSpacing:Float = 7;

	var signStart = FlxPoint.get(69, 99);
	var signSize = FlxPoint.get(265, 113);

	public var midpoint:FlxPoint = FlxPoint.get();

	override public function new(X, Y, startText:Array<String>) {
		super(X, Y);

		setText(startText);
		this.x += offset.x;
		this.y += offset.y;

		solid = true;
		immovable = true;
		// this.pixelPerfectRender = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		getMidpoint(midpoint);
	}

	override function draw() {
		super.draw();
	}

	function getLineWidth(line:Array<LetterTile>):Float {
		var width = 0.0;
		for (i in 0...line.length) {
			width += line[i].width;
			if (i != line.length - 1) {
				width += letterSpacing;
			}
		}
		return width;
	}

	function getLineHeight(line:Array<LetterTile>) {
		var height = 0.0;
		for (i in 0...line.length) {
			height = Math.max(height, line[i].height);
		}
		return height;
	}

	public function setText(linesToChangeTo:Array<String>) {
		lines = [];
		loadGraphic(AssetPaths.signboard__png, false, 0, 0, true);

		this.height = frameHeight * 0.15;
		this.width = frameWidth * 0.9;
		centerOffsets();
		offset.y = frameHeight - this.height - 20;

		midpoint = getMidpoint();

		for (line in linesToChangeTo) {
			var newLine = [];
			for (c in 0...line.length) {
				var char = line.charAt(c);
				var letter = new LetterTile(0, 0, char, this);
				// add(letter);
				newLine.push(letter);
			}
			lines.push(newLine);
		}

		for (lineIndex in 0...lines.length) {
			var line = lines[lineIndex];
			var lineY = signStart.y + (lineSpacing + getLineHeight(line)) * lineIndex;
			var lineX = signStart.x + signSize.x / 2 - getLineWidth(line) / 2;

			for (tileIndex in 0...lines[lineIndex].length) {
				var letter = lines[lineIndex][tileIndex];
				var letterX = lineX + (letterSpacing + letter.width) * tileIndex;
				letter.relativeX = Std.int(letterX);
				letter.relativeY = Std.int(lineY);
				trace(letter.char, letterX, lineY);
				// letter.pixelPerfectRender = true;
			}
		}

		// stamp all letter tiles at their relative positions
		for (lineIndex in 0...lines.length) {
			var line = lines[lineIndex];
			for (tileIndex in 0...lines[lineIndex].length) {
				var letter = lines[lineIndex][tileIndex];
				this.stamp(letter, Std.int(letter.relativeX), Std.int(letter.relativeY));
			}
		}
	}
}

class LetterTile extends FlxSprite {
	public var char(default, null):String;
	public var relativeX(default, default):Float;
	public var relativeY(default, default):Float;

	var parent:FlxSprite;

	override public function new(X, Y, letter:String, parent:FlxSprite) {
		super(X, Y);
		letter = letter.toUpperCase();
		this.char = letter;
		this.parent = parent;
		loadGraphic(AssetPaths.letterframe__png, false, 0, 0, true);
		if (StringTools.trim(letter).length != 0) {
			var letter_tile_text:FlxText = new FlxText(0, 0, width, letter);
			letter_tile_text.setFormat(null, 16, FlxColor.BLACK, "center");
			letter_tile_text.drawFrame(true);
			this.stamp(letter_tile_text, 1, 5);
		}
		else {
			this.makeGraphic(frameWidth, frameHeight, FlxColor.TRANSPARENT);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		this.x = parent.x + relativeX;
		this.y = parent.y + relativeY;
	}
}
