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

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	if (eventName == 'FocusCamera') focusCamera(value1, value2);
	else if (eventName == 'ZoomCamera') zoomCamera(value1, value2);
}

// --- Camera focus/zoom events, ported with real tweening (Psych's native
// "Camera Follow Pos"/"Add Camera Zoom" only snap instantly) - see
// PORT_INFO.md for the FocusCamera/ZoomCamera event format. ---
var cameraFollowTween:FlxTween;
var cameraZoomTween:FlxTween;

function resolveEase(name:String):Float->Float
{
	if (name == null || name.length < 1) return FlxEase.linear;
	var fn = Reflect.field(FlxEase, name);
	return (fn != null) ? fn : FlxEase.linear;
}

function focusCamera(value1:String, value2:String)
{
	var p:Array<String> = value1.split(',');
	var char:Int = Std.parseInt(p[0]);
	var offX:Float = p.length > 1 ? Std.parseFloat(p[1]) : 0;
	var offY:Float = p.length > 2 ? Std.parseFloat(p[2]) : 0;

	var e:Array<String> = value2.split(',');
	var duration:Float = e.length > 0 ? Std.parseFloat(e[0]) : 4;
	var ease:String = e.length > 1 ? e[1] : 'linear';

	var tx:Float = offX;
	var ty:Float = offY;

	if (char == 0 && game.boyfriend != null)
	{
		tx += game.boyfriend.getMidpoint().x - 100 - (game.boyfriend.cameraPosition[0] - game.boyfriendCameraOffset[0]);
		ty += game.boyfriend.getMidpoint().y - 100 + game.boyfriend.cameraPosition[1] + game.boyfriendCameraOffset[1];
	}
	else if (char == 1 && game.dad != null)
	{
		tx += game.dad.getMidpoint().x + 150 + game.dad.cameraPosition[0] + game.opponentCameraOffset[0];
		ty += game.dad.getMidpoint().y - 100 + game.dad.cameraPosition[1] + game.opponentCameraOffset[1];
	}
	else if (char == 2 && game.gf != null)
	{
		tx += game.gf.getMidpoint().x + game.gf.cameraPosition[0] + game.girlfriendCameraOffset[0];
		ty += game.gf.getMidpoint().y + game.gf.cameraPosition[1] + game.girlfriendCameraOffset[1];
	}

	game.isCameraOnForcedPos = true;
	if (cameraFollowTween != null) cameraFollowTween.cancel();

	if (ease == 'CLASSIC')
	{
		game.camFollow.setPosition(tx, ty);
	}
	else
	{
		var durSeconds:Float = (ease == 'INSTANT') ? 0.001 : Conductor.stepCrochet * duration / 1000;
		cameraFollowTween = FlxTween.tween(game.camFollow, {x: tx, y: ty}, durSeconds, {ease: resolveEase(ease)});
	}
}

function zoomCamera(value1:String, value2:String)
{
	var p:Array<String> = value1.split(',');
	var zoom:Float = p.length > 0 ? Std.parseFloat(p[0]) : 1;
	var mode:String = p.length > 1 ? p[1] : 'stage';

	var e:Array<String> = value2.split(',');
	var duration:Float = e.length > 0 ? Std.parseFloat(e[0]) : 4;
	var ease:String = e.length > 1 ? e[1] : 'linear';

	var target:Float = zoom * (mode == 'direct' ? 1 : game.defaultCamZoom);

	if (cameraZoomTween != null) cameraZoomTween.cancel();

	if (ease == 'INSTANT')
	{
		FlxG.camera.zoom = target;
		return;
	}

	var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
	cameraZoomTween = FlxTween.tween(FlxG.camera, {zoom: target}, durSeconds, {ease: resolveEase(ease)});
}
