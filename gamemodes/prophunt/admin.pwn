CMD:reloadmaps(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, -1, " >  Admin only command.");
		return 1;
	}

	ReloadMaps();

	return 1;
}

CMD:restart(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, -1, " >  Admin only command.");
		return 1;
	}

	SendRconCommand("gmx");

	return 1;
}

CMD:pause(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, -1, " >  Admin only command.");
		return 1;
	}

	gPauseGame = !gPauseGame;

	return 1;
}
