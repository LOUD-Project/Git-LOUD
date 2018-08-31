#**  File     :  /lua/sim/buff.lua
#**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.

local WaitTicks = coroutine.yield
local LOUDENTITY = EntityCategoryContains
local LOUDPARSE = ParseEntityCategory

# The Unit's BuffTable for applied buffs looks like this:
#
# Unit.Buffs = {
#    Affects = {
#        <AffectType (Regen/MaxHealth/etc)> = {
#            BuffName = {
#                Count = i,
#                Add = X,
#                Mult = X,
#            }
#        }
#    }
#    BuffTable = {
#        <BuffType (LEVEL/CATEGORY)> = {
#            BuffName = {
#                Count = i,
#                Trash = trashbag,
#            }
#        }
#    }

-- Function to apply a buff to a unit.
-- This function is a fire-and-forget.  Apply this and it'll be applied over time if there is a duration.
function ApplyBuff(unit, buffName, instigator)

    if unit.Dead then 
        return 
    end

    local def = Buffs[buffName]
	
    if not def then
        error("*ERROR: Tried to add a buff that doesn\'t exist! Name: ".. buffName, 2)
        return
    end
    
    if def.EntityCategory then
	
		if not LOUDENTITY( def.EntityCategory, unit ) then
			return
        end
		
    end
    
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
    
    -- If add this buff to the list of buffs the unit has -- be careful of stacking buffs.
    if not ubt[def.BuffType] then
        ubt[def.BuffType] = {}
    end
    
    if def.Stacks == 'IGNORE' and ubt[def.BuffType] and table.getsize(ubt[def.BuffType]) > 0 then
        return
    end
    
    local data = ubt[def.BuffType][buffName]
    local instigator = instigator or unit
	
    if not data then
	
        -- This is a new buff (as opposed to an additional one being stacked)
        data = { BuffName = buffName, Count = 1, Trash = TrashBag() }
        ubt[def.BuffType][buffName] = data
		
    else
        -- This buff is already on the unit so stack another by incrementing the
        -- counts. data.Count is how many times the buff has been applied
        data.Count = data.Count + 1
		
    end
    
    local uaffects = unit.Buffs.Affects
	
    if def.Affects then
        for k,v in def.Affects do
		
            -- Don't save off 'instant' type affects like health and energy
            if k != 'Health' and k != 'Energy' then
			
                if not uaffects[k] then
                    uaffects[k] = {}
                end
                
                if not uaffects[k][buffName] then
                    -- This is a new affect.
                    local affectdata = { BuffName = buffName, Count = 1, }
					
                    for buffkey, buffval in v do
                        affectdata[buffkey] = buffval
                    end
					
                    uaffects[k][buffName] = affectdata
					
                else
                    -- This affect is already there, increment the count
                    uaffects[k][buffName].Count = uaffects[k][buffName].Count + 1
                end
            end
        end
    end
	
	PlayBuffEffect(unit, buffName, data)
    
	-- for buffs with a duration -- 
    if def.Duration and def.Duration > 0 then
	
        local thread = ForkThread(BuffWorkThread, unit, buffName, instigator) 
        unit.Trash:Add(thread)
        data.Trash:Add(thread)
	
	-- otherwise just apply the buff once
	-- just note that buffs that only fire once are left here
    else
    
		ubt[def.BuffType][buffName] = data

		if def.OnApplyBuff then
			def:OnApplyBuff(unit, instigator)
		end
	
		BuffAffectUnit(unit, buffName, instigator, false)
	end

end

