---  File     :  /lua/game.lua
---  Summary  : Script full of overall game functions
---  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

VeteranDefault = {
    Level1 = 25,
    Level2 = 100,
    Level3 = 250,
    Level4 = 500,
    Level5 = 1000,
}

SpecialWepRestricted = false
UnitCatRestricted = false

_UnitRestricted_cache = {}
_UnitRestricted_unitchecked = {}
_UnitRestricted_checked = false

doscript('/lua/BuffFieldDefinitions.lua')

BrewLANLOUDPath = function()
    for i, mod in __active_mods do
        if mod.uid == "25D57D85-7D84-27HT-A501-BR3WL4N000079" then
            return mod.location
        end
    end 
end

BrewLANPath = function()
    for i, mod in __active_mods do
        if mod.uid == "25D57D85-7D84-27HT-A501-BR3WL4N000079" then
            return mod.location
        end
    end 
end

-- Return the total time (in seconds), energy, and mass it will take for the given
-- builder to create a unit of type target_bp.
--
-- targetData may also be an "Enhancement" section of a unit's blueprint rather than
-- a full blueprint.
function GetConstructEconomyModel(builder, targetData)

    local builder_bp = __blueprints[builder.BlueprintID]
    
    -- 'rate' here is how fast we build relative to a unit with build rate of 1
    local rate = builder:GetBuildRate()

    local time = targetData.BuildTime
    local mass = targetData.BuildCostMass
    local energy = targetData.BuildCostEnergy

    -- apply penalties/bonuses to effective time
    local time_mod = builder.BuildTimeModifier or 0
	
    time = time * (100 + time_mod) * .01

    -- apply penalties/bonuses to effective energy cost
    local energy_mod = builder.EnergyModifier or 0
	
    energy = energy * (100 + energy_mod) * .01
	
    if energy<0 then
		energy = 0
	end

    -- apply penalties/bonuses to effective mass cost
    local mass_mod = builder.MassModifier or 0
	
    mass = mass * (100 + mass_mod)*.01
	
    if mass<0 then
		mass = 0
	end
	
	-- from BrewLAN - accounting for discounted upgrade costs
	-- this allows marking a blueprint so that you pay normal costs if directly built
	-- or discounted costs if the building is being upgraded from something else
	
	-- JAN 2019 - while this code affects the visual costs of the upgrade - it does NOT impact the actual costs from what I can see.
	-- originally - even in the absence of the trigger variables - it was calculating a 50% discount - I made that no discout
    if builder_bp.BlueprintId == targetData.HalfPriceUpgradeFromID or builder_bp.General.UpgradesTo == targetData.HalfPriceUpgradeFromID or builder_bp.Economy.BuilderDiscountMult then
	
        local discount = targetData.UpgradeFromCostDiscount or builder_bp.Economy.BuilderDiscountMult or 1.0	-- if the discount is not specified then no discount is applied
		
		energy = energy * discount
		mass = mass * discount
	
	end
	
    return time/rate, energy, mass
end

function UnitRestricted(unit, unitId)

    if ScenarioInfo.Options.RestrictedCategories then     -- if restrictions defined
	
		if unit then
			unitId = unit.BlueprintID
		end

		if _UnitRestricted_cache[unitId] then          -- use cache if available

			return true
		end
		
		if not _UnitRestricted_unitchecked[unitId] then

			CacheRestrictedUnitLists()
		
			for k, cat in UnitCatRestricted do
	
				if EntityCategoryContains( cat, unitId ) then   -- because of this function we need the unit, not the unitId

					_UnitRestricted_cache[unitId] = true
			
					break
				end
			end
			
			_UnitRestricted_unitchecked[unitId] = true

			return _UnitRestricted_cache[unitId]
		
		end
	else
	
		return false
		
	end
	
end

function WeaponRestricted(weaponLabel)

    if not CheckUnitRestrictionsEnabled() then     -- if no restrictions defined then dont bother
        return false
    end
	
    CacheRestrictedUnitLists()
	
    return SpecialWepRestricted[weaponLabel]
end


function NukesRestricted()
    return WeaponRestricted('StrategicMissile')
end


function TacticalMissilesRestricted()
    return WeaponRestricted('TacticalMissile')
end


function CheckUnitRestrictionsEnabled()
    -- tells you whether unit restrictions are enabled
    if ScenarioInfo.Options.RestrictedCategories then return true end
    return false
end

-- modified to make use of a global -- _UnitRestricted_checked
-- which avoids continually rebuilding the restricted units list
-- however - anytime a restriction is added or removed during the
-- game, this global must be reset so that the list can be rebuilt
function CacheRestrictedUnitLists()

	if _UnitRestricted_checked then
		return
	end

    if type(UnitCatRestricted) == 'table' then
        return
    end

    SpecialWepRestricted = {}
    UnitCatRestricted = {}
	
	LOG("*AI DEBUG CacheRestrictedUnitLists")
	
    local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
    local c

    -- loop through enabled restrictions
    for k, restriction in ScenarioInfo.Options.RestrictedCategories do 

        -- create a list of all unit category restrictions. TO be clear, this results in a table of categories
        -- So, for example:   { categories.TECH1, categories.TECH2, categories.MASSFAB }
        if restrictedUnits[restriction].categories then
		
            for l, cat in restrictedUnits[restriction].categories do
			
                c = cat
				
                if type(c) == 'string' then
					c = ParseEntityCategory(c)
				end
				
                table.insert( UnitCatRestricted, c )
            end
        end

        -- create a list of restricted special weapons (nukes, tactical missiles)
        if restrictedUnits[restriction].specialweapons then   
            for l, cat in restrictedUnits[restriction].specialweapons do

                -- strategic missiles
                if cat == 'StrategicMissile' or cat == 'strategicmissile' or cat == 'sm' or cat == 'SM' then
                    SpecialWepRestricted['StrategicMissile'] = true

                -- tactical missiles
                elseif cat == 'TacticalMissile' or cat == 'tacticalmissile' or cat == 'tm' or cat == 'TM' then
                    SpecialWepRestricted['TacticalMissile'] = true

                -- mod added weapons
                else
                    SpecialWepRestricted[cat] = true
                end
            end
        end
    end
	
	_UnitRestricted_checked = true
end