#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


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
	match_Tick = gLobbyTime;
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
		{
			SpawnPlayerAsHider(i);
			ShowPlayerNameTagForPlayer(i, firstseeker, 1);
			SetPlayerMarkerForPlayer(i, firstseeker, 1);
			ShowPlayerNameTagForPlayer(firstseeker, i, 0);
			SetPlayerMarkerForPlayer(firstseeker, i, 0);
		}
	}

	match_Tick = gRoundTime;
	match_State = MATCH_STATE_RUNNING;
}

RoundEnd()
{
	GameTextForAll("~r~Round End", 1000, 5);

	if(Iter_Count(match_Hiders) > 0)
		SendClientMessageToAll(COLOUR_YELLOW, " >  Hiders Win!");

	foreach(new i : Player)
	{
		SetPlayerHP(i, 100.0);
		ResetPlayerWeapons(i);
		RemovePlayerAttachedObject(i, 0);

		if(GetPlayerSpectateTarget(i) != INVALID_PLAYER_ID)
		{
			ExitSpectateMode(i);
			SpawnPlayerAsHider(i);
		}
	}

	gCurrentMap++;

	if(gCurrentMap >= GetTotalMaps())
		gCurrentMap = 0;

	match_Tick = gLobbyTime;
	match_State = MATCH_STATE_LOBBY;
}

SpawnPlayerAsHider(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		propsetid,
		propid,
		model,
		Float:offsetx,
		Float:offsety,
		Float:offsetz,
		Float:rotx,
		Float:roty,
		Float:rotz,
		Float:scalex,
		Float:scaley,
		Float:scalez;

	GetHiderSpawn(x, y, z, r);
	propsetid = GetCurrentPropSet();
	propid = GetRandomPropFromSet(propsetid);
	model = GetPropModel(propid);
	GetPropOffset(propid, offsetx, offsety, offsetz);
	GetPropRotation(propid, rotx, roty, rotz);
	GetPropScale(propid, scalex, scaley, scalez);

	printf("set: %d prop: %d model: %d offsets: %f %f %f", propsetid, propid, model, offsetx, offsety, offsetz);

	SetPlayerTeam(playerid, TEAM_HIDER);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	SetPlayerAttachedObject(playerid, 0, model, 1, offsetx, offsety, offsetz, rotx, roty, rotz, scalex, scaley, scalez);

	GivePlayerWeapon(playerid, 8, 1000000);
	ClearAnimations(playerid);

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

	GivePlayerWeapon(playerid, 33, 1000000);
	ClearAnimations(playerid);

	Iter_Add(match_Seekers, playerid);
	Iter_Remove(match_Hiders, playerid);
}

KickPlayerFromMatch(playerid)
{
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Kicked for being out of the map area too long.");
	EnterSpectateMode(playerid);

	Iter_Remove(match_Seekers, playerid);
	Iter_Remove(match_Hiders, playerid);

	if(Iter_Count(match_Hiders) == 0)
	{
		SendClientMessageToAll(COLOUR_YELLOW, " >  Round ended!");
		RoundEnd();
	}

	if(Iter_Count(match_Seekers) == 0)
	{
		SendClientMessageToAll(COLOUR_YELLOW, " >  Round ended!");
		RoundEnd();
	}
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
					SendClientMessageToAll(COLOUR_YELLOW, " >  Seekers Win!");
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
