--* File: lua/modules/ui/game/unitview.lua
--* Author: Chris Blackwell
--* Summary: Rollover unit view control

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local EnhancementCommon = import('/lua/enhancementcommon.lua')
local Factions = import('/lua/factions.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local GetEnhancementPrefix = import("/lua/ui/game/construction.lua").GetEnhancementPrefix
local Group = import('/lua/maui/group.lua').Group
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local UIUtil = import('/lua/ui/uiutil.lua')
local veterancyDefaults = import('/lua/game.lua').VeteranDefault

local Prefs = import('/lua/user/prefs.lua')
local options = Prefs.GetFromCurrentProfile('options')

local LOUDFLOOR = math.floor

local rolloverInfo = false
local consTrue = false
local focusBool = false

controls = {}
local unitViewLayout = nil -- Holds the current layout, updated by SetLayout().

function Contract()
    controls.bg:SetNeedsFrameUpdate(false)
    controls.bg:Hide()
end

function Expand()
    controls.bg:SetNeedsFrameUpdate(true)
    controls.bg:Show()
end

--INFO:   blueprintId="uel0001",
--INFO:   energyConsumed=0,
--INFO:   energyProduced=10,
--INFO:   energyRequested=0,
--INFO:   entityId="0",
--INFO:   fuelRatio=-1,
--INFO:   health=12000,
--INFO:   kills=0,
--INFO:   massConsumed=0,
--INFO:   massProduced=1,
--INFO:   massRequested=0,
--INFO:   maxHealth=12000,
--INFO:   nukeSiloBuildCount=0,
--INFO:   nukeSiloMaxStorageCount=1,
--INFO:   nukeSiloStorageCount=0,
--INFO:   regenrate=0       -- added by LOUD 
--INFO:   shieldRatio=0,
--INFO:   tacticalSiloBuildCount=0,
--INFO:   tacticalSiloMaxStorageCount=1,
--INFO:   tacticalSiloStorageCount=0,
--INFO:   teamColor="ffe80a0a",
--INFO:   workProgress=0

local queueTextures = {
    Move = {texture = UIUtil.UIFile('/game/orders/move_btn_up.dds'), text = '<LOC order_0000>Moving'},
    FormMove = {texture = UIUtil.UIFile('/game/orders/move_btn_up.dds'), text = '<LOC order_0000>Moving'},
    BuildMobile = {texture = UIUtil.UIFile('/game/orders/move_btn_up.dds'), text = '<LOC order_0001>Building'},
    Attack = {texture = UIUtil.UIFile('/game/orders/attack_btn_up.dds'), text = '<LOC order_0002>Attacking'},
    AggressiveMove = {texture = UIUtil.UIFile('/game/orders/attack_btn_up.dds'), text = '<LOC order_0002>Attacking'},
    Upgrade = {texture = UIUtil.UIFile('/game/orders/repair_btn_up.dds'), text = '<LOC order_0003>Upgrading'},
    Guard = {texture = UIUtil.UIFile('/game/orders/guard_btn_up.dds'), text = '<LOC order_0011>'},
    Repair = {texture = UIUtil.UIFile('/game/orders/repair_btn_up.dds'), text = '<LOC order_0005>Repairing'},
    Capture = {texture = UIUtil.UIFile('/game/orders/convert_btn_up.dds'), text = '<LOC order_0007>Capturing'},
    Ferry = {texture = UIUtil.UIFile('/game/orders/ferry_btn_up.dds'), text = '<LOC order_0016>Ferry'},
    Patrol = {texture = UIUtil.UIFile('/game/orders/patrol_btn_up.dds'), text = '<LOC order_0017>Patrol'},
    TransportReverseLoadUnits = {texture = UIUtil.UIFile('/game/orders/load_btn_up.dds'), text = '<LOC order_0008>Loading'},
    TransportUnloadUnits = {texture = UIUtil.UIFile('/game/orders/unload_btn_up.dds'), text = '<LOC order_0009>Unloading'},
    TransportLoadUnits = {texture = UIUtil.UIFile('/game/orders/load_btn_up.dds'), text = '<LOC order_0010>Loading'},
    AssistCommander = {texture = UIUtil.UIFile('/game/orders/unload02_btn_up.dds'), text = '<LOC order_0011>Assisting'},
    Sacrifice = {texture = UIUtil.UIFile('/game/orders/sacrifice_btn_up.dds'), text = '<LOC order_0012>Sacrificing'},
    Nuke = {texture = UIUtil.UIFile('/game/orders/nuke_btn_up.dds'), text = '<LOC order_0013>Nuking'},
    Tactical = {texture = UIUtil.UIFile('/game/orders/tactical_btn_up.dds'), text = '<LOC order_0014>Launching'},
    OverCharge = {texture = UIUtil.UIFile('/game/orders/overcharge_btn_up.dds'), text = '<LOC order_0015>Overcharging'},
}

local function FormatTime(seconds)
    return string.format("%02d:%02d", math.floor(seconds/60), math.floor(math.mod(seconds, 60)))
end

local statFuncs = {
	-- combined stats showing mass trend for own units or army icon + nickname for others' units
	function(info)
	    local massUsed = math.max(info.massRequested, info.massConsumed)
	    if info.massProduced > 0 or massUsed > 0 then
	        local netMass = info.massProduced - massUsed
	        local absNetMass = math.abs(netMass)
	        local str
	        -- Thanks to an engine patch, `GetRolloverInfo` returns floats for economy values:
	        -- - https://github.com/FAForever/FA-Binary-Patches/pull/75
	        -- This allows us to show adjacency-affected values better.
	        if absNetMass < 5 then
	            str = string.format('%+.3g', netMass)
	        elseif absNetMass < 10 then
	            str = string.format('%+.2g', netMass)
	        elseif absNetMass < 100 then
	            str = string.format('%+.3g', netMass)
	        else
	            str = string.format('%+d', math.round(netMass))
	        end

	        return str
	            , UIUtil.UIFile('/game/unit_view_icons/mass.dds')
	            , '00000000'

	    elseif info.armyIndex + 1 ~= GetFocusArmy() and info.kills == 0 and info.shieldRatio <= 0 then
	        local armyData = GetArmiesTable().armiesTable[info.armyIndex + 1]
	        local icon = Factions.Factions[armyData.faction + 1].Icon
	        if armyData.showScore and icon then
	            return string.sub(armyData.nickname, 1, 12), UIUtil.UIFile(icon), armyData.color
	        else
	            return false
	        end
	    else
	        return false
	    end
	end,
	-- energy trend
	function(info)
	    local energyUsed = math.max(info.energyRequested, info.energyConsumed)
	    if info.energyProduced > 0 or energyUsed > 0 then
	        local netEnergy = info.energyProduced - energyUsed
	        local absNetEnergy = math.abs(netEnergy)
	        -- Thanks to an engine patch, `GetRolloverInfo` returns floats for economy values:
	        -- - https://github.com/FAForever/FA-Binary-Patches/pull/75
	        -- This allows us to show adjacency-affected values better.
	        if absNetEnergy < 10 then
	            return string.format('%+.2g', netEnergy)
	        elseif absNetEnergy < 100 then
	            return string.format('%+.3g', netEnergy)
	        else
	            return string.format('%+d', math.round(netEnergy))
	        end
	    else
	        return false
	    end
	end,
	-- vet xp
	function(info)
		-- No idea why this works in FAF, but here it draws some text over the already shown veteran stats.
		-- As there is hard-coded indexing elsewhere, this element must not be removed, but simply marked as deactivated
        return false
--[[
		if info.kills then
            local nextLevel = 0
            local veterancyLevels = __blueprints[info.blueprintId].Veteran or veterancyDefaults
            for index = 1, 5 do
                local i = index
				local vet = veterancyLevels[string.format('Level%d', i)]

				if info.kills < vet then
				    return string.format('%d / %d', info.kills, vet)
				end
			end

			return false
        else
            return false
        end
--]]
	end,
	-- kill count
	function(info)
	    if info.kills > 0 then
	        return string.format('%d', info.kills)
	    else
	        return false
	    end
	end,
	-- tactical/strategic missile count
	function(info)
	    if info.tacticalSiloMaxStorageCount > 0 or info.nukeSiloMaxStorageCount > 0 then
	        if info.userUnit:IsInCategory('VERIFYMISSILEUI') then
	            local curEnh = EnhancementCommon.GetEnhancements(info.userUnit:GetEntityId())
	            if curEnh then
	                if curEnh.Back == 'TacticalMissile' or curEnh.Back == 'Missile' then
	                    return string.format('%d / %d', info.tacticalSiloStorageCount, info.tacticalSiloMaxStorageCount) , 'tactical'
	                elseif curEnh.Back == 'TacticalNukeMissile' then
	                    return string.format('%d / %d', info.nukeSiloStorageCount, info.nukeSiloMaxStorageCount), 'strategic'
	                else
	                    return false
	                end
	            else
	                return false
	            end
	        end
	        if info.nukeSiloMaxStorageCount > 0 then
	            return string.format('%d / %d', info.nukeSiloStorageCount, info.nukeSiloMaxStorageCount), 'strategic'
	        else
	            return string.format('%d / %d', info.tacticalSiloStorageCount, info.tacticalSiloMaxStorageCount), 'tactical'
	        end
	    elseif info.userUnit and not table.empty(GetAttachedUnitsList({ info.userUnit })) then
	        return string.format('%d', table.getn(GetAttachedUnitsList({ info.userUnit }))), 'attached'
	    else
	        return false
	    end
	end,
	-- shield % HP
	function(info, bp)
	    if info.shieldRatio > 0 then
	        return string.format('%d%%', math.floor(info.shieldRatio * 100))
	    else
	        return false
	    end
	end,
	-- fuel remaining time
	function(info, bp)
	    if info.fuelRatio > -1 then
	        return FormatTime(bp.Physics.FuelUseTime * info.fuelRatio)
	    else
	        return false
	    end
	end,
	-- buildrate
	function(info, bp)
	    if options.gui_detailed_unitview == 0 then
	        return false
	    end
	    if info.userUnit ~= nil and info.userUnit:GetBuildRate() > 1 then
	        return string.format("%.6g", info.userUnit:GetBuildRate())
	    end
	    return false
	end,
}

-- this is from BOGIS (all credit to Black Ops authors)
function UpdateWindow(info)
    if info.blueprintId == 'unknown' then
        controls.name:SetText(LOC('<LOC rollover_0000>Unknown Unit'))
        controls.icon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
        controls.stratIcon:SetTexture('/textures/ui/common/game/strategicicons/icon_structure_generic_selected.dds')
        for index = 1, table.getn(controls.statGroups) do
            local i = index
            controls.statGroups[i].icon:Hide()
            if controls.statGroups[i].color then
                controls.statGroups[i].color:SetSolidColor('00000000')
            end
            if controls.vetIcons[i] then
                controls.vetIcons[i]:Hide()
            end
        end
        controls.healthBar:Hide()
        controls.shieldBar:Hide()
        controls.fuelBar:Hide()
        controls.vetBar:Hide()
        controls.actionIcon:Hide()
        controls.actionText:Hide()
        controls.abilities:Hide()
    else
        local bp = __blueprints[info.blueprintId]
        local path = GameCommon.GetUnitIconPath(bp)
        controls.icon:SetTexture(path)
        if DiskGetFileInfo('/textures/ui/common/game/strategicicons/'..bp.StrategicIconName..'_selected.dds') then
            controls.stratIcon:SetTexture('/textures/ui/common/game/strategicicons/'..bp.StrategicIconName..'_selected.dds')
        else
            controls.stratIcon:SetSolidColor('00000000')
        end
        local techLevel = false
        local levels = {TECH1 = 1,TECH2 = 2,TECH3 = 3}
        for i, v in bp.Categories do
            if levels[v] then
                techLevel = levels[v]
                break
            end
        end
        local description = LOC(bp.Description)
        if techLevel then
            description = LOCF("Tech %d %s", techLevel, bp.Description)
        end
        LayoutHelpers.AtTopIn(controls.name, controls.bg, 10)
        controls.name:SetFont(UIUtil.bodyFont, 14)
        local name = ''
        if info.customName then
            name = LOC(info.customName)
        elseif bp.General.UnitName then
            name = LOC(bp.General.UnitName)
        end
        if name ~= '' then
            name = name .. ': '
        end
        controls.name:SetText(name .. description)
        local scale = controls.name.Width() / controls.name.TextAdvance()
        if scale < 1 then
            LayoutHelpers.AtTopIn(controls.name, controls.bg, 10 / scale)
            controls.name:SetFont(UIUtil.bodyFont, 14 * scale)
        end
        for index = 1, table.getn(statFuncs) do
            local i = index
			
            if statFuncs[i](info, bp) then
			
                if i == 1 then
				
                    local value, iconType, color = statFuncs[i](info, bp)
                    controls.statGroups[i].color:SetSolidColor(color)
                    controls.statGroups[i].icon:SetTexture(iconType)
                    controls.statGroups[i].value:SetText(value)
                elseif i == 3 then
                    local value, iconType, color = statFuncs[i](info, bp)
					controls.statGroups[i].value:SetText(value)
                    controls.statGroups[i].icon:SetTexture(UIUtil.UIFile(Factions.Factions[
                        Factions.FactionIndexMap[string.lower(bp.General.FactionName)] ].VeteranIcon))
                elseif i == 5 then
                    local text, iconType = statFuncs[i](info, bp)
                    controls.statGroups[i].value:SetText(text)
					
                    if iconType == 'strategic' then
                        controls.statGroups[i].icon:SetTexture(UIUtil.UIFile('/game/unit_view_icons/missiles.dds'))
                    elseif iconType == 'attached' then
                        controls.statGroups[i].icon:SetTexture(UIUtil.UIFile('/game/unit_view_icons/attached.dds'))
                    else
                        controls.statGroups[i].icon:SetTexture(UIUtil.UIFile('/game/unit_view_icons/tactical.dds'))
                    end
					
                else
                    controls.statGroups[i].value:SetText(statFuncs[i](info, bp))
                end
				
                controls.statGroups[i].icon:Show()
				
            else
			
                controls.statGroups[i].icon:Hide()
				
                if controls.statGroups[i].color then
                    controls.statGroups[i].color:SetSolidColor('00000000')
                end
				
            end
			
        end
        
        if info.shieldRatio > 0 then
            controls.shieldBar:Show()
            controls.shieldBar:SetValue(info.shieldRatio)
        else
            controls.shieldBar:Hide()
        end
        
        if info.fuelRatio > 0 then
            controls.fuelBar:Show()
            controls.fuelBar:SetValue(info.fuelRatio)
		else
		    controls.fuelBar:Hide()
        end

        if info.shieldRatio > 0 and info.fuelRatio > 0 then
            controls.store = 1
        else
            controls.store = 0
        end
		
        if info.health then
            controls.healthBar:Show()
            controls.healthBar:SetValue(info.health/info.maxHealth)
            if info.health/info.maxHealth > .75 then
                controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_green.dds'))
            elseif info.health/info.maxHealth > .25 then
                controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_yellow.dds'))
            else
                controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_red.dds'))
            end

            controls.health:SetText(string.format("%d / %d", info.health, info.maxHealth ))
        else
            controls.healthBar:Hide()
        end

		-- always hide veterancy stars initially
		for i = 1, 5 do
		    controls.vetIcons[i]:Hide()
		end

		-- Control the veterancy stars
		if bp.Veteran and info.kills then
	        -- show stars
			local experience = info.kills
			local lowerThreshold = 0
			local upperThreshold
	        for i = 1, 5 do
				local threshold = bp.Veteran[string.format('Level%d', i)]
				if experience >= threshold then
	                controls.vetIcons[i]:Show()
	                controls.vetIcons[i]:SetTexture(UIUtil.UIFile(Factions.Factions[Factions.FactionIndexMap[string.lower(bp.General.FactionName)]].VeteranIcon))
					lowerThreshold = threshold
				elseif not upperThreshold then
					upperThreshold = threshold
	            end
	        end
			
	        -- show veterancy to gain
			local progress, title
	        if upperThreshold then
	            title = 'Veterancy'
	            progress = (experience - lowerThreshold) / (upperThreshold - lowerThreshold)
	            controls.nextVet:SetText(experience .. '/' .. string.format('%d', upperThreshold))
	
	        -- show total experience
	        else
	            title = 'Killed'
	            progress = 1
	            controls.nextVet:SetText(experience)
	        end
			
	        -- always show it, regardless
	        controls.vetBar:Show()
	        controls.vetBar:SetValue(progress)
	        controls.vetTitle:SetText(title)
		else
			controls.vetBar:Hide()
		end
		
		local unitQueue = false
		if info.userUnit then
		    unitQueue = info.userUnit:GetCommandQueue()
		end

		if info.focus then
		    local path, valid = GameCommon.GetUnitIconPath(__blueprints[info.focus.blueprintId])
            if valid then
                controls.actionIcon:SetTexture(path)
            else
                -- Sets placeholder because no other icon was found
                controls.actionIcon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
            end

            if info.focus.health and info.focus.maxHealth then
			
                controls.actionText:SetFont(UIUtil.bodyFont, 14)
                controls.actionText:SetText(string.format('%d%%', (info.focus.health / info.focus.maxHealth) * 100))
				
            elseif queueTextures[unitQueue[1].type] then
			
                controls.actionText:SetFont(UIUtil.bodyFont, 10)
                controls.actionText:SetText(LOC(queueTextures[unitQueue[1].type].text))
				
            else
			
                controls.actionText:SetText('')
				
            end
			
            controls.actionIcon:Show()
            controls.actionText:Show()
			
        elseif info.focusUpgrade then
		
            controls.actionIcon:SetTexture(queueTextures.Upgrade.texture)
            controls.actionText:SetFont(UIUtil.bodyFont, 14)
            controls.actionText:SetText(string.format('%d%%', info.workProgress * 100))
            controls.actionIcon:Show()
            controls.actionText:Show()
			
        elseif info.userUnit and queueTextures[unitQueue[1].type] and not info.userUnit:IsInCategory('FACTORY') then
		
            controls.actionText:SetFont(UIUtil.bodyFont, 10)
            controls.actionText:SetText(LOC(queueTextures[unitQueue[1].type].text))
            controls.actionIcon:SetTexture(queueTextures[unitQueue[1].type].texture)
            controls.actionIcon:Show()
            controls.actionText:Show()
			
        elseif info.userUnit and info.userUnit:IsIdle() then
		
            controls.actionIcon:SetTexture(UIUtil.UIFile('/game/unit_view_icons/idle.dds'))
            controls.actionText:SetFont(UIUtil.bodyFont, 10)
            controls.actionText:SetText(LOC('<LOC _Idle>'))
            controls.actionIcon:Show()
            controls.actionText:Show()
			
        else
		
            controls.actionIcon:Hide()
            controls.actionText:Hide()
			
        end
        
        if Prefs.GetOption('uvd_format') == 'full' and bp.Display.Abilities then
		
            local i = 1
            local maxWidth = 0
            local index = table.getn(bp.Display.Abilities)
			
            while bp.Display.Abilities[index] do
			
                if not controls.abilityText[i] then
				
                    controls.abilityText[i] = UIUtil.CreateText(controls.abilities, LOC(bp.Display.Abilities[index]), 12, UIUtil.bodyFont)
                    controls.abilityText[i]:DisableHitTest()
					
                    if i == 1 then
                        LayoutHelpers.AtLeftIn(controls.abilityText[i], controls.abilities)
                        LayoutHelpers.AtBottomIn(controls.abilityText[i], controls.abilities)
                    else
                        LayoutHelpers.Above(controls.abilityText[i], controls.abilityText[i-1])
                    end
					
                else
				
                    controls.abilityText[i]:SetText(LOC(bp.Display.Abilities[index]))
					
                end
				
                maxWidth = math.max(maxWidth, controls.abilityText[i].Width())
                index = index - 1
                i = i + 1
				
            end
			
            while controls.abilityText[i] do
			
                controls.abilityText[i]:Destroy()
                controls.abilityText[i] = nil
                i = i + 1
				
            end
			
            controls.abilities.Width:Set(maxWidth)
            if controls.abilityText[1] then
                controls.abilities.Height:Set(function() return controls.abilityText[1].Height() * table.getsize(controls.abilityText) end)
            end    
            if controls.abilities:IsHidden() then
                controls.abilities:Show()
            end
        elseif not controls.abilities:IsHidden() then
            controls.abilities:Hide()
        end
        
        -- code taken from below --
        
        -- first replaces fuel bar with progress bar when when upgrading
        controls.fuelBar:Hide()
        if info.workProgress > 0 then
            controls.fuelBar:Show()
            controls.fuelBar:SetValue(info.workProgress)
        end

        -- second adds additional info to the display
        -- such as Regen Rate due to enhancements or veterancy buffs
        -- shield max health and regen rate due to enhancements or other buffs
        
        controls.shieldText:Hide()

		-- works properly but i've yet to find a good spot to put that data in
--[[        
		    if info.userUnit != nil and info.userUnit:GetBlueprint().Economy.StorageMass > 0 and info.userUnit:GetBlueprint().Economy.StorageEnergy > 0 then
		       controls.StorageMass:SetText(string.format("%d",LOUDFLOOR(info.userUnit:GetBlueprint().Economy.StorageMass)))
		       controls.StorageEnergy:SetText(string.format("%d",LOUDFLOOR(info.userUnit:GetBlueprint().Economy.StorageEnergy)))
		       controls.StorageMass:Show()
		       controls.StorageEnergy:Show()
		    else
		       controls.StorageMass:Hide()
		       controls.StorageEnergy:Hide()
		    end
--]]
        -- show the unit health and regen
        if info.userUnit != nil then
    
            info.regenrate = info.userUnit:GetStat( 'REGEN' ).Value
            info.shieldHP = info.userUnit:GetStat('SHIELDHP').Value
            info.shieldRegen = info.userUnit:GetStat('SHIELDREGEN').Value
            if info.health and info.regenrate > 0 then
                controls.health:SetText(string.format("%d / %d +%d/s", info.health, info.maxHealth, LOUDFLOOR(info.regenrate) ))
            end
        end

        -- now do all the same for the Shield - showing health, max health and shield regen rate
        -- and display it all on the SHIELD bar
        if info.shieldRatio > 0 and info.shieldHP > 0 then
            controls.shieldText:Show()
            if info.shieldRegen then
                controls.shieldText:SetText(string.format("%d / %d +%d/s", LOUDFLOOR( info.shieldHP * info.shieldRatio), info.shieldHP , info.shieldRegen ))
            else
                controls.shieldText:SetText(string.format("%d / %d", LOUDFLOOR( info.shieldHP * info.shieldRatio), info.shieldHP))
            end
        end

        controls.SCUType:Hide()
        if info.userUnit.SCUType then
            controls.SCUType:SetTexture('/lua/gaz_ui/textures/scumanager/'..info.userUnit.SCUType..'_icon.dds')
            controls.SCUType:Show()
        end
    end
	UpdateEnhancementIcons(info)
end

function UpdateEnhancementIcons(info)
    local unit = info.userUnit
    local existingEnhancements
    if unit then
        existingEnhancements = EnhancementCommon.GetEnhancements(unit:GetEntityId())
    end

    for slot, enhancement in controls.enhancements do
        if unit == nil or
            (not unit:IsInCategory('COMMAND') and not unit:IsInCategory('SUBCOMMANDER')) or
            existingEnhancements == nil or existingEnhancements[slot] == nil then
            enhancement:Hide()
            continue
        end

        local bp = unit:GetBlueprint()
        local bpId = bp.BlueprintId
        local enhancementBp = bp.Enhancements[ existingEnhancements[slot] ]
        local texture = GetEnhancementPrefix(bpId, enhancementBp.Icon) .. '_btn_up.dds'

        enhancement:Show()
        enhancement:SetTexture(UIUtil.UIFile(texture, true))
        LayoutHelpers.SetDimensions(enhancement, 30, 30)
    end
end

function ShowROBox()
end

function SetLayout(layout)
    unitViewLayout = import(UIUtil.GetLayoutFilename('unitview'))
    unitViewLayout.SetLayout()
end

function SetupUnitViewLayout(mapGroup, orderControl)
    controls.parent = mapGroup
    controls.orderPanel = orderControl
    unitViewLayout = import(UIUtil.GetLayoutFilename('unitview')) -- SetLayout() will set this too but let's make sure CreateUI() does not use nil, even though it only sets up an OnFrame function.
    CreateUI()
    SetLayout(UIUtil.currentLayout)
end

function CreateUI()

    controls.bg = Bitmap(controls.parent)
    controls.bracket = Bitmap(controls.bg)
    controls.name = UIUtil.CreateText(controls.bg, '', 14, UIUtil.bodyFont)
    controls.icon = Bitmap(controls.bg)
    controls.stratIcon = Bitmap(controls.bg)
    controls.vetIcons = {}
    for i = 1, 5 do
        controls.vetIcons[i] = Bitmap(controls.bg)
    end
    controls.healthBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
    controls.shieldBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
    controls.fuelBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
    controls.health = UIUtil.CreateText(controls.healthBar, '', 14, UIUtil.bodyFont)
    controls.vetBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
    controls.nextVet = UIUtil.CreateText(controls.vetBar, '', 10, UIUtil.bodyFont)
    controls.vetTitle = UIUtil.CreateText(controls.vetBar, 'Veterancy', 10, UIUtil.bodyFont)

    controls.statGroups = {}
    for i = 1, table.getn(statFuncs) do
        controls.statGroups[i] = {}
        controls.statGroups[i].icon = Bitmap(controls.bg)
        controls.statGroups[i].value = UIUtil.CreateText(controls.statGroups[i].icon, '', 12, UIUtil.bodyFont)
        if i == 1 then
            controls.statGroups[i].color = Bitmap(controls.bg)
            LayoutHelpers.FillParent(controls.statGroups[i].color, controls.statGroups[i].icon)
            controls.statGroups[i].color.Depth:Set(function() return controls.statGroups[i].icon.Depth() - 1 end)
        end
    end
    controls.actionIcon = Bitmap(controls.bg)
    controls.actionText = UIUtil.CreateText(controls.bg, '', 14, UIUtil.bodyFont)
    
    controls.abilities = Group(controls.bg)
    controls.abilityText = {}
    controls.abilityBG = {}
    controls.abilityBG.TL = Bitmap(controls.abilities)
    controls.abilityBG.TR = Bitmap(controls.abilities)
    controls.abilityBG.TM = Bitmap(controls.abilities)
    controls.abilityBG.ML = Bitmap(controls.abilities)
    controls.abilityBG.MR = Bitmap(controls.abilities)
    controls.abilityBG.M = Bitmap(controls.abilities)
    controls.abilityBG.BL = Bitmap(controls.abilities)
    controls.abilityBG.BR = Bitmap(controls.abilities)
    controls.abilityBG.BM = Bitmap(controls.abilities)
    
    controls.bg:DisableHitTest(true)
    
    controls.bg:SetNeedsFrameUpdate(true)

    controls.bg.OnFrame = function(self, delta)
        local info = GetRolloverInfo()
        if not info and import("/lua/gaz_ui/modules/selectedinfo.lua").SelectedInfoOn then
            local selUnits = GetSelectedUnits()
            if selUnits and table.getn(selUnits) == 1 and import('/lua/ui/game/unitviewDetail.lua').View.Hiding then
                info = import("/lua/gaz_ui/modules/selectedinfo.lua").GetUnitRolloverInfo(selUnits[1])
            end 
        end
        
        if info then
            UpdateWindow(info)
            if self:GetAlpha() < 1 then
                self:SetAlpha(math.min(self:GetAlpha() + (delta*3), 1), true)
            end
			unitViewLayout.PositionWindow()
			unitViewLayout.UpdateStatusBars(controls)
        elseif self:GetAlpha() > 0 then
            self:SetAlpha(math.max(self:GetAlpha() - (delta*3), 0), true)
        end
    end

	-- This section is for the small icons showing what active enhancements an ACU has
	controls.enhancements = {}
	controls.enhancements['RCH'] = Bitmap(controls.bg)
	controls.enhancements['Back'] = Bitmap(controls.bg)
	controls.enhancements['LCH'] = Bitmap(controls.bg)

	LayoutHelpers.AtLeftTopIn(controls.enhancements['RCH'], controls.bg, 10, -30)
	LayoutHelpers.AtLeftTopIn(controls.enhancements['Back'], controls.bg, 42, -30)
	LayoutHelpers.AtLeftTopIn(controls.enhancements['LCH'], controls.bg, 74, -30)

    -- from GAZ UI - SCU Manager
    controls.SCUType = Bitmap(controls.bg)
    LayoutHelpers.AtRightIn(controls.SCUType, controls.icon)
    LayoutHelpers.AtBottomIn(controls.SCUType, controls.icon)

    -- expanded unit stats also from GAZ
    controls.shieldText = UIUtil.CreateText(controls.bg, '', 13, UIUtil.bodyFont)

    -- these are available but not implemented - showing storage values --
	--controls.StorageMass = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
	--controls.StorageEnergy = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
end
