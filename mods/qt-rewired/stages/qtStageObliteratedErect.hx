import openfl.display.BlendMode;

var sky:FlxSprite;
var bgBuildings2:FlxSprite;
var bgBuilding:FlxSprite;
var sign:FlxSprite;
var lampAndBuilding:FlxSprite;
var storeBg:FlxSprite;
var storeInterior:FlxSprite;
var tvStatic:FlxSprite;
var mainGround:FlxSprite;
var flower:FlxSprite;
var grass:FlxSprite;
var posterProp:FlxSprite;
var tvLightsOverlay:FlxSprite;
var car:FlxSprite;
var windProp:FlxSprite;
var overlayAdd:FlxSprite;
var blackScreen:FlxSprite;

// --- Sawblade dodge mechanic (same as qtStageKiller.hx) ---
var sawSprite:FlxAnimate;
var warningVfx:FlxAnimate;
var dodgeActive:Bool = false;
var dodgeWindowStart:Float = 0;
var dodgeWindowEnd:Float = 0;
var dodgeUsed:Bool = false;

function onCreate()
{
	sky = new FlxSprite(-973, -1076);
	sky.loadGraphic(Paths.image('obliteratedErect/sky'));
	game.add(sky);

	bgBuildings2 = new FlxSprite(-606, -671);
	bgBuildings2.loadGraphic(Paths.image('obliteratedErect/bgBuildings2'));
	bgBuildings2.scrollFactor.set(0.8, 0.8);
	game.add(bgBuildings2);

	bgBuilding = new FlxSprite(-1075, -835);
	bgBuilding.loadGraphic(Paths.image('obliteratedErect/bgBuilding'));
	bgBuilding.scrollFactor.set(0.75, 0.75);
	game.add(bgBuilding);

	sign = new FlxSprite(30, -425);
	sign.loadGraphic(Paths.image('obliteratedErect/signBetterCallSahur'));
	sign.scrollFactor.set(0.85, 0.85);
	game.add(sign);

	lampAndBuilding = new FlxSprite(875, 125);
	lampAndBuilding.loadGraphic(Paths.image('obliteratedErect/lampAndBuilding'));
	lampAndBuilding.scrollFactor.set(0.8, 0.8);
	game.add(lampAndBuilding);

	storeBg = new FlxSprite(-989, 446);
	storeBg.loadGraphic(Paths.image('obliteratedErect/storeBg'));
	storeBg.scale.set(1.0057, 1.0057);
	storeBg.updateHitbox();
	game.add(storeBg);

	storeInterior = new FlxSprite(-985, 437);
	storeInterior.loadGraphic(Paths.image('obliteratedErect/storeInterior'));
	storeInterior.scale.set(0.6663, 0.6663);
	storeInterior.updateHitbox();
	storeInterior.scrollFactor.set(0.95, 0.95);
	game.add(storeInterior);

	tvStatic = new FlxSprite(89, 580);
	tvStatic.frames = Paths.getSparrowAtlas('obliteratedErect/tvScreens');
	tvStatic.animation.addByPrefix('tvStatic', 'tvStatic', 24, true);
	tvStatic.animation.play('tvStatic');
	game.add(tvStatic);

	mainGround = new FlxSprite(-992, -305);
	mainGround.loadGraphic(Paths.image('obliteratedErect/mainGround'));
	game.add(mainGround);

	flower = new FlxSprite(-56, 1080);
	flower.frames = Paths.getSparrowAtlas('obliteratedErect/flower');
	flower.animation.addByPrefix('flower', 'flower', 24, true);
	flower.animation.play('flower');
	game.add(flower);

	grass = new FlxSprite(1598, 1115);
	grass.frames = Paths.getSparrowAtlas('obliteratedErect/grass');
	grass.animation.addByPrefix('grass', 'grass', 24, true);
	grass.animation.play('grass');
	game.add(grass);

	posterProp = new FlxSprite(1665, 846);
	posterProp.frames = Paths.getSparrowAtlas('obliteratedErect/poster');
	posterProp.animation.addByPrefix('poster', 'poster', 24, true);
	posterProp.animation.play('poster');
	game.add(posterProp);

	tvLightsOverlay = new FlxSprite(-300, 155);
	tvLightsOverlay.frames = Paths.getSparrowAtlas('obliteratedErect/tvLightsAdd');
	tvLightsOverlay.animation.addByPrefix('tvLights', 'tvLights', 24, true);
	tvLightsOverlay.animation.play('tvLights');
	tvLightsOverlay.blend = BlendMode.ADD;
	game.add(tvLightsOverlay);
}