-- Function to do work on the buff.  Apply the buff every second
-- Then remove the buff so it can be applied again
function BuffWorkThread(unit, buffName, instigator)
    
    local buffTable = Buffs[buffName]

    local pulse = 0
   
    --while pulse < buffTable.Duration and not unit.Dead do
	while not unit.Dead do

        BuffAffectUnit(unit, buffName, instigator, false)
		
        WaitTicks(10)
        pulse = pulse + 10
    end
	
    RemoveBuff(unit, buffName)
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
    
    for atype, vals in buffAffects do

        if atype == 'Health' then
        
            --Note: With health we don't actually look at the unit's table because it's an instant happening.  We don't want to overcalculate something as pliable as health.
            local health = unit:GetHealth()
            local val = ((buffAffects.Health.Add or 0) + health) * (buffAffects.Health.Mult or 1)
            local healthadj = val - health
            
            if healthadj < 0 then
                unit:DoTakeDamage( instigator, -1 * healthadj, VDiff(instigator:GetPosition(), unit:GetPosition()), 'Normal')
            else
                unit:AdjustHealth(instigator, healthadj)
            end
        
		elseif atype == 'FuelRatio' then
			
			-- as with Health we just apply the effect when it happens
			local unitfuel = unit:GetFuelRatio()
			-- and we use the lowest value so never more than 1.0 (full)
			local val = math.min((unitfuel + (buffAffects.FuelRatio.Add or 0)) * (buffAffects.FuelRatio.Mult or 1), 1)
			
			unit:SetFuelRatio(val)
			unit:RequestRefreshUI()
		
        elseif atype == 'MaxHealth' then
        
            local unitbphealth = unit:GetBlueprint().Defense.MaxHealth or 1
            local val = BuffCalculate(unit, buffName, 'MaxHealth', unitbphealth)
        
            local oldmax = unit:GetMaxHealth()
        
            unit:SetMaxHealth(val)
            
            if not vals.DoNoFill then
                if val > oldmax then
                    unit:AdjustHealth(unit, val - oldmax)
                else
                    unit:SetHealth(unit, math.min(unit:GetHealth(), unit:GetMaxHealth())) 
                end
            end            
        
        elseif atype == 'Regen' then
            
            local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
            local val = BuffCalculate(unit, buffName, 'Regen', bpregn)
        
            unit:SetRegenRate(val)
			unit:RequestRefreshUI()
        

        elseif atype == 'RegenPercent' then
		
			-- get the standard regen
			local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
			
			-- get the total current regen subtract the standard regen to get extra regen
			local vetregn = BuffCalculate(unit, nil, 'Regen', bpregn) - bpregn

            if afterRemove then
                --Restore normal regen value plus buffs
                val = BuffCalculate(unit, nil, 'Regen', bpregn)
            else
                --Buff this
                val = BuffCalculate(unit, buffName, 'RegenPercent', bpregn + vetregn)
            end
            
            unit:SetRegenRate(val)
			unit:RequestRefreshUI()
			
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
        
                    wep:ChangeDamage(val)
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

        elseif atype == 'MaxRadius' then
        
            for i = 1, unit:GetWeaponCount() do
        
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprad = wepbp.MaxRadius
                local val = BuffCalculate(unit, buffName, 'MaxRadius', weprad)
        
                wep:ChangeMaxRadius(val)
            end

        elseif atype == 'MoveMult' then
            
            local val = BuffCalculate(unit, buffName, 'MoveMult', 1)
            
            unit:SetSpeedMult(val)
            unit:SetAccMult(val)
            unit:SetTurnMult(val)
            
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

        elseif atype == 'VisionRadius' then
		
            local val = BuffCalculate(unit, buffName, 'VisionRadius', unit:GetBlueprint().Intel.VisionRadius or 0)
			
			if val > 0 then
				unit:SetIntelRadius('Vision', val)
			end
			
		elseif atype == 'WaterVisionRadius' then
		
			local val = BuffCalculate(unit, buffName, 'WaterVisionRadius', unit:GetBlueprint().Intel.WaterVisionRadius or 0)
			
			if val > 0 then
				unit:SetIntelRadius('WaterVision', val)
				unit:EnableIntel('WaterVision')
			end

        elseif atype == 'RadarRadius' then
		
            local val = BuffCalculate(unit, buffName, 'RadarRadius', unit:GetBlueprint().Intel.RadarRadius or 0)
			
			if val > 0 then
				if not unit:IsIntelEnabled('Radar') then
					unit:InitIntel(unit:GetArmy(),'Radar', val)
					unit:EnableIntel('Radar')
				else
					unit:SetIntelRadius('Radar', val)
					unit:EnableIntel('Radar')
				end
            else
                unit:DisableIntel('Radar')
            end
			
        elseif atype == 'SonarRadius' then
		
            local val = BuffCalculate(unit, buffName, 'SonarRadius', unit:GetBlueprint().Intel.SonarRadius or 0)
			
			if val > 0 then
				if not unit:IsIntelEnabled('Sonar') then
					unit:InitIntel(unit:GetArmy(),'Sonar', val)
					unit:EnableIntel('Sonar')
				else
					unit:SetIntelRadius('Sonar', val)
					unit:EnableIntel('Sonar')
				end
			else
                unit:DisableIntel('Sonar')
            end
        
        elseif atype == 'OmniRadius' then
		
            local val = BuffCalculate(unit, buffName, 'OmniRadius', unit:GetBlueprint().Intel.OmniRadius or 0)
			
			if val > 0 then
				if not unit:IsIntelEnabled('Omni') then
					unit:InitIntel(unit:GetArmy(),'Omni', val)
					unit:EnableIntel('Omni')
				else
					unit:SetIntelRadius('Omni', val)
					unit:EnableIntel('Omni')
				end
			else
                unit:DisableIntel('Omni')
            end            
            
        elseif atype == 'BuildRate' then
            local val = BuffCalculate(unit, buffName, 'BuildRate', unit:GetBlueprint().Economy.BuildRate or 1)
            unit:SetBuildRate( val )
          

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
				local regenrate = unit:GetBlueprint().Defense.Shield.ShieldRegenRate or 1
		
				unit.MyShield:SetShieldRegenRate(val * regenrate)
			end
			
		elseif atype == 'ShieldSize' then

			
			if unit.MyShield then

				local val = BuffCalculate(unit, buffName, 'ShieldSize', 1)
				local shieldsize = unit:GetBlueprint().Defense.Shield.ShieldSize or 1
			
				unit.MyShield:SetSize(val * shieldsize)

				unit.MyShield:RemoveShield()
				unit.MyShield:CreateShieldMesh()
			end			

		elseif atype == 'ShieldHealth' then
		
			if unit.MyShield then
			
				local val = BuffCalculate(unit, buffName, 'ShieldHealth', 1)
				local shieldhealth = unit:GetBlueprint().Defense.Shield.ShieldMaxHealth or 1

				local shield = unit.MyShield
			
				shield:SetMaxHealth(val * shieldhealth)
				shield.Owner:SetShieldRatio( shield:GetHealth() / shield:GetMaxHealth() )

				if unit.Sync.id then
					ForkThread(FloatingEntityText, unit.Sync.id, 'Max Health now '..math.floor(shield:GetMaxHealth()).." Size is "..math.floor(shield.Size).."  Regen is "..math.floor(shield.RegenRate))
				end
				
				if shield.RegenThread then
					KillThread(shield.RegenThread)
					shield.RegenThread = nil
				end
				
				shield.RegenThread = shield:ForkThread( shield.RegenStartThread )
				shield.Owner.Trash:Add(shield.RegenThread)
			end		

