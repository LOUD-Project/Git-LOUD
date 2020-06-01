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
    DPS.DPS = 0
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
        DPS.RoF = 1

    elseif weapon.DummyWeapon == true then --skip dummy weapons
        DPS.RateOfFire = 1
        DPS.Damage = 0
    elseif weapon.WeaponCategory  == 'Kamikaze' then
        --Suicide Weapons have no RateOfFire
        DPS.RateOfFire = 1
        DPS.Damage = weapon.Damage

    elseif weapon.DoTPulses then -- Not verified by DJO yet.
        if(debug) then print("DoTPulses") end
        DPS.RateOfFire = 1 / (round(10/weapon.RateOfFire) / 10)
        DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize * weapon.DoTPulses

    elseif (weapon.ContinuousBeam) then
        if(debug) then print("Continuous Beam") end
        local timeToTriggerDam = math.max(weapon.BeamCollisionDelay,0.1)
        DPS.RateOfFire = weapon.RateOfFire
        DPS.Damage = weapon.Damage * weapon.BeamLifetime / timeToTriggerDam

    elseif weapon.BeamLifetime then
        if(debug) then print("Pulse Beam") end
        DPS.RateOfFire = math.min(10, weapon.RateOfFire, weapon.BeamLifetime)
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
        DPS.RateOfFire = math.min(10, weapon.RateOfFire, 1/(weapon.MuzzleSalvoDelay*weapon.MuzzleSalvoSize))
        DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize
        if(weapon.RackFireTogether) then 
            DPS.Damage = DPS.Damage * numRackBones
        end

    else
        if(debug) then print("One Shot") end
        local MuzzleSalvoSize = weapon.MuzzleSalvoSize or 1
        DPS.RateOfFire = 1 / (round(10/weapon.RateOfFire) / 10)
        DPS.Damage = weapon.Damage * MuzzleSalvoSize

    end

    if(weapon.EnergyRequired and weapon.EnergyRequired > 0) then
        -- TODO: Add Rounding Factor
        local rechargeRoF = weapon.EnergyDrainPerSecond/weapon.EnergyRequired
        DPS.RateOfFire = math.min(DPS.RateOfFire,rechargeRoF)
        DPS.RateOfFire = 1 / (math.max(round(10/DPS.RateOfFire),1) / 10)
    end

    -- TODO: Add code to check if RateOfFire has rounding error problem (ie., RoF = 3 --> TimeToFire = 0.333 --> 0.4)

    -- TODO: Rework RoF to include 0.1 second rounding

    -- TODO: Add a check that if(RackReloadTimeout>0 and numRackBones > 1)

    if DPS.RateOfFire == 0 then DPS.RateOfFire = 1 end
    --print(' Damage: '..DPS.Damage..' - RateOfFire: '..DPS.RateOfFire..' - new DPS: '..(DPS.Damage*DPS.RateOfFire))
    DPS.DPS = DPS.Damage*DPS.RateOfFire
    return DPS
end

return PhxWeapDPS