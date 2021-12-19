package;

import flixel.graphics.FlxGraphic;
import openfl.display.Bitmap;
import openfl.geom.ColorTransform;

class Globals {
	public static var cameras(default, null):Cameras = new Cameras();

	public static var SHOW_GHOSTS:Bool = false;
	public static var playerInputAllowed:Bool = true;
}

class Cameras {
	public var mainCam:FlxCamera;
	public var ghostCam:FlxCamera;
	public var uiCam:FlxCamera;

	public function new() {}
}

class Utils {
	public static function getColorModifiedBitmapData(assetKey:String, alpha:Float = 1, tint:FlxColor = FlxColor.WHITE) {
		var will:FlxGraphic = FlxGraphic.fromAssetKey(assetKey, false);
		var newBmd = new BitmapData(will.width, will.height, true, 0x00000000);
		var b:Bitmap = new Bitmap(will.bitmap);
		newBmd.draw(b, null, new ColorTransform(tint.redFloat, tint.greenFloat, tint.blueFloat, alpha), null, null, true);
		return newBmd;
	}

	public static function rerange(value:Float, oldMin:Float, oldMax:Float, newMin:Float, newMax:Float) {
		return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
	}

	public static function normalizeAngle(angle:Float):Float {
		angle = angle % 360;

		if (angle < 0) {
			angle += 360;
		}
		return angle;
	}
}
