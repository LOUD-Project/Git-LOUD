--* File: lua/modules/ui/game/tooltip.lua
--* Author: Ted Snook
--* Summary: Tool Tips

local Bitmap        = import('/lua/maui/bitmap.lua').Bitmap
local Button        = import('/lua/maui/button.lua').Button
local Group         = import('/lua/maui/group.lua').Group
local Keymapping    = import('/lua/keymap/defaultKeyMap.lua').defaultKeyMap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Prefs         = import('/lua/user/prefs.lua')
local TooltipInfo   = import('/lua/ui/help/tooltips.lua')
local UIUtil        = import('/lua/ui/uiutil.lua')

local AITooltipInfo, TooltipInfo = import('/lua/enhancedlobby.lua').GetCustomTooltips(TooltipInfo)	

local mouseoverDisplay = false
local createThread = false

function ReloadTooltips()
    AITooltipInfo, TooltipInfo = import('/lua/enhancedlobby.lua').GetCustomTooltips(TooltipInfo)	
end

function CreateMouseoverDisplay(parent, ID, delay, extendedBool, hotkeyID)

    if mouseoverDisplay then
        mouseoverDisplay:Destroy()
        mouseoverDisplay = false
    end

    if not Prefs.GetOption('tooltips') then
		return
	end
    
    -- this will add any custom tooltips to the master TooltipInfo

    local createDelay = 0
	
    if delay and Prefs.GetOption('tooltip_delay') then
        createDelay = math.max(delay, Prefs.GetOption('tooltip_delay'))
    else
        createDelay = Prefs.GetOption('tooltip_delay') or 0
    end
	
    local totalTime = 0
    local alpha = 0.0
    local text = ""
    local body = ""
	
    if type(ID) == 'string' then

        if TooltipInfo['Tooltips'][ID] then

            text = LOC(TooltipInfo['Tooltips'][ID]['title'])
            body = LOC(TooltipInfo['Tooltips'][ID]['description'])

            if TooltipInfo['Tooltips'][ID]['keyID'] and TooltipInfo['Tooltips'][ID]['keyID'] != "" then

                for i, v in Keymapping do

                    if v == TooltipInfo['Tooltips'][ID]['keyID'] then
                        local properkeyname = import('/lua/ui/dialogs/keybindings.lua').FormatKeyName(i)
                        text = LOCF("%s (%s)", text, properkeyname)
                        break
                    end
                end
            end
			
		elseif AITooltipInfo['Tooltips'][ID] then

            text = LOC(AITooltipInfo['Tooltips'][ID]['title'])
            body = LOC(AITooltipInfo['Tooltips'][ID]['description'])

            if AITooltipInfo['Tooltips'][ID]['keyID'] and AITooltipInfo['Tooltips'][ID]['keyID'] != "" then

                for i, v in Keymapping do

                    if v == AITooltipInfo['Tooltips'][ID]['keyID'] then
                        local properkeyname = import('/lua/ui/dialogs/keybindings.lua').FormatKeyName(i)
                        text = LOCF("%s (%s)", text, properkeyname)
                        break
                    end
                end
            end
			
        else

            if extendedBool then
                WARN("No tooltip in table for key: "..ID)
            end

            text = ID
            body = "No Description"
        end
		
    elseif type(ID) == 'table' then

        text = LOC(ID.text)
        body = LOC(ID.body)

    else
        WARN('UNRECOGNIZED TOOLTIP ENTRY - Not a string or table! ', repr(ID))
    end
	
    if extendedBool then
        mouseoverDisplay = CreateExtendedToolTip(parent, text, body)
    else
        mouseoverDisplay = CreateToolTip(parent, text)
    end
	
    if extendedBool then
        local Frame = GetFrame(0)
        if parent.Top() - mouseoverDisplay.Height() < 0 then
			LayoutHelpers.AnchorToBottom(mouseoverDisplay, parent, 10)
        else
            mouseoverDisplay.Bottom:Set(parent.Top)
        end
        if (parent.Left() + (parent.Width() / 2)) - (mouseoverDisplay.Width() / 2) < 0 then
            mouseoverDisplay.Left:Set(parent.Right)
        elseif (parent.Right() - (parent.Width() / 2)) + (mouseoverDisplay.Width() / 2) > Frame.Right() then
            mouseoverDisplay.Right:Set(parent.Left)
        else
            LayoutHelpers.AtHorizontalCenterIn(mouseoverDisplay, parent)
        end
    else
        local Frame = GetFrame(0)
        mouseoverDisplay.Bottom:Set(parent.Top)
        if (parent.Left() + (parent.Width() / 2)) - (mouseoverDisplay.Width() / 2) < 0 then
            mouseoverDisplay.Left:Set(LayoutHelpers.ScaleNumber(4))
        elseif (parent.Right() - (parent.Width() / 2)) + (mouseoverDisplay.Width() / 2) > Frame.Right() then
			LayoutHelpers.AtRightIn(mouseoverDisplay, Frame, 4)
        else
            LayoutHelpers.AtHorizontalCenterIn(mouseoverDisplay, parent)
        end
    end
	
    if ID == "mfd_defense" then
        local size = table.getn(mouseoverDisplay.desc)
        mouseoverDisplay.desc[size]:SetColor('ffff0000')
        mouseoverDisplay.desc[size-1]:SetColor('ffffff00')
        mouseoverDisplay.desc[size-2]:SetColor('ff00ff00')
        mouseoverDisplay.desc[size-3]:SetColor('ff4f77f4')
    end
	
    mouseoverDisplay:SetAlpha(alpha, true)
    mouseoverDisplay:SetNeedsFrameUpdate(true)

    mouseoverDisplay.OnFrame = function(self, deltaTime)
        if totalTime > createDelay then
            if parent then
                if alpha < 1 then
                    mouseoverDisplay:SetAlpha(alpha, true)
                    alpha = alpha + (deltaTime * 4)
                else
                    mouseoverDisplay:SetAlpha(1, true)
                    mouseoverDisplay:SetNeedsFrameUpdate(false)
                end
            else
                WARN("NO PARENT SPECIFIED FOR TOOLTIP")
            end
        end
        totalTime = totalTime + deltaTime
    end
