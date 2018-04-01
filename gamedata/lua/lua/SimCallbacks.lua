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


function Callbacks.OnMovieFinished(name)
    ScenarioInfo.DialogueFinished[name] = true
end

Callbacks.OnControlGroupAssign = function(units)

    if ScenarioInfo.tutorial then
        local function OnUnitKilled(unit)
            if ScenarioInfo.ControlGroupUnits then
                for i,v in ScenarioInfo.ControlGroupUnits do
                   if unit == v then
                        LOUDREMOVE(ScenarioInfo.ControlGroupUnits, i)
                   end 
                end
            end
        end


        if not ScenarioInfo.ControlGroupUnits then
            ScenarioInfo.ControlGroupUnits = {}
        end
        
        # add units to list
        local entities = {}
        for k,v in units do
            LOUDINSERT(entities, GetEntityById(v))
        end
        ScenarioInfo.ControlGroupUnits = table.merged(ScenarioInfo.ControlGroupUnits, entities)

        # remove units on death
        for k,v in entities do
            import('/lua/scenariotriggers.lua').CreateUnitDeathTrigger(OnUnitKilled, v)
            import('/lua/scenariotriggers.lua').CreateUnitReclaimedTrigger(OnUnitKilled, v) #same as killing for our purposes   
        end
    end
end

Callbacks.OnControlGroupApply = function(units)
end


