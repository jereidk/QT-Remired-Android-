import openfl.display.BlendMode;

var wall:FlxSprite;
var tvShadow:FlxSprite;
var tvFront:FlxSprite;
var tvFrontShine:FlxSprite;
var lightOverlay:FlxSprite;
var blackScreen:FlxSprite;
var spotLight:FlxSprite;
var redScreen:FlxSprite;

function onCreate()
{
	// Background layers (rendered behind the characters).
	tvShadow = new FlxSprite(-150, 530);
	tvShadow.loadGraphic(Paths.image('obliterated/tv_shadow'));
	tvShadow.scrollFactor.set(0.99, 0.99);
	tvShadow.antialiasing = ClientPrefs.data.antialiasing;
	game.add(tvShadow);

	wall = new FlxSprite(-649, -42);
	wall.loadGraphic(Paths.image('blissful/bg'));
	wall.scrollFactor.set(0.99, 0.99);
	wall.antialiasing = ClientPrefs.data.antialiasing;
	game.add(wall);
}

function onCreatePost()
{
	// Foreground layers (rendered above the characters).
	tvFront = new FlxSprite(-314, 873);
	tvFront.loadGraphic(Paths.image('obliterated/fg'));
	tvFront.scrollFactor.set(1.35, 1.35);
	tvFront.antialiasing = ClientPrefs.data.antialiasing;
	game.add(tvFront);

	tvFrontShine = new FlxSprite(45, 873);
	tvFrontShine.loadGraphic(Paths.image('obliterated/fg_shine'));
	tvFrontShine.scrollFactor.set(1.35, 1.35);
	tvFrontShine.antialiasing = ClientPrefs.data.antialiasing;
	tvFrontShine.color = 0xFFC986BD;
	game.add(tvFrontShine);

	lightOverlay = new FlxSprite(-654, -60);
	lightOverlay.frames = Paths.getSparrowAtlas('common/gradientManager');
	lightOverlay.animation.addByPrefix('Normal', 'overlay-Normal', 24, true);
	lightOverlay.animation.play('Normal');
	lightOverlay.blend = BlendMode.ADD;
	game.add(lightOverlay);

	blackScreen = new FlxSprite(-649, -42);
	blackScreen.makeGraphic(2589, 1306, FlxColor.BLACK);
	blackScreen.alpha = 0;
	game.add(blackScreen);

	spotLight = new FlxSprite(-10, -390);
	spotLight.loadGraphic(Paths.image('cutscene/lightFocus'));
	spotLight.alpha = 0;
	game.add(spotLight);

	redScreen = new FlxSprite(-649, -342);
	redScreen.makeGraphic(2589, 1506, 0xFFB81404);
	redScreen.alpha = 0;
	game.add(redScreen);
}

function onGameOver()
{
	// Restore stage colors in case a future dodge-mechanic tint is added later.
}

// --- Blissful (base) outro cutscene, ported from blissful.hxc's onSongEnd()
// + QtTransformSongOutro.hxc. QT is swapped out for a standalone FlxAnimate
// playing the mod's own "qt transform" symbol (a proper Adobe Animate atlas
// with a symbol dictionary this time, unlike the frame-label-only atlases
// used elsewhere - addBySymbol works directly), inserted into the display
// list right below the fade overlays so it renders where dad used to be.
// Same onEndSong/Function_Stop interception pattern as the other cutscenes.
// Subtitles/skip-key are dropped (Psych has no subtitle system) - see
// PORT_INFO.md.
var hasPlayedOutro:Bool = false;
var qtCutscene:FlxAnimate;

function onEndSong():Dynamic
{
	if (hasPlayedOutro) return null;
	hasPlayedOutro = true;
	playIntroCutscene();
	return Function_Stop;
}

function dadFocusX():Float return game.dad.getMidpoint().x + 150 + game.dad.cameraPosition[0] + game.opponentCameraOffset[0];
function dadFocusY():Float return game.dad.getMidpoint().y - 100 + game.dad.cameraPosition[1] + game.opponentCameraOffset[1];

function playIntroCutscene()
{
	game.inCutscene = true;
	game.isCameraOnForcedPos = true;
	if (cameraFollowTween != null) cameraFollowTween.cancel();
	if (cameraZoomTween != null) cameraZoomTween.cancel();

	FlxTween.tween(game.camHUD, {alpha: 0}, 1);

	qtCutscene = new FlxAnimate(game.dad.x - 45, game.dad.y - 269);
	qtCutscene.showPivot = false;
	Paths.loadAnimateAtlas(qtCutscene, 'characters/QT_assets/qtCutscene');
	qtCutscene.anim.addBySymbol('transform', 'qt transform', 24, false);
	game.dad.visible = false;

	var insertAt:Int = game.members.indexOf(lightOverlay);
	if (insertAt >= 0) game.insert(insertAt, qtCutscene);
	else game.add(qtCutscene);

	// 0.68 is the original's literal absolute target zoom (not a multiplier
	// of the stage's own defaultZoom, unlike tweenCamZoomAbs elsewhere).
	cameraZoomTween = FlxTween.tween(FlxG.camera, {zoom: 0.68}, 1, {ease: FlxEase.quadInOut});
	qtCutscene.anim.play('transform', true);

	var opponentTargetX:Float = dadFocusX();
	var opponentTargetY:Float = game.camFollow.y;

	new FlxTimer().start(1, function(_) FlxG.sound.play(Paths.sound('qtsfx')));

	new FlxTimer().start(1, function(_) tweenCamPos(opponentTargetX, opponentTargetY, 2.55, FlxEase.quadInOut));

	new FlxTimer().start(2.26, function(_)
	{
		FlxTween.tween(lightOverlay, {alpha: 0}, 1.10, {ease: FlxEase.linear});
		FlxTween.tween(blackScreen, {alpha: 1}, 1.10, {ease: FlxEase.linear});
		FlxTween.tween(spotLight, {alpha: 1}, 1.10, {ease: FlxEase.linear});
	});

	new FlxTimer().start(12, function(_)
	{
		FlxG.camera.shake(0.002, 8);
		FlxTween.tween(redScreen, {alpha: 1}, 0.7, {ease: FlxEase.linear});
		FlxTween.tween(spotLight, {alpha: 0}, 0.7, {ease: FlxEase.linear});
	});

	new FlxTimer().start(13, function(_)
	{
		FlxG.camera.fade(0xFFFFFFFF, 2, false, function()
		{
			if (qtCutscene != null)
			{
				qtCutscene.destroy();
				qtCutscene = null;
			}
		});
	});

	new FlxTimer().start(15.7, function(_) FlxG.camera.fade(0xFF000000, 0.0001, false));

	new FlxTimer().start(17.5, function(_)
	{
		game.inCutscene = false;
		game.endSong();
	});
}

