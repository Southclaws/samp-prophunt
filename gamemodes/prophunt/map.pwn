#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


#define MAX_MAPS				(32)
#define MAP_INDEX_FILE			"PropHunt/maplist.cfg"
#define MAP_DIRECTORY			"PropHunt/Maps/"
#define MAX_PROP_TYPES_PER_MAP	(32)


enum E_MAP_DATA
{
Float:	map_bounds[4],
Float:	map_hideSpawn[4],
Float:	map_seekSpawn[4],
		map_propList[MAX_PROP_TYPES_PER_MAP],
		map_totalProps
}

static
		map_Data[MAX_MAPS][E_MAP_DATA],
		map_Total;


/*==============================================================================

	Core

==============================================================================*/


hook OnGameModeInit()
{
	LoadMaps();
}

LoadMaps()
{
	new
		File:file,
		line[128];

	if(!fexist(MAP_INDEX_FILE))
	{
		print("ERROR: Map index file not found.");
		return;
	}

	file = fopen(MAP_INDEX_FILE, io_read);

	while(fread(file, line))
	{
		strtrim(line, "\r\n");
		LoadMap(line);
	}

	fclose(file);
}

LoadMap(mapname[])
{
	new
		filename[64],
		File:file,
		line[128],
		data[2][64],
		loaded_bounds,
		loaded_hidespawn,
		loaded_seekspawn;

	format(filename, sizeof(filename), ""#MAP_DIRECTORY"%s.map", mapname);

	if(!fexist(filename))
	{
		printf("ERROR: Map data file '%s' not found.", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	map_Data[map_Total][map_totalProps] = 0;

	while(fread(file, line))
	{
		strtrim(line, "\r\n\t");

		if(isnull(line))
			continue;

		strexplode(data, line, ":", 2);

		// Map Boundaries
		if(!loaded_bounds)
		{
			if(!strcmp(data[0], "map-bounds"))
			{
				sscanf(data[1], "p<,>ffff", map_Data[map_Total][map_bounds][0], map_Data[map_Total][map_bounds][1], map_Data[map_Total][map_bounds][2], map_Data[map_Total][map_bounds][3]);
				loaded_bounds = true;
			}
		}

		// Hider Spawn
		if(!loaded_hidespawn)
		{
			if(!strcmp(data[0], "hide-spawn"))
			{
				sscanf(data[1], "p<,>ffff", map_Data[map_Total][map_hideSpawn][0], map_Data[map_Total][map_hideSpawn][1], map_Data[map_Total][map_hideSpawn][2], map_Data[map_Total][map_hideSpawn][3]);
				loaded_hidespawn = true;
			}
		}

		// Seeker Spawn
		if(!loaded_seekspawn)
		{
			if(!strcmp(data[0], "seek-spawn"))
			{
				sscanf(data[1], "p<,>ffff", map_Data[map_Total][map_seekSpawn][0], map_Data[map_Total][map_seekSpawn][1], map_Data[map_Total][map_seekSpawn][2], map_Data[map_Total][map_seekSpawn][3]);
				loaded_seekspawn = true;
			}
		}

		// Prop List
		if(!strcmp(data[0], "prop"))
		{
			if(!sscanf(data[1], "d", map_Data[map_Total][map_propList][map_Data[map_Total][map_totalProps]]))
			{
				map_Data[map_Total][map_totalProps]++;
			}
		}

		// Objects

		//print(line);
	}

/*
	printf("Map Boundaries: %f, %f, %f, %f", map_Data[map_Total][map_bounds][0], map_Data[map_Total][map_bounds][1], map_Data[map_Total][map_bounds][2], map_Data[map_Total][map_bounds][3]);
	printf("Hide Spawn: %f, %f, %f, %f", map_Data[map_Total][map_hideSpawn][0], map_Data[map_Total][map_hideSpawn][1], map_Data[map_Total][map_hideSpawn][2], map_Data[map_Total][map_hideSpawn][3]);
	printf("Seek Spawn: %f, %f, %f, %f", map_Data[map_Total][map_seekSpawn][0], map_Data[map_Total][map_seekSpawn][1], map_Data[map_Total][map_seekSpawn][2], map_Data[map_Total][map_seekSpawn][3]);

	for(new i; i < map_Data[map_Total][map_totalProps]; i++)
		printf("Prop%d: %d", i, map_Data[map_Total][map_propList][i]);
*/

	fclose(file);
	printf("Loaded Map (%d): '%s'", map_Total, mapname);
	map_Total++;

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetMapBounds(&Float:minx, &Float:maxx, &Float:miny, &Float:maxy)
{
	minx = map_Data[gCurrentMap][map_bounds][0];
	maxx = map_Data[gCurrentMap][map_bounds][1];
	miny = map_Data[gCurrentMap][map_bounds][2];
	maxy = map_Data[gCurrentMap][map_bounds][3];
}

stock GetHiderSpawn(&Float:x, &Float:y, &Float:z, &Float:r)
{
	x = map_Data[gCurrentMap][map_hideSpawn][0];
	y = map_Data[gCurrentMap][map_hideSpawn][1];
	z = map_Data[gCurrentMap][map_hideSpawn][2];
	r = map_Data[gCurrentMap][map_hideSpawn][3];
}

stock GetSeekerSpawn(&Float:x, &Float:y, &Float:z, &Float:r)
{
	x = map_Data[gCurrentMap][map_seekSpawn][0];
	y = map_Data[gCurrentMap][map_seekSpawn][1];
	z = map_Data[gCurrentMap][map_seekSpawn][2];
	r = map_Data[gCurrentMap][map_seekSpawn][3];
}

stock GetRandomProp()
{
	return map_Data[gCurrentMap][map_propList][random(map_Data[gCurrentMap][map_totalProps])];
}

stock GetTotalMaps()
{
	return map_Total;
}

stock ReloadMaps()
{
	print("Reloading Maps");
	map_Total = 0;
	LoadMaps();
}
