#*****************************************************************************
#* File: lua/modules/ui/game/orders.lua
#* Author: Chris Blackwell
#* Summary: Unit orders UI
#*
#* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#*****************************************************************************


local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Grid = import('/lua/maui/grid.lua').Grid
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua')
local Prefs = import('/lua/user/prefs.lua')
local Keymapping = import('/lua/keymap/defaultKeyMap.lua').defaultKeyMap
local CM = import('/lua/ui/game/commandmode.lua')
local UIMain = import('/lua/ui/uimain.lua')

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 
local __CustomToggles = __DMSI.Custom_Toggles()

local InitCapStateDone = false
local AddExtraSlots = false

local function OrderLayout_Params2(key)
	local Params = UIUtil.OrderLayout_Params(key)
	
	if Params then 
		return Params
	else
		return false
	end
end

local function ExraToggleInit(control, unitList)
	local result = nil
    local mixed = false
	
	if control._data.pulse then 
		result = false
	else
		for i, v in unitList do
			local unitdata = UnitData[v:GetEntityId()]
			local thisUnitStatus = unitdata[control._data.toggle_name .. '_state']
		
			if result == nil then
				result = thisUnitStatus
			else
				if thisUnitStatus != result then
					mixed = true
					result = true
					break
				end
			end
		end
	end
	
    if mixed then
        control._mixedIcon = Bitmap(control, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
        LayoutHelpers.AtRightTopIn(control._mixedIcon, control, -2, 2)
    end
    control:SetCheck(result)
end

local function ExtraToggleButtonOrderBehavior(self, modifiers)
	if self._mixedIcon then
        self._mixedIcon:Destroy()
        self._mixedIcon = nil
    end
	
	if self._data.toggle_name then 
		
		local state
		local checkstate = self:IsChecked()
		
		if self._data.pulse then
			state = false
			checkstate = true
		else
		
			if table.getsize(currentSelection) > 1 then 
				if checkstate then
					state = true
				else 
					state = false
				end
			else
				local Data = UnitData[currentSelection[1]:GetEntityId()]
				if Data[self._data.toggle_name] then 
					if Data[self._data.toggle_name ..'_state'] then 
						state = false
					else
						state = true
					end
				end
			end
		end
		
		if state != checkstate then 
			local Params = {}
			Params.Units = {}
			Params.ToggleState = state
			Params.BitName = self._data.toggle_name
	
			for i, u in currentSelection do
				local Data = UnitData[u:GetEntityId()]
				if Data[self._data.toggle_name] then 
					table.insert(Params.Units, u:GetEntityId())
				end
			end
	
			local TTB = { Func = 'ToggleTheBit', Args = { Params = Params } }
			SimCallback(TTB, true)
		
			if controls.mouseoverDisplay.text then
				controls.mouseoverDisplay.text:SetText(self._curHelpText)
			end
		
			if not self._data.pulse then 
				Checkbox.OnClick(self)
			end
		end
	end
end

local function ExtraAbilityButtonBehavior(self, modifiers)
    if self:IsChecked() then
        CM.EndCommandMode(true)
    else
        local modeData = {
            name="RULEUCC_Script", 
            AbilityName=self._script,
            TaskName=self._script,
        }
        CM.StartCommandMode("order", modeData)
    end
end

function Merge_Toggle_Tables()
	for CapName, Params in __CustomToggles do
		__CustomToggles[CapName].behavior = ExtraToggleButtonOrderBehavior
		__CustomToggles[CapName].initialStateFunc = ExraToggleInit 
	end
	
	defaultOrdersTable = table.merged(defaultOrdersTable, __CustomToggles)
end

numSlots = UIUtil.OrderLayout_Params('numSlots') or 12
firstAltSlot = UIUtil.OrderLayout_Params('firstAltSlot') or 7
vertRows = UIUtil.OrderLayout_Params('vertRows') or 6
horzRows = UIUtil.OrderLayout_Params('horzRows') or 2

vertCols = numSlots/vertRows
horzCols = numSlots/horzRows

do



--overriden function because i cant figure out how to hook it correctly
function CreateOrderGlow(parent)
    controls.orderGlow = Bitmap(parent, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
    LayoutHelpers.AtCenterIn(controls.orderGlow, parent)
    controls.orderGlow:SetAlpha(0.0)
    controls.orderGlow:DisableHitTest()
    controls.orderGlow:SetNeedsFrameUpdate(true)
    local alpha = 0.0
    local incriment = true
    controls.orderGlow.OnFrame = function(self, deltaTime)
        if incriment then
		--1.2
            alpha = alpha + (deltaTime * 0.20)
        else
            alpha = alpha - (deltaTime * 0.20)
        end
        if alpha < 0 then
            alpha =  0.0
            incriment = true
        end
		--.4
        if alpha > .0300 then
            alpha = .0300
            incriment = false
        end
        controls.orderGlow:SetAlpha(alpha)
    end     
end

local oldCreateOrderButtonGrid = CreateOrderButtonGrid
function CreateOrderButtonGrid()
	local params = UIUtil.OrderLayout_Params('iconsize')
	
	if params then
		controls.orderButtonGrid = Grid(controls.bg, params.Width, params.Height)
		controls.orderButtonGrid:SetName("Orders Grid")
		controls.orderButtonGrid:DeleteAll()
	else
		oldCreateOrderButtonGrid()
	end		
end

local oldCreateFirestatePopup = CreateFirestatePopup
function CreateFirestatePopup(parent, selected)
	local bg = oldCreateFirestatePopup(parent, selected)
	local params = UIUtil.OrderLayout_Params('iconsize')

	if params then
		for _, btn in bg.buttons do
			btn.Width:Set(params.Width)
			btn.Height:Set(params.Height)
		end
	end
	
	return bg

end

local oldAddOrder = AddOrder
function AddOrder(orderInfo, slot, batchMode)
	checkbox = oldAddOrder(orderInfo, slot, batchMode)

	local params = UIUtil.OrderLayout_Params('iconsize')
	
	if params then
		checkbox.Width:Set(params.Width)
		checkbox.Height:Set(params.Height)
	end
	
	return checkbox

end

local oldCreateControls = CreateControls
function CreateControls()
	if controls.orderButtonGrid then
        CreateOrderButtonGrid()
    end
	
	oldCreateControls()
end

--[[
-- called by gamemain when new orders are available, 
local OldSetAvailableOrders = SetAvailableOrders
function SetAvailableOrders(availableOrders, availableToggles, newSelection)
    currentSelection = newSelection
		
	for index, unit in currentSelection do
		local tempBP = UnitData[unit:GetEntityId()]
			
		if tempBP then
			for ToggleName, Param in tempBP do	
				if defaultOrdersTable[ToggleName] and Param then 
					table.insert(availableToggles, ToggleName)
				end	
			end
		end
	end	
	
	-- :( override...
	SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)
			
	--OldSetAvailableOrders(availableOrders, availableToggles, currentSelection)
end
--]]


-- called by gamemain when new orders are available, 
local OldSetAvailableOrders = SetAvailableOrders
function SetAvailableOrders(availableOrders, availableToggles, newSelection)
    currentSelection = newSelection
		
	for index, unit in currentSelection do
		local tempBP = UnitData[unit:GetEntityId()]
			
		if tempBP then
			for ToggleName, Param in tempBP do	
				if defaultOrdersTable[ToggleName] and Param then 
					table.insert(availableToggles, ToggleName)
				end	
			end
		end
	end	
		
	-- :( override...
	SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)
			
	--OldSetAvailableOrders(availableOrders, availableToggles, currentSelection)
end


--had to override this function
function SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)
	
	# save new selection
	currentSelection = newSelection
	controls.AddExtraSlots = false
	
	local TotalSlotsNeeded = 0

	if currentSelection and categories.ABILITYBUTTON and EntityCategoryFilterDown(categories.ABILITYBUTTON, currentSelection) then
        for index, unit in currentSelection do
            local tempBP = UnitData[unit:GetEntityId()]
            if tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
					-- needed to add this table.find into this loop, so that all the orders slots are NOT filled with custom abilities
                    if ability.Active != false and not table.find(availableOrders, abilityIndex) then
                        TotalSlotsNeeded = TotalSlotsNeeded + 1
                    end
                end
            end
        end
    end

    # clear existing orders
    orderCheckboxMap = {}
    controls.orderButtonGrid:DestroyAllItems(true)
	
    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)
    
    -- look in blueprints for any icon or tooltip overrides
    -- note that if multiple overrides are found for the same order, then the default is used
    -- the syntax of the override in the blueprint is as follows (the overrides use same naming as in the default table above):
    -- In General table
    -- OrderOverrides = {
    --     RULEUTC_IntelToggle = {
    --         bitmapId = 'custom',
    --         helpText = 'toggle_custom',
    --     },
    --  },
    -- 
    local orderDiffs
    
    for index, unit in newSelection do
        local overrideTable = unit:GetBlueprint().General.OrderOverrides
        if overrideTable then
            for orderKey, override in overrideTable do
                if orderDiffs == nil then
                    orderDiffs = {}
                end
                if orderDiffs[orderKey] != nil and (orderDiffs[orderKey].bitmapId != override.bitmapId or orderDiffs[orderKey].helpText != override.helpText) then
                    -- found order diff already, so mark it false so it gets ignored when applying to table
                    orderDiffs[orderKey] = false
                else
                    orderDiffs[orderKey] = override
                end
            end
        end
    end
    
    -- apply overrides
    if orderDiffs != nil then
        for orderKey, override in orderDiffs do
            if override and override != false then
                if override.bitmapId then
                    standardOrdersTable[orderKey].bitmapId = override.bitmapId
                end
                if override.helpText then
                    standardOrdersTable[orderKey].helpText = override.helpText
                end
            end
        end
    end
    
    CreateCommonOrders(availableOrders)
    
	--Lets see how many orders we have, and create our orders panel accordingly. 12 or 18
	local numValidOrders = 0
	for i, v in availableOrders do
		if standardOrdersTable[v] then
			numValidOrders = numValidOrders + 1
		end
	end
	
	for i, v in availableToggles do
		if standardOrdersTable[v] then
			numValidOrders = numValidOrders + 1
		end
	end
	
	local assitingUnitList = {}
    local podUnits = {}
    if table.getn(currentSelection) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, currentSelection) or EntityCategoryFilterDown(categories.POD, currentSelection)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, currentSelection)
        local Pods = EntityCategoryFilterDown(categories.POD, currentSelection)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
             TotalSlotsNeeded = TotalSlotsNeeded + 1
        end
        if assistingUnits[2] then
             TotalSlotsNeeded = TotalSlotsNeeded + 1
        end
    end
	
	numValidOrders = numValidOrders + TotalSlotsNeeded
			
	if numValidOrders > 12 then 
		--UpdateNumSlots()
		controls.AddExtraSlots = true
	end
		
		
	--LOG('numvalidorders ' .. repr(numValidOrders))
    
	--Had to override this function, because of this line.. default is 12 slots.
	if numValidOrders <= numSlots then
		CreateAltOrders(availableOrders, availableToggles, currentSelection)
	end
    
	controls.orderButtonGrid:EndBatch()
	if table.getn(currentSelection) == 0 and controls.bg.Mini then
		controls.bg.Mini(true)
	elseif controls.bg.Mini then
		controls.bg.Mini(false)
	end
