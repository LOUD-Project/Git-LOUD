--* File: lua/sim/tasks/AttackMove.lua

local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT


AttackMove = Class(ScriptTask) {
    TaskTick = function(self)
        self:SetAIResult(AIRESULT.Success)
        return TASKSTATUS.Done
    end,
}
