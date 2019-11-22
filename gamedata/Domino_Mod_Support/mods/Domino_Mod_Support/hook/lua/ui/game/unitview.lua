--*****************************************************************************
--* File: lua/modules/ui/game/unitview.lua
--* Author: Chris Blackwell
--* Summary: Rollover unit view control
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************
do
end

--[[

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua')
local __Textures = __DMSI.__DModTextures
local __FileNameTextures = __DMSI.__DModFileNamePath

local OldUpdateWindow = UpdateWindow
function UpdateWindow(info)
	
	OldUpdateWindow(info)
		
    if info.blueprintId != 'unknown' then
		 local bp = __blueprints[info.blueprintId]
		 local Texture = UIUtil.UIFile('/icons/units/'..info.blueprintId..'_icon.dds')
			
		if DiskGetFileInfo(Texture) then 
			controls.icon:SetTexture(Texture)
		else
			controls.icon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
		end
    end
	
	if info.focus then
		local Texture = UIUtil.UIFile('/icons/units/'..info.focus.blueprintId..'_icon.dds')
			
		if DiskGetFileInfo(Texture) then 
			controls.actionIcon:SetTexture(Texture)
		else
			controls.actionIcon:SetTexture('/textures/ui/common/game/unit_view_icons/unidentified.dds')
		end     
    end
end

--domino says.. if the unit blueprint contains bp.General.DoNotShowUnitInfo, do not show the rollover info for this unit.
local OldCreateUI = CreateUI
function CreateUI()
   
   local Roll = GetRolloverInfo()
   local ShowRoll = true

	local Entity = false
	
	if Roll and Roll.entityId then
		local Entity = GetUnitById(Roll.entityId)
		
		if Entity then 
			local bp = Entity:GetBlueprint()
				
			if bp.General.DoNotShowUnitInfo then 
				ShowRoll = false
			end
		end
	end
			
	if ShowRoll then
		OldCreateUI()
	end	  
end

--]]