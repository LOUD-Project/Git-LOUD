--**  File     :  /lua/sim/buff.lua
--**  Copyright � 2008 Gas Powered Games, Inc.  All rights reserved.

local WaitTicks = coroutine.yield
local LOUDENTITY = EntityCategoryContains
local LOUDPARSE = ParseEntityCategory
local LOUDCOPY = table.copy
local LOUDEMPTY = table.empty

local EntityMethods = moho.entity_methods
local UnitMethods = moho.unit_methods

local AdjustHealth          = EntityMethods.AdjustHealth
local BeenDestroyed         = EntityMethods.BeenDestroyed
local DisableIntel          = EntityMethods.DisableIntel
local EnableIntel           = EntityMethods.EnableIntel
local GetBlueprint          = EntityMethods.GetBlueprint
local GetMaxHealth          = EntityMethods.GetMaxHealth
local RequestRefreshUI      = EntityMethods.RequestRefreshUI
local SetHealth             = EntityMethods.SetHealth
local SetIntelRadius        = EntityMethods.SetIntelRadius
local SetMaxHealth          = EntityMethods.SetMaxHealth

local GetAIBrain            = UnitMethods.GetAIBrain
local GetFuelRatio          = UnitMethods.GetFuelRatio
local GetHealth             = UnitMethods.GetHealth
local SetAccMult            = UnitMethods.SetAccMult
local SetBuildRate          = UnitMethods.SetBuildRate
local SetFuelRatio          = UnitMethods.SetFuelRatio
local SetRegenRate          = UnitMethods.SetRegenRate
local SetShieldRatio        = UnitMethods.SetShieldRatio
local SetSpeedMult          = UnitMethods.SetSpeedMult
local SetStat               = UnitMethods.SetStat
local SetTurnMult           = UnitMethods.SetTurnMult

EntityMethods = nil
UnitMethods = nil

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

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
    
    if not unit or unit.Dead or not unit.Buffs.BuffTable or not buffName then
        return
    end

    local BuffDialog = ScenarioInfo.BuffDialog

    local BuffAffectUnit = BuffAffectUnit
    local ForkThread = unit.ForkThread

    local LOUDEMPTY = LOUDEMPTY
    local LOUDENTITY = LOUDENTITY
    local LOUDPARSE = LOUDPARSE
    local RemoveBuff = RemoveBuff
    local TrashAdd = TrashAdd

    local bp = __blueprints[unit.BlueprintID]
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

        if not def:BuffCheckFunction(unit, bp, nil) then
            return
        end

    end
    
    local BuffType = def.BuffType

    local ubt = unit.Buffs.BuffTable

    if def.Stacks == 'REPLACE' and ubt[BuffType] then

        for key, bufftbl in ubt[BuffType] do

            RemoveBuff(unit, key, true)

        end
    end

	-- if the unit already has this bufftype then ignore it
    if def.Stacks == 'IGNORE' and ubt[BuffType] and not LOUDEMPTY(ubt[BuffType]) then
        return
    end
	
	local newbuff = false

    local data = ubt[BuffType][buffName]


    if not data then

        -- This is a new buff (as opposed to an additional one being stacked)
		data = { Count = 0, Trash = TrashBag() }
		
		newbuff = true

    end

    local uaffects = unit.Buffs.Affects
	
	if BuffDialog then
		LOG("*AI DEBUG Applying "..buffName.." to "..repr(bp.Description).." "..unit.EntityID )
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

				if not v:BuffCheckFunction(unit, bp, nil) then

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
    
        local bufffx
        
        local CreateAttachedEmitter= CreateAttachedEmitter

		for k, fx in Buffs[buffName].Effects do

			bufffx = CreateAttachedEmitter(unit, 0, unit.Army, fx)

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

			TrashAdd( data.Trash, bufffx )

		end

    end
	
    local instigator = instigator or unit

	-- for buffs with a duration --
    if def.Duration and def.Duration > 0 then
	
		if unit then

			ForkThread( unit, BuffWorkThread, buffName, instigator )

			if data.Count > 0 then

				-- create the unit BuffTable entry
				if not ubt[BuffType] then
					ubt[BuffType] = {}
				end

				ubt[BuffType][buffName] = data

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
			if not ubt[BuffType] then
				ubt[BuffType] = {}
			end

			ubt[BuffType][buffName] = data

			if def.OnApplyBuff then
				def:OnApplyBuff(unit, instigator)
			end

		end

		BuffAffectUnit(unit, buffName, instigator, false)

	end

	if BuffDialog then
		LOG("*AI DEBUG BUFF Unit "..unit:GetBlueprint().Description.." after applying buffs is "..repr(unit.Buffs))
	end

