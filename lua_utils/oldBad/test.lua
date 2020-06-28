local inspect = require('inspect')
local dirtree = require('dirtree')

local allBlueprints = {}
local curBlueprint = {}
local allShortIDs = {}
local allFullDirs = {}
print(inspect(allBlueprints))

function UnitBlueprint(bp)
    table.insert(allBlueprints, bp)
    curBlueprint = bp
end

function Sound(list)
    return list
end

function MeshBlueprint(list)
    return list
end

function TrailEmitterBlueprint(list)
    return list
end

--print(allBlueprints[2].AI.AttackAngle)

--print(bob.BuildIconSortPriority)
-- Code by David Kastrup
-- Borrowed from http://lua-users.org/wiki/DirTreeIterator

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

        print(UnitBaseName)
        dofile(filename)
        table.insert(allShortIDs, UnitBaseName)
        table.insert(allFullDirs, filename)
    end

end
--print(allBlueprints[2].AI.AttackAngle)
--print(allBlueprints[3].AI.AttackAngle)

for curBPid,curBP in ipairs(allBlueprints) do
    --print(allShortIDs[i], "has max speed", bp.Physics.MaxSpeed, "is stored in", allFullDirs[i])
    NumWeapons = table.getn(curBP.Weapon)
    print(allShortIDs[curBPid], "has ", NumWeapons, "weapons and is stored in", allFullDirs[curBPid])
    for curWepID,curWep in ipairs(curBP.Weapon) do
        if curWep.RackBones then
            numRackBones = table.getn(curWep.RackBones)
            if(numRackBones > 1) then 
                print(allShortIDs[curBPid], "has ", numRackBones)---Move to Warning Log file
            end
            print(allShortIDs[curBPid], "has weapon", curWep.Label, 
                "with dps =", curWep.MuzzleSalvoDelay * curWep.MuzzleSalvoSize)
         end
    end
end
--  print(string.match("./modDir3/units/UAL0204_unit.bp", '[%a%d]*_unit%.bp$'))
