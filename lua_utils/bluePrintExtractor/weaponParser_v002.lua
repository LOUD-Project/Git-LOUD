local inspect = require('inspect')
local dirtree = require('dirtree')
local uvesoWeapDPS = require('uvesoWeapDPS')

local allBlueprints = {}
local curBlueprint = {}
local allShortIDs = {}
local allFullDirs = {}
--print(inspect(allBlueprints))

function UnitBlueprint(bp)
    table.insert(allBlueprints, bp)
    curBlueprint = bp
end

function Sound(list)
    return list
end

for filename, attr in dirtree(".") do
--for filename, attr in dirtree("../SCFA_Git3/Git-LOUD/gamedata") do
        --print(attr.mode, filename)
    --if string.find(filename, '.*[.]bp') then
    if string.find(filename, '.*/units/.*[.]bp') then
        -- filename = "./modDir2/units/UAL0402_unit.bp"

        print("Found Matching File:", filename)
        UnitBaseName = string.match(filename, '[%a%d]*_unit%.bp$')
        -- UnitBaseName = "UAL0402_unit.bp"

        local strStrt = 1
        local strStop = string.find(UnitBaseName,"[_%.]") -1 --Find first _ or .
        UnitBaseName = string.sub(UnitBaseName,strStrt,strStop)
        -- UnitBaseName = "UAL0402"

        --print(UnitBaseName)
        dofile(filename)
        table.insert(allShortIDs, UnitBaseName)
        table.insert(allFullDirs, filename)
    end

end
--print(allBlueprints[2].AI.AttackAngle)
--print(allBlueprints[3].AI.AttackAngle)
local curDPS = 0
local curDam = 0
local curTimeToFire = 0

for curBPid,curBP in ipairs(allBlueprints) do
    --print(allShortIDs[i], "has max speed", bp.Physics.MaxSpeed, "is stored in", allFullDirs[i])
    local NumWeapons = table.getn(curBP.Weapon)
    print(allShortIDs[curBPid] .. " has " .. NumWeapons .. " weapons and" ..
          " is stored in" .. allFullDirs[curBPid])
    for curWepID,curWep in ipairs(curBP.Weapon) do
        if not curWep.DummyWeapon == true then --skip dummy weapons
            curTimeToFire = 0

            if curWep.BeamLifetime then -- This is a Beam Weapons
                curDPS = curWep.BeamLifetime / math.max(curWep.BeamCollisionDelay, 0.1) * curWep.Damage * curWep.RateOfFire
            end

            if curWep.RackBones and curWep.BallisticArc ~= 'RULEUBA_None' then -- Stadnard Proj. Weap.
                local numRackBones = table.getn(curWep.RackBones)
                if(numRackBones > 1) then 
                    print(allShortIDs[curBPid] .. " weapon " .. curWep.Label .. " has " ..
                        numRackBones .. " Rack Bones")   -- TODO: Move to Warning Log file
                end

                if(curWep.EnergyRequired) then
                    local rechargeTime = curWep.EnergyRequired/curWep.EnergyDrainPerSecond
                    curTimeToFire = math.max(curTimeToFire,rechargeTime)
                end
                curTimeToFire = math.max(curTimeToFire, curWep.MuzzleSalvoDelay*curWep.MuzzleSalvoSize )
                curTimeToFire = math.max(curTimeToFire, 1/curWep.RateOfFire)
                curDam = curWep.Damage * curWep.MuzzleSalvoSize
                curDPS = (curDam / curTimeToFire )
            end
            print(allShortIDs[curBPid] .. " has weapon " .. curWep.Label ..
            " with dps = " .. curDPS)
        end
    end
end
--  print(string.match("./modDir3/units/UAL0204_unit.bp", '[%a%d]*_unit%.bp$'))

print("...Uveso Run Begining...")

for curBPid,curBP in ipairs(allBlueprints) do
    --print(allShortIDs[i], "has max speed", bp.Physics.MaxSpeed, "is stored in", allFullDirs[i])
    local NumWeapons = table.getn(curBP.Weapon)
    print(allShortIDs[curBPid] .. "/" .. curBP.Description .. 
          " has " .. NumWeapons .. " weapons" ..
          " and is stored in " .. allFullDirs[curBPid])
    for curWepID,curWep in ipairs(curBP.Weapon) do
        --print(allShortIDs[curBPid] .. " is stored in " .. allFullDirs[curBPid])
        local DPS = uvesoWeapDPS(curBP,curWep)
        print(allShortIDs[curBPid] ..
              "/" .. DPS.WeaponName ..
              ': has Damage: ' .. DPS.Damage ..
              ' - RateOfFire: ' .. DPS.RateOfFire ..
              ' - new DPS: ' .. (DPS.Damage*DPS.RateOfFire))
        print(" ")
    end
end