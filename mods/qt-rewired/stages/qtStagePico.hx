import openfl.display.BlendMode;
import states.PlayState;
import backend.Song;
import backend.Highscore;
import states.LoadingState;

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
var cars:FlxAnimate;

function onCreate()
{
	// Must run before the first onUpdate/applyCameraZoom() call - see the
	// "SetCameraBop" block below for why this can't just default to 1.0.
	camZoomState.zoom = game.defaultCamZoom;

	floorUnder = new FlxSprite(158, 460);
	floorUnder.makeGraphic(2045, 728, 0xFF4B7334);
	game.add(floorUnder);

	// "cars" is an Adobe Animate atlas with no symbol dictionary - just a
	// main timeline whose frame labels are car-0..car-3. addByFrameLabel
	// operates on that root timeline directly (unlike addBySymbol, which
	// needs a named symbol library entry).
	cars = new FlxAnimate(-600, 30);
	cars.showPivot = false;
	Paths.loadAnimateAtlas(cars, 'outskirts/cars');
	cars.anim.addByFrameLabel('car-0', 'car-0', 24, false);
	cars.anim.addByFrameLabel('car-1', 'car-1', 24, false);
	cars.anim.addByFrameLabel('car-2', 'car-2', 24, false);
	cars.anim.addByFrameLabel('car-3', 'car-3', 24, false);
	cars.anim.play('car-0');
	cars.scrollFactor.set(0.9, 1);
	game.add(cars);

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
	else if (eventName == 'SetCameraBop') setCameraBop(value1, value2);
	else if (eventName == 'PlayAnim') playCharAnim(value1, value2);
}

// Native "PlayAnimation" chart event (value1=target, value2=anim) - see
// qtStage.hx for the full rationale. Only dad(qt)'s preDance->cheer fires
// here (reusing the same qt.json entries added for Blissful base). The
// chart's own boyfriend(pico-qt)/girlfriend(gf-qt) cues for this same
// moment - cough/burp-long/preDance/hey on pico-qt, huh/combo50 on gf-qt -
// aren't ported: pico-qt is already a vanilla-Pico-sprite fallback with none
// of those poses (limitation 1), and gf-qt's atlas has no huh/combo50
// symbols. gf-qt's own "cheer" at this same moment DOES fire, though -
// same entry already added for Blissful base.
function playCharAnim(target:String, anim:String)
{
	var char:Dynamic = null;
	if (target == 'dad') char = game.dad;
	else if (target == 'boyfriend') char = game.boyfriend;
	else if (target == 'girlfriend') char = game.gf;
	if (char != null) char.playAnim(anim, true);
}

// --- Blissful Pico intro cutscene, ported from blissful-pico.hxc's
// onCountdownStart(). Runs once before the real countdown via the
// onStartCountdown/Function_Stop hook (same interception pattern the
// onEndSong cutscenes use elsewhere). Camera choreography, dad's
// "still"/"intro" frame-label poses (already on the qt atlas), a standalone
// overlay for bf's "introbl" pose, the hi_cutie/picoWave/introSong-pico
// sound cues, the hi-cutie subtitle (showSubtitle() below), and the skip-key
// prompt (setupSkipPrompt()/updateSkipPrompt() below) are kept. The GF
// beat-synced head bop and the 1%-chance easter egg branch (which even
// opens a YouTube URL in the original) are dropped - see PORT_INFO.md.
var hasPlayedIntroCutscene:Bool = false;
var picoOverlay:FlxAnimate;

function onStartCountdown():Dynamic
{
	if (hasPlayedIntroCutscene) return null;
	hasPlayedIntroCutscene = true;
	playIntroCutscene();
	return Function_Stop;
}

function dadFocusX():Float return game.dad.getMidpoint().x + 150 + game.dad.cameraPosition[0] + game.opponentCameraOffset[0];
function dadFocusY():Float return game.dad.getMidpoint().y - 100 + game.dad.cameraPosition[1] + game.opponentCameraOffset[1];
function playerFocusX():Float return game.boyfriend.getMidpoint().x - 100 - (game.boyfriend.cameraPosition[0] - game.boyfriendCameraOffset[0]);
function playerFocusY():Float return game.boyfriend.getMidpoint().y - 100 + game.boyfriend.cameraPosition[1] + game.boyfriendCameraOffset[1];