function tweenCamPos(x:Float, y:Float, duration:Float, ease:Float->Float)
{
	if (cameraFollowTween != null) cameraFollowTween.cancel();
	cameraFollowTween = FlxTween.tween(game.camFollow, {x: x, y: y}, duration, {ease: ease});
}

function tweenCamZoomAbs(mult:Float, duration:Float, ease:Float->Float)
{
	if (cameraZoomTween != null) cameraZoomTween.cancel();
	cameraZoomTween = FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom * mult}, duration, {ease: ease});
}

// --- Blissful (base) intro cutscene, ported from blissful.hxc's
// onCountdownStart() - a separate feature from the QT-transform outro above
// that had been missed entirely in an earlier pass (see PORT_INFO.md). Same
// "still"-then-"intro" frame-label pose on the plain "qt" atlas (no swap
// needed - unlike Blissful-erect, base Blissful's dad never leaves "qt"),
// same onStartCountdown/Function_Stop interception as the other intro
// cutscenes. Subtitles/skip-key dropped, same as the rest.
var hasPlayedIntroCutscene:Bool = false;
var introMusic:Dynamic;

function onStartCountdown():Dynamic
{
	if (hasPlayedIntroCutscene) return null;
	hasPlayedIntroCutscene = true;
	playIntroCutsceneCountdown();
	return Function_Stop;
}

function playIntroCutsceneCountdown()
{
	game.inCutscene = true;
	game.isCameraOnForcedPos = true;
	if (cameraFollowTween != null) cameraFollowTween.cancel();
	if (cameraZoomTween != null) cameraZoomTween.cancel();

	game.camHUD.visible = false;
	game.camHUD.alpha = 0;

	if (game.dad.atlas != null)
	{
		game.dad.atlas.anim.addByFrameLabel('still', 'hi cutie', 24, false);
		game.dad.atlas.anim.addByFrameLabel('intro', 'hi cutie', 24, false);
	}

	introMusic = FlxG.sound.play(Paths.music('gameplay/introSong/introSong-default'), 0.1);

	game.camFollow.setPosition(dadFocusX(), dadFocusY() - 235);
	FlxG.camera.fade(0xFF000000, 2.75, true, null, true);

	game.dad.playAnim('still', true, true);
	tweenCamPos(dadFocusX(), dadFocusY(), 2.75, FlxEase.expoOut);
	tweenCamZoomAbs(1.1875, 2.75, FlxEase.expoOut);

	new FlxTimer().start(0.5, function(_) game.dad.playAnim('intro', true, false));

	new FlxTimer().start(1.09, function(_) FlxG.sound.play(Paths.sound('gameplay/countdown/hi_cutie'), 1));

	new FlxTimer().start(4, function(_)
	{
		tweenCamZoomAbs(1.0, 4, FlxEase.smoothStepInOut);

		game.inCutscene = false;
		game.camHUD.visible = true;
		game.camHUD.alpha = 0;
		FlxTween.tween(game.camHUD, {alpha: 1}, 1, {ease: FlxEase.smoothStepInOut});

		if (introMusic != null) introMusic.stop();
		game.startCountdown();
	});
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

// SetCameraBop uses FunkinCrew's real per-frame exponential decay
// (SetCameraBopSongEvent.hx / PlayState.hx:
// cameraBopMultiplier = lerp(1, cameraBopMultiplier, 0.95^(elapsed*60)))
// instead of a fixed-duration up/down tween. Paused while an explicit
// ZoomCamera tween is active so the two don't fight over FlxG.camera.zoom -
// see PORT_INFO.md.
var cameraBopMultiplier:Float = 1.0;
var bopBaseZoom:Float = 1.0;

function onBeatHit()
{
	if (bopRate <= 0 || bopIntensity == 1.0) return;

	var beat:Int = getVar('curBeat');
	if (Math.round((beat + bopOffset) % bopRate) != 0) return;

	if (cameraBopMultiplier == 1.0) bopBaseZoom = FlxG.camera.zoom;
	cameraBopMultiplier = bopIntensity;
}

function decayCameraBop(elapsed:Float)
{
	if (cameraBopMultiplier == 1.0) return;
	if (cameraZoomTween != null && cameraZoomTween.active) return;

	var decayRate:Float = 0.95;
	var dt:Float = elapsed * 60;
	cameraBopMultiplier = 1.0 + (cameraBopMultiplier - 1.0) * Math.pow(decayRate, dt);
	FlxG.camera.zoom = bopBaseZoom * cameraBopMultiplier;

	if (Math.abs(cameraBopMultiplier - 1.0) < 0.0005) cameraBopMultiplier = 1.0;
}

function onUpdate(elapsed:Float)
{
	decayCameraBop(elapsed);
}
