-- Original Code by Uveso, Modified by Phoenix
local inspect = require('inspect')
local cleanUnitName = require('cleanUnitName')
-- TODO: move canTargetBlah() to seperate helper file
-- local Entity = import('/lua/sim/Entity.lua').Entity

local function round(x) --Uveso(?) Round Function, unused?
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local function canTargetHighAir(weapon)
    local completeTargetLayerList = ''
--    for curLayerID,curLayerList in ipairs(weapon.FireTargetLayerCapsTable) do
--        completeTargetLayerList = completeTargetLayerList .. curLayerList
--    end
    if(weapon.FireTargetLayerCapsTable) then
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(string.find(completeTargetLayerList,"Air") and
           not string.find(weapon.TargetRestrictDisallow,"HIGHALTAIR")
        ) then
            return true
        end
    end

    return false
end

local function canTargetLand(weapon)
    local completeTargetLayerList = ''
--    for curLayerID,curLayerList in ipairs(weapon.FireTargetLayerCapsTable) do
--        completeTargetLayerList = completeTargetLayerList .. curLayerList
--    end
    if(weapon.FireTargetLayerCapsTable) then
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(string.find(completeTargetLayerList,"Land") or
           string.find(completeTargetLayerList,"Water")
        ) then
            return true
        end
    end

    return false
end

local function canTargetSubs(weapon)
    if(weapon.AboveWaterTargetsOnly) then return false end
    if(weapon.FireTargetLayerCapsTable) then
        local completeTargetLayerList = ''
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(
            string.find(completeTargetLayerList,"Sub") 
            --or string.find(completeTargetLayerList,"Seabed") 
        ) then
            return true
        end
    end

    return false
end

local dirtree ={
    _VERSION = '0.2',
    _DESCRIPTION = 'DPS Calculator',
}

