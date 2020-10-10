/*==============================================================================


	Southclaws' Prop Hunt

		A gamemode inspired by the popular Team Fortress 2 mod "PropHunt"
		by Darkimmortal.


==============================================================================*/


// sampctl/samp-stdlib
#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (32)
#define YSI_NO_HEAP_MALLOC

// maddinat0r/sscanf
#include <sscanf2>

// oscar-broman/strlib
#include <strlib>

// BigETI/Dini
#include <dini>


/*==============================================================================

	Global

==============================================================================*/


#define SETTINGS_FILE				"PropHunt/settings.ini"
#define MAP_INDEX_FILE				"PropHunt/maplist"
#define MAP_DIRECTORY				"PropHunt/Maps/"
#define PROP_INDEX_FILE				"PropHunt/propsets"
#define PROP_DIRECTORY				"PropHunt/Props/"

#define COLOUR_YELLOW				0xFFFF00FF
#define COLOUR_RED					0xE85454FF
#define COLOUR_GREEN				0x33AA33FF
#define COLOUR_BLUE					0x33CCFFFF
#define COLOUR_ORANGE				0xFFAA00FF
#define COLOUR_GREY					0xAFAFAFFF

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
	print("Southclaws' Prop Hunt\n\n");
	print("    A gamemode inspired by the popular Team Fortress 2 mod \"PropHunt\"\n");
	print("    by Darkimmortal.");
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

	InitMatch();

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

	gRoundTime = dini_Int(SETTINGS_FILE, "roundtime");
	gLobbyTime = dini_Int(SETTINGS_FILE, "lobbytime");
	gOutOfMapTime = dini_Int(SETTINGS_FILE, "outboundslimit");

	print("\nLoading Settings...\n");
	printf("\tRound Time: %d", gRoundTime);
	printf("\tLobby Time: %d", gLobbyTime);
	printf("\tOut-of-Bounds Limit: %d", gOutOfMapTime);

	return 1;
}
