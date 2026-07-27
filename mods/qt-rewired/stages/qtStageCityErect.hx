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
