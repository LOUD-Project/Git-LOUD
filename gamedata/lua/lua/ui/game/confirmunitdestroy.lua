
local UIUtil = import('/lua/ui/uiutil.lua')

local destructingUnits = {}
local controls = {}
local countdownThreads = {}

function ConfirmUnitDestruction()

    local units = GetSelectedUnits()

    if units then

        local unitIds = {}

        for _, unit in units do
            table.insert(unitIds, unit:GetEntityId())
        end

        SimCallback({Func = 'ToggleSelfDestruct', Args = {units = unitIds, owner = GetFocusArmy()}})
    end

end