end

function DestroyMouseoverDisplay()
    if createThread then
        KillThread(createThread)
    end
    if mouseoverDisplay then
        mouseoverDisplay:Destroy()
        mouseoverDisplay = false
    end
end

function CreateToolTip(parent, text)

    local tooltip = UIUtil.CreateText(parent, text, 12, UIUtil.bodyFont)

    tooltip.Depth:Set(function() return parent.Depth() + 10000 end)

    tooltip.bg = Bitmap(tooltip)
    tooltip.bg:SetSolidColor(UIUtil.tooltipTitleColor)

    tooltip.bg.Depth:Set(function() return tooltip.Depth() - 1 end)

    tooltip.bg.Top:Set(tooltip.Top)
    tooltip.bg.Bottom:Set(tooltip.Bottom)
    LayoutHelpers.AtLeftIn(tooltip.bg, tooltip, -2)
    LayoutHelpers.AtRightIn(tooltip.bg, tooltip, -2)
    
    tooltip.border = Bitmap(tooltip)
    tooltip.border:SetSolidColor(UIUtil.tooltipBorderColor)

    tooltip.border.Depth:Set(function() return tooltip.bg.Depth() - 1 end)
    LayoutHelpers.AtLeftTopIn(tooltip.border, tooltip, -1, -1)
    LayoutHelpers.AtRightBottomIn(tooltip.border, tooltip, -1, -1)
    
    tooltip:DisableHitTest(true)
    
    return tooltip
end