function playIntroCutscene()
{
	game.inCutscene = true;
	game.isCameraOnForcedPos = true;
	game.camHUD.visible = false;
	game.camHUD.alpha = 0;

	setupSkipPrompt();
	activeCutsceneFinish = finishIntroCutscene;

	// GF bops along at 103 BPM during the cutscene - the original drives this
	// off a secondary Conductor synced to introSong-pico; simplified here to
	// a fixed-interval repeating timer since the main Conductor isn't
	// running yet during this pre-song cutscene. 18 loops covers ~10.5s of
	// the ~11s cutscene.
	scheduleCutsceneTimer(60 / 103, function(_) { if (game.gf != null) game.gf.dance(); }, 18);

	if (game.dad.atlas != null)
	{
		game.dad.atlas.anim.addByFrameLabel('still', 'hi cutie', 24, false);
		game.dad.atlas.anim.addByFrameLabel('intro', 'hi cutie', 24, false);
	}

	// pico-qt's own character uses the vanilla Pico sprite for gameplay (the
	// mod's own Pico atlas only has cutscene-specific poses, no base sing/idle
	// - see PORT_INFO.md), so this pose is a standalone FlxAnimate overlay
	// positioned at bf's anchor + the original animation's own offset. Not
	// pixel-exact against the vanilla rig - documented approximation.
	picoOverlay = new FlxAnimate(0, 0);
	picoOverlay.showPivot = false;
	Paths.loadAnimateAtlas(picoOverlay, 'characters/PICO/all');
	picoOverlay.anim.addByFrameLabel('introbl', 'blissful intro', 24, false);
	picoOverlay.visible = false;
	game.add(picoOverlay);

	if (cameraFollowTween != null) cameraFollowTween.cancel();
	if (cameraZoomTween != null) cameraZoomTween.cancel();
	game.camFollow.setPosition(dadFocusX(), dadFocusY() - 235);

	FlxG.sound.play(Paths.music('gameplay/introSong/introSong-pico'), 0.1);
	FlxG.camera.fade(0xFF000000, 2.75, true, null, true);

	game.dad.playAnim('still', true, true);

	tweenCamPos(dadFocusX(), dadFocusY(), 2.75, FlxEase.expoOut);
	tweenCamZoomAbs(1.1875, 2.75, FlxEase.expoOut);

	scheduleCutsceneTimer(0.5, function(_) game.dad.playAnim('intro', true, false));

	scheduleCutsceneTimer(0.98, function(_)
	{
		FlxG.sound.play(Paths.sound('gameplay/countdown/hi_cutie'), 1);
		showSubtitle('Hi Cutie!', 3.963);
	});

	scheduleCutsceneTimer(3.5, function(_)
	{
		tweenCamPos(playerFocusX() + 100, playerFocusY(), 3, FlxEase.quadInOut);
		game.boyfriend.visible = false;
		picoOverlay.setPosition(game.boyfriend.x + 55, game.boyfriend.y + 16.87);
		picoOverlay.visible = true;
		picoOverlay.anim.play('introbl', true);
	});

	scheduleCutsceneTimer(4.15, function(_) FlxG.sound.play(Paths.sound('gameplay/cutsceneSfx/pico/introCutscene/picoWave')));

	scheduleCutsceneTimer(6.35, function(_) tweenCamZoomAbs(1.25, 1.5, FlxEase.quadInOut));

	scheduleCutsceneTimer(11, function(_) finishIntroCutscene());
}

function finishIntroCutscene()
{
	activeCutsceneFinish = null;
	game.boyfriend.visible = true;
	if (picoOverlay != null)
	{
		picoOverlay.visible = false;
		game.remove(picoOverlay);
	}
	if (cameraZoomTween != null) cameraZoomTween.cancel();
	camZoomState.zoom = game.defaultCamZoom;
	game.inCutscene = false;
	game.camHUD.visible = true;
	game.camHUD.alpha = 0;
	FlxTween.tween(game.camHUD, {alpha: 1}, 1, {ease: FlxEase.smoothStepInOut});
	game.startCountdown();
}

// Blissful-pico only has an intro cutscene, no outro - a win redirects to
// the "QT-Rewired" master menu song immediately instead of Psych's real
// Freeplay/Story Mode - see qtStage.hx for the full rationale.
function onEndSong():Dynamic
{
	returnToQtRewiredMenu();
	return Function_Stop;
}

