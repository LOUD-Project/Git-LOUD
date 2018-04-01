--*****************************************************************************
--* File: lua/modules/ui/dialogs/eschandler.lua
--* Author: Chris Blackwell
--* Summary: Determines appropriate actions to take when the escape key is pressed in game
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local Prefs = import('/lua/user/prefs.lua')

local quickDialog = false

-- If yesNoOnly is true, then the in game dialog will never be shown
function HandleEsc(yesNoOnly)

    local function CreateYesNoDialog()
        if quickDialog then
            return
        end
        GetCursor():Show()
        quickDialog = UIUtil.QuickDialog(GetFrame(0), "<LOC EXITDLG_0000>Are you sure you'd like to quit?", 
            "<LOC _Yes>", function() ExitApplication() end, 
            "<LOC _No>", function() quickDialog:Destroy() quickDialog = false end, 
            nil, nil, 
            true,
            {escapeButton = 2, enterButton = 1, worldCover = true})
    end

    if yesNoOnly then
        if Prefs.GetOption('quick_exit') == 'true' then
            ExitApplication()
        else
            CreateYesNoDialog()
        end
    elseif import('/lua/ui/game/commandmode.lua').GetCommandMode()[1] != false then
        import('/lua/ui/game/commandmode.lua').EndCommandMode(true)
    elseif GetSelectedUnits() then
        SelectUnits(nil)
    end
end