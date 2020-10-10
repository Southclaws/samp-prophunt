#define CMD:%1(%2)		forward cmd_%1(%2);\
						public cmd_%1(%2)

#define ACMD:%1(%2)		forward acmd_%1(%2);\
						public acmd_%1(%2)


/*==============================================================================

	Command processing

==============================================================================*/


public OnPlayerCommandText(playerid, cmdtext[])
{
	new
		cmd[30],
		params[127],
		cmdfunction[64],
		result = 1;

	printf("[cmds] [%p]: %s", playerid, cmdtext);

	sscanf(cmdtext, "s[30]s[127]", cmd, params);

	for (new i, j = strlen(cmd); i < j; i++)
		cmd[i] = tolower(cmd[i]);

	format(cmdfunction, 64, "cmd_%s", cmd[1]);

	if(funcidx(cmdfunction) == -1)
	{
		if(IsPlayerAdmin(playerid))
		{
			format(cmdfunction, 64, "acmd_%s", cmd[1]);
			result = 1;
		}
		else
		{
			return 0;
		}
	}

	if(result == 1)
	{
		if(isnull(params))
			result = CallLocalFunction(cmdfunction, "is", playerid, "\1");

		else
			result = CallLocalFunction(cmdfunction, "is", playerid, params);
	}

	return result;
}


/*==============================================================================

	Admin commands

==============================================================================*/


ACMD:reloadmaps(playerid, params[], help)
{
	ReloadMaps();

	return 1;
}

ACMD:reloadprops(playerid, params[], help)
{
	ReloadPropSets();

	return 1;
}

ACMD:restart(playerid, params[], help)
{
	SendRconCommand("gmx");

	return 1;
}

ACMD:pause(playerid, params[], help)
{
	gPauseGame = !gPauseGame;

	return 1;
}

ACMD:setroundtime(playerid, params[], help)
{
	gRoundTime = strval(params);
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Round time updated");

	return 1;
}

ACMD:setlobbytime(playerid, params[], help)
{
	gLobbyTime = strval(params);
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Lobby time updated");

	return 1;
}

ACMD:setboundslimit(playerid, params[], help)
{
	gOutOfMapTime = strval(params);
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Out-of-bounds limit updated");

	return 1;
}

ACMD:spawnashider(playerid, params[], help)
{
	SpawnPlayerAsHider(playerid);

	return 1;
}

ACMD:spawnasseeker(playerid, params[], help)
{
	SpawnPlayerAsSeeker(playerid);

	return 1;
}


/*==============================================================================

	Regular commands

==============================================================================*/


CMD:credits(playerid, params[], help)
{
	SendClientMessage(playerid, COLOUR_YELLOW, "");
	SendClientMessage(playerid, COLOUR_YELLOW, " >  Server Credits:");
	SendClientMessage(playerid, COLOUR_YELLOW, " >  "EMBED_BLUE"Darkimmortal - "EMBED_GREEN"Original PropHunt idea for TF2");
	SendClientMessage(playerid, COLOUR_YELLOW, " >  "EMBED_BLUE"Southclaw - "EMBED_GREEN"SA:MP Version of PropHunt");
	SendClientMessage(playerid, COLOUR_YELLOW, "");

	return 1;
}
