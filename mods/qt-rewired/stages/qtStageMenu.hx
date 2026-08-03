import openfl.display.BlendMode;
import states.PlayState;
import backend.MusicBeatState;
import states.FreeplayState;
import states.StoryMenuState;
import states.LoadingState;
import backend.Song;
import backend.Mods;
import objects.HealthIcon;

// --- "QT-Rewired" master menu song ---
// The user wants every song reachable ONLY through a single Freeplay entry
// ("QT-Rewired") that recreates the original mod's own menu flow (title
// card -> main menu -> song select) instead of listing all 7 variants
// directly in Psych's real Freeplay/Story Mode. This is a completely
// different technique from every other file in this port: instead of
// scripting a real song, "qt-rewired" is a dummy song (empty notes, a
// looping instrumental, data/qt-rewired/qt-rewired.json) whose entire
// purpose is to be hijacked by this stage script into a self-contained menu
// system, built the same way everything else in this mod is (standalone
// FlxText/FlxSprite/HealthIcon, keyJustPressed for input) - no source/
// changes, but a much bigger, unverified surface area than anything else
// here. See PORT_INFO.md for the full writeup, including the one
// unavoidable seam: dying in a real song and pressing BACK on the Game Over
// screen lands you in Psych's REAL Freeplay (which, after weeks/QT.json was
// trimmed down, only contains this same "QT-Rewired" entry anyway, so it's
// a harmless extra step, not a dead end).
//
// Song catalog for the custom Freeplay list - folder names match
// data/<folder>/ exactly (see PORT_INFO.md's per-variant notes table).
var songEntries:Array<Dynamic> = [
	{name: 'Blissful', folder: 'blissful', icon: 'qt'},
	{name: 'Obliterated', folder: 'obliterated', icon: 'kb'},
	{name: 'Blissful Erect', folder: 'blissful-erect', icon: 'qt'},
	{name: 'Obliterated Erect', folder: 'obliterated-erect', icon: 'kb'},
	{name: 'Obliterated Legacy', folder: 'obliterated-legacy', icon: 'kb'},
	{name: 'Blissful Pico', folder: 'blissful-pico', icon: 'qt'},
	{name: 'Blissful 2021', folder: 'blissful-2021', icon: 'qt-legacy'}
];

var diffNames:Array<String> = ['EASY', 'NORMAL', 'HARD'];
var diffSuffixes:Array<String> = ['-easy', '', '-hard'];

// title -> mainmenu -> freeplay (back goes the other way; back from title
// exits to Psych's real Freeplay/Story Mode, whichever launched this song)
var menuState:String = 'title';

var bg:FlxSprite;

var titleText:FlxText;
var pressText:FlxText;
var pressBlink:Float = 0;

var mainMenuTexts:Array<FlxText> = [];
var mainMenuIndex:Int = 0;

var songTexts:Array<FlxText> = [];
var songIcons:Array<HealthIcon> = [];
var songCursor:FlxSprite;
var diffText:FlxText;
var songIndex:Int = 0;
var diffIndex:Int = 1;

function onCreate()
{
	// No camZoomState/SetCameraBop system here unlike every other stage in
	// this mod - this "song" has no cutscenes or camera chart events, and
	// every menu sprite below is scrollFactor-fixed to the screen, so the
	// underlying camera zoom is never actually visible.
	FlxG.camera.zoom = game.defaultCamZoom;
}

function onCreatePost()
{
	// This "song" has no real gameplay - hide every native HUD/character
	// element instantly instead of the fade-based helpers other stages use,
	// since there's nothing to fade from (nothing was ever meant to be seen).
	game.healthBar.visible = false;
	game.scoreTxt.visible = false;
	game.iconP1.visible = false;
	game.iconP2.visible = false;
	game.playerStrums.visible = false;
	game.opponentStrums.visible = false;
	if (game.dad != null) game.dad.visible = false;
	if (game.boyfriend != null) game.boyfriend.visible = false;
	if (game.gf != null) game.gf.visible = false;

	FlxG.sound.music.volume = 0.5;

	bg = new FlxSprite(0, 0);
	bg.makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), 0xFF1a0e14);
	bg.scrollFactor.set();
	bg.screenCenter();
	game.add(bg);

	buildTitleScreen();
	buildMainMenu();
	buildFreeplay();

	showOnly('title');
}

