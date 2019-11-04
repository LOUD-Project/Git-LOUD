local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Prefs = import('/lua/user/prefs.lua')
local UnitDescriptions = import('/lua/ui/help/unitdescription.lua').Description

--local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua')
local   enhancementSlotNames = {}         -- __DMSI.__DMod_EnhancementSlotNames or {}

enhancementSlotNames.back = '<LOC uvd_0007>Back'
enhancementSlotNames.lch = '<LOC uvd_0008>LCH'
enhancementSlotNames.rch = '<LOC uvd_0009>RCH'

View = false
ViewState = "full"
MapView = false

-- Added by Tanksy to allow rounding.
function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function Contract()
	View:SetNeedsFrameUpdate(false)
	View:Hide()
end

function Expand()
	View:Show()
	View:SetNeedsFrameUpdate(true)
end

function GetTechLevelString(bp)
    if EntityCategoryContains(categories.TECH1, bp.BlueprintId) then
        return 1
    elseif EntityCategoryContains(categories.TECH2, bp.BlueprintId) then
        return 2
    elseif EntityCategoryContains(categories.TECH3, bp.BlueprintId) then
        return 3
    else
        return false
    end
end

-- Taken from Unitview.lua,
-- Instead of the original function which did this in a strange and long-winded process.
function FormatTime(seconds)
	return string.format("%02d:%02d", math.floor(seconds / 60), math.mod(seconds, 60))
end

function GetAbilityList(bp)
    local abilitiesList = {}

    return abilitiesList
end

function CheckFormat()
    if ViewState != Prefs.GetOption('uvd_format') then
        SetLayout()
    end
    if ViewState == "off" then
        return false
    else
        return true
    end
end

function ShowView( showUpKeep, enhancement, showecon, showShield )

	import('/lua/ui/game/unitview.lua').ShowROBox(false, false)
	
	View:Show()
    
    View.Hiding = false
	
	View.UpkeepGroup:SetHidden(not showUpKeep)
	
	View.BuildCostGroup:SetHidden(not showecon)
	View.UpkeepGroup:SetHidden(not showUpKeep)
	View.TimeStat:SetHidden(not showecon)
	View.HealthStat:SetHidden(not showecon)
	
	View.HealthStat:SetHidden(enhancement)
	
	View.ShieldStat:SetHidden(not showShield)
end

function ShowEnhancement( bp, bpID, iconID, iconPrefix, userUnit )

	if View and CheckFormat() then
    
        LOG("*AI DEBUG ShowEnhancement")

		-- Name / Description
		View.UnitImg:SetTexture(UIUtil.UIFile(iconPrefix..'_btn_up.dds'))

		LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
		View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)

		local slotName = enhancementSlotNames[string.lower(bp.Slot)]
		slotName = slotName or bp.Slot

		if bp.Name != nil then
			View.UnitShortDesc:SetText(LOCF("%s: %s", bp.Name, slotName))
		else
			View.UnitShortDesc:SetText(LOC(slotName))
		end
		
		if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
			LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
			View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
		end

		local showecon = true
		local showAbilities = false
		local showUpKeep = false
		local time, energy, mass
		
		if bp.Icon != nil and not string.find(bp.Name, 'Remove') then
		
			time, energy, mass = import('/lua/game.lua').GetConstructEconomyModel(userUnit, bp)
			time = math.max(time, 1)
			
			showUpKeep = DisplayResources(bp, time, energy, mass)
			View.TimeStat.Value:SetFont(UIUtil.bodyFont, 14)
			View.TimeStat.Value:SetText(string.format("%s", FormatTime(time)))
			
			if string.len(View.TimeStat.Value:GetText()) > 5 then
				View.TimeStat.Value:SetFont(UIUtil.bodyFont, 10)
			end
		else
			showecon = false
			
			if View.Description then
			
				View.Description:Hide()
				
				for i, v in View.Description.Value do
					v:SetText("")
				end
			end
		end

		if View.Description then
		
			local tempDescID = bpID.."-"..iconID
			
			if UnitDescriptions[tempDescID] and not string.find(bp.Name, 'Remove') then
			
				local tempDesc = LOC(UnitDescriptions[tempDescID])
				
				WrapAndPlaceText(nil, nil, nil, nil, tempDesc, View.Description)
			else
				WARN('No description found for unit: ', bpID, ' enhancement: ', iconID)
				
				View.Description:Hide()
				
				for i, v in View.Description.Value do
					v:SetText("")
				end
			end
		end

		local showShield = false
		
		if bp.ShieldMaxHealth then
			showShield = true
			View.ShieldStat.Value:SetText(bp.ShieldMaxHealth)
		end

		ShowView(showUpKeep, true, showecon, showShield)
		
		if time == 0 and energy == 0 and mass == 0 then
			View.BuildCostGroup:Hide()
			View.TimeStat:Hide()
		end
        
	elseif not View or not CheckFormat() then
    
		Hide()
        
	end
    
