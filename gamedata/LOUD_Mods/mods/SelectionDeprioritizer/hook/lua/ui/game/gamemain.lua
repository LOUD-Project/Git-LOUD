local SelectionDeprioritizer = import('/mods/SelectionDeprioritizer/modules/SelectionDeprioritizer.lua')
local Selection = import('/lua/ui/game/selection.lua')

local pathMod = '/lua/hotbuild/'
local upgradeTab = import(pathMod .. 'upgradeTab.lua').upgradeTab

-- Function to remove low priority units from a selection which includes units other than low priority ones
-- Original version from FAF
-- Credit to IceDreamer (https://github.com/aeoncleanse)
function OldDeselectSelens(selection)
    local LowPriorityUnits = false
    local otherUnits = false

    -- Find any units with the low priority flag
    for id, unit in selection do
        -- Stupid-ass UnitData table uses string number IDs as keys
        if UnitData[unit:GetEntityId()].LowPriority then
            LowPriorityUnits = true
        else
            if not otherUnits then otherUnits = {} end -- Ugly hack to make later logic easier
            table.insert(otherUnits, unit)
        end
    end

    -- Return original selection with no-change key if nothing has changed
    if (otherUnits and not LowPriorityUnits) or (not otherUnits and LowPriorityUnits) then
        return selection, false
    end

    return otherUnits, true
end

function DeselectSelens(selection)

	local oldChanged, changed = false, false
	local newSelection = selection
	newSelection, oldChanged = OldDeselectSelens(newSelection)

	newSelection, changed = SelectionDeprioritizer.Deselect(newSelection)

	--[[
		Do selection in here because the SelectUnits in FAF's OnSelectionChanged makes no noise. If that
		gets fixed, remove the call here.
	]]
	if oldChanged or changed then
		SelectUnits(newSelection)
		return newSelection, oldChanged or changed
	end

	return selection, false

end

-- This function is called whenever the set of currently selected units changes
-- See /lua/unit.lua for more information on the lua unit object
--      oldSelection: What the selection was before
--      newSelection: What the selection is now
--      added: Which units were added to the old selection
--      removed: Which units where removed from the old selection
function OnSelectionChanged(oldSelection, newSelection, added, removed)

    -- Deselect Selens if necessary. Also do work on Hotbuild labels
    local changed = false -- Prevent recursion
    if newSelection and table.getn(newSelection) > 0 then
        newSelection, changed = DeselectSelens(newSelection)

        if changed then
            ForkThread(function()
                SelectUnits(newSelection)
            end)
            return
        end

        -- This bit is for the Hotbuild labels
        local bp = newSelection[1]:GetBlueprint()
        local upgradesTo = nil
        local potentialUpgrades = upgradeTab[bp.BlueprintId] or bp.General.UpgradesTo
        if potentialUpgrades then
            if type(potentialUpgrades) == "string" then 
                upgradesTo = potentialUpgrades
            elseif type(potentialUpgrades) == "table" then 
                local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(newSelection)
                for _, v in potentialUpgrades do
                    if EntityCategoryContains(buildableCategories, v) then
                        upgradesTo = v
                        break
                    end
                end
            end
        end

        if upgradesTo and upgradesTo:len() < 7 then
            upgradesTo = nil
        end
        local isFactory = newSelection[1]:IsInCategory("FACTORY")
        -- hotkeyLabelsOnSelectionChanged(upgradesTo, isFactory)
    end

    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(newSelection)
    local isOldSelection = table.equal(oldSelection, newSelection)

    if not gameUIHidden then
	
        if not isReplay then
		
            import('/lua/ui/game/orders.lua').SetAvailableOrders(availableOrders, availableToggles, newSelection)
			
        end
		
        -- todo change the current command mode if no longer available? or set to nil?
        import('/lua/ui/game/construction.lua').OnSelection(buildableCategories,newSelection,isOldSelection)
		
    end

    if not isOldSelection then
	
        import('/lua/ui/game/selection.lua').PlaySelectionSound(added)
        import('/lua/ui/game/rallypoint.lua').OnSelectionChanged(newSelection)
		
    end
	
	local selUnits = newSelection

    if selUnits and table.getn(selUnits) == 1
    and import('/lua/gaz_ui/modules/selectedinfo.lua').SelectedOverlayOn then
    
        import('/lua/gaz_ui/modules/selectedinfo.lua').ActivateSingleRangeOverlay()
        
    else
		import('/lua/gaz_ui/modules/selectedinfo.lua').DeactivateSingleRangeOverlay()
        
	end 

end


local oldCreateUI = CreateUI
function CreateUI(isReplay) 
	oldCreateUI(isReplay)
	import('/mods/SelectionDeprioritizer/modules/SelectionDeprioritizerConfig.lua').init()
end
