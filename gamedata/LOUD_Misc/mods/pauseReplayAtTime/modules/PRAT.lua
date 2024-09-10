local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')

local modpath = '/mods/pauseReplayAtTime/'

local controls = {}
local sizes = {
    width = 100,
    height = 50,
}
local dialog = false

local pauseAtSeconds = false
local threadRunning = false
local isReplay = false


function init()
    isReplay = true
    controls.parent = Bitmap(GetFrame(0))
    LayoutHelpers.SetDimensions(controls.parent, sizes.width, sizes.height)
    LayoutHelpers.AtHorizontalCenterIn(controls.parent, GetFrame(0), 200)
    controls.parent.Top:Set(GetFrame(0).Top)
--    controls.parent:Hide()

    controls.bgTop = CreateStretchBar(controls.parent, true)
    controls.bgBottom = CreateStretchBar(controls.parent)
    controls.bgBottom.Width:Set(controls.bgTop.Width)
    
    controls.content = Group(controls.bgTop)
    controls.content:DisableHitTest()
    LayoutHelpers.SetDimensions(controls.content, sizes.width, sizes.height)

    controls.collapseArrow = Checkbox(GetFrame(0))
    Tooltip.AddCheckboxTooltip(controls.collapseArrow, {
        text = "[Hide/Show] Replay pause timer",
        body = "",
    })

    controls.collapseArrow.OnCheck = function(self, checked)
        if controls.parent:IsHidden() then
            controls.parent:Show()
            controls.collapseArrow:SetCheck(false, true)
        else
            controls.parent:Hide()
            controls.collapseArrow:SetCheck(true, true)
        end
    end

    controls.time = UIUtil.CreateText(controls.content, getTimerString(), 18, UIUtil.bodyFont)
    controls.time:DisableHitTest()

    controls.changeTime = Button(controls.content,
        modpath..'textures/transparent.png',
        modpath..'textures/transparent.png',
        modpath..'textures/transparent.png',
        modpath..'textures/transparent.png')
    LayoutHelpers.SetDimensions(controls.changeTime, sizes.widthsizes.height)
    controls.changeTime.OnClick = function(self)
        ShowTimeDialog()
    end
    SetLayout()
end


function SetLayout()
    if not isReplay then
        return
    end
    controls.collapseArrow:SetTexture(UIUtil.UIFile('/game/tab-t-btn/tab-close_btn_up.dds'))
    controls.collapseArrow:SetNewTextures(UIUtil.UIFile('/game/tab-t-btn/tab-close_btn_up.dds'),
        UIUtil.UIFile('/game/tab-t-btn/tab-open_btn_up.dds'),
        UIUtil.UIFile('/game/tab-t-btn/tab-close_btn_over.dds'),
        UIUtil.UIFile('/game/tab-t-btn/tab-open_btn_over.dds'),
        UIUtil.UIFile('/game/tab-t-btn/tab-close_btn_dis.dds'),
        UIUtil.UIFile('/game/tab-t-btn/tab-open_btn_dis.dds'))
    LayoutHelpers.AtTopIn(controls.collapseArrow, GetFrame(0), -3)
    LayoutHelpers.AtHorizontalCenterIn(controls.collapseArrow, controls.parent)
    controls.collapseArrow.Depth:Set(function() return controls.bgTop.Depth() + 10 end)

    controls.bgTop.center:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_horz_um.dds'))
    controls.bgTop.left:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_ul.dds'))
    controls.bgTop.right:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_ur.dds'))
    
    controls.bgTop.centerLeft:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_horz_uml.dds'))
    controls.bgTop.centerRight:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_horz_umr.dds'))
    
    LayoutHelpers.AtTopIn(controls.bgTop, controls.parent)
    LayoutHelpers.AtHorizontalCenterIn(controls.bgTop, controls.parent)
    
    controls.bgBottom.center:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_horz_lm.dds'))
    controls.bgBottom.left:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_ll.dds'))
    controls.bgBottom.right:SetTexture(UIUtil.UIFile('/game/options-panel/options_brd_lr.dds'))
    controls.bgBottom.Top:Set(controls.bgTop.Bottom)
    LayoutHelpers.AtHorizontalCenterIn(controls.bgBottom, controls.parent)

    LayoutHelpers.AtHorizontalCenterIn(controls.content, controls.parent)
    LayoutHelpers.AtTopIn(controls.content, controls.bgTop, 10)

    LayoutHelpers.AtCenterIn(controls.time, controls.content)
    LayoutHelpers.AtCenterIn(controls.changeTime, controls.content)
