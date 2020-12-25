-- unitdb.lua
-- Author: Rat Circus

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Edit = import('/lua/maui/edit.lua').Edit
local Group = import('/lua/maui/group.lua').Group
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

allBlueprints = {}
curBlueprint = {}
countBPs = 0

local filters = {}

function CreateUnitDB(over, inGame, callback)
	-- Must plug UnitBlueprint() into engine before running doscript on .bps
	doscript '/lua/ui/menus/unitdb_bps.lua'

	for _, file in DiskFindFiles('/units', '*_unit.bp') do
		safecall("UNIT DB: Loading BP "..file, doscript, file)
	end

-- Basics

	local parent = over
	local panel = Bitmap(over, UIUtil.UIFile('/scx_menu/unitdb/panel_unitdb.dds'))
	LayoutHelpers.AtCenterIn(panel, parent)
	panel.brackets = UIUtil.CreateDialogBrackets(panel, 38, 24, 38, 24)
	local title = UIUtil.CreateText(panel, LOC("LOUD Unit Database"), 24)
	LayoutHelpers.AtTopIn(title, panel, 24)
	LayoutHelpers.AtHorizontalCenterIn(title, panel)
	panel.Depth:Set(GetFrame(over:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
	local worldCover = nil
	if not inGame then
		worldCover = UIUtil.CreateWorldCover(panel)
	end

-- Unit display

	local unitDisplay = Group(panel)
	unitDisplay.Height:Set(600)
	unitDisplay.Width:Set(260)
	unitDisplay.top = 0
	LayoutHelpers.AtLeftTopIn(unitDisplay, panel, 20, 72)
	unitDisplay.bg = Bitmap(unitDisplay)
	unitDisplay.bg.Depth:Set(unitDisplay.Depth)
	LayoutHelpers.FillParent(unitDisplay.bg, unitDisplay)

	local displayIcon = Bitmap(unitDisplay, '/textures/ui/common/icons/units/SEL0323_icon.dds')
	LayoutHelpers.AtLeftTopIn(displayIcon, unitDisplay)
	local displayName = UIUtil.CreateText(unitDisplay, 'Trickshot', 24, "Arial Bold")
	displayName:DisableHitTest()
	LayoutHelpers.RightOf(displayName, displayIcon, 6)
	local displayShortDesc = UIUtil.CreateText(unitDisplay, 'Mobile Non-Ivan Unit', 18, "Arial")
	displayShortDesc:DisableHitTest()
	LayoutHelpers.Below(displayShortDesc, displayName)
	local desc = 'Experimental rapid-fire artillery. Fires drop-pods containing manually constructed land units deep into enemy lines, causing minor impact damage. Drop-pods are launched in a first in last out order.'
	local displayDesc = UIUtil.CreateTextBox(unitDisplay)
	LayoutHelpers.Below(displayDesc, displayIcon, 4)
	displayDesc.Width:Set(unitDisplay.Width)
	displayDesc.Height:Set(120)
	UIUtil.SetTextBoxText(displayDesc, desc)
	displayDesc.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end

-- List of filtered units

	local listContainer = Group(panel)
	listContainer.Height:Set(556)
	listContainer.Width:Set(260)
	listContainer.top = 0
	LayoutHelpers.RightOf(listContainer, unitDisplay, 48)

	local unitList = {}

	local function CreateElement(i)
		unitList[i] = Group(listContainer)
		unitList[i].Height:Set(64)
		unitList[i].Width:Set(listContainer.Width)
		unitList[i].bg = Bitmap(unitList[i])
		unitList[i].bg.Depth:Set(unitList[i].Depth)
		LayoutHelpers.FillParent(unitList[i].bg, unitList[i])
		unitList[i].bg.Right:Set(function() return unitList[i].Right() - 10 end)
		unitList[i].icon = Bitmap(unitList[i], '/textures/ui/common/icons/units/SEL0323_icon.dds')
		LayoutHelpers.AtLeftTopIn(unitList[i].icon, unitList[i])
		unitList[i].text = UIUtil.CreateText(listContainer, 'Some Unit', 14, "Arial")
		unitList[i].text:DisableHitTest()
		LayoutHelpers.CenteredRightOf(unitList[i].text, unitList[i].icon, 2)
	end

	CreateElement(1)
	LayoutHelpers.AtLeftTopIn(unitList[1], listContainer)

	for i = 2, 9 do
		CreateElement(i)
		LayoutHelpers.Below(unitList[i], unitList[i - 1])
	end

-- Filters section

	local filterContainer = Group(panel)
	filterContainer.Height:Set(556)
	filterContainer.Width:Set(260)
	filterContainer.top = 0
	LayoutHelpers.RightOf(filterContainer, listContainer, 16)

	local filterContainerTitle = UIUtil.CreateText(filterContainer, 'Filters', 24, UIUtil.titleFont)
	LayoutHelpers.AtTopIn(filterContainerTitle, filterContainer)
	LayoutHelpers.AtHorizontalCenterIn(filterContainerTitle, filterContainer)

	local filterGroupName = Group(filterContainer)
	filterGroupName.Height:Set(24)
	filterGroupName.Width:Set(filterContainer.Width)
	LayoutHelpers.AtLeftTopIn(filterGroupName, filterContainer, 0, 32)
	local filterNameLabel = UIUtil.CreateText(filterGroupName, 'Name', 14, "Arial")
	LayoutHelpers.AtLeftIn(filterNameLabel, filterGroupName, 2)
	LayoutHelpers.AtVerticalCenterIn(filterNameLabel, filterGroupName)
	local filterNameEdit = Edit(filterGroupName)
	LayoutHelpers.RightOf(filterNameEdit, filterNameLabel, 2)
	filterNameEdit.Width:Set(160)
	filterNameEdit.Height:Set(filterGroupName.Height)
	filterNameEdit:SetFont(UIUtil.bodyFont, 12)
	filterNameEdit:SetForegroundColor(UIUtil.fontColor)
	filterNameEdit:SetHighlightBackgroundColor('00000000')
    filterNameEdit:SetHighlightForegroundColor(UIUtil.fontColor)
	filterNameEdit:ShowBackground(true)
	filterNameEdit:SetMaxChars(40)

	local searchBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Search", 16, 2)
	LayoutHelpers.AtRightTopIn(searchBtn, panel, 30, 644)
	searchBtn.OnClick = function(self, modifiers)
		-- ???
	end

-- Bottom bar buttons: search, reset filters, exit

	local resetBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Reset Filters", 16, 2)
	LayoutHelpers.LeftOf(resetBtn, searchBtn)
	resetBtn.OnClick = function(self, modifiers)
		-- Set all filter fields to defaults
		-- Reflect reset in UI
	end

	local exitBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Exit", 16, 2)
	LayoutHelpers.AtLeftTopIn(exitBtn, panel, 30, 644)
	exitBtn.OnClick = function(self, modifiers)
		if over then
			panel:Destroy()
		else
			parent:Destroy()
		end
		callback()
	end

	UIUtil.MakeInputModal(panel, function() exitBtn.OnClick(exitBtn) end)
end