function CreateExtendedToolTip(parent, text, desc)

    if text != "" or desc != "" then
	
        local tooltip = Group(parent)
		
        tooltip.Depth:Set(function() return parent.Depth() + 10000 end)
		
        LayoutHelpers.SetWidth(tooltip, 150)
        
        if text != "" and text != nil then
		
            tooltip.title = UIUtil.CreateText(tooltip, text, 14, UIUtil.bodyFont)
			
            tooltip.title.Top:Set(tooltip.Top)
            tooltip.title.Left:Set(tooltip.Left)

            tooltip.bg = Bitmap(tooltip)
			
            tooltip.bg:SetSolidColor(UIUtil.tooltipTitleColor)
			
            tooltip.bg.Depth:Set(function() return tooltip.title.Depth() - 1 end)

            tooltip.bg.Top:Set(tooltip.title.Top)
            tooltip.bg.Bottom:Set(tooltip.title.Bottom)
			LayoutHelpers.AtLeftIn(tooltip.bg, tooltip, -2)
            LayoutHelpers.AtRightIn(tooltip.bg, tooltip, -2)
			
        end
        
        tooltip.desc = {}

        local tempTable = false
        
        if desc != "" and desc != nil then
		
            tooltip.desc[1] = UIUtil.CreateText(tooltip, "", 12, UIUtil.bodyFont)

            tooltip.desc[1].Width:Set(tooltip.Width)

            if text == "" and text != nil then
                tooltip.desc[1].Top:Set(tooltip.Top)
                tooltip.desc[1].Left:Set(tooltip.Left)
            else
                LayoutHelpers.Below(tooltip.desc[1], tooltip.title)
            end
            
            local textBoxWidth = tooltip.Width()

            tempTable = import('/lua/maui/text.lua').WrapText(LOC(desc), textBoxWidth, function(text) return tooltip.desc[1]:GetStringAdvance(text)            end)
            
            for i=1, table.getn(tempTable) do
			
                if i == 1 then
                    tooltip.desc[i]:SetText(tempTable[i])
                else
                    local index = i
					
                    tooltip.desc[i] = UIUtil.CreateText(tooltip, tempTable[i], 12, UIUtil.bodyFont)
                    tooltip.desc[i].Width:Set(tooltip.desc[1].Width)
                    LayoutHelpers.Below(tooltip.desc[index], tooltip.desc[index-1])
                end
				
                tooltip.desc[i]:SetColor('FFCCCCCC')
            end
            
            tooltip.extbg = Bitmap(tooltip)
            tooltip.extbg:SetSolidColor('FF000202')
            tooltip.extbg.Depth:Set(function() return tooltip.desc[1].Depth() - 1 end)
            tooltip.extbg.Top:Set(tooltip.desc[1].Top)
            LayoutHelpers.AtLeftIn(tooltip.extbg, tooltip, -2)
            LayoutHelpers.AtRightIn(tooltip.extbg, tooltip, -2)
             tooltip.extbg.Bottom:Set(tooltip.desc[table.getn(tempTable)].Bottom)
			
        end
        
        
        tooltip.extborder = Bitmap(tooltip)
        tooltip.extborder:SetSolidColor(UIUtil.tooltipBorderColor)

        if text != "" and text != nil then
            tooltip.extborder.Depth:Set(function() return tooltip.bg.Depth() - 1 end)
			LayoutHelpers.AtLeftTopIn(tooltip.extborder, tooltip.bg, -1, -1)
            LayoutHelpers.AtRightIn(tooltip.extborder, tooltip.bg, -1)
        else
            tooltip.extborder.Depth:Set(function() return tooltip.extbg.Depth() - 1 end)
			LayoutHelpers.AtLeftTopIn(tooltip.extborder, tooltip.extbg, -1, -1)
			LayoutHelpers.AtRightIn(tooltip.extborder, tooltip.extbg, -1)
        end

        if desc != "" and desc != nil then
			LayoutHelpers.AtBottomIn(tooltip.extborder, tooltip.extbg, -1)
        else
			LayoutHelpers.AtBottomIn(tooltip.extborder, tooltip.bg, -1)
        end
        
        tooltip:DisableHitTest(true)
        
        if text != "" and text != nil then
            tooltip.Width:Set(function() return math.max(tooltip.title.Width(), LayoutHelpers.ScaleNumber(150)) end)
        else
            tooltip.Width:Set(function() return LayoutHelpers.ScaleNumber(150) end)
        end
        
        if text == "" and text != nil then
            tooltip.Height:Set(function() return (tooltip.desc[1].Height() * table.getn(tempTable)) end)
        elseif desc == "" and desc != nil then
            tooltip.Height:Set(function() return tooltip.title.Height() end)
            tooltip.Width:Set(function() return tooltip.title.Width() end)
        else
            tooltip.Height:Set(function() return tooltip.title.Height() + (tooltip.desc[1].Height() * table.getn(tempTable)) end)
        end
        
        return tooltip

    else
        WARN("Tooltip error! Text and description are both empty!  This should not happen.")
    end
end

-- helpers functions to make is simple to add tooltips
function AddButtonTooltip(control, tooltipID, delay)

    control.HandleEvent = function(self, event)

        if event.Type == 'MouseEnter' then
            CreateMouseoverDisplay(self, tooltipID, delay, true)
        elseif event.Type == 'MouseExit' then
            DestroyMouseoverDisplay()
        end

        return Button.HandleEvent(self, event)
    end
end 

function AddControlTooltip(control, tooltipID, delay)

    if not control.oldHandleEvent then
        control.oldHandleEvent = control.HandleEvent
    end

    control.HandleEvent = function(self, event)

        if event.Type == 'MouseEnter' then
            CreateMouseoverDisplay(self, tooltipID, delay, true)
        elseif event.Type == 'MouseExit' then
            DestroyMouseoverDisplay()
        end

        return self.oldHandleEvent(self, event)
    end
end

function AddCheckboxTooltip(control, tooltipID, delay)

    if not control.oldHandleEvent then
        control.oldHandleEvent = control.HandleEvent
    end

    control.HandleEvent = function(self, event)

        if event.Type == 'MouseEnter' then
            CreateMouseoverDisplay(self, tooltipID, delay, true)
        elseif event.Type == 'MouseExit' then
            DestroyMouseoverDisplay()
        end

        return self.oldHandleEvent(self, event)
    end
end

function AddComboTooltip(control, tooltipTable, optPosition)

    local locParent = optPosition or control

    control.OnMouseExit = function(self)
        DestroyMouseoverDisplay()
    end

    control.OnOverItem = function(self, index, text)
        --tooltip popup here, note, -1 is possible index (which means not over an item)
        if index != -1 and tooltipTable[index] then
            CreateMouseoverDisplay(locParent, tooltipTable[index], nil, true)
        else
            DestroyMouseoverDisplay()
        end
    end
end

function RemoveComboTooltip(control)

    control.OnMouseExit = function(self)
    end

    control.OnOverItem = function(self, index, text)
    end
end

function SetTooltipText(control, id)

    if not mouseoverDisplay or control != mouseoverDisplay:GetParent() then return end

    if mouseoverDisplay.title then
        mouseoverDisplay.title:SetText(id)
    else
        mouseoverDisplay:SetText(id)
    end
end