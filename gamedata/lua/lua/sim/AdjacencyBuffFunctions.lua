---  /lua/sim/AdjacencyBuffFunctions.lua

local GetWeapon         = moho.unit_methods.GetWeapon
local GetWeaponCount    = moho.unit_methods.GetWeaponCount


DefaultBuffRemove = function(buff, unit, instigator)

    unit:DestroyAdjacentEffects( instigator )

end

DefaultBuffAffect = function(buff, unit, instigator)

    unit:CreateAdjacentEffect( instigator )

end

WaterVisionBuffCheck = function( buff, unit, bp, instigator )

	return bp.Intel.WaterVisionRadius >= 1

end

RadarRadiusBuffCheck = function( buff, unit, bp, instigator )

	return bp.Intel.RadarRadius >= 1

end

SonarRadiusBuffCheck = function( buff, unit, bp, instigator )

	return bp.Intel.SonarRadius >= 1

end

OmniRadiusBuffCheck = function( buff, unit, bp, instigator )

	return bp.Intel.OmniRadius >= 1

end

BuildRateBuffCheck = function( buff, unit, bp, instigator )

	-- while not technically true - the engine gives ALL units a buildrate of 1, even if not specified
	return bp.Economy.BuildRate > 1

end

-- for factories - reduces mass and energy consumption when active
BuildBuffCheck = function( buff, unit, bp, instigator )

	-- we have to test this since the engine gives ALL units an empty BuildableCategory table
    -- and this mechanism does not pickup structures with enhancements --
    -- return not LOUDEMPTY(bp.Economy.BuildableCategory)
    
    -- so lets make the check simple - do you have build power ?
    return BuildRateBuffCheck( buff, unit, bp, instigator )

end


-- Legacy functions --

EnergyBuildBuffCheck = function( buff, unit, bp, instigator )
    return BuildBuffCheck(buff, unit, bp, instigator)
end

EnergyBuildBuffRemove = function(buff, unit, bp, instigator)
    return DefaultBuffRemove(buff, unit, bp, instigator)
end

EnergyBuildBuffAffect = function(buff, unit, bp, instigator)
    return DefaultBuffAffect(buff, unit, bp, instigator)
end

MassBuildBuffCheck = function( buff, unit, bp, instigator )
    return BuildBuffCheck(buff, unit, bp, instigator)
end

MassBuildBuffRemove = function(buff, unit, bp, instigator)
    return DefaultBuffRemove(buff, unit, bp, instigator)
end

MassBuildBuffAffect = function(buff, unit, bp, instigator)
    return DefaultBuffAffect(buff, unit, bp, instigator)
end


EnergyMaintenanceBuffCheck = function( buff, unit, bp, instigator )

    if bp.Economy.MaintenanceConsumptionPerSecondEnergy or unit.EnergyMaintenanceConsumptionOverride then

        return true

    end

    return false

end

EnergyStorageBuffCheck = function( buff, unit, bp, instigator )

    if bp.Economy.StorageEnergy > 0 then

        return true

    end

	return false

end

-- Energy Weapon Bonus -- intended for energy consuming weapons
-- weapon must have EnergyRequired parameter
EnergyWeaponBuffCheck = function( buff, unit, bp, instigator )

    for i = 1, GetWeaponCount(unit) do

        if GetWeapon( unit, i ):WeaponUsesEnergy() then

            return true

        end

    end

    return false

end

-- Weapon Rate of Fire -- for energy using weapons
-- this is difficult since many energy using weapons have their RoF controlled by the charge cycle
-- and not by RoF -changing RoF has, in most cases, no impact
RateOfFireBuffCheck = function( buff, unit, bp, instigator )

    return EnergyWeaponBuffCheck( buff, unit, bp, instigator )

end

ShieldRegenBuffCheck = function( buff, unit, bp, instigator )

	return bp.Defense.Shield.ShieldRegenRate > 0

end

ShieldSizeBuffCheck = function( buff, unit, bp, instigator )

	return bp.Defense.Shield.ShieldSize > 0

end

ShieldHealthBuffCheck = function( buff, unit, bp, instigator )

	return bp.Defense.Shield.ShieldMaxHealth > 0
end

EnergyProductionBuffCheck = function( buff, unit, bp, instigator )

	return bp.Economy.ProductionPerSecondEnergy > 0

end

MassProductionBuffCheck = function( buff, unit, bp, instigator )

	return bp.Economy.ProductionPerSecondMass > 0

end

MassStorageBuffCheck = function( buff, unit, bp, instigator )

    if bp.Economy.StorageMass > 0 then

        return true

    end

	return false

end
