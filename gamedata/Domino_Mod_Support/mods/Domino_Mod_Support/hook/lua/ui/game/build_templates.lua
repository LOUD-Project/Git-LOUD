#*****************************************************************************
#* File: lua/modules/ui/game/build_templates.lua
#* Author: Ted Snook
#* Summary: Build Templates UI
#*
#* Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')

do
local oldGetInitialIcon = GetInitialIcon
function GetInitialIcon(template)
    for _, entry in template do
        if type(entry) != 'table' then continue end
        if DiskGetFileInfo(UIUtil.UIFile('/icons/units/'..entry[1]..'_icon.dds')) then
            return entry[1]
        else
            return oldGetInitialIcon(template)
        end
    end
end
end