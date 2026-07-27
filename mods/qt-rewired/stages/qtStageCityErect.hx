import openfl.display.BlendMode;

var sky:FlxSprite;
var stars:FlxSprite;
var bgBuildings2:FlxSprite;
var bgBuilding:FlxSprite;
var sign:FlxSprite;
var storeBg:FlxSprite;
var storeInterior:FlxSprite;
var lampAndBuilding:FlxSprite;
var mainGround:FlxSprite;
var storeLightAdd:FlxSprite;
var flower:FlxSprite;
var grass:FlxSprite;
var poster:FlxSprite;
var car:FlxSprite;
var overlayOverlay:FlxSprite;
var overlayAdd:FlxSprite;

function onCreate()
{
	// Furthest back to closest, all behind the characters (zIndex < 100 in
	// the original stage data).
	sky = new FlxSprite(-973, -1076);
	sky.loadGraphic(Paths.image('erectCity/sky'));
	game.add(sky);

	stars = new FlxSprite(-685, -600);
	stars.frames = Paths.getSparrowAtlas('erectCity/stars');
	stars.animation.addByPrefix('idle', 'stars', 24, true);
	stars.animation.play('idle');
	stars.scrollFactor.set(0.7, 0.7);
	game.add(stars);

	bgBuildings2 = new FlxSprite(-606, -671);
	bgBuildings2.loadGraphic(Paths.image('erectCity/bgBuildings2'));
	bgBuildings2.scrollFactor.set(0.8, 0.8);
	game.add(bgBuildings2);

	bgBuilding = new FlxSprite(-1075, -835);
	bgBuilding.loadGraphic(Paths.image('erectCity/bgBuilding'));
	bgBuilding.scrollFactor.set(0.75, 0.75);
	game.add(bgBuilding);

	sign = new FlxSprite(30, -425);
	sign.loadGraphic(Paths.image('erectCity/signBetterCallSahur'));
	sign.scrollFactor.set(0.85, 0.85);
	game.add(sign);

	storeBg = new FlxSprite(-989, 446);
	storeBg.loadGraphic(Paths.image('erectCity/storeBg'));
	storeBg.scale.set(1.0057, 1.0057);
	storeBg.updateHitbox();
	game.add(storeBg);

	storeInterior = new FlxSprite(-985, 437);
	storeInterior.loadGraphic(Paths.image('erectCity/storeInterior'));
	storeInterior.scale.set(0.6663, 0.6663);
	storeInterior.updateHitbox();
	storeInterior.scrollFactor.set(0.95, 0.95);
	game.add(storeInterior);

	lampAndBuilding = new FlxSprite(875, 125);
	lampAndBuilding.loadGraphic(Paths.image('erectCity/lampAndBuilding'));
	lampAndBuilding.scrollFactor.set(0.8, 0.8);
	game.add(lampAndBuilding);

	mainGround = new FlxSprite(-992, -305);
	mainGround.loadGraphic(Paths.image('erectCity/mainGround'));
	game.add(mainGround);

	storeLightAdd = new FlxSprite(-1249, 161);
	storeLightAdd.loadGraphic(Paths.image('erectCity/storeLightAdd'));
	storeLightAdd.blend = BlendMode.ADD;
	storeLightAdd.alpha = 0.7;
	game.add(storeLightAdd);

	flower = new FlxSprite(-56, 1080);
	flower.frames = Paths.getSparrowAtlas('erectCity/flower');
	flower.animation.addByPrefix('flower', 'flower', 24, true);
	flower.animation.play('flower');
	game.add(flower);

	grass = new FlxSprite(1598, 1115);
	grass.frames = Paths.getSparrowAtlas('erectCity/grass');
	grass.animation.addByPrefix('grass', 'grass', 24, true);
	grass.animation.play('grass');
	game.add(grass);

	poster = new FlxSprite(1665, 846);
	poster.frames = Paths.getSparrowAtlas('erectCity/poster');
	poster.animation.addByPrefix('poster', 'poster', 24, true);
	poster.animation.play('poster');
	game.add(poster);
}

function onCreatePost()
{
	// In front of the characters (zIndex >= 100 in the original stage data).
	car = new FlxSprite(-1048, 810);
	car.loadGraphic(Paths.image('erectCity/car'));
	car.scrollFactor.set(1.03, 1.03);
	game.add(car);

	overlayOverlay = new FlxSprite(-1025, -665);
	overlayOverlay.loadGraphic(Paths.image('erectCity/overlayOverlay'));
	overlayOverlay.scrollFactor.set(1, 0.5);
	overlayOverlay.blend = BlendMode.OVERLAY;
	overlayOverlay.alpha = 0.6;
	game.add(overlayOverlay);

	overlayAdd = new FlxSprite(-1242, -1060);
	overlayAdd.loadGraphic(Paths.image('erectCity/overlayAdd'));
	overlayAdd.scrollFactor.set(1, 0.5);
	overlayAdd.blend = BlendMode.ADD;
	overlayAdd.alpha = 0.15;
	game.add(overlayAdd);
}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	if (eventName == 'FocusCamera') focusCamera(value1, value2);
	else if (eventName == 'ZoomCamera') zoomCamera(value1, value2);
	else if (eventName == 'SetCameraBop') setCameraBop(value1, value2);
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

// --- SetCameraBop: periodic camera zoom pulse (see PORT_INFO.md) ---
var bopRate:Float = 4;
var bopOffset:Float = 0;
var bopIntensity:Float = 1.0;

function setCameraBop(value1:String, value2:String)
{
	var p:Array<String> = value1.split(',');
	bopIntensity = (p.length > 0 && p[0].length > 0) ? Std.parseFloat(p[0]) : 1.0;
	bopRate = (p.length > 1 && p[1].length > 0) ? Std.parseFloat(p[1]) : 4;
	bopOffset = (p.length > 2 && p[2].length > 0) ? Std.parseFloat(p[2]) : 0;
}

function onBeatHit()
{
	if (bopRate <= 0 || bopIntensity == 1.0) return;

	var beat:Int = getVar('curBeat');
	if (Math.round((beat + bopOffset) % bopRate) != 0) return;

	var bump:Float = (bopIntensity - 1.0) * game.defaultCamZoom;
	var startZoom:Float = FlxG.camera.zoom;
	var half:Float = (Conductor.crochet * bopRate) / 2000;

	FlxTween.tween(FlxG.camera, {zoom: startZoom + bump}, half, {
		ease: FlxEase.quadOut,
		onComplete: function(_) FlxTween.tween(FlxG.camera, {zoom: startZoom}, half, {ease: FlxEase.quadIn})
	});
}
