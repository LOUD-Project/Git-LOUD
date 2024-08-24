--*****************************************************************************
--* File: lua/modules/ui/dialogs/desync.lua
--* Author: Chris Blackwell
--* Summary: handles multiplayer desyncs
--*
--* Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group

local dialog = false
local beforeStop = 0

function UpdateDialog(beatNumber, strings)

    if beforeStop != false then
    
		if not dialog then
        
			dialog = Group(GetFrame(0), "updateDialogGroup")
            
			LOG("Desynch at beat " .. beatNumber .. " tick " .. string.format("%.2f",GetGameTimeSeconds()) )
            
			LayoutHelpers.SetDimensions(dialog, 300, 250)
			dialog.Depth:Set(GetFrame(0):GetTopmostDepth() + 10)
            
			LayoutHelpers.AtCenterIn(dialog, GetFrame(0))
            
			local border, bg = UIUtil.CreateBorder(dialog, true)

			local title = UIUtil.CreateText(bg, "<LOC desync_0000>Desync Detected", 14, UIUtil.titleFont)
            
			LayoutHelpers.AtTopIn(title, dialog, 5)
			LayoutHelpers.AtHorizontalCenterIn(title, dialog)

			dialog.textControls = {}            
            
			local prev = false
            
			for i = 1,9 do
            
				dialog.textControls[i] = UIUtil.CreateText(bg, "", 12, UIUtil.bodyFont)
                
				if prev then
					LayoutHelpers.Below(dialog.textControls[i], prev, 5)
				else
					LayoutHelpers.AtLeftIn(dialog.textControls[i], bg, 5)
					LayoutHelpers.AnchorToBottom(dialog.textControls[i], title, 5)
				end
                
				prev = dialog.textControls[i]
			end
			
			local okBtn = UIUtil.CreateButtonStd(bg, '/widgets/small', "<LOC _Ok>", 10)
            
			okBtn.Top:Set(dialog.textControls[9].Bottom)
            
			LayoutHelpers.AtLeftIn(okBtn, bg)
            
			okBtn.OnClick = function(self, modifiers)
				dialog:Destroy()
				dialog = false
				beforeStop = beforeStop + 1
			end
			
			local StopBtn = UIUtil.CreateButtonStd(bg, '/widgets/small', "Stop Pop-Ups", 10) -- Add button by Xinnony
            
			StopBtn.Top:Set(dialog.textControls[9].Bottom)
            
			LayoutHelpers.AtRightIn(StopBtn, bg)
            
			if beforeStop < 1 then
				StopBtn:Disable()
			else
				StopBtn:Enable()
			end
            
			StopBtn.OnClick = function(self, modifiers)
				dialog:Destroy()
				dialog = false
				beforeStop = false
			end
		end
		
		for i = 1,8 do
			if strings[i] then
				dialog.textControls[i]:SetText(strings[i])
			end
		end
        
		dialog.textControls[9]:SetText(LOC("<LOC desync_0001>Beat# ") .. tostring(beatNumber))
        
	else
    
		--PrintText('Desync', 4, UIUtil.fontColor, 1, '')
        
	end
end