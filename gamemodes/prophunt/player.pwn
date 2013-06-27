#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


#define MAX_OUT_OF_MAP_TIME			(3)


enum E_PLAYER_DATA
{
			ply_Spawned,
Float:		ply_Health
}


static
			ply_Data[MAX_PLAYERS][E_PLAYER_DATA],
			ply_OutOfMap[MAX_PLAYERS],
			ply_OutOfMapTick[MAX_PLAYERS],
PlayerText:	ply_HealthUI;


/*==============================================================================

	Core

==============================================================================*/


public OnPlayerConnect(playerid)
{
	new str[128];
	format(str, sizeof(str), " >  %P Has joined the game!", playerid);
	SendClientMessageToAll(GREEN, str);

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

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new str[128];
	format(str, sizeof(str), " >  %P Has left the game!", playerid);
	SendClientMessageToAll(GREY, str);

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
			SetPlayerPos(playerid, 0.0, 0.0, 3.0);
			SendClientMessage(playerid, -1, "TODO: When a player joins while a match is in progress, make them spectate until match ends.");
		}
	}

	SetPlayerHP(playerid, 100.0);
	ply_Data[playerid][ply_Spawned] = true;

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & KEY_CROUCH)
	{
		if(GetPlayerAnimationIndex(playerid) == 1068)
			ClearAnimations(playerid);

		else
			ApplyAnimation(playerid, "PED", "COWER", 4.0, 0, 0, 0, 1, 100);
	}
}

ptask PlayerUpdate[1000](playerid)
{
	if(ply_Data[playerid][ply_Spawned] && GetMatchState() == MATCH_STATE_RUNNING)
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
				ply_OutOfMapTick[playerid] = MAX_OUT_OF_MAP_TIME;
			}

			format(str, sizeof(str), "Return To Map Area~n~%d Seconds", ply_OutOfMapTick[playerid]);

			GameTextForPlayer(playerid, str, 1500, 5);

			if(ply_OutOfMapTick[playerid] == 0)
			{
				SendClientMessage(playerid, YELLOW, " >  Kicked for being out of the map area too long.");
				// Kick(playerid);
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
