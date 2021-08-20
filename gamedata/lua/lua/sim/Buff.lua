--**  File     :  /lua/sim/buff.lua
--**  Copyright � 2008 Gas Powered Games, Inc.  All rights reserved.

local WaitTicks = coroutine.yield
local LOUDENTITY = EntityCategoryContains
local LOUDPARSE = ParseEntityCategory
local LOUDEMPTY = table.empty

local GetBlueprint = moho.entity_methods.GetBlueprint

local AdjustHealth = moho.entity_methods.AdjustHealth
local GetHealth = moho.unit_methods.GetHealth
local GetMaxHealth = moho.entity_methods.GetMaxHealth
local SetHealth = moho.entity_methods.SetHealth
local SetMaxHealth = moho.entity_methods.SetMaxHealth
local SetShieldRatio = moho.unit_methods.SetShieldRatio

local GetAIBrain = moho.unit_methods.GetAIBrain
local GetFuelRatio = moho.unit_methods.GetFuelRatio
local SetFuelRatio = moho.unit_methods.SetFuelRatio

local SetRegenRate = moho.unit_methods.SetRegenRate

local SetAccMult = moho.unit_methods.SetAccMult
local SetSpeedMult = moho.unit_methods.SetSpeedMult
local SetTurnMult = moho.unit_methods.SetTurnMult

local SetBuildRate = moho.unit_methods.SetBuildRate

local DisableIntel = moho.entity_methods.DisableIntel
local EnableIntel = moho.entity_methods.EnableIntel
local SetIntelRadius = moho.entity_methods.SetIntelRadius

local RequestRefreshUI = moho.entity_methods.RequestRefreshUI

