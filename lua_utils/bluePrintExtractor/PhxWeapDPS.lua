-- Heavily modified by Phoenix
-- Contributions by Uveso, Balthazar, Sprouto
local PhxWeapDPS ={
    _VERSION = '0.4',
    _DESCRIPTION = 'DPS Calculator',
}

local canTargetHighAir = require('PhxLib').canTargetHighAir
local canTargetLand = require('PhxLib').canTargetLand
local canTargetSubs = require('PhxLib').canTargetSubs

local inspect = require('inspect')

function PhxWeapDPS(weapon)
    -- Original Code by Uveso, edited by Phoenix
    local DPS = {}
    DPS.RateOfFire = 0
    DPS.Ttime = 0
    DPS.Damage = 0
    DPS.DPS = 0
    DPS.Range = 0
    DPS.WeaponName = (weapon.Label or "None") .. 
                     "/" .. (weapon.DisplayName or "None")
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

        DPS.Ttime = math.ceil(timeToTriggerDam*10)/10
        DPS.Damage = weapon.Damage

    elseif (weapon.RackBones) then
        -- TODO: Need a better methodology to identify single-shot and
        --       multi-muzzle/rack weapons
        if(debug) then print("Multiple Rack/Muzzles") end

        -- This is extrapolated from coversations with people, not actual code
        --  It is supposed to be time between onFire() events
        local onFireTime = math.max(0.1,math.ceil(10/weapon.RateOfFire)/10)

        -- Muzzles Cycle, MuzzleSalvoDelay
        local muzzleTime =  (weapon.MuzzleSalvoDelay  or 0) +
                            (weapon.MuzzleChargeDelay or 0)
        --print("Quick Debug: ",(weapon.MuzzleSalvoDelay  or 0),",",(weapon.MuzzleChargeDelay  or 0),",",muzzleTime)

        if weapon.MuzzleSalvoDelay == 0 then  
            -- These are special catch for a dumb if() in code
            DPS.Damage = weapon.Damage * numMuzzleBones
            muzzleTime = muzzleTime * numMuzzleBones
        else  -- These are the standard calculations
            DPS.Damage = weapon.Damage * (weapon.MuzzleSalvoSize or 1)
            muzzleTime = muzzleTime * (weapon.MuzzleSalvoSize or 1)
        end
        --print("Quick Debug: ",muzzleTime)

        if(weapon.RackFireTogether) then 
            DPS.Damage = DPS.Damage * numRackBones
            muzzleTime = muzzleTime * numRackBones
        elseif (numRackBones > 1) then
            muzzleTime = math.max(muzzleTime, onFireTime) * numRackBones
            DPS.Damage = DPS.Damage * numRackBones
        end

        -- Check for Beams that trigger multiple times
        local BeamLifetime = (weapon.BeamLifetime or 0)
        if(BeamLifetime > 0) then
            if(debug) then print("Pulse Beam") end
            
            BeamLifetime = math.ceil(BeamLifetime*10)/10
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
        rackNchargeTime = math.ceil(rackNchargeTime*10)/10
        
        -- RateofFire is always in parallel
        -- MuzzleTime is added to rackTime and energy-based recharge time
        --print("Quick Debug: ",muzzleTime,',',rackNchargeTime,',',math.ceil(10/weapon.RateOfFire)/10)
        DPS.Ttime = math.max(   
                                muzzleTime + rackNchargeTime, 
                                onFireTime
                            )

        --   This is correct method for DoT, which happen DoTPulses 
        --   times and stack infinately
        if(weapon.DoTPulses) then 
            DPS.Damage = DPS.Damage * weapon.DoTPulses
        end

        -- This is a rare weapon catch that skips OnFire() and
        --   EconDrain entirely, its kinda scary.
        if(weapon.RackSalvoFiresAfterCharge and 
           weapon.RackSalvoReloadTime>0 and
           weapon.RackSalvoChargeTime>0
          ) then
            DPS.Ttime = muzzleTime + RackTime
            DPS.Warn = DPS.Warn .. "RackSalvoFiresAfterCharge_ComboWarn,"
        end

        -- TODO: Add additional time if( WeaponUnpacks && WeaponRepackTimeout > 0 && RackSalvoChargeTime <= 0) 
        -- {add_time WeaponRepackTimeout}
        -- This only matters if SkipReadState is true and we enter Unpack more than once.
        if(weapon.SkipReadyState and weapon.WeaponUnpacks) then
            DPS.Warn = DPS.Warn .. "SkipReadyState_addsUnpackDelay,"
        end

        -- TODO: Another oddball case, if SkipReadyState and not 
        --   RackSalvoChargeTime>0 and not WeaponUnpacks then Econ 
        --   drain doesn't get checked.  Otherwise behaves normally(?).
        -- Only three units /w : BRPAT2BOMBER, DEA0202, XSA0202

    else
        if(debug) then print("Unknown") end
        print("ERROR: Weapon Type Undetermined")
        DPS.Warn = DPS.Warn .. 'Unknown Type,'
        DPS.Damage = 0
        DPS.Ttime = 1
    end

    -- TODO: Add warning code to check if RateOfFire has rounding error problem (ie., RoF = 3 --> TimeToFire = 0.333 --> 0.4)
    -- TODO: Add warning code to check if(RackReloadTimeout>0 and numRackBones > 1)
    
    -- TODO: SkipReadyState is not modeled yet.
    
    -- DONE: Check if(MuzzleSalvoDelay == 0 and MuzzleBones ~= MuzzleSalvoSize)
    if (weapon.MuzzleSalvoDelay == 0) and (numMuzzleBones ~= (weapon.MuzzleSalvoSize or 1)) then 
        DPS.Warn = DPS.Warn.."MuzzleSalvoSize_Overridden,"
    end
    --    || Results in MuzzleBones firing not MuzzleSalvoSize
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
    --Weapons that can target air also are allowed to be counted as 
    --  surf/sub damge
    if(canTargetHighAir(weapon)) then
        DPS.airDPS = DPS.DPS
        if(debug) then print("air") end
    end

    --Since "Surface" and "Sub" both include water sub damage must 
    --  override surface damage.
    if(canTargetSubs(weapon)) then
        DPS.subDPS = DPS.DPS
        if(debug) then print("sub") end
    elseif (canTargetLand(weapon)) then
        DPS.srfDPS = DPS.DPS
        if(debug) then print("surface") end
    end

    return DPS
end

return PhxWeapDPS