package;

import flixel.effects.FlxFlicker;
import ControlsSubState;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Preferences', 'Controls', 'Exit'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	private var flickering:Bool = false;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		curSelected = 0;

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, (100 * i) + 210, options[i], true, false);
			optionText.x = 240;
			optionText.y -= 102;
			optionText.screenCenter(X);
			grpOptions.add(optionText);
		}
		changeSelection();

		super.create();
	}

	var doVisible:Bool;
	override function closeSubState() {
		super.closeSubState();
		doVisible = true;
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		if(doVisible) {
			changeSelection();
			doVisible = false;
		}
		super.update(elapsed);
	
		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (!flickering)
		{	
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}
	
			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
	
				flickering = true;
				FlxFlicker.flicker(grpOptions.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker)
				{
					for (item in grpOptions.members) {
						item.alpha = 0;
					}
	
					switch(options[curSelected]) {
						case 'Preferences':
							openSubState(new PreferencesSubstate());
						
						case 'Controls':
							openSubState(new ControlsSubstate());
						
						case 'Exit':
							FlxG.switchState(new MainMenuState());
					}
	
					flickering = false;
				});
			}
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