-- The Unit's BuffTable for applied buffs looks like this:
--
-- Unit.Buffs = {
--    Affects = {
--        <AffectType (Regen/MaxHealth/etc)> = {
--            BuffName = {
--                Count = i,
--                Add = X,
--                Mult = X,
--            }
--        }
--    }
--    BuffTable = {
--        <BuffType (LEVEL/CATEGORY)> = {
--            BuffName = {
--                Count = i,
--                Trash = trashbag,
--            }
--        }
--    }

-- Function to apply a buff to a unit.
-- This function is a fire-and-forget.  Apply this and it'll be applied over time if there is a duration.
function ApplyBuff(unit, buffName, instigator)

    if not unit or unit.Dead or not unit.Buffs.BuffTable then
        return
    end

    local def = Buffs[buffName]

    if not def then
        error("*ERROR: Tried to add a buff that doesn\'t exist! Name: ".. buffName, 2)
        return
    end

    if def.EntityCategory and not def.ParsedEntityCategory then
        def.ParsedEntityCategory = LOUDPARSE(def.EntityCategory)
    end

    if def.ParsedEntityCategory then

		if not LOUDENTITY( def.ParsedEntityCategory, unit ) then
			return
        end

    end

	-- in this new version we can now have a check at the definition level
	-- and at the individual affects level
    if def.BuffCheckFunction then

        if not def:BuffCheckFunction(unit) then
            return
        end

    end

    local ubt = unit.Buffs.BuffTable

    if def.Stacks == 'REPLACE' and ubt[def.BuffType] then

        for key, bufftbl in unit.Buffs.BuffTable[def.BuffType] do

            RemoveBuff(unit, key, true)

        end
    end

	-- if the unit already has this bufftype then ignore it
    if def.Stacks == 'IGNORE' and ubt[def.BuffType] and not table.empty(ubt[def.BuffType]) then
        return
    end
	
	local newbuff = false

    local data = ubt[def.BuffType][buffName]


    if not data then

        -- This is a new buff (as opposed to an additional one being stacked)
		data = { Count = 0, Trash = TrashBag() }
		
		newbuff = true

    end

    local uaffects = unit.Buffs.Affects
	
	if ScenarioInfo.BuffDialog then

		LOG("*AI DEBUG Applying "..buffName.." to "..repr(unit:GetBlueprint().Description).." "..unit.Sync.id )
		
	end

    if def.Affects then
    
        local buffcheck = true

        for k,v in def.Affects do

			buffcheck = true

			-- this new feature allows us to check individual parts of a multi-stage buff
			-- so that we only store those buffs which actually affect a given unit
			-- this can save a lot of data since with AI buffs, units were having buffs
			-- applied which actually didn't do anything
			-- while we process more up front, we save data, and process less on the buff
			-- removal stage
			if v.BuffCheckFunction then

				if not v:BuffCheckFunction(unit) then

					buffcheck = false

					continue

				end

			end

            -- Don't save off 'instant' type affects like health and energy or those that fail a buff check function
            if buffcheck and k != 'Health' and k != 'Energy' and k != 'FuelRatio' then

				data.Count = data.Count + 1

                if not uaffects[k] then
                    uaffects[k] = {}
                end

                if not uaffects[k][buffName] then

                    -- This is a new affect.
                    local affectdata = {  Count = 1, }

                    for buffkey, buffval in v do

						if buffkey != 'BuffCheckFunction' then

							affectdata[buffkey] = buffval

						end
                    end

                    uaffects[k][buffName] = affectdata

                else
                    -- This affect is already there, increment the count
                    uaffects[k][buffName].Count = uaffects[k][buffName].Count + 1
                end
            end

        end

    end

	-- visual effects are only applied the first time a buff is added
	-- this avoids stacking up trash entries which can cause stack overflows
	
	-- if no count has taken place (from buffs like health, fuel, etc) BUT
	-- we have a visual effect - we bump the count to 1 to insure that we
	-- flush the visual effect when the buff comes off
    if newbuff and Buffs[buffName].Effects then

		for k, fx in Buffs[buffName].Effects do

			local bufffx = CreateAttachedEmitter(unit, 0, unit.Sync.army, fx)

			if Buffs[buffName].EffectsScale then
				bufffx:ScaleEmitter(Buffs[buffName].EffectsScale)
			end
			
			-- some of the instant buffs dont increment the count
			-- but may have effects associated with them - we have
			-- to bump up the count so we can track the destruction
			-- of the effect when needed.
			if data.Count < 1 then
				data.Count = 1
			end

			data.Trash:Add(bufffx)

		end

    end
	
    local instigator = instigator or unit

	-- for buffs with a duration --
    if def.Duration and def.Duration > 0 then
	
		if unit then

			unit:ForkThread( BuffWorkThread, buffName, instigator )

			if data.Count > 0 then

				-- create the unit BuffTable entry
				if not ubt[def.BuffType] then
					ubt[def.BuffType] = {}
				end

				ubt[def.BuffType][buffName] = data

				if def.OnApplyBuff then
					def:OnApplyBuff(unit, instigator)
				end
			end
		end

	-- otherwise apply the buff
	-- just note that buffs that only fire once are left here
    else

		if data.Count > 0 then

			-- create the unit BuffTable entry
			if not ubt[def.BuffType] then
				ubt[def.BuffType] = {}
			end

			ubt[def.BuffType][buffName] = data

			if def.OnApplyBuff then
				def:OnApplyBuff(unit, instigator)
			end

		end

		BuffAffectUnit(unit, buffName, instigator, false)

	end

	if ScenarioInfo.BuffDialog then
	
		LOG("*AI DEBUG Unit "..unit:GetBlueprint().Description.." after applying buffs is "..repr(unit.Buffs))
		
	end

end

-- Function to do work on the buff.  Apply the buff every second
-- Then remove the buff so it can be applied again
function BuffWorkThread(unit, buffName, instigator)

	--LOG("*AI DEBUG BuffWorkThread launched")

	local buffTable = Buffs[buffName]

	local BeenDestroyed = moho.entity_methods.BeenDestroyed

	local pulse = 0

	while not BeenDestroyed(unit) and pulse < buffTable.Duration do

		BuffAffectUnit( unit, buffName, instigator, false )

		pulse = pulse + 1

		if pulse < buffTable.Duration then

			WaitTicks(10)

		end
	end

	if unit.Buffs.BuffTable[Buffs[buffName].BuffType][buffName] then
		RemoveBuff(unit, buffName)
	end

end



-- Functions to affect the unit.  Everytime you want to affect a new part of unit, add it in here.
-- afterRemove is a bool that defines if this buff is affecting after the removal of a buff.
-- We reaffect the unit to make sure that buff type is recalculated accurately without the buff that was on the unit.
-- However, this doesn't work for stunned units because it's a fire-and-forget type buff, not a fire-and-keep-track-of type buff.
function BuffAffectUnit(unit, buffName, instigator, afterRemove)

    local buffDef = Buffs[buffName]

    local buffAffects = buffDef.Affects

    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end
	
	if not instigator then
		instigator = unit
	end
	
	if ScenarioInfo.BuffDialog then
		LOG("*AI DEBUG Affecting unit "..repr(unit:GetBlueprint().Description).." with Buff "..buffName.." from "..repr(instigator:GetBlueprint().Description) )
	end

    for atype, vals in buffAffects do

        if atype == 'Health' then

            --Note: With health we don't actually look at the unit's table because it's an instant happening.  We don't want to overcalculate something as pliable as health.
            local health = GetHealth(unit)

            local val = ((buffAffects.Health.Add or 0) + health) * (buffAffects.Health.Mult or 1)
            local healthadj = val - health

            if healthadj < 0 then
                unit:DoTakeDamage( instigator, -1 * healthadj, false, 'Normal')	--VDiff(instigator:GetPosition(), unit:GetPosition())
            else
                AdjustHealth( unit, instigator, healthadj )
            end

		elseif atype == 'FuelRatio' then

			-- as with Health we just apply the effect when it happens
			local unitfuel = GetFuelRatio(unit)
            
            if unitfuel > -1 then

                -- and we use the lowest value so never more than 1.0 (full)
                local val = math.min((unitfuel + (buffAffects.FuelRatio.Add or 0)) * (buffAffects.FuelRatio.Mult or 1), 1)

                SetFuelRatio( unit, val )

                RequestRefreshUI(unit)
                
            end

        elseif atype == 'MaxHealth' then

            local unitbphealth = __blueprints[unit.BlueprintID].Defense.MaxHealth or 1
            local val = BuffCalculate(unit, buffName, 'MaxHealth', unitbphealth)

            local oldmax = GetMaxHealth( unit )

            SetMaxHealth( unit, val)

            if not vals.DoNoFill then

                if val > oldmax then

                    AdjustHealth( unit, instigator, val - oldmax)

                else

                    SetHealth( unit, instigator, math.min( GetHealth(unit), GetMaxHealth(unit) ))

                end

            end

        elseif atype == 'Regen' then

            local bpregn = __blueprints[unit.BlueprintID].Defense.RegenRate or 0
            local val = BuffCalculate(unit, buffName, 'Regen', bpregn)

            SetRegenRate( unit, val )

			RequestRefreshUI(unit)


        elseif atype == 'RegenPercent' then

			-- get the standard regen
			local bpregn = __blueprints[unit.BlueprintID].Defense.RegenRate or 0

			-- get the total current regen subtract the standard regen to get extra regen
			local vetregn = BuffCalculate(unit, nil, 'Regen', bpregn) - bpregn

            if afterRemove then
                --Restore normal regen value plus buffs
                val = BuffCalculate(unit, nil, 'Regen', bpregn)
            else
                --Buff this
                val = BuffCalculate(unit, buffName, 'RegenPercent', bpregn + vetregn)
            end

            SetRegenRate( unit, val )

			RequestRefreshUI(unit)

        elseif atype == 'MoveMult' then

            local val = BuffCalculate(unit, buffName, 'MoveMult', 1)

            SetSpeedMult( unit, val )
            SetAccMult( unit, val )
            SetTurnMult( unit, val )

        elseif atype == 'VisionRadius' then

            local val = BuffCalculate(unit, buffName, 'VisionRadius', __blueprints[unit.BlueprintID].Intel.VisionRadius or 0)

			if val > 0 then

				SetIntelRadius( unit, 'Vision', val)

			end

		elseif atype == 'WaterVisionRadius' then

			local val = BuffCalculate(unit, buffName, 'WaterVisionRadius', __blueprints[unit.BlueprintID].Intel.WaterVisionRadius or 0)

			if val > 0 then

				SetIntelRadius( unit, 'WaterVision', val)

				EnableIntel( unit, 'WaterVision')
			end

        elseif atype == 'RadarRadius' then

            local val = BuffCalculate(unit, buffName, 'RadarRadius', __blueprints[unit.BlueprintID].Intel.RadarRadius or 0)

			if val > 0 then

				if not unit:IsIntelEnabled('Radar') then

					unit:InitIntel(unit.Sync.army,'Radar', val)

					EnableIntel( unit, 'Radar')

				else

					SetIntelRadius( unit, 'Radar', val)

					EnableIntel( unit, 'Radar')
				end

            else
                DisableIntel( unit, 'Radar')
            end

        elseif atype == 'SonarRadius' then

            local val = BuffCalculate(unit, buffName, 'SonarRadius', __blueprints[unit.BlueprintID].Intel.SonarRadius or 0)

			if val > 0 then

				if not unit:IsIntelEnabled('Sonar') then

					unit:InitIntel(unit.Sync.army,'Sonar', val)

					EnableIntel( unit, 'Sonar')
				else

					SetIntelRadius( unit, 'Sonar', val)

					EnableIntel( unit, 'Sonar')
				end

			else
                DisableIntel( unit, 'Sonar')
            end

        elseif atype == 'OmniRadius' then

            local val = BuffCalculate(unit, buffName, 'OmniRadius', __blueprints[unit.BlueprintID].Intel.OmniRadius or 0)

			if val > 0 then

				if not unit:IsIntelEnabled('Omni') then

					unit:InitIntel(unit.Sync.army,'Omni', val)

					EnableIntel( unit, 'Omni')
				else

					SetIntelRadius( unit, 'Omni', val )

					EnableIntel( unit, 'Omni')
				end

			else
                DisableIntel( unit, 'Omni')
            end

        elseif atype == 'BuildRate' then
            local val = BuffCalculate(unit, buffName, 'BuildRate', __blueprints[unit.BlueprintID].Economy.BuildRate or 1)

            SetBuildRate( unit, val )

        -- NOTE:  Energy and Mass Storage buffs are borked - the first one will work
        -- any subsequent one will turn off the previous one before turning on the new one
        -- as a result - you can have one - but not both - on the same unit - and only one.
        -- in order to avoid stacking buffs that are no longer working - you should remove
        -- the previous storage buff before adding another - otherwise they'll stack up in
        -- the units data, but won't actually be working
        
		elseif atype == 'EnergyStorage' then
        
			local val = BuffCalculate(unit, buffName, 'EnergyStorage', __blueprints[unit.BlueprintID].Economy.StorageEnergy or 1)

            local brain = GetAIBrain(unit)

			-- the trick here is to know just how much storage there already is - and add to it - can't seem to find that
            -- other than the original blueprint value - rather than any 'current' value
            -- since atm I only use this once, on the ACU at the start of the game - it's not a real issue
			brain:GiveStorage('ENERGY',val)
            
            brain:GiveResource('Energy',val)

		elseif atype == 'MassStorage' then
        
			local val = BuffCalculate(unit, buffName, 'MassStorage', __blueprints[unit.BlueprintID].Economy.StorageMass or 1)
            
            local brain = GetAIBrain(unit)

			brain:GiveStorage('MASS',val)
            
            brain:GiveResource('Mass',val - 1)

        --- ADJACENCY EFFECTS ---
        elseif atype == 'EnergyActive' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyActive', 1)
            
            unit.EnergyBuildAdjMod = val
            unit:UpdateConsumptionValues()

        elseif atype == 'MassActive' then
        
            local val = BuffCalculate(unit, buffName, 'MassActive', 1)
            
            unit.MassBuildAdjMod = val
            unit:UpdateConsumptionValues()

        elseif atype == 'EnergyMaintenance' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyMaintenance', 1)
            
            unit.EnergyMaintAdjMod = val
            unit:UpdateConsumptionValues()

        elseif atype == 'MassMaintenance' then
        
            local val = BuffCalculate(unit, buffName, 'MassMaintenance', 1)
            
            unit.MassMaintAdjMod = val
            unit:UpdateConsumptionValues()

        elseif atype == 'EnergyProduction' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyProduction', 1)
            
            unit.EnergyProdAdjMod = val
            unit:UpdateProductionValues()

        elseif atype == 'MassProduction' then
        
            local val = BuffCalculate(unit, buffName, 'MassProduction', 1)
            
            unit.MassProdAdjMod = val
            unit:UpdateProductionValues()

        elseif atype == 'EnergyWeapon' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyWeapon', 1)

            for i = 1, unit:GetWeaponCount() do
            
                local wep = unit:GetWeapon(i)
                
                if wep:WeaponUsesEnergy() then

                    if unit.Sync.id then
                        ForkThread(FloatingEntityText, unit.Sync.id, 'Energy Req now '..math.floor(val*100).."%")
                    end
                
                    wep.AdjEnergyMod = val

                end
            end

        elseif atype == 'RateOfFire' then
        
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprof = wepbp.RateOfFire

                -- Set new rate of fire based on blueprint rate of fire.
				-- the value returned is always less than 1
				-- for example the returned value is .9
                local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)
                
                --LOG("*AI DEBUG RoF value is "..repr(val))

				-- Rate of Fire is basically firings per second
				-- ie. 3 = 3 shots per second

				-- so the delay is the period between shots
				-- ie. 1 / 3 = .33 delay between shots
                local delay = 1 / wepbp.RateOfFire

				-- multiply the delay time by the new value
				-- ie. .9 times .33 = .297

                -- and divide into 1 gives you the new Rate of Fire
				-- ie. 1 / .297 = 3.36
                wep:ChangeRateOfFire( 1 / ( val * delay ) )
                
            end

		elseif atype == 'ShieldRegeneration' then

			if unit.MyShield then

				local val = BuffCalculate(unit, buffName, 'ShieldRegeneration', 1)
				local regenrate = __blueprints[unit.BlueprintID].Defense.Shield.ShieldRegenRate or 1

				unit.MyShield:SetShieldRegenRate(val * regenrate)
			end

		elseif atype == 'ShieldSize' then

			if unit.MyShield then

				local val = BuffCalculate(unit, buffName, 'ShieldSize', 1)
				local shieldsize = __blueprints[unit.BlueprintID].Defense.Shield.ShieldSize or 1

				unit.MyShield:SetSize(val * shieldsize)
                
                if unit.MyShield:IsOn() then

                    unit.MyShield:RemoveShield()
                    unit.MyShield:CreateShieldMesh()
                    
                end
			end

		elseif atype == 'ShieldHealth' then

			if unit.MyShield then

				local val = BuffCalculate(unit, buffName, 'ShieldHealth', 1)
				local shieldhealth = __blueprints[unit.BlueprintID].Defense.Shield.ShieldMaxHealth or 1

				local shield = unit.MyShield

				SetMaxHealth( shield, val * shieldhealth)

				SetShieldRatio( shield.Owner, shield:GetHealth() / shield:GetMaxHealth() )

				if unit.Sync.id then
                    ForkThread(FloatingEntityText, unit.Sync.id, 'Max Health now '..math.floor( GetMaxHealth(shield) or 0 ).." Size is "..math.floor(shield.Size or 0).."  Regen is "..math.floor(shield.RegenRate or 0))
				end

				if shield.RegenThread then
					KillThread(shield.RegenThread)
					shield.RegenThread = nil
				end

				shield.RegenThread = shield:ForkThread( shield.RegenStartThread )
				shield.Owner.Trash:Add(shield.RegenThread)
			end

        elseif atype == 'Stun' and not afterRemove then

            unit:SetStunned(buffDef.Duration or 1, instigator)

            if unit.Anims then
                for k, manip in unit.Anims do
                    manip:SetRate(0)
                end
            end

        elseif atype == 'WeaponsEnable' then

            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local val, bool = BuffCalculate(unit, buffName, 'WeaponsEnable', 0, true)

                wep:SetWeaponEnabled(bool)
            end

        elseif atype == 'Damage' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                if wep.Label != 'DeathWeapon' and wep.Label != 'DeathImpact' then
                    local wepbp = wep:GetBlueprint()
                    local wepdam = wepbp.Damage
                    local val = BuffCalculate(unit, buffName, 'Damage', wepdam)

                    if val >= ( math.abs(val) + 0.5 ) then
                        val = math.ceil(val)
                    else
                        val = math.floor(val)
                    end
                    
                    LOG("*AI DEBUG Weapon Damage is "..repr(val))

                    wep:ChangeDamage(val)
                    -- wep.damageTable.DamageAmount = val
                end
            end

        elseif atype == 'DamageRadius' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprad = wepbp.DamageRadius
                local val = BuffCalculate(unit, buffName, 'DamageRadius', weprad)

                wep:SetDamageRadius(val)
            end
            
        elseif atype == 'FiringRandomness' then
        
            for i = 1, unit:GetWeaponCount() do
            
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local wepfr = wepbp.FiringRandomness

                local val = BuffCalculate(unit, buffName, 'FiringRandomness', 1)

                --LOG("*AI DEBUG Weapon Randomness is "..repr(wepfr * val))
                
                wep:SetFiringRandomness( wepfr * val )

            end

        elseif atype == 'MaxRadius' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprad = wepbp.MaxRadius
                local val = BuffCalculate(unit, buffName, 'MaxRadius', weprad)

                wep:ChangeMaxRadius(val)
            end

