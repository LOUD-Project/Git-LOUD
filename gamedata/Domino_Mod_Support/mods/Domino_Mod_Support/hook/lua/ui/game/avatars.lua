
--*****************************************************************************
--* File: lua/modules/ui/game/avatars.lua
--* Author: Ted Snook
--* Summary: In Game Avatar Icons
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************


do


local oldCreateAvatar = CreateAvatar
function CreateAvatar(unit)
    local Oldbg = oldCreateAvatar(unit)
	local Blueprint = unit:GetBlueprint()
	local Texture = UIUtil.UIFile('/icons/units/'..Blueprint.BlueprintId..'_icon.dds')
    if DiskGetFileInfo(Texture) then
        Oldbg.icon:SetTexture(Texture)
    else
        Oldbg.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
    end
    return Oldbg
end

end