 --*****************************************************************************
--* File: lua/modules/ui/uiutil.lua
--* Author: Chris Blackwell
--* Summary: Various utility functions to make UI scripts easier and more consistent
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local LazyVar = import('/lua/lazyvar.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Text = import('/lua/maui/text.lua').Text
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local Button = import('/lua/maui/button.lua').Button
local Edit = import('/lua/maui/edit.lua').Edit
local Checkbox = import('/lua/maui/Checkbox.lua').Checkbox
local Scrollbar = import('/lua/maui/scrollbar.lua').Scrollbar
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Cursor = import('/lua/maui/cursor.lua').Cursor
local Prefs = import('/lua/user/prefs.lua')
local Border = import('/lua/maui/border.lua').Border
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Layouts = import('/lua/skins/layouts.lua')

local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')

do
local oldUIFile = UIFile

function UIFile(filespec)
	for i, v in BlackopsIcons.EXIconPaths do
		temp1 = v .. '_icon'
		temp2 = string.upper(v .. '_icon')
		temp3 = string.lower(v .. '_icon')
		if string.find(filespec, temp1) or string.find(filespec, temp2) or string.find(filespec, temp3) then
			temp4 = string.upper(filespec)
			local curfile = '/textures/ui/common' .. filespec

			--####################
			--Exavier Code Block +
			--####################
			local EXunitID = bp.temp4
			if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
				-- Check manually assigned overwrite table
				local expath = EXunitID..'_icon.dds'
				excurfile =  BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. EXunitID
			elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
				-- Check modded icon hun table
				local expath = EXunitID..'_icon.dds'
				excurfile =  BlackopsIcons.EXIconTableScan(EXunitID) .. EXunitID
			else
				if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
					-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
					WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
					BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
				end
			end
			--####################
			--Exavier Code Block -
			--####################
			return curfile
		end
		return oldUIFile(filespec)
	end
end 

end
