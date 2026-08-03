import substates.GameOverSubstate;

// Ported from GameOverSubtitles.hxc (a global Module in the original, hooked
// to GameOverSubState via onSubStateOpenEnd/onUpdate) - on death, the
// currently-playing boyfriend character says a random voice line
// (qtGameover-N.ogg) with a matching subtitle, picked from a pool specific
// to that character (bf-qt vs pico-qt - the mod's only two boyfriend
// variants across all 7 songs). This is a global script (mods/qt-rewired/
// scripts/, loaded for every song regardless of stage - see
// Mods.directoriesWithFile(..., 'scripts/') in PlayState.hx) since
// onGameOverStart needs to fire no matter which stage is active.
//
// Simplifications vs the original: only the English voice lines/subtitles
// were ported (the original also has Spanish ones, gated by a language
// option this mod doesn't have - same call already made for Blissful-erect's
// cutscene subtitles, see PORT_INFO.md limitation 8). The death CHARACTER
// MODEL itself is left as Psych's default vanilla "bf-dead" rather than a
// custom QT-specific death pose - the original's death animations for
// bf-qt/pico-qt aren't part of this port's copied assets. Each line's
// on-screen duration is the fixed total length of its .srt cues (in
// data-src/subtitles/english/gameover/, kept as reference) rather than
// tracking real playback position, matching how showSubtitle() elsewhere in
// this mod already works.
var goQuoteText:FlxText;

var bfLines:Array<Dynamic> = [
	{sound: 'qtgameover/english/bf/qtGameover-1', text: 'Oh no! Are you okay?\nIs he okay...?', duration: 5.163},
	{sound: 'qtgameover/english/bf/qtGameover-2', text: 'Uh oh!', duration: 0.632},
	{sound: 'qtgameover/english/bf/qtGameover-3', text: "Oh, that was not good!\nLet's try again...", duration: 4.808},
	{sound: 'qtgameover/english/bf/qtGameover-4', text: 'Come on! I know you can do better than that!', duration: 3.051},
	{sound: 'qtgameover/english/bf/qtGameover-5', text: 'Uhmm... Maybe we should leave it for another time...', duration: 3.618},
	{sound: 'qtgameover/english/bf/qtGameover-6', text: 'Ow... Was I singing too fast?', duration: 2.653},
	{sound: 'qtgameover/english/bf/qtGameover-7', text: 'Dude, do you need a break?', duration: 1.814}
];

var picoLines:Array<Dynamic> = [
	{sound: 'qtgameover/english/pico/qtGameover-1', text: 'Hey!\nWhy did you do that for?', duration: 2.310},
	{sound: 'qtgameover/english/pico/qtGameover-2', text: 'Aww...\nI was having fun!', duration: 2.990},
	{sound: 'qtgameover/english/pico/qtGameover-3', text: 'That was rude!', duration: 1.200},
	{sound: 'qtgameover/english/pico/qtGameover-4', text: 'I thought you both were friends...', duration: 2.086},
	{sound: 'qtgameover/english/pico/qtGameover-5', text: 'I knew you two would get hurt with those weapons you carry!', duration: 3.240},
	{sound: 'qtgameover/english/pico/qtGameover-6', text: 'Oh! Is he gonna be okay?\nDoes this happen often...?', duration: 4.490}
];

function subtitlesEnabled():Bool
{
	var v:Dynamic = getModSetting('qtSubtitles');
	return (v == null) ? true : v;
}

function onGameOverStart()
{
	if (!subtitlesEnabled()) return;
	if (GameOverSubstate.instance == null) return;
	if (game.boyfriend == null) return;

	var pool:Array<Dynamic> = null;
	if (game.boyfriend.curCharacter == 'pico-qt') pool = picoLines;
	else if (game.boyfriend.curCharacter == 'bf-qt') pool = bfLines;
	if (pool == null || pool.length == 0) return;

	// Short delay before the quote plays so it doesn't talk over the game
	// over screen's own initial death stinger (fnf_loss_sfx) - the original
	// deferred this similarly (onSubStateOpenEnd, one frame after the
	// substate's open transition finishes).
	new FlxTimer().start(1.2, function(_)
	{
		if (GameOverSubstate.instance == null) return;

		var pick:Dynamic = pool[FlxG.random.int(0, pool.length - 1)];
		FlxG.sound.play(Paths.sound(pick.sound));

		goQuoteText = new FlxText(20, FlxG.height - 140, FlxG.width - 40, pick.text, 28);
		goQuoteText.setFormat(Paths.font('vcr.ttf'), 28, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
		goQuoteText.scrollFactor.set();
		GameOverSubstate.instance.add(goQuoteText);

		new FlxTimer().start(pick.duration, function(_)
		{
			if (goQuoteText != null && GameOverSubstate.instance != null) GameOverSubstate.instance.remove(goQuoteText);
		});
	});
}
