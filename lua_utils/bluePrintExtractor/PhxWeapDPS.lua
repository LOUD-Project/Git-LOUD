-- Heavily modified by Phoenix
-- Contributions by Uveso, Balthazar, Sprouto
local PhxWeapDPS ={
    _VERSION = '1.0',
    _DESCRIPTION = 'DPS Calculator',
}

local canTargetHighAir = require('PhxLib').canTargetHighAir
local canTargetLand = require('PhxLib').canTargetLand
local canTargetSubs = require('PhxLib').canTargetSubs

local inspect = require('inspect')

function PhxWeapDPS(weapon)
    -- Inputs: weapon blueprint
    -- Outputs: DPS table with:
    --            Ttime - total time for all racks+muzzles+recharges etc.
    --            RateOfFire - 1/(Ttime)
    --              NOTE: Not blueprint weapon RoF!
    --            Damage - Alpha Strike or Impulse Damage
    --            Range
    --            WeaponName
    --            Warn - A comma-delimited list of special warnings
    --            subDPS - DPS to submarine vessels (not seafloor)
    --            airDPS - DPS to High Altitude Air 
    --            srfDPS - DPS to surface targets (land and sea)
    --            DPS - Total DPS to any one target (not the sum of above!)

    local DPS = {}
    local Ttime = 0
    local Tdamage = 0
    DPS.Range = weapon.MaxRadius or 0
    DPS.WeaponName = (weapon.Label or "None") .. 
                     "/" .. (weapon.DisplayName or "None")
    local Warn = ''

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
    local BeamLifetime = (weapon.BeamLifetime or 0)

    if weapon.DPSOverRide then
        -- Override of script-based weapons (like drones)
        Tdamage = weapon.DPSOverRide
        Ttime = 1

    elseif weapon.DummyWeapon == true or weapon.Label == 'DummyWeapon' then
        --skip dummy weapons
        Tdamage = 0
        Ttime = 1

    elseif weapon.WeaponCategory  == 'Kamikaze' then
        --Suicide Weapons have no RateOfFire
        Ttime = 1
        Tdamage = weapon.Damage

    -- Check for Continous Beams
    --   NOTE: This will throw out lots of logic as beam turns on only
    --         once and then do damage continuously. That's ok for now.
    elseif (weapon.ContinuousBeam and BeamLifetime==0) then
        if(debug) then print("Continuous Beam") end
        local timeToTriggerDam = math.max(weapon.BeamCollisionDelay,0.1)

        Ttime = math.ceil(timeToTriggerDam*10)/10
        Tdamage = weapon.Damage

    elseif (numRackBones > 0) then
        -- TODO: Need a better methodology to identify single-shot and
        --       multi-muzzle/rack weapons
        if(debug) then print("Multiple Rack/Muzzles") end

        -- This is extrapolated from coversations with people, not actual code
        --  It is supposed to be time between onFire() events
        local onFireTime = math.max(0.1,math.ceil(10/weapon.RateOfFire)/10)

        -- Each Muzzle Cycle Time
        local MuzzleSalvoDelay = (weapon.MuzzleSalvoDelay or 0)
        local muzzleTime =  MuzzleSalvoDelay +
                            (weapon.MuzzleChargeDelay or 0)

        if not(MuzzleSalvoDelay == 0) then  
            -- These are the standard calculations
            -- Each Muzzle spawns a projectile and takes muzzleTime to do so
            Tdamage = weapon.Damage * (weapon.MuzzleSalvoSize or 1)
            muzzleTime = muzzleTime * (weapon.MuzzleSalvoSize or 1)
        else  
            -- These are special catch for a dumb if() statement
            --    || Issue in deafaultweapons.lua Line 850
            
            -- Warn if the number of MuzzleBones doesn't equal the MuzzleSalvoSize
            if (numMuzzleBones ~= (weapon.MuzzleSalvoSize or 1)) then 
                Warn = Warn.."MuzzleSalvoSize_Overridden,"
            end

            -- either way report the actual DPS (but likely unintended)
            Tdamage = weapon.Damage * numMuzzleBones
            muzzleTime = muzzleTime * numMuzzleBones

        end

        -- If RackFireTogether is set, then each rack also fires all muzzles
        --  all in RackSalvoFiringState without exiting to another state
        if(weapon.RackFireTogether) then 
            Tdamage = Tdamage * numRackBones
            muzzleTime = muzzleTime * numRackBones
        elseif (numRackBones > 1) then
            --  However, racks go back to RackSalvoFireReadyState and wait
            --   for OnFire() event
            muzzleTime = math.max(muzzleTime, onFireTime) * numRackBones
            Tdamage = Tdamage * numRackBones
        end

        -- Check for Beams that trigger multiple times
        if(BeamLifetime > 0) then
            if(debug) then print("Pulse Beam") end
            
            -- Beam damage events can only trigger on ticks, therefore round
            --  both BeamLifetime and BeamTriggerTime
            BeamLifetime = math.ceil(BeamLifetime*10)/10
            local BeamTriggerTime = math.max(0.1,weapon.BeamCollisionDelay)
            BeamTriggerTime = math.ceil(BeamTriggerTime*10)/10

            Ttime = math.max(BeamLifetime,0.1,Ttime)
            Tdamage = Tdamage * BeamLifetime / BeamTriggerTime
        end

        local rechargeTime = 0
        local energyRequired = (weapon.EnergyRequired or 0)
        if(energyRequired > 0 and 
           not weapon.RackSalvoFiresAfterCharge) then
            rechargeTime = energyRequired / 
                           weapon.EnergyDrainPerSecond
            rechargeTime = math.ceil(rechargeTime*10)/10
            rechargeTime = math.max(0.1,rechargeTime)
        end

        local RackTime = (weapon.RackSalvoReloadTime or 0) + 
                         (weapon.RackSalvoChargeTime or 0)

        -- RackTime is in parallel with energy-based recharge time
        local rackNchargeTime = math.max(RackTime,rechargeTime)
        rackNchargeTime = math.ceil(rackNchargeTime*10)/10
        
        -- RateofFire is always in parallel
        -- MuzzleTime is added to rackTime and energy-based recharge time
        --print("Quick Debug: ",muzzleTime,',',rackNchargeTime,',',math.ceil(10/weapon.RateOfFire)/10)
        Ttime = math.max(   
                                muzzleTime + rackNchargeTime, 
                                onFireTime
                            )

        --   This is correct method for DoT, which happen DoTPulses 
        --   times and stack infinately
        if(weapon.DoTPulses) then 
            Tdamage = Tdamage * weapon.DoTPulses
        end

        -- This is a rare weapon catch that skips OnFire() and
        --   EconDrain entirely, its kinda scary.
        if(weapon.RackSalvoFiresAfterCharge and 
           weapon.RackSalvoReloadTime>0 and
           weapon.RackSalvoChargeTime>0
          ) then
            Ttime = muzzleTime + RackTime
            Warn = Warn .. "RackSalvoFiresAfterCharge_ComboWarn,"
        end
        -- Units Affected: 
        -- UAB2204 (T2 Aeon? Flak), 
        -- XSB3304 (T3 Sera Flak), 
        -- XSS0202 (T2 Sera Cruiser),
        -- WRA0401, 

        -- TODO: Add additional time if( WeaponUnpacks && WeaponRepackTimeout > 0 && RackSalvoChargeTime <= 0) 
        -- {add_time WeaponRepackTimeout}
        -- This only matters if SkipReadState is true and we enter Unpack more than once.
        if(weapon.SkipReadyState and weapon.WeaponUnpacks) then
            Warn = Warn .. "SkipReadyState_addsUnpackDelay,"
        end

        -- TODO: Another oddball case, if SkipReadyState and not 
        --   RackSalvoChargeTime>0 and not WeaponUnpacks then Econ 
        --   drain doesn't get checked.  Otherwise behaves normally(?).
        -- Only three units /w : BRPAT2BOMBER, DEA0202, XSA0202

    else
        if(debug) then print("Unknown") end
        print("ERROR: Weapon Type Undetermined")
        Warn = Warn .. 'Unknown Type,'
        Tdamage = 0
        Ttime = 1
    end

    -- TODO: Add warning code to check if RateOfFire has rounding error problem (ie., RoF = 3 --> TimeToFire = 0.333 --> 0.4)
    -- TODO: Add warning code to check if(RackReloadTimeout>0 and numRackBones > 1)
    
    DPS.RateOfFire = 1/Ttime
    DPS.DPS = Tdamage/Ttime
    DPS.Damage = Tdamage
    DPS.Ttime = Ttime

    -- Categorize DPS
    DPS.subDPS = 0
    DPS.airDPS = 0
    DPS.srfDPS = 0
    --Weapons that can target air also are allowed to be counted as 
    --  surf/sub damge
    if(canTargetHighAir(weapon)) then
        DPS.airDPS = Tdamage/Ttime
        if(debug) then print("air") end
    end

    --Since "Surface" and "Sub" both include water sub damage must 
    --  override surface damage.
    if(canTargetSubs(weapon)) then
        DPS.subDPS = Tdamage/Ttime
        if(debug) then print("sub") end
    elseif (canTargetLand(weapon)) then
        DPS.srfDPS = Tdamage/Ttime
        if(debug) then print("surface") end
    end

    DPS.Warn = Warn

    return DPS
end

return PhxWeapDPS