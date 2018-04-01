do
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local veterancyDefaults = import('/lua/game.lua').VeteranDefault
local Factions = import('/lua/factions.lua')
local Prefs = import('/lua/user/prefs.lua')
local EnhancementCommon = import('/lua/enhancementcommon.lua')

local rolloverInfo = false
local consTrue = false
local focusBool = false

local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')

function UpdateWindow(info)
    if info.blueprintId == 'unknown' then
        controls.name:SetText(LOC('<LOC rollover_0000>Unknown Unit'))
        controls.icon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
        controls.stratIcon:SetTexture('/textures/ui/common/game/strategicicons/icon_structure_generic_selected.dds')
        for index = 1, 6 do
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
        controls.actionIcon:Hide()
        controls.actionText:Hide()
        controls.abilities:Hide()
    else
        local bp = __blueprints[info.blueprintId]
        local path = '/textures/ui/common/icons/units/'..info.blueprintId..'_icon.dds'

		--####################
		--Exavier Code Block +
		--####################
		local EXunitID = bp.BlueprintId
		if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
			-- Check manually assigned overwrite table
			local expath = EXunitID..'_icon.dds'
			controls.icon:SetTexture(BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath)
		elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
			-- Check modded icon hun table
			local expath = EXunitID..'_icon.dds'
			controls.icon:SetTexture(BlackopsIcons.EXIconTableScan(EXunitID) .. expath)
		else
			-- Check default GPG directories
			if DiskGetFileInfo(path) then
				controls.icon:SetTexture(path)
			else 
				-- Sets placeholder because no other icon was found
				controls.icon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
				if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
					-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
					WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
					BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
				end
			end
		end
		--####################
		--Exavier Code Block -
		--####################

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
        if info.customName then
            controls.name:SetText(LOCF('%s: %s', info.customName, description))
        elseif bp.General.UnitName then
            controls.name:SetText(LOCF('%s: %s', bp.General.UnitName, description))
        else
            controls.name:SetText(LOCF('%s', description))
        end
        if controls.name:GetStringAdvance(controls.name:GetText()) > controls.name.Width() then
            LayoutHelpers.AtTopIn(controls.name, controls.bg, 14)
            controls.name:SetFont(UIUtil.bodyFont, 10)
        end
        for index = 1, 6 do
            local i = index
            if statFuncs[i](info, bp) then
                if i == 1 then
                    local value, iconType, color = statFuncs[i](info, bp)
                    controls.statGroups[i].color:SetSolidColor(color)
                    controls.statGroups[i].icon:SetTexture(iconType)
                    controls.statGroups[i].value:SetText(value)
                elseif i == 4 then
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
        
        controls.shieldBar:Hide()
        controls.fuelBar:Hide()

        if info.shieldRatio > 0 then
            controls.shieldBar:Show()
            controls.shieldBar:SetValue(info.shieldRatio)
        end
        
        if info.fuelRatio > 0 then
            controls.fuelBar:Show()
            controls.fuelBar:SetValue(info.fuelRatio)
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
            controls.health:SetText(string.format("%d / %d", info.health, info.maxHealth))
        else
            controls.healthBar:Hide()
        end
        local veterancyLevels = bp.Veteran or veterancyDefaults
        for index = 1, 5 do
            local i = index
            if info.kills >= veterancyLevels[string.format('Level%d', i)] then
                controls.vetIcons[i]:Show()
                controls.vetIcons[i]:SetTexture(UIUtil.UIFile(Factions.Factions[Factions.FactionIndexMap[string.lower(bp.General.FactionName)]].VeteranIcon))
            else
                controls.vetIcons[i]:Hide()
            end
        end
        local unitQueue = false
        if info.userUnit then
            unitQueue = info.userUnit:GetCommandQueue()
        end
        if info.focus then
            local path = '/textures/ui/common/icons/units/'..info.focus.blueprintId..'_icon.dds'

			--####################
			--Exavier Code Block +
			--####################
			local EXunitID = info.focus.blueprintId
			if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
				-- Check manually assigned overwrite table
				local expath = EXunitID..'_icon.dds'
				controls.actionIcon:SetTexture(BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath)
			elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
				-- Check modded icon hun table
				local expath = EXunitID..'_icon.dds'
				controls.actionIcon:SetTexture(BlackopsIcons.EXIconTableScan(EXunitID) .. expath)
			else
				-- Check default GPG directories
				if DiskGetFileInfo(path) then
					controls.actionIcon:SetTexture(path)
				else 
					-- Sets placeholder because no other icon was found
					controls.actionIcon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
					if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
						-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
						WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
						BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
					end
				end
			end
			--####################
			--Exavier Code Block -
			--####################
		
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
            controls.abilities.Height:Set(function() return controls.abilityText[1].Height() * table.getsize(controls.abilityText) end)
            if controls.abilities:IsHidden() then
                controls.abilities:Show()
            end
        elseif not controls.abilities:IsHidden() then
            controls.abilities:Hide()
        end
    end
end

end