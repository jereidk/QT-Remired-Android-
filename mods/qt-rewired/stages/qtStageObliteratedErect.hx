import openfl.display.BlendMode;
import hxcodec.flixel.FlxVideo;
import shaders.ColorSwap;
import substates.GameOverSubstate;

// --- Mid-song cinematic (two videos + camera/HUD fades + layout change),
// ported from obliterated-erect.hxc's onSongStart/onStepHit/onUpdate. Uses
// the same hxCodec/FlxVideo approach already shipped for Obliterated
// base's cutsceneVideo (see qtStageKiller.hx/PORT_INFO.md) plus
// game.camGame.fade(), which this mod already uses elsewhere (see
// qtStagePico.hx's playIntroCutscene) - so unlike the video import, the
// camera-fade calls here have an already-shipped precedent in this same
// codebase, not just an assumption from the original source.
var huzzVideo:FlxVideo;
var editVideo:FlxVideo;
var tsundereOverlay:FlxAnimate;
var strumOriginalX:Array<Float> = [];
var strumPositionsCaptured:Bool = false;
var colorGrade:ColorSwap;

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
	// Must run before the first onUpdate/applyCameraZoom() call - see the
	// "SetCameraBop" block below for why this can't just default to 1.0.
	camZoomState.zoom = game.defaultCamZoom;

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

	// Color grading for the whole song, ported from QtStageObliteratedErect.hxc's
	// buildStage()/addCharacter() (updateColorShader(-30, -65, 10, -60) applied
	// to bf/dad/gf via a shared AdjustColorShader). Psych doesn't have that
	// exact shader class, but does ship its own hue/saturation/brightness
	// shader (shaders.ColorSwap, source/shaders/ColorSwap.hx) - real, compiled
	// into the engine, so importing it here carries none of the "might not
	// resolve at build time" risk that hxCodec below does. What's lost:
	// ColorSwap has no contrast control (the original's contrast=10 is
	// dropped), and there's no equivalent at all for the original's
	// DropShadowShader rim-light glow on dad/gf (no such shader ships with
	// Psych) - both are approximations, not exact matches, and can't be
	// visually verified in this environment. Unit conversion assumption:
	// the original's hue/saturation/brightness read like a standard
	// Photoshop-style HSB adjustment (hue in degrees -180..180, saturation/
	// brightness as percent -100..100), while ColorSwap adds hue/saturation
	// directly to the normalized (0..1) HSV components and multiplies
	// brightness by (1 + value) - so the constants are converted accordingly
	// (hue/360, saturation/100, brightness/100) rather than used raw.
	colorGrade = new ColorSwap();
	colorGrade.hue = -30 / 360;
	colorGrade.saturation = -65 / 100;
	colorGrade.brightness = -60 / 100;
	if (game.boyfriend != null) game.boyfriend.shader = colorGrade.shader;
	if (game.dad != null) game.dad.shader = colorGrade.shader;
	if (game.gf != null) game.gf.shader = colorGrade.shader;

	// Mid-song cinematic: two videos overlaid on live gameplay, ported from
	// obliterated-erect.hxc's onUpdate() video1Triggered/video2Triggered
	// blocks - same hxCodec/FlxVideo approach and the same accepted import
	// risk already shipped for Obliterated base's cutsceneVideo (see
	// qtStageKiller.hx/PORT_INFO.md).
	huzzVideo = new FlxVideo();
	huzzVideo.autoResize = false;
	huzzVideo.visible = false;
	huzzVideo.x = 0;
	huzzVideo.y = 0;
	huzzVideo.width = FlxG.width;
	huzzVideo.height = FlxG.height;

	editVideo = new FlxVideo();
	editVideo.autoResize = false;
	editVideo.visible = false;
	editVideo.x = 0;
	editVideo.y = 0;
	editVideo.width = FlxG.width;
	editVideo.height = FlxG.height;
	editVideo.onEndReached.add(function()
	{
		editVideo.stop();
		editVideo.visible = false;
		// Fallback in case the chart's own dadTsundere event (below) somehow
		// doesn't line up with hxCodec's actual video duration - idempotent,
		// safe to call twice.
		showTsundereOverlay();
	});

	// dad's "tsundere" ending pose (kb.json's kb-erect-end atlas), shown once
	// editVideo finishes - see showTsundereOverlay() below. The original's
	// earlier "intro-erect" frozen pose (frame 0 held from song start,
	// resumed at step 34) is NOT ported: freezing/resuming an FlxAnimate
	// mid-playback via HScript is unverified in this environment (same
	// reasoning already applied to Blissful-erect's erectIntro1 pose - see
	// PORT_INFO.md), and the pose is almost entirely hidden by the 12.5s
	// camera fade-in anyway, so dad just plays his normal animations for
	// those first few seconds instead.
	tsundereOverlay = new FlxAnimate(0, 0);
	tsundereOverlay.showPivot = false;
	Paths.loadAnimateAtlas(tsundereOverlay, 'characters/kb_export/kb-erect-end');
	tsundereOverlay.anim.addBySymbol('tsundere', 'exportanim', 24, false);
	tsundereOverlay.visible = false;
	game.add(tsundereOverlay);

	// HUD (health bar/score/icons/both strumlines) starts fully hidden, same
	// as the original's onSongLoaded doHudFade(0, 0, true) - restored by the
	// "hudFadeIn" event partway through the song (see onEvent below).
	fadeHud(0, 0, true);
}

