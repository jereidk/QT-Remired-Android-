var stageBack:FlxSprite;
var floorSprite:FlxSprite;
var tvs:FlxSprite;

function onCreate()
{
	// Must run before the first onUpdate/applyCameraZoom() call - see the
	// "SetCameraBop" block below for why this can't just default to 1.0.
	camZoomState.zoom = game.defaultCamZoom;

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

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	if (eventName == 'FocusCamera') focusCamera(value1, value2);
	else if (eventName == 'ZoomCamera') zoomCamera(value1, value2);
	else if (eventName == 'SetCameraBop') setCameraBop(value1, value2);
}

// --- "Kade Engine 2021" throwback HUD, ported from blissful-2021.hx.
// Replaces Psych's native score text with a custom score/accuracy/rank
// line (own formulas, matching the original's judgement vocabulary 1:1 -
// verified against source that Psych's own Rating.hx uses the exact same
// 'sick'/'good'/'bad'/'shit' names), a per-note ms-timing popup, and a
// watermark. The original also had a bunch of settings toggles
// (baseGameRank/baseGameAccuracy/lerpEverything/judgementCounter/
// holdSplashes/noteSplashes/disableKeWatermark) all OFF by default except
// the watermark being ON - only that default configuration is ported here,
// the toggles themselves aren't (see PORT_INFO.md). Deliberately does NOT
// port handleFakeLag(), a function that burns CPU on purpose as a period
// joke - see PORT_INFO.md.
var scoreTxt2021:FlxText;
var msDisplayText2021:FlxText;
var msTween2021:FlxTween;

var tallySick:Int = 0;
var tallyGood:Int = 0;
var tallyBad:Int = 0;
var tallyShit:Int = 0;
var tallyMissed:Int = 0;
var totalNotesHitWeighted:Float = 0;
var totalNotesPlayed:Int = 0;
var notesHitArray:Array<Float> = [];
var nps:Int = 0;

function onCreatePost()
{
	game.scoreTxt.visible = false;

	var isAltMode:Bool = ClientPrefs.data.downScroll || FlxG.onMobile;
	var scoreX:Float = 0;
	var scoreY:Float = 0;
	var fieldWidth:Float = 0;
	var align:String = 'left';

	if (isAltMode)
	{
		scoreX = 0;
		scoreY = FlxG.height * 0.17;
		fieldWidth = FlxG.width;
		align = 'center';
	}
	else
	{
		scoreX = FlxG.width * 0.35;
		scoreY = game.healthBar.y + 50;
		fieldWidth = 0;
		align = 'left';
	}

	scoreTxt2021 = new FlxText(scoreX, scoreY, fieldWidth, generateScoreString(), 16);
	scoreTxt2021.setFormat(Paths.font('vcr.ttf'), 16, 0xFFFFFFFF, align, FlxTextBorderStyle.OUTLINE, 0xFF000000);
	scoreTxt2021.scrollFactor.set();
	scoreTxt2021.cameras = [game.camHUD];
	game.add(scoreTxt2021);

	var watermark:FlxText = new FlxText(4, 0, 0, game.songName + ' ' + game.storyDifficultyText + ' - KE 1.4.2', 16);
	watermark.setFormat(Paths.font('vcr.ttf'), 16, 0xFFFFFFFF, 'left', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	watermark.y = FlxG.height - watermark.height - 4;
	watermark.scrollFactor.set(0, 0);
	watermark.cameras = [game.camHUD];
	game.add(watermark);
}

function goodNoteHit(note:Dynamic)
{
	switch (note.rating)
	{
		case 'sick': tallySick++;
		case 'good': tallyGood++;
		case 'bad': tallyBad++;
		case 'shit': tallyShit++;
	}

	if (note.rating != 'sick')
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - note.strumTime);
		var addShit:Float = 35 / noteDiff;

		totalNotesHitWeighted += (addShit > 1 ? 1 : addShit);
		totalNotesPlayed++;
		notesHitArray.unshift(note.strumTime);

		makeMsDisplay(Conductor.songPosition - note.strumTime, note.rating);
	}
}