function onStartCountdown():Dynamic
{
	// Never let the real countdown/gameplay start - this song only exists
	// to host the menu built above.
	return Function_Stop;
}

// --- Title screen ---
function buildTitleScreen()
{
	titleText = new FlxText(0, FlxG.height * 0.36, FlxG.width, 'QT: REWIRED', 64);
	titleText.setFormat(Paths.font('vcr.ttf'), 64, 0xFFFF69B4, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	titleText.scrollFactor.set();
	game.add(titleText);

	pressText = new FlxText(0, FlxG.height * 0.6, FlxG.width, 'Press ACCEPT', 28);
	pressText.setFormat(Paths.font('vcr.ttf'), 28, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	pressText.scrollFactor.set();
	game.add(pressText);
}

function updateTitle(elapsed:Float)
{
	pressBlink += elapsed;
	pressText.alpha = 0.5 + Math.abs(Math.sin(pressBlink * 3)) * 0.5;

	if (keyJustPressed('accept'))
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		showOnly('mainmenu');
	}
	else if (keyJustPressed('back'))
	{
		exitToRealFreeplay();
	}
}

// --- Main menu ---
function buildMainMenu()
{
	var items:Array<String> = ['FREEPLAY', 'EXIT'];
	for (i in 0...items.length)
	{
		var txt:FlxText = new FlxText(0, FlxG.height * 0.4 + i * 70, FlxG.width, items[i], 40);
		txt.setFormat(Paths.font('vcr.ttf'), 40, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
		txt.scrollFactor.set();
		game.add(txt);
		mainMenuTexts.push(txt);
	}
	updateMainMenuHighlight();
}

function updateMainMenuHighlight()
{
	for (i in 0...mainMenuTexts.length)
		mainMenuTexts[i].color = (i == mainMenuIndex) ? 0xFFFF69B4 : 0xFFFFFFFF;
}

function updateMainMenu()
{
	if (keyJustPressed('ui_up'))
	{
		mainMenuIndex = (mainMenuIndex - 1 + mainMenuTexts.length) % mainMenuTexts.length;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateMainMenuHighlight();
	}
	else if (keyJustPressed('ui_down'))
	{
		mainMenuIndex = (mainMenuIndex + 1) % mainMenuTexts.length;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateMainMenuHighlight();
	}
	else if (keyJustPressed('back'))
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		showOnly('title');
	}
	else if (keyJustPressed('accept'))
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		if (mainMenuIndex == 0)
			showOnly('freeplay');
		else
			exitToRealFreeplay();
	}
}