// Skips the visual countdown entirely (same public-API substitute for the
// original's private startSong()/Countdown.stopCountdown() calls already
// used in qtStageKiller.hx's onStartCountdown - see PORT_INFO.md), then the
// long fade-in from black starts exactly when the song itself starts,
// ported from onSongStart's camGame.fade(BLACK, 12.5, true, null, true).
function onStartCountdown():Dynamic
{
	game.skipCountdown = true;
	return null;
}

function onSongStart()
{
	game.camGame.fade(FlxColor.BLACK, 12.5, true, null, true);
}

function onSongRetry()
{
	FlxTween.cancelTweensOf(game.healthBar);
	FlxTween.cancelTweensOf(game.scoreTxt);
	FlxTween.cancelTweensOf(game.iconP1);
	FlxTween.cancelTweensOf(game.iconP2);

	huzzVideo.stop();
	huzzVideo.visible = false;
	editVideo.stop();
	editVideo.visible = false;
	tsundereOverlay.visible = false;
	if (game.dad != null) game.dad.visible = true;

	restorePlayerStrumPositions();
	game.opponentStrums.visible = true;

	fadeHud(0, 0, true);
	sawInstakillDeath = false;
}

// A distinct mood for dying to an instakill sawblade hit vs a normal miss -
// see qtStageKiller.hx for the full rationale (the original's real
// "fakeoutDeath" jumpscare pose/sound has no asset anywhere in this mod's
// copied package - this is a same-spirit substitute using only things
// already proven safe here, not new content).
var sawInstakillDeath:Bool = false;

function onGameOverStart()
{
	if (!sawInstakillDeath) return;
	if (GameOverSubstate.instance == null) return;

	FlxG.camera.shake(0.015, 0.5);

	var vignette:FlxSprite = new FlxSprite(0, 0);
	vignette.makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), 0xFF8B0000);
	vignette.scrollFactor.set();
	vignette.blend = BlendMode.MULTIPLY;
	vignette.alpha = 0.6;
	GameOverSubstate.instance.add(vignette);
	FlxTween.tween(vignette, {alpha: 0}, 2.2, {ease: FlxEase.quadOut});
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
	// --- Mid-song cinematic events, synthetic (injected into events.json at
	// the original's hardcoded timestamps - see PORT_INFO.md), matching
	// obliterated-erect.hxc's onUpdate() one-shot triggers 1:1. ---
	else if (eventName == 'camFade2') game.camGame.fade(FlxColor.BLACK, 1.773, false, null, true);
	else if (eventName == 'hudFadeOut1') fadeHud(0, 1.8, true);
	else if (eventName == 'video1Start')
	{
		huzzVideo.visible = true;
		huzzVideo.play(Paths.video('obliteratedErectMid'));
	}
	else if (eventName == 'layoutChange')
	{
		centerPlayerStrums();
		game.opponentStrums.visible = false;
	}
	else if (eventName == 'hudFadeIn') fadeHud(1, 2.9, false);
	else if (eventName == 'video2Start')
	{
		huzzVideo.stop();
		huzzVideo.visible = false;
		editVideo.visible = true;
		editVideo.play(Paths.video('obliteratedErectEdit'));
	}
	else if (eventName == 'camFade3') game.camGame.fade(FlxColor.BLACK, 9.5, true, null, true);
	// The original chart itself already has a native "PlayAnimation" event
	// for this (target: dad, anim: tsundere, t=179052.63) - very close to
	// but not literally the same trigger as editVideo's own onEndReached
	// (which also calls showTsundereOverlay() as a fallback below). Using
	// the chart's own fixed timestamp is more reliable than depending on
	// hxCodec's onEndReached firing at exactly the right moment - see
	// PORT_INFO.md. The chart's matching "PlayAnimation" for boyfriend
	// ('tired', t=178302.63) is NOT ported - bf-qt's atlas has no such
	// animation.
	else if (eventName == 'dadTsundere') showTsundereOverlay();
	else if (eventName == 'hudFadeOut2') fadeHud(0, 5.0, false);
	else if (eventName == 'camFade4') game.camGame.fade(FlxColor.BLACK, 4.65, false, null, true);
}

