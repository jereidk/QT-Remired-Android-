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

// --- Simplified intro/outro cutscene (see PORT_INFO.md) ---
// The original (QtTransformSongOutro.hxc) drove a whole QT->robot transform
// character animation with a bus sprite and camera choreography. This is a
// scaled-down stand-in - fade to black, spotlight, the original "qtsfx" cue,
// hold, fade back - using only assets already on this stage, played once per
// song completion (matching the original's hasPlayedOutro guard).
var introCutscenePlayed:Bool = false;

function onEndSong():Dynamic
{
	if (introCutscenePlayed) return null;
	introCutscenePlayed = true;
	playIntroCutscene();
	return Function_Stop;
}

function playIntroCutscene()
{
	FlxTween.tween(blackScreen, {alpha: 1}, 1.0, {ease: FlxEase.quadOut});
	FlxTween.tween(spotLight, {alpha: 1}, 1.0, {
		ease: FlxEase.quadOut,
		onComplete: function(_)
		{
			FlxG.sound.play(Paths.sound('qtsfx'));
			new FlxTimer().start(3.5, function(_)
			{
				FlxTween.tween(blackScreen, {alpha: 0}, 1.0);
				FlxTween.tween(spotLight, {alpha: 0}, 1.0, {
					onComplete: function(_) game.endSong()
				});
			});
		}
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