----   CLOAKING is a can of worms.  Revisit later.
----        elseif atype == 'Cloak' then
----
----            local val, bool = BuffCalculate(unit, buffName, 'Cloak', 0)
----
----            if unit:IsIntelEnabled('Cloak') then
----
----                if bool then
----                    unit:InitIntel(unit:GetArmy(), 'Cloak')
----                    unit:SetRadius('Cloak')
----                    unit:EnableIntel('Cloak')
----
----                elseif not bool then
----                    unit:DisableIntel('Cloak')
----                end
----
----           end


		else
            WARN("*WARNING: Tried to apply a buff with an unknown affect type of " .. atype .. " for buff " .. buffName)
        end
    end

end

-- Calculates the buff from all the buffs of the same time the unit has.
function BuffCalculate(unit, buffName, affectType, initialVal, initialBool)

    local adds = 0
    local mults = 1.0
    local bool = initialBool or false

	local returnVal = 1
    local highestCeil = false
    local lowestFloor = false

    if unit.Buffs.Affects[affectType] then	-- return initialVal, bool end

		for k, v in unit.Buffs.Affects[affectType] do
		
			if ScenarioInfo.BuffDialog then	
				LOG("*AI DEBUG Affecting "..repr(v))
			end

			if v.Add and v.Add != 0 then
				adds = adds + (v.Add * v.Count)
			end

			if v.Mult and v.Mult != 0 then

				for i = 1, v.Count do

					mults = mults * v.Mult

				end

			end

			if not v.Bool then
				bool = false
			else
				bool = true
			end

			if v.Ceil and (not highestCeil or highestCeil < v.Ceil) then
				highestCeil = v.Ceil
			end

			if v.Floor and (not lowestFloor or lowestFloor > v.Floor) then
				lowestFloor = v.Floor
			end
		end
	end

    -- Adds are calculated first, then the mults.  May want to expand that later.
    returnVal = (initialVal + adds) * mults

    if lowestFloor and returnVal < lowestFloor then
		returnVal = lowestFloor
	end

    if highestCeil and returnVal > highestCeil then
		returnVal = highestCeil
	end
	
	if ScenarioInfo.BuffDialog then
		LOG("*AI DEBUG Returnval is "..repr(returnVal).." bool is "..repr(bool))
	end

    return returnVal, bool
