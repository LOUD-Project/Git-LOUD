
do

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 

local constructionTabs = __DMSI.__Dmod_ConstructionTabs
local nestedTabKey = __DMSI.__DMod_NestedTabKey
local enhancementTooltips = __DMSI.__DMod_EnhancementTooltips
local Custom_Enhancement_Tooltips = __DMSI.__DMod_Custom_Tooltips

local OldCommonLogic = CommonLogic
function CommonLogic()
	OldCommonLogic()
    
    local oldSecChoiceSetControlToType = controls.secondaryChoices.SetControlToType
    controls.secondaryChoices.SetControlToType = function(control, type)
		oldSecChoiceSetControlToType(control, type)
		--MOD ICON
		if __blueprints[control.Data.id].ModIconName then
			local ModIcon = __blueprints[control.Data.id].ModIconName
			if DiskGetFileInfo(UIUtil.UIFile('/icons/modicons/'..ModIcon..'_icon.dds')) then
				control.ModIcon:SetTexture(UIUtil.UIFile('/icons/modicons/'..ModIcon..'_icon.dds'))				   
				control.ModIcon.Height:Set(20)
				control.ModIcon.Width:Set(20)
			else
				control.ModIcon:SetSolidColor('ff00ff00')
			end
		else
			control.ModIcon:SetSolidColor('00000000')
		end
        
    end
    
	local oldSecChoCreateElement = controls.secondaryChoices.CreateElement
    controls.secondaryChoices.CreateElement = function()
        local btn = oldSecChoCreateElement()
        		
		--MOD ICON
		btn.ModIcon = Bitmap(btn.Icon)
        btn.ModIcon:DisableHitTest()
        LayoutHelpers.AtBottomIn(btn.ModIcon, btn.Icon, 1)
        LayoutHelpers.AtLeftIn(btn.ModIcon, btn.Icon, 2)
                
        return btn
    end
    
	local choiceCreateElement = controls.choices.CreateElement
    controls.choices.CreateElement = function()
        local btn = choiceCreateElement()
        		
		--MOD ICON
		btn.ModIcon = Bitmap(btn.Icon)
        btn.ModIcon:DisableHitTest()
        LayoutHelpers.AtBottomIn(btn.ModIcon, btn.Icon, 1)
        LayoutHelpers.AtLeftIn(btn.ModIcon, btn.Icon, 2)
                
        return btn
    end
    
	local choiceSetControlToType = controls.choices.SetControlToType
    controls.choices.SetControlToType = function(control, type)
        choiceSetControlToType(control, type)
			
		--MOD ICON
		if __blueprints[control.Data.id].ModIconName then
			local ModIcon = __blueprints[control.Data.id].ModIconName
			if DiskGetFileInfo(UIUtil.UIFile('/icons/modicons/'..ModIcon..'_icon.dds')) then
				control.ModIcon:SetTexture(UIUtil.UIFile('/icons/modicons/'..ModIcon..'_icon.dds'))				
				control.ModIcon.Height:Set(20)
				control.ModIcon.Width:Set(20)	
			else
				control.ModIcon:SetSolidColor('ff00ff00')
			end
		else
			control.ModIcon:SetSolidColor('00000000')
		end
	end
end

--This adds the custom enhancement slots.
--This is a semi destructive hook, im overriding the enhancement (TYPE) to add the new slots, else create the normal tabs..
local OldCreateTabs = CreateTabs
function CreateTabs(type)

    local defaultTabOrder = {}
    local desiredTabs = 0
    if type == 'enhancement' then
        local selection = sortedOptions.selection
        local enhancements = selection[1]:GetBlueprint().Enhancements 
        local enhCommon = import('/lua/enhancementcommon.lua')
        local enhancementPrefixes = __DMSI.__DMod_EnhancementPrefixes
        local newTabs = {}
        if enhancements.Slots then
           -- local tabIndex = 1
			
		  -- local tabIndex = table.getsize(enhancements.Slots)		   
           -- for slotName, slotInfo in enhancements.Slots do
		   
		   for slotName, tabIndex in __DMSI.__DMod_DefaultTabOrder do
                if not controls.tabs[tabIndex] then
                    controls.tabs[tabIndex] = CreateTab(controls.constructionGroup, nil, OnNestedTabCheck)
                end		
                controls.tabs[tabIndex].tooltipKey = enhancementTooltips[slotName]
                controls.tabs[tabIndex].OnRolloverEvent = function(self, event)
                    if event == 'enter' then
                        local existing = enhCommon.GetEnhancements(selection[1]:GetEntityId())
                        if existing[slotName] then
                            local enhancement = enhancements[existing[slotName]]
                            local icon = enhancements[existing[slotName]].Icon
                            local bpID = selection[1]:GetBlueprint().BlueprintId
                            local enhName = existing[slotName]
                            local texture = UIUtil.UIFile(GetEnhancementPrefix(bpID, enhancementPrefixes[slotName]..icon))
                            UnitViewDetail.ShowEnhancement(enhancement, bpID, icon, texture, sortedOptions.selection[1])
                        end
                    elseif event == 'exit' then
                        if existing[slotName] then
                            UnitViewDetail.Hide()
                        end
                    end
                end
                Tooltip.AddControlTooltip(controls.tabs[tabIndex], enhancementTooltips[slotName])
                controls.tabs[tabIndex].ID = slotName
                newTabs[tabIndex] = controls.tabs[tabIndex]
				
               -- tabIndex = tabIndex - 1
                
				sortedOptions[slotName] = {}
                for enhName, enhTable in enhancements do
                    if enhTable.Slot == slotName then
                        enhTable.ID = enhName
                        enhTable.UnitID = selection[1]:GetBlueprint().BlueprintId
                        table.insert(sortedOptions[slotName], enhTable)
                    end
                end
            end
            desiredTabs = table.getsize(enhancements.Slots)
        end
        defaultTabOrder = __DMSI.__DMod_DefaultTabOrder
		
		while table.getsize(controls.tabs) > desiredTabs do
			controls.tabs[table.getsize(controls.tabs)]:Destroy()
			controls.tabs[table.getsize(controls.tabs)] = nil
		end
		import(UIUtil.GetLayoutFilename('construction')).LayoutTabs(controls)
		local defaultTab = false
		local numActive = 0
		for _, tab in controls.tabs do
			if sortedOptions[tab.ID] and table.getn(sortedOptions[tab.ID]) > 0 then
				tab:Enable()
				numActive = numActive + 1
				if defaultTabOrder[tab.ID] then
					if not defaultTab or defaultTabOrder[tab.ID] < defaultTabOrder[defaultTab.ID] then
						defaultTab = tab
					end
				end
			else
				tab:Disable()
			end
		end
		if previousTabSet != type or previousTabSize != numActive then
			if defaultTab then
				defaultTab:SetCheck(true)
			end
			previousTabSet = type
			previousTabSize = numActive
		elseif activeTab then
			activeTab:SetCheck(true)
		end
	else
		OldCreateTabs(type)
    end
end
------------------------------------------------------------------------------------------------------------------------

end