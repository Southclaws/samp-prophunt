/*==============================================================================

	Variables

==============================================================================*/


#define MAX_PROP_SETS				(32)
#define MAX_PROPS_PER_SET			(32)
#define MAX_PROP_SET_NAME			(32)


enum E_PROPSET_DATA
{
		propset_name[MAX_PROP_SET_NAME],
		propset_animLibrary[32],
		propset_animName[32],
		propset_size,
		propset_props[MAX_PROPS_PER_SET]
}

static
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
		print("ERROR: Prop index file not found.\n");
		return 0;
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

	if(propset_Total == 0)
	{
		printf("ERROR: No propsets loaded.\n");
		return 0;
	}

	return 1;
}

LoadPropSet(propsetname[MAX_PROP_SET_NAME])
{
	new
		filename[64],
		File:file,
		line[256],
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

	format(filename, sizeof(filename), ""PROP_DIRECTORY"%s", propsetname);

	if(!fexist(filename))
	{
		printf("ERROR: Map data file '%s' not found.", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	propset_Data[propset_Total][propset_name] = propsetname;
	propset_Data[propset_Total][propset_size] = 0;

	// Load the animation for the propset (library and animation name pair, separated by '\')
	fread(file, line);
	strtrim(line, "\r\n");
	if(sscanf(line, "p</>s[32]s[32]", propset_Data[propset_Total][propset_animLibrary], propset_Data[propset_Total][propset_animName]))
	{
		printf("ERROR: Loading animation data from line 1 of '%s'", filename);
		print("Please place an animation library and animation name separated by a / character on line 1 of the file.");
		return 1;
	}

	// Load each line after the animation data, parse for attachment model, offset, rotation and scale data
	while(fread(file, line))
	{
		if(!sscanf(line, "p<,>dffffffffp<;>f{S(_)}", model, offsetx, offsety, offsetz, rotx, roty, rotz, scalex, scaley, scalez))
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
	printf("\tLoaded Propset (%d): '%s' size: %d Animation: '%s/%s'", propset_Total, propsetname, propset_Data[propset_Total][propset_size], propset_Data[propset_Total][propset_animLibrary], propset_Data[propset_Total][propset_animName]);
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


stock GetPropSetID(const propsetname[])
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

stock GetTotalProps()
{
	return propset_Total;
}

stock GetPropsetAnimData(propsetid, lib[], name[])
{
	lib[0] = EOS;
	name[0] = EOS;

	strcat(lib, propset_Data[propsetid][propset_animLibrary], 32);
	strcat(name, propset_Data[propsetid][propset_animName], 32);

	return 1;
}
