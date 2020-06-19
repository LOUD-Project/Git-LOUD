-- This file is the initial pass for debugging PhxWeapDPS
-- all BP files are scanned, DPS and threat is calcualted on a per weapon basis
-- and output to outputFileName
local outputFileName = "output_fullSSwThreat.csv"

-- Threat Balance Constants
-- see: https://docs.google.com/document/d/1oMpHiHDKjTID0szO1mvNSH_dAJfg0-DuZkZAYVdr-Ms/edit
local SpeedT2_KNIFE = 3.1
local RangeT2_KNIFE = 25
local RangeAvgEngage = 50
local tEnd = 13.0

local inspect = require('inspect')
local dirtree = require('dirtree')
local PhxWeapDPS = require('PhxWeapDPS')
local cleanUnitName = require('PhxLib').cleanUnitName
local getTechLevel = require('PhxLib').getTechLevel

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

print("...Phx DPS and Threat Run Beginning...")
local file = io.open(outputFileName, "w+")
io.output(file)
io.write(
                "ID" 
                .. "," .. "Unit Name"
                .. "," .. "Tier"
                .. "," .. "Type"
                .. "," .. "Type2"
                .. "," .. "Chassis"
                .. "," .. "ThreatSpd"
                .. "," .. "ThreatRange"
                .. "," .. "ThreatDamHP"
                .. "," .. "ThreatTotal"
                .. "," .. "tSurfDPS"
                .. "," .. "tSubDPS"
                .. "," .. "tAirDPS"
                .. "," .. "totDPS"
                .. "," .. "maxRange"
                .. "," .. "Vision"
                .. "," .. "Shield"
                .. "," .. "Health"
                .. "," .. "Mass"
                .. "," .. "Energy"
                .. "," .. "BuildTime"
                .. "," .. "Speed"
                .. "," .. "Warnings"
                .. "\n"
            )

for curBPid,curBP in ipairs(allBlueprints) do
    local curShortID = (allShortIDs[curBPid] or "None")
    local tSurfDPS = 0
    local tSubDPS = 0
    local tAirDPS = 0
    local totDPS = 0
    local maxRange = 0
    local tWarn = ''

    local Health = 0
    local Shield = 0
    local Speed = 0
    local Mass = 0
    local Energy = 0
    local BuildTime = 0
    local Tier = 0
    local Vision = 0

    local ThreatSpd = 0
    local ThreatRange = 0
    local ThreatDamHP = 0
    local ThreatTotal = 0

    if curBP.Weapon then
        local NumWeapons = table.getn(curBP.Weapon)
        print("**" .. curShortID .. "/" .. cleanUnitName(curBP) 
            .. " has " .. NumWeapons .. " weapons" 
            --.. " and is stored in " .. (allFullDirs[curBPid] or "None")
        )

        -- Run PhxWeapDPS on each weapon, then calculate threat value 
        --  and accumulate into totals for the unit.
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
            totDPS = totDPS + DPS.DPS

            --Do per weapon checking here
            tWarn = tWarn .. DPS.Warn

            print(" ")  -- End of Weapon Import

            -- local SpeedT2_KNIFE = 3.1
            -- local RangeT2_KNIFE = 25
            -- local RangeAvgEngage = 50
            -- local tEnd = 13.0

            ThreatRange = ThreatRange + math.max(0,(DPS.Range - RangeT2_KNIFE)/SpeedT2_KNIFE*DPS.srfDPS/tEnd)
            ThreatDamHP = ThreatDamHP + DPS.srfDPS

        end --Weapon For Loop

        ThreatDamHP = (ThreatDamHP + (Health+Shield)/tEnd)/2
        ThreatSpd = math.max(0,(RangeAvgEngage/SpeedT2_KNIFE - RangeAvgEngage/Speed)*tSurfDPS/tEnd)
        ThreatTotal = ThreatSpd + ThreatRange + ThreatDamHP
    else
        print(curShortID .. "/" .. (curBP.Description or "None") .. 
            " has NO weapons")
    end

    -- Do per unit processing here
    -- TODO: big and hard to read, move to seperate function(s)
    -- Get Health and Shield values, if they exist
    if( curBP.Defense and 
        curBP.Defense.MaxHealth
    ) then 
        Health = (curBP.Defense.MaxHealth or 0)

        if( curBP.Defense.Shield and 
            curBP.Defense.ShieldMaxHealth
        ) then
            Shield = curBP.Defense.Shield.SheildMaxHealth
        else 
            Shield = 0
        end
    else
        Health = 0
    end

    -- Get Speed Value if it exists
    if( curBP.Physics and 
        curBP.Physics.MaxSpeed
    ) then
        Speed = curBP.Physics.MaxSpeed
    else 
        Speed = SpeedT2_KNIFE
    end

    -- Get Economic values for Mass Energy and BuildTime if they exist
    if curBP.Economy then
        Energy = curBP.Economy.BuildCostEnergy or 0
        Mass = curBP.Economy.BuildCostMass or 0
        BuildTime = curBP.Economy.BuildCostMass or 0
    else 
        Energy = 0
        Mass = 0
        BuildTime = 0
    end

    -- Get Tech Level
    Tier = getTechLevel(curBP)

    if curBP.Intel and curBP.Intel.VisionRadius then
        Vision = curBP.Intel.VisionRadius
    end

    --Record Accumulated Values and Final Values
    io.write(
        curShortID 
        .. "," .. cleanUnitName(curBP)
        .. "," .. Tier
        .. "," .. "Type"
        .. "," .. "Type2"
        .. "," .. "Chassis"
        .. "," .. ThreatSpd
        .. "," .. ThreatRange
        .. "," .. ThreatDamHP
        .. "," .. ThreatTotal
        .. "," .. tSurfDPS
        .. "," .. tSubDPS
        .. "," .. tAirDPS
        .. "," .. totDPS
        .. "," .. maxRange
        .. "," .. Vision
        .. "," .. Shield
        .. "," .. Health
        .. "," .. "Mass"
        .. "," .. "Energy"
        .. "," .. "BuildTime"
        .. "," .. Speed
        .. "," .. tWarn
        .. "\n"
    )
end -- Blueprint for() Loop

io.close(file)
