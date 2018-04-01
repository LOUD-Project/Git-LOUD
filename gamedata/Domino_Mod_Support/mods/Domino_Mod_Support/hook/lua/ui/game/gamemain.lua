--*****************************************************************************
--* File: lua/modules/ui/game/gamemain.lua
--* Author: Chris Blackwell
--* Summary: Entry point for the in game UI
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************
local IsMerged = false
do
local OldSetLayout = SetLayout
function SetLayout(layout)
	OldSetLayout(layout)
    if not isReplay then
		if not IsMerged then 
			import('/lua/ui/game/orders.lua').Merge_Toggle_Tables()
			IsMerged = true
		end
    end
end


local oldOnSelectionChanged = OnSelectionChanged

function OnSelectionChanged(oldSelection, newSelection, added, removed)
	
	oldOnSelectionChanged(oldSelection, newSelection, added, removed)

	
	--Added this hook to place a flag in each unit in the sim to say self.IsSelected.
	
	local OldSelection = {}
	local NewSelection = {}
	
	for id, unit in oldSelection do
		OldSelection[unit:GetEntityId()] = unit:GetEntityId()
	end
	
	for id, unit in newSelection do
		NewSelection[unit:GetEntityId()] = unit:GetEntityId()
	end
	
	local SortedOldSelection = table.sorted(OldSelection)
	local SortedNewSelection = table.sorted(NewSelection)
	

	if table.getsize(SortedOldSelection) > 0 then
		local OS = { Func = 'RemoveSelectedUnits', Args = { OldSelection = SortedOldSelection } }
		SimCallback(OS, true)
	end

	if table.getsize(SortedNewSelection) > 0 then
		local NS = { Func = 'UpdateSelectedUnits', Args = { NewSelection = SortedNewSelection } }
		SimCallback(NS, true)
	end

	
end


local oldOnPause = OnPause
function OnPause(pausedBy, timeoutsRemaining)
	oldOnPause(pausedBy, timeoutsRemaining)

    import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').OnGamePause(true)
end

local oldOnResume = OnResume
function OnResume()
	oldOnResume()
    import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').OnGamePause(false)
end

local oldOnUserPause = OnUserPause
function OnUserPause(pause)
	oldOnUserPause(pause)
	
    local Tabs = import('/lua/ui/game/tabs.lua')
    local focus = GetArmiesTable().focusArmy
    if Tabs.CanUserPause() then
        if focus == -1 and not SessionIsReplay() then
            return
        end

        if pause then
            import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').PauseTransmission()
        else
            import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').ResumeTransmission()
        end
    end
end

end