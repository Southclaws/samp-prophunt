#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


enum E_PLAYER_DATA
{
			ply_Spawned,
Float:		ply_Health,
			ply_SpectateTarget
}


static
			ply_Data[MAX_PLAYERS][E_PLAYER_DATA],
			ply_OutOfMap[MAX_PLAYERS],
			ply_OutOfMapTick[MAX_PLAYERS],
PlayerText:	ply_HealthUI;


static
			ply_Colours[64] =
			{
				0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF,
				0xF4A460FF, 0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF,
				0x0FD9FAFF, 0x10DC29FF, 0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF,
				0x635B03FF, 0xCB7ED3FF, 0x65ADEBFF, 0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF,
				0x54137DFF, 0x275222FF, 0xF09F5BFF, 0x3D0A4FFF, 0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF,
				0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF, 0x057F94FF, 0xB98519FF, 0x388EEAFF, 0x028151FF,
				0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF, 0x18F71FFF, 0x4B8987FF, 0x491B9EFF,
				0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF, 0x12D6D4FF, 0x48C000FF
			};


/*==============================================================================

	Core

==============================================================================*/


public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, ply_Colours[playerid]);

	new str[128];
	format(str, sizeof(str), " >  %P Has joined the game!", playerid);
	SendClientMessageToAll(COLOUR_GREEN, str);

	TextDrawShowForPlayer(playerid, gMatchTimerUI);
	SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	ply_HealthUI					=CreatePlayerTextDraw(playerid, 577.000000, 66.000000, "100hp");
	PlayerTextDrawAlignment			(playerid, ply_HealthUI, 2);
	PlayerTextDrawBackgroundColor	(playerid, ply_HealthUI, -1);
	PlayerTextDrawFont				(playerid, ply_HealthUI, 1);
	PlayerTextDrawLetterSize		(playerid, ply_HealthUI, 0.439999, 1.000000);
	PlayerTextDrawColor				(playerid, ply_HealthUI, -16776961);
	PlayerTextDrawSetOutline		(playerid, ply_HealthUI, 0);
	PlayerTextDrawSetProportional	(playerid, ply_HealthUI, 1);
	PlayerTextDrawSetShadow			(playerid, ply_HealthUI, 0);
	PlayerTextDrawUseBox			(playerid, ply_HealthUI, 1);
	PlayerTextDrawBoxColor			(playerid, ply_HealthUI, 255);
	PlayerTextDrawTextSize			(playerid, ply_HealthUI, 655.000000, 60.000000);
	PlayerTextDrawShow				(playerid, ply_HealthUI);

	ply_Data[playerid][ply_SpectateTarget] = INVALID_PLAYER_ID;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new str[128];
	format(str, sizeof(str), " >  %P Has left the game!", playerid);
	SendClientMessageToAll(COLOUR_GREY, str);

	if(Iter_Count(Player) == 1)
	{
		RoundEnd();
	}

	PlayerTextDrawDestroy(playerid, ply_HealthUI);

	ply_Data[playerid][ply_Spawned] = false;

	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(!ply_Data[playerid][ply_Spawned])
	{
		if(GetMatchState() == MATCH_STATE_LOBBY)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:r;

			GetSeekerSpawn(x, y, z, r);

			SetPlayerPos(playerid, x, y, z);
			SetPlayerFacingAngle(playerid, r);
		}
		else
		{
			EnterSpectateMode(playerid);
		}
	}

	SetPlayerHP(playerid, 100.0);
	ply_Data[playerid][ply_Spawned] = true;

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerTeam(playerid) == TEAM_HIDER)
	{
		if(oldkeys & KEY_CROUCH)
		{
			if(GetPlayerAnimationIndex(playerid) == 1068)
				ClearAnimations(playerid);

			else
				ApplyAnimation(playerid, "PED", "COWER", 4.0, 0, 0, 0, 1, 100);
		}
	}

	if(ply_Data[playerid][ply_SpectateTarget] != INVALID_PLAYER_ID)
	{
		if(newkeys == 4)
		{
			new
				id = ply_Data[playerid][ply_SpectateTarget] - 1,
				iters;

			if(id < 0)
				id = MAX_PLAYERS-1;

			while(id >= 0 && iters <= MAX_PLAYERS)
			{
				iters++;
				if(id == playerid || !IsPlayerConnected(id) || !ply_Data[id][ply_Spawned] || GetPlayerState(id) == PLAYER_STATE_SPECTATING)
				{
					id--;

					if(id <= 0)
						id = MAX_PLAYERS - 1;

					continue;
				}
				break;
			}
			EnterSpectateMode(playerid, id);
		}

		if(newkeys == 128)
		{
			new
				id = ply_Data[playerid][ply_SpectateTarget] + 1,
				iters;

			if(id == MAX_PLAYERS)
				id = 0;

			while(id < MAX_PLAYERS && iters <= MAX_PLAYERS)
			{
				iters++;
				if(id == playerid || !IsPlayerConnected(id) || !ply_Data[id][ply_Spawned] || GetPlayerState(id) == PLAYER_STATE_SPECTATING)
				{
					id++;

					if(id >= MAX_PLAYERS - 1)
						id = 0;

					continue;
				}
				break;
			}
			EnterSpectateMode(playerid, id);
		}
	}
}

