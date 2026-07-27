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
