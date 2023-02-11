--LOG("*AI DEBUG loading BO Icon Search")

EXIconPaths = {}
EXIconPathOverwrites = {}
EXUnitIconTemp = nil
EXUpgradeIconPaths = {}
EXUpgradeIconOverwrites = {}
EXNoIconLogSpamControl = {}
EXUpgradeIconTemp = nil

function BlackopsBlueprintLocator()

    EXBuildIconReferenceTables()

end

function EXUnitIconPathCondensor(EXIconID)

	local EXIconID = EXIconID
	
	if string.find(EXIconID, '/', 1) then
	
		EXIconID = string.sub(EXIconID, string.find(EXIconID, '/', 1), string.len(EXIconID))
		EXIconID = string.gsub(EXIconID,'/','',1)
		EXUnitIconTemp = EXIconID
		EXUnitIconPathCondensor(EXIconID)
		
	else
	
		return EXUnitIconTemp
		
	end
	
end

function EXUpgradeIconPathCondensor(EXUIconID)

	local EXUIconID = EXUIconID
	
	if string.find(EXUIconID, '/', 1) then
	
		EXUIconID = string.sub(EXUIconID, string.find(EXUIconID, '/', 1), string.len(EXUIconID))
		EXUIconID = string.gsub(EXUIconID,'/','',1)
		EXUpgradeIconTemp = EXUIconID
		EXUpgradeIconPathCondensor(EXUIconID)
		
	else
	
		return EXUpgradeIconTemp
		
	end
	
end

function EXBuildIconReferenceTables()

    for id, mod in __active_mods do
    
        LOG("*AI DEBUG EXBuildIconReferenceTable for "..repr(mod.location))
	
		-- Icon hunt script locates all icon DDS files in the active mod directories
        local LocatedIcons = DiskFindFiles(mod.location, '*_icon.dds')
		
        for id, icon in LocatedIcons do
			-- Converts results of the icon hunt into location tables referenced by other scripts
            EXIconID = string.gsub(icon, '_icon.dds', '')
            EXIconPath = EXIconID
            EXUnitIconPathCondensor(EXIconID)
            EXIconID = EXUnitIconTemp
            EXIconID = string.upper(EXIconID)
			EXIconPath = string.sub(EXIconPath, 0, (string.len(EXIconPath) - string.len(EXIconID)))
            EXIconPaths[EXIconID] = EXIconPath
        end
		
        local LocatedIcons = DiskFindFiles(mod.location, '*_btn_up.dds')
		
        for id2, upgrades in LocatedIcons do
		
			-- Converts results of the icon hunt into location tables referenced by other scripts
            EXUIconID = string.gsub(upgrades, '_btn_up.dds', '')
            EXUIconPath = EXUIconID
            EXUpgradeIconPathCondensor(EXUIconID)
            EXUIconID = EXUpgradeIconTemp
            EXUIconID = string.upper(EXUIconID)
			EXUIconPath = string.sub(EXUIconPath, 0, (string.len(EXUIconPath) - string.len(EXUIconID)))
			
			if string.find(EXUIconPath, 'uef\-', 1) then
			
				EXUIconID = EXUIconID..'U'
				EXUpgradeIconPaths[EXUIconID] = EXUIconPath
				
			elseif string.find(EXUIconPath, 'aeon\-', 1) then
			
				EXUIconID = EXUIconID..'A'
				EXUpgradeIconPaths[EXUIconID] = EXUIconPath
				
			elseif string.find(EXUIconPath, 'cybran\-', 1) then
			
				EXUIconID = EXUIconID..'C'
				EXUpgradeIconPaths[EXUIconID] = EXUIconPath
				
			elseif string.find(EXUIconPath, 'seraphim\-', 1) then
			
				EXUIconID = EXUIconID..'S'
				EXUpgradeIconPaths[EXUIconID] = EXUIconPath
				
			end
			
        end
		
    end
	
	for k, v in __blueprints do
	
		-- Runs a quick scan of all blueprints sorting to just blueprints with 7 digit names
		-- key: k = unitid, v = bp
		if string.len(k) == 7 then
		
			if v.Display.AlternateIconPath then
			
				-- Tables icons selected for manual overwrite so the game knows where to check for them
				EXAltIcon = v.BlueprintId
				EXAltIcon = string.upper(EXAltIcon)
				
				if DiskGetFileInfo(v.Display.AlternateIconPath..EXAltIcon..'_icon.dds') then
				
					EXIconPathOverwrites[EXAltIcon] = v.Display.AlternateIconPath
					
				else
				
					WARN('Blackops Icon Mod: Alternate Unit Icon Path Not Valid - '..EXAltIcon)
					
				end
				
			end
			
			if v.Display.AlternateUpgradeIconPath then
			
				-- Tables enhancement icons selected for manual overwrite so the game knows where to check for them
				EXAltUpgrade = v.BlueprintId
				EXAltUpgrade = string.upper(EXAltUpgrade)
				EXUpgradeIconOverwrites[EXAltUpgrade] = v.Display.AlternateUpgradeIconPath
				
			end
			
		end
		
	end
	
	LOG('Blackops Icon Support Mod - Icon Location Complete')

