/*==============================================================================


	API file for writing extra code in hooked callbacks from the main game.

		From here you can add on to the simple game by using the available
		callbacks. For instance, a ranking or stats system could be made with
		the player win/loss callback.


==============================================================================*/


public OnRoundStart()
{
	return 1;
}

public OnRoundEnd(winningteam)
{
	return 1;
}

public OnPlayerKill(playerid, targetid)
{
	return 1;
}