end

function WrapAndPlaceText(air, physics, weapons, abilities, text, control)

	local textLines = {}
	
	-- -1 so that no line color can change (As there won't be an index of -1),
	-- but only if there's no Air or Physics on the blueprint.
	local physics_line = -1
	
	if text != nil then
		textLines = import('/lua/maui/text.lua').WrapText(text, control.Value[1].Width(),function(text) return control.Value[1]:GetStringAdvance(text) end)
	end
	
	local abilityLines = 0
	
	if abilities != nil then
	
		local i = table.getn(abilities)
		
		while abilities[i] do
			table.insert(textLines, 1, LOC(abilities[i]))
			i = i - 1
		end
		
		abilityLines = table.getsize(abilities)
	end

	-- Start point of the weapon lines.
	local weapon_start = table.getn(textLines)
	
	if weapons != nil then
		table.insert(textLines, "")

		-- Used for comparing last weapon checked.
		local lastWeaponDmg = 0
		local lastWeaponPPOF = 0
		local lastWeaponDoT = 0
		local lastWeaponDmgRad = 0
		local lastWeaponMinRad = 0
		local lastWeaponMaxRad = 0
		local lastWeaponROF = 0
		local lastWeaponFF = false
		local lastWeaponNukeInDmg = 0
		local lastWeaponNukeInRad = 0
		local lastWeaponNukeInTime = 0
		local lastWeaponNukeOutDmg = 0
		local lastWeaponNukeOutRad = 0
		local lastWeaponNukeOutTime = 0
		local weaponText = ""
		
		-- BuffType.
		local bType = ""
		-- RangeCategory.
		local wepCategory = ""
		
		local dupWeaponCount = 1

		for i, weapon in weapons do
			-- Check for RangeCategories.
			if weapon.RangeCategory == 'UWRC_DirectFire' then
				wepCategory = "Direct Fire"
			elseif weapon.RangeCategory == 'UWRC_IndirectFire' then
				wepCategory = "Indirect"
			elseif weapon.RangeCategory == 'UWRC_AntiAir' then
				wepCategory = "Anti Air"
			elseif weapon.RangeCategory == 'UWRC_AntiNavy' then
				wepCategory = "Anti Navy"
			elseif weapon.RangeCategory == 'UWRC_Countermeasure' then
				wepCategory = "Defense"
			elseif string.find(weapon.Label, "Death") then
				if weapon.Label== "DeathImpact" then
					wepCategory = "Air Crash"
				else
					wepCategory = "Volatile"
				end
			elseif weapon.Label == "Suicide" then
				wepCategory = "Kamikaze"
			else
				wepCategory = tostring(weapon.Label)
			end
			
			-- Check if we're a Nuke weapon.
			if weapon.NukeInnerRingDamage > 0 then
				wepCategory = "Nuke"
			end
			
			-- Check if it's a death weapon.
			if wepCategory == "Air Crash" or wepCategory == "Volatile" or wepCategory == "Kamikaze" then
			
				weaponText = (wepCategory .. " { Dmg: " .. tostring(round(weapon.Damage,2)))
				
				-- Check DamageRadius and concat.
				if weapon.DamageRadius > 0 then
					weaponText = (weaponText .. ", AoE: " .. tostring(weapon.DamageRadius))
				end
				
				-- Check DamageFriendly and concat.
				if weapon.DamageFriendly != false then
					weaponText = (weaponText .. ", (FF)")
				end
				
				-- Finish text line.
				weaponText = (weaponText .. " }")

				-- Insert death weapon text line.
				table.insert(textLines, weaponText)
				
			-- Check if it's a nuke weapon.
			elseif wepCategory == "Nuke" then
			
				-- Look for signs that it's a Death weapon. This will do until we make everything uniform with each unit having the same setup for their death nukes.
				if string.find(tostring(weapon.WeaponCategory), "Death") then
					weaponText = ("Death " .. wepCategory)
				elseif string.find(tostring(weapon.Label), "Death") then
					weaponText = ("Death " .. wepCategory)
				else
					weaponText = (wepCategory)
				end
				
				if weapon.NukeInnerRingTotalTime > 0 or weapon.NukeOuterRingTotalTime > 0 then
					weaponText = (weaponText .. " { In-Dmg: " .. tostring(weapon.NukeInnerRingDamage) .. " (" .. tostring(weapon.NukeInnerRingTotalTime) .. "s), AoE: " .. tostring(weapon.NukeInnerRingRadius) .. " | Out-Dmg: " .. tostring(weapon.NukeOuterRingDamage) .. " (" .. tostring(weapon.NukeOuterRingTotalTime) .. "s), AoE: " .. tostring(weapon.NukeOuterRingRadius))
				else
					weaponText = (weaponText .. " { In-Dmg: " .. tostring(weapon.NukeInnerRingDamage) .. ", AoE: " .. tostring(weapon.NukeInnerRingRadius) .. " | Out-Dmg: " .. tostring(weapon.NukeOuterRingDamage) .. ", AoE: " .. tostring(weapon.NukeOuterRingRadius))
				end
				
				-- Check Buffs and concat.
				if weapon.Buffs then
				
					for i, buff in weapon.Buffs do
					
						bType = buff.BuffType
						weaponText = (weaponText .. ", " .. bType)
					end
				end
				
				-- Finish text lines.
				weaponText = (weaponText .. " }")

				if weapon.NukeInnerRingDamage == lastWeaponNukeInDmg and weapon.NukeInnerRingRadius == lastWeaponNukeInRad and weapon.NukeInnerRingTotalTime == lastWeaponNukeInTime and weapon.NukeOuterRingDamage == lastWeaponNukeOutDmg and weapon.NukeOuterRingRadius == lastWeaponNukeOutRad and weapon.NukeOuterRingTotalTime == lastWeaponNukeOutTime and weapon.DamageFriendly == lastWeaponFF then
					dupWeaponCount = dupWeaponCount + 1
					-- Remove the old lines, to insert the new ones with the updated weapon count.
					table.remove(textLines, table.getn(textLines))
					table.insert(textLines, string.format("%s (x%d)", weaponText, dupWeaponCount))
				else
					dupWeaponCount = 1
					-- Insert the textLine.
					table.insert(textLines, weaponText)
				end
			else
				-- Start the weaponText string if we do damage.
				if weapon.Damage > 1 then
				
					weaponText = (wepCategory .. " { Dmg: " .. tostring(round(weapon.Damage,2)))
					-- Check PPF and concat.
					if weapon.ProjectilesPerOnFire > 1 then
						weaponText = (weaponText .. " (x" .. tostring(weapon.ProjectilesPerOnFire) .. ")")
					end
					
					-- Check DoTPulses and concat.
					if weapon.DoTPulses > 0 then
						weaponText = (weaponText .. " (" .. tostring(weapon.DoTPulses) .. " Times)")
					end
					
					-- Check DamageRadius and concat.
					if weapon.DamageRadius > 0 then
						weaponText = (weaponText .. ", AoE: " .. tostring(weapon.DamageRadius))
					end
					
					-- Check RateOfFire and concat.
					if weapon.RateOfFire > 0 then
						weaponText = (weaponText .. ", RoF: " .. tostring(round(weapon.RateOfFire, 2)))
					end
					
					-- Check Min/Max Radius and concat.
					if weapon.MaxRadius > 0 then
						if weapon.MinRadius > 0 then
							weaponText = (weaponText .. ", Rng: " .. tostring(round(weapon.MinRadius, 2)) .. "-" .. tostring(round(weapon.MaxRadius, 2)))
						else
							weaponText = (weaponText .. ", Rng: " .. tostring(round(weapon.MaxRadius, 2)))
						end
					end
					
					-- Check Buffs and concat.
					if weapon.Buffs then
						for i, buff in weapon.Buffs do
							bType = buff.BuffType
							weaponText = (weaponText .. ", " .. bType)
						end
					end
					
					-- Check friendly fire and concat.
					if weapon.DamageFriendly != false then
						weaponText = (weaponText .. " (FF)")
					end
					
					-- Finish text line.
					weaponText = (weaponText .. " }")

					-- Check duplicate weapons. We compare lots of values here, 
					-- any slight difference should be considered a different weapon. 
					if weapon.Damage == lastWeaponDmg and weapon.ProjectilesPerOnFire == lastWeaponPPOF and weapon.DoTPulses == lastWeaponDoT and weapon.DamageRadius == lastWeaponDmgRad and 	weapon.RateOfFire == lastWeaponROF and weapon.MinRadius == lastWeaponMinRad and 	weapon.MaxRadius == lastWeaponMaxRad and weapon.DamageFriendly == lastWeaponFF then
						dupWeaponCount = dupWeaponCount + 1
						-- Remove the old line, to insert the new one with the updated weapon count.
						table.remove(textLines, table.getn(textLines))
						table.insert(textLines, string.format("%s (x%d)", weaponText, dupWeaponCount))
					else
						dupWeaponCount = 1
						-- Insert the textLine.
						table.insert(textLines, weaponText)
					end
				end
			end
			
			-- Set lastWeapon stuff.
			lastWeaponDmg = weapon.Damage
			lastWeaponPPOF = weapon.ProjectilesPerOnFire
			lastWeaponDoT = weapon.DoTPulses
			lastWeaponDmgRad = weapon.DamageRadius
			lastWeaponROF = weapon.RateOfFire
			lastWeaponMinRad = weapon.MinRadius
			lastWeaponMaxRad = weapon.MaxRadius
			lastWeaponFF = weapon.DamageFriendly
			lastWeaponNukeInDmg = weapon.NukeInnerRingDamage
			lastWeaponNukeInRad = weapon.NukeInnerRingRadius
			lastWeaponNukeInTime = weapon.NukeInnerRingTotalTime
			lastWeaponNukeOutDmg = weapon.NukeOuterRingDamage
			lastWeaponNukeOutRad = weapon.NukeOuterRingRadius
			lastWeaponNukeOutTime = weapon.NukeOuterRingTotalTime
		end
	end

	local weapon_end = table.getn(textLines)
		
	if air != nil then
	
		if air.MaxAirspeed and air.MaxAirspeed !=0 then
			table.insert(textLines, LOCF("Speed: %0.2f, Turning: %0.2f", air.MaxAirspeed, air.TurnSpeed))
			physics_line = table.getn(textLines)
		end
		
	elseif physics != nil then
	
		if physics.MaxSpeed and physics.MaxSpeed !=0 then
			table.insert(textLines, LOCF("Speed: %0.2f, Acceleration: %0.2f, Turning: %d", physics.MaxSpeed, physics.MaxBrake, physics.TurnRate))
			physics_line = table.getn(textLines)
		end
	end

	for i, v in textLines do
	
		local index = i
		
		if control.Value[index] then
			-- If control.Value (View.Description) has a value, 
			-- set the text of the value to the value of the index we're looping through.
			control.Value[index]:SetText(v)
		else
			-- If control.Value (View.Description) has no value, we create the value.
			control.Value[index] = UIUtil.CreateText( control, v, 12, UIUtil.bodyFont)
			LayoutHelpers.Below(control.Value[index], control.Value[index-1])
			control.Value[index].Right:Set(function() return control.Right() - 7 end)
			control.Value[index].Width:Set(function() return control.Right() - control.Left() - 14 end)
			control.Value[index]:SetClipToWidth(true)
			control.Value[index]:DisableHitTest(true)
		end
		
		-- Set colors of lines.
		if index <= abilityLines then
			control.Value[index]:SetColor(UIUtil.bodyColor)
			control.Value[index]:SetFont(UIUtil.bodyFont, 12)
		elseif index == physics_line then
			-- Physics text color
			control.Value[index]:SetColor('83d5e6')
			-- Squish down the info text by 1 font size point to fit more in the box.
			control.Value[index]:SetFont(UIUtil.bodyFont, 11)
		elseif index > weapon_start and index <= weapon_end then
			control.Value[index]:SetFont(UIUtil.bodyFont, 11)
			if string.find(tostring(v), "Direct Fire") then			-- Direct Fire
				control.Value[index]:SetColor('ff3333')
			elseif string.find(tostring(v), "Anti Air") then		-- Anti Air
				control.Value[index]:SetColor('00ffff')
			elseif string.find(tostring(v), "Indirect") then		-- Indirect Fire
				control.Value[index]:SetColor('ffff00')
			elseif string.find(tostring(v), "Anti Navy") then		-- Anti Navy
				control.Value[index]:SetColor('00ff00')
			elseif string.find(tostring(v), "Defense") then			-- Countermeasure
				control.Value[index]:SetColor('ffa500')
			elseif string.find(tostring(v), "Nuke") then			-- Nuke
				control.Value[index]:SetColor('ffa500')
			elseif string.find(tostring(v), "Air Crash") then		-- Air Crash
				control.Value[index]:SetColor('b077ff')
			elseif string.find(tostring(v), "Volatile") then		-- Volatile
				control.Value[index]:SetColor('b077ff')
			elseif string.find(tostring(v), "Kamikaze") then		-- Kamikaze/Suicide
				control.Value[index]:SetColor('b077ff')
			else
				control.Value[index]:SetColor('909090')
			end
		else
			control.Value[index]:SetColor(UIUtil.fontColor)
			control.Value[index]:SetFont(UIUtil.bodyFont, 12)
		end
		
		control.Height:Set(function() return (math.max(table.getsize(textLines), 4) * control.Value[1].Height()) + 30 end)
	end
	
	for i, v in control.Value do
	
		local index = i
		
		if index > table.getsize(textLines) then
			v:SetText("")
		end
	end
end

function Show(bp, buildingUnit, bpID)

	if CheckFormat() then
	
		-- Name / Description
		if false then
			local foo, iconName = GameCommon.GetCachedUnitIconFileNames(bp)
			if iconName then
				View.UnitIcon:SetTexture(iconName)
			else
				View.UnitIcon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))    
			end
		end
		
		LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
		View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)
		
		local description = LOC(bp.Description)
		
		if GetTechLevelString(bp) then
			description = LOCF('Tech %d %s', GetTechLevelString(bp), description)
		end
		
		if bp.General.UnitName != nil then
			View.UnitShortDesc:SetText(LOCF("%s: %s", bp.General.UnitName, description))
		else
			View.UnitShortDesc:SetText(LOCF("%s", description))
		end
		
		if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
			LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
			View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
		end
		
		local showecon = true
		local showUpKeep = false
		local showAbilities = false
		
		if buildingUnit != nil then
		
			local time, energy, mass = import('/lua/game.lua').GetConstructEconomyModel(buildingUnit, bp.Economy)
			time = math.max(time, 1)
			
			showUpKeep = DisplayResources(bp, time, energy, mass)
			View.TimeStat.Value:SetFont(UIUtil.bodyFont, 14)
			View.TimeStat.Value:SetText(string.format("%s", FormatTime(time)))
			
			if string.len(View.TimeStat.Value:GetText()) > 5 then
				View.TimeStat.Value:SetFont(UIUtil.bodyFont, 10)
			end
		else
			showecon = false
		end

		-- Health stat
		View.HealthStat.Value:SetText(string.format("%d", bp.Defense.MaxHealth))

		if View.Description then
			WrapAndPlaceText(bp.Air, bp.Physics, bp.Weapon, bp.Display.Abilities, LOC(UnitDescriptions[bpID]), View.Description)
		end
		
		local showShield = false
		
		if bp.Defense.Shield and bp.Defense.Shield.ShieldMaxHealth then
			showShield = true
			View.ShieldStat.Value:SetText(bp.Defense.Shield.ShieldMaxHealth)
		end

		local iconName = GameCommon.GetCachedUnitIconFileNames(bp)
		
		View.UnitImg:SetTexture(iconName)
		View.UnitImg.Height:Set(46)
		View.UnitImg.Width:Set(48)

		ShowView(showUpKeep, false, showecon, showShield)
	else
		Hide()
	end
