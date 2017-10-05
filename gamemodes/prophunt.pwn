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

#define EMBED_YELLOW				"{FFFF00}"
#define EMBED_RED					"{E85454}"
#define EMBED_GREEN					"{33AA33}"
#define EMBED_BLUE					"{33CCFF}"
#define EMBED_ORANGE				"{FFAA00}"
#define EMBED_GREY					"{AFAFAF}"


enum
{
	TEAM_SEEKER,
	TEAM_HIDER
}


new
		gRoundTime = 300,
		gLobbyTime = 30,
		gOutOfMapTime = 3,

		gPauseGame,
		gCurrentMap,
Text:	gMatchTimerUI;


forward OnRoundStart();
forward OnRoundEnd(winningteam);
forward OnPlayerKill(playerid, targetid);


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

	if(!LoadPropSets())
		return 0;

	if(!LoadMaps())
		return 0;

	if(!LoadSettings())
		return 0;

	return 1;
}

public OnGameModeExit()
{

	return 1;
}

LoadSettings()
{
	if(!fexist(SETTINGS_FILE))
	{
		print("ERROR: Settings file '"SETTINGS_FILE"' not found.\n");
		return 0;
	}

	INI_Load(SETTINGS_FILE);

	print("\nLoading Settings...\n");
	printf("\tRound Time: %d", gRoundTime);
	printf("\tLobby Time: %d", gLobbyTime);
	printf("\tOut-of-Bounds Limit: %d", gOutOfMapTime);

	return 1;
}

INI:settings[](name[], value[])
{
	INI_Int("roundtime", gRoundTime);
	INI_Int("lobbytime", gLobbyTime);
	INI_Int("outboundslimit", gOutOfMapTime);

	return 1;
}
