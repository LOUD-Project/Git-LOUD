--*****************************************************************************
--* File: lua/modules/ui/game/gamecommon.lua
--* Author: Chris Blackwell
--* Summary: Functionality that is used by several game UI components
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

do
local UIUtil = import('/lua/ui/uiutil.lua')
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 
local __Textures = __DMSI.__DModTextures
local __FileNameTextures = __DMSI.__DModFileNamePath

iconBmpHeight = 48
iconBmpWidth = 48
iconVertPadding = 0.2
iconHorzPadding = 0.2
iconHeight = iconBmpHeight + (2 * iconVertPadding)
iconWidth = iconBmpWidth + (2 * iconHorzPadding)

local oldGetUnitIconFileNames = GetUnitIconFileNames
function GetUnitIconFileNames(blueprint)

	local IconPath = 'icons/units/'

	local ModiconName = IconPath .. blueprint.Display.IconName .. '_icon.dds'
	local ModupIconName = IconPath .. blueprint.Display.IconName .. '_build_btn_up.dds'
	local ModdownIconName = IconPath .. blueprint.Display.IconName .. '_build_btn_down.dds'
	local ModoverIconName = IconPath .. blueprint.Display.IconName .. '_build_btn_over.dds'

	local iconName = __Textures[ModiconName].filepath or '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_icon.dds'
	local upIconName = __Textures[ModupIconName].filepath	or '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_up.dds'
	local downIconName = __Textures[ModdownIconName].filepath	or '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_down.dds'
	local overIconName = __Textures[ModoverIconName].filepath or '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_over.dds'
	
	--If we dont find our icon... lets check for the filename 
	if DiskGetFileInfo(iconName) == false then		
		iconName = __FileNameTextures[blueprint.Display.IconName .. '_icon'].filepath or false
		upIconName = __FileNameTextures[blueprint.Display.IconName .. '_build_btn_up'].filepath or false
		downIconName = __FileNameTextures[blueprint.Display.IconName .. '_build_btn_down'].filepath or false
		overIconName = __FileNameTextures[blueprint.Display.IconName .. '_build_btn_over'].filepath or false
    end
    
	if not iconName then
        iconName = UIUtil.UIFile('/icons/units/default_icon.dds')
    end
    
    if not upIconName then
        upIconName = iconName
    end

    if not downIconName then
        downIconName = iconName
    end

    if not overIconName then
        overIconName = iconName
    end

	return iconName, upIconName, downIconName, overIconName

end



end

