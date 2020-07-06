-- This file is the initial pass for debugging PhxWeapDPS
-- all BP files are scanned, DPS and threat is calcualted on a per weapon basis
-- summed up per unit and output to outputFileName is spreadsheet friendly format
local outputFileName = "output_fullSSwThreat.csv"

local dirtree = require('dirtree')

dofile('../../gamedata/lua/lua/PhxLib.lua')
local cleanUnitName = PhxLib.cleanUnitName
local getTechLevel = PhxLib.getTechLevel
local getVision = PhxLib.getVision
local getWaterVision = PhxLib.getWaterVision
local calcUnitDPS = PhxLib.calcUnitDPS

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
    -- Dummy function that replaces the SCFA function Sound()
    -- This is required to execute .bp files in commandline LUA interpretter
    return list
end

-- Initial loop that finds and runs each BP file in the path given
-- This will generate the following:
--   allBlueprints - a single table with all BPs in it.
--   allShortIDs - a table of UnitIDSs for all BPs (Stripped from file names)
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
                .. "," .. "Race"
                .. "," .. "Chassis"
                .. "," .. "ThreatSpd"
                .. "," .. "ThreatRange"
                .. "," .. "ThreatHP"
                .. "," .. "SrfThreatTotal"
                .. "," .. "SubThreatTotal"
                .. "," .. "AirThreatTotal"
                .. "," .. "tSurfDPS"
                .. "," .. "tSubDPS"
                .. "," .. "tAirDPS"
                .. "," .. "totDPS"
                .. "," .. "maxRange"
                .. "," .. "Vision"
                .. "," .. "Wvision"
                .. "," .. "Intel"
                .. "," .. "Shield"
                .. "," .. "Health"
                .. "," .. "TorpDefRate"
                .. "," .. "Regen"
                .. "," .. "Mass"
                .. "," .. "Energy"
                .. "," .. "BuildTime"
                .. "," .. "Speed"
                .. "," .. "Warnings"
                .. "\n"
            )

for curBPid,curBP in ipairs(allBlueprints) do
    local curShortID = (allShortIDs[curBPid] or "None")

    local Mass = 0
    local Energy = 0
    local BuildTime = 0
    local Tier = 0
    local Vision = 0
    local Wvision = 0
    local TorpDefRate = 0
    local Race = 'none'
    local Chassis = 'unknown'
    local Intel = ''

    local unitDPS = calcUnitDPS(curShortID,curBP)

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

    Tier = getTechLevel(curBP)
    Vision = getVision(curBP)
    Wvision = getWaterVision(curBP)
    Chassis = PhxLib.getChassis(curBP)
    Intel = PhxLib.getIntel(curBP)
    TorpDefRate = PhxLib.getAntiTorpRate(curBP)

    if curBP.General and curBP.General.FactionName then 
        Race = curBP.General.FactionName
    end
    
    --Record Unit Stats to output file
    io.write(
        curShortID 
        .. "," .. cleanUnitName(curBP)
        .. "," .. Tier
        .. "," .. "Type"
        .. "," .. "Type2"
        .. "," .. Race
        .. "," .. Chassis
        .. "," .. unitDPS.Threat.Speed
        .. "," .. unitDPS.Threat.Range
        .. "," .. unitDPS.Threat.HP
        .. "," .. unitDPS.Threat.srfTotal
        .. "," .. unitDPS.Threat.subTotal
        .. "," .. unitDPS.Threat.airTotal
        .. "," .. unitDPS.srfDPS
        .. "," .. unitDPS.subDPS
        .. "," .. unitDPS.airDPS
        .. "," .. unitDPS.totDPS
        .. "," .. unitDPS.maxRange
        .. "," .. Vision
        .. "," .. Wvision
        .. "," .. Intel
        .. "," .. unitDPS.Shield
        .. "," .. unitDPS.Health
        .. "," .. TorpDefRate
        .. "," .. unitDPS.Regen
        .. "," .. Mass
        .. "," .. Energy
        .. "," .. BuildTime
        .. "," .. unitDPS.Speed
        .. "," .. unitDPS.Warn
        .. "\n"
    )
end -- Blueprint for() Loop

io.close(file)
