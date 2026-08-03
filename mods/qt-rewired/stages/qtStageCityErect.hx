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

// Pink "flash" overlay, ported from blissful-erect.hxc's pinkFlash/
// triggerPinkFlash - used once during the intro cutscene and 3 more times
// during regular gameplay (gameplayFlashTimes, checked against
// Conductor.songPosition in onUpdate, same as the original).
var pinkFlash:FlxSprite;
var gameplayFlashTimes:Array<Float> = [116840, 202490, 226380];
var currentFlashIndex:Int = 0;

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

	pinkFlash = new FlxSprite(0, 0);
	pinkFlash.makeGraphic(Math.floor(FlxG.width * 2), Math.floor(FlxG.height * 2), 0xFFFF9BF6);
	pinkFlash.blend = BlendMode.OVERLAY;
	pinkFlash.scrollFactor.set(0, 0);
	pinkFlash.screenCenter();
	pinkFlash.alpha = 0;
	pinkFlash.cameras = [game.camHUD];
	game.add(pinkFlash);
}

function triggerPinkFlash(cams:Array<FlxCamera>)
{
	if (pinkFlash == null) return;
	FlxTween.cancelTweensOf(pinkFlash);
	pinkFlash.cameras = cams;
	pinkFlash.alpha = 0.3;
	FlxTween.tween(pinkFlash, {alpha: 0}, 1.4, {ease: FlxEase.linear});
}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	if (eventName == 'FocusCamera') focusCamera(value1, value2);
	else if (eventName == 'ZoomCamera') zoomCamera(value1, value2);
	else if (eventName == 'SetCameraBop') setCameraBop(value1, value2);
}

// --- Blissful Erect ending cutscene, ported from blissful-erect.hxc's
// onSongEnd(). Camera choreography + sound cues + the dedicated dad/bf poses
// are kept, along with the subtitle line (showSubtitle() below) and the
// skip-key prompt (setupSkipPrompt()/updateSkipPrompt() below). Dad's
// "erectEnding" pose and bf's "shoulderSwish" both live in the qt-erect /
// bf-qt-erect Animate atlases as frame labels (no symbol dictionary entry),
// so they're registered with addByFrameLabel the same way qtStagePico's
// "cars" prop is.
var hasPlayedOutro:Bool = false;
var outroMusic:Dynamic;

function onEndSong():Dynamic
{
	if (hasPlayedOutro) return null;
	hasPlayedOutro = true;
	playEndingCutscene();
	return Function_Stop;
}

function playEndingCutscene()
{
	game.inCutscene = true;
	game.isCameraOnForcedPos = true;
	if (cameraFollowTween != null) cameraFollowTween.cancel();
	if (cameraZoomTween != null) cameraZoomTween.cancel();

	setupSkipPrompt();
	activeCutsceneFinish = finishEndingCutscene;

	FlxTween.tween(game.camHUD, {alpha: 0}, 1.2, {
		ease: FlxEase.quadOut,
		onComplete: function(_) game.camHUD.visible = false
	});

	// Dad needs to be the qt-erect character for its "erectEnding" pose -
	// same swap technique the caramelldansen window already uses.
	game.triggerEvent('Change Character', 'dad', 'qt-erect', 0);
	if (game.dad.atlas != null) game.dad.atlas.anim.addByFrameLabel('erectEnding', 'qt erect ending', 24, false);
	if (game.boyfriend.atlas != null) game.boyfriend.atlas.anim.addByFrameLabel('shoulderSwish', 'shoulder swish', 24, false);

	FlxG.sound.play(Paths.sound('gameplay/cutsceneSfx/bf/qt_erect_ending'));
	outroMusic = FlxG.sound.play(Paths.music('gameplay/introSong/outroSong-erect'), 0.2);
	scheduleCutsceneTimer(3.72, function(_) showSubtitle("You're kind of a show-off, huh?", 2.52));

	tweenCamPos(510, 923, 2.7, FlxEase.quartInOut);
	tweenCamZoomAbs(1.20, 2.7, FlxEase.quartInOut);

	scheduleCutsceneTimer(0.458, function(_) game.dad.playAnim('erectEnding', true));

	scheduleCutsceneTimer(2.35, function(_)
	{
		tweenCamPos(538, 923, 2, FlxEase.expoOut);
		tweenCamZoomAbs(1.08, 2, FlxEase.expoOut);
	});

	scheduleCutsceneTimer(4.65, function(_)
	{
		tweenCamPos(538, 923, 0.8, FlxEase.quartIn);
		tweenCamZoomAbs(1.16, 0.8, FlxEase.quartIn);
	});

	scheduleCutsceneTimer(4.95, function(_)
	{
		tweenCamPos(538, 923, 2.2, FlxEase.expoOut);
		tweenCamZoomAbs(1.12, 2.2, FlxEase.expoOut);
	});

	scheduleCutsceneTimer(5.75, function(_)
	{
		tweenCamPos(538, 923, 1.4, FlxEase.expoOut);
		tweenCamZoomAbs(1.0, 1.4, FlxEase.expoOut);
	});

	scheduleCutsceneTimer(6.4, function(_)
	{
		tweenCamPos(1040, 931, 2.1, FlxEase.quartInOut);
		tweenCamZoomAbs(1.0, 2.1, FlxEase.quartInOut);
	});

	scheduleCutsceneTimer(7.942, function(_) FlxG.sound.play(Paths.sound('gameplay/cutsceneSfx/bf/bf_erect_shoulder_swish')));

	scheduleCutsceneTimer(7.958, function(_) game.boyfriend.playAnim('shoulderSwish', true));

	scheduleCutsceneTimer(8.4, function(_) tweenCamPos(1040, 320, 2.9, FlxEase.quartIn));

	scheduleCutsceneTimer(9.3, function(_) FlxG.camera.fade(0xFF000000, 2.0, false, null, true));

	scheduleCutsceneTimer(14, function(_) finishEndingCutscene());
}

