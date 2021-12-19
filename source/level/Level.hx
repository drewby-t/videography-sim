package level;

import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.ui.FlxUI.SortValue;
import flixel.util.FlxSort;
import level.wildlife.Bee;
import level.wildlife.Butterfly;
import level.wildlife.Duck;
import level.wildlife.Duckling;

class Level extends FlxGroup {
	var tiledData:TiledMap;

	var player:Player;

	public var ponds:FlxTypedGroup<Pond>;
	public var ducks:FlxTypedGroup<Duck>;
	public var trees:FlxTypedGroup<Tree>;
	public var graves:FlxTypedGroup<Grave>;
	public var ghosts:FlxTypedGroup<Ghost>;
	public var butterflies = new FlxTypedGroup<Butterfly>();
	public var bees = new FlxTypedGroup<Bee>();
	public var hives = new FlxTypedGroup<FlxSprite>();
	public var signs = new FlxTypedGroup<Sign>();
	public var allObjects:FlxTypedGroup<FlxObject>;
	public var overlay:FlxTypedGroup<FlxObject>;
	public var allColliders:FlxTypedGroup<FlxObject>;
	public var dirt:FlxTypedGroup<FlxSprite>;

	public var playerStart:FlxPoint = FlxPoint.get(0, 0);

	public var changeableSign:Sign = null;

