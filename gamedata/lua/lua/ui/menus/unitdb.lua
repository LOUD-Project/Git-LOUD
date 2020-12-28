-- unitdb.lua
-- Author: Rat Circus

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local BitmapCombo = import('/lua/ui/controls/combo.lua').BitmapCombo
local Combo = import('/lua/ui/controls/combo.lua').Combo
local Edit = import('/lua/maui/edit.lua').Edit
local FactionData = import('/lua/factions.lua')
local Group = import('/lua/maui/group.lua').Group
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

-- Constants

local dirs = {
	'/units',
	'/mods/4DC/units',
	'/mods/BlackOpsUnleashed/units',
	'/mods/BrewLAN_LOUD/units',
	'/mods/LOUD Unit Additions/units',
	'/mods/TotalMayhem/units',
	'/mods/BattlePack/units',
}

local originMap = {
	['vanilla'] = 'Vanilla',
	['4dc'] = '4th Dimension Units',
	['blackopsunleashed'] = 'BlackOps Unleashed',
	['brewlan_loud'] = 'BrewLAN LOUD',
	['loud unit additions'] = 'LOUD Unit Additions',
	['totalmayhem'] = 'Total Mayhem',
	['battlepack'] = 'Wyvern Battle Pack',
}

local unitDispAbilHeight = 120

local factionBmps = {}
local factionTooltips = {}

table.insert(factionBmps, "/faction_icon-sm/random_ico.dds")
-- RATODO: Tooltip for all faction filter option

for i, tbl in FactionData.Factions do
	factionBmps[i + 1] = tbl.SmallIcon
	factionTooltips[i + 1] = tbl.TooltipID
end

-- Backing structures

allBlueprints = {} -- Map unit IDs to BPs
temp = nil
countBPs = 0

local units = {} -- Map unit indices to ID
local origin = {} -- Map unit indices to origin mod
local notFiltered = {} -- Units by index which pass filters
local count = 0 -- Number of units which pass filters
local first = -1 -- Index of first unit to pass filters
local last = -1 -- Index of last unit to pass filters
local noIcon = {} -- Precache ID of units with no icons
local filters = {}

-- GUI elements

local unitDisplay = false
local listContainer = false
local resultText = false

