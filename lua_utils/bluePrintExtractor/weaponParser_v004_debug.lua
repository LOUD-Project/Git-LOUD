

-- This example code looks at all the units in the 4DC Modpack. It was utilized to check 
--   more edge cases.

local inspect = require('inspect')
local dirtree = require('dirtree')
local PhxWeapDPS = require('PhxWeapDPS')

local allBlueprints = {}
local curBlueprint = {}
local allShortIDs = {}
local allFullDirs = {}
local countBPs = 0
local countFiles = 0

function UnitBlueprint(bp)
    countBPs = countBPs + 1
    table.insert(allBlueprints, bp)
    curBlueprint = bp
end

function Sound(list)
    return list
end

for filename, attr in dirtree("../../gamedata/BrewLAN_LOUD/mods/BrewLAN_LOUD/units/SRL0000/") do
--for filename, attr in dirtree("../SCFA_Git3/Git-LOUD/gamedata") do
        --print(attr.mode, filename)
    --if string.find(filename, '.*[.]bp') then
    if string.find(filename, '.*/units/.*_unit%.bp') then
        -- filename = "./modDir2/units/UAL0402_unit.bp"

        print("Found Matching File:", filename)
        UnitBaseName = string.match(filename, '[%a%d]*_unit%.bp$')
        -- UnitBaseName = "UAL0402_unit.bp"

        local strStrt = 1
        local strStop = string.find(UnitBaseName,"[_%.]") - 1 --Find first _ or .
        UnitBaseName = string.sub(UnitBaseName,strStrt,strStop)
        -- UnitBaseName = "UAL0402"

        --print(UnitBaseName)
        countFiles = countFiles + 1
        dofile(filename)
        table.insert(allShortIDs, UnitBaseName)
        table.insert(allFullDirs, filename)

        local BPnum = 1
        while (countFiles ~= countBPs) do
            table.insert(allShortIDs, UnitBaseName .. "_" .. BPnum)
            table.insert(allFullDirs, filename)
            countFiles = countFiles + 1
            BPnum = BPnum + 1
        end 

    end

end

local curDPS = 0
local curDam = 0
local curTimeToFire = 0

print("...PhxWeapDPS Run Beginning...")
local file = io.open("output.csv", "w+")
io.output(file)
io.write(
                "ID".. "," .. 
                "Desc" .. "," ..
                "Weapon".. "," .. 
                "DPS" .. "," ..
                "Range" .. "\n"
            )

for curBPid,curBP in ipairs(allBlueprints) do
    local UnitName = "None"
    if(curBP.General and curBP.General.UnitName) then 
        UnitName = curBP.General.UnitName
    end
    print("index: ", curBPid, "ID: ", allShortIDs[curBPid],
          "called", UnitName ,"from", allFullDirs[curBPid])

end

print("Num allShortIDs: ",table.getn(allShortIDs))
print("Num allFullDirs: ",table.getn(allFullDirs))
print("Num allBlueprints: ",table.getn(allBlueprints))

io.close(file)
