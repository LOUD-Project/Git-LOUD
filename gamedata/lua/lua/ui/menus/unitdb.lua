-- unitdb.lua
-- Author: Rat Circus

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Edit = import('/lua/maui/edit.lua').Edit
local Group = import('/lua/maui/group.lua').Group
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local dirs = {
	'/units',
	'/mods/4DC/units',
	'/mods/BlackOpsUnleashed/units',
	'/mods/BrewLAN_LOUD/units',
	'/mods/LOUD Unit Additions/units',
	'/mods/TotalMayhem/units',
	'/mods/BattlePack/units',
}

allBlueprints = {} -- Map unit IDs to BPs
temp = nil
countBPs = 0

local unitDisplay = false
local listContainer = false

local units = {} -- Map unit indices to IDs
local notFiltered = {} -- Units by index which pass filters
local count = 0 -- Number of units which pass filters
local last = -1 -- Index of last unit to pass filters
local noIcon = {} -- Precache ID of units with no icons

local filters = {}

function CreateUnitDB(over, inGame, callback)
-- Parse BPs
	-- Must plug UnitBlueprint() into engine before running doscript on .bps
	doscript '/lua/ui/menus/unitdb_bps.lua'

	local bpc = 1
	for _, dir in dirs do
		for _, file in DiskFindFiles(dir, '*_unit.bp') do
			-- RATODO: Certain BrewLAN IDs end with _large or _small
			local id = string.sub(file, string.find(file, '[%a%d]*_unit%.bp$'))
			id = string.sub(id, 1, string.len(id) - 8)
			safecall("UNIT DB: Loading BP "..file, doscript, file)
			allBlueprints[id] = temp
			local ico = '/textures/ui/common/icons/units/'..id..'_icon.dds'
			if not DiskGetFileInfo(ico) then
				noIcon[id] = true
			end
			units[bpc] = id
			notFiltered[bpc] = true
			bpc = bpc + 1
		end
	end

	last = bpc
	count = table.getsize(units)

	-- Fetch all unit descriptions

	doscript '/lua/ui/help/unitdescription.lua'
	doscript '/mods/BrewLAN_LOUD/hook/lua/ui/help/unitdescription.lua'
	doscript '/mods/4DC/hook/lua/ui/help/unitdescription.lua'
	doscript '/mods/BlackOpsUnleashed/hook/lua/ui/help/unitdescription.lua'
	doscript '/mods/LOUD Unit Additions/hook/lua/ui/help/unitdescription.lua'
	doscript '/mods/TotalMayhem/hook/lua/ui/help/unitdescription.lua'
	doscript '/mods/BattlePack/hook/lua/ui/help/unitdescription.lua'

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

	unitDisplay = Group(panel)
	unitDisplay.Height:Set(600)
	unitDisplay.Width:Set(260)
	unitDisplay.top = 0
	LayoutHelpers.AtLeftTopIn(unitDisplay, panel, 20, 72)
	unitDisplay.bg = Bitmap(unitDisplay)
	unitDisplay.bg.Depth:Set(unitDisplay.Depth)
	LayoutHelpers.FillParent(unitDisplay.bg, unitDisplay)

	unitDisplay.icon = Bitmap(unitDisplay)
	LayoutHelpers.AtLeftTopIn(unitDisplay.icon, unitDisplay)
	unitDisplay.name = UIUtil.CreateText(unitDisplay, '', 24, "Arial Bold")
	unitDisplay.name:DisableHitTest()
	LayoutHelpers.RightOf(unitDisplay.name, unitDisplay.icon, 6)
	unitDisplay.shortDesc = UIUtil.CreateText(unitDisplay, '', 18, UIUtil.bodyFont)
	unitDisplay.shortDesc:DisableHitTest()
	LayoutHelpers.Below(unitDisplay.shortDesc, unitDisplay.name)
	unitDisplay.longDesc = UIUtil.CreateTextBox(unitDisplay)
	LayoutHelpers.Below(unitDisplay.longDesc, unitDisplay.icon, 4)
	unitDisplay.longDesc.Width:Set(unitDisplay.Width)
	unitDisplay.longDesc.Height:Set(120)
	unitDisplay.longDesc.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end
	unitDisplay.abilities = ItemList(unitDisplay)
	LayoutHelpers.Below(unitDisplay.abilities, unitDisplay.longDesc, 6)
	unitDisplay.abilities.Width:Set(unitDisplay.Width)
	unitDisplay.abilities.Height:Set(120)
	unitDisplay.abilities.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end
	UIUtil.CreateVertScrollbarFor(unitDisplay.abilities)

