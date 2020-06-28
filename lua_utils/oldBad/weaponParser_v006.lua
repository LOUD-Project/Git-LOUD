-- This file is the initial pass for debugging PhxWeapDPS
-- all files are scanned and output to output.csv
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
    -- Helper function that replaces the SCFA function UnitBlueprint() and
    --   instead concatinates all BPs into "allBlueprints"
    -- Required Globals (bad practice I know, but kludge.)
    --    curBlueprint
    --    allBlueprints
    countBPs = countBPs + 1
    table.insert(allBlueprints, bp)
    curBlueprint = bp
end

function Sound(list)
    -- Helper function that replaces the SCFA function Sound()
    return list
end

-- Initial loop that finds and runs each BP file in the path given
-- This will generate the following:
--   allBlueprints - a single table with all BPs in it.
--   allShortIDs - a table of UnitIDSs for all BPs
--   allFullDirs - a table of full directory path to each BP
local baseFolder = "../../gamedata"
print("Reading blueprints...")
print("Scanning all folders in " .. baseFolder)
for filename, attr in dirtree("../../gamedata/") do
    if string.find(filename, '.*/units/.*_unit%.bp') then
        -- filename = "./modDir/units/UAL0402_unit.bp"

        --print("Found Matching File:", filename)
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
local outputFileName = "output.csv"
local file = io.open(outputFileName, "w+")
io.output(file)
io.write(
                "ID" 
                .. "," .. "Unit Name"
                .. "," .. "tSurfDPS"
                .. "," .. "tSubDPS"
                .. "," .. "tAirDPS"
                .. "," .. "maxRange"
                .. "," .. "Warnings"
                .. "\n"
            )

for curBPid,curBP in ipairs(allBlueprints) do
    local curShortID = (allShortIDs[curBPid] or "None")
    local tSurfDPS = 0
    local tSubDPS = 0
    local tAirDPS = 0
    local maxRange = 0
    local tWarn = ''

    if curBP.Weapon then
        local NumWeapons = table.getn(curBP.Weapon)
        print("**" .. curShortID .. "/" .. cleanUnitName(curBP) 
            .. " has " .. NumWeapons .. " weapons" 
            --.. " and is stored in " .. (allFullDirs[curBPid] or "None")
        )
        for curWepID,curWep in ipairs(curBP.Weapon) do
            local DPS = PhxWeapDPS(curWep)
            print(curShortID ..
                "/" .. DPS.WeaponName ..
                ': has Damage: ' .. DPS.Damage ..
                ' - Time: ' .. DPS.Ttime ..
                ' - new DPS: ' .. (DPS.Damage/DPS.Ttime)
            )

            if(maxRange < DPS.Range) then maxRange = DPS.Range end
            tSurfDPS = tSurfDPS + DPS.srfDPS
            tSubDPS = tSubDPS + DPS.subDPS
            tAirDPS = tAirDPS + DPS.airDPS

            --Do per weapon checking here
            tWarn = tWarn .. DPS.Warn

            print(" ")  -- End of Weapon Analysis
        end --Weapon For Loop
    else
        print(curShortID .. "/" .. (curBP.Description or "None") .. 
            " has NO weapons")
    end

    --Record Accumulated Values and Final Values

    io.write(
        curShortID 
        .. "," .. cleanUnitName(curBP)
        .. "," .. tSurfDPS
        .. "," .. tSubDPS
        .. "," .. tAirDPS
        .. "," .. maxRange
        .. "," .. tWarn
        .. "\n"
    )
end -- Blueprint for() Loop

io.close(file)
