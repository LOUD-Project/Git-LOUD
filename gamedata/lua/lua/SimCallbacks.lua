# This module contains the Sim-side lua functions that can be invoked
# from the user side.  These need to validate all arguments against
# cheats and exploits.

# We store the callbacks in a sub-table (instead of directly in the
# module) so that we don't include any

local Callbacks = {}

function DoCallback(name, data, units)
    local fn = Callbacks[name];
    if fn then
        fn(data, units)
    else
        error('No callback named ' .. repr(name))
    end
end

Callbacks.BreakAlliance = import('/lua/simutils.lua').BreakAlliance
Callbacks.GiveOrders = import('/lua/spreadattack.lua').GiveOrders
Callbacks.GiveUnitsToPlayer = import('/lua/simutils.lua').GiveUnitsToPlayer
Callbacks.GiveResourcesToPlayer = import('/lua/simutils.lua').GiveResourcesToPlayer
Callbacks.SetResourceSharing = import('/lua/simutils.lua').SetResourceSharing
Callbacks.RequestAlliedVictory = import('/lua/simutils.lua').RequestAlliedVictory
Callbacks.SetOfferDraw = import('/lua/simutils.lua').SetOfferDraw

Callbacks.SpawnPing = import('/lua/simping.lua').SpawnPing
Callbacks.UpdateMarker = import('/lua/simping.lua').UpdateMarker
Callbacks.FactionSelection = import('/lua/scenarioframework.lua').OnFactionSelect
Callbacks.ToggleSelfDestruct = import('/lua/selfdestruct.lua').ToggleSelfDestruct
Callbacks.MarkerOnScreen = import('/lua/simcameramarkers.lua').MarkerOnScreen
Callbacks.SimDialogueButtonPress = import('/lua/simdialogue.lua').OnButtonPress

Callbacks.AIChat = import('/lua/ai/sorianutilities.lua').FinishAIChat

Callbacks.DiplomacyHandler = import('/lua/simdiplomacy.lua').DiplomacyHandler

Callbacks.OnCameraFinish = import('/lua/simcamera.lua').OnCameraFinish
Callbacks.OnPlayerQuery = import('/lua/simplayerquery.lua').OnPlayerQuery
Callbacks.OnPlayerQueryResult = import('/lua/simplayerquery.lua').OnPlayerQueryResult
Callbacks.PingGroupClick = import('/lua/simpinggroup.lua').OnClickCallback

Callbacks.NoteSimSpeedChange = function(data)
	UpdateSimSpeed(data)
end


function Callbacks.OnMovieFinished(name)
    ScenarioInfo.DialogueFinished[name] = true
end

Callbacks.OnControlGroupAssign = function(units)
end

Callbacks.OnControlGroupApply = function(units)
end

--Toggles
function Callbacks.ToggleTheBit(data)

	local Units = data.Params.Units
	local ToggleState = data.Params.ToggleState
	local ToggleName = data.Params.BitName

	for i,u in Units do
		local unit = GetEntityById(u)
		if unit and UnitData[u].Data[ToggleName] then 
			if ToggleState then 
				--if true toggle the bit off
				unit.Sync[ToggleName ..'_state'] = ToggleState
				unit:OnExtraToggleSet(ToggleName)
			else
				--if false toggle the bit on
				unit.Sync[ToggleName ..'_state'] = ToggleState
				unit:OnExtraToggleClear(ToggleName)
			end
		end
	end
end
	
--Selected Units
function Callbacks.RemoveSelectedUnits(data)

	if table.getsize(data.OldSelection) > 0 then
		for i, unit in data.OldSelection do
			if GetEntityById(unit) then 
				local RemUnit = GetEntityById(unit)

				if RemUnit then 
					RemUnit.IsSelected = false
				end
			end
		end
	end
end
	
function Callbacks.UpdateSelectedUnits(data)

	if table.getsize(data.NewSelection) > 0 then
		for i, unit in data.NewSelection do
			if GetEntityById(unit) then 
				local SelUnit = GetEntityById(unit)

				if SelUnit then 
					SelUnit.IsSelected = true
				end
			end
		end
	end
end



