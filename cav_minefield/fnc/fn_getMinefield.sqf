
#include "..\script_macros.hpp"

params ["_trigger"];

if(isNil QGVAR(minefieldData)) exitWith {nil};

_minefield = nil;
{
	if(_x select 1 == _trigger) then {
		_minefield = _x;
	};
} foreach GVAR(minefieldData);

_minefield