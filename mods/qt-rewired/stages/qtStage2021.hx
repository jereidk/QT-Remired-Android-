var stageBack:FlxSprite;
var floorSprite:FlxSprite;
var tvs:FlxSprite;

function onCreate()
{
	stageBack = new FlxSprite(-750, -145);
	stageBack.loadGraphic(Paths.image('2021/streetBackCute'));
	stageBack.scrollFactor.set(0.9, 0.9);
	game.add(stageBack);

	floorSprite = new FlxSprite(-820, 710);
	floorSprite.loadGraphic(Paths.image('2021/streetFrontCute'));
	floorSprite.scale.set(1.15, 1.15);
	floorSprite.updateHitbox();
	floorSprite.scrollFactor.set(0.9, 0.9);
	game.add(floorSprite);

	tvs = new FlxSprite(-62, 540);
	tvs.loadGraphic(Paths.image('2021/TV_V2_off'));
	tvs.scale.set(1.2, 1.2);
	tvs.updateHitbox();
	tvs.scrollFactor.set(0.9, 0.9);
	game.add(tvs);
}
