/*==============================================================================


	Southclaw's Prop Hunt

		A gamemode inspired by the popular Team Fortress 2 mod "PropHunt"
		by Darkimmortal.


==============================================================================*/


#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS	(32)

native IsValidVehicle(vehicleid);


/*==============================================================================


	Main


==============================================================================*/

#define MAX_PROPS (18)

new
	gPropList[MAX_PROPS]=
	{
	    1227,
	    1208,
	    1224,
	    1221,
	    1236,
	    1299,
	    1300,
		1331,
		1332,
		1333,
		1334,
		1335,
		1336,
		1337,
		1340,
		1344,
		1345,
		1346
	};

main()
{
}


public OnGameModeInit()
{

	AddPlayerClass(0, -2763.2041, 85.0597, 7.5184, 270.0, 0, 0, 0, 0, 0, 0);

	return 1;
}

public OnGameModeExit()
{

	return 1;
}

public OnPlayerConnect(playerid)
{

	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerWorldBounds(playerid, -2715.92, -2799.01, 147.67, 49.51);
	
	SetPlayerAttachedObject(playerid, 0, gPropList[random(sizeof(gPropList))], 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_CROUCH)
	{
		ApplyAnimation(playerid, "PED", "COWER", 4.0, 0, 1, 1, 1, 100);
	}
	if(newkeys & KEY_SPRINT)
	{
	    ClearAnimations(playerid);
	}
}





































