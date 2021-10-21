---  /lua/sim/AdjacencyBuffFunctions.lua

--local LOUDENTITY = EntityCategoryContains
--local LOUDEMPTY = table.empty

local GetWeapon = moho.unit_methods.GetWeapon
local GetWeaponCount = moho.unit_methods.GetWeaponCount


DefaultBuffRemove = function(buff, unit, instigator)

    unit:DestroyAdjacentEffects( instigator )

end

DefaultBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect( instigator )

end

WaterVisionBuffCheck = function( buff, unit )

	return __blueprints[unit.BlueprintID].Intel.WaterVisionRadius > 1

end

RadarRadiusBuffCheck = function( buff, unit )

	return __blueprints[unit.BlueprintID].Intel.RadarRadius > 1

end

SonarRadiusBuffCheck = function( buff, unit )

	return __blueprints[unit.BlueprintID].Intel.SonarRadius > 1

end

OmniRadiusBuffCheck = function( buff, unit )

	return __blueprints[unit.BlueprintID].Intel.OmniRadius > 1

end

BuildRateBuffCheck = function( buff, unit )

	-- while not technically true - the engine gives ALL units a buildrate of 1, even if not specified
	return __blueprints[unit.BlueprintID].Economy.BuildRate > 1

end

-- for factories - reduces mass and energy consumption when active
BuildBuffCheck = function(buff, unit)

	-- we have to test this since the engine gives ALL units an empty BuildableCategory table
    -- and this mechanism does not pickup structures with enhancements --
    -- return not LOUDEMPTY(__blueprints[unit.BlueprintID].Economy.BuildableCategory)
    
    -- so lets make the check simple - do you have build power ?
    return BuildRateBuffCheck( buff,unit)

end

--------------------------------------------------------------------------------
-- Legacy functions
--------------------------------------------------------------------------------
EnergyBuildBuffCheck = function(buff, unit)
    return BuildBuffCheck(buff, unit)
end

EnergyBuildBuffRemove = function(buff, unit, instigator)
    return DefaultBuffRemove(buff, unit, instigator)
end

EnergyBuildBuffAffect = function(buff, unit, instigator)
    return DefaultBuffAffect(buff, unit, instigator)
end

MassBuildBuffCheck = function(buff, unit)
    return BuildBuffCheck(buff, unit)
end

MassBuildBuffRemove = function(buff, unit, instigator)
    return DefaultBuffRemove(buff, unit, instigator)
end

MassBuildBuffAffect = function(buff, unit, instigator)
    return DefaultBuffAffect(buff, unit, instigator)
end
--------------------------------------------------------------------------------

EnergyMaintenanceBuffCheck = function(buff, unit)

    if __blueprints[unit.BlueprintID].Economy.MaintenanceConsumptionPerSecondEnergy or unit.EnergyMaintenanceConsumptionOverride then

        return true

    end

    return false

end

EnergyStorageBuffCheck = function(buff, unit)

    if __blueprints[unit.BlueprintID].Economy.StorageEnergy > 0 then

        return true

    end

	return false

end

-- Energy Weapon Bonus
-- intended for energy consuming weapons
-- weapon must have EnergyRequired parameter
EnergyWeaponBuffCheck = function(buff, unit)

    for i = 1, GetWeaponCount(unit) do

        if GetWeapon( unit, i ):WeaponUsesEnergy() then

            return true

        end

    end

    return false

end

-- Weapon Rate of Fire -- for energy using weapons
-- this is difficult since many energy using weapons have their
-- RoF controlled by the charge cycle - and not by RoF
-- so changing RoF has, in most cases, no impact
RateOfFireBuffCheck = function(buff, unit)

    return EnergyWeaponBuffCheck( buff,unit)

end

-- Shield Regeneration -- this is new with LOUDAI
ShieldRegenBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Defense.Shield.ShieldRegenRate > 0

end

-- Shield Size -- also new with LOUDAI
ShieldSizeBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Defense.Shield.ShieldSize > 0

end

-- Shield Health -- also new with LOUDAI
ShieldHealthBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Defense.Shield.ShieldMaxHealth > 0
end

-- Energy Production -- for any energy producing structure
EnergyProductionBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Economy.ProductionPerSecondEnergy > 0

end

-- Mass Production - any mass producing structure
MassProductionBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Economy.ProductionPerSecondMass > 0

end

MassStorageBuffCheck = function(buff, unit)

    if __blueprints[unit.BlueprintID].Economy.StorageMass > 0 then

        return true

    end

	return false

end