end

-- altered to report true/false if Buff was removed --
function RemoveBuff(unit, buffName, removeAllCounts, instigator)

    local def = Buffs[buffName]

    local unitBuff = unit.Buffs.BuffTable[def.BuffType][buffName]

	if unitBuff then

        if ScenarioInfo.BuffDialog then
            LOG("*AI DEBUG Removing Buff "..buffName.." from "..repr(unit:GetBlueprint().Description))
        end
	
		if ScenarioInfo.BuffDialog then
			LOG("*AI DEBUG before Removing "..buffName.." unit data is "..repr(unit.Buffs) )	
		end

		for atype,_ in def.Affects do

			if unit.Buffs.Affects[atype] and unit.Buffs.Affects[atype][buffName] then

				-- If we're removing all buffs of this name, only remove as
				-- many affects as there are buffs since other buffs may have
				-- added these same affects.
				if removeAllCounts then

					unitBuff.Count = unitBuff.Count - unit.Buffs.Affects[atype][buffName].Count
					unit.Buffs.Affects[atype][buffName].Count = 0

				else

					unit.Buffs.Affects[atype][buffName].Count = unit.Buffs.Affects[atype][buffName].Count - 1
					unitBuff.Count = unitBuff.Count - 1

				end

				if unit.Buffs.Affects[atype][buffName].Count <= 0 then
					unit.Buffs.Affects[atype][buffName] = nil
				end

				if LOUDEMPTY(unit.Buffs.Affects[atype]) then
					unit.Buffs.Affects[atype] = nil
				end

			end

		end

		if removeAllCounts or unitBuff.Count < 1 or not unit.Buffs.Affects then
			
			-- unit:PlayEffect('RemoveBuff', buffName)

			unitBuff.Trash:Destroy()

			unit.Buffs.BuffTable[def.BuffType][buffName] = nil

			if LOUDEMPTY(unit.Buffs.BuffTable[def.BuffType]) then
				unit.Buffs.BuffTable[def.BuffType] = nil
			end

		end

		if def.OnBuffRemove then
			def:OnBuffRemove(unit, instigator)
		end

		-- FIXME: This doesn't work because the magic sync table doesn't detect
		-- the change. Need to give all child tables magic meta tables too.
		if def.Icon then
			-- If the user layer was displaying an icon, remove it from the sync table
			local newTable = unit.Sync.Buffs
			table.removeByValue(newTable,buffName)
			unit.Sync.Buffs = table.copy(newTable)
		end

		BuffAffectUnit(unit, buffName, instigator, true)

	else
        return false
    end
	
	if ScenarioInfo.BuffDialog then
		LOG("*AI DEBUG AFTER Removing "..buffName.." unit data is "..repr(unit.Buffs) )
	end
    
    return true
end

function HasBuff(unit, buffName)

    if unit.Buffs.BuffTable[Buffs[buffName].BuffType][buffName] then
        return true
    end

    return false
end

function PlayBuffEffect(unit, buffName, data)

    if not Buffs[buffName].Effects then
        return
    end

    for k, fx in Buffs[buffName].Effects do

        local bufffx = CreateAttachedEmitter(unit, 0, unit.Sync.army, fx)

        if Buffs[buffName].EffectsScale then
            bufffx:ScaleEmitter(Buffs[buffName].EffectsScale)
        end

        data.Trash:Add(bufffx)

        unit.Trash:Add(bufffx)
    end
end


--[[
--
-- DEBUG FUNCTIONS
--
_G.PrintBuffs = function()
    local selection = DebugGetSelection()
    for k,unit in selection do
        if unit.Buffs then
            LOG('Buffs = ', repr(unit.Buffs))
        end
    end
end
--]]
