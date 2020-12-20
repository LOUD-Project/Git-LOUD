

-- This example code looks at all the units in the 4DC Modpack. It was utilized to check 
--   more edge cases.

local inspect = require('inspect')
local dirtree = require('dirtree')
local PhxWeapDPS = require('PhxWeapDPS')

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

for filename, attr in dirtree("../../gamedata/units/units") do
--for filename, attr in dirtree("../SCFA_Git3/Git-LOUD/gamedata") do
        --print(attr.mode, filename)
    --if string.find(filename, '.*[.]bp') then
    if string.find(filename, '.*/units/.*_unit[.]bp') then
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
--  print(string.match("./modDir3/units/UAL0204_unit.bp", '[%a%d]*_unit%.bp$'))

print("...Phx-Version Run Begining...")

for curBPid,curBP in ipairs(allBlueprints) do
    --print(allShortIDs[i], "has max speed", bp.Physics.MaxSpeed, "is stored in", allFullDirs[i])
    if curBP.Weapon then
        local NumWeapons = table.getn(curBP.Weapon)
        print(allShortIDs[curBPid] .. "/" .. curBP.Description .. 
            " has " .. NumWeapons .. " weapons" ..
            " and is stored in " .. allFullDirs[curBPid])
        for curWepID,curWep in ipairs(curBP.Weapon) do
            --print(allShortIDs[curBPid] .. " is stored in " .. allFullDirs[curBPid])
            local DPS = PhxWeapDPS(curBP,curWep)
            print(allShortIDs[curBPid] ..
                "/" .. DPS.WeaponName ..
                ': has Damage: ' .. DPS.Damage ..
                ' - Time: ' .. DPS.Ttime ..
                ' - new DPS: ' .. (DPS.Damage/DPS.Ttime))
            print(" ")
        end
    else
        print(allShortIDs[curBPid] .. "/" .. curBP.Description .. 
            " has NO weapons")
    end
end