--[[
    Enhanced Pause Behavior - hook for /lua/ui/game/tabs.lua

    Create:      installs the ready check
    CommonLogic: keeps the pause button pressed when a resume was intercepted
    OnPause:     closes the ready check once the game resumes
]]

local EPB_ReadyCheck = import('/mods/enhancedpausebehavior/modules/readycheck.lua')

local EPB_OldCreate = Create
function Create(parent)
    EPB_ReadyCheck.Init()
    return EPB_OldCreate(parent)
end

local EPB_OldCommonLogic = CommonLogic
function CommonLogic()
    EPB_OldCommonLogic()
    for _, tab in controls.tabs do
        if tab.Data.pause and not tab.EPB_Wrapped then
            tab.EPB_Wrapped = true
            local oldOnCheck = tab.OnCheck
            tab.OnCheck = function(self, checked)
                EPB_ReadyCheck.ClearBlocked()
                oldOnCheck(self, checked)
                if not checked and EPB_ReadyCheck.TakeBlocked() then
                    self:SetCheck(true, true)
                    self:SetGlowState(true)
                end
            end
        end
    end
end

local EPB_OldOnPause = OnPause
function OnPause(state, pausedBy, lTimeoutsRemaining, isOwner)
    EPB_OldOnPause(state, pausedBy, lTimeoutsRemaining, isOwner)
    if not state then
        EPB_ReadyCheck.OnGameResumed()
    end
end