#--   CLOAKING is a can of worms.  Revisit later.
#--        elseif atype == 'Cloak' then
#--            
#--            local val, bool = BuffCalculate(unit, buffName, 'Cloak', 0)
#--            
#--            if unit:IsIntelEnabled('Cloak') then
#--
#--                if bool then
#--                    unit:InitIntel(unit:GetArmy(), 'Cloak')
#--                    unit:SetRadius('Cloak')
#--                    unit:EnableIntel('Cloak')
#--            
#--                elseif not bool then
#--                    unit:DisableIntel('Cloak')
#--                end
#--            
#--           end

		
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
    
    local highestCeil = false
    local lowestFloor = false
    
    if not unit.Buffs.Affects[affectType] then return initialVal, bool end
    
    for k, v in unit.Buffs.Affects[affectType] do
    
        if v.Add and v.Add != 0 then
            adds = adds + (v.Add * v.Count)
        end
        
        if v.Mult and v.Mult != 0 then
            for i=1,v.Count do
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
    
    -- Adds are calculated first, then the mults.  May want to expand that later.
    local returnVal = (initialVal + adds) * mults
    
    if lowestFloor and returnVal < lowestFloor then
		returnVal = lowestFloor
	end
    
    if highestCeil and returnVal > highestCeil then
		returnVal = highestCeil
	end 

    return returnVal, bool
end

function RemoveBuff(unit, buffName, removeAllCounts, instigator)
    
    local def = Buffs[buffName]
    local unitBuff = unit.Buffs.BuffTable[def.BuffType][buffName]
	
	if unitBuff then
    
		for atype,_ in def.Affects do
	
			local list = unit.Buffs.Affects[atype]
		
			if list and list[buffName] then
		
				-- If we're removing all buffs of this name, only remove as 
				-- many affects as there are buffs since other buffs may have
				-- added these same affects.
				if removeAllCounts then
					list[buffName].Count = list[buffName].Count - unitBuff.Count
				else
					list[buffName].Count = list[buffName].Count - 1
				end
            
				if list[buffName].Count <= 0 then
					list[buffName] = nil
				end
				
				if table.empty(unit.Buffs.Affects[atype]) then
					unit.Buffs.Affects[atype] = nil
				end
				
			end

		end
    
		if unitBuff.Count then
			unitBuff.Count = unitBuff.Count - 1
		end

		if removeAllCounts or unitBuff.Count <= 0 then
			-- unit:PlayEffect('RemoveBuff', buffName)

			unitBuff.Trash:Destroy()
			unit.Buffs.BuffTable[def.BuffType][buffName] = nil
			
			if table.empty(unit.Buffs.BuffTable[def.BuffType]) then
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
		
	end

    BuffAffectUnit(unit, buffName, unit, true)
	
	--LOG("*AI DEBUG Removing "..buffName.." unit data is "..repr(unit))    
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
	
        local bufffx = CreateAttachedEmitter(unit, 0, unit:GetArmy(), fx)
		
        if Buffs[buffName].EffectsScale then
            bufffx:ScaleEmitter(Buffs[buffName].EffectsScale)
        end
		
        data.Trash:Add(bufffx)
		
        unit.Trash:Add(bufffx)
    end
end


--[[
#
# DEBUG FUNCTIONS
# 
_G.PrintBuffs = function()
    local selection = DebugGetSelection()
    for k,unit in selection do
        if unit.Buffs then
            LOG('Buffs = ', repr(unit.Buffs))
        end
    end
end
--]]