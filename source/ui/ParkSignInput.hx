package ui;

import djFlixel.D;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import level.Sign;

class ParkSignInput extends FlxUIGroup {
	var bg:FlxUISprite;

	var titleText:FlxUIText;

	var numLines:Int = 3;
	var maxLineLength:Int = 8;
	var lineInputs:Array<SimpleTextInput> = [];
	var currentLine:Int = 0;

	var submitText:FlxUIText;
	var isSumbitted:Bool = false;

	public var onSubmit:Array<String>->Void;

	var lastText = "";

	public var sign:Sign;

	override public function new() {
		super();
		bg = new FlxUISprite();
		bg.makeGraphic(400, 300, FlxColor.BROWN.getDarkened(0.3));
		FlxSpriteUtil.drawRect(bg, 1, 1, bg.frameWidth - 2, bg.frameHeight - 2, FlxColor.TRANSPARENT, {thickness: 2, color: FlxColor.BROWN.getDarkened(0.3)});

		titleText = new FlxUIText(0, 0, bg.width * 0.9, "Change Sign Text", 23);
		titleText.alignment = FlxTextAlign.CENTER;
		// titleText.font = AssetPaths.Ubuntu_Bold__ttf;
		titleText.color = FlxColor.WHITE;
		D.align.XAxis(titleText, bg);
		D.align.YAxis(titleText, bg, "t", 16);

		for (i in 0...numLines) {
			var t = new FlxText(0, 0, Std.int(bg.width * 0.7), "", 24);
			// t.font = AssetPaths.Ubuntu_Medium__ttf;
			t.color = FlxColor.BLACK;
			t.alignment = FlxTextAlign.CENTER;
			var lineInput = new SimpleTextInput(t, FlxColor.WHITE, 5, 5);
			lineInput.maxLength = maxLineLength;
			lineInputs.push(lineInput);
		}

		// lineInputs[currentLine].hasFocus = true;

		var lineSpacing = 10;
		// place each line in a vertical column with spacing = lineSpacing
		for (i in 0...numLines) {
			var line = lineInputs[i];
			line.x = bg.width * 0.5 - line.width * 0.5;
			line.y = 20 + titleText.x + titleText.height + i * (line.height + lineSpacing);
		}

		add(bg);
		add(titleText);
		for (line in lineInputs) {
			add(line);
		}
	}

	function trySubmit() {
		if (isSumbitted) {
			return;
		}
		onSubmit(lineInputs.map(li -> {
			return li.textBox.text;
		}));
		isSumbitted = true;
	}

	public function show() {
		visible = true;
		isSumbitted = false;
		for (line in lineInputs) {
			line.hasFocus = false;
			line.textBox.text = "";
			if (line.textBox.text.length == 0) {
				line.textBox.visible = false;
			}
			else {
				line.textBox.visible = true;
			}
		}
		lineInputs[0].hasFocus = true;
	}

	public function hide() {
		currentLine = 0;
		visible = false;
		for (line in lineInputs) {
			line.hasFocus = false;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!visible) {
			return;
		}
		for (line in lineInputs) {
			if (line.textBox.text.length == 0) {
				line.textBox.visible = false;
			}
			else {
				line.textBox.visible = true;
			}
		}

		if (FlxG.keys.pressed.ANY && !FlxG.keys.pressed.BACKSPACE && currentLineInputHasReachedCharLimit()) {
			if (currentLine < numLines - 1) {
				goToNextLine();
			}
		}
		if (FlxG.keys.justPressed.ENTER) {
			if (currentLine == numLines - 1) {
				trySubmit();
			}
			else {
				goToNextLine();
			}
		}
		if (FlxG.keys.pressed.BACKSPACE) {
			if (currentLineHasNoText()) {
				if (currentLine > 0) {
					goToPreviousLine();
				}
			}
		}
	}

	function goToNextLine() {
		currentLine++;
		lineInputs[currentLine].hasFocus = true;
		lineInputs[currentLine - 1].hasFocus = false;
	}

	function goToPreviousLine() {
		currentLine--;
		lineInputs[currentLine].hasFocus = true;
		lineInputs[currentLine + 1].hasFocus = false;
	}

	function currentLineHasNoText() {
		return lineInputs[currentLine].textBox.text.length == 0;
	}

	function currentLineInputHasReachedCharLimit() {
		return lineInputs[currentLine].textBox.text.length >= maxLineLength;
	}
}