function CreateUnitDB(over, inGame, callback)
-- Parse BPs
	-- Must plug UnitBlueprint() into engine before running doscript on .bps
	doscript '/lua/ui/menus/unitdb_bps.lua'

	local bpc = 1
	for _, dir in dirs do
		for _, file in DiskFindFiles(dir, '*_unit.bp') do
			-- RATODO: Certain BrewLAN IDs end with _large or _small
			local mod = 'vanilla'
			local x, z = string.find(file, '^/mods/[%s_%w]+/')
			if x and z then
				mod = string.sub(file, x, z)
				mod = string.sub(mod, 7, string.len(mod) - 1)
			end
			local id = string.sub(file, string.find(file, '[%a%d]*_unit%.bp$'))
			id = string.sub(id, 1, string.len(id) - 8)
			safecall("UNIT DB: Loading BP "..file, doscript, file)
			allBlueprints[id] = temp
			local ico = '/textures/ui/common/icons/units/'..id..'_icon.dds'
			if not DiskGetFileInfo(ico) then
				noIcon[id] = true
			end
			units[bpc] = id
			-- Make mod origin correspond to an index on the filter combo
			if mod == 'vanilla' then
				origin[bpc] = 2
			elseif mod == '4dc' then
				origin[bpc] = 3
			elseif mod == 'blackopsunleashed' then
				origin[bpc] = 4
			elseif mod == 'brewlan_loud' then
				origin[bpc] = 5
			elseif mod == 'loud unit additions' then
				origin[bpc] = 6
			elseif mod == 'totalmayhem' then
				origin[bpc] = 7
			elseif mod == 'battlepack' then
				origin[bpc] = 8
			end
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

	ClearFilters()

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

	unitDisplay.stratIcon = Bitmap(unitDisplay.icon)
	LayoutHelpers.AtRightTopIn(unitDisplay.stratIcon, unitDisplay.icon)

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
	unitDisplay.abilities.Height:Set(unitDispAbilHeight)
	unitDisplay.abilities.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end
	UIUtil.CreateVertScrollbarFor(unitDisplay.abilities)

	unitDisplay.healthIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-health_bmp.dds'))
	LayoutHelpers.Below(unitDisplay.healthIcon, unitDisplay.abilities, 6)
	unitDisplay.health = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.health, unitDisplay.healthIcon, 6)
	unitDisplay.health:DisableHitTest()

	unitDisplay.massIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-mass_bmp.dds'))
	LayoutHelpers.Below(unitDisplay.massIcon, unitDisplay.healthIcon, 6)
	unitDisplay.mass = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.mass, unitDisplay.massIcon, 6)
	unitDisplay.mass:DisableHitTest()
	unitDisplay.energyIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-energy_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.energyIcon, unitDisplay.mass, 6)
	unitDisplay.energy = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.energy, unitDisplay.energyIcon, 6)
	unitDisplay.energy:DisableHitTest()
	unitDisplay.capIcon = Bitmap(unitDisplay, UIUtil.UIFile('/dialogs/score-overlay/tank_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.capIcon, unitDisplay.energy, 6)
	unitDisplay.cap = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.cap, unitDisplay.capIcon, 6)
	unitDisplay.cap:DisableHitTest()

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
		self.top = math.max(math.min(size - numLines(), top), 0)
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
		local j
		-- Move to first unit which passes filter if possible
		if first > 0 then j = first
		else j = 0 end
		-- Account for scroll bar offset
		for t = 1, self.top do
			j = j + 1
			while not notFiltered[j] do
				j = j + 1
			end
		end
		for i, v in unitList do
			-- Skip over filtered units
			while not notFiltered[j] do
				if j > last then
					ClearRemaining(i)
					return
				end
				j = j + 1
			end
			FillLine(v, allBlueprints[units[j]], j)
			j = j + 1
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

-- FILTERS: Basics

	local filterContainer = Group(panel)
	filterContainer.Height:Set(556)
	filterContainer.Width:Set(260)
	filterContainer.top = 0
	LayoutHelpers.RightOf(filterContainer, listContainer, 32)

	local filterContainerTitle = UIUtil.CreateText(filterContainer, 'Filters', 24, UIUtil.titleFont)
	LayoutHelpers.AtTopIn(filterContainerTitle, filterContainer)
	LayoutHelpers.AtHorizontalCenterIn(filterContainerTitle, filterContainer)

	-- Name

	local filterGroupName = Group(filterContainer)
	filterGroupName.Height:Set(20)
	filterGroupName.Width:Set(filterContainer.Width)
	LayoutHelpers.AtLeftTopIn(filterGroupName, filterContainer, 0, 32)
	local filterNameLabel = UIUtil.CreateText(filterGroupName, 'Name', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterNameLabel, filterGroupName, 2)
	LayoutHelpers.AtVerticalCenterIn(filterNameLabel, filterGroupName)

	local filterNameEdit = Edit(filterGroupName)
	LayoutHelpers.AtRightIn(filterNameEdit, filterGroupName, 2)
	LayoutHelpers.AtVerticalCenterIn(filterNameEdit, filterGroupName)
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

	-- Faction

	local filterGroupFaction = Group(filterContainer)
	filterGroupFaction.Height:Set(20)
	filterGroupFaction.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupFaction, filterGroupName)
	local filterFactionLabel = UIUtil.CreateText(filterGroupFaction, 'Faction', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterFactionLabel, filterGroupFaction)
	LayoutHelpers.AtVerticalCenterIn(filterFactionLabel, filterGroupFaction)

	local filterFactionCombo = BitmapCombo(filterGroupFaction, factionBmps, table.getn(factionBmps), nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	LayoutHelpers.AtRightIn(filterFactionCombo, filterGroupFaction, 2)
	LayoutHelpers.AtVerticalCenterIn(filterFactionCombo, filterGroupFaction)
	filterFactionCombo.Width:Set(60)
	filterFactionCombo.OnClick = function(self, index)
		-- 1 = All ; 2 = UEF ; 3 = Cybran ; 4 = Aeon ; 5 -> Sera
		filters['faction'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	Tooltip.AddComboTooltip(filterFactionCombo, factionTooltips)

	-- Tech level

	local filterGroupTech = Group(filterContainer)
	filterGroupTech.Height:Set(20)
	filterGroupTech.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupTech, filterGroupFaction)
	local filterTechLabel = UIUtil.CreateText(filterGroupTech, 'Tech Level', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterTechLabel, filterGroupTech)
	LayoutHelpers.AtVerticalCenterIn(filterTechLabel, filterGroupTech)

	local filterTechCombo = Combo(filterGroupTech, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterTechCombo:AddItems({'All', 'Tech 1', 'Tech 2', 'Tech 3', 'Experimental'}, 1)
	LayoutHelpers.AtRightIn(filterTechCombo, filterGroupTech, 2)
	LayoutHelpers.AtVerticalCenterIn(filterTechCombo, filterGroupTech)
	filterTechCombo.Width:Set(120)
	filterTechCombo.OnClick = function(self, index)
		filters['tech'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Type (land, air, naval, base)

	local filterGroupType = Group(filterContainer)
	filterGroupType.Height:Set(20)
	filterGroupType.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupType, filterGroupTech)
	local filterTypeLabel = UIUtil.CreateText(filterGroupType, 'Unit Type', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterTypeLabel, filterGroupType)
	LayoutHelpers.AtVerticalCenterIn(filterTypeLabel, filterGroupType)

	local filterTypeCombo = Combo(filterGroupType, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterTypeCombo:AddItems({'All', 'Land', 'Air', 'Naval', 'Base'}, 1)
	LayoutHelpers.AtRightIn(filterTypeCombo, filterGroupType, 2)
	LayoutHelpers.AtVerticalCenterIn(filterTypeCombo, filterGroupType)
	filterTypeCombo.Width:Set(80)
	filterTypeCombo.OnClick = function(self, index)
		filters['type'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Origin mod

	local filterGroupOrigin = Group(filterContainer)
	filterGroupOrigin.Height:Set(20)
	filterGroupOrigin.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupOrigin, filterGroupType)
	local filterOriginLabel = UIUtil.CreateText(filterGroupOrigin, 'Mod', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterOriginLabel, filterGroupOrigin)
	LayoutHelpers.AtVerticalCenterIn(filterOriginLabel, filterGroupOrigin)

	local modComboOpts = {
		'All',
		'Vanilla',
		'4th Dimension Units',
		'BlackOps Unleashed',
		'BrewLAN LOUD',
		'LOUD Unit Additions',
		'Total Mayhem',
		'Wyvern Battle Pack',
	}
	local filterOriginCombo = Combo(filterGroupOrigin, 14, table.getsize(modComboOpts), nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterOriginCombo:AddItems(modComboOpts, 1)
	LayoutHelpers.AtRightIn(filterOriginCombo, filterGroupOrigin, 2)
	LayoutHelpers.AtVerticalCenterIn(filterOriginCombo, filterGroupOrigin)
	filterOriginCombo.Width:Set(160)
	filterOriginCombo.OnClick = function(self, index)
		filters['mod'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

-- FILTERS: Weaponry

	-- Horizontal row to divide fundamental traits from weapons block
	-- Also, a label

	local weaponsRow = Bitmap(filterContainer)
	LayoutHelpers.Below(weaponsRow, filterGroupOrigin, 4)
	weaponsRow.Height:Set(2)
	weaponsRow.Width:Set(filterContainer.Width() - 8)
	weaponsRow:SetSolidColor('ADCFCE') -- Same colour as light lines in background

	local weaponsBlockLabel = UIUtil.CreateText(filterContainer, 'Weapons', 20, UIUtil.buttonFont)
	LayoutHelpers.Below(weaponsBlockLabel, weaponsRow, 4)
	LayoutHelpers.AtHorizontalCenterIn(weaponsBlockLabel, filterContainer)

	-- Direct fire

	local filterGroupDirectfire = Group(filterContainer)
	filterGroupDirectfire.Height:Set(20)
	filterGroupDirectfire.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupDirectfire, weaponsRow, 4 + weaponsBlockLabel.Height())
	local filterDirectfireLabel = UIUtil.CreateText(filterGroupDirectfire, 'Direct Fire', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterDirectfireLabel, filterGroupDirectfire)
	LayoutHelpers.AtVerticalCenterIn(filterDirectfireLabel, filterGroupDirectfire)

	local filterDirectfireCombo = Combo(filterGroupDirectfire, 14, 3, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterDirectfireCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterDirectfireCombo, filterGroupDirectfire, 2)
	LayoutHelpers.AtVerticalCenterIn(filterDirectfireCombo, filterGroupDirectfire)
	filterDirectfireCombo.Width:Set(60)
	filterDirectfireCombo.OnClick = function(self, index)
		filters['directfire'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Indirect fire

	local filterGroupIndirectfire = Group(filterContainer)
	filterGroupIndirectfire.Height:Set(20)
	filterGroupIndirectfire.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupIndirectfire, filterGroupDirectfire, 2)
	local filterIndirectfireLabel = UIUtil.CreateText(filterGroupIndirectfire, 'Indirect Fire', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterIndirectfireLabel, filterGroupIndirectfire)
	LayoutHelpers.AtVerticalCenterIn(filterIndirectfireLabel, filterGroupIndirectfire)

	local filterIndirectfireCombo = Combo(filterGroupIndirectfire, 14, 3, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterIndirectfireCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterIndirectfireCombo, filterGroupIndirectfire, 2)
	LayoutHelpers.AtVerticalCenterIn(filterIndirectfireCombo, filterGroupIndirectfire)
	filterIndirectfireCombo.Width:Set(60)
	filterIndirectfireCombo.OnClick = function(self, index)
		filters['indirectfire'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Anti-air

	local filterGroupAntiair = Group(filterContainer)
	filterGroupAntiair.Height:Set(20)
	filterGroupAntiair.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupAntiair, filterGroupIndirectfire, 2)
	local filterAntiairLabel = UIUtil.CreateText(filterGroupAntiair, 'Anti-Air', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterAntiairLabel, filterGroupAntiair)
	LayoutHelpers.AtVerticalCenterIn(filterAntiairLabel, filterGroupAntiair)

	local filterAntiairCombo = Combo(filterGroupAntiair, 14, 3, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterAntiairCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterAntiairCombo, filterGroupAntiair, 2)
	LayoutHelpers.AtVerticalCenterIn(filterAntiairCombo, filterGroupAntiair)
	filterAntiairCombo.Width:Set(60)
	filterAntiairCombo.OnClick = function(self, index)
		filters['antiair'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Torpedoes

	local filterGroupTorps = Group(filterContainer)
	filterGroupTorps.Height:Set(20)
	filterGroupTorps.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupTorps, filterGroupAntiair, 2)
	local filterTorpsLabel = UIUtil.CreateText(filterGroupTorps, 'Torpedoes', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterTorpsLabel, filterGroupTorps)
	LayoutHelpers.AtVerticalCenterIn(filterTorpsLabel, filterGroupTorps)

	local filterTorpsCombo = Combo(filterGroupTorps, 14, 3, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterTorpsCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterTorpsCombo, filterGroupTorps, 2)
	LayoutHelpers.AtVerticalCenterIn(filterTorpsCombo, filterGroupTorps)
	filterTorpsCombo.Width:Set(60)
	filterTorpsCombo.OnClick = function(self, index)
		filters['torpedoes'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Countermeasures

	local filterGroupCounter = Group(filterContainer)
	filterGroupCounter.Height:Set(20)
	filterGroupCounter.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupCounter, filterGroupTorps, 2)
	local filterCounterLabel = UIUtil.CreateText(filterGroupCounter, 'Countermeasures', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterCounterLabel, filterGroupCounter)
	LayoutHelpers.AtVerticalCenterIn(filterCounterLabel, filterGroupCounter)

	local filterCounterCombo = Combo(filterGroupCounter, 14, 3, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterCounterCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterCounterCombo, filterGroupCounter, 2)
	LayoutHelpers.AtVerticalCenterIn(filterCounterCombo, filterGroupCounter)
	filterCounterCombo.Width:Set(60)
	filterCounterCombo.OnClick = function(self, index)
		filters['countermeasures'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Death weapons

	local filterGroupDeathWeap = Group(filterContainer)
	filterGroupDeathWeap.Height:Set(20)
	filterGroupDeathWeap.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupDeathWeap, filterGroupCounter, 2)
	local filterDeathWeapLabel = UIUtil.CreateText(filterGroupDeathWeap, 'Death Weapon', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterDeathWeapLabel, filterGroupDeathWeap)
	LayoutHelpers.AtVerticalCenterIn(filterDeathWeapLabel, filterGroupDeathWeap)

	local filterDeathWeapCombo = Combo(filterGroupDeathWeap, 14, 4, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterDeathWeapCombo:AddItems({'Any', 'Death Explosion', 'Air Crash', 'None'}, 1)
	LayoutHelpers.AtRightIn(filterDeathWeapCombo, filterGroupDeathWeap, 2)
	LayoutHelpers.AtVerticalCenterIn(filterDeathWeapCombo, filterGroupDeathWeap)
	filterDeathWeapCombo.Width:Set(140)
	filterDeathWeapCombo.OnClick = function(self, index)
		filters['deathweapon'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

-- FILTERS: Miscellaneous

	-- Another horizontal row

	local miscRow = Bitmap(filterContainer)
	LayoutHelpers.Below(miscRow, filterGroupDeathWeap, 4)
	miscRow.Height:Set(2)
	miscRow.Width:Set(filterContainer.Width() - 8)
	miscRow:SetSolidColor('ADCFCE') -- Same colour as light lines in background

	-- Amphibious

	local filterGroupAmphib = Group(filterContainer)
	filterGroupAmphib.Height:Set(20)
	filterGroupAmphib.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupAmphib, miscRow, 2)
	local filterAmphibLabel = UIUtil.CreateText(filterGroupAmphib, 'Amphibious', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterAmphibLabel, filterGroupAmphib)
	LayoutHelpers.AtVerticalCenterIn(filterAmphibLabel, filterGroupAmphib)

	local filterAmphibCombo = Combo(filterGroupAmphib, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterAmphibCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterAmphibCombo, filterGroupAmphib, 2)
	LayoutHelpers.AtVerticalCenterIn(filterAmphibCombo, filterGroupAmphib)
	filterAmphibCombo.Width:Set(80)
	filterAmphibCombo.OnClick = function(self, index)
		filters['amphib'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Transport capability

	local filterGroupTransport = Group(filterContainer)
	filterGroupTransport.Height:Set(20)
	filterGroupTransport.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupTransport, filterGroupAmphib, 2)
	local filterTransportLabel = UIUtil.CreateText(filterGroupTransport, 'Transport', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterTransportLabel, filterGroupTransport)
	LayoutHelpers.AtVerticalCenterIn(filterTransportLabel, filterGroupTransport)

	local filterTransportCombo = Combo(filterGroupTransport, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterTransportCombo:AddItems({'Any', 'Yes', 'No'}, 1)
	LayoutHelpers.AtRightIn(filterTransportCombo, filterGroupTransport, 2)
	LayoutHelpers.AtVerticalCenterIn(filterTransportCombo, filterGroupTransport)
	filterTransportCombo.Width:Set(80)
	filterTransportCombo.OnClick = function(self, index)
		filters['transport'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	local filterGroupShield = Group(filterContainer)
	filterGroupShield.Height:Set(20)
	filterGroupShield.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupShield, filterGroupTransport, 2)
	local filterShieldLabel = UIUtil.CreateText(filterGroupShield, 'Shielding', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterShieldLabel, filterGroupShield)
	LayoutHelpers.AtVerticalCenterIn(filterShieldLabel, filterGroupShield)

	local filterShieldCombo = Combo(filterGroupShield, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterShieldCombo:AddItems({'Any', 'Dome', 'Personal', 'None'}, 1)
	LayoutHelpers.AtRightIn(filterShieldCombo, filterGroupShield, 2)
	LayoutHelpers.AtVerticalCenterIn(filterShieldCombo, filterGroupShield)
	filterShieldCombo.Width:Set(100)
	filterShieldCombo.OnClick = function(self, index)
		filters['shield'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Intel

	local filterGroupIntel = Group(filterContainer)
	filterGroupIntel.Height:Set(20)
	filterGroupIntel.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupIntel, filterGroupShield, 2)
	local filterIntelLabel = UIUtil.CreateText(filterGroupIntel, 'Intel', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterIntelLabel, filterGroupIntel)
	LayoutHelpers.AtVerticalCenterIn(filterIntelLabel, filterGroupIntel)

	local filterIntelCombo = Combo(filterGroupIntel, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterIntelCombo:AddItems({'Any', 'None', 'Radar', 'Sonar', 'Omni'}, 1)
	LayoutHelpers.AtRightIn(filterIntelCombo, filterGroupIntel, 2)
	LayoutHelpers.AtVerticalCenterIn(filterIntelCombo, filterGroupIntel)
	filterIntelCombo.Width:Set(80)
	filterIntelCombo.OnClick = function(self, index)
		filters['intel'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	-- Stealth

	local filterGroupStealth = Group(filterContainer)
	filterGroupStealth.Height:Set(20)
	filterGroupStealth.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupStealth, filterGroupIntel)
	local filterStealthLabel = UIUtil.CreateText(filterGroupStealth, 'Stealth', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterStealthLabel, filterGroupStealth)
	LayoutHelpers.AtVerticalCenterIn(filterStealthLabel, filterGroupStealth)

	local filterStealthCombo = Combo(filterGroupStealth, 14, 5, nil, nil,  "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	filterStealthCombo:AddItems({'Any', 'None', 'Radar', 'Sonar', 'Cloak'}, 1)
	LayoutHelpers.AtRightIn(filterStealthCombo, filterGroupStealth, 2)
	LayoutHelpers.AtVerticalCenterIn(filterStealthCombo, filterGroupStealth)
	filterStealthCombo.Width:Set(80)
	filterStealthCombo.OnClick = function(self, index)
		filters['stealth'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

-- Bottom bar controls

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
		ClearFilters()
		-- Reflect reset in UI
		filterNameEdit:SetText('')
		filterFactionCombo:SetItem(1)
		filterTechCombo:SetItem(1)
		filterTypeCombo:SetItem(1)
		filterOriginCombo:SetItem(1)

		filterDirectfireCombo:SetItem(1)
		filterIndirectfireCombo:SetItem(1)
		filterAntiairCombo:SetItem(1)
		filterTorpsCombo:SetItem(1)
		filterCounterCombo:SetItem(1)
		filterDeathWeapCombo:SetItem(1)

		filterAmphibCombo:SetItem(1)
		filterTransportCombo:SetItem(1)
		filterShieldCombo:SetItem(1)
		filterIntelCombo:SetItem(1)
		filterStealthCombo:SetItem(1)
		Filter()
		listContainer:CalcVisible()
	end

	local exitBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Exit", 16, 2)
	LayoutHelpers.AtLeftTopIn(exitBtn, panel, 36, 644)
	exitBtn.OnClick = function(self, modifiers)
		if over then
			panel:Destroy()
		else
			parent:Destroy()
		end
		ClearFilters()
		callback()
	end

	local r = tostring(count).." results found."
	resultText = UIUtil.CreateText(panel, r, 16, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(resultText, panel, exitBtn.Width() + 30, 670)

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
	unitDisplay.stratIcon:SetTexture(UIUtil.UIFile('/game/strategicicons/'..bp.StrategicIconName..'_rest.dds'))
	local ld = LOC(Description[id]) or 'No description available for this unit.'
	UIUtil.SetTextBoxText(unitDisplay.longDesc, ld)
	if bp.Display.Abilities then
		unitDisplay.abilities:DeleteAllItems()
		unitDisplay.abilities.Height:Set(unitDispAbilHeight)
		unitDisplay.abilities:Show()
		for _, a in bp.Display.Abilities do
			unitDisplay.abilities:AddItem(LOC(a))
		end
	else
		unitDisplay.abilities.Height:Set(0)
		unitDisplay.abilities:Hide()
	end
	unitDisplay.health:SetText(tostring(bp.Defense.MaxHealth))
	unitDisplay.mass:SetText(tostring(bp.Economy.BuildCostMass))
	unitDisplay.energy:SetText(tostring(bp.Economy.BuildCostEnergy))
	if bp.General.CapCost then
		unitDisplay.cap:SetText(tostring(bp.General.CapCost))
	else
		unitDisplay.cap:SetText('1')
	end
end

function Filter()
	local function TryLower(string)
		if not string then return ''
		else return string.lower(string) end
	end

	first = -1

	local checkWeaps = 
		filters['directfire'] ~= 1 or
		filters['indirectfire'] ~= 1 or
		filters['antiair'] ~= 1 or
		filters['torpedoes'] ~= 1 or
		filters['countermeasures'] ~= 1 or
		filters['deathweapon'] ~= 1

	LOG("UNIT DB: Filtering by: "..repr(filters))
	listContainer.top = 0
	count = table.getsize(units)
	for i, id in units do
		local bp = allBlueprints[id]
		notFiltered[i] = true

		if filters['name'] then
			local bpN = TryLower(LOC(bp.General.UnitName))
			local bpSD = TryLower(LOC(bp.Description))
			filters['name'] = string.lower(filters['name'])
			if not string.find(bpN, filters['name'])
			and not string.find(bpSD, filters['name'])
			then
				notFiltered[i] = false
				count = count - 1
				continue
			end
		end

		if filters['faction'] == 1 then
			-- Do nothing
		elseif (filters['faction'] == 2 and bp.General.FactionName ~= 'UEF')
		or (filters['faction'] == 3 and bp.General.FactionName ~= 'CYBRAN')
		or (filters['faction'] == 4 and bp.General.FactionName ~= 'AEON')
		or (filters['faction'] == 5 and bp.General.FactionName ~= 'SERAPHIM') then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		if filters['tech'] == 1 then
			-- Do nothing
		elseif (filters['tech'] == 2 and not table.find(bp.Categories, 'TECH1'))
		or (filters['tech'] == 3 and not table.find(bp.Categories, 'TECH2'))
		or (filters['tech'] == 4 and not table.find(bp.Categories, 'TECH3'))
		or (filters['tech'] == 5 and not table.find(bp.Categories, 'EXPERIMENTAL')) then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		if filters['type'] == 1 then
			-- Do nothing
		else
			local struct = table.find(bp.Categories, 'STRUCTURE')
			if (filters['type'] == 5 and not struct)
			or (filters['type'] == 3 and not bp.Physics.BuildOnLayerCaps.LAYER_Air)
			or (filters['type'] == 2 and (struct or not table.find(bp.Categories, 'LAND')))
			or (filters['type'] == 4 and (struct or not table.find(bp.Categories, 'NAVAL')))
			then
				notFiltered[i] = false
				count = count - 1
				continue
			end
		end

		if filters['mod'] == 1 then
			-- Do nothing
		elseif filters['mod'] ~= origin[i] then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		if checkWeaps then
			local hasDirect = false
			local hasIndirect = false
			local hasAA = false
			local hasTorp = false
			local hasCounter = false
			-- 0 is no, 1 is explosion, 2 is air crash
			local hasDeathWeap = 0
			
			-- If no weapons are present, leave all as false
			if bp.Weapon then
				for _, v in bp.Weapon do
					-- Ignore dummy weapons
					if v.Label and
					(string.find(v.Label, 'Dummy') or
					string.find(v.Label, 'Painter') or
					string.find(v.Label, 'Tractor')) then
						continue
					end

					if v.RangeCategory == 'UWRC_DirectFire' then
						hasDirect = true
					elseif v.RangeCategory == 'UWRC_IndirectFire' then
						hasIndirect = true
					elseif v.RangeCategory == 'UWRC_AntiAir' then
						hasAA = true
					elseif v.RangeCategory == 'UWRC_AntiNavy' then
						hasTorp = true
					elseif v.RangeCategory == 'UWRC_Countermeasure' then
						hasCounter = true
					elseif v.Label == 'DeathImpact' then
						hasDeathWeap = 2
					elseif v.WeaponCategory == 'Death' then
						hasDeathWeap = 1
					end
				end
			end

			if ((filters['directfire'] == 2 and not hasDirect)
			or (filters['directfire'] == 3 and hasDirect))
			or ((filters['indirectfire'] == 2 and not hasIndirect)
			or (filters['indirectfire'] == 3 and hasIndirect))
			or ((filters['antiair'] == 2 and not hasAA)
			or (filters['antiair'] == 3 and hasAA))
			or ((filters['torpedoes'] == 2 and not hasTorp)
			or (filters['torpedoes'] == 3 and hasTorp))
			or ((filters['countermeasures'] == 2 and not hasCounter)
			or (filters['countermeasures'] == 3 and hasCounter))
			or ((filters['deathweapon'] == 2 and hasDeathWeap ~= 1)
			or (filters['deathweapon'] == 3 and hasDeathWeap ~= 2)
			or (filters['deathweapon'] == 4 and hasDeathWeap ~= 0)) then
				notFiltered[i] = false
				count = count - 1
				continue
			end
		end

		if (filters['amphib'] == 2 and not table.find(bp.Categories, 'AMPHIBIOUS'))
		or (filters['amphib'] == 3 and table.find(bp.Categories, 'AMPHIBIOUS'))
		then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		if (filters['transport'] == 2 and not (
			bp.Transport.Class1AttachSize
			or bp.Transport.Class2AttachSize
			or bp.Transport.Class3AttachSize))
		or (filters['transport'] == 3 and (
			bp.Transport.Class1AttachSize
			or bp.Transport.Class2AttachSize
			or bp.Transport.Class3AttachSize))
		then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		-- No shield is most common, so handle it first
		-- RATODO: This does not account for BrewLAN personal shields,
		-- which are implemented as bubbles but only big enough to be personal
		if (filters['shield'] == 4 and bp.Defense.Shield)
		or (filters['shield'] == 3 and (not bp.Defense.Shield or not bp.Defense.Shield.PersonalShield))
		or (filters['shield'] == 2 and (not bp.Defense.Shield or bp.Defense.Shield.PersonalShield))
		then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		if filters['intel'] == 1 then
			-- Do nothing
		elseif
		(filters['intel'] == 2 and
		(bp.Intel.RadarRadius or bp.Intel.SonarRadius or bp.Intel.OmniRadius)) or
		(filters['intel'] == 3 and not bp.Intel.RadarRadius) or
		(filters['intel'] == 4 and not bp.Intel.SonarRadius) or
		(filters['intel'] == 5 and not bp.Intel.OmniRadius) then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		if filters['stealth'] == 1 then
			-- Do nothing
		elseif
		(filters['stealth'] == 2 and
		(bp.Intel.RadarStealth or bp.Intel.SonarStealth)) or
		(filters['stealth'] == 3 and not bp.Intel.RadarStealth) or
		(filters['stealth'] == 4 and not bp.Intel.SonarStealth) or
		(filters['stealth'] == 5 and not bp.Intel.Cloak) then
			notFiltered[i] = false
			count = count - 1
			continue
		end

		-- If unit has passed all filters, it is now the last
		-- (and might be the first) to have done so
		if first < 0 then first = i end
		last = i
	end

	local r
	if count ~= 1 then r = "results"
	else r = "result" end
	resultText:SetText(tostring(count).." "..r.." found.")
end

function ClearFilters()
	filters['name'] = ''
	filters['faction'] = 1
	filters['tech'] = 1
	filters['type'] = 1
	filters['mod'] = 1

	filters['directfire'] = 1
	filters['indirectfire'] = 1
	filters['antiair'] = 1
	filters['torpedoes'] = 1
	filters['countermeasures'] = 1
	filters['deathweapon'] = 1

	filters['amphib'] = 1
	filters['transport'] = 1
	filters['shield'] = 1
	filters['intel'] = 1
	filters['stealth'] = 1
end