function finishEndingCutscene()
{
	activeCutsceneFinish = null;
	game.inCutscene = false;
	if (outroMusic != null) outroMusic.stop();
	game.endSong();
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

function dadFocusX():Float return game.dad.getMidpoint().x + 150 + game.dad.cameraPosition[0] + game.opponentCameraOffset[0];
function dadFocusY():Float return game.dad.getMidpoint().y - 100 + game.dad.cameraPosition[1] + game.opponentCameraOffset[1];

// Subtitles shared by both cutscenes in this file (see PORT_INFO.md) - the
// original's 3 .srt files here only have 1-2 short entries each, hardcoded
// as plain text+duration instead of parsing .srt at runtime. Toggled by the
// "Show Subtitles" mod setting (data/settings.json), since Psych has no
// built-in subtitles preference to check like the original's
// Preferences.subtitles.
var subtitleText:FlxText;

function subtitlesEnabled():Bool
{
	var v:Dynamic = getModSetting('qtSubtitles');
	return (v == null) ? true : v;
}

function showSubtitle(text:String, duration:Float)
{
	if (!subtitlesEnabled()) return;

	if (subtitleText == null)
	{
		subtitleText = new FlxText(0, FlxG.height * 0.85, FlxG.width, '', 28);
		subtitleText.setFormat(Paths.font('vcr.ttf'), 28, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
		subtitleText.scrollFactor.set();
		subtitleText.cameras = [FlxG.camera];
		subtitleText.alpha = 0;
		game.add(subtitleText);
	}

	subtitleText.text = text;
	subtitleText.alpha = 1;
	new FlxTimer().start(duration, function(_) { if (subtitleText != null) subtitleText.alpha = 0; });
}

// --- Cutscene skip prompt, shared by both cutscenes in this file (see
// PORT_INFO.md) - ported from the original's skipText/canSkipCutscene/
// cutsceneSkipped pattern: first press of the skip key fades in a
// "Hold [ACCEPT] to skip" prompt over 0.5s, a second press after that
// actually skips. Every FlxTimer inside either cutscene is created via
// scheduleCutsceneTimer() instead of "new FlxTimer()" directly so skip can
// cancel all of them at once. Known gap: skipping while an
// FlxG.camera.fade() is actively running won't cancel that fade (no verified
// way to do that from HScript).
var cutsceneTimers:Array<FlxTimer> = [];
var skipText:FlxText;
var canSkipCutscene:Bool = false;
var cutsceneSkipped:Bool = false;
var activeCutsceneFinish:Void->Void;

function scheduleCutsceneTimer(time:Float, cb:Float->Void):FlxTimer
{
	var t:FlxTimer = new FlxTimer().start(time, cb);
	cutsceneTimers.push(t);
	return t;
}

function skipKeyJustPressed():Bool
{
	return keyJustPressed('accept');
}

function setupSkipPrompt()
{
	cutsceneSkipped = false;
	canSkipCutscene = false;

	for (t in cutsceneTimers) if (t != null) t.cancel();
	cutsceneTimers = [];

	if (skipText == null)
	{
		skipText = new FlxText(0, FlxG.height - 60, FlxG.width - 20, '', 20);
		skipText.setFormat(Paths.font('vcr.ttf'), 20, 0xFFFFFFFF, 'right', FlxTextBorderStyle.OUTLINE, 0xFF000000);
		skipText.scrollFactor.set();
		skipText.cameras = [FlxG.camera];
		game.add(skipText);
	}

	skipText.text = 'Hold [ACCEPT] to skip';
	skipText.alpha = 0;
	skipText.visible = true;
}

function doSkipCutscene()
{
	cutsceneSkipped = true;
	canSkipCutscene = false;
	if (skipText != null) skipText.visible = false;
	if (subtitleText != null) subtitleText.alpha = 0;

	for (t in cutsceneTimers) if (t != null) t.cancel();
	cutsceneTimers = [];

	if (activeCutsceneFinish != null)
	{
		var finish:Void->Void = activeCutsceneFinish;
		activeCutsceneFinish = null;
		finish();
	}
}

function updateSkipPrompt()
{
	if (!game.inCutscene || cutsceneSkipped || skipText == null) return;

	if (skipKeyJustPressed())
	{
		if (!canSkipCutscene)
		{
			if (skipText.alpha == 0)
			{
				FlxTween.tween(skipText, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				scheduleCutsceneTimer(0.5, function(_) canSkipCutscene = true);
			}
		}
		else
		{
			doSkipCutscene();
		}
	}
}

// --- Blissful Erect intro cutscene, ported from blissful-erect.hxc's
// onCountdownStart(). Dad needs the qt-erect atlas again for its
// "erectIntro1"/"erectIntro2" poses (frame labels, addByFrameLabel like the
// ending cutscene) - swapped back to "qt" at the end since real gameplay
// needs the normal singing character. Subtitle lines and the skip-key
// prompt (same showSubtitle()/setupSkipPrompt() as the ending cutscene
// above) are both kept. The original's danceQT/QTErectDanceSprite overlay
// sprite (used during onCreate for the caramelldansen section) isn't
// ported - this mod already handles that section via the Change Character
// swap instead, a different but working approach - see PORT_INFO.md.
var hasPlayedIntroCutscene:Bool = false;
var introMusic:Dynamic;

function onStartCountdown():Dynamic
{
	if (hasPlayedIntroCutscene) return null;
	hasPlayedIntroCutscene = true;
	playIntroCutscene();
	return Function_Stop;
}

function playIntroCutscene()
{
	game.inCutscene = true;
	game.isCameraOnForcedPos = true;
	if (cameraFollowTween != null) cameraFollowTween.cancel();
	if (cameraZoomTween != null) cameraZoomTween.cancel();

	setupSkipPrompt();
	activeCutsceneFinish = finishIntroCutscene;

	game.camHUD.visible = false;
	game.camHUD.alpha = 0;

	game.triggerEvent('Change Character', 'dad', 'qt-erect', 0);
	if (game.dad.atlas != null)
	{
		game.dad.atlas.anim.addByFrameLabel('erectIntro1', 'qt erect intro 1', 24, false);
		game.dad.atlas.anim.addByFrameLabel('erectIntro2', 'qt erect intro 2', 24, false);
	}
	if (game.boyfriend.atlas != null) game.boyfriend.atlas.anim.addByFrameLabel('superHey', 'super hey', 24, false);

	introMusic = FlxG.sound.play(Paths.music('gameplay/introSong/introSong-erect'), 0.2);

	game.camFollow.setPosition(538, 500);
	FlxG.camera.zoom = game.defaultCamZoom * 1.08;
	FlxG.camera.fade(0xFF000000, 2.75, true, null, true);

	var dad = game.dad;
	var bf = game.boyfriend;

	// Original freezes this on frame 0 until the 0.90s mark, then replays it
	// for real. Not attempting the freeze here (uncertain whether pausing an
	// individual FlxAnimate mid-play is safe in this API) - it just plays
	// through once early, then replays at 0.90s, same as the "still" pose in
	// Blissful-pico's intro - see PORT_INFO.md.
	dad.playAnim('erectIntro1', true, false);
	tweenCamPos(538, 923, 3.4, FlxEase.expoOut);
	tweenCamZoomAbs(1.08, 3.4, FlxEase.expoOut);

	scheduleCutsceneTimer(0.90, function(_)
	{
		dad.playAnim('erectIntro1', true, false);
		FlxG.sound.play(Paths.sound('gameplay/cutsceneSfx/bf/qt_erect_intro_1'));
		showSubtitle('Alright, cutie...', 1.676);
	});

	scheduleCutsceneTimer(0.90 + 1.70, function(_) showSubtitle('Think you can keep up?', 1.45));

	scheduleCutsceneTimer(2.59, function(_)
	{
		tweenCamPos(510, 923, 3, FlxEase.expoOut);
		tweenCamZoomAbs(1.16, 3, FlxEase.expoOut);
	});

	scheduleCutsceneTimer(3.483, function(_)
	{
		tweenCamPos(1090, 931, 2.6, FlxEase.quartInOut);
		tweenCamZoomAbs(1.30, 2.6, FlxEase.quartInOut);
	});

	scheduleCutsceneTimer(4.341, function(_)
	{
		bf.playAnim('superHey', true, false);
		FlxG.sound.play(Paths.sound('gameplay/cutsceneSfx/bf/bf_erect_yeah'));
	});

	scheduleCutsceneTimer(5.7, function(_)
	{
		tweenCamPos(1040, 931, 0.8, FlxEase.elasticOut);
		tweenCamZoomAbs(1.16, 0.8, FlxEase.elasticOut);
	});

	scheduleCutsceneTimer(5.74, function(_) triggerPinkFlash([FlxG.camera]));

	scheduleCutsceneTimer(6, function(_) dad.playAnim('erectIntro2', true, false));

	scheduleCutsceneTimer(6.25, function(_)
	{
		tweenCamPos(510, 923, 2.5, FlxEase.quartInOut);
		tweenCamZoomAbs(1.16, 2.5, FlxEase.quartInOut);
	});

	scheduleCutsceneTimer(7.1, function(_)
	{
		FlxG.sound.play(Paths.sound('gameplay/cutsceneSfx/bf/qt_erect_intro_2'));
		showSubtitle("Pfft, we'll see about that!", 2.0);
	});

	scheduleCutsceneTimer(8.4, function(_)
	{
		tweenCamPos(dadFocusX(), dadFocusY(), 4.5, FlxEase.quartInOut);
		tweenCamZoomAbs(1.0, 4.5, FlxEase.quartInOut);
	});

	scheduleCutsceneTimer(9.8, function(_) finishIntroCutscene());
}

function finishIntroCutscene()
{
	activeCutsceneFinish = null;

	// Swap dad back to the real singing character before gameplay starts.
	game.triggerEvent('Change Character', 'dad', 'qt', 0);

	if (cameraZoomTween != null) cameraZoomTween.cancel();
	FlxG.camera.zoom = game.defaultCamZoom;

	game.inCutscene = false;
	game.camHUD.visible = true;
	game.camHUD.alpha = 0;
	FlxTween.tween(game.camHUD, {alpha: 1}, 1, {ease: FlxEase.smoothStepInOut});

	if (introMusic != null) introMusic.stop();
	game.startCountdown();
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

// Opponent-strumline dimming during the caramelldansen window, ported
// straight from blissful-erect.hxc's onBeatHit. Psych represents the
// strumline as a group of individual notes (opponentStrums), not a single
// object like the original's opponentStrumline, so each member is tweened.
function fadeOpponentStrums(target:Float)
{
	for (strum in game.opponentStrums.members)
		FlxTween.tween(strum, {alpha: target}, 1.5, {ease: FlxEase.quadInOut});
}

function onBeatHit()
{
	var beat:Int = getVar('curBeat');

	if (beat == 221) fadeOpponentStrums(0.3);
	else if (beat == 348) fadeOpponentStrums(1);
	else if (beat == 478) fadeOpponentStrums(0.3);
	else if (beat == 544) fadeOpponentStrums(1);

	if (bopRate <= 0 || bopIntensity == 1.0) return;
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
	updateSkipPrompt();

	if (!game.inCutscene && currentFlashIndex < gameplayFlashTimes.length)
	{
		if (Conductor.songPosition >= gameplayFlashTimes[currentFlashIndex])
		{
			triggerPinkFlash([game.camHUD]);
			currentFlashIndex++;
		}
	}
}
