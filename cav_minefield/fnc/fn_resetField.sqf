
#include "..\script_macros.hpp"

params ["_target","_caller","_id","_args"];
_args params ["_ctrlObject","_trigger","_name","_count","_types","_minDistance"];

LOG_1("Resetting minefield for %1",_trigger);
hint (format ["Minefield %1 Reset",_name]);

_hook = GET_VAR(_trigger,GVAR(layHook),nil);

if(!isNil "_hook") then {
	terminate _hook;
};

{ deleteVehicle _x; } foreach (GET_VAR(_trigger,GVAR(mines),[]));

{
	if(_x isKindOf "GroundWeaponHolder") then {
		deleteVehicle _x;
	};
} foreach list _trigger;

[nil,nil,nil,[_ctrlObject,_trigger,_name,_count,_types,_minDistance]] call FUNC(layField);