	override public function new(tiledMap:TiledMap, player:Player) {
		super();
		this.player = player;

		tiledData = tiledMap;
		trees = new FlxTypedGroup<Tree>();
		ponds = new FlxTypedGroup<Pond>();
		ducks = new FlxTypedGroup<Duck>();
		graves = new FlxTypedGroup<Grave>();
		ghosts = new FlxTypedGroup<Ghost>();
		butterflies = new FlxTypedGroup<Butterfly>();
		bees = new FlxTypedGroup<Bee>();
		dirt = new FlxTypedGroup<FlxSprite>();
		hives = new FlxTypedGroup<FlxSprite>();
		signs = new FlxTypedGroup<Sign>();
		allObjects = new FlxTypedGroup<FlxObject>();
		allColliders = new FlxTypedGroup<FlxObject>();
		overlay = new FlxTypedGroup<FlxObject>();

		add(dirt);
		add(ponds); // ponds are always on the ground below stuff
		add(allObjects);
		add(overlay); // for now butterlies appear above everything
		add(ghosts); // ghosts are always visible on their camera

		// render objects
		for (layer in tiledData.layers) {
			if (layer.type == TiledLayerType.OBJECT) {
				var objectLayer:TiledObjectLayer = cast layer;

				if (objectLayer.name.toLowerCase() == "player start") {
					for (object in objectLayer.objects) {
						playerStart.x = object.x;
						playerStart.y = object.y;
					}
				}

				if (objectLayer.name.toLowerCase() == "dirt") {
					var tileset:TiledTileSet = tiledData.tilesets.get("dirt patch");
					for (object in objectLayer.objects) {
						var dirtSprite:FlxSprite = new FlxSprite(object.x, object.y);
						dirtSprite.loadGraphic(StringTools.replace(tileset.getImageSourceByGid(object.gid).source, "../..", "assets"));
						dirt.add(dirtSprite);
					}
				}

				if (objectLayer.name.toLowerCase() == "colliders") {
					for (object in objectLayer.objects) {
						var collider:FlxObject = new FlxObject(object.x,
							object.y); // rect objects from tiled dont require us to subtract the height like tile objects lol
						// collider.makeGraphic(object.width, object.height, FlxColor.TRANSPARENT, false);
						collider.width = object.width;
						collider.height = object.height;
						allColliders.add(collider);
						allObjects.add(collider);
						collider.solid = true;
						collider.immovable = true;
					}
				}

				if (objectLayer.name.toLowerCase() == "trees") {
					for (object in objectLayer.objects) {
						var tree:Tree = new Tree(object.x, object.y - object.height);
						trees.add(tree);
						allObjects.add(tree);
						allColliders.add(tree);
					}
				}

				if (objectLayer.name.toLowerCase() == "signs") {
					for (object in objectLayer.objects) {
						var lines = object.properties.get("text_lines").split(",");
						var sign:Sign = new Sign(object.x, object.y - object.height, lines);
						trace(sign.x, sign.y);
						allObjects.add(sign);
						signs.add(sign);
						allColliders.add(sign);
					}
				}

				if (objectLayer.name.toLowerCase() == "beehives") {
					for (object in objectLayer.objects) {
						var numBees = Random.int(12, 19);
						var hive:FlxSprite = new FlxSprite(object.x, object.y - object.height, AssetPaths.beehive_sized__png);
						hives.add(hive);
						overlay.add(hive);
						var objectCenter = new FlxPoint(hive.x + hive.width / 2, hive.y + hive.height / 2);
						var randomPoints = [
							for (i in 0...numBees)
								FlxPoint.get(objectCenter.x + Random.float(-60, 60), objectCenter.y + Random.float(-60, 60))
						];

						for (p in randomPoints) {
							var bee = new Bee(p.x, p.y, 80);
							bees.add(bee);
							overlay.add(bee);
						}
					}
				}

				if (objectLayer.name.toLowerCase() == "butterflies") {
					var tileset = tiledData.tilesets.get("butterflies-sized");
					trace(tileset);
					for (object in objectLayer.objects) {
						var tileProps = tileset.getPropertiesByGid(object.gid);
						var radiusDefault = Std.parseInt(tileProps.get("radius"));
						var radiusCustom = Std.parseInt(object.properties.get("radius"));
						var radius = radiusCustom == null || radiusCustom == 0 ? radiusDefault : radiusCustom;

						var bf:Butterfly = new Butterfly(object.x, object.y, radius);
						butterflies.add(bf);
						if (Random.bool()) {
							overlay.add(bf);
						}
						else {
							allObjects.add(bf);
						}
					}
				}

				if (objectLayer.name.toLowerCase() == "graves") {
					var tileset = tiledData.tilesets.get("graves_sized");

					Grave.tileWidth = tileset.tileWidth;
					Grave.tileHeight = tileset.tileHeight;
					for (object in objectLayer.objects) {
						var tileProps = tileset.getPropertiesByGid(object.gid);
						var graveType = Std.parseInt(tileProps.get("grave_type"));
						var ghostType = Std.parseInt(object.properties.get("ghost_type"));
						var grave:Grave = new Grave(object.x, object.y - object.height, graveType);
						allObjects.add(grave);
						allColliders.add(grave);
						graves.add(grave);

						if (object.properties.contains("ghost_type") && ghostType != -1) {
							var ghost:Ghost = new Ghost(object.x + 18, object.y - object.height, ghostType);
							ghosts.add(ghost);
							// allObjects.add(ghost);
						}
					}
				}

				if (objectLayer.name.toLowerCase() == "ponds") {
					for (object in objectLayer.objects) {
						var pond:Pond = new Pond(object.x, object.y - object.height);
						ponds.add(pond);
						var duck:Duck = new Duck(pond);
						ducks.add(duck);
						allObjects.add(duck);
						var duckling:Duckling = new Duckling(duck);
						allObjects.add(duckling);
						ducks.add(duckling);
						duckling.setPositionByMidpoint(duck.midpoint.x + 10, duck.midpoint.y + 20);
						duckling.getMidpoint(duckling.midpoint);

						var duckling2:Duckling = new Duckling(duckling, FlxColor.ORANGE.getLightened(0.45));
						allObjects.add(duckling2);
						ducks.add(duckling2);
						duckling2.setPositionByMidpoint(duckling.midpoint.x + 10, duckling.midpoint.y + 20);
						duckling2.maxDistanceToParent *= 0.8;
						duckling2.thrust = duckling.thrust;
					}
				}
			}
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		sortObjects();
		checkSignDistance();
	}

	function checkSignDistance() {
		var found = false;
		for (sign in signs) {
			var distToSign = FlxPoint.weak(player.x + player.width / 2, player.y + player.height / 2)
				.distanceTo(FlxPoint.weak(sign.x + sign.width / 2, sign.y + sign.height / 2));
			// trace("dist to Sign", distToSign);
			if (distToSign <= 200) {
				var text = "[E] to change sign]";
				if (player.helpText == null || player.helpText.text != text || player.helpText.visible == false) {
					player.showHelpText(text);
					trace("show help text");
					this.changeableSign = sign;
				}
				found = true;
				break;
			}
		}
		if (!found) {
			trace("hide help text");
			player.hideHelpText();
			changeableSign = null;
		}
	}

	function sortObjects() {
		allObjects.sort((order, a, b) -> {
			var a:FlxObject = cast a;
			var b:FlxObject = cast b;
			if (b.y + b.height < a.y + a.height) {
				return -order;
			}
			else if (a.y + a.height < b.y + b.height) {
				return order;
			}
			else {
				return 0;
			}
		}, FlxSort.ASCENDING);
	}
}
