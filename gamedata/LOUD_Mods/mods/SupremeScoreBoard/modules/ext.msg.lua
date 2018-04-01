 
--LOG("HUSSAR: " .. "Loading message extensions module: ex.msg.LUA... "  )
 
--[[
TODO:
-  
-  
--]]
 

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group  = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local bg = false

function CreateMessageBox(text, textDetails, onFinished)   
    local scoreDlg = import('/lua/ui/dialogs/score.lua')
    if scoreDlg.dialog then
        if onFinished then
           onFinished()
        end
        return
    end
    if bg then
        if bg.OnFinished then
           bg.OnFinished()
        end
        bg.OnFrame = function(self, delta)
            local newAlpha = self:GetAlpha() - (delta*2)
            if newAlpha < 0 then
                newAlpha = 0
                self:Destroy()
                bg.OnFinished = nil
                bg = false
                CreateMessageBox(text, textDetails, onFinished)
            end
            self:SetAlpha(newAlpha, true)
        end
        return
    end
    bg = Bitmap(GetFrame(0), UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_m.dds'))
    bg.Height:Set(0)
    bg.Width:Set(0)
    bg.Depth:Set(GetFrame(0):GetTopmostDepth()+1)
    LayoutHelpers.AtCenterIn(bg, GetFrame(0))
    
    bg.border = CreateBorder(bg)
    PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Announcement_Open'}))
    local textGroup = Group(bg)
    
    local text = UIUtil.CreateText(textGroup, text, 22, UIUtil.titleFont)
    LayoutHelpers.AtCenterIn(text, GetFrame(0), -250)
    text:SetDropShadow(true)
    text:SetColor(UIUtil.fontColor)
    text:SetNeedsFrameUpdate(true)
    
    if textDetails then
        textBox = UIUtil.CreateText(textGroup, textDetails, 18, UIUtil.bodyFont)
        textBox:SetDropShadow(true)
        textBox:SetColor(UIUtil.fontColor)
        LayoutHelpers.Below(textBox, text, 10)
        LayoutHelpers.AtHorizontalCenterIn(textBox, text)
        textGroup.Top:Set(text.Top)
        textGroup.Left:Set(function() return math.min(textBox.Left(), text.Left()) end)
        textGroup.Right:Set(function() return math.max(textBox.Right(), text.Right()) end)
        textGroup.Bottom:Set(textBox.Bottom)
    else
        LayoutHelpers.FillParent(textGroup, text)
    end
    textGroup:SetAlpha(0, true)
    
    bg:DisableHitTest(true)
    bg.OnFinished = onFinished
    bg.time = 0
    bg:SetNeedsFrameUpdate(true)
    bg.CloseSoundPlayed = false
    bg.OnFrame = function(self, delta)
        self.time = self.time + delta
        if self.time >= 3.5 and self.time < 3.7 then
            if not self.CloseSoundPlayed then
                PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Announcement_Close'}))
                self.CloseSoundPlayed = false
            end
            self.Top:Set(MATH_Lerp(self.time, 3.5, 3.7, textGroup.Top(), 0))
            self.Left:Set(MATH_Lerp(self.time, 3.5, 3.7, textGroup.Left(), 0))
            self.Right:Set(MATH_Lerp(self.time, 3.5, 3.7, textGroup.Right(), 0))
            self.Bottom:Set(MATH_Lerp(self.time, 3.5, 3.7, textGroup.Bottom(), 0))
            self.Height:Set(MATH_Lerp(self.time, 3.5, 3.7, textGroup.Height(), 0))
            self.Width:Set(MATH_Lerp(self.time, 3.5, 3.7, textGroup.Width(), 0))
        elseif self.time < .2 then
            self.Top:Set(MATH_Lerp(self.time, 0, .2, 0, textGroup.Top()))
            self.Left:Set(MATH_Lerp(self.time, 0, .2, 0, textGroup.Left()))
            self.Right:Set(MATH_Lerp(self.time, 0, .2, 0, textGroup.Right()))
            self.Bottom:Set(MATH_Lerp(self.time, 0, .2, 0, textGroup.Bottom()))
            self.Height:Set(MATH_Lerp(self.time, 0, .2, 0, textGroup.Height()))
            self.Width:Set(MATH_Lerp(self.time, 0, .2, 0, textGroup.Width()))
        elseif self.time > .2 and self.time < 3.5 then
            self.Top:Set(textGroup.Top)
            self.Left:Set(textGroup.Left)
            self.Right:Set(textGroup.Right)
            self.Bottom:Set(textGroup.Bottom)
            self.Height:Set(textGroup.Height)
            self.Width:Set(textGroup.Width)
        end
        
        if self.time > 3 and textGroup:GetAlpha() ~= 0 then
            textGroup:SetAlpha(math.max(textGroup:GetAlpha()-(delta*2), 0), true)
        elseif self.time > .2 and self.time < 3 and text:GetAlpha() ~= 1 then
            textGroup:SetAlpha(math.min(text:GetAlpha()+(delta*2), 1), true)
        end
        if self.time > 3.7 then
            if bg.OnFinished then
                bg.OnFinished()
            end
            bg:Destroy()
            bg.OnFinished = nil
            bg = false
        end
    end
    if import('/lua/ui/game/gamemain.lua').gameUIHidden then
       bg:Hide()
    end
end

function Contract()
    if bg then
       bg:Hide()
    end
end

function Expand()
    if bg then
       bg:Show()
    end
end

function CreateBorder(parent)
    local border = {}
    
    border.tl = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ul.dds'))
    border.tm = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'))
    border.tr = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ur.dds'))
    border.ml = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'))
    border.mr = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'))
    border.bl = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ll.dds'))
    border.bm = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_lm.dds'))
    border.br = Bitmap(parent, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_lr.dds'))
    
    border.tl.Bottom:Set(parent.Top)
    border.tl.Right:Set(parent.Left)
    
    border.bl.Top:Set(parent.Bottom)
    border.bl.Right:Set(parent.Left)
    
    border.tr.Bottom:Set(parent.Top)
    border.tr.Left:Set(parent.Right)
    
    border.br.Top:Set(parent.Bottom)
    border.br.Left:Set(parent.Right)
    
    border.tm.Bottom:Set(parent.Top)
    border.tm.Left:Set(parent.Left)
    border.tm.Right:Set(parent.Right)
    
    border.bm.Top:Set(parent.Bottom)
    border.bm.Left:Set(parent.Left)
    border.bm.Right:Set(parent.Right)
    
    border.ml.Top:Set(parent.Top)
    border.ml.Bottom:Set(parent.Bottom)
    border.ml.Right:Set(parent.Left)
    
    border.mr.Top:Set(parent.Top)
    border.mr.Bottom:Set(parent.Bottom)
    border.mr.Left:Set(parent.Right)
    
    return border
end