end


--overridden function.. 	
function CreateAltOrders(availableOrders, availableToggles, units)

    --Look for units in the selection that have special ability buttons
    --If any are found, add the ability information to the standard order table
    if units and categories.ABILITYBUTTON and EntityCategoryFilterDown(categories.ABILITYBUTTON, units) then
        for index, unit in units do
            local tempBP = UnitData[unit:GetEntityId()]
            if tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
					-- needed to add this table.find into this loop, so that all the orders slots are NOT filled with custom abilities
                    if ability.Active != false and not table.find(availableOrders, abilityIndex) then
                        table.insert(availableOrders, abilityIndex)
                        standardOrdersTable[abilityIndex] = table.merged(ability, import('/lua/abilitydefinition.lua').abilities[abilityIndex])
                        standardOrdersTable[abilityIndex].behavior = AbilityButtonBehavior
                    end
                end
            end
        end
    end
    local assitingUnitList = {}
    local podUnits = {}
    if table.getn(units) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units) or EntityCategoryFilterDown(categories.POD, units)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units)
        local Pods = EntityCategoryFilterDown(categories.POD, units)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
            table.insert(availableOrders, 'DroneL')
            assitingUnitList['DroneL'] = assistingUnits[1]
        end
        if assistingUnits[2] then
            table.insert(availableOrders, 'DroneR')
            assitingUnitList['DroneR'] = assistingUnits[2]
        end
    end
    
    # determine what slots to put alt orders
    # we first want a table of slots we want to fill, and what orders want to fill them
    local desiredSlot = {}
    local usedSpecials = {}
    for index, availOrder in availableOrders do
        if standardOrdersTable[availOrder] then 
            local preferredSlot = standardOrdersTable[availOrder].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availOrder)
        else
            if specialOrdersTable[availOrder] != nil then
                specialOrdersTable[availOrder].behavior()
                usedSpecials[availOrder] = true
            end
        end
    end

    for index, availToggle in availableToggles do
        if standardOrdersTable[availToggle] then 
            local preferredSlot = standardOrdersTable[availToggle].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availToggle)
        else
            if specialOrdersTable[availToggle] != nil then
                specialOrdersTable[availToggle].behavior()
                usedSpecials[availToggle] = true
            end
        end
    end

    for i, specialOrder in specialOrdersTable do
        if not usedSpecials[i] and specialOrder.notAvailableBehavior then
            specialOrder.notAvailableBehavior()
        end
    end

    # now go through that table and determine what doesn't fit and look for slots that are empty
    # since this is only alt orders, just deal with slots 7-12
    local orderInSlot = {}
    
    # go through first time and add all the first entries to their preferred slot
    for slot = firstAltSlot,numSlots do
        if desiredSlot[slot] then
            orderInSlot[slot] = desiredSlot[slot][1]
        end
    end

    # now put any additional entries wherever they will fit
    for slot = firstAltSlot,numSlots do
        if desiredSlot[slot] and table.getn(desiredSlot[slot]) > 1 then
            for index, item in desiredSlot[slot] do
                if index > 1 then
                    local foundFreeSlot = false
                    for newSlot = firstAltSlot, numSlots do
                        if not orderInSlot[newSlot] then
                            orderInSlot[newSlot] = item
                            foundFreeSlot = true
                            break
                        end
                    end
                    if not foundFreeSlot then
                        WARN("No free slot for order: " .. item)
                        # could break here, but don't, then you'll know how many extra orders you have
                    end
                end
            end
        end
    end

    # now map it the other direction so it's order to slot
    local slotForOrder = {}
    for slot, order in orderInSlot do
        slotForOrder[order] = slot
    end
	
   -- LOG('available orders ' .. repr(availableOrders) .. ' Order in slot ' .. repr(orderInSlot) .. ' order for slot ' .. repr(slotForOrder))
    
    # create the alt order buttons
    for index, availOrder in availableOrders do
        if not standardOrdersTable[availOrder] then continue end   # skip any orders we don't have in our table
        if not commonOrders[availOrder] then
            local orderInfo = standardOrdersTable[availOrder] or AbilityInformation[availOrder]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availOrder], true)

            orderCheckbox._order = availOrder
            
            if standardOrdersTable[availOrder].script then
                orderCheckbox._script = standardOrdersTable[availOrder].script
            end
            
            if assitingUnitList[availOrder] then
                orderCheckbox._unit = assitingUnitList[availOrder]
            end
            
            if podUnits[availOrder] then
                orderCheckbox._pod = podUnits[availOrder]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availOrder] = orderCheckbox
        end
    end

    for index, availToggle in availableToggles do
        if not standardOrdersTable[availToggle] then continue end   # skip any orders we don't have in our table
        if not commonOrders[availToggle] then
            local orderInfo = standardOrdersTable[availToggle] or AbilityInformation[availToggle]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availToggle], true)

            orderCheckbox._order = availToggle
            
            if standardOrdersTable[availToggle].script then
                orderCheckbox._script = standardOrdersTable[availToggle].script
            end
            
            if assitingUnitList[availToggle] then
                orderCheckbox._unit = assitingUnitList[availToggle]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availToggle] = orderCheckbox
        end
    end
end

function UpdateNumSlots()
	if not controls.AddExtraSlots then 
		numSlots = 12
		firstAltSlot = 7
		vertRows = 6
		horzRows = 2
		vertCols = numSlots/vertRows
		horzCols = numSlots/horzRows
	else
		numSlots = UIUtil.OrderLayout_Params('numSlots') or 12
		firstAltSlot = UIUtil.OrderLayout_Params('firstAltSlot') or 7
		vertRows = UIUtil.OrderLayout_Params('vertRows') or 6
		horzRows = UIUtil.OrderLayout_Params('horzRows') or 2
		vertCols = numSlots/vertRows
		horzCols = numSlots/horzRows
	end
end


end