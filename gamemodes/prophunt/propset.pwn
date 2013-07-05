#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


#define MAX_PROP_SETS				(32)
#define MAX_PROPS_PER_SET			(32)
#define MAX_PROP_SET_NAME			(32)


enum E_PROPSET_DATA
{
		propset_name[MAX_PROP_SET_NAME],
		propset_size,
		propset_props[MAX_PROPS_PER_SET]
}

new
		propset_Data[MAX_PROP_SETS][E_PROPSET_DATA],
		propset_Total;


/*==============================================================================

	Core

==============================================================================*/


LoadPropSets()
{
	new
		File:file,
		line[MAX_PROP_SET_NAME];

	if(!fexist(PROP_INDEX_FILE))
	{
		print("ERROR: Prop index file not found.");
		return;
	}

	print("\nLoading Props...\n");

	file = fopen(PROP_INDEX_FILE, io_read);

	propset_Total = 0;

	while(fread(file, line))
	{
		strtrim(line, "\r\n");
		LoadPropSet(line);
	}

	fclose(file);
}

LoadPropSet(propsetname[MAX_PROP_SET_NAME])
{
	new
		filename[64],
		File:file,
		line[128],
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

	format(filename, sizeof(filename), ""#PROP_DIRECTORY"%s", propsetname);

	if(!fexist(filename))
	{
		printf("ERROR: Map data file '%s' not found.", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	propset_Data[propset_Total][propset_name] = propsetname;
	propset_Data[propset_Total][propset_size] = 0;

	while(fread(file, line))
	{
		if(!sscanf(line, "p<,>dfffffffff", model, offsetx, offsety, offsetz, rotx, roty, rotz, scalex, scaley, scalez))
		{
			propset_Data[propset_Total][propset_props][propset_Data[propset_Total][propset_size]] = AddProp(model, offsetx, offsety, offsetz, rotx, roty, rotz, scalex, scaley, scalez);
			propset_Data[propset_Total][propset_size]++;
		}
		else
		{
			printf("ERROR: Loading prop %d from '%s'", propset_Data[propset_Total][propset_size] + 1, filename);
		}
	}

	fclose(file);
	printf("\tLoaded Propset (%d): '%s' size: %d", propset_Total, propsetname, propset_Data[propset_Total][propset_size]);
	propset_Total++;

	return 1;
}

ReloadPropSets()
{
	ResetPropTotal();
	LoadPropSets();
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetPropSetID(propsetname[])
{
	if(isnull(propsetname))
		return -1;

	new id = -1;

	for(new i; i < propset_Total; i++)
	{
		if(!strcmp(propsetname, propset_Data[i][propset_name]))
		{
			id = i;
			break;
		}
	}

	return id;
}

stock GetPropSetName(propsetid, name[MAX_PROP_SET_NAME])
{
	if(!(0 <= propsetid < propset_Total))
		return 0;

	name = propset_Data[id][propset_name];

	return 1;
}

stock GetRandomPropFromSet(propsetid)
{
	if(!(0 <= propsetid < propset_Total))
		return 0;

	return propset_Data[propsetid][propset_props][random(propset_Data[propsetid][propset_size])];
}
