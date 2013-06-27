#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


#define MAX_PROP_TYPES	(18)
#define MAX_ROUND_TIME	60//(300)
#define MAX_LOBBY_TIME	10//(30)

enum
{
			MATCH_STATE_LOBBY,
			MATCH_STATE_RUNNING
}

static
			match_Tick,
			match_State,
Iterator:	match_Hiders<MAX_PLAYERS>,
Iterator:	match_Seekers<MAX_PLAYERS>;


/*==============================================================================

	Core

==============================================================================*/


hook OnGameModeInit()
{
	match_Tick = MAX_LOBBY_TIME;
}

task MatchUpdate[1000]()
{
	if(gPauseGame)
		return;

	if(Iter_Count(Player) < 2)
	{
		TextDrawSetString(gMatchTimerUI, "Not enough players");
		return;
	}

	if(match_Tick > 0)
	{
		new str[6];
		format(str, sizeof(str), "%d:%02d", match_Tick / 60, match_Tick % 60);
		TextDrawSetString(gMatchTimerUI, str);
	}
	else
	{
		TextDrawSetString(gMatchTimerUI, "0:00");

		if(match_State == MATCH_STATE_RUNNING)
		{
			RoundEnd();

			return;
		}

		if(match_State == MATCH_STATE_LOBBY)
		{
			RoundStart();

			return;
		}
	}

	match_Tick--;

	return;
}

RoundStart()
{
	new firstseeker = Iter_Random(Player);

	SpawnPlayerAsSeeker(firstseeker);

	GameTextForAll("~b~Round Start!", 1000, 5);

	foreach(new i : Player)
	{
		SetPlayerHP(i, 100.0);
		SetCameraBehindPlayer(i);
		TogglePlayerControllable(i, true);
		ClearAnimations(i);

		if(i != firstseeker)
			SpawnPlayerAsHider(i);
	}

	match_Tick = MAX_ROUND_TIME;
	match_State = MATCH_STATE_RUNNING;
}

RoundEnd()
{
	GameTextForAll("~r~Round End", 1000, 5);

	if(Iter_Count(match_Hiders) > 0)
		SendClientMessageToAll(YELLOW, " >  Hiders Win!");

	foreach(new i : Player)
	{
		SetPlayerHP(i, 100.0);
		ResetPlayerWeapons(i);
		RemovePlayerAttachedObject(i, 0);
	}

	gCurrentMap++;

	if(gCurrentMap >= GetTotalMaps())
		gCurrentMap = 0;

	match_Tick = MAX_LOBBY_TIME;
	match_State = MATCH_STATE_LOBBY;
}

SpawnPlayerAsHider(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetHiderSpawn(x, y, z, r);

	SetPlayerTeam(playerid, TEAM_HIDER);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	SetPlayerAttachedObject(playerid, 0, GetRandomProp(), 1, 0.239000, 0.011000, 0.004000,  97.600036, 40.200016, 109.399894, 1.0, 1.0, 1.0);

	GivePlayerWeapon(playerid, 8, 1000000);

	Iter_Add(match_Hiders, playerid);
	Iter_Remove(match_Seekers, playerid);
}

SpawnPlayerAsSeeker(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetSeekerSpawn(x, y, z, r);

	SetPlayerTeam(playerid, TEAM_SEEKER);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	RemovePlayerAttachedObject(playerid, 0);

	GivePlayerWeapon(playerid, 29, 1000000);

	Iter_Add(match_Seekers, playerid);
	Iter_Remove(match_Hiders, playerid);
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount)
{
	if(match_State == MATCH_STATE_RUNNING)
	{
		if(GetPlayerTeam(playerid) != GetPlayerTeam(damagedid))
			SetPlayerHP(damagedid, GetPlayerHP(damagedid) - (amount * 2));

		if(GetPlayerHP(damagedid) <= 0.0)
		{
			if(GetPlayerTeam(playerid) == TEAM_SEEKER)
			{
				SpawnPlayer(damagedid);
				SpawnPlayerAsSeeker(damagedid);

				if(Iter_Count(match_Hiders) == 0)
				{
					SendClientMessageToAll(YELLOW, " >  Seekers Win!");
					RoundEnd();
				}
			}
			else
			{
				SpawnPlayer(damagedid);
				SpawnPlayerAsHider(damagedid);
			}
		}
	}

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetMatchState()
{
	return match_State;
}

stock GetMatchTick()
{
	return match_Tick;
}

CMD:startmatch(playerid, params[])
{
	RoundStart();
	return 1;
}
