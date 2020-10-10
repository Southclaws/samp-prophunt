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
			match_Hiders[MAX_PLAYERS],
			match_HidersNum,
			match_Seekers[MAX_PLAYERS],
			match_SeekersNum;


/*==============================================================================

	Core

==============================================================================*/


InitMatch()
{
	match_Tick = gLobbyTime;
	match_State = MATCH_STATE_LOBBY;

	SetTimer("MatchUpdate", 1000, true);
}

forward MatchUpdate();
public MatchUpdate()
{
	if(gPauseGame)
		return;

	if(GetOnlinePlayers() < 2)
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
	new firstseeker = match_Seekers[random(match_SeekersNum)];

	SpawnPlayerAsSeeker(firstseeker);

	GameTextForAll("~b~Round Start!", 1000, 5);

	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i))
			continue;

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

	CallRemoteFunction("OnRoundStart", "");
}

RoundEnd(winningteam = -1) // if 'winningteam' = -1, determine the winning team in the function.
{
	if(winningteam == -1)
	{
		if(match_HidersNum > 0)
			winningteam = TEAM_HIDER;

		if(match_SeekersNum > 0)
			winningteam = TEAM_SEEKER;
	}

	if(winningteam == TEAM_HIDER)
		SendClientMessageToAll(COLOUR_YELLOW, " >  Hiders Win!");

	else if(winningteam == TEAM_SEEKER)
		SendClientMessageToAll(COLOUR_YELLOW, " >  Seekers Win!");

	else
		SendClientMessageToAll(COLOUR_YELLOW, " >  No one wins.");

	match_HidersNum = 0;
	match_SeekersNum = 0;

	GameTextForAll("~r~Round End", 1000, 5);

	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i))
			continue;

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

	CallRemoteFunction("OnRoundEnd", "d", winningteam);
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

	match_Hiders[match_HidersNum++] = playerid;
	new bool:found = false;
	for(new i = 0; i < match_SeekersNum; i++) {
		if(!found) {
			if(match_Seekers[i] == playerid) {
				found = true;
			}
		} else {
			match_Seekers[i - 1] = match_Seekers[i];
			match_Seekers[i] = 0;
		}
	}
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

	match_Seekers[match_SeekersNum++] = playerid;
	new bool:found = false;
	for(new i = 0; i < match_HidersNum; i++) {
		if(!found) {
			if(match_Hiders[i] == playerid) {
				found = true;
			}
		} else {
			match_Hiders[i - 1] = match_Hiders[i];
			match_Hiders[i] = 0;
		}
	}
}

KickPlayerFromMatch(playerid)
{
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Kicked for being out of the map area too long.");
	EnterSpectateMode(playerid);

	if(match_HidersNum == 0)
	{
		SendClientMessageToAll(COLOUR_YELLOW, " >  Round ended!");
		RoundEnd();
	}

	if(match_SeekersNum == 0)
	{
		SendClientMessageToAll(COLOUR_YELLOW, " >  Round ended!");
		RoundEnd();
	}
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount)
{
	if(match_State == MATCH_STATE_RUNNING)
	{
		if(GetPlayerTeam(playerid) == GetPlayerTeam(damagedid))
			return 0;

		new Float:hp;
		GetPlayerHP(damagedid, hp);

		if(hp <= 0.0)
		{
			CallRemoteFunction("OnPlayerKill", "dd", playerid, damagedid);

			if(GetPlayerTeam(playerid) == TEAM_SEEKER)
			{
				SpawnPlayer(damagedid);
				SpawnPlayerAsSeeker(damagedid);

				if(match_HidersNum == 0)
				{
					RoundEnd(TEAM_SEEKER);
				}
			}
			else
			{
				SpawnPlayer(damagedid);
				SpawnPlayerAsHider(damagedid);
			}
		}

		SetPlayerHP(damagedid, hp - (amount * 2));
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

stock RemoveFromTeams(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new bool:found = false;
	for(new i = 0; i < match_HidersNum; i++) {
		if(!found) {
			if(match_Hiders[i] == playerid) {
				found = true;
			}
		} else {
			match_Hiders[i - 1] = match_Hiders[i];
			match_Hiders[i] = 0;
		}
	}

	found = false;
	for(new i = 0; i < match_SeekersNum; i++) {
		if(!found) {
			if(match_Seekers[i] == playerid) {
				found = true;
			}
		} else {
			match_Seekers[i - 1] = match_Seekers[i];
			match_Seekers[i] = 0;
		}
	}

	return 1;
}

stock GetTotalHiders()
{
	return match_HidersNum;
}

stock GetTotalSeekers()
{
	return match_SeekersNum;
}