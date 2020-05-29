-- Original Code by Uveso, Modified by Phoenix

local function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local dirtree ={
    _VERSION = '0.1',
    _DESCRIPTION = 'DPS Calculator',
}

function UvesoWeapDPS(bp,weapon)
    -- Original Code by Uveso, edited by Phoenix
    local DPS = {}
    DPS.Damage = 0
    DPS.RateOfFire = 0
    DPS.DPS = 0

    -- enable debug text
    local bugtext = false
    if weapon.DoTPulses then
        -- DoTPulses
        DPS.RateOfFire = 1 / (round(10/weapon.RateOfFire) / 10)
        DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize * weapon.DoTPulses
    elseif weapon.ContinuousBeam then
        --Continuous Beam

        --print(' weapon.BeamCollisionDelay='..weapon.BeamCollisionDelay)
        local temp = weapon.BeamCollisionDelay == 0 and 1 or weapon.BeamCollisionDelay
        --print(' temp='..temp)
        DPS.RateOfFire = 1 / (weapon.BeamCollisionDelay == 0 and 1 or weapon.BeamCollisionDelay)
        DPS.Damage = weapon.Damage * 10
    elseif (weapon.BeamLifetime and weapon.BeamLifetime > 0) then
        --Pulse Beam
        local BeamCollisionDelay = weapon.BeamCollisionDelay or 0
        local BeamLifetime = weapon.BeamLifetime or 1
        if BeamLifetime > 5 then
            BeamLifetime = 5
        end
        DPS.RateOfFire = 1 / (round(10/weapon.RateOfFire) / 10)
        DPS.Damage = weapon.Damage * BeamLifetime * 10
    elseif (weapon.RackSalvoReloadTime and weapon.RackSalvoReloadTime > 0) and not weapon.RackSalvoFiresAfterCharge then
        -- Salvos
        -- Don't use weapon.RateOfFire
        DPS.RateOfFire = 1 / ((weapon.MuzzleSalvoSize * weapon.MuzzleSalvoDelay + weapon.RackSalvoReloadTime))
        DPS.Damage = weapon.Damage * weapon.MuzzleSalvoSize
    elseif (weapon.DummyWeapon == true) then
        -- Dummy Weapon - Do nothing
        DPS.RateOfFire = 1
        DPS.Damage = 0
    else
        --One Shot
        local AttackGroundTries = weapon.AttackGroundTries or 1
        local MuzzleSalvoSize = weapon.MuzzleSalvoSize or 1
        DPS.RateOfFire = 1 / (round(10/weapon.RateOfFire) / 10)
        DPS.Damage = weapon.Damage * MuzzleSalvoSize
    end
    if DPS.RateOfFire == 0 then DPS.RateOfFire = 1 end
    --print(' Damage: '..DPS.Damage..' - RateOfFire: '..DPS.RateOfFire..' - new DPS: '..(DPS.Damage*DPS.RateOfFire))
    DPS.DPS = DPS.Damage*DPS.RateOfFire
    return DPS
end

return UvesoWeapDPS