function onCreatePost()
{
	car = new FlxSprite(-1048, 810);
	car.loadGraphic(Paths.image('obliteratedErect/car'));
	car.scrollFactor.set(1.03, 1.03);
	game.add(car);

	windProp = new FlxSprite(-1000, 280);
	windProp.frames = Paths.getSparrowAtlas('obliteratedErect/wind');
	windProp.animation.addByPrefix('wind', 'wind', 24, true);
	windProp.animation.play('wind');
	game.add(windProp);

	overlayAdd = new FlxSprite(-1242, -1060);
	overlayAdd.loadGraphic(Paths.image('obliteratedErect/overlayAdd'));
	overlayAdd.scrollFactor.set(1, 0.5);
	overlayAdd.blend = BlendMode.ADD;
	overlayAdd.alpha = 0.15;
	game.add(overlayAdd);

	blackScreen = new FlxSprite(0, 0);
	blackScreen.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	blackScreen.scrollFactor.set(0, 0);
	blackScreen.cameras = [game.camGame];
	blackScreen.alpha = 0;
	game.add(blackScreen);

	// Sawblade mechanic sprites, hidden until the first "sawKB" event fires.
	warningVfx = new FlxAnimate();
	warningVfx.showPivot = false;
	Paths.loadAnimateAtlas(warningVfx, 'saw_mechanic/warning');
	warningVfx.anim.addBySymbol('alert1', 'export real/alert 1', 24, false);
	warningVfx.anim.addBySymbol('alert2', 'export real/alert 2', 24, false);
	warningVfx.anim.addBySymbol('attack', 'export real/attack', 24, false);
	warningVfx.anim.addBySymbol('doubleAlert1', 'export real/doubleAlert 1', 24, false);
	warningVfx.anim.addBySymbol('doubleAlert2', 'export real/doubleAlert 2', 24, false);
	warningVfx.anim.addBySymbol('doubleAttack1', 'export real/doubleAttack 1', 24, false);
	warningVfx.anim.addBySymbol('doubleAttack2', 'export real/doubleAttack 2', 24, false);
	warningVfx.visible = false;
	warningVfx.cameras = [game.camHUD];
	warningVfx.zIndex = 900;
	game.add(warningVfx);

	sawSprite = new FlxAnimate();
	sawSprite.showPivot = false;
	Paths.loadAnimateAtlas(sawSprite, 'saw_mechanic/saw_assets');
	sawSprite.anim.addBySymbol('spin', 'saw anim alert', 24, false);
	sawSprite.anim.addBySymbol('attack', 'saw anim attack', 24, false);
	sawSprite.visible = false;
	if (game.dad != null)
	{
		sawSprite.x = game.dad.getGraphicMidpoint().x - 50;
		sawSprite.y = game.dad.getGraphicMidpoint().y - 275;
	}
	game.add(sawSprite);
}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	if (eventName == 'sawKB')
	{
		if (getSawMode() == 'Disabled') return;
		var numSaws:Int = Std.parseInt(value1);
		if (numSaws == null || numSaws <= 0) numSaws = 1;
		startSawSequence(numSaws);
	}
	else if (eventName == 'FocusCamera') focusCamera(value1, value2);
	else if (eventName == 'ZoomCamera') zoomCamera(value1, value2);
	else if (eventName == 'SetCameraBop') setCameraBop(value1, value2);
}