-- List of filtered units

	listContainer = Group(panel)
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
		unitList[i].icon:DisableHitTest()
		unitList[i].name:DisableHitTest()
		unitList[i].desc:DisableHitTest()
		unitList[i].id:DisableHitTest()
	end

	CreateElement(1)
	LayoutHelpers.AtLeftTopIn(unitList[1], listContainer)

	for i = 2, 9 do
		CreateElement(i)
		LayoutHelpers.Below(unitList[i], unitList[i - 1])
	end

	local numLines = function() return table.getsize(unitList) end

	local function DataSize()
		return count
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
		local function ClearRemaining(cur)
			for l = cur, table.getsize(unitList) do
				unitList[l].name:SetText('')
				unitList[l].desc:SetText('')
				unitList[l].id:SetText('')
				unitList[l]:Hide()
			end
		end
		local j = self.top
		for i, v in unitList do
			j = j + 1
			while not notFiltered[j] do
				if j > last then
					ClearRemaining(i)
					return
				end
				j = j + 1
			end
			FillLine(v, allBlueprints[units[j]], j)
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

	filterNameEdit.OnTextChanged = function(self, newText, oldText)
		if newText == '' then
			filters['name'] = nil
		end
		if not filters['name'] or filters['name'] ~= newText then
			filters['name'] = newText
		end
	end

-- Bottom bar buttons: search, reset filters, exit

	local searchBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Search", 16, 2)
	LayoutHelpers.AtRightTopIn(searchBtn, panel, 30, 644)
	searchBtn.OnClick = function(self, modifiers)
		Filter()
		listContainer:CalcVisible()
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

function FillLine(line, bp, index)
	line:Show()
	local n = LOC(bp.General.UnitName) or LOC(bp.Description) or 'Unnamed Unit'
	line.name:SetText(n)
	line.desc:SetText(LOC(bp.Description) or 'Unnamed Unit')
	line.id:SetText(units[index])
	local ico = '/textures/ui/common/icons/units/'..units[index]..'_icon.dds'
	if noIcon[units[index]] then
		line.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
	else
		line.icon:SetTexture(ico)
	end
	line.HandleEvent = function(self, event)
		if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
			DisplayUnit(bp, units[index])
			local sound = Sound({Cue = "UI_Mod_Select", Bank = "Interface",})
            PlaySound(sound)
		end
	end
end

function DisplayUnit(bp, id)
	unitDisplay.name:SetText(LOC(bp.General.UnitName) or LOC(bp.Description) or 'Unnamed Unit')
	unitDisplay.shortDesc:SetText(LOC(bp.Description) or 'Unnamed Unit')
	local ico = '/textures/ui/common/icons/units/'..id..'_icon.dds'
	if noIcon[id] then
		unitDisplay.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
	else
		unitDisplay.icon:SetTexture(ico)
	end
	local ld = LOC(Description[id]) or 'No description available for this unit.'
	UIUtil.SetTextBoxText(unitDisplay.longDesc, ld)
	if bp.Display.Abilities then
		unitDisplay.abilities:DeleteAllItems()
		unitDisplay.abilities:Show()
		for _, a in bp.Display.Abilities do
			unitDisplay.abilities:AddItem(LOC(a))
		end
	else
		unitDisplay.abilities:Hide()
	end
end

function Filter()
	local function TryLower(string)
		if not string then return ''
		else return string.lower(string) end
	end

	LOG("UNIT DB: Filtering by: "..repr(filters))
	listContainer.top = 0
	count = table.getsize(units)
	for i, id in units do
		local bp = allBlueprints[id]
		notFiltered[i] = true

		if filters['name'] then
			local bpN = TryLower(LOC(bp.General.UnitName))
			filters['name'] = string.lower(filters['name'])
			if not string.find(bpN, filters['name']) then
				notFiltered[i] = false
				count = count - 1
				continue
			end
		end

		-- If unit has passed all filters, it is now the last to have done so
		last = i
	end

	LOG("UNIT DB: Unit list filtered down to: "..count)
end