end

-- Function to do work on the buff.  Apply the buff every second
-- Then remove the buff so it can be applied again
function BuffWorkThread(unit, buffName, instigator)

	local buffTable = Buffs[buffName]

    local BuffAffectUnit = BuffAffectUnit
    local WaitTicks = WaitTicks

	local pulse = 0
    local Duration = (buffTable.Duration * 10) + 1

	if not BeenDestroyed(unit) then

		BuffAffectUnit( unit, buffName, instigator, false )

		WaitTicks(Duration)

	end

	if not BeenDestroyed(unit) and unit.Buffs.BuffTable[Buffs[buffName].BuffType][buffName] then
		RemoveBuff(unit, buffName)
	end

end



-- Functions to affect the unit.  Everytime you want to affect a new part of unit, add it in here.
-- afterRemove is a bool that defines if this buff is affecting after the removal of a buff.
-- We reaffect the unit to make sure that buff type is recalculated accurately without the buff that was on the unit.
-- However, this doesn't work for stunned units because it's a fire-and-forget type buff, not a fire-and-keep-track-of type buff.
function BuffAffectUnit(unit, buffName, instigator, afterRemove)

    local BuffDialog = ScenarioInfo.BuffDialog
    
    local buffDef = Buffs[buffName]

    local buffAffects = buffDef.Affects
    local BuffCalculate = BuffCalculate

    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end
	
	if not instigator then
		instigator = unit
	end
	
	if BuffDialog then
		LOG("*AI DEBUG BUFF Affecting unit "..repr(unit:GetBlueprint().Description).." with Buff "..buffName.." from "..repr(instigator:GetBlueprint().Description).." Duration "..repr(buffDef.Duration) )
	end
    
    local GetHealth = GetHealth

    for atype, vals in buffAffects do

        if atype == 'Health' then

            --Note: With health we don't actually look at the unit's table because it's an instant happening.  We don't want to overcalculate something as pliable as health.
            local health = GetHealth(unit)

            local val = ((buffAffects.Health.Add or 0) + health) * (buffAffects.Health.Mult or 1)
            local healthadj = val - health

            if healthadj < 0 then
                unit:DoTakeDamage( instigator, -1 * healthadj, false, 'Normal')
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
            
            SetStat( unit, 'REGEN', val )
            
            unit.CurrentRegenRate = val

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
            
            SetStat( unit, 'REGEN', val )
            
            unit.CurrentRegenRate = val

			RequestRefreshUI(unit)

        elseif atype == 'MoveMult' then

            local val = BuffCalculate(unit, buffName, 'MoveMult', 1)

            SetSpeedMult( unit, val )
            SetAccMult( unit, val )
            SetTurnMult( unit, val )

        elseif atype == 'SpeedMult' then

            local val = BuffCalculate(unit, buffName, 'SpeedMult', 1)

            SetSpeedMult( unit, val )

        elseif atype == 'AccelMult' then

            local val = BuffCalculate(unit, buffName, 'AccelMult', 1)

            SetAccMult( unit, val )

        elseif atype == 'TurnMult' then

            local val = BuffCalculate(unit, buffName, 'TurnMult', 1)

            SetTurnMult( unit, val )

        elseif atype == 'VisionRadius' then

            local val = BuffCalculate(unit, buffName, 'VisionRadius', __blueprints[unit.BlueprintID].Intel.VisionRadius or 0)

			if val > 0 then
				SetIntelRadius( unit, 'Vision', val)
                SetStat( unit, 'VISION', val )
			end

		elseif atype == 'WaterVisionRadius' then

			local val = BuffCalculate(unit, buffName, 'WaterVisionRadius', __blueprints[unit.BlueprintID].Intel.WaterVisionRadius or 0)

			if val > 0 then
				SetIntelRadius( unit, 'WaterVision', val)
                SetStat( unit, 'WATERVISION', val )
                
				EnableIntel( unit, 'WaterVision')
			end

        elseif atype == 'RadarRadius' then

            local val = BuffCalculate(unit, buffName, 'RadarRadius', __blueprints[unit.BlueprintID].Intel.RadarRadius or 0)

			if val > 0 then
				if not unit:IsIntelEnabled('Radar') then
					unit:InitIntel(unit.Army,'Radar', val)
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
					unit:InitIntel(unit.Army,'Sonar', val)
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
					unit:InitIntel(unit.Army,'Omni', val)
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
            
            if val != 1 then
                unit.EnergyBuildAdjMod = val
            else
                unit.EnergyBuildAdjMod = nil
            end
            
            unit:UpdateConsumptionValues()

        elseif atype == 'MassActive' then
        
            local val = BuffCalculate(unit, buffName, 'MassActive', 1)
            
            if val != 1 then
                unit.MassBuildAdjMod = val
            else
                unit.MassBuildAdjMod = nil
            end
            
            unit:UpdateConsumptionValues()

        elseif atype == 'EnergyMaintenance' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyMaintenance', 1)
            
            if val != 1 then
                unit.EnergyMaintAdjMod = val
            else
                unit.EnergyMaintAdjMod = nil
            end
            
            unit:UpdateConsumptionValues()

        elseif atype == 'MassMaintenance' then
        
            local val = BuffCalculate(unit, buffName, 'MassMaintenance', 1)
            
            if val != 1 then
                unit.MassMaintAdjMod = val
            else
                unit.MassMaintAdjMod = nil
            end
            
            unit:UpdateConsumptionValues()

        elseif atype == 'EnergyProduction' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyProduction', 1)
            
            if val != 1 then
                unit.EnergyProdAdjMod = val
            else
                unit.EnergyProdAdjMod = nil
            end
            
            unit:UpdateProductionValues()

        elseif atype == 'MassProduction' then
        
            local val = BuffCalculate(unit, buffName, 'MassProduction', 1)
            
            if val != 1 then
                unit.MassProdAdjMod = val
            else
                unit.MassProdAdjMod = nil
            end
            
            unit:UpdateProductionValues()

        elseif atype == 'EnergyWeapon' then
        
            local val = BuffCalculate(unit, buffName, 'EnergyWeapon', 1)

            for i = 1, unit:GetWeaponCount() do
            
                local wep = unit:GetWeapon(i)
                
                if wep:WeaponUsesEnergy() then

                    if unit.EntityID then
                        ForkThread(FloatingEntityText, unit.EntityID, 'Energy Req now '..math.floor(val*100).."%")
                    end
                    
                    if val != 1 then
                        wep.AdjEnergyMod = val
                    else
                        wep.AdjEnergyMod = nil
                    end

                end
            end

        elseif atype == 'RateOfFire' then
        
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep.bp
                local weprof = wepbp.RateOfFire

                -- Set new rate of fire based on blueprint rate of fire.
				-- the value returned is always less than 1
				-- for example the returned value is .9
                local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)

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
                
                SetStat( unit, 'SHIELDREGEN', val * regenrate )
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

                SetStat( unit, 'SHIELDHP', val * shieldhealth )

				SetShieldRatio( shield.Owner, shield:GetHealth() / shield:GetMaxHealth() )

				if unit.EntityID then
                    ForkThread(FloatingEntityText, unit.EntityID, 'Max Health now '..math.floor( GetMaxHealth(shield) or 0 ).." Size is "..math.floor(shield.Size or 0).."  Regen is "..math.floor(shield.RegenRate or 0))
				end

				if shield.RegenThread then
					KillThread(shield.RegenThread)
					shield.RegenThread = nil
				end

				shield.RegenThread = shield:ForkThread( shield.RegenStartThread )
                
				TrashAdd( shield.Owner.Trash, shield.RegenThread )
			end

        elseif atype == 'Stun' and not afterRemove then

            unit:SetStunned(buffDef.Duration or 1, instigator)

            if unit.Anims then
                for k, manip in unit.Anims do
                    manip:SetRate(0)
                end
            end

        -- WEAPON ORIENTED BUFFS --
        -- The problem with these buffs is that they try to apply to ALL weapons on the unit
        -- There is no current mechanic to specify precisely which weapon is affected

        -- I have (commented out atm) a method to have the buff specify which weapon # to affect
        -- but this is rather limited, since it implies knowledge of a specific weapon in the blueprint
        -- and that weapon # may or may not even be there, let alone, be a valid weapon (targeting lasers)

        elseif atype == 'WeaponsEnable' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)

                local val, bool = BuffCalculate(unit, buffName, 'WeaponsEnable', 0, true)

                wep:SetWeaponEnabled(bool)

            end

        elseif atype == 'Damage' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)

                    if wep.bp.Label != 'DeathWeapon' and wep.bp.Label != 'DeathImpact' then

                        local wepbp = wep.bp
                        local wepdam = wepbp.Damage

                        local val = BuffCalculate(unit, buffName, 'Damage', wepdam)

                        if val >= ( math.abs(val) + 0.5 ) then
                            val = math.ceil(val)
                        else
                        val = math.floor(val)
                    end

                    wep:ChangeDamage(val)
                end
                
            end

        elseif atype == 'DamageRadius' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep.bp
                    local weprad = wepbp.DamageRadius

                local val = BuffCalculate(unit, buffName, 'DamageRadius', weprad)

                wep:SetDamageRadius(val)
            end
            
        elseif atype == 'FiringRandomness' then
        
            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep.bp
                local wepfr = wepbp.FiringRandomness

                local val = BuffCalculate(unit, buffName, 'FiringRandomness', 1)

                wep:SetFiringRandomness( wepfr * val )
            end

        elseif atype == 'MaxRadius' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep.bp
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

    local BuffDialog = ScenarioInfo.BuffDialog
    
    local adds = 0
    local mults = 1.0
    local bool = initialBool or false

	local returnVal = 1
    local highestCeil = false
    local lowestFloor = false

    if unit.Buffs.Affects[affectType] then	-- return initialVal, bool end

		for k, v in unit.Buffs.Affects[affectType] do
		
			if BuffDialog then	
				LOG("*AI DEBUG BUFF Affecting "..repr(v))
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
	
	if BuffDialog and bool then
		LOG("*AI DEBUG BUFF Returnval is "..repr(returnVal).." bool is "..repr(bool))
	end

    return returnVal, bool