// HUD fade helper covering health bar/score/icons/player strumline, and
// optionally the opponent strumline too - ported from doHudFade(). Toggles
// each strumline group's own .visible immediately (fade-in) or once the
// tween finishes (fade-out) since FlxTypedGroup has no .alpha to tween
// directly (see PORT_INFO.md) - members are tweened individually, and
// safely resolve to zero iterations before generateStaticArrows() has run
// (onCreatePost's initial fadeHud(0, 0, true) call), since the groups
// themselves are already toggled visible=false at that point regardless.
function fadeHud(target:Float, duration:Float, includeOpponent:Bool)
{
	var targets:Array<Dynamic> = [game.healthBar, game.scoreTxt, game.iconP1, game.iconP2];
	for (t in game.playerStrums.members) targets.push(t);
	if (includeOpponent) for (t in game.opponentStrums.members) targets.push(t);

	if (duration <= 0)
	{
		for (t in targets) if (t != null) t.alpha = target;
		game.playerStrums.visible = (target > 0);
		if (includeOpponent) game.opponentStrums.visible = (target > 0);
		return;
	}

	if (target > 0)
	{
		game.playerStrums.visible = true;
		if (includeOpponent) game.opponentStrums.visible = true;
	}

	for (t in targets)
	{
		if (t == null) continue;
		FlxTween.tween(t, {alpha: target}, duration, {ease: FlxEase.quadInOut});
	}

	if (target <= 0)
	{
		new FlxTimer().start(duration, function(_)
		{
			game.playerStrums.visible = false;
			if (includeOpponent) game.opponentStrums.visible = false;
		});
	}
}

// Shifts the player strumline (all 4 arrows) so it's horizontally centered
// on screen, ported from centerPlayerStrumline() - the original also skips
// this when using an alternate ("Arrows") control scheme, which Psych has
// no equivalent toggle for, so it's always applied here.
function centerPlayerStrums()
{
	captureStrumPositions();
	if (game.playerStrums.members.length == 0) return;

	var minX:Float = 999999;
	var maxX:Float = -999999;
	for (strum in game.playerStrums.members)
	{
		if (strum.x < minX) minX = strum.x;
		if (strum.x + strum.width > maxX) maxX = strum.x + strum.width;
	}

	var delta:Float = (FlxG.width / 2) - ((minX + maxX) / 2);
	for (strum in game.playerStrums.members) strum.x += delta;
}

function captureStrumPositions()
{
	if (strumPositionsCaptured) return;
	strumPositionsCaptured = true;
	for (strum in game.playerStrums.members) strumOriginalX.push(strum.x);
}

function restorePlayerStrumPositions()
{
	if (!strumPositionsCaptured) return;
	var i:Int = 0;
	for (strum in game.playerStrums.members)
	{
		if (i < strumOriginalX.length) strum.x = strumOriginalX[i];
		i++;
	}
}

// dad's ending pose after the editVideo cutscene, ported from editVideo's
// onEndReached (dad.playAnimation('tsundere', true, true)) - shown as a
// standalone FlxAnimate overlay instead of a real character animation
// (same approach as qtStagePico.hx's picoOverlay/qtStageCityErect.hx's
// erectIntro poses - see PORT_INFO.md), since Psych characters can't swap
// mid-song to an animation living in a different, separate atlas file. Left
// up for the rest of the song - the original never reverts it either.
function showTsundereOverlay()
{
	if (game.dad == null) return;
	game.dad.visible = false;
	tsundereOverlay.setPosition(game.dad.x - 124, game.dad.y - 182);
	tsundereOverlay.visible = true;
	tsundereOverlay.anim.play('tsundere', true);
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
		showDodgedPopup();
	}
	else
	{
		dodgeUsed = false; // too early, doesn't count
	}
}

// "DODGED!" popup on a successful dodge - see qtStageKiller.hx for the full
// rationale (ported from SawbladeAndDodgeModule.hxc's popUpScore("dodged"),
// implemented as a standalone sprite instead of hooking Psych's real
// judgement-popup pipeline).
function showDodgedPopup()
{
	var popup:FlxSprite = new FlxSprite();
	popup.loadGraphic(Paths.image('ui/popup/funkin/dodged'));
	popup.scrollFactor.set();
	popup.cameras = [game.camHUD];
	popup.screenCenter();
	popup.x = (FlxG.width * 0.35) - (popup.width / 2);
	popup.y -= 60;
	popup.zIndex = 950;
	game.add(popup);

	FlxTween.tween(popup, {y: popup.y - 100, alpha: 0}, 0.6, {
		ease: FlxEase.quadOut,
		onComplete: function(_) game.remove(popup)
	});
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
	{
		// Distinct, more dramatic Game Over music for an instakill sawblade
		// death - see qtStageKiller.hx for the full rationale.
		GameOverSubstate.loopSoundName = 'gameOver-sawblade';
		GameOverSubstate.endSoundName = 'gameOverEnd-sawblade';
		sawInstakillDeath = true;
		game.health = 0;
	}
	else
		game.health = Math.max(game.health - 1.0, 0);

	FlxG.camera.flash(0xFFff0000, 0.3);
	game.camGame.shake(0.008, 0.3);
}

function onUpdate(elapsed:Float)
{
	decayCameraBop(elapsed);
	applyCameraZoom();

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