end


function CreateStretchBar(parent, topPiece)
    local group = Group(parent)
    group.center = Bitmap(group)
    group.left = Bitmap(group)
    group.right = Bitmap(group)
    
    LayoutHelpers.AtHorizontalCenterIn(group.center, group)
    LayoutHelpers.AtTopIn(group.center, group)
    LayoutHelpers.AtLeftIn(group.left, group)
    LayoutHelpers.AtTopIn(group.left, group)
    LayoutHelpers.AtRightIn(group.right, group)
    LayoutHelpers.AtTopIn(group.right, group)
    
    if topPiece then
        group.centerLeft = Bitmap(group)
        LayoutHelpers.AtTopIn(group.centerLeft, group.center, 8)
        group.centerLeft.Left:Set(group.left.Right)
        group.centerLeft.Right:Set(group.center.Left)
        
        group.centerRight = Bitmap(group)
        group.centerRight.Top:Set(group.centerLeft.Top)
        group.centerRight.Left:Set(group.center.Right)
        group.centerRight.Right:Set(group.right.Left)
        
        group.Width:Set(function() return group.right.Width() + group.left.Width() + group.center.Width() end)
    else
        group.center.Left:Set(group.left.Right)
        group.center.Right:Set(group.right.Left)
    end
    
    group.Height:Set(function() return math.max(group.center.Height(), group.left.Height()) end)
    
    group:DisableHitTest(true)
    
    return group
end


function getTimerString()
    if not pauseAtSeconds then
        return "Not set"
    end
    return FormatTime(pauseAtSeconds)
end


function getTimeHMS(seconds)
    local hours = math.floor(seconds / 3600)
    local remseconds = seconds - (hours * 3600)
    local minutes = math.floor(remseconds / 60)
    remseconds = seconds - ((hours * 3600) + (minutes * 60))
    return hours, minutes, remseconds   
end


function FormatTime(seconds)
    if not seconds then
        return "00:00:00"
    end
    local hours, minutes, remseconds = getTimeHMS(seconds)
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


function setNewPauseTime(hours, minutes, seconds)
    if type(hours) ~= "number" or type(minutes) ~= "number" or type(seconds) ~= "number" then
        return
    end
    pauseAtSeconds = hours*3600 + minutes*60 + seconds
    controls.time:SetText(getTimerString())
    if threadRunning then
        return
    end

    SessionResume()
    threadRunning = true
    ForkThread(function()
        while true do
            if GetGameTimeSeconds() >= pauseAtSeconds then
                SessionRequestPause()
                threadRunning = false
                pauseAtSeconds = false
                controls.time:SetText(getTimerString())
                return
            end
            WaitSeconds(0.1)
        end
    end)
end


function parseAndSetTime(time)
    if type(time) == 'string' then
        vars = split(time, ':')
        if table.getn(vars) ~= 3 then
            return
        end
        setNewPauseTime(tonumber(vars[1]), tonumber(vars[2]), tonumber(vars[3]))
    end
end


-- credits of this to http://stackoverflow.com/a/1579673
function split(pString, pPattern)
    local Table = {}
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= string.len(pString) then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end


function ShowTimeDialog()
    if dialog then
        return
    end

    dialog = UIUtil.CreateInputDialog(GetFrame(0), LOC("Enter time HH:MM:SS"),
        function(self, newtime)
            parseAndSetTime(newtime)
        end
    )
    dialog.inputBox:SetFont(UIUtil.bodyFont, 14)
    dialog.inputBox:SetText(FormatTime(pauseAtSeconds))

    dialog.OnClosed = function()
        dialog = nil
    end
end