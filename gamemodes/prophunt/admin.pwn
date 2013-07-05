hook OnPlayerConnect(playerid)
{
	SetCommandPermissions(playerid, false);
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new playerip[16];

	foreach(new i : Player)
	{
		GetPlayerIp(i, playerip, 16);

		if(!isnull(playerip) && !strcmp(ip, playerip))
		{
			SetCommandPermissions(i, true);
			break;
		}
	}
}

SetCommandPermissions(playerid, bool:toggle)
{
	Command_SetPlayerNamed("commands", playerid, toggle);
	Command_SetPlayerNamed("reloadmaps", playerid, toggle);
	Command_SetPlayerNamed("reloadprops", playerid, toggle);
	Command_SetPlayerNamed("restart", playerid, toggle);
	Command_SetPlayerNamed("pause", playerid, toggle);
	Command_SetPlayerNamed("setroundtime", playerid, toggle);
	Command_SetPlayerNamed("setlobbytime", playerid, toggle);
	Command_SetPlayerNamed("setboundslimit", playerid, toggle);
	Command_SetPlayerNamed("spawnashider", playerid, toggle);
	Command_SetPlayerNamed("spawnasseeker", playerid, toggle);
}

YCMD:commands(playerid, params[], help)
{
	if(help)
	{
		SendClientMessage(playerid, COLOUR_YELLOW, " >  Lists all the commands a player can use.");
	}
	else
	{
		new count = Command_GetPlayerCommandCount(playerid);

		for(new i; i != count; ++i)
			SendClientMessage(playerid, COLOUR_YELLOW, Command_GetNext(i, playerid));
	}

	return 1;
}

YCMD:reloadmaps(playerid, params[], help)
{
	ReloadMaps();

	return 1;
}

YCMD:reloadprops(playerid, params[], help)
{
	ReloadPropSets();

	return 1;
}

YCMD:restart(playerid, params[], help)
{
	SendRconCommand("gmx");

	return 1;
}

YCMD:pause(playerid, params[], help)
{
	gPauseGame = !gPauseGame;

	return 1;
}

YCMD:setroundtime(playerid, params[], help)
{
	gRoundTime = strval(params);
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Round time updated");

	return 1;
}

YCMD:setlobbytime(playerid, params[], help)
{
	gLobbyTime = strval(params);
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Lobby time updated");

	return 1;
}

YCMD:setboundslimit(playerid, params[], help)
{
	gOutOfMapTime = strval(params);
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Out-of-bounds limit updated");

	return 1;
}

YCMD:spawnashider(playerid, params[], help)
{
	SpawnPlayerAsHider(playerid);

	return 1;
}

YCMD:spawnasseeker(playerid, params[], help)
{
	SpawnPlayerAsSeeker(playerid);

	return 1;
}