// --- Freeplay (song select) ---
function buildFreeplay()
{
	for (i in 0...songEntries.length)
	{
		var entry:Dynamic = songEntries[i];
		var rowY:Float = 120 + i * 78;

		var icon:HealthIcon = new HealthIcon(entry.icon, false);
		icon.setGraphicSize(64, 64);
		icon.updateHitbox();
		icon.x = 140;
		icon.y = rowY - 32;
		icon.scrollFactor.set();
		game.add(icon);
		songIcons.push(icon);

		var txt:FlxText = new FlxText(230, rowY - 20, FlxG.width - 260, entry.name, 34);
		txt.setFormat(Paths.font('vcr.ttf'), 34, 0xFFFFFFFF, 'left', FlxTextBorderStyle.OUTLINE, 0xFF000000);
		txt.scrollFactor.set();
		game.add(txt);
		songTexts.push(txt);
	}

	songCursor = new FlxSprite(0, 0);
	songCursor.makeGraphic(FlxG.width - 60, 68, 0xFFFF69B4);
	songCursor.alpha = 0.18;
	songCursor.scrollFactor.set();
	songCursor.x = 30;
	game.add(songCursor);
	// Push the highlight bar behind the icons/text rows added just above -
	// bg (added first, in onCreatePost) already renders behind everything
	// on its own, this only needs to move songCursor back under the rows.
	var rowsStart:Int = game.members.indexOf(songIcons[0]);
	if (rowsStart >= 0)
	{
		game.remove(songCursor);
		game.insert(rowsStart, songCursor);
	}

	diffText = new FlxText(0, FlxG.height - 70, FlxG.width, '', 30);
	diffText.setFormat(Paths.font('vcr.ttf'), 30, 0xFFFF69B4, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	diffText.scrollFactor.set();
	game.add(diffText);

	updateFreeplayHighlight();
}

function updateFreeplayHighlight()
{
	songCursor.y = 120 + songIndex * 78 - 34;
	diffText.text = '< ' + diffNames[diffIndex] + ' >';

	for (i in 0...songTexts.length)
		songTexts[i].color = (i == songIndex) ? 0xFFFF69B4 : 0xFFFFFFFF;
}

function updateFreeplay()
{
	if (keyJustPressed('ui_up'))
	{
		songIndex = (songIndex - 1 + songEntries.length) % songEntries.length;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateFreeplayHighlight();
	}
	else if (keyJustPressed('ui_down'))
	{
		songIndex = (songIndex + 1) % songEntries.length;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateFreeplayHighlight();
	}
	else if (keyJustPressed('ui_left'))
	{
		diffIndex = (diffIndex - 1 + diffNames.length) % diffNames.length;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateFreeplayHighlight();
	}
	else if (keyJustPressed('ui_right'))
	{
		diffIndex = (diffIndex + 1) % diffNames.length;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateFreeplayHighlight();
	}
	else if (keyJustPressed('back'))
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		showOnly('mainmenu');
	}
	else if (keyJustPressed('accept'))
	{
		launchSong(songEntries[songIndex].folder, diffIndex);
	}
}

// Switches visibility so only the current screen's sprites are shown -
// everything for all 3 screens is built once in onCreatePost instead of
// created/destroyed per transition, simpler and safer to reason about.
function showOnly(state:String)
{
	menuState = state;

	titleText.visible = (state == 'title');
	pressText.visible = (state == 'title');

	for (t in mainMenuTexts) t.visible = (state == 'mainmenu');

	var onFreeplay:Bool = (state == 'freeplay');
	for (t in songTexts) t.visible = onFreeplay;
	for (i in songIcons) i.visible = onFreeplay;
	songCursor.visible = onFreeplay;
	diffText.visible = onFreeplay;
}

function onUpdate(elapsed:Float)
{
	switch (menuState)
	{
		case 'title':
			updateTitle(elapsed);
		case 'mainmenu':
			updateMainMenu();
		case 'freeplay':
			updateFreeplay();
	}
}

// Loads a real song+difficulty exactly the way FreeplayState itself does
// (Song.loadFromJson + LoadingState.loadAndSwitchState(new PlayState())),
// bypassing Psych's own Freeplay/Story Mode screens entirely.
function launchSong(folder:String, diff:Int)
{
	var jsonName:String = folder + diffSuffixes[diff];

	PlayState.SONG = Song.loadFromJson(jsonName, folder);
	PlayState.isStoryMode = false;
	PlayState.storyDifficulty = diff;

	// Muted rather than stopped, matching FreeplayState's own exact
	// approach right before this same loadAndSwitchState call.
	FlxG.sound.music.volume = 0;
	LoadingState.loadAndSwitchState(new PlayState());
}

// Leaves the custom menu entirely, back to Psych's real Freeplay - this is
// also where a win/loss in one of the 7 real songs redirects to re-enter
// this menu instead (see each real stage's onEndSong/PORT_INFO.md), so
// "back to real Freeplay" only ever happens from here or from a Game Over
// BACK press (the one seam that can't be redirected - see PORT_INFO.md).
function exitToRealFreeplay()
{
	// Mirrors PlayState.endSong()'s own exact freeplay/story-exit sequence
	// (Mods.loadTopMod() + the freakyMenu music) rather than inventing a
	// different one - and returns to whichever of Story Mode/Freeplay this
	// "QT-Rewired" entry was actually opened from.
	Mods.loadTopMod();
	FlxG.sound.playMusic(Paths.music('freakyMenu'));
	if (PlayState.isStoryMode)
		MusicBeatState.switchState(new StoryMenuState());
	else
		MusicBeatState.switchState(new FreeplayState());
}