end

function DisplayResources(bp, time, energy, mass)

	-- Cost Group
	if time > 0 then
		local consumeEnergy = -energy / time
		local consumeMass = -mass / time
		View.BuildCostGroup.EnergyValue:SetText( string.format("%d (%d)",-energy,consumeEnergy) )
		View.BuildCostGroup.MassValue:SetText( string.format("%d (%d)",-mass,consumeMass) )

		View.BuildCostGroup.EnergyValue:SetColor( "FFF05050" )
		View.BuildCostGroup.MassValue:SetColor( "FFF05050" )
	end

	-- Upkeep Group
	local plusEnergyRate = bp.Economy.ProductionPerSecondEnergy or bp.ProductionPerSecondEnergy
	local negEnergyRate = bp.Economy.MaintenanceConsumptionPerSecondEnergy or bp.MaintenanceConsumptionPerSecondEnergy
	local plusMassRate = bp.Economy.ProductionPerSecondMass or bp.ProductionPerSecondMass
	local negMassRate = bp.Economy.MaintenanceConsumptionPerSecondMass or bp.MaintenanceConsumptionPerSecondMass
	local upkeepEnergy = GetYield(negEnergyRate, plusEnergyRate)
	local upkeepMass = GetYield(negMassRate, plusMassRate)
	local showUpkeep = false
	
	if upkeepEnergy != 0 or upkeepMass != 0 then
	
		View.UpkeepGroup.Label:SetText(LOC("<LOC uvd_0002>Yield"))
		View.UpkeepGroup.EnergyValue:SetText( string.format("%d",upkeepEnergy) )
		View.UpkeepGroup.MassValue:SetText( string.format("%d",upkeepMass) )
		
		if upkeepEnergy >= 0 then
			View.UpkeepGroup.EnergyValue:SetColor( "FF50F050" )
		else
			View.UpkeepGroup.EnergyValue:SetColor( "FFF05050" )
		end

		if upkeepMass >= 0 then
			View.UpkeepGroup.MassValue:SetColor( "FF50F050" )
		else
			View.UpkeepGroup.MassValue:SetColor( "FFF05050" )
		end
		
		showUpkeep = true
		
	elseif bp.Economy and (bp.Economy.StorageEnergy != 0 or bp.Economy.StorageMass != 0) then
	
		View.UpkeepGroup.Label:SetText(LOC("<LOC uvd_0006>Storage"))
		
		local upkeepEnergy = bp.Economy.StorageEnergy or 0
		local upkeepMass = bp.Economy.StorageMass or 0
		
		View.UpkeepGroup.EnergyValue:SetText( string.format("%d",upkeepEnergy) )
		View.UpkeepGroup.MassValue:SetText( string.format("%d",upkeepMass) )
		View.UpkeepGroup.EnergyValue:SetColor( "FF50F050" )
		View.UpkeepGroup.MassValue:SetColor( "FF50F050" )
		
		showUpkeep = true
	end

	return showUpkeep 
end

function GetYield(consumption, production)

    if consumption then
        return -consumption
    elseif production then
        return production
    else
        return 0
    end
end

function OnNIS()
	if View then
		View:Hide()
		View:SetNeedsFrameUpdate(false)
	end
end

function Hide()

    if View then
        View:Hide()
        View.Hiding = true
    end
end

function SetLayout()
    import(UIUtil.GetLayoutFilename('unitviewDetail')).SetLayout()
end

function SetupUnitViewLayout(parent)

	if View then
		View:Destroy()
		View = nil
	end
	
	MapView = parent
	
	SetLayout()
	
	View:Hide()
	View:SetNeedsFrameUpdate(true)
	View:DisableHitTest(true)
end