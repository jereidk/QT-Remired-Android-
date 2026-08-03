import openfl.display.BlendMode;
import hxcodec.flixel.FlxVideo;
import substates.GameOverSubstate;

// --- Background layers ---
var tvStaticLeft:FlxSprite;
var tvStaticRight:FlxSprite;
var warningScreen:FlxSprite;
var blueScreen:FlxSprite;
var tvShadow:FlxSprite;
var wall:FlxSprite;
var tvShine:FlxSprite;
var tvLights:FlxSprite;
var tvFront:FlxSprite;
var tvFrontShine:FlxSprite;
var fgWireBack:FlxSprite;
var fgWireFront:FlxSprite;
var lightOverlay:FlxSprite;
var blackScreen:FlxSprite;
var spotLight:FlxSprite;
var redScreen:FlxSprite;

// --- Mid-song video cutscene, ported from obliterated.hxc's fadeStart/
// cutsceneVideo/cutsceneVideoOut chart events (see PORT_INFO.md). Confirmed
// via hxCodec's own source (pinned to v3.0.2 in hmm.json) that FlxVideo is a
// real, usable class here - it's a raw OpenFL Bitmap added directly to the
// stage (not a normal FlxSprite/game.add()), with play()/pause()/stop()/
// onEndReached matching what the original's FunkinVideoSprite wrapper
// exposed. Ghost-tap miss suppression while the video plays (isOnVideo in
// the original) isn't ported - Psych's noteMissPress fires after the miss
// penalty already applied, so there's no clean way to cancel it from here.
var blackScreenVideo:FlxSprite;
var midVideo:FlxVideo;
var isOnVideo:Bool = false;

// --- Sawblade dodge mechanic ---
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

	tvStaticLeft = new FlxSprite(-230, 523);
	tvStaticLeft.frames = Paths.getSparrowAtlas('obliterated/tv_static_assets');
	tvStaticLeft.animation.addByPrefix('static', 'static anim', 24, true);
	tvStaticLeft.animation.play('static');
	tvStaticLeft.scrollFactor.set(0.99, 0.99);
	game.add(tvStaticLeft);

	tvStaticRight = new FlxSprite(1231, 523);
	tvStaticRight.frames = Paths.getSparrowAtlas('obliterated/tv_static_assets');
	tvStaticRight.animation.addByPrefix('static', 'static anim', 24, true);
	tvStaticRight.animation.play('static');
	tvStaticRight.scrollFactor.set(0.99, 0.99);
	game.add(tvStaticRight);

	warningScreen = new FlxSprite(-115, 581);
	warningScreen.loadGraphic(Paths.image('obliterated/screen_danger'));
	warningScreen.scrollFactor.set(0.99, 0.99);
	game.add(warningScreen);

	blueScreen = new FlxSprite(-115, 581);
	blueScreen.loadGraphic(Paths.image('obliterated/blue_screens'));
	blueScreen.scrollFactor.set(0.99, 0.99);
	blueScreen.alpha = 0;
	game.add(blueScreen);

	tvShadow = new FlxSprite(-150, 530);
	tvShadow.loadGraphic(Paths.image('obliterated/tv_shadow'));
	tvShadow.scrollFactor.set(0.99, 0.99);
	game.add(tvShadow);

	wall = new FlxSprite(-649, -42);
	wall.loadGraphic(Paths.image('obliterated/bg'));
	wall.scrollFactor.set(0.99, 0.99);
	game.add(wall);

	tvShine = new FlxSprite(-306, 572);
	tvShine.loadGraphic(Paths.image('obliterated/tv_shine'));
	tvShine.scrollFactor.set(0.99, 0.99);
	game.add(tvShine);
}

function onCreatePost()
{
	tvLights = new FlxSprite(-332, 214);
	tvLights.frames = Paths.getSparrowAtlas('obliterated/tv_lights_assets');
	tvLights.animation.addByPrefix('Normal', 'tv lights animated', 24, true);
	tvLights.animation.addByPrefix('Killer', 'tv lights animated', 24, true);
	tvLights.animation.addByPrefix('Blue', 'blue', 24, true);
	tvLights.animation.addByPrefix('Red', 'red', 24, true);
	tvLights.animation.play('Normal');
	tvLights.blend = BlendMode.ADD;
	tvLights.scrollFactor.set(1, 1);
	game.add(tvLights);

	tvFront = new FlxSprite(-314, 873);
	tvFront.loadGraphic(Paths.image('obliterated/fg'));
	tvFront.scrollFactor.set(1.35, 1.35);
	game.add(tvFront);

	tvFrontShine = new FlxSprite(45, 873);
	tvFrontShine.loadGraphic(Paths.image('obliterated/fg_shine'));
	tvFrontShine.scrollFactor.set(1.35, 1.35);
	tvFrontShine.color = 0xFFC986BD;
	game.add(tvFrontShine);

	fgWireBack = new FlxSprite(-331, -48);
	fgWireBack.loadGraphic(Paths.image('obliterated/wire1'));
	fgWireBack.scrollFactor.set(1.5, 1.5);
	game.add(fgWireBack);

	fgWireFront = new FlxSprite(-361, -51);
	fgWireFront.loadGraphic(Paths.image('obliterated/wire2'));
	fgWireFront.scrollFactor.set(1.8, 1.8);
	game.add(fgWireFront);

	lightOverlay = new FlxSprite(-654, -60);
	lightOverlay.frames = Paths.getSparrowAtlas('common/gradientManager');
	lightOverlay.animation.addByPrefix('Normal', 'overlay-Normal', 24, true);
	lightOverlay.animation.addByPrefix('Killer', 'overlay-Killer', 24, true);
	lightOverlay.animation.addByPrefix('Blue', 'overlay-Killer', 24, true);
	lightOverlay.animation.addByPrefix('Red', 'overlay-Killer', 24, true);
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

	blackScreenVideo = new FlxSprite(-649, -42);
	blackScreenVideo.makeGraphic(2589, 1306, FlxColor.BLACK);
	blackScreenVideo.alpha = 0;
	blackScreenVideo.cameras = [game.camHUD];
	game.add(blackScreenVideo);

	midVideo = new FlxVideo();
	midVideo.autoResize = false;
	midVideo.visible = false;
	midVideo.x = 0;
	midVideo.y = 0;
	midVideo.width = FlxG.width;
	midVideo.height = FlxG.height;
	midVideo.onEndReached.add(function()
	{
		midVideo.stop();
		midVideo.visible = false;
		isOnVideo = false;
	});
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
	else if (eventName == 'changeStage') changeStageColor(value1);
	else if (eventName == 'blackIn') blackScreen.alpha = 1;
	else if (eventName == 'fadeStart')
	{
		fadeHud(0, 3);
		FlxTween.tween(blackScreenVideo, {alpha: 1}, 3, {ease: FlxEase.quadInOut});
	}
	else if (eventName == 'cutsceneVideo')
	{
		isOnVideo = true;
		midVideo.visible = true;
		midVideo.play(Paths.video('cutscene'));
		fadePlayerStrums(0.67, 2);
	}
	else if (eventName == 'cutsceneVideoOut')
	{
		isOnVideo = false;
		midVideo.stop();
		midVideo.visible = false;
		fadeHud(1, 0);
		blackScreenVideo.alpha = 0;
		fadePlayerStrums(1, 1);
	}
}

