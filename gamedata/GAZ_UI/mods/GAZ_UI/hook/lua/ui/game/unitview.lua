do
    local Prefs = import('/lua/user/prefs.lua')
    local options = Prefs.GetFromCurrentProfile('options')
	
	local LOUDFLOOR = math.floor
	
    if options.gui_scu_manager != 0 then
        local originalUpdateWindow = UpdateWindow
		
        function UpdateWindow(info)
            originalUpdateWindow(info)
            controls.SCUType:Hide()
            if info.userUnit.SCUType then
                controls.SCUType:SetTexture('/mods/GAZ_UI/textures/scumanager/'..info.userUnit.SCUType..'_icon.dds')
                controls.SCUType:Show()
            end
        end

        local originalCreateUI = CreateUI
        function CreateUI()
            originalCreateUI()
            controls.SCUType = Bitmap(controls.bg)
            LayoutHelpers.AtRightIn(controls.SCUType, controls.icon)
            LayoutHelpers.AtBottomIn(controls.SCUType, controls.icon)
        end
    end

    if options.gui_enhanced_unitview != 0 then
        local originalCreateUI = CreateUI
        local originalUpdateWindow = UpdateWindow
        function CreateUI()
            originalCreateUI()
            local oldBGOnFrame = controls.bg.OnFrame
            controls.bg.OnFrame = function(self, delta)
                local info = GetRolloverInfo()
                -- If no rollover, then see if we have a single unit selected
                if not info and import("/mods/GAZ_UI/modules/selectedinfo.lua").SelectedInfoOn then
                    local selUnits = GetSelectedUnits()
                    if selUnits and table.getn(selUnits) == 1 and import('/lua/ui/game/unitviewDetail.lua').View.Hiding then
                        info = import("/mods/GAZ_UI/modules/selectedinfo.lua").GetUnitRolloverInfo(selUnits[1])
                        --LOG(repr(import('/lua/enhancementcommon.lua').GetEnhancements(info.entityId)))
                    end
                end
                -- Original function code
                if info then
                    UpdateWindow(info)
                    if self:GetAlpha() < 1 then
                        self:SetAlpha(math.min(self:GetAlpha() + (delta*3), 1), true)
                    end
                    import(UIUtil.GetLayoutFilename('unitview')).PositionWindow()
                elseif self:GetAlpha() > 0 then
                    self:SetAlpha(math.max(self:GetAlpha() - (delta*3), 0), true)
                end
            end
        end

        function UpdateWindow(info)
            originalUpdateWindow(info)
            -- Replace fuel bar with progress bar
            if info.blueprintId ~= 'unknown' then
                controls.fuelBar:Hide()
                if info.workProgress > 0 then
                    controls.fuelBar:Show()
                    controls.fuelBar:SetValue(info.workProgress)
                end
            end
        end
    end
    if options.gui_detailed_unitview != 0 then
        local TV = import('/mods/GAZ_UI/modules/tvcheck.lua').Init()
        if TV == false then
            local OldUpdateWindow = UpdateWindow
            function UpdateWindow(info)
                OldUpdateWindow(info)
                if info.blueprintId != 'unknown' then
                    controls.Buildrate:Hide()
                    controls.shieldText:Hide()
-- works properly but i've yet to find a good spot to put that data in

--    if info.userUnit != nil and info.userUnit:GetBlueprint().Economy.StorageMass > 0 and info.userUnit:GetBlueprint().Economy.StorageEnergy > 0 then
--       controls.StorageMass:SetText(string.format("%d",LOUDFLOOR(info.userUnit:GetBlueprint().Economy.StorageMass)))
--       controls.StorageEnergy:SetText(string.format("%d",LOUDFLOOR(info.userUnit:GetBlueprint().Economy.StorageEnergy)))
--       controls.StorageMass:Show()
--       controls.StorageEnergy:Show()
--    else
--       controls.StorageMass:Hide()
--       controls.StorageEnergy:Hide()
--    end