end

function GetCustomIconLocation(unitID)

    unitID = string.upper(unitID)
	
    if not BlueprintList[unitID] then

		WARN('Blackops Support Alert: '.. unitID ..' is not a modded unit')
        return ''
		
    else
	
        return BlueprintLocations[unitID]
		
    end
	
end

function EXIconTableScan(unitID)

    unitID = string.upper(unitID)
	
    return EXIconPaths[unitID]
	
end

function EXIconTableScanOverwrites(unitID)

    unitID = string.upper(unitID)
	
    return EXIconPathOverwrites[unitID]
	
end

function EXUpgradeIconTableOverwrites(unitID)

    unitID = string.upper(unitID)
	
    return EXUpgradeIconOverwrites[unitID]
	
end

function EXUpgradeIconTableScan(unitID)

    unitID = string.upper(unitID)
	
    return EXUpgradeIconPaths[unitID]
	
end

function EXBlueprintScanner()

	for k, v in __blueprints do
	
		-- Runs a quick scan of all blueprints sorting to just blueprints with 7 digit names
		-- key: k = unitid, v = bp
		if string.len(k) == 7 then
			-- Basics
			EXunitID = 0
			EXunitName = 0
			EXunitType = 0
			EXunitFaction = 0
			-- Economy
			EXEnergyCost = 0
			EXMassCost = 0
			EXBT = 0
			-- Defense
			EXHealth = 0
			EXRegen = 0
			EXShieldHealth = 0
			EXShieldRegen = 0
			-- Intel
			EXVision = 0
			EXRadar = 0
			EXSonar = 0
			EXOmni = 0
			
			--LOG(v.BlueprintId)
			
			if v.BlueprintId then
				EXunitID = v.BlueprintId
			end
			
			if v.General.UnitName and string.find(v.General.UnitName, '>', 1) then
			
				EXunitName = v.General.UnitName
				EXunitName = string.sub(EXunitName, string.find(EXunitName, '>', 1), string.len(EXunitName))
				EXunitName = string.gsub(EXunitName,'>','',1)
				
			elseif v.General.UnitName and not string.find(v.General.UnitName, '>', 1) then
			
				EXunitName = v.General.UnitName
				
			end
			
			if v.Description and string.find(v.Description, '>', 1) then
			
				EXunitType = v.Description
				EXunitType = string.sub(EXunitType, string.find(EXunitType, '>', 1), string.len(EXunitType))
				EXunitType = string.gsub(EXunitType,'>','',1)
				
			elseif v.Description and not string.find(v.Description, '>', 1) then
			
				EXunitType = v.Description
				
			end
			
			if v.General.FactionName then
			
				EXunitFaction = v.General.FactionName
				
			end
			
			if v.Economy.BuildCostEnergy then
			
				EXEnergyCost = v.Economy.BuildCostEnergy
				
			end
			
			if v.Economy.BuildCostMass then
			
				EXMassCost = v.Economy.BuildCostMass
				
			end
			
			if v.Economy.BuildTime then
			
				EXBT = v.Economy.BuildTime
				
			end
			
			if v.Defense.MaxHealth then
			
				EXHealth = v.Defense.MaxHealth
				
			end
			
			if v.Defense.RegenRate then
			
				EXRegen = v.Defense.RegenRate
				
			end
			
			if v.Defense.Shield.ShieldMaxHealth then
			
				EXShieldHealth = v.Defense.Shield.ShieldMaxHealth
				
			end
			
			if v.Defense.Shield.ShieldRegenRate then
			
				EXShieldRegen = v.Defense.Shield.ShieldRegenRate
				
			end
			
			if v.Intel.VisionRadius then
			
				EXVision = v.Intel.VisionRadius
				
			end
			
			if v.Intel.RadarRadius then
			
				EXRadar = v.Intel.RadarRadius
				
			end
			
			if v.Intel.SonarRadius then
			
				EXSonar = v.Intel.SonarRadius
				
			end
			
			if v.Intel.OmniRadius then
			
				EXOmni = v.Intel.OmniRadius
				
			end
			
			WARN(':'..EXunitID..':'..EXunitName..':'..EXunitType..':'..EXunitFaction..':'..EXEnergyCost..':'..EXMassCost..':'..EXBT..':'..EXHealth..':'..EXRegen..':'..EXShieldHealth..':'..EXShieldRegen..':'..EXVision..':'..EXRadar..':'..EXSonar..':'..EXOmni)
			
		end
		
	end
end