function fadePlayerStrums(target:Float, duration:Float)
{
	for (strum in game.playerStrums.members)
		FlxTween.tween(strum, {alpha: target}, duration, {ease: FlxEase.quadInOut});
}

// HUD dimming for the mid-song video cutscene (fadeStart/cutsceneVideoOut
// above) - dims health bar/score/opponent's side, matching the original's
// hudAlpha(), while leaving the player's own strumline/notes fully visible
// so gameplay stays playable during the video.
function fadeHud(target:Float, duration:Float)
{
	var targets:Array<Dynamic> = [game.healthBar, game.scoreTxt, game.iconP1, game.iconP2];
	for (t in game.opponentStrums.members) targets.push(t);

	if (duration <= 0)
	{
		for (t in targets) t.alpha = target;
	}
	else
	{
		for (t in targets) FlxTween.tween(t, {alpha: target}, duration, {ease: FlxEase.quadInOut});
	}
}

// Recolors tvLights/lightOverlay to match the chart's "changeStage" cues
// (Normal/Killer/Blue/Red) instead of actually swapping the background -
// the original only ever recolors these two props, it never changes the
// rest of the stage (see PORT_INFO.md).
function changeStageColor(mode:String)
{
	if (mode == null || mode.length < 1) mode = 'Normal';
	if (tvLights != null) tvLights.animation.play(mode);
	if (lightOverlay != null) lightOverlay.animation.play(mode == 'Normal' ? 'Normal' : 'Killer');
}

// Obliterated/Obliterated-legacy open on a black screen that fades in over
// the first 5s of the song, ported from obliterated.hxc's onCountdownStart/
// onSongStart/onSongRetry. The original also skips the visual countdown
// entirely (in story mode) via a private startSong() call we can't reach
// from HScript, and freezes boyfriend's "obliterated intro" pose (a
// frame-label anim on the mod's own bf-qt atlas, which isn't used for
// normal gameplay here - see limitation 1) - both dropped as low-value,
// higher-risk detail for a few seconds that's mostly hidden by the black
// screen anyway. game.skipCountdown gets the same "jump straight to the
// song" effect through public API instead of a private method call.
function onStartCountdown():Dynamic
{
	blackScreen.alpha = 1;
	game.camFollow.setPosition(1100, 655);
	camZoomState.zoom = 1.2;
	game.isCameraOnForcedPos = true;
	game.skipCountdown = true;
	return null;
}

function onSongStart()
{
	FlxTween.tween(blackScreen, {alpha: 0}, 5, {ease: FlxEase.quadInOut});
}

function onSongRetry()
{
	FlxTween.cancelTweensOf(blackScreen);
	blackScreen.alpha = 1;
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

// "DODGED!" popup on a successful dodge, ported from
// SawbladeAndDodgeModule.hxc's playState.popUpScore("dodged") - that call
// goes through the original engine's real judgement-popup pipeline, which
// Psych's equivalent (PlayState.popUpScore) is tightly coupled to actual
// note hits/combo/accuracy tracking, so hooking into it for a non-note event
// risked messing with scoring for no real benefit. This is a standalone
// sprite instead, positioned/animated like Psych's own rating popups
// (PlayState.hx's popUpScore: placement = FlxG.width * 0.35, screenCenter()
// then offset) - floats up and fades out over 0.6s.
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
		// death, ported from SawbladeAndDodgeModule.hxc's executeInstantKill()
		// (GameOverSubState.musicSuffix = '-sawblade'). Psych doesn't have a
		// music-suffix concept, but GameOverSubstate.loopSoundName/endSoundName
		// are public statics settable directly - and GameOverSubstate.
		// resetVariables() (which would reset them back to the song's default)
		// only runs once at PlayState.create(), long before this can fire, so
		// setting them here right before death sticks for this attempt.
		GameOverSubstate.loopSoundName = 'gameOver-sawblade';
		GameOverSubstate.endSoundName = 'gameOverEnd-sawblade';
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
