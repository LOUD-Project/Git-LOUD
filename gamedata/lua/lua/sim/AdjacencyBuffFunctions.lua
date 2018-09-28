---  /lua/sim/AdjacencyBuffFunctions.lua

local LOUDENTITY = EntityCategoryContains
local LOUDEMPTY = table.empty
local LOUDGETN = table.getn

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
    return not LOUDEMPTY(__blueprints[unit.BlueprintID].Economy.BuildableCategory)
	
end

BuildBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects( instigator)
	
end

BuildBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect( instigator)
	
end


-- Energy Maintenance Bonus
-- usually shields, radar and other structures which constantly consume energy
EnergyMaintenanceBuffCheck = function(buff, unit)

    if __blueprints[unit.BlueprintID].Economy.MaintenanceConsumptionPerSecondEnergy or unit.EnergyMaintenanceConsumptionOverride then
	
        return true
		
    end
	
    return false
	
end

EnergyMaintenanceBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

EnergyMaintenanceBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
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

EnergyWeaponBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

EnergyWeaponBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end

-- Weapon Rate of Fire -- for energy using weapons
RateOfFireBuffCheck = function(buff, unit)

    return unit:GetWeaponCount() > 0
	
end

RateOfFireBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

RateOfFireBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end

-- Shield Regeneration -- this is new with LOUDAI
ShieldRegenBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Defense.Shield.ShieldRegenRate > 0
	
end

ShieldRegenBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

ShieldRegenBuffAffect = function(buff, unit, instigator)

	unit:CreateAdjacentEffect(instigator)
	
end

-- Shield Size -- also new with LOUDAI
ShieldSizeBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Defense.Shield.ShieldSize > 0
	
end

ShieldSizeBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

ShieldSizeBuffAffect = function(buff, unit, instigator)

	unit:CreateAdjacentEffect(instigator)
	
end

-- Shield Health -- also new with LOUDAI
ShieldHealthBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Defense.Shield.ShieldMaxHealth > 0
end

ShieldHealthBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

ShieldHealthBuffAffect = function(buff, unit, instigator)

	unit:CreateAdjacentEffect(instigator)
	
end

-- Energy Production -- for any energy producing structure
EnergyProductionBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Economy.ProductionPerSecondEnergy > 0
	
end

EnergyProductionBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

EnergyProductionBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end

-- Mass Production - any mass producing structure
MassProductionBuffCheck = function(buff, unit)

	return __blueprints[unit.BlueprintID].Economy.ProductionPerSecondMass > 0
	
end

MassProductionBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

MassProductionBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end