// Sequence timeline (beats, relative to the event's strumTime):
//   beat 0: first alert
//   beat 1: second alert + saw appears, spinning
//   beat (1+i) for i in 1...numSaws: attack #i lands; the dodge window for
//     that hit spans from beat (1+i-1) to beat (1+i).
// This generalizes the single-saw sequence (numSaws=1: alert, alert+spin,
// attack) to N sequential hits, matching the original single/double/triple
// SawbladeEvent variants.
function startSawSequence(numSaws:Int)
{
	var beat:Float = Conductor.crochet;
	var isSingle:Bool = numSaws == 1;

	FlxTween.tween(blackScreen, {alpha: 0.3}, 0.35, {ease: FlxEase.linear});
	playWarning(isSingle ? 'alert1' : 'doubleAlert1');

	new FlxTimer().start(beat / 1000, function(_)
	{
		playWarning(isSingle ? 'alert2' : 'doubleAlert2');
		spawnSaw();
		beginHitWindow(beat);
	});

	for (i in 1...numSaws + 1)
	{
		var hitIndex:Int = i;
		new FlxTimer().start((beat * (1 + hitIndex)) / 1000, function(_)
		{
			resolveHit(hitIndex, numSaws, beat);
		});
	}
}

function beginHitWindow(beat:Float)
{
	dodgeUsed = false;
	dodgeWindowStart = Conductor.songPosition;
	dodgeWindowEnd = Conductor.songPosition + beat;
	dodgeActive = true;
}

function resolveHit(hitIndex:Int, numSaws:Int, beat:Float)
{
	var isSingle:Bool = numSaws == 1;
	sawSprite.anim.play('attack', true);
	playWarning(isSingle ? 'attack' : (hitIndex == 1 ? 'doubleAttack1' : 'doubleAttack2'), true);
	game.camGame.shake(0.007, 0.25);

	if (!dodgeUsed) applySawHit();
	dodgeActive = false;

	if (hitIndex < numSaws)
	{
		// More hits queued: re-spin the saw and open the next dodge window.
		sawSprite.anim.play('spin', true);
		beginHitWindow(beat);
	}
	else
	{
		new FlxTimer().start(0.3, function(_) hideSawVisuals());
	}
}

function playWarning(anim:String, isAttack:Bool = false)
{
	warningVfx.visible = true;
	warningVfx.anim.play(anim, true);
	warningVfx.screenCenter();
	playSfx(isAttack ? 'sawblades/attacks/attack-1' : 'sawblades/alerts/alert-1');
}

function playSfx(sound:String)
{
	FlxG.sound.play(Paths.sound(sound));
}

function spawnSaw()
{
	sawSprite.visible = true;
	sawSprite.anim.play('spin', true);
}

function hideSawVisuals()
{
	if (game.health <= 0) return;
	sawSprite.visible = false;
	warningVfx.visible = false;
	FlxTween.tween(blackScreen, {alpha: 0}, 0.35, {ease: FlxEase.quadInOut});
}

function tryDodge()
{
	if (!dodgeActive || dodgeUsed) return;
	dodgeUsed = true;

	if (game.boyfriend != null) game.boyfriend.playAnim('dodge', true);
	if (game.gf != null) game.gf.playAnim('dodge', true);

	var timeDiff:Float = Conductor.songPosition - dodgeWindowEnd;
	if (Math.abs(timeDiff) <= dodgeWindowEnd - dodgeWindowStart)
	{
		game.health += 0.2;
	}
	else
	{
		dodgeUsed = false; // too early, doesn't count
	}
}

function getSawMode():String
{
	var mode:Dynamic = getModSetting('qtSawMode');
	return (mode != null) ? mode : 'Damage';
}

function dodgeKeyJustPressed():Bool
{
	var kb:Dynamic = getModSetting('qtDodgeKey');
	if (kb == null) return keyJustPressed('accept');

	var kbPressed:Bool = (kb.keyboard != null && kb.keyboard != 'NONE') ? keyboardJustPressed(kb.keyboard) : false;
	var padPressed:Bool = (kb.gamepad != null && kb.gamepad != 'NONE') ? anyGamepadJustPressed(kb.gamepad) : false;
	return kbPressed || padPressed;
}

function applySawHit()
{
	var mode:String = getSawMode();
	if (mode == 'Disabled') return;

	if (mode == 'Instakill')
		game.health = 0;
	else
		game.health = Math.max(game.health - 1.0, 0);

	FlxG.camera.flash(0xFFff0000, 0.3);
	game.camGame.shake(0.008, 0.3);
}

function onUpdate(elapsed:Float)
{
	if (dodgeActive && !dodgeUsed && (FlxG.onMobile ? false : dodgeKeyJustPressed()))
	{
		tryDodge();
	}
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