function PhxWeapDPS(bp,weapon)
    -- Original Code by Uveso, edited by Phoenix
    local DPS = {}
    DPS.RateOfFire = 0
    DPS.Ttime = 0
    DPS.Damage = 0
    DPS.DPS = 0
    DPS.Range = 0
    DPS.WeaponName = (weapon.Label or "None") .. 
                     "/" .. (weapon.DisplayName or "None")
    DPS.UnitName = cleanUnitName(bp)
    DPS.Warn = ''

    local debug = true

    local numRackBones = 0
    local numMuzzleBones = 0
    if weapon.RackBones then
        
        numRackBones = table.getn(weapon.RackBones) or 0

        if(weapon.RackBones[1].MuzzleBones) then
            numMuzzleBones = table.getn(weapon.RackBones[1].MuzzleBones)
        end
        
        if(debug) then print("Racks: " .. numRackBones .. ", Rack 1 Muzzles: " .. numMuzzleBones) end
    end


    -- enable debug text
    local bugtext = false
    if weapon.DPSOverRide then
        DPS.Damage = weapon.DPSOverRide
        DPS.Ttime = 1

    elseif weapon.DummyWeapon == true or weapon.Label == 'DummyWeapon' then
        --skip dummy weapons
        DPS.Damage = 0
        DPS.Ttime = 1

    elseif weapon.WeaponCategory  == 'Kamikaze' then
        --Suicide Weapons have no RateOfFire
        DPS.Ttime = 1
        DPS.Damage = weapon.Damage

    -- Check for Continous Beams
    --   NOTE: This will throw out lots of logic as beam turns on only
    --         once and then do damage continuously. That's ok for now.
    elseif (weapon.ContinuousBeam and weapon.BeamLifetime==0) then
        if(debug) then print("Continuous Beam") end
        local timeToTriggerDam = math.max(weapon.BeamCollisionDelay,0.1)

        DPS.cBeamTimeError = DPS.Ttime 
        DPS.Ttime = math.ceil(timeToTriggerDam*10)/10
        DPS.cBeamTimeError = DPS.MaxTimeError - DPS.Ttime

        DPS.Damage = weapon.Damage

    -- elseif weapon.BeamLifetime and weapon.BeamLifetime > 0 then
    --     if(debug) then print("Pulse Beam") end
    --     local BeamLifetime = math.ceil(weapon.BeamLifetime*10)/10
    --     DPS.Ttime = math.max(BeamLifetime,(math.ceil(10/weapon.RateOfFire) / 10))
    --     DPS.Ttime = math.max(0.1,DPS.Ttime)
    --     local BeamTriggerTime = math.max(0.1,weapon.BeamCollisionDelay)
    --     DPS.Damage = weapon.Damage * weapon.BeamLifetime / BeamTriggerTime

    elseif (weapon.RackBones) then
        -- TODO: Need a better methodology to identify single-shot and
        --       multi-muzzle/rack weapons
        if(debug) then print("Multiple Rack/Muzzles") end

        -- This is extracted from coversations with people, not actual code
        --  It is supposed to be time between onFire events
        local onFireTime = math.max(0.1,math.ceil(10/weapon.RateOfFire)/10)

        -- Muzzles Cycle
        local muzzleTime =  (weapon.MuzzleSalvoDelay  or 0) +
                            (weapon.MuzzleChargeDelay or 0)

        if weapon.MuzzleSalvoDelay == 0 then  -- These are special for a dumb if() in code
            DPS.Damage = weapon.Damage * numMuzzleBones
            muzzleTime = muzzleTime * numMuzzleBones
        else  -- These are the standard calculations
            DPS.Damage = weapon.Damage * (weapon.MuzzleSalvoSize or 1)
            muzzleTime = muzzleTime * (weapon.MuzzleSalvoSize or 1)
        end

        if(weapon.RackFireTogether) then 
            DPS.Damage = DPS.Damage * numRackBones
            muzzleTime = muzzleTime * numRackBones
        elseif (numRackBones > 1) then
            muzzleTime = math.max(muzzleTime, onFireTime) * numRackBones
            DPS.Damage = DPS.Damage * numRackBones
        end
        --TODO: Rack Salvo Size Fix

        -- Check for Beams that trigger multiple times
        local BeamLifetime = (weapon.BeamLifetime or 0)
        if(BeamLifetime > 0) then
            if(debug) then print("Pulse Beam") end
            
            DPS.BeamLifeTimeError = BeamLifetime
            BeamLifetime = math.ceil(BeamLifetime*10)/10
            DPS.BeamLifeTimeError = DPS.BeamLifeTimeError - BeamLifetime

            local BeamTriggerTime = math.max(0.1,weapon.BeamCollisionDelay)

            DPS.Ttime = math.max(BeamLifetime,0.1,DPS.Ttime)
            DPS.Damage = DPS.Damage * BeamLifetime / BeamTriggerTime
        end

        local rechargeTime = 0
        if(weapon.EnergyRequired and 
           weapon.EnergyRequired > 0 and 
           not weapon.RackSalvoFiresAfterCharge) then
            rechargeTime = weapon.EnergyRequired / 
                           weapon.EnergyDrainPerSecond
            if (rechargeTime < 0.1) then
                rechargeTime = 0.1
            end
        end

        local RackTime = (weapon.RackSalvoReloadTime or 0) + 
                         (weapon.RackSalvoChargeTime or 0)

        -- RackTime is in parallel with energy-based recharge time
        local rackNchargeTime = math.max(RackTime,rechargeTime)
        
        DPS.rackNchargeTimeError = rackNchargeTime
        rackNchargeTime = math.ceil(rackNchargeTime*10)/10
        DPS.rackNchargeTimeError = DPS.rackNchargeTimeError - rackNchargeTime
        
        -- RateofFire is always in parallel
        -- MuzzleTime is added to rackTime and energy-based recharge time
        --print("Quick Debug: ",muzzleTime,',',rackNchargeTime,',',math.ceil(10/weapon.RateOfFire)/10)
        DPS.Ttime = math.max(   
                                muzzleTime + rackNchargeTime, 
                                onFireTime
                            )

        -- TODO: Add additional time if( WeaponUnpacks && WeaponRepackTimeout > 0 && RackSalvoChargeTime <= 0) 
        -- {add_time WeaponRepackTimeout}

    -- TODO: Talk to Sprouto about DOTs
    --   I think this is correct, may need to add a safety catch for
    --   DoTTime > Ttime(?) or DoTTime > onFireTime
    if(weapon.DoTPulses) then 
        DPS.Damage = DPS.Damage * weapon.DoTPulses
        if(weapon.DoTTime > DPS.Ttime) then 
            DPS.Warn = DPS.Warn .. "Possible_DoT_overrun,"
        end
    end

    -- elseif weapon.DoTPulses then -- Not verified by DJO yet.
    --     if(debug) then print("DoTPulses") end
    --     DPS.Ttime = (math.ceil(10/weapon.RateOfFire) / 10)
    --     DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize * weapon.DoTPulses

    else
        if(debug) then print("Unknown") end
        print("ERROR: Weapon Type Undetermined")
        DPS.Warn = DPS.Warn .. 'Unknown Type,'
        DPS.Damage = 0
        DPS.Ttime = 1
    end

    -- TODO: Migrated this up to main Rack/Muzzle Code, might 
    --       have screwed up some edge cases
    -- if(weapon.EnergyRequired and 
    --    weapon.EnergyRequired > 0 and 
    --    weapon.RackSalvoFiresAfterCharge==false) then
    --     local rechargeRoF = weapon.EnergyDrainPerSecond/weapon.EnergyRequired
    --     DPS.RateOfFire = math.min(DPS.RateOfFire,rechargeRoF)
    --     DPS.RateOfFire = 1 / (math.max(round(10/DPS.RateOfFire),1) / 10)
    -- end

    -- TODO: Add warning code to check if RateOfFire has rounding error problem (ie., RoF = 3 --> TimeToFire = 0.333 --> 0.4)
    -- TODO: Add warning code to check if(RackReloadTimeout>0 and numRackBones > 1)
    
    -- DONE: Check if(MuzzleSalvoDelay == 0 and MuzzleBones ~= MuzzleSalvoSize)
    if (weapon.MuzzleSalvoDelay == 0) and (numMuzzleBones ~= (weapon.MuzzleSalvoSize or 1)) then 
        DPS.Warn = DPS.Warn.."MuzzleSalvoSize_Overridden,"
    end
    --    || Results in MuzzleBones firing, MuzzleSalvoSize
    --    || Issue in deafaultweapons.lua Line 850

    if DPS.RateOfFire == 0 then DPS.RateOfFire = 1 end
    --print(' Damage: '..DPS.Damage..' - RateOfFire: '..DPS.RateOfFire..' - new DPS: '..(DPS.Damage*DPS.RateOfFire))
    DPS.RateOfFire = 1/DPS.Ttime
    DPS.DPS = DPS.Damage/DPS.Ttime
    DPS.Range = weapon.MaxRadius or 0

    -- Categorize DPS
    DPS.subDPS = 0
    DPS.airDPS = 0
    DPS.srfDPS = 0
    if(canTargetHighAir(weapon)) then
        DPS.airDPS = DPS.DPS
        if(debug) then print("air") end
    end
    if(canTargetSubs(weapon)) then
        DPS.subDPS = DPS.DPS
        if(debug) then print("sub") end
    else
        DPS.srfDPS = DPS.DPS
        if(debug) then print("surface") end
    end

    return DPS
end

return PhxWeapDPS