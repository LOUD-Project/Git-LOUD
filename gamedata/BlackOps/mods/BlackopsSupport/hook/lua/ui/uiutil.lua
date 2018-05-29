 --*****************************************************************************
--* File: lua/modules/ui/uiutil.lua
--* Author: Chris Blackwell
--* Summary: Various utility functions to make UI scripts easier and more consistent
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

--[[
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

end
--]]