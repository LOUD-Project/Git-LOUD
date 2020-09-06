local PhxThreat ={
    _VERSION = '1.0',
    _DESCRIPTION = 'DPS Calculator',
}

-- Threat Balance Constants
-- see: https://docs.google.com/document/d/1oMpHiHDKjTID0szO1mvNSH_dAJfg0-DuZkZAYVdr-Ms/edit
local SpeedT2_KNIFE = 3.1
local RangeT2_KNIFE = 25
local RangeAvgEngage = 50
local tEnd = 13.0

local PhxWeapDPS = require('PhxWeapDPS')

function PhxThreat(curBP)
    local unitDPS = {}
    unitDPS.SrfDPS = 0
    unitDPS.SubDPS = 0
    unitDPS.AirDPS = 0
    unitDPS.TotDPS = 0
    unitDPS.Warn = ''
    unitDPS.MaxRange = 0
for curWepID,curWep in ipairs(curBP.Weapon) do
        local DPS = PhxWeapDPS(curWep)
        print(DPS.WeaponName ..
            ': has Damage: ' .. DPS.Damage ..
            ' - Time: ' .. DPS.Ttime ..
            ' - new DPS: ' .. (DPS.Damage/DPS.Ttime)
        )

        if(unitDPS.MaxRange < DPS.Range) then 
            unitDPS.MaxRange = DPS.Range 
        end
        unitDPS.SrfDPS = unitDPS.SrfDPS + DPS.srfDPS
        unitDPS.SubDPS = unitDPS.SubDPS + DPS.subDPS
        unitDPS.AirDPS = unitDPS.AirDPS + DPS.airDPS
        unitDPS.TotDPS = unitDPS.TotDPS + DPS.DPS

        --Do per weapon checking here
        unitDPS.Warn = unitDPS.Warn .. DPS.Warn

        print(" ")  -- End of Weapon Import

        -- local SpeedT2_KNIFE = 3.1
        -- local RangeT2_KNIFE = 25
        -- local RangeAvgEngage = 50
        -- local tEnd = 13.0
        local thisThreatRange = (DPS.Range - RangeT2_KNIFE)
                                / SpeedT2_KNIFE 
                                * DPS.srfDPS/tEnd
        thisThreatRange = math.max(0,thisThreatRange)
        unitDPS.Range = unitDPS.Range + thisThreatRange
        unitDPS.SurfDPS = unitDPS.SurfDPS + DPS.srfDPS


    end --Weapon For Loop
    return unitDPS
end

return PhxThreat