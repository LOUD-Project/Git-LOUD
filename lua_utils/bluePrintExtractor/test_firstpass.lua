local inspect = require('inspect')
local dirtree = require('dirtree')

local allBlueprints = {}
print(inspect(allBlueprints))

function UnitBlueprint(bp)
    table.insert(allBlueprints, bp)
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

dofile("./BSS0401_unit_trimmed.bp")
dofile("./BSS0401_unit_trimmed.bp")
print(inspect(allBlueprints))

--print(allBlueprints[2].AI.AttackAngle)

--print(bob.BuildIconSortPriority)
-- Code by David Kastrup
-- Borrowed from http://lua-users.org/wiki/DirTreeIterator

for filename, attr in dirtree(".") do
--for filename, attr in dirtree("../SCFA_Git3/Git-LOUD/gamedata") do
        --print(attr.mode, filename)
        if string.find(filename, '.*[.]bp') then
        --if string.find(filename, '.*/units/.*[.]bp') then
            print("Found Matching File:", filename)
        print(filename)
        dofile(filename)
    end

end
--print(allBlueprints[2].AI.AttackAngle)
--print(allBlueprints[3].AI.AttackAngle)

for i,bp in ipairs(allBlueprints) do
    print(i,bp.MaxSpeed.AttackAngle)
end
