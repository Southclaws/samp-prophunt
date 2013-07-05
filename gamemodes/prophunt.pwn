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
#include <YSI\y_ini>
#include <YSI\y_commands>
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764

native IsValidVehicle(vehicleid);


/*==============================================================================

	Global

==============================================================================*/


#define SETTINGS_FILE				"PropHunt/settings.ini"
#define MAP_INDEX_FILE				"PropHunt/maplist"
#define MAP_DIRECTORY				"PropHunt/Maps/"
#define PROP_INDEX_FILE				"PropHunt/propsets"
#define PROP_DIRECTORY				"PropHunt/Props/"

#define COLOUR_YELLOW				0xFFFF00AA
#define COLOUR_RED					0xE85454AA
#define COLOUR_GREEN				0x33AA33AA
#define COLOUR_BLUE					0x33CCFFAA
#define COLOUR_ORANGE				0xFFAA00AA
#define COLOUR_GREY					0xAFAFAFAA


enum
{
	TEAM_SEEKER,
	TEAM_HIDER
}


new
		gRoundTime,
		gLobbyTime,
		gOutOfMapTime,

		gPauseGame,
		gCurrentMap,
Text:	gMatchTimerUI;


/*==============================================================================

	Modules

==============================================================================*/


#include "prophunt\utils.pwn"
#include "prophunt\match.pwn"
#include "prophunt\player.pwn"
#include "prophunt\prop.pwn"
#include "prophunt\propset.pwn"
#include "prophunt\map.pwn"
#include "prophunt\admin.pwn"
#include "prophunt\api.pwn"


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

	LoadPropSets();
	LoadMaps();
	LoadSettings();

	return 1;
}

public OnGameModeExit()
{

	return 1;
}

LoadSettings()
{
	if(!fexist(SETTINGS_FILE))
		print("ERROR: Settings file '"SETTINGS_FILE"' not found.");

	INI_Load(SETTINGS_FILE);

	print("\nLoading Settings...\n");
	printf("\tRound Time: %d", gRoundTime);
	printf("\tLobby Time: %d", gLobbyTime);
	printf("\tOut-of-Bounds Limit: %d", gOutOfMapTime);
}

INI:settings[](name[], value[])
{
	INI_Int("roundtime", gRoundTime);
	INI_Int("lobbytime", gLobbyTime);
	INI_Int("outboundslimit", gOutOfMapTime);

	return 1;
}
