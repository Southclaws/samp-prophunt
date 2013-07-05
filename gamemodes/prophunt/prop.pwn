#include <YSI\y_hooks>


/*==============================================================================

	Variables

==============================================================================*/


#define MAX_PROPS					(128)


enum E_PROP_DATA
{
		prop_model,
Float:	prop_posX,
Float:	prop_posY,
Float:	prop_posZ,
Float:	prop_rotX,
Float:	prop_rotY,
Float:	prop_rotZ,
Float:	prop_scaX,
Float:	prop_scaY,
Float:	prop_scaZ
}

static
		prop_Data[MAX_PROPS][E_PROP_DATA],
		prop_Total;


/*==============================================================================

	Core

==============================================================================*/


AddProp(model, Float:posX, Float:posY, Float:posZ, Float:rotX, Float:rotY, Float:rotZ, Float:scaX, Float:scaY, Float:scaZ)
{
	if(prop_Total == MAX_PROPS)
	{
		print("ERROR: Prop limit reached.");
		return 0;
	}

	prop_Data[prop_Total][prop_model] = model;
	prop_Data[prop_Total][prop_posX] = posX;
	prop_Data[prop_Total][prop_posY] = posY;
	prop_Data[prop_Total][prop_posZ] = posZ;
	prop_Data[prop_Total][prop_rotX] = rotX;
	prop_Data[prop_Total][prop_rotY] = rotY;
	prop_Data[prop_Total][prop_rotZ] = rotZ;
	prop_Data[prop_Total][prop_scaX] = scaX;
	prop_Data[prop_Total][prop_scaY] = scaY;
	prop_Data[prop_Total][prop_scaZ] = scaZ;

	return prop_Total++;
}


/*==============================================================================

	Interface

==============================================================================*/


GetPropModel(propid)
{
	if(!(0 <= propid < prop_Total))
		return 0;

	return prop_Data[propid][prop_model];
}

GetPropOffset(propid, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= propid < prop_Total))
		return 0;

	x = prop_Data[propid][prop_posX];
	y = prop_Data[propid][prop_posY];
	z = prop_Data[propid][prop_posZ];

	return 1;
}

GetPropRotation(propid, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= propid < prop_Total))
		return 0;

	x = prop_Data[propid][prop_rotX];
	y = prop_Data[propid][prop_rotY];
	z = prop_Data[propid][prop_rotZ];

	return 1;
}

GetPropScale(propid, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= propid < prop_Total))
		return 0;

	x = prop_Data[propid][prop_scaX];
	y = prop_Data[propid][prop_scaY];
	z = prop_Data[propid][prop_scaZ];

	return 1;
}

ResetPropTotal()
{
	prop_Total = 0;
}