--evilnewcode
                    local getEnh = import('/lua/enhancementcommon.lua')
					
                    if info.userUnit != nil then
					
                        local enhRegen , regenBase = 0 , 0
						
                        if getEnh.GetEnhancements(info.entityId) != nil then
                            for k,v in getEnh.GetEnhancements(info.entityId) do
                                if info.userUnit:GetBlueprint().Enhancements[getEnh.GetEnhancements(info.entityId)[k]].NewRegenRate != nil then
                                    enhRegen = info.userUnit:GetBlueprint().Enhancements[getEnh.GetEnhancements(info.entityId)[k]].NewRegenRate
                                end
                            end
                        end
						
                        local veterancyLevels = info.userUnit:GetBlueprint().Veteran or veterancyDefaults
						
                        if info.kills >= veterancyLevels[string.format('Level%d', 1)] then
						
                            local lvl = 1
							
                            for i = 2,5 do
                                if info.kills >= veterancyLevels[string.format('Level%d', i)] then
                                    lvl = i
                                end
                            end
							
							-- note -- this requires that units have a Buff entry in the blueprint - not always true so default to 0 if not found
                            local addRegen = info.userUnit:GetBlueprint().Buffs.Regen[string.format('Level%d', lvl)] or 0
                            local regenTotal
							
                            if info.userUnit != nil and info.health then
							
                                if LOUDFLOOR(info.userUnit:GetBlueprint().Defense.RegenRate) > 0 then
                                    regenTotal = LOUDFLOOR(  (info.userUnit:GetBlueprint().Defense.RegenRate) + addRegen )
                                    regenBase = LOUDFLOOR(info.userUnit:GetBlueprint().Defense.RegenRate + enhRegen )
                                else
                                    regenTotal = LOUDFLOOR(addRegen)
                                end
								
                                if regenTotal > 0 and regenBase > 0 then
                                    controls.health:SetText(string.format("%d / %d +%d(%d)/s", info.health, info.maxHealth, regenBase ,regenTotal ))
                                else
                                    controls.health:SetText(string.format("%d / %d +%d/s", info.health, info.maxHealth ,regenTotal ))
                                end
                            end
                        else
                            if info.userUnit != nil and info.health and info.userUnit:GetBlueprint().Defense.RegenRate > 0 then
                                controls.health:SetText(string.format("%d / %d +%d/s", info.health, info.maxHealth,LOUDFLOOR(info.userUnit:GetBlueprint().Defense.RegenRate + enhRegen)))
                            end
                        end
                    end
--endevilnewcode

                    if info.shieldRatio > 0 and info.userUnit:GetBlueprint().Defense.Shield.ShieldMaxHealth then
						
                        local ShieldMaxHealth = info.userUnit:GetBlueprint().Defense.Shield.ShieldMaxHealth
						
                        controls.shieldText:Show()
						
                        if info.userUnit:GetBlueprint().Defense.Shield.ShieldRegenRate then
                            controls.shieldText:SetText(string.format("%d / %d +%d/s", LOUDFLOOR(ShieldMaxHealth*info.shieldRatio), info.userUnit:GetBlueprint().Defense.Shield.ShieldMaxHealth , info.userUnit:GetBlueprint().Defense.Shield.ShieldRegenRate))
                        else
                            controls.shieldText:SetText(string.format("%d / %d", LOUDFLOOR(ShieldMaxHealth*info.shieldRatio), info.userUnit:GetBlueprint().Defense.Shield.ShieldMaxHealth ))
                        end
                    end
-- newcode
                    if info.shieldRatio > 0 and info.userUnit:GetBlueprint().Defense.Shield.ShieldMaxHealth == nil then
						
                        local ShieldMaxHealth = info.userUnit:GetBlueprint().Enhancements[getEnh.GetEnhancements(info.entityId).Back].ShieldMaxHealth
						
						if ShieldMaxHealth then
							controls.shieldText:Show()
						
						
                        if info.userUnit:GetBlueprint().Enhancements[getEnh.GetEnhancements(info.entityId).Back].ShieldRegenRate then
                            controls.shieldText:SetText(string.format("%d / %d +%d/s", LOUDFLOOR(ShieldMaxHealth*info.shieldRatio), ShieldMaxHealth , info.userUnit:GetBlueprint().Enhancements[getEnh.GetEnhancements(info.entityId).Back].ShieldRegenRate))
                        else
                            controls.shieldText:SetText(string.format("%d / %d", LOUDFLOOR(ShieldMaxHealth*info.shieldRatio), ShieldMaxHealth ))
                        end
						
						end
                    end
--newcode
                    if info.userUnit != nil and info.userUnit:GetBuildRate() >= 2 then
                        controls.Buildrate:SetText(string.format("%d",LOUDFLOOR(info.userUnit:GetBuildRate())))
                        controls.Buildrate:Show()
                    else
                        controls.Buildrate:Hide()
                    end
                end
            end
            local OldCreateUI = CreateUI
            function CreateUI()
                OldCreateUI()
                controls.shieldText = UIUtil.CreateText(controls.bg, '', 13, UIUtil.bodyFont)
                controls.Buildrate = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
-- controls.StorageMass = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
-- controls.StorageEnergy = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
            end
        end
    end
end
