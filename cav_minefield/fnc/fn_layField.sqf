#include "..\script_macros.hpp"

/*
 * Author: WO1.Raynor.D
 * Place mines
 *
 * Arguments:
 * Area Name
 * Trigger area
 * Mine count
 * Mine Type(s)
 * Minimum Distance
 *
 
 "Sign_Sphere25cm_F"
 
 minefield data format:
 
	name
	script hook
	array of mines
 
 * Example:
 * 
 */

params ["_target","_caller","_id","_args"];
_args params ["_ctrlObject","_trigger","_name","_count","_types","_minDistance"];

LOG_1("Laying minefield: %1",_this); 

SET_VAR(_trigger,GVAR(fieldSet),true);

{ deleteVehicle _x; } foreach (GET_VAR(_trigger,GVAR(mines),[]));

if(isNil QGVAR(minefieldData)) then {GVAR(minefieldData) = []};

//if(true) exitWith {};

//{deleteVehicle _x} foreach GVAR(minefieldData);
sleep 1;

_mines = [];
_minesPos = [];
for "_i" from 0 to (_count - 1) do {
	_pos = [];
	if(_i == 0 || _minDistance == 0) then {
		_pos = ([_trigger] call BIS_fnc_randomPosTrigger);
	} else {
		_found = false;
		_tries = 0;
		while{!_found && _tries < 1000} do {
			_tooClose = false;
			_pos = ([_trigger] call BIS_fnc_randomPosTrigger);
			{
				if(_pos distance _x < _minDistance) exitWith {_tooClose = true;};
			} foreach _minesPos;
			
			if(_tooClose) then {
				_tries = _tries + 1;
			} else {
				_found = true;
			};
		};
	};

	_type = (_types select (floor random (count _types)));
	_mine = (_type createvehicle _pos);
	_mine setDir (random 360);
	_mines pushback _mine;
	_minesPos pushBack _pos;
};

SET_VAR(_trigger,GVAR(mines),_mines);


_hook = [_trigger,_name] spawn {
	params ["_trigger","_name"];
	
	LOG_3("Watching array: %1 > %2 (Count: %3)", _trigger, (GET_VAR(_trigger,GVAR(mines),[])), count (GET_VAR(_trigger,GVAR(mines),[])));

	_cleared = false;
	while{!_cleared} do {
		sleep 1;
		_continue = true;
		{
			if(!isNull _x) exitWith {_continue = false};
		} foreach (GET_VAR(_trigger,GVAR(mines),[]));
		if(_continue) then {_cleared = true};
	};
	
	sleep 3;
	
	{
		deleteVehicle _x;
	} foreach nearestObjects [_trigger,["GroundWeaponHolder"],((triggerArea _trigger select 0) max (triggerArea _trigger select 1)) * 2];

	SET_VAR(_trigger,GVAR(fieldSet),nil);
	hint format ["Minefield (%1) cleared! Good job!", _name];
};

SET_VAR(_trigger,GVAR(layHook),_hook);


