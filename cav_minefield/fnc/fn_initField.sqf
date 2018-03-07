#include "..\script_macros.hpp"

// fields should only init from server
if(isMultiplayer && !isServer) exitWith {};

INFO_2("Initializing minefield: %1 (Build: %2)",_this,QUOTE(PROJECT_VERSION)); 

params ["_ctrlObject","_trigger","_name", "_count", "_types", ["_minDistance",0]];

DEF_GVAR(minefieldData,[]);
LOG_GVAR(minefieldData);
LOG("I can change it and restart");

// Check if the trigger already has a minefield assigned to it
_fieldId = -1;
{
	if(_x select 1 == _trigger) then {
		_fieldId = _forEachIndex;
	};
} foreach GVAR(minefieldData);

if(_fieldId >= 0) then {WARNING_1("Trigger %1 already has a minefield assigned to it. Replacing action.",_trigger)};

// change to check
_addId = _trigger getVariable [QGVAR(addId), -1];
if(_addId >= 0) then {_ctrlObject removeAction _addId; LOG_2("%1 removing addId: %2", vehicleVarName _trigger, _addId)};

_resetId = _trigger getVariable [QGVAR(resetId), -1];
if(_resetId >= 0) then {_ctrlObject removeAction _resetId; LOG_2("%1 removing resetId: %2", vehicleVarName _trigger, _resetId)};

_clearId = _trigger getVariable [QGVAR(clearId), -1];
if(_clearId >= 0) then {_ctrlObject removeAction _clearId; LOG_2("%1 removing clearId: %2", vehicleVarName _trigger, _clearId)};

_newAddId = _ctrlObject addAction [
	format ["Lay Minefield %1",_name],
	FUNC(layField),
	[_ctrlObject,_trigger,_name,_count,_types,_minDistance],
	1.5,true,true,"",
	format ["!(%1 getVariable ['%2',false])",vehicleVarName _trigger,QGVAR(fieldSet)]
];
_newResetId = _ctrlObject addAction [
	format ["Reset Minefield %1",_name],
	FUNC(resetField),
	[_ctrlObject,_trigger,_name,_count,_types,_minDistance],
	1.5,true,true,"",
	format ["%1 getVariable ['%2',false]",vehicleVarName _trigger,QGVAR(fieldSet)]
];
_newClearId = _ctrlObject addAction [
	format ["Clear Minefield %1",_name],
	FUNC(clearField),
	[_ctrlObject,_trigger,_name,_count,_types,_minDistance],
	1.5,true,true,"",
	format ["%1 getVariable ['%2',false]",vehicleVarName _trigger,QGVAR(fieldSet)]
];

LOG_2("%1 adding newAddId: %2", vehicleVarName _trigger, _newAddId);
LOG_2("%1 adding newResetId: %2", vehicleVarName _trigger, _newResetId);
LOG_2("%1 adding newClearId: %2", vehicleVarName _trigger, _newClearId);
_trigger setVariable [QGVAR(addId), _newAddId];
_trigger setVariable [QGVAR(resetId), _newResetId];
_trigger setVariable [QGVAR(clearId), _newClearId];

// add the field to the global list
if(_fieldId >= 0) then {
	GVAR(minefieldData) set [_fieldId, [_ctrlObject,_trigger,_name,_count,_types,_minDistance]];
	LOG_2("Overwriting minefield %1 as index %2 in data",_name,_fieldId);
} else {
	_id = GVAR(minefieldData) pushBack [_ctrlObject,_trigger,_name,_count,_types,_minDistance];
	LOG_2("Pushing minefield %1 as index %2 in data",_name,_id);
};