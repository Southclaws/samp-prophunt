/*==============================================================================


	Southclaw's Prop Hunt

		A gamemode inspired by the popular Team Fortress 2 mod "PropHunt"
		by Darkimmortal.


==============================================================================*/


#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS	(32)

#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <YSI\y_timers>				// By Y_Less:				http://forum.sa-mp.com/showthread.php?p=1696956
#include <YSI\y_iterate>
#include <YSI\y_hooks>
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <zcmd>						// Zeex						http://forum.sa-mp.com/showthread.php?t=91354

native IsValidVehicle(vehicleid);


/*==============================================================================

	Global Variables

==============================================================================*/


#define YELLOW						0xFFFF00AA

#define RED							0xE85454AA
#define GREEN						0x33AA33AA
#define BLUE						0x33CCFFAA

#define ORANGE						0xFFAA00AA
#define GREY						0xAFAFAFAA
#define PINK						0xFFC0CBAA
#define NAVY						0x000080AA
#define GOLD						0xB8860BAA
#define LGREEN						0x00FD4DAA
#define TEAL						0x008080AA
#define BROWN						0xA52A2AAA
#define AQUA						0xF0F8FFAA

#define BLACK						0x000000AA
#define WHITE						0xFFFFFFAA


enum
{
	TEAM_SEEKER,
	TEAM_HIDER
}


new
		gPauseGame,
		gCurrentMap,
Text:	gMatchTimerUI;


/*==============================================================================

	Modules

==============================================================================*/


#include "prophunt\match.pwn"
#include "prophunt\player.pwn"
#include "prophunt\map.pwn"
#include "prophunt\admin.pwn"


/*==============================================================================

	Core

==============================================================================*/


main()
{
	print("\n\n/*==============================================================================\n\n");
	print("    Southclaw's Prop Hunt\n\n");
	print("        A gamemode inspired by the popular Team Fortress 2 mod \"PropHunt\"\n");
	print("        by Darkimmortal.");
	print("\n\n==============================================================================*/\n\n");
}


public OnGameModeInit()
{
	AddPlayerClass(0, -2763.2041, 85.0597, 7.5184, 270.0, 0, 0, 0, 0, 0, 0);

	gMatchTimerUI				=TextDrawCreate(430.000000, 10.000000, "00:00");
	TextDrawAlignment			(gMatchTimerUI, 2);
	TextDrawBackgroundColor		(gMatchTimerUI, 255);
	TextDrawFont				(gMatchTimerUI, 1);
	TextDrawLetterSize			(gMatchTimerUI, 0.400000, 2.000000);
	TextDrawColor				(gMatchTimerUI, -1);
	TextDrawSetOutline			(gMatchTimerUI, 1);
	TextDrawSetProportional		(gMatchTimerUI, 1);

	return 1;
}

public OnGameModeExit()
{

	return 1;
}
