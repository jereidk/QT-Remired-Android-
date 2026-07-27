import openfl.display.BlendMode;

var floorUnder:FlxSprite;
var sky:FlxSprite;
var cityBehind:FlxSprite;
var cityFront:FlxSprite;
var tree:FlxSprite;
var electricPoles:FlxSprite;
var pole1:FlxSprite;
var pole2:FlxSprite;
var stopBus:FlxSprite;
var wall:FlxSprite;
var bridge:FlxSprite;
var floorGrass:FlxSprite;
var lucky:FlxSprite;
var tvs:FlxSprite;
var addOv:FlxSprite;
var multOv:FlxSprite;
var speakerGrass:FlxSprite;
var picoGrass:FlxSprite;
var reeds:FlxSprite;
var tvFG:FlxSprite;
var difOv:FlxSprite;
var sunOv:FlxSprite;

function onCreate()
{
	floorUnder = new FlxSprite(158, 460);
	floorUnder.makeGraphic(2045, 728, 0xFF4B7334);
	game.add(floorUnder);

	sky = new FlxSprite(-270, -356);
	sky.loadGraphic(Paths.image('outskirts/sky'));
	game.add(sky);

	cityBehind = new FlxSprite(-977, -57);
	cityBehind.loadGraphic(Paths.image('outskirts/cityBack'));
	cityBehind.scrollFactor.set(0.6, 0.6);
	game.add(cityBehind);

	cityFront = new FlxSprite(66, -177);
	cityFront.loadGraphic(Paths.image('outskirts/cityFront'));
	cityFront.scrollFactor.set(0.7, 0.7);
	game.add(cityFront);

	tree = new FlxSprite(537, -73.5);
	tree.loadGraphic(Paths.image('outskirts/tree'));
	tree.scrollFactor.set(0.85, 0.85);
	game.add(tree);

	electricPoles = new FlxSprite(101, -139);
	electricPoles.loadGraphic(Paths.image('outskirts/electricPoles'));
	electricPoles.scrollFactor.set(0.9, 0.9);
	game.add(electricPoles);

	pole1 = new FlxSprite(238, -140);
	pole1.loadGraphic(Paths.image('outskirts/lightPole1'));
	pole1.scrollFactor.set(0.93, 0.93);
	game.add(pole1);

	pole2 = new FlxSprite(1848, -135.5);
	pole2.loadGraphic(Paths.image('outskirts/lightPole2'));
	pole2.scrollFactor.set(0.93, 0.93);
	game.add(pole2);

	stopBus = new FlxSprite(1157, -59);
	stopBus.loadGraphic(Paths.image('outskirts/busStop'));
	stopBus.scrollFactor.set(0.96, 0.96);
	game.add(stopBus);

	wall = new FlxSprite(-58.5, 99);
	wall.loadGraphic(Paths.image('outskirts/wall'));
	game.add(wall);

	bridge = new FlxSprite(-926, -366);
	bridge.loadGraphic(Paths.image('outskirts/bridge'));
	game.add(bridge);

	floorGrass = new FlxSprite(158, 460);
	floorGrass.loadGraphic(Paths.image('outskirts/grass'));
	game.add(floorGrass);

	lucky = new FlxSprite(-411, 489);
	lucky.loadGraphic(Paths.image('outskirts/lucky'));
	lucky.scrollFactor.set(0.98, 0.98);
	game.add(lucky);

	tvs = new FlxSprite(-852, 242);
	tvs.loadGraphic(Paths.image('outskirts/TVs'));
	game.add(tvs);

	addOv = new FlxSprite(-924, -344.5);
	addOv.loadGraphic(Paths.image('outskirts/overlayAdd'));
	addOv.blend = BlendMode.ADD;
	addOv.alpha = 0.25;
	game.add(addOv);
}

function onCreatePost()
{
	multOv = new FlxSprite(-901, -331);
	multOv.loadGraphic(Paths.image('outskirts/overlayMultiply'));
	multOv.blend = BlendMode.MULTIPLY;
	multOv.alpha = 0.6;
	game.add(multOv);

	speakerGrass = new FlxSprite(199, 708);
	speakerGrass.loadGraphic(Paths.image('outskirts/grassSpeaker'));
	game.add(speakerGrass);

	picoGrass = new FlxSprite(394, 691);
	picoGrass.loadGraphic(Paths.image('outskirts/grassPico'));
	game.add(picoGrass);

	reeds = new FlxSprite(397, 700);
	reeds.loadGraphic(Paths.image('outskirts/foregroundReeds'));
	reeds.scrollFactor.set(1.15, 1.15);
	game.add(reeds);

	tvFG = new FlxSprite(-770, 790);
	tvFG.loadGraphic(Paths.image('outskirts/foregroundTV'));
	tvFG.scrollFactor.set(1.2, 1.2);
	game.add(tvFG);

	difOv = new FlxSprite(-917.5, 458.5);
	difOv.loadGraphic(Paths.image('outskirts/overlayOverlay'));
	difOv.blend = BlendMode.OVERLAY;
	difOv.alpha = 0.25;
	game.add(difOv);

	sunOv = new FlxSprite(-811, -683);
	sunOv.loadGraphic(Paths.image('outskirts/sunlightAdd'));
	sunOv.scrollFactor.set(1.04, 1.04);
	sunOv.blend = BlendMode.ADD;
	sunOv.alpha = 0.7;
	game.add(sunOv);
}
