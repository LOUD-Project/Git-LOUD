--* File: lua/modules/ui/game/gamecommon.lua
--* Author: Chris Blackwell
--* Summary: Functionality that is used by several game UI components

iconBmpHeight = 48
iconBmpWidth = 48
iconVertPadding = 1
iconHorzPadding = 1
iconHeight = iconBmpHeight + (2 * iconVertPadding)
iconWidth = iconBmpWidth + (2 * iconHorzPadding)

local BlackopsIcons = import('/lua/BlackopsIconSearch.lua')

function GetUnitIconFileNames(blueprint)

    local iconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_icon.dds'
    local upIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_up.dds'
    local downIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_down.dds'
    local overIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_over.dds'

	local EXunitID = blueprint.Display.IconName
	
	if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
	
		-- Check manually assigned overwrite table
		local expath = EXunitID..'_icon.dds'
		iconName = BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath
		upIconName = BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath
		downIconName = BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath
		overIconName = BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath
		
	elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
	
		-- Check modded icon hun table
		local expath = EXunitID..'_icon.dds'
		iconName = BlackopsIcons.EXIconTableScan(EXunitID) .. expath
		upIconName = BlackopsIcons.EXIconTableScan(EXunitID) .. expath
		downIconName = BlackopsIcons.EXIconTableScan(EXunitID) .. expath
		overIconName = BlackopsIcons.EXIconTableScan(EXunitID) .. expath
		
	else
	
		-- Check default GPG directories
		if DiskGetFileInfo(iconName) then
		
			iconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_icon.dds'
			
		else
		
			-- Sets placeholder because no other icon was found
            iconName = '/textures/ui/common/icons/units/default_icon.dds'
            upIconName = '/textures/ui/common/icons/units/default_icon.dds'
            downIconName = '/textures/ui/common/icons/units/default_icon.dds'
            overIconName = '/textures/ui/common/icons/units/default_icon.dds'
			
			if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
				-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
				--WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
				BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
			end
			
		end
		
	end

    return iconName, upIconName, downIconName, overIconName
	
end

-- add the filenames of the icons to the blueprint, creating a new RuntimeData table in the process where runtime things
-- can be stored in blueprints for convenience
-- Now also prefetches the icons and keeps them in the cache
function InitializeUnitIconBitmaps(prefetchTable)

    local alreadyFound = {}
	
    for i,v in __blueprints do
	
        v.RuntimeData = {}
		
        if v.Display.IconName then -- filter for icon name
		
            v.RuntimeData.IconFileName, v.RuntimeData.UpIconFileName, v.RuntimeData.DownIconFileName, v.RuntimeData.OverIconFileName  = GetUnitIconFileNames(v)
			
            if not alreadyFound[v.RuntimeData.IconFileName] then
                table.insert(prefetchTable, v.RuntimeData.IconFileName)
                alreadyFound[v.RuntimeData.IconFileName] = true
            end
			
            if not alreadyFound[v.RuntimeData.UpIconFileName] then
                table.insert(prefetchTable, v.RuntimeData.UpIconFileName)
                alreadyFound[v.RuntimeData.UpIconFileName] = true
            end
			
            if not alreadyFound[v.RuntimeData.DownIconFileName] then
                table.insert(prefetchTable, v.RuntimeData.DownIconFileName)
                alreadyFound[v.RuntimeData.DownIconFileName] = true
            end
			
            if not alreadyFound[v.RuntimeData.OverIconFileName] then
                table.insert(prefetchTable, v.RuntimeData.OverIconFileName)
                alreadyFound[v.RuntimeData.OverIconFileName] = true
            end
			
        end
		
    end
	
end

-- call this to get the cached version of the filename, and will recache if the cache is lost
function GetCachedUnitIconFileNames(blueprint)
    
    -- Handle finding Unit icons
    if not blueprint.RuntimeData.IconFileName then
	
        if not blueprint.RuntimeData then
		
            blueprint.RuntimeData = {}
			
        end
		
        blueprint.RuntimeData.IconFileName, blueprint.RuntimeData.UpIconFileName, blueprint.RuntimeData.DownIconFileName, blueprint.RuntimeData.OverIconFileName = GetUnitIconFileNames(blueprint)
		
    end
	
    return blueprint.RuntimeData.IconFileName, blueprint.RuntimeData.UpIconFileName, blueprint.RuntimeData.DownIconFileName, blueprint.RuntimeData.OverIconFileName
end

-- generic function that can be used to replace the OnHide that supresses showing the item
-- when returning from HideUI state
-- supress showing when coming back from hidden UI
function SupressShowingWhenRestoringUI(self, hidden)
    if not hidden then
        if import('/lua/ui/game/gamemain.lua').gameUIHidden then
            self:Hide()
            return true
        end
    end
end

-- Catch-all function for LOUD standard unit icons, usermod icons, and dynamically-created
-- blueprints which get assigned existing icons from either.
-- Arguments have an XOR nil allowance.
-- Returns a path string (from '/') and false if the path is to a placeholder
function GetUnitIconPath(blueprint, bpID)
    if not blueprint then
        if bpID then
            blueprint = __blueprints[bpID]
        else
            return '/textures/ui/common/icons/units/default_icon.dds', false
        end
    end

    -- Don't use UIUtil.UIFile in any of this to skip skinning checks & avoid possible log spam
    if blueprint.Display.IconPath then
        -- Assigned during original ModBlueprints(), and contains the complete path
        return blueprint.Display.IconPath, true
    elseif blueprint.Display.IconName
    and DiskGetFileInfo('/textures/ui/common/icons/units/'..blueprint.Display.IconName..'_icon.dds') then
        -- Assigned to let a blueprint reference another icon from the LOUD standard
        return '/textures/ui/common/icons/units/'..blueprint.Display.IconName..'_icon.dds', true
    else
        -- It's either in the mainline textures folder or it's completely absent.
        -- In the latter case, use a placeholder
        local path = '/textures/ui/common/icons/units/'..blueprint.BlueprintId..'_icon.dds', true
        if DiskGetFileInfo(path) then
            return path, true
        else
            return '/textures/ui/common/icons/units/default_icon.dds', false
        end
    end
end
