--* File: lua/modules/ui/game/timer.lua
--* Author: Ted Snook
--* Summary: On screen objective Countdown timer

local UIUtil = import('/lua/ui/uiutil.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local controls = {
    bg = false,
    clockIcon = false,
    clockGlow = false,
    clockText = false,
}
local glowThread = false
function CreateTimerDialog(parent)
    if not controls.bg then
        controls.bg = Bitmap(parent, UIUtil.UIFile('/game/timer/timer-panel_bmp.dds'))
    end
    LayoutHelpers.AtRightIn(controls.bg, parent, 3)
    controls.bg.Top:Set(function() return parent.Top() + 5 end)
    
    if not controls.clockIcon then
        controls.clockIcon = Bitmap(controls.bg, UIUtil.UIFile('/game/timer/clock_bmp.dds'))
    end
    controls.clockIcon.Left:Set(function() return controls.bg.Left() + 6 end)
    controls.clockIcon.Top:Set(function() return controls.bg.Top() + 6 end)
    
    if not controls.clockGlow then
        controls.clockGlow = Bitmap(controls.bg, UIUtil.UIFile('/game/timer/glow-02_bmp.dds'))
    end
    LayoutHelpers.AtCenterIn(controls.clockGlow, controls.clockIcon)
    controls.clockGlow:SetAlpha(0)
    
    if not controls.clockText then
        controls.clockText = UIUtil.CreateText(controls.bg, "00:00:00", 18, UIUtil.bodyFont)
    end
    controls.clockText.Left:Set(function() return controls.clockIcon.Right() + 5 end)
    controls.clockText.Top:Set(function() return controls.bg.Top() + 7 end)
    
    controls.bg:Hide()
end

function SetTimer(time)
    if time == 0 then
        if glowThread then
            KillThread(glowThread)
            controls.clockGlow:SetNeedsFrameUpdate(false)
            glowThread = false
        end
        controls.bg:Hide()
    else
        controls.bg:Show()
        if time < 30 then
            if not glowThread then
                glowThread = ForkThread(StartGlow, controls.clockGlow)
            end
        end
        controls.clockText:SetText(FormatTime(time))
    end
end

function StartGlow(control)
    control:SetNeedsFrameUpdate(true)
    local alpha = 0
    local ascending = true
    control.OnFrame = function(self, deltaTime)
        self:SetAlpha(alpha)
        if ascending then
            alpha = alpha + (deltaTime * 2)
        else
            alpha = alpha - (deltaTime * 2)
        end
        if alpha > .3 then
            alpha = .3
            ascending = false
        end
        if alpha < 0 then
            alpha = 0
            ascending = true
        end
    end
end

function ResetTimer()
    controls.bg:Hide()
end

function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds / 60)
    local remseconds = (seconds - ((hours * 3600) + (minutes * 60)))
    if hours < 10 then
        hours = "0" .. tostring(hours)
    else
        hours = tostring(hours)
    end
    if minutes < 10 then
        minutes = "0" .. tostring(minutes)
    else
        minutes = tostring(minutes)
    end
    if remseconds < 10 then
        remseconds = "0" .. tostring(remseconds)
    else
        remseconds = tostring(remseconds)
    end
    return string.format("%s:%s:%s", hours, minutes, remseconds)
end