function noteMiss(note:Dynamic)
{
	tallyMissed++;
	totalNotesPlayed++;
}

function makeMsDisplay(differenceRaw:Float, judgement:String)
{
	if (msDisplayText2021 == null)
	{
		msDisplayText2021 = new FlxText(0, 0, 0, '', 16);
		msDisplayText2021.borderStyle = FlxTextBorderStyle.OUTLINE;
		msDisplayText2021.borderSize = 1;
		msDisplayText2021.borderColor = 0xFF000000;
		msDisplayText2021.x = (FlxG.width * 0.507) + 100;
		msDisplayText2021.y = (FlxG.height * 0.45 - 60) + 100;
		msDisplayText2021.cameras = [game.camHUD];
		game.add(msDisplayText2021);
	}

	if (msTween2021 != null) msTween2021.cancel();

	var colorCode:Int = 0xFFFFFFFF;
	switch (judgement)
	{
		case 'shit' | 'bad': colorCode = 0xFFFF0000;
		case 'good': colorCode = 0xFF00FF00;
		case 'sick': colorCode = 0xFF00FFFF;
	}

	msDisplayText2021.color = colorCode;
	msDisplayText2021.text = truncateFloat(differenceRaw, 2) + 'ms';
	msDisplayText2021.alpha = 1;

	msTween2021 = FlxTween.tween(msDisplayText2021, {alpha: 0}, 0.2, {startDelay: 0.1});
}

function truncateFloat(number:Float, precision:Int):Float
{
	var num:Float = number * Math.pow(10, precision);
	return Math.round(num) / Math.pow(10, precision);
}

function getAccuracy():Float
{
	var accuracy:Float = totalNotesHitWeighted / totalNotesPlayed * 100;
	if (!Math.isFinite(accuracy)) return 0;
	return accuracy;
}

// Thresholds collapsed from the original's redundant cascade (e.g. it
// checked >=99.90/>=99.80/>=99.70 as three separate branches all producing
// "AAA." - only the lowest bound of each group matters).
function generateRanking():String
{
	var misses:Int = tallyMissed;
	var bads:Int = tallyBad;
	var shits:Int = tallyShit;
	var goods:Int = tallyGood;
	var accuracy:Float = getAccuracy();

	var ranking:String = 'N/A';
	if (misses == 0 && bads == 0 && shits == 0 && goods == 0) ranking = '(MFC)';
	else if (misses == 0) ranking = '(GFC)';
	else if (misses < 10) ranking = '(SDCB)';
	else ranking = '(Clear)';

	if (accuracy >= 99.9935) ranking += ' AAAAA.';
	else if (accuracy >= 99.955) ranking += ' AAAA.';
	else if (accuracy >= 99.70) ranking += ' AAA.';
	else if (accuracy >= 93) ranking += ' AA.';
	else if (accuracy >= 80) ranking += ' A.';
	else if (accuracy >= 70) ranking += ' B.';
	else if (accuracy >= 60) ranking += ' C.';
	else ranking += ' D.';

	if (accuracy == 0) ranking = 'N/A';
	return ranking;
}

function generateScoreString():String
{
	var score:Int = game.songScore;
	var misses:Int = tallyMissed + tallyBad + tallyShit;
	var accuracy:Float = getAccuracy();

	var textString:String = 'NPS: ' + nps + ' | ';
	textString += 'Score: ' + score + ' | Combo Breaks:' + misses + ' | Accuracy:' + truncateFloat(accuracy, 2) + '% | ' + generateRanking();
	return textString;
}

function onSongRetry()
{
	tallySick = 0;
	tallyGood = 0;
	tallyBad = 0;
	tallyShit = 0;
	tallyMissed = 0;
	totalNotesHitWeighted = 0;
	totalNotesPlayed = 0;
	notesHitArray = [];
	nps = 0;
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

	if (scoreTxt2021 != null) scoreTxt2021.text = generateScoreString();

	var currentTime:Float = Conductor.songPosition;
	while (notesHitArray.length > 0 && notesHitArray[notesHitArray.length - 1] + 1000 < currentTime)
		notesHitArray.pop();
	nps = notesHitArray.length;
}