function returnToQtRewiredMenu()
{
	// game.endSong() would normally save the highscore itself - since it's
	// bypassed entirely (see qtStage.hx's returnToQtRewiredMenu comment),
	// this replicates that one piece of it manually so scores/progressive
	// unlock (see qtStageMenu.hx) still work.
	var percent:Float = game.ratingPercent;
	if (Math.isNaN(percent)) percent = 0;
	Highscore.saveScore(PlayState.SONG.song, game.songScore, game.storyDifficulty, percent);

	PlayState.SONG = Song.loadFromJson('qt-rewired', 'qt-rewired');
	PlayState.isStoryMode = false;
	FlxG.sound.music.volume = 0;
	LoadingState.loadAndSwitchState(new PlayState());
}

function tweenCamPos(x:Float, y:Float, duration:Float, ease:Float->Float)
{
	if (cameraFollowTween != null) cameraFollowTween.cancel();
	cameraFollowTween = FlxTween.tween(game.camFollow, {x: x, y: y}, duration, {ease: ease});
}

function tweenCamZoomAbs(mult:Float, duration:Float, ease:Float->Float)
{
	if (cameraZoomTween != null) cameraZoomTween.cancel();
	cameraZoomTween = FlxTween.tween(camZoomState, {zoom: game.defaultCamZoom * mult}, duration, {ease: ease});
}

// Subtitle for the cutscene above (see PORT_INFO.md) - the original's
// hi-cutie.srt only has one short entry, hardcoded here as plain
// text+duration instead of parsing .srt at runtime. Toggled by the
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

// --- Cutscene skip prompt (see PORT_INFO.md) - ported from the original's
// skipText/canSkipCutscene/cutsceneSkipped pattern: first press of the skip
// key fades in a "Hold [ACCEPT] to skip" prompt over 0.5s, a second press
// after that actually skips. Every FlxTimer inside the cutscene is created
// via scheduleCutsceneTimer() instead of "new FlxTimer()" directly so skip
// can cancel all of them at once. Known gap: skipping while an
// FlxG.camera.fade() is actively running won't cancel that fade (no verified
// way to do that from HScript).
var cutsceneTimers:Array<FlxTimer> = [];
var skipText:FlxText;
var canSkipCutscene:Bool = false;
var cutsceneSkipped:Bool = false;
var activeCutsceneFinish:Void->Void;

function scheduleCutsceneTimer(time:Float, cb:Float->Void, loops:Int = 1):FlxTimer
{
	var t:FlxTimer = new FlxTimer().start(time, cb, loops);
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
		camZoomState.zoom = target;
		return;
	}

	var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
	cameraZoomTween = FlxTween.tween(camZoomState, {zoom: target}, durSeconds, {ease: resolveEase(ease)});
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
// instead of a fixed-duration up/down tween. The camera's "intended" zoom
// (whatever ZoomCamera events/cutscenes want) is tracked separately in
// camZoomState.zoom instead of writing FlxG.camera.zoom directly, so it
// composes cleanly with the bop multiplier every frame (applyCameraZoom())
// instead of the two systems fighting over the same field - see
// PORT_INFO.md. camZoomState.zoom MUST be initialized to game.defaultCamZoom
// in onCreate (see above) before the first applyCameraZoom() call.
var camZoomState = {zoom: 1.0};
var cameraBopMultiplier:Float = 1.0;

function onBeatHit()
{
	if (bopRate <= 0 || bopIntensity == 1.0) return;

	var beat:Int = getVar('curBeat');
	if (Math.round((beat + bopOffset) % bopRate) != 0) return;

	cameraBopMultiplier = bopIntensity;
}

function decayCameraBop(elapsed:Float)
{
	if (cameraBopMultiplier == 1.0) return;

	var decayRate:Float = 0.95;
	var dt:Float = elapsed * 60;
	cameraBopMultiplier = 1.0 + (cameraBopMultiplier - 1.0) * Math.pow(decayRate, dt);

	if (Math.abs(cameraBopMultiplier - 1.0) < 0.0005) cameraBopMultiplier = 1.0;
}

function applyCameraZoom()
{
	FlxG.camera.zoom = camZoomState.zoom * cameraBopMultiplier;
}

function onUpdate(elapsed:Float)
{
	decayCameraBop(elapsed);
	applyCameraZoom();
	updateSkipPrompt();
}
