local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Prefs = import('/lua/user/prefs.lua')
local UnitDescriptions = import('/lua/ui/help/unitdescription.lua').Description
local TitleCase = import('/lua/utilities.lua').LOUD_TitleCase

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') or false

local enhancementSlotNames = {}

local LOUDFIND = string.find
local LOUDFORMAT = string.format
local LOUDFLOOR = math.floor
local LOUDUPPER = string.upper
local LOUDLOWER = string.lower
local LOUDSUB = string.sub

-- This function checks and converts Meters to Kilometers if the measurement (in meters) is >= 1000.
function LOUD_KiloCheck(aMeasurement)
	if aMeasurement >= 1000 then
		return LOUDFORMAT("%.2f", aMeasurement / 1000):gsub("%.?0+$", "") .. "km"
	else
		return tostring(aMeasurement) .. "m"
	end
end

-- This function checks and converts numbers to thousands if the number is >= 1000.
function LOUD_ThouCheck(aNumber)
	if aNumber >= 1000 then
		return LOUDFORMAT("%.1f", aNumber / 1000):gsub("%.?0+$", "") .. "K"
	else
		return tostring(aNumber)
	end
end

-- This function returns a formatted Fuel time value.
function LOUD_FuelCheck(aFuelTime)
	local minutes = LOUDFORMAT("%02.f", LOUDFLOOR(aFuelTime / 60)):gsub("%.?0+$", "")
	local seconds = LOUDFORMAT("%02.f", math.mod(aFuelTime, 60))
	
	return minutes..":"..seconds.."s"
end

-- This function checks and converts a speed value (o-grids per second) into a human-readable speed. (Meters/second)
function LOUD_SpeedCheck(aSpeed)
	return LOUDFORMAT("%.2f", aSpeed * 20):gsub("%.?0+$", "") .. "m/s"
end



-- if DMS is turned on --
if __DMSI then
    enhancementSlotNames = __DMSI.__DMod_EnhancementSlotNames
end

enhancementSlotNames.back = '<LOC uvd_0007>Back'
enhancementSlotNames.lch = '<LOC uvd_0008>LCH'
enhancementSlotNames.rch = '<LOC uvd_0009>RCH'

View = false
ViewState = "full"
MapView = false

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
    if ViewState ~= Prefs.GetOption('uvd_format') then
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
    
        --LOG("*AI DEBUG ShowEnhancement")

		-- Name / Description
		View.UnitImg:SetTexture(UIUtil.UIFile(iconPrefix..'_btn_up.dds'))

		LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
		View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)

		local slotName = enhancementSlotNames[string.lower(bp.Slot)]
		slotName = slotName or bp.Slot

		if bp.Name ~= nil then
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
		
		if bp.Icon ~= nil and not LOUDFIND(bp.Name, 'Remove') then
		
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
			
			if UnitDescriptions[tempDescID] and not LOUDFIND(bp.Name, 'Remove') then
			
				local tempDesc = LOC(UnitDescriptions[tempDescID])
				
				WrapAndPlaceText(nil, nil, nil, nil, nil, tempDesc, View.Description)
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