ptask PlayerUpdate[1000](playerid)
{
	if(ply_Data[playerid][ply_Spawned] && ply_Data[playerid][ply_SpectateTarget] == INVALID_PLAYER_ID && GetMatchState() == MATCH_STATE_RUNNING)
	{
		new
			Float:px,
			Float:py,
			Float:pz,
			Float:minx,
			Float:maxx,
			Float:maxy,
			Float:miny;

		GetPlayerPos(playerid, px, py, pz);
		GetMapBounds(minx, maxx, miny, maxy);

		if(minx < px < maxx && miny < py < maxy)
		{
			ply_OutOfMap[playerid] = false;
		}
		else
		{
			new str[32];

			if(!ply_OutOfMap[playerid])
			{
				ply_OutOfMap[playerid] = true;
				ply_OutOfMapTick[playerid] = gOutOfMapTime;
			}

			format(str, sizeof(str), "Return To Map Area~n~%d Seconds", ply_OutOfMapTick[playerid]);

			GameTextForPlayer(playerid, str, 1500, 5);

			if(ply_OutOfMapTick[playerid] == 0)
			{
				KickPlayerFromMatch(playerid);
				ply_OutOfMap[playerid] = false;
			}

			ply_OutOfMapTick[playerid]--;
		}
	}

	return 1;
}

public OnPlayerUpdate(playerid)
{
	SetPlayerHealth(playerid, 1000.0);

	return 1;
}

UpdateHealthUI(playerid)
{
	new str[6];
	format(str, 6, "%.0f", ply_Data[playerid][ply_Health]);
	PlayerTextDrawSetString(playerid, ply_HealthUI, str);
}

EnterSpectateMode(playerid, targetid = -1)
{
	if(targetid == -1)
	{
		new start = playerid;

		targetid = playerid + 1;

		if(targetid == MAX_PLAYERS)
			targetid = 0;

		while(targetid < MAX_PLAYERS)
		{
			if(targetid == start)
				return 0;

			if(targetid == playerid || !IsPlayerConnected(targetid) || !ply_Data[targetid][ply_Spawned] || GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
			{
				targetid++;

				if(targetid >= MAX_PLAYERS - 1)
					targetid = 0;

				continue;
			}
			break;
		}
	}

	if(!IsPlayerConnected(targetid))
		return 0;

	TogglePlayerSpectating(playerid, true);
	PlayerSpectatePlayer(playerid, targetid);

	ply_Data[playerid][ply_SpectateTarget] = targetid;

	return 1;
}

ExitSpectateMode(playerid)
{
	if(ply_Data[playerid][ply_SpectateTarget] == INVALID_PLAYER_ID)
		return 0;

	TogglePlayerSpectating(playerid, false);

	ply_Data[playerid][ply_SpectateTarget] = INVALID_PLAYER_ID;

	return 1;
}



/*==============================================================================

	Interface

==============================================================================*/


forward Float:GetPlayerHP(playerid);
Float:GetPlayerHP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_Health];
}

SetPlayerHP(playerid, Float:amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Health] = amount;
	UpdateHealthUI(playerid);

	return 1;
}

GetPlayerSpectateTarget(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_PLAYER_ID;

	return ply_Data[playerid][ply_SpectateTarget];
}
