-- unitdb.lua
-- Author: Rat Circus

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Edit = import('/lua/maui/edit.lua').Edit
local Group = import('/lua/maui/group.lua').Group
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local dirs = {
	'/mods/4DC/units',
	'/mods/BlackOpsUnleashed/units',
	'/mods/BrewLAN_LOUD/units',
	'/mods/LOUD Unit Additions/units',
	'/mods/TotalMayhem/units',
	'/mods/BattlePack/units',
	'/units',
}

allBlueprints = {}
temp = nil
countBPs = 0

local units = {}

local filters = {}

function CreateUnitDB(over, inGame, callback)
-- Parse BPs
	-- Must plug UnitBlueprint() into engine before running doscript on .bps
	doscript '/lua/ui/menus/unitdb_bps.lua'

	local i = 1
	for _, dir in dirs do
		for _, file in DiskFindFiles(dir, '*_unit.bp') do
			local id = string.sub(file, string.find(file, '[%a%d]*_unit%.bp$'))
			id = string.sub(id, 1, string.len(id) - 8)
			safecall("UNIT DB: Loading BP "..file, doscript, file)
			allBlueprints[id] = temp
			units[i] = id
			i = i + 1
		end
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

	local displayIcon = Bitmap(unitDisplay)
	LayoutHelpers.AtLeftTopIn(displayIcon, unitDisplay)
	local displayName = UIUtil.CreateText(unitDisplay, 'Trickshot', 24, "Arial Bold")
	displayName:DisableHitTest()
	LayoutHelpers.RightOf(displayName, displayIcon, 6)
	local displayShortDesc = UIUtil.CreateText(unitDisplay, 'Mobile Non-Ivan Unit', 18, "Arial")
	displayShortDesc:DisableHitTest()
	LayoutHelpers.Below(displayShortDesc, displayName)
	local displayDesc = UIUtil.CreateTextBox(unitDisplay)
	LayoutHelpers.Below(displayDesc, displayIcon, 4)
	displayDesc.Width:Set(unitDisplay.Width)
	displayDesc.Height:Set(120)
	displayDesc.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end

-- List of filtered units

	local listContainer = Group(panel)
	listContainer.Height:Set(556)
	listContainer.Width:Set(320)
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
		unitList[i].bg:SetSolidColor('3B4649') -- Same colour as lobby rows in background
		unitList[i].bg.Right:Set(function() return unitList[i].Right() - 10 end)
		unitList[i].icon = Bitmap(unitList[i])
		LayoutHelpers.AtLeftTopIn(unitList[i].icon, unitList[i])
		unitList[i].name = UIUtil.CreateText(listContainer, '', 14, UIUtil.bodyFont)
		LayoutHelpers.RightOf(unitList[i].name, unitList[i].icon, 2)
		unitList[i].desc = UIUtil.CreateText(listContainer, '', 14, UIUtil.bodyFont)
		LayoutHelpers.Below(unitList[i].desc, unitList[i].name, 2)
		unitList[i].id = UIUtil.CreateText(listContainer, '', 14, UIUtil.bodyFont)
		LayoutHelpers.Below(unitList[i].id, unitList[i].desc, 2)
	end

	CreateElement(1)
	LayoutHelpers.AtLeftTopIn(unitList[1], listContainer)

	for i = 2, 9 do
		CreateElement(i)
		LayoutHelpers.Below(unitList[i], unitList[i - 1])
	end

	local numLines = function() return table.getsize(unitList) end

	local function DataSize()
		return table.getn(units)
	end

	listContainer.GetScrollValues = function(self, axis)
		local size = DataSize()
		return 0, size, self.top, math.min(self.top + numLines(), size)
	end

	listContainer.ScrollLines = function(self, axis, delta)
		self:ScrollSetTop(axis, self.top + math.floor(delta))
	end

	listContainer.ScrollPages = function(self, axis, delta)
		self:ScrollSetTop(axis, self.top + math.floor(delta) * numLines())
	end

	listContainer.ScrollSetTop = function(self, axis, top)
		top = math.floor(top)
        if top == self.top then return end
        local size = DataSize()
        self.top = math.max(math.min(size - numLines() , top), 0)
        self:CalcVisible()
	end

	listContainer.IsScrollable = function(self, axis)
		return true
	end

	listContainer.CalcVisible = function(self)
		for i, v in unitList do
			if units[i + self.top] then
				-- LOG("RATS: "..repr(i + self.top)..": "..repr(units[i + self.top])..": "..repr(allBlueprints[units[i + self.top]]))
				FillLine(v, allBlueprints[units[i + self.top]], i + self.top)
			else
				v:Hide()
			end
		end
	end

	listContainer:CalcVisible()

	listContainer.HandleEvent = function(self, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            self:ScrollLines(nil, lines)
        end
	end

	UIUtil.CreateVertScrollbarFor(listContainer)

-- Filters section

	local filterContainer = Group(panel)
	filterContainer.Height:Set(556)
	filterContainer.Width:Set(260)
	filterContainer.top = 0
	LayoutHelpers.RightOf(filterContainer, listContainer, 32)

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

-- Bottom bar buttons: search, reset filters, exit

	local searchBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Search", 16, 2)
	LayoutHelpers.AtRightTopIn(searchBtn, panel, 30, 644)
	searchBtn.OnClick = function(self, modifiers)
		-- ???
	end

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

function FillLine(line, bp, lineID)
	local n = LOC(bp.General.UnitName) or LOC(bp.Description) or 'Unnamed Unit'
	line.name:SetText(n)
	line.desc:SetText(LOC(bp.Description) or 'Unnamed Unit')
	line.id:SetText(units[lineID])
	local ico = '/textures/ui/common/icons/units/'..units[lineID]..'_icon.dds'
	line.icon:SetTexture(ico)
end

local function Filter()
	if table.getsize(filters) == 0 then
		
	end
end