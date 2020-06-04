-- Original Code by Uveso, Modified by Phoenix

local function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local dirtree ={
    _VERSION = '0.2',
    _DESCRIPTION = 'DPS Calculator',
}

function PhxWeapDPS(bp,weapon)
    -- Original Code by Uveso, edited by Phoenix
    local DPS = {}
    DPS.Damage = 0
    DPS.RateOfFire = 0
    DPS.Ttime = 0
    DPS.Damage = 0
    DPS.DPS = 0
    DPS.Range = 0
    DPS.WeaponName = weapon.DisplayName or "No Name"

    local debug = true

    local numRackBones = 0
    local numMuzzleBones = 0
    if weapon.RackBones then
        numRackBones = table.getn(weapon.RackBones) or 0
        if(numRackBones > 1) then 
            DPS.Warn = "Weapon: " .. weapon.Label .. " has " ..
                numRackBones .. " Rack Bones"   -- TODO: Move to Warning Log file
        end
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

    elseif weapon.DummyWeapon == true then --skip dummy weapons
        DPS.Damage = 0
        DPS.Ttime = 1

    elseif weapon.WeaponCategory  == 'Kamikaze' then
        --Suicide Weapons have no RateOfFire
        DPS.Ttime = 1
        DPS.Damage = weapon.Damage

    elseif weapon.DoTPulses then -- Not verified by DJO yet.
        if(debug) then print("DoTPulses") end
        DPS.Ttime = (math.ceil(10/weapon.RateOfFire) / 10)
        DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize * weapon.DoTPulses

    elseif (weapon.ContinuousBeam and weapon.BeamLifetime==0) then
        if(debug) then print("Continuous Beam") end
        local timeToTriggerDam = math.max(weapon.BeamCollisionDelay,0.1)
        DPS.RateOfFire = weapon.RateOfFire
        DPS.Ttime = math.ceil(timeToTriggerDam*10)/10
        DPS.Damage = weapon.Damage

    elseif weapon.BeamLifetime then
        if(debug) then print("Pulse Beam") end
        DPS.RateOfFire = math.min(10, weapon.RateOfFire, weapon.BeamLifetime)
        DPS.Ttime = math.ceil(10/DPS.RateOfFire)/10
        local BeamTriggerTime = math.max(0.1,weapon.BeamCollisionDelay)
        DPS.Damage = weapon.Damage * weapon.BeamLifetime / BeamTriggerTime

    -- elseif (weapon.RackSalvoReloadTime and weapon.RackSalvoReloadTime > 0) and not weapon.RackSalvoFiresAfterCharge then
    --     print("Rack Salvos")
    --     -- Don't use weapon.RateOfFire
    --     DPS.RateOfFire = 1 / ((weapon.MuzzleSalvoSize * weapon.MuzzleSalvoDelay + weapon.RackSalvoReloadTime))
    --     DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize

    elseif (weapon.RackBones) then
        -- TODO: Need a better methodology to identify single-shot and
        --       multi-muzzle/rack weapons
        if(debug) then print("Multiple Rack/Muzzles") end
        --print("Weapon RoFs Options: " .. weapon.RateOfFire .. " , " .. 1/(weapon.MuzzleSalvoDelay*weapon.MuzzleSalvoSize) )
        DPS.Ttime = math.ceil((weapon.MuzzleSalvoDelay or 0)*10)/10 + DPS.Ttime
        DPS.Ttime = math.ceil((weapon.MuzzleChargeDelay or 0)*10)/10 + DPS.Ttime
        DPS.Ttime = (weapon.MuzzleSalvoSize or 1) * DPS.Ttime

        DPS.Damage = weapon.Damage * (weapon.MuzzleSalvoSize or 1)
        if(weapon.RackFireTogether) then 
            DPS.Damage = DPS.Damage * numRackBones
            DPS.Ttime = DPS.Ttime * numRackBones
        end

        DPS.Ttime = (weapon.RackSalvoChargeTime or 0) + DPS.Ttime
        DPS.Ttime = (weapon.RackSalvoReloadTime or 0) + DPS.Ttime

        -- I'm still a little confused, does energy charge happen in parallel?
        local rechargeTime = 0
        if(weapon.EnergyRequired and 
           weapon.EnergyRequired > 0 and 
           weapon.RackSalvoFiresAfterCharge==false) then
            rechargeTime = (weapon.EnergyRequired or 0) / 
                           (weapon.EnergyDrainPerSecond or 0)
        end

        -- I'm pretty certain, but not positive that RateOfFire happens in parallel
        DPS.Ttime = math.max(   0.1,
                                math.ceil(10*rechargeTime)/10, 
                                math.ceil(10/weapon.RateOfFire)/10,
                                DPS.Ttime)

        --Add additional time if(RackSalvoChargeTime > 0) {add time RackSalvoChargeTime}

        --Add additional time if( WeaponUnpacks && WeaponRepackTimeout > 0 && RackSalvoChargeTime <= 0) 
        -- {add_time WeaponRepackTimeout}

    else
        if(debug) then print("Unknown") end
        print("ERROR: Weapon Type Undetermined")

    end

    if(weapon.EnergyRequired and 
       weapon.EnergyRequired > 0 and 
       weapon.RackSalvoFiresAfterCharge==false) then
        -- TODO: Add Rounding Factor
        local rechargeRoF = weapon.EnergyDrainPerSecond/weapon.EnergyRequired
        DPS.RateOfFire = math.min(DPS.RateOfFire,rechargeRoF)
        DPS.RateOfFire = 1 / (math.max(round(10/DPS.RateOfFire),1) / 10)
    end

    -- TODO: Add code to check if RateOfFire has rounding error problem (ie., RoF = 3 --> TimeToFire = 0.333 --> 0.4)

    -- TODO: Rework RoF to include 0.1 second rounding

    -- TODO: Add a check that if(RackReloadTimeout>0 and numRackBones > 1)

    -- TODO: Check if(MuzzleSalvoDelay == 0 and MuzzleBones ~= MuzzleSalvoSize)
    --    || Results in MuzzleBones firing, MuzzleSalvoSize
    --    || Issue in deafaultweapons.lua Line 850

    if DPS.RateOfFire == 0 then DPS.RateOfFire = 1 end
    --print(' Damage: '..DPS.Damage..' - RateOfFire: '..DPS.RateOfFire..' - new DPS: '..(DPS.Damage*DPS.RateOfFire))
    DPS.RateOfFire = 1/DPS.Ttime
    DPS.DPS = DPS.Damage/DPS.Ttime
    DPS.Range = weapon.MaxRadius or 0

    return DPS
end

return PhxWeapDPS