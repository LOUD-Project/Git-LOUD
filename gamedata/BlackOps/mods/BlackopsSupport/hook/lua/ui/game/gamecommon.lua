do
local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')

function GetUnitIconFileNames(blueprint)
    local iconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_icon.dds'
    local upIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_up.dds'
    local downIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_down.dds'
    local overIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_over.dds'

	--####################
	--Exavier Code Block +
	--####################
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
				WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
				BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
			end
		end
	end
	--####################
	--Exavier Code Block -
	--####################
    
    return iconName, upIconName, downIconName, overIconName
end

end