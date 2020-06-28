

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

local curDPS = 0
local curDam = 0
local curTimeToFire = 0

print("...PhxWeapDPS Run Beginning...")
local file = io.open("output.csv", "w+")
io.output(file)
io.write(
                "ID" 
                .. "," .. "Desc"
                .. "," .. "Weapon"
                .. "," .. "DPS"
                .. "," .. "Range"
                .. "," .. "djoWarn"
                .. "\n"
            )

for curBPid,curBP in ipairs(allBlueprints) do
    --print(allShortIDs[i], "has max speed", bp.Physics.MaxSpeed, "is stored in", allFullDirs[i])
    local curShortID = (allShortIDs[curBPid] or "None")
    if curBP.Weapon then
        local NumWeapons = table.getn(curBP.Weapon)
        print(curShortID .. "/" .. (curBP.Description or "None") .. 
            " has " .. NumWeapons .. " weapons" ..
            " and is stored in " .. (allFullDirs[curBPid] or "None"))
        for curWepID,curWep in ipairs(curBP.Weapon) do
            --print(curShortID .. " is stored in " .. allFullDirs[curBPid])
            local DPS = PhxWeapDPS(curBP,curWep)
            local djoWarn = 'false'
            print(curShortID ..
                "/" .. DPS.WeaponName ..
                ': has Damage: ' .. DPS.Damage ..
                ' - Time: ' .. DPS.Ttime ..
                ' - new DPS: ' .. (DPS.Damage/DPS.Ttime)
            )

            if(
                curWep.MuzzleSalvoDelay and
                curWep.MuzzleSalvoSize and
                curWep.RackBones[curWepID] and
                table.getn(curWep.RackBones[curWepID].MuzzleBones) and
                curWep.MuzzleSalvoDelay == 0 and
                curWep.MuzzleSalvoSize ~= table.getn(curWep.RackBones[curWepID].MuzzleBones)
                ) 
            then
                djoWarn = 'true'
                --io.write("DJO QUICK WARN\n")
            end

            io.write(
                curShortID 
                .. "," .. DPS.UnitName
                .. "," .. DPS.WeaponName
                .. "," .. DPS.Damage/DPS.Ttime
                .. "," .. DPS.Range
                .. "," .. djoWarn
                .. "\n"
            )

            print(" ")  -- End of Weapon Analysis
        end
    else
        print(curShortID .. "/" .. (curBP.Description or "None") .. 
            " has NO weapons")
    end
end

io.close(file)
