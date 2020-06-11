

-- This example code looks at all the units in the 4DC Modpack. It was utilized to check 
--   more edge cases.

local inspect = require('inspect')
local dirtree = require('dirtree')
local PhxWeapDPS = require('PhxWeapDPS')
local cleanUnitName = require('PhxLib').cleanUnitName

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

for filename, attr in dirtree("../../gamedata/") do
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

print("...PhxWeapDPS Run Beginning...")
local file = io.open("sizes_dewey.csv", "w+")
io.output(file)
io.write(
                "ID" 
                .. "," .. "Unit Name"
                .. "," .. "SizeX"
                .. "," .. "SizeY"
                .. "," .. "SizeZ"
                .. "," .. "UniformScale"
                .. "\n"
            )

for curBPid,curBP in ipairs(allBlueprints) do
    local curShortID = (allShortIDs[curBPid] or "None")

    --Record Accumulated Values and Final Values
    io.write(
        curShortID 
        .. "," .. cleanUnitName(curBP)
        .. "," .. (curBP.SizeX or "None")
        .. "," .. (curBP.SizeY or "None")
        .. "," .. (curBP.SizeZ or "None")
        .. "," .. ((curBP.Display and curBP.Display.UniformScale) or "None")
        .. "\n"
    )
end -- Blueprint for() Loop

io.close(file)