function WrapAndPlaceText(air, physics, intel, weapons, abilities, text, control)
	
	-- Create the table of text to be displayed once populated.
	local textLines = {}
	
	-- -1 so that no line color can change (As there won't be an index of -1),
	-- but only if there's no Air or Physics on the blueprint.
	local physics_line = -1
	local intel_line = -1
	
	if text ~= nil then
		textLines = import('/lua/maui/text.lua').WrapText( text, control.Value[1].Width(), function(text) return control.Value[1]:GetStringAdvance(text) end)
	end
	
	-- Keep a count of the Ability lines.
	local abilityLines = 0
	
	-- Check for abilities on the BP.
	if abilities ~= nil then
	
		local i = table.getn(abilities)
		
		-- Insert each ability into the textLines table.
		while abilities[i] do
			table.insert(textLines, 1, LOC(abilities[i]))
			i = i - 1
		end
		
		--Update the count of Ability lines.
		abilityLines = table.getsize(abilities)
	end

	-- Start point of the weapon lines.
	local weapon_start = table.getn(textLines)
	
	if weapons ~= nil then
		-- Inserts a blank line for spacing.
		table.insert(textLines, "")
		
		-- Import PhoenixMT's DPS Calculator script.
		doscript '/lua/PhxLib.lua'

		-- Used for comparing last weapon checked.
		local lastWeaponDmg = 0
		local lastWeaponDPS = 0
		local lastWeaponPPOF = 0
		local lastWeaponDoT = 0
		local lastWeaponDmgRad = 0
		local lastWeaponMinRad = 0
		local lastWeaponMaxRad = 0
		local lastWeaponROF = 0
		local lastWeaponFF = false
		local lastWeaponCF = false
		local lastWeaponTarget = ''
		local lastWeaponNukeInDmg = 0
		local lastWeaponNukeInRad = 0
		local lastWeaponNukeOutDmg = 0
		local lastWeaponNukeOutRad = 0
		local weaponText = ""
		
		-- BuffType.
		local bType = ""
		-- Weapon Category is checked to color lines, as well as checked for countermeasure weapons and differentiating the info displayed.
		local wepCategory = ""
		
		local dupWeaponCount = 1

		for i, weapon in weapons do
			-- Check for DummyWeapon Label (Used by Paragons for Range Rings).
			if not LOUDFIND(weapon.Label, 'Dummy') and not LOUDFIND(weapon.Label, 'Tractor') and not LOUDFIND(weapon.Label, 'Painter') then
				-- Check for RangeCategories.
				if weapon.RangeCategory ~= nil then
					if weapon.RangeCategory == 'UWRC_DirectFire' then
						wepCategory = "Direct"
					end
					if weapon.RangeCategory == 'UWRC_IndirectFire' then
						wepCategory = "Indirect"
					end
					if weapon.RangeCategory == 'UWRC_AntiAir' then
						wepCategory = "Anti Air"
					end
					if weapon.RangeCategory == 'UWRC_AntiNavy' then
						wepCategory = "Anti Navy"
					end
					if weapon.RangeCategory == 'UWRC_Countermeasure' then
						wepCategory = " Defense"
					end
				end
				
				-- Check for Death weapon labels
				if LOUDFIND(weapon.Label, 'Death') then
					wepCategory = "Volatile"
				end
				if weapon.Label == 'DeathImpact' then
					wepCategory = "Crash"
				end
				if weapon.Label == 'Suicide' then
					wepCategory = "Suicide"
				end
				
				-- These weapons have no RangeCategory, but do have Labels.
				if weapon.Label == 'Bomb' then
					wepCategory = "Indirect"
				end
				if weapon.Label == 'Torpedo' then
					wepCategory = "Anti Navy"
				end
				if weapon.Label == 'QuantumBeamGeneratorWeapon' then
					wepCategory = "Direct"
				end
				if weapon.Label == 'ChinGun' then
					wepCategory = "Direct"
				end
				if LOUDFIND(weapon.Label, 'Melee') then
					wepCategory = "Melee"
				end
				
				-- Check if we're a Nuke weapon by checking our InnerRingDamage, which all Nukes must have.
				if weapon.NukeInnerRingDamage > 0 then
					wepCategory = "Nuke"
				end
				
				-- Now categories are established, we check which category we ended up using.
				
				-- Check if it's a death weapon.
				if wepCategory == "Crash" or wepCategory == "Volatile" or wepCategory == "Suicide" then
					
					-- Start the weaponText string with the weapon category.
					weaponText = wepCategory
					
					-- Check DamageFriendly and concat.
					if weapon.CollideFriendly ~= false or weapon.DamageRadius > 0 then
						weaponText = (weaponText .. " (FF)")
					end
					
					-- Concat damage.
					weaponText = (weaponText .. " { Dmg: " .. LOUD_ThouCheck(weapon.Damage))
					
					-- Check DamageRadius and concat.
					if weapon.DamageRadius > 0 then
						weaponText = (weaponText .. ", AoE: " .. LOUD_KiloCheck(weapon.DamageRadius * 20))
					end

					-- Finish text line.
					weaponText = (weaponText .. " }")

					-- Insert death weapon text line.
					table.insert(textLines, weaponText)
					
				-- Check if it's a nuke weapon.
				elseif wepCategory == "Nuke" then
				
					-- Check if this nuke is a Death nuke.
					if LOUDFIND(weapon.Label, "Death") then
						wepCategory = "Volatile"
						weaponText = wepCategory
					else
						weaponText = wepCategory
					end
					
					-- Check DamageFriendly and Buffs
					if weapon.CollideFriendly ~= false or (weapon.NukeInnerRingRadius > 0 and weapon.DamageFriendly ~= false) or weapon.Buffs ~= nil then
						weaponText = (weaponText .. " (")
						if weapon.Buffs then
							for i, buff in weapon.Buffs do
								bType = buff.BuffType
								if i == 1 then
									weaponText = (weaponText .. bType)
								else
									weaponText = (weaponText .. ", " .. bType)
								end
							end
						end
						if weapon.CollideFriendly ~= false or (weapon.NukeInnerRingRadius > 0 and weapon.DamageFriendly ~= false) then
							if weapon.Buffs then
								weaponText = (weaponText .. ", FF")
							else
								weaponText = (weaponText .. "FF")
							end
						end
						weaponText = (weaponText .. ")")
					end
					
					weaponText = (weaponText .. " { Inner Dmg: " .. LOUD_ThouCheck(weapon.NukeInnerRingDamage) .. ", AoE: " .. LOUD_KiloCheck(weapon.NukeInnerRingRadius * 20) .. " | Outer Dmg: " .. LOUD_ThouCheck(weapon.NukeOuterRingDamage) .. ", AoE: " .. LOUD_KiloCheck(weapon.NukeOuterRingRadius * 20))
					
					-- Finish text lines.
					weaponText = (weaponText .. " }")

					if weapon.NukeInnerRingDamage == lastWeaponNukeInDmg and weapon.NukeInnerRingRadius == lastWeaponNukeInRad  and weapon.NukeOuterRingDamage == lastWeaponNukeOutDmg and weapon.NukeOuterRingRadius == lastWeaponNukeOutRad and weapon.DamageFriendly == lastWeaponFF then
						dupWeaponCount = dupWeaponCount + 1
						-- Remove the old lines, to insert the new ones with the updated weapon count.
						table.remove(textLines, table.getn(textLines))
						table.insert(textLines, LOUDFORMAT("%s (x%d)", weaponText, dupWeaponCount))
					else
						dupWeaponCount = 1
						-- Insert the textLine.
						table.insert(textLines, weaponText)
					end
				else
					-- Start the weaponText string if we do damage.
					if weapon.Damage > 0.01 then
						
						-- Start the weaponText string with the weapon category.
						weaponText = wepCategory
						
						-- Check DamageFriendly and Buffs
						if wepCategory ~= " Defense" and wepCategory ~= "Melee" then
							if weapon.CollideFriendly ~= false or (weapon.DamageRadius > 0 and weapon.DamageFriendly ~= false) or weapon.Buffs ~= nil then
								weaponText = (weaponText .. " (")
								if weapon.Buffs then
									for i, buff in weapon.Buffs do
										bType = buff.BuffType
										if i == 1 then
											weaponText = (weaponText .. bType)
										else
											weaponText = (weaponText .. ", " .. bType)
										end
									end
								end
								if weapon.CollideFriendly ~= false or (weapon.DamageRadius > 0 and weapon.DamageFriendly ~= false) then
									if weapon.Buffs then
										weaponText = (weaponText .. ", FF")
									else
										weaponText = (weaponText .. "FF")
									end
								end
								weaponText = (weaponText .. ")")
							end
						
							-- Concat Damage. We don't check it here because we already checked it exists to get this far.
							weaponText = (weaponText .. " { Dmg: " .. LOUD_ThouCheck(weapon.Damage))
							
							-- Check PPF and concat.
							if weapon.ProjectilesPerOnFire > 1 then
								weaponText = (weaponText .. " (" .. tostring(weapon.ProjectilesPerOnFire) .. " Shots)")
							end
							
							-- Check DoTPulses and concat.
							if weapon.DoTPulses > 0 then
								weaponText = (weaponText .. " (" .. tostring(weapon.DoTPulses) .. " Hits)")
							end
							
							-- Concat DPS, calculated from PhxLib.
							weaponText = (weaponText .. ", DPS: " .. LOUD_ThouCheck(LOUDFLOOR(PhxLib.PhxWeapDPS(weapon).DPS + 0.5)))
						
							-- Check DamageRadius and concat.
							if weapon.DamageRadius > 0 then
								weaponText = (weaponText .. ", AoE: " .. LOUD_KiloCheck(weapon.DamageRadius * 20))
							end
						else
							if wepCategory == " Defense" then
								-- Display Countermeasure Targets as the weapon type.
								if weapon.TargetRestrictOnlyAllow then
									weaponText = (LOUD_TitleCase(weapon.TargetRestrictOnlyAllow) .. wepCategory)
								end
								
								-- If a weapon is a Countermeasure, we don't care about its damage or DPS, as it's all very small numbers purely for shooting projectiles.
								weaponText = (weaponText .. " {")

								-- Show RoF for Countermeasure weapons.
								if PhxLib.PhxWeapDPS(weapon).RateOfFire > 0 then
									weaponText = (weaponText .. " RoF: " .. LOUDFORMAT("%.2f", PhxLib.PhxWeapDPS(weapon).RateOfFire) .. "/s"):gsub("%.?0+$", "")
								end
							end
							-- Special case for Melee weapons, only showing Damage.
							if wepCategory == "Melee" then
								weaponText = (weaponText .. " { Dmg: " .. LOUD_ThouCheck(weapon.Damage))
							end
						end
						
						-- Check RateOfFire and concat.
						-- (NOTE: Commented out for now. DPS can infer ROF well enough and we have limited real-estate in the rollover box until someone figures out how to extend its width limit.)
						if PhxLib.PhxWeapDPS(weapon).RateOfFire > 0 then
						--	weaponText = (weaponText .. ", RoF: " .. LOUDFORMAT("%.2f", weapon.RateOfFire) .. "/s"):gsub("%.?0+$", "")
						end
						
						-- Check Min/Max Radius and concat.
						if weapon.MaxRadius > 0 then
							if weapon.MinRadius > 0 then
								weaponText = (weaponText .. ", Rng: " .. LOUD_KiloCheck(weapon.MinRadius * 20) .. "-" .. LOUD_KiloCheck(weapon.MaxRadius * 20))
							else
								weaponText = (weaponText .. ", Rng: " .. LOUD_KiloCheck(weapon.MaxRadius * 20))
							end
						end
						
						-- Finish text line.
						weaponText = (weaponText .. " }")

						-- Check duplicate weapons. We compare lots of values here, 
						-- any slight difference should be considered a different weapon. 
						if weapon.Damage == lastWeaponDmg and LOUDFLOOR(PhxLib.PhxWeapDPS(weapon).DPS + 0.5) == lastWeaponDPS and weapon.ProjectilesPerOnFire == lastWeaponPPOF and weapon.DoTPulses == lastWeaponDoT and weapon.DamageRadius == lastWeaponDmgRad and weapon.MinRadius == lastWeaponMinRad and weapon.MaxRadius == lastWeaponMaxRad and weapon.DamageFriendly == lastWeaponFF and PhxLib.PhxWeapDPS(weapon).RateOfFire == lastWeaponROF and weapon.CollideFriendly == lastWeaponCF and weapon.TargetRestrictOnlyAllow == lastWeaponTarget then
							dupWeaponCount = dupWeaponCount + 1
							-- Remove the old line, to insert the new one with the updated weapon count.
							table.remove(textLines, table.getn(textLines))
							table.insert(textLines, LOUDFORMAT("%s (x%d)", weaponText, dupWeaponCount))
						else
							dupWeaponCount = 1
							-- Insert the textLine.
							table.insert(textLines, weaponText)
						end
					end
				end
				
				-- Set lastWeapon stuff.
				lastWeaponDmg = weapon.Damage
				lastWeaponDPS = LOUDFLOOR(PhxLib.PhxWeapDPS(weapon).DPS + 0.5)
				lastWeaponPPOF = weapon.ProjectilesPerOnFire
				lastWeaponDoT = weapon.DoTPulses
				lastWeaponDmgRad = weapon.DamageRadius
				lastWeaponROF = PhxLib.PhxWeapDPS(weapon).RateOfFire
				lastWeaponMinRad = weapon.MinRadius
				lastWeaponMaxRad = weapon.MaxRadius
				lastWeaponFF = weapon.DamageFriendly
				lastWeaponCF = weapon.CollideFriendly
				lastWeaponTarget = weapon.TargetRestrictOnlyAllow
				lastWeaponNukeInDmg = weapon.NukeInnerRingDamage
				lastWeaponNukeInRad = weapon.NukeInnerRingRadius
				lastWeaponNukeOutDmg = weapon.NukeOuterRingDamage
				lastWeaponNukeOutRad = weapon.NukeOuterRingRadius
			end
		end
	end

	local weapon_end = table.getn(textLines)
	local physicsText = ""

	--Physics info
	if physics and physics.MotionType ~= 'RULEMT_None' then
		if physics.MotionType == 'RULEUMT_Air' then
			if air.MaxAirspeed ~= 0 then
				physicsText = ("Top Speed: " .. LOUD_SpeedCheck(air.MaxAirspeed))
				
				if air.TurnSpeed ~= 0 then
					physicsText = (physicsText .. ", Turn Speed: " .. LOUD_SpeedCheck(air.TurnSpeed))
				end
				if physics.FuelUseTime ~= 0 then
					physicsText = (physicsText .. ", Fuel Time: " .. LOUD_FuelCheck(physics.FuelUseTime))
				end
			end
			
			-- Insert the physics text into the table.
			table.insert(textLines, physicsText)
			-- Get the index of the physics text line from the textLines table.
			physics_line = table.getn(textLines)
		else
			if physics.MaxSpeed ~= 0 then
				physicsText = ("Top Speed: " .. LOUD_SpeedCheck(physics.MaxSpeed))
				
				if physics.MaxAcceleration ~= 0 then
					physicsText = (physicsText .. ", Acceleration: " .. LOUD_SpeedCheck(physics.MaxAcceleration))
				end
			end
			
			-- Insert the physics text into the table.
			table.insert(textLines, physicsText)
			-- Get the index of the physics text line from the textLines table.
			physics_line = table.getn(textLines)
		end
	end
	
	local intelText = ""
	
	-- Intel info
	if intel then
		if intel.VisionRadius ~= 0 then
			intelText = ("Vision: " .. LOUD_KiloCheck(intel.VisionRadius * 20))
		end
		if intel.RadarRadius ~= 0 then
			intelText = (intelText .. ", Radar: " .. LOUD_KiloCheck(intel.RadarRadius * 20))
		end
		if intel.SonarRadius ~= 0 then
			intelText = (intelText .. ", Sonar: " .. LOUD_KiloCheck(intel.SonarRadius * 20))
		end
		
		-- Insert the intel text into the table.
		table.insert(textLines, intelText)
		-- Get the index of the intel text line from the textLines table.
		intel_line = table.getn(textLines)
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
			control.Value[index]:SetColor('ff83d5e6')
			-- Text font size
			control.Value[index]:SetFont(UIUtil.bodyFont, 11)
		elseif index == intel_line then
			-- Intel text color
			control.Value[index]:SetColor('ff29757e')
			-- Text font size
			control.Value[index]:SetFont(UIUtil.bodyFont, 11)
		elseif index > weapon_start and index <= weapon_end then
			control.Value[index]:SetFont(UIUtil.bodyFont, 11)
			if LOUDFIND(tostring(v), "Direct") then	-- Direct Fire
				control.Value[index]:SetColor('ffff3333')
			elseif LOUDFIND(tostring(v), "Indirect") then -- Indirect Fire
				control.Value[index]:SetColor('ffffff00')
			elseif LOUDFIND(tostring(v), "Anti Navy") then -- Anti Navy
				control.Value[index]:SetColor('ff00ff00')
			elseif LOUDFIND(tostring(v), "Anti Air") then -- Anti Air
				control.Value[index]:SetColor('ff00ffff')
			elseif LOUDFIND(tostring(v), " Defense") then -- Countermeasure
				control.Value[index]:SetColor('ffffa500')
			elseif LOUDFIND(tostring(v), "Nuke") then -- Nuke
				control.Value[index]:SetColor('ffffa500')
			elseif LOUDFIND(tostring(v), "Crash") then -- Air Crash
				control.Value[index]:SetColor('ffb077ff')
			elseif LOUDFIND(tostring(v), "Volatile") then -- Volatile
				control.Value[index]:SetColor('ffb077ff')
			elseif LOUDFIND(tostring(v), "Suicide") then -- Kamikaze/Suicide
				control.Value[index]:SetColor('ffb077ff')
			elseif LOUDFIND(tostring(v), "Melee") then	-- Melee
				control.Value[index]:SetColor('ffff3333')
			else
				control.Value[index]:SetColor('ff909090')
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
		
		if bp.General.UnitName ~= nil then
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
		
		if buildingUnit ~= nil then
		
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
			WrapAndPlaceText(bp.Air, bp.Physics, bp.Intel, bp.Weapon, bp.Display.Abilities, LOC(UnitDescriptions[bpID]), View.Description)
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
	
	if upkeepEnergy ~= 0 or upkeepMass ~= 0 then
	
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
		
	elseif bp.Economy and (bp.Economy.StorageEnergy ~= 0 or bp.Economy.StorageMass ~= 0) then
	
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