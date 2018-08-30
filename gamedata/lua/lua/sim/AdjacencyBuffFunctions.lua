---  /lua/sim/AdjacencyBuffFunctions.lua

local LOUDENTITY = EntityCategoryContains
local LOUDGETN = table.getn

local GetBlueprint = moho.entity_methods.GetBlueprint

local GetWeapon = moho.unit_methods.GetWeapon
local GetWeaponCount = moho.unit_methods.GetWeaponCount


DefaultBuffRemove = function(buff, unit, instigator)

    unit:DestroyAdjacentEffects( instigator )
	
end

DefaultBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect( instigator )
	
end

-- Energy Build Bonus - Energy Active Consumption
-- for factories - reduces energy consumption when active
EnergyBuildBuffCheck = function(buff, unit)

    local bp = GetBlueprint(unit)
	
    if bp.Economy.BuildableCategory then
	
        return true
		
    end
	
	-- Silos no longer get this bonus
    --if LOUDENTITY(categories.SILO, unit) and LOUDENTITY(categories.STRUCTURE, unit) then
        --return true
    --end
	
    return false
	
end

EnergyBuildBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects( instigator)
	
end

EnergyBuildBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect( instigator)
	
end

-- Mass Build Bonus - Mass Active Consumption
-- for factories - reduces mass consumption when active
MassBuildBuffCheck = function(buff, unit)

	local bp = GetBlueprint(unit)
	
    if bp.Economy.BuildableCategory then
	
        return true
		
    end
	
	-- Silos no longer get this bonus
    --if LOUDENTITY(categories.SILO, unit) and LOUDENTITY(categories.STRUCTURE, unit) then
        --return true
    --end
	
    return false
	
end

MassBuildBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

MassBuildBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end

-- Energy Maintenance Bonus
-- usually shields, radar and other structures which constantly consume energy
EnergyMaintenanceBuffCheck = function(buff, unit)

    if GetBlueprint(unit).Economy.MaintenanceConsumptionPerSecondEnergy or unit.EnergyMaintenanceConsumptionOverride then
	
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

	return GetBlueprint(unit).Defense.Shield.ShieldRegenRate > 0
	
end

ShieldRegenBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

ShieldRegenBuffAffect = function(buff, unit, instigator)

	unit:CreateAdjacentEffect(instigator)
	
end

-- Shield Size -- also new with LOUDAI
ShieldSizeBuffCheck = function(buff, unit)

	return GetBlueprint(unit).Defense.Shield.ShieldSize > 0
	
end

ShieldSizeBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

ShieldSizeBuffAffect = function(buff, unit, instigator)

	unit:CreateAdjacentEffect(instigator)
	
end

-- Shield Health -- also new with LOUDAI
ShieldHealthBuffCheck = function(buff, unit)

	return GetBlueprint(unit).Defense.Shield.ShieldMaxHealth > 0
end

ShieldHealthBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

ShieldHealthBuffAffect = function(buff, unit, instigator)

	unit:CreateAdjacentEffect(instigator)
	
end

-- Energy Production -- for any energy producing structure
EnergyProductionBuffCheck = function(buff, unit)

	return GetBlueprint(unit).Economy.ProductionPerSecondEnergy > 0
	
end

EnergyProductionBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

EnergyProductionBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end

-- Mass Production - any mass producing structure
MassProductionBuffCheck = function(buff, unit)

	return GetBlueprint(unit).Economy.ProductionPerSecondMass > 0
	
end

MassProductionBuffRemove = function(buff, unit, instigator)

	unit:DestroyAdjacentEffects(instigator)
	
end

MassProductionBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect(instigator)
	
end