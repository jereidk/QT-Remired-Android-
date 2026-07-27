import openfl.display.BlendMode;

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

// --- Sawblade dodge mechanic ---
var sawSprite:FlxAnimate;
var warningVfx:FlxAnimate;
var dodgeActive:Bool = false;
var dodgeWindowStart:Float = 0;
var dodgeWindowEnd:Float = 0;
var dodgeUsed:Bool = false;

function onCreate()
{
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
	if (eventName == 'sawKB') startSawSequence();
}

function startSawSequence()
{
	var beat:Float = Conductor.crochet;

	FlxTween.tween(blackScreen, {alpha: 0.3}, 0.35, {ease: FlxEase.linear});
	playWarning('alert1');

	new FlxTimer().start(beat / 1000, function(_)
	{
		playWarning('alert2');
		spawnSaw();
		dodgeUsed = false;
		dodgeWindowStart = Conductor.songPosition;
		dodgeWindowEnd = Conductor.songPosition + beat;
		dodgeActive = true;
	});

	new FlxTimer().start((beat * 2) / 1000, function(_)
	{
		sawSprite.anim.play('attack', true);
		playWarning('attack');
		game.camGame.shake(0.007, 0.25);

		if (!dodgeUsed) applySawHit();

		dodgeActive = false;
		new FlxTimer().start(0.3, function(_) hideSawVisuals());
	});
}

function playWarning(anim:String)
{
	warningVfx.visible = true;
	warningVfx.anim.play(anim, true);
	warningVfx.screenCenter();
	playSfx(anim == 'attack' ? 'sawblades/attacks/attack-1' : 'sawblades/alerts/alert-1');
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

function applySawHit()
{
	var damage:Float = 2.0 * 0.5;
	game.health = Math.max(game.health - damage, 0);
	FlxG.camera.flash(0xFFff0000, 0.3);
	game.camGame.shake(0.008, 0.3);
}

function onUpdate(elapsed:Float)
{
	if (dodgeActive && !dodgeUsed && (FlxG.onMobile ? false : keyJustPressed('accept')))
	{
		tryDodge();
	}
}