end

-- altered to report true/false if Buff was removed --
function RemoveBuff(unit, buffName, removeAllCounts, instigator)

    local BuffDialog = ScenarioInfo.BuffDialog
    
    local LOUDEMPTY = LOUDEMPTY
    
    local BuffAffectUnit = BuffAffectUnit
    
    local def = Buffs[buffName]

    local unitBuff = unit.Buffs.BuffTable[def.BuffType][buffName]

	if unitBuff then

        if BuffDialog then
            LOG("*AI DEBUG BUFF Removing Buff "..buffName.." from "..repr(unit:GetBlueprint().Description))
			LOG("*AI DEBUG BUFF before Removing "..buffName.." unit data is "..repr(unit.Buffs) )	
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

			TrashDestroy(unitBuff.Trash)

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
			unit.Sync.Buffs = LOUDCOPY(newTable)
		end

		BuffAffectUnit(unit, buffName, instigator, true)

	else
        return false
    end
	
	if BuffDialog then
		LOG("*AI DEBUG BUFF after Removing "..buffName.." unit data is "..repr(unit) )
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
    
    local CreateAttachedEmitter = CreateAttachedEmitter
    local TrashAdd = TrashAdd
    
    local bufffx
    
    local CreateAttachedEmitter= CreateAttachedEmitter

    for k, fx in Buffs[buffName].Effects do

        bufffx = CreateAttachedEmitter(unit, 0, unit.Army, fx)

        if Buffs[buffName].EffectsScale then
            bufffx:ScaleEmitter(Buffs[buffName].EffectsScale)
        end

        TrashAdd( data.Trash, bufffx )

        TrashAdd( unit.Trash, bufffx )
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
