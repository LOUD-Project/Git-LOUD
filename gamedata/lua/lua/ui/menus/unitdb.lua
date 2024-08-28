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
local Text = import('/lua/maui/text.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local UVD = import('/lua/ui/game/unitviewDetail.lua')

-- Constants

local mainDirs = {
	'/units',
	'/mods/4DC/units',
	'/mods/BlackOpsUnleashed/units',
	'/mods/BlackopsACUs/units',
	'/mods/BrewLAN_LOUD/units',
	'/mods/LOUD Unit Additions/units',
	'/mods/TotalMayhem/units',
	'/mods/BattlePack/units',
}

local originMap = {
	'', -- Dummy value to account for Any in the filter combo
	'Forged Alliance',
	'4th Dimension Units',
	'BlackOps Unleashed',
	'BlackOps ACUs',
	'BrewLAN LOUD',
	'LOUD Unit Additions',
	'Total Mayhem',
	'Wyvern Battle Pack',
}

local unitDispAbilHeight = 120

local factionBmps = {} -- Order: All, UEF, Aeon, Cybran, Sera
local factionTooltips = {}

table.insert(factionBmps, "/faction_icon-sm/random_ico.dds")
-- RATODO: Tooltip for all faction filter option

for i, tbl in FactionData.Factions do
	factionBmps[i + 1] = tbl.SmallIcon
	factionTooltips[i + 1] = tbl.TooltipID
end

-- Backing structures

allBlueprints = {} -- Map unit IDs to BPs
temp = false

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

function ParseMerges(dir)
	for _, file in DiskFindFiles(dir, '*_unit.bp') do
		safecall("UNIT DB: Loading BP "..file, doscript, file)
		local id = temp.BlueprintId
		if allBlueprints[id] then
			Merge(allBlueprints[id], temp)
		else
			WARN("UNIT DB: No merge possible at ID "..id)
		end
	end
end

function Merge(orig, new)
	for nk, nv in new do
		if type(orig[nk]) == 'table' then
			Merge(orig[nk], nv)
		else
			orig[nk] = nv
		end
	end
end

function CreateUnitDB(over, callback)
-- Parse BPs
	-- Must plug UnitBlueprint() into engine before running doscript on .bps
	doscript '/lua/ui/menus/unitdb_bps.lua'

	local bpc = 1
	for _, dir in mainDirs do
		for _, file in DiskFindFiles(dir, '*_unit.bp') do
			-- RATODO: Certain BrewLAN IDs end with _large or _small
			local mod = 'vanilla'
			local x, z = string.find(file, '^/mods/[%s_%w]+/')
			if x and z then
				mod = string.sub(file, x, z)
				mod = string.sub(mod, 7, string.len(mod) - 1)
			end
			local id = string.sub(file, string.find(file, '[%a%d_]+_unit%.bp$'))
			id = string.sub(id, 1, string.len(id) - 8)
			safecall("UNIT DB: Loading BP "..file, doscript, file)
			if not temp then
				continue
			end
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
			elseif mod == 'blackopsacus' then
				origin[bpc] = 5
			elseif mod == 'brewlan_loud' then
				origin[bpc] = 6
			elseif mod == 'loud unit additions' then
				origin[bpc] = 7
			elseif mod == 'totalmayhem' then
				origin[bpc] = 8
			elseif mod == 'battlepack' then
				origin[bpc] = 9
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
	local title = UIUtil.CreateText(panel, "Unit Database", 24)
	LayoutHelpers.AtTopIn(title, panel, 24)
	LayoutHelpers.AtHorizontalCenterIn(title, panel)
	panel.Depth:Set(GetFrame(over:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)

	ClearFilters()

-- Unit display

	unitDisplay = Group(panel)
	LayoutHelpers.SetDimensions(unitDisplay, 280, 576)
	LayoutHelpers.AtLeftTopIn(unitDisplay, panel, 20, 60)
	unitDisplay.bg = Bitmap(unitDisplay)
	unitDisplay.bg.Depth:Set(unitDisplay.Depth)
	LayoutHelpers.FillParent(unitDisplay.bg, unitDisplay)
	unitDisplay.bg:SetSolidColor('505358')

	local promptStr = 'Click a unit on the right.'
	unitDisplay.prompt = UIUtil.CreateText(unitDisplay, promptStr, 14, UIUtil.bodyFont)
	LayoutHelpers.AtCenterIn(unitDisplay.prompt, unitDisplay)

	unitDisplay.backIcon = Bitmap(unitDisplay)
	LayoutHelpers.AtLeftTopIn(unitDisplay.backIcon, unitDisplay)
	unitDisplay.icon = Bitmap(unitDisplay)
	LayoutHelpers.AtCenterIn(unitDisplay.icon, unitDisplay.backIcon)
	unitDisplay.stratIcon = Bitmap(unitDisplay.icon)
	LayoutHelpers.AtRightTopIn(unitDisplay.stratIcon, unitDisplay.icon)

	unitDisplay.name = UIUtil.CreateText(unitDisplay, '', 18, "Arial Bold")
	unitDisplay.name:DisableHitTest()
	LayoutHelpers.RightOf(unitDisplay.name, unitDisplay.backIcon, 4)

	unitDisplay.shortDesc1 = UIUtil.CreateText(unitDisplay, '', 18, UIUtil.bodyFont)
	unitDisplay.shortDesc1:DisableHitTest()
	LayoutHelpers.Below(unitDisplay.shortDesc1, unitDisplay.name)
	unitDisplay.shortDesc2 = UIUtil.CreateText(unitDisplay, '', 18, UIUtil.bodyFont)
	unitDisplay.shortDesc2:DisableHitTest()
	LayoutHelpers.Below(unitDisplay.shortDesc2, unitDisplay.shortDesc1)

	unitDisplay.factionIcon = Bitmap(unitDisplay.icon)
	unitDisplay.factionIcon:SetSolidColor(UIUtil.panelColor)
	LayoutHelpers.Below(unitDisplay.factionIcon, unitDisplay.backIcon, 4)

	-- Origin mod and ID
	unitDisplay.technicals = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.technicals, unitDisplay.factionIcon, 4)

	unitDisplay.longDesc = UIUtil.CreateTextBox(unitDisplay)
	LayoutHelpers.Below(unitDisplay.longDesc, unitDisplay.factionIcon, 4)
	unitDisplay.longDesc.Width:Set(unitDisplay.Width)
	LayoutHelpers.SetHeight(unitDisplay.longDesc, 120)
	unitDisplay.longDesc.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end

	unitDisplay.abilities = ItemList(unitDisplay)
	LayoutHelpers.Below(unitDisplay.abilities, unitDisplay.longDesc, 6)
	unitDisplay.abilities.Width:Set(unitDisplay.Width)
	unitDisplay.abilities.Height:Set(0)
	unitDisplay.abilities.OnClick = function(self, row, event)
		-- Prevent highlighting lines on click
	end
	unitDisplay.abilities:SetFont(UIUtil.bodyFont, 12)
	UIUtil.CreateVertScrollbarFor(unitDisplay.abilities)

	unitDisplay.healthIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-health_bmp.dds'))
	LayoutHelpers.Below(unitDisplay.healthIcon, unitDisplay.abilities, 6)
	unitDisplay.health = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.health, unitDisplay.healthIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.healthIcon, 'unitdb_health')
	Tooltip.AddControlTooltip(unitDisplay.health, 'unitdb_health')

	unitDisplay.shieldIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/unit_view_icons/shield.dds'))
	LayoutHelpers.RightOf(unitDisplay.shieldIcon, unitDisplay.health, 6)
	unitDisplay.shield = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.shield, unitDisplay.shieldIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.shieldIcon, 'unitdb_shield')
	Tooltip.AddControlTooltip(unitDisplay.shield, 'unitdb_shield')

	unitDisplay.capIcon = Bitmap(unitDisplay, UIUtil.UIFile('/dialogs/score-overlay/tank_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.capIcon, unitDisplay.shield, 6)
	unitDisplay.cap = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.cap, unitDisplay.capIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.capIcon, 'unitdb_capcost')
	Tooltip.AddControlTooltip(unitDisplay.cap, 'unitdb_capcost')

	unitDisplay.massCostIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-mass_bmp.dds'))
	LayoutHelpers.Below(unitDisplay.massCostIcon, unitDisplay.healthIcon, 6)
	unitDisplay.mass = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.mass, unitDisplay.massCostIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.massCostIcon, 'unitdb_mass')
	Tooltip.AddControlTooltip(unitDisplay.mass, 'unitdb_mass')
	unitDisplay.energyCostIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-energy_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.energyCostIcon, unitDisplay.mass, 6)
	unitDisplay.energy = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.energy, unitDisplay.energyCostIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.energyCostIcon, 'unitdb_energy')
	Tooltip.AddControlTooltip(unitDisplay.energy, 'unitdb_energy')
	unitDisplay.buildTimeIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-clock_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.buildTimeIcon, unitDisplay.energy, 6)
	unitDisplay.buildTime = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.buildTime, unitDisplay.buildTimeIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.buildTimeIcon, 'unitdb_buildtime')
	Tooltip.AddControlTooltip(unitDisplay.buildTime, 'unitdb_buildtime')

	unitDisplay.fuelIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/unit_view_icons/fuel.dds'))
	LayoutHelpers.Below(unitDisplay.fuelIcon, unitDisplay.massCostIcon, 6)
	unitDisplay.fuelTime = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.fuelTime, unitDisplay.fuelIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.fuelIcon, 'unitdb_fuel')
	Tooltip.AddControlTooltip(unitDisplay.fuelTime, 'unitdb_fuel')

	unitDisplay.buildPowerIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/unit_view_icons/build.dds'))
	LayoutHelpers.RightOf(unitDisplay.buildPowerIcon, unitDisplay.fuelIcon, 6)
	unitDisplay.buildPower = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.buildPower, unitDisplay.buildPowerIcon, 6)
	Tooltip.AddControlTooltip(unitDisplay.buildPowerIcon, 'unitdb_buildpower')
	Tooltip.AddControlTooltip(unitDisplay.buildPower, 'unitdb_buildpower')

	unitDisplay.storageLabel = UIUtil.CreateText(unitDisplay, "Storage:", 14, UIUtil.bodyFont)
	LayoutHelpers.Below(unitDisplay.storageLabel, unitDisplay.fuelIcon, 6)

	unitDisplay.massStorageIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-mass_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.massStorageIcon, unitDisplay.storageLabel, 6)
	unitDisplay.massStorage = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.massStorage, unitDisplay.massStorageIcon, 6)

	unitDisplay.energyStorageIcon = Bitmap(unitDisplay, UIUtil.UIFile('/game/build-ui/icon-energy_bmp.dds'))
	LayoutHelpers.RightOf(unitDisplay.energyStorageIcon, unitDisplay.massStorage, 6)
	unitDisplay.energyStorage = UIUtil.CreateText(unitDisplay, '', 14, UIUtil.bodyFont)
	LayoutHelpers.RightOf(unitDisplay.energyStorage, unitDisplay.energyStorageIcon, 6)

	unitDisplay.weaponsLabel = UIUtil.CreateText(unitDisplay, 'Weapons', 18, UIUtil.buttonFont)
	LayoutHelpers.Below(unitDisplay.weaponsLabel, unitDisplay.storageLabel, 6)
	LayoutHelpers.AtHorizontalCenterIn(unitDisplay.weaponsLabel, unitDisplay)

	unitDisplay.weapons = ItemList(unitDisplay)
	LayoutHelpers.Below(unitDisplay.weapons, unitDisplay.weaponsLabel, 2)
	LayoutHelpers.AtHorizontalCenterIn(unitDisplay.weapons, unitDisplay)
	unitDisplay.weapons.Width:Set(unitDisplay.Width)
	unitDisplay.weapons.Height:Set(0)
	unitDisplay.weapons:SetFont(UIUtil.bodyFont, 12)
	UIUtil.CreateVertScrollbarFor(unitDisplay.weapons)

	ClearUnitDisplay()

-- List of filtered units

	listContainer = Group(panel)
	LayoutHelpers.SetDimensions(listContainer, 328, 576)
	listContainer.top = 0
	LayoutHelpers.RightOf(listContainer, unitDisplay, 40)

	local unitList = {}

	local function CreateElement(i)
		unitList[i] = Group(listContainer)
		LayoutHelpers.SetHeight(unitList[i], 64)
		unitList[i].Width:Set(listContainer.Width)
		unitList[i].bg = Bitmap(unitList[i])
		unitList[i].bg.Depth:Set(unitList[i].Depth)
		LayoutHelpers.FillParent(unitList[i].bg, unitList[i])
		if math.mod(i, 2) == 0 then
			 -- Same colour as rows in lobby background
			unitList[i].bg:SetSolidColor('3B4649')
		else
			unitList[i].bg:SetSolidColor('445258')
		end
		LayoutHelpers.AtRightIn(unitList[i].bg, unitList[i], 10)
		unitList[i].backIcon = Bitmap(unitList[i])
		LayoutHelpers.AtLeftTopIn(unitList[i].backIcon, unitList[i], 4, 1)
		unitList[i].icon = Bitmap(unitList[i])
		LayoutHelpers.AtCenterIn(unitList[i].icon, unitList[i].backIcon)
		unitList[i].name = UIUtil.CreateText(listContainer, '', 14, UIUtil.bodyFont)
		LayoutHelpers.AtLeftTopIn(unitList[i].name, unitList[i], 72, 4)
		unitList[i].desc = UIUtil.CreateText(listContainer, '', 14, UIUtil.bodyFont)
		LayoutHelpers.Below(unitList[i].desc, unitList[i].name, 2)
		unitList[i].id = UIUtil.CreateText(listContainer, '', 14, UIUtil.bodyFont)
		LayoutHelpers.Below(unitList[i].id, unitList[i].desc, 2)
		unitList[i].icon:DisableHitTest()
		unitList[i].name:DisableHitTest()
		unitList[i].desc:DisableHitTest()
		unitList[i].id:DisableHitTest()

		unitList[i].HandleEvent = function(self, event)
			if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
				if self.unitIndex then
					DisplayUnit(self.unitIndex)
					local sound = Sound({Cue = "UI_Mod_Select", Bank = "Interface",})
					PlaySound(sound)
				end
			end
		end
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
		return count > 9
	end

	listContainer.CalcVisible = function(self)
		local function ClearRemaining(cur)
			for l = cur, table.getsize(unitList) do
				unitList[l].name:SetText('')
				unitList[l].desc:SetText('')
				unitList[l].id:SetText('')
				unitList[l].backIcon:Hide()
				unitList[l].icon:Hide()
				unitList[l].unitIndex = nil
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
			FillLine(v, j)
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

	local listScrollbar = UIUtil.CreateVertScrollbarFor(listContainer, -16)
	listScrollbar.Depth:Set(listScrollbar.Depth() + 20)

-- Settings

	local settingsContainer = Group(panel)
	LayoutHelpers.SetDimensions(settingsContainer, 262, 120)
	LayoutHelpers.RightOf(settingsContainer, listContainer, 28)

	local settingsContainerTitle = UIUtil.CreateText(settingsContainer, 'Settings', 24, UIUtil.titleFont)
	LayoutHelpers.AtTopIn(settingsContainerTitle, settingsContainer)
	LayoutHelpers.AtHorizontalCenterIn(settingsContainerTitle, settingsContainer)

	local settingGroupEvenflow = Group(settingsContainer)
	LayoutHelpers.SetHeight(settingGroupEvenflow, 20)
	settingGroupEvenflow.Width:Set(settingsContainer.Width)
	LayoutHelpers.AtLeftTopIn(settingGroupEvenflow, settingsContainer, 0, 32)
	local settingEvenflowLabel = UIUtil.CreateText(settingGroupEvenflow, 'LOUD EvenFlow', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(settingEvenflowLabel, settingGroupEvenflow)
	LayoutHelpers.AtVerticalCenterIn(settingEvenflowLabel, settingGroupEvenflow)

	local evenflowCheckbox = UIUtil.CreateCheckboxStd(settingGroupEvenflow, '/dialogs/check-box_btn/radio')
	LayoutHelpers.AtRightIn(evenflowCheckbox, settingGroupEvenflow)
	LayoutHelpers.AtVerticalCenterIn(evenflowCheckbox, settingGroupEvenflow)
	evenflowCheckbox.OnCheck = function(self, checked)
		ToggleSetting('evenflow', checked)
	end

	Tooltip.AddControlTooltip(settingGroupEvenflow, 'unitdb_evenflow')

	local settingGroupArtillery = Group(settingsContainer)
	LayoutHelpers.SetHeight(settingGroupArtillery, 20)
	settingGroupArtillery.Width:Set(settingsContainer.Width)
	LayoutHelpers.Below(settingGroupArtillery, settingGroupEvenflow, 4)
	local settingArtyLabel = UIUtil.CreateText(settingGroupArtillery, 'Enhanced T4 Artillery', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(settingArtyLabel, settingGroupArtillery)
	LayoutHelpers.AtVerticalCenterIn(settingArtyLabel, settingGroupArtillery)

	local artyCheckbox = UIUtil.CreateCheckboxStd(settingGroupArtillery, '/dialogs/check-box_btn/radio')
	LayoutHelpers.AtRightIn(artyCheckbox, settingGroupArtillery)
	LayoutHelpers.AtVerticalCenterIn(artyCheckbox, settingGroupArtillery)
	artyCheckbox.OnCheck = function(self, checked)
		ToggleSetting('artillery', checked)
	end

	Tooltip.AddControlTooltip(settingGroupArtillery, 'unitdb_artillery')

	local settingGroupCommanders = Group(settingsContainer)
	LayoutHelpers.SetHeight(settingGroupCommanders, 20)
	settingGroupCommanders.Width:Set(settingsContainer.Width)
	LayoutHelpers.Below(settingGroupCommanders, settingGroupArtillery, 4)
	local settingComLabel = UIUtil.CreateText(settingGroupCommanders, 'Enhanced Commanders', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(settingComLabel, settingGroupCommanders)
	LayoutHelpers.AtVerticalCenterIn(settingComLabel, settingGroupCommanders)

	local comCheckbox = UIUtil.CreateCheckboxStd(settingGroupCommanders, '/dialogs/check-box_btn/radio')
	LayoutHelpers.AtRightIn(comCheckbox, settingGroupCommanders)
	LayoutHelpers.AtVerticalCenterIn(comCheckbox, settingGroupCommanders)
	comCheckbox.OnCheck = function(self, checked)
		ToggleSetting('commanders', checked)
	end

	Tooltip.AddControlTooltip(settingGroupCommanders, 'unitdb_commanders')

	local settingGroupNukes = Group(settingsContainer)
	LayoutHelpers.SetHeight(settingGroupNukes, 20)
	settingGroupNukes.Width:Set(settingsContainer.Width)
	LayoutHelpers.Below(settingGroupNukes, settingGroupCommanders, 4)
	local settingNukesLabel = UIUtil.CreateText(settingGroupNukes, 'Realistic Nukes', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(settingNukesLabel, settingGroupNukes)
	LayoutHelpers.AtVerticalCenterIn(settingNukesLabel, settingGroupNukes)

	local nukesCheckbox = UIUtil.CreateCheckboxStd(settingGroupNukes, '/dialogs/check-box_btn/radio')
	LayoutHelpers.AtRightIn(nukesCheckbox, settingGroupNukes)
	LayoutHelpers.AtVerticalCenterIn(nukesCheckbox, settingGroupNukes)
	nukesCheckbox.OnCheck = function(self, checked)
		ToggleSetting('nukes', checked)
	end

	Tooltip.AddControlTooltip(settingGroupNukes, 'unitdb_nukes')

-- FILTERS: Basics

	local filterContainer = Group(panel)
	LayoutHelpers.SetDimensions(filterContainer, 262, 384)
	LayoutHelpers.Below(filterContainer, settingsContainer, 4)

	local filterContainerTitle = UIUtil.CreateText(filterContainer, 'Filters', 24, UIUtil.titleFont)
	LayoutHelpers.AtTopIn(filterContainerTitle, filterContainer)
	LayoutHelpers.AtHorizontalCenterIn(filterContainerTitle, filterContainer)

	-- Used for everything except name and faction; returns a Group
	local function MakeFilterCombo(labelText, width, filterKey, items, elementAbove)
		local filterGroup = Group(filterContainer)
		LayoutHelpers.SetHeight(filterGroup, 20)
		filterGroup.Width:Set(filterContainer.Width)
		if elementAbove then
			LayoutHelpers.Below(filterGroup, elementAbove, 2)
		end
		filterGroup.label = UIUtil.CreateText(filterGroup, labelText, 14, UIUtil.bodyFont)
		filterGroup.label:DisableHitTest()
		LayoutHelpers.AtLeftIn(filterGroup.label, filterGroup)
		LayoutHelpers.AtVerticalCenterIn(filterGroup.label, filterGroup)
		filterGroup.combo = Combo(filterGroup, 14, 5, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
		filterGroup.combo:AddItems(items, 1)
		LayoutHelpers.AtRightIn(filterGroup.combo, filterGroup, 2)
		LayoutHelpers.AtVerticalCenterIn(filterGroup.combo, filterGroup)
		LayoutHelpers.SetWidth(filterGroup.combo, width)
		filterGroup.combo.OnClick = function(self, index)
			filters[filterKey] = index
			Tooltip.DestroyMouseoverDisplay()
		end
		return filterGroup
	end

	-- Name

	local filterGroupName = Group(filterContainer)
	LayoutHelpers.SetHeight(filterGroupName, 20)
	filterGroupName.Width:Set(filterContainer.Width)
	LayoutHelpers.AtLeftTopIn(filterGroupName, filterContainer, 0, 32)
	local filterNameLabel = UIUtil.CreateText(filterGroupName, 'Name', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterNameLabel, filterGroupName)
	LayoutHelpers.AtVerticalCenterIn(filterNameLabel, filterGroupName)

	local filterNameEdit = Edit(filterGroupName)
	LayoutHelpers.AtRightIn(filterNameEdit, filterGroupName, 4)
	LayoutHelpers.AtVerticalCenterIn(filterNameEdit, filterGroupName)
	LayoutHelpers.SetWidth(filterNameEdit, 160)
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
	LayoutHelpers.SetHeight(filterGroupFaction, 20)
	filterGroupFaction.Width:Set(filterContainer.Width)
	LayoutHelpers.Below(filterGroupFaction, filterGroupName, 2)
	local filterFactionLabel = UIUtil.CreateText(filterGroupFaction, 'Faction', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftIn(filterFactionLabel, filterGroupFaction)
	LayoutHelpers.AtVerticalCenterIn(filterFactionLabel, filterGroupFaction)

	local filterFactionCombo = BitmapCombo(filterGroupFaction, factionBmps, table.getn(factionBmps), nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	LayoutHelpers.AtRightIn(filterFactionCombo, filterGroupFaction, 2)
	LayoutHelpers.AtVerticalCenterIn(filterFactionCombo, filterGroupFaction)
	LayoutHelpers.SetWidth(filterFactionCombo, 60)
	filterFactionCombo.OnClick = function(self, index)
		-- 1 = All ; 2 = UEF ; 3 = Cybran ; 4 = Aeon ; 5 -> Sera
		filters['faction'] = index
		Tooltip.DestroyMouseoverDisplay()
	end

	Tooltip.AddComboTooltip(filterFactionCombo, factionTooltips)

	local filterGroups = {}

	local techFilterItems = { "All", "Tech 1", "Tech 2", "Tech 3", "Experimental"}
	filterGroups.tech = MakeFilterCombo("Tech Level", 120, 'tech', techFilterItems, filterGroupFaction)
	local typeFilterItems = { "All", "Land", "Air", "Naval", "Base", "Commander" }
	filterGroups.type = MakeFilterCombo("Type", 120, 'type', typeFilterItems, filterGroups.tech)
	local modFilterItems = { "All",
		"Vanilla",
		"4th Dimension Units",
		"BlackOps Unleashed",
		"BlackOps ACUs",
		"BrewLAN LOUD",
		"LOUD Unit Additions",
		"Total Mayhem",
		"Wyvern Battle Pack" }
	filterGroups.origin = MakeFilterCombo("Mod", 160, 'mod', modFilterItems, filterGroups.type)

-- FILTERS: Weaponry

	-- Horizontal row to divide fundamental traits from weapons block
	-- Also, a label

	local weaponsRow = Bitmap(filterContainer)
	LayoutHelpers.Below(weaponsRow, filterGroups.origin, 4)
	LayoutHelpers.SetHeight(weaponsRow, 2)
	weaponsRow.Width:Set(filterContainer.Width() - LayoutHelpers.ScaleNumber(8))
	weaponsRow:SetSolidColor('ADCFCE') -- Same colour as light lines in background

	local weaponsBlockLabel = UIUtil.CreateText(filterContainer, 'Weapons', 18, UIUtil.buttonFont)
	LayoutHelpers.Below(weaponsBlockLabel, weaponsRow, 4)
	LayoutHelpers.AtHorizontalCenterIn(weaponsBlockLabel, filterContainer)

	local anyYesNo = { "Any", "Yes", "No" }
	filterGroups.directFire = MakeFilterCombo("Direct Fire", 60, 'directfire', anyYesNo, nil)
	filterGroups.directFire.Left:Set(filterGroups.origin.Left)
	LayoutHelpers.AnchorToBottom(filterGroups.directFire, weaponsBlockLabel, 4)
	filterGroups.indirectFire = MakeFilterCombo("Indirect Fire", 60, 'indirectfire', anyYesNo, filterGroups.directFire)
	filterGroups.antiAir = MakeFilterCombo("Anti-Air", 60, 'antiair', anyYesNo, filterGroups.indirectFire)
	filterGroups.torps = MakeFilterCombo("Torpedoes", 60, 'torpedoes', anyYesNo, filterGroups.antiAir)
	local counterFilterItems = { "Any", "Torpedo", "Tactical Missile", "Strategic Missile", "None" }
	filterGroups.countermeasures = MakeFilterCombo("Countermeasures", 140, 'countermeasures', counterFilterItems, filterGroups.torps)
	local deathWeapFilterItems = { "Any", "Death Explosion", "Air Crash", "None" }
	filterGroups.deathWeap = MakeFilterCombo("Death Weapon", 140, 'deathweapon', deathWeapFilterItems, filterGroups.countermeasures)
	filterGroups.EMP = MakeFilterCombo("EMP/Stun Effects", 60, 'emp', anyYesNo, filterGroups.deathWeap)

-- FILTERS: Miscellaneous

	-- Another horizontal row

	local miscRow = Bitmap(filterContainer)
	LayoutHelpers.Below(miscRow, filterGroups.EMP, 4)
	LayoutHelpers.SetHeight(miscRow, 2)
	miscRow.Width:Set(filterContainer.Width() - LayoutHelpers.ScaleNumber(8))
	miscRow:SetSolidColor('ADCFCE') -- Same colour as light lines in background

	filterGroups.amphib = MakeFilterCombo("Amphibious", 60, 'amphib', anyYesNo, nil)
	LayoutHelpers.Below(filterGroups.amphib, miscRow, 4)
	filterGroups.transport = MakeFilterCombo("Transport", 60, 'transport', anyYesNo, filterGroups.amphib)
	local shieldFilterItems = { "Any", "Dome", "Personal", "None" }
	filterGroups.shield = MakeFilterCombo("Shielding", 100, 'shield', shieldFilterItems, filterGroups.transport)
	local intelFilterItems = { "Any", "None", "Radar", "Sonar", "Omni" }
	filterGroups.intel = MakeFilterCombo("Intel", 80, 'intel', intelFilterItems, filterGroups.shield)
	local stealthFilterItems = { "Any", "None", "Radar", "Sonar", "Cloak" }
	filterGroups.stealth = MakeFilterCombo("Stealth", 80, 'stealth', stealthFilterItems, filterGroups.intel)

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
		for _, v in filterGroups do
			v.combo:SetItem(1)
		end
		Filter()
		listContainer:CalcVisible()
	end
	Tooltip.AddControlTooltip(resetBtn, 'unitdb_reset')

	local exitBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Exit", 16, 2)
	LayoutHelpers.AtLeftTopIn(exitBtn, panel, 36, 644)
	exitBtn.OnClick = function(self, modifiers)
		for i = 1, table.getn(allBlueprints) do
			allBlueprints[i] = nil
			units[i] = nil
			origin[i] = nil
			notFiltered[i] = nil
		end
		for i = 1, table.getn(noIcon) do
			noIcon[i] = nil
		end
		count = 0
		first = -1
		last = -1
		ClearFilters()
		if over then
			panel:Destroy()
			panel = false
		else
			parent:Destroy()
			parent = false
		end
		callback()
	end

	local r = tostring(count).." results found."
	resultText = UIUtil.CreateText(panel, r, 16, UIUtil.bodyFont)
	LayoutHelpers.AnchorToRight(resultText, exitBtn, 40)
	LayoutHelpers.AtTopIn(resultText, panel, 670)

	panel.HandleEvent = function(self, event)
		if event.Type ~= 'KeyDown' then
			return
		end
		if event.KeyCode == 319 then
			if event.Modifiers.Shift then
				listContainer:ScrollPages(nil, 1)
			elseif event.Modifiers.Ctrl then
				listContainer:ScrollSetTop(nil, count)
			else
				listContainer:ScrollLines(nil, 1)
			end
		elseif event.KeyCode == 317 then
			if event.Modifiers.Shift then
				listContainer:ScrollPages(nil, -1)
			elseif event.Modifiers.Ctrl then
				listContainer:ScrollSetTop(nil, 0)
			else
				listContainer:ScrollLines(nil, -1)
			end
		elseif event.KeyCode == 49 then
			DisplayUnit(unitList[1].unitIndex)
		elseif event.KeyCode == 50 then
			DisplayUnit(unitList[2].unitIndex)
		elseif event.KeyCode == 51 then
			DisplayUnit(unitList[3].unitIndex)
		elseif event.KeyCode == 52 then
			DisplayUnit(unitList[4].unitIndex)
		elseif event.KeyCode == 53 then
			DisplayUnit(unitList[5].unitIndex)
		elseif event.KeyCode == 54 then
			DisplayUnit(unitList[6].unitIndex)
		elseif event.KeyCode == 55 then
			DisplayUnit(unitList[7].unitIndex)
		elseif event.KeyCode == 56 then
			DisplayUnit(unitList[8].unitIndex)
		elseif event.KeyCode == 57 then
			DisplayUnit(unitList[9].unitIndex)
		end
	end

	UIUtil.MakeInputModal(panel,
	function() searchBtn.OnClick(searchBtn) end, 
	function() exitBtn.OnClick(exitBtn) end)
end

function FillLine(line, index)
	local id = units[index]
	local bp = allBlueprints[id]
	line.unitIndex = index
	line:Show()
	local n = LOC(bp.General.UnitName) or LOC(bp.Description) or 'Unnamed Unit'
	line.name:SetText(n)
	local wrappedText = Text.FitText(LOC(bp.Description) or 'Unnamed Unit', LayoutHelpers.ScaleNumber(224),
		function(nt) return line.desc:GetStringAdvance(nt) end)
		if table.getn(wrappedText) > 1 then
			line.desc:SetText(wrappedText[1]..'...')
		else
			line.desc:SetText(wrappedText[1])
		end
	line.id:SetText(string.format('%s (%s)', originMap[origin[index]], id))
	local validIcons = {land = true, air = true, sea = true, amph = true}
	if validIcons[bp.General.Icon] then
        line.backIcon:SetTexture(UIUtil.UIFile('/icons/units/'..bp.General.Icon..'_up.dds'))
    else
        line.backIcon:SetTexture(UIUtil.UIFile('/icons/units/land_up.dds'))
    end
	local ico = '/textures/ui/common/icons/units/'..id..'_icon.dds'
	if noIcon[units[index]] then
		line.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
	else
		line.icon:SetTexture(ico)
	end
end

function DisplayUnit(index)
	if not index then
		return
	end

	unitDisplay.prompt:Hide()
	local id = units[index]
	local bp = allBlueprints[id]
	unitDisplay.name:SetText(LOC(bp.General.UnitName) or LOC(bp.Description) or 'Unnamed Unit')

	local sd = LOC(bp.Description) or "Unnamed Unit"
	if table.find(bp.Categories, 'TECH1') then
		sd = "Tech 1 "..sd
	elseif table.find(bp.Categories, 'TECH2') then
		sd = "Tech 2 "..sd
	elseif table.find(bp.Categories, 'TECH3') then
		sd = "Tech 3 "..sd
	end
	local sdt = Text.WrapText(sd, 240,
		function(nt) return unitDisplay.shortDesc1:GetStringAdvance(nt) end)
	unitDisplay.shortDesc1:SetText(sdt[1])
	if sdt[2] then
		unitDisplay.shortDesc2:SetText(sdt[2])
	end

	unitDisplay.icon:Show()
	unitDisplay.stratIcon:Show()
	unitDisplay.factionIcon:Show()
	unitDisplay.backIcon:Show()
	local validIcons = {land = true, air = true, sea = true, amph = true}
	if validIcons[bp.General.Icon] then
        unitDisplay.backIcon:SetTexture(UIUtil.UIFile('/icons/units/'..bp.General.Icon..'_up.dds'))
    else
        unitDisplay.backIcon:SetTexture(UIUtil.UIFile('/icons/units/land_up.dds'))
    end
	local ico = '/textures/ui/common/icons/units/'..id..'_icon.dds'
	if noIcon[id] then
		unitDisplay.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
	else
		unitDisplay.icon:SetTexture(ico)
	end
	unitDisplay.stratIcon:SetTexture(UIUtil.UIFile('/game/strategicicons/'..bp.StrategicIconName..'_rest.dds'))

	local factionKey = string.lower(bp.General.FactionName)
	if factionKey then
		local factionIndex = FactionData.FactionIndexMap[factionKey]
		if factionIndex then
			local factionIcon = FactionData.Factions[factionIndex].SmallIcon
			if factionIcon then
				unitDisplay.factionIcon:SetTexture(UIUtil.UIFile(factionIcon))
			end
		end
	end

	unitDisplay.technicals:SetText('Mod: '..originMap[origin[index]]..' ('..id..')')

	unitDisplay.longDesc:Show()
	local ld = LOC(Description[id]) or 'No description available for this unit.'
	UIUtil.SetTextBoxText(unitDisplay.longDesc, ld)
	if bp.Display.Abilities then
		unitDisplay.abilities:DeleteAllItems()
		LayoutHelpers.SetHeight(unitDisplay.abilities, unitDispAbilHeight)
		unitDisplay.abilities:Show()
		for _, a in bp.Display.Abilities do
			unitDisplay.abilities:AddItem(LOC(a))
		end
	else
		unitDisplay.abilities.Height:Set(0)
		unitDisplay.abilities:Hide()
	end

	local strHealth = tostring(bp.Defense.MaxHealth)
	local bpRR = bp.Defense.RegenRate
	if bpRR and bpRR > 0 then
		strHealth = strHealth..string.format(" (+%02.f/s)", bpRR)
	end
	unitDisplay.healthIcon:Show()
	unitDisplay.health:SetText(strHealth)
	if bp.Defense.Shield then
		unitDisplay.shieldIcon:Show()
		unitDisplay.shield:SetText(tostring(bp.Defense.Shield.ShieldMaxHealth))
	else
		unitDisplay.shieldIcon:Hide()
		unitDisplay.shield:SetText('')
	end

	unitDisplay.capIcon:Show()
	if bp.General.CapCost then
		local str = string.format("%.1f", bp.General.CapCost)
		str = str:gsub("%.?0+$", "")
		unitDisplay.cap:SetText(str)
	else
		unitDisplay.cap:SetText('1')
	end

	unitDisplay.massCostIcon:Show()
	unitDisplay.mass:SetText(tostring(bp.Economy.BuildCostMass))
	unitDisplay.energyCostIcon:Show()
	unitDisplay.energy:SetText(tostring(bp.Economy.BuildCostEnergy))
	unitDisplay.buildTimeIcon:Show()
	local bpBTMins = math.floor((bp.Economy.BuildTime / 10) / 60)
	local bpBTSecs = math.floor(bp.Economy.BuildTime / 10) - (bpBTMins * 60)
	unitDisplay.buildTime:SetText(string.format("%02.f:%02.fs", bpBTMins, bpBTSecs))

	local bpFuel = bp.Physics.FuelUseTime
	if bpFuel then
		unitDisplay.fuelIcon:Show()
		local bpFTMins = string.format("%02.f", math.floor(bpFuel / 60)):gsub("%.?0+$", "")
		local bpFTSecs = string.format("%02.f", math.mod(bpFuel, 60))
		unitDisplay.fuelTime:SetText(bpFTMins..":"..bpFTSecs.."s")
	else
		unitDisplay.fuelIcon:Hide()
		unitDisplay.fuelTime:SetText('')
	end

	if bp.Economy.BuildRate then
		unitDisplay.buildPowerIcon:Show()
		unitDisplay.buildPower:SetText(tostring(bp.Economy.BuildRate))
	else
		unitDisplay.buildPowerIcon:Hide()
		unitDisplay.buildPower:SetText('')
	end

	unitDisplay.storageLabel:Hide()

	if bp.Economy.StorageMass then
		unitDisplay.storageLabel:Show()
		unitDisplay.massStorageIcon:Show()
		unitDisplay.massStorage:SetText(tostring(bp.Economy.StorageMass))
	else
		unitDisplay.massStorageIcon:Hide()
		unitDisplay.massStorage:SetText('')
	end

	if bp.Economy.StorageEnergy then
		unitDisplay.storageLabel:Show()
		unitDisplay.energyStorageIcon:Show()
		unitDisplay.energyStorage:SetText(tostring(bp.Economy.StorageEnergy))
	else
		unitDisplay.energyStorageIcon:Hide()
		unitDisplay.energyStorage:SetText('')
	end

	if bp.Weapon then
		unitDisplay.weaponsLabel:Show()
		unitDisplay.weapons:Show()
		unitDisplay.weapons:DeleteAllItems()
		LayoutHelpers.SetHeight(unitDisplay.weapons, 120)

		local textLines = {}
		-- Import PhoenixMT's DPS Calculator script.
		doscript '/lua/PhxLib.lua'

		-- Used for comparing last weapon checked.
		local lastWeaponDmg = 0
		local lastWeaponDPS = 0
		local lastWeaponPPOF = 0
		local lastWeaponDoT = 0
		local lastWeaponDmgRad = 0
		local lastWeaponMinRad = 0
		local lastWeaponMaxRad = 0
		local lastWeaponROF = 0
		local lastWeaponFF = false
		local lastWeaponCF = false
		local lastWeaponTarget = ''
		local lastWeaponNukeInDmg = 0
		local lastWeaponNukeInRad = 0
		local lastWeaponNukeOutDmg = 0
		local lastWeaponNukeOutRad = 0
		local weaponText = ""

		-- BuffType.
		local bType = ""
		-- Weapon Category is checked to color lines, as well as checked for countermeasure weapons and differentiating the info displayed.
		local wepCategory = ""

		local dupWeaponCount = 1

		for _, weapon in bp.Weapon do
			-- Check for DummyWeapon Label (Used by Paragons for Range Rings).
			if string.find(weapon.Label, 'Dummy')
			or string.find(weapon.Label, 'Tractor')
			or string.find(weapon.Label, 'Painter') then
				continue
			end

			-- Check for RangeCategories.
			if weapon.RangeCategory ~= nil then
				if weapon.RangeCategory == 'UWRC_DirectFire' then
					wepCategory = "Direct"
				end
				if weapon.RangeCategory == 'UWRC_IndirectFire' then
					wepCategory = "Indirect"
				end
				if weapon.RangeCategory == 'UWRC_AntiAir' then
					wepCategory = "Anti Air"
				end
				if weapon.RangeCategory == 'UWRC_AntiNavy' then
					wepCategory = "Anti Navy"
				end
				if weapon.RangeCategory == 'UWRC_Countermeasure' then
					wepCategory = " Defense"
				end
			end

			-- Check for Death weapon labels
			if string.find(weapon.Label, 'Death') then
				wepCategory = "Volatile"
			end
			if weapon.Label == 'DeathImpact' then
				wepCategory = "Crash"
			end
			if weapon.Label == 'Suicide' then
				wepCategory = "Suicide"
			end

			-- These weapons have no RangeCategory, but do have Labels.
			if weapon.Label == 'Bomb' then
				wepCategory = "Indirect"
			end
			if weapon.Label == 'Torpedo' then
				wepCategory = "Anti Navy"
			end
			if weapon.Label == 'QuantumBeamGeneratorWeapon' then
				wepCategory = "Direct"
			end
			if weapon.Label == 'ChinGun' then
				wepCategory = "Direct"
			end
			if string.find(weapon.Label, 'Melee') then
				wepCategory = "Melee"
			end

			-- Check if we're a Nuke weapon by checking our InnerRingDamage, which all Nukes must have.
			if weapon.NukeInnerRingDamage > 0 then
				wepCategory = "Nuke"
			end

			-- Now categories are established, we check which category we ended up using.

			-- Check if it's a death weapon.
			if wepCategory == "Crash" or wepCategory == "Volatile" or wepCategory == "Suicide" then

				-- Start the weaponText string with the weapon category.
				weaponText = '> '..wepCategory

				-- Check DamageFriendly and concat.
				if weapon.CollideFriendly ~= false or weapon.DamageRadius > 0 then
					weaponText = (weaponText .. " (FF)")
				end

				-- Concat damage.
				weaponText = (weaponText .. " { Dmg: " .. UVD.LOUD_ThouCheck(weapon.Damage))

				-- Check DamageRadius and concat.
				if weapon.DamageRadius > 0 then
					weaponText = (weaponText .. ", AoE: " .. UVD.LOUD_KiloCheck(weapon.DamageRadius * 20))
				end

				-- Finish text line.
				weaponText = (weaponText .. " }")

				-- Insert death weapon text line.
				table.insert(textLines, weaponText)

			-- Check if it's a nuke weapon.
			elseif wepCategory == "Nuke" then

				-- Check if this nuke is a Death nuke.
				if string.find(weapon.Label, "Death") then
					wepCategory = "Volatile"
				end
				weaponText = '> '..wepCategory

				-- Check DamageFriendly and Buffs
				if weapon.CollideFriendly ~= false or (weapon.NukeInnerRingRadius > 0 and weapon.DamageFriendly ~= false) or weapon.Buffs ~= nil then
					weaponText = (weaponText .. " (")
					if weapon.Buffs then
						for i, buff in weapon.Buffs do
							bType = buff.BuffType
							if i == 1 then
								weaponText = (weaponText .. bType)
							else
								weaponText = (weaponText .. ", " .. bType)
							end
						end
					end
					if weapon.CollideFriendly ~= false or (weapon.NukeInnerRingRadius > 0 and weapon.DamageFriendly ~= false) then
						if weapon.Buffs then
							weaponText = (weaponText .. ", FF")
						else
							weaponText = (weaponText .. "FF")
						end
					end
					weaponText = (weaponText .. ")")
				end

				weaponText = (weaponText .. " { Inner Dmg: " .. UVD.LOUD_ThouCheck(weapon.NukeInnerRingDamage) .. ", AoE: " .. UVD.LOUD_KiloCheck(weapon.NukeInnerRingRadius * 20) .. " | Outer Dmg: " .. UVD.LOUD_ThouCheck(weapon.NukeOuterRingDamage) .. ", AoE: " .. UVD.LOUD_KiloCheck(weapon.NukeOuterRingRadius * 20))

				if weapon.MaxProjectileStorage then
					weaponText = weaponText .. ", Max Ammo: " .. weapon.MaxProjectileStorage
				end

				-- Finish text lines.
				weaponText = (weaponText .. " }")

				if weapon.NukeInnerRingDamage == lastWeaponNukeInDmg and weapon.NukeInnerRingRadius == lastWeaponNukeInRad  and weapon.NukeOuterRingDamage == lastWeaponNukeOutDmg and weapon.NukeOuterRingRadius == lastWeaponNukeOutRad and weapon.DamageFriendly == lastWeaponFF then
					dupWeaponCount = dupWeaponCount + 1
					-- Remove the old lines, to insert the new ones with the updated weapon count.
					table.remove(textLines, table.getn(textLines))
					table.insert(textLines, string.format("%s (x%d)", weaponText, dupWeaponCount))
				else
					dupWeaponCount = 1
					-- Insert the textLine.
					table.insert(textLines, weaponText)
				end
			else
				-- Start the weaponText string if we do damage.
				if weapon.Damage > 0.01 then

					-- Start weaponText string with label and category.
					weaponText = weapon.DisplayName or weapon.Label or 'Unnamed Weapon'
					weaponText = '> '..weaponText..' - '..wepCategory

					-- Check DamageFriendly and Buffs
					if wepCategory ~= " Defense" and wepCategory ~= "Melee" then
						if weapon.CollideFriendly ~= false or (weapon.DamageRadius > 0 and weapon.DamageFriendly ~= false) or weapon.Buffs ~= nil then
							weaponText = (weaponText .. " (")
							if weapon.Buffs then
								for i, buff in weapon.Buffs do
									bType = buff.BuffType
									if i == 1 then
										weaponText = (weaponText .. bType)
									else
										weaponText = (weaponText .. ", " .. bType)
									end
								end
							end
							if weapon.CollideFriendly ~= false or (weapon.DamageRadius > 0 and weapon.DamageFriendly ~= false) then
								if weapon.Buffs then
									weaponText = (weaponText .. ", FF")
								else
									weaponText = (weaponText .. "FF")
								end
							end
							weaponText = (weaponText .. ")")
						end

						-- Concat Damage. We don't check it here because we already checked it exists to get this far.
						weaponText = (weaponText .. " { Dmg: " .. UVD.LOUD_ThouCheck(weapon.Damage))

						-- Check PPF and concat.
						if weapon.ProjectilesPerOnFire > 1 then
							weaponText = (weaponText .. " (" .. tostring(weapon.ProjectilesPerOnFire) .. " Shots)")
						end

						-- Check DoTPulses and concat.
						if weapon.DoTPulses > 0 then
							weaponText = (weaponText .. " (" .. tostring(weapon.DoTPulses) .. " Hits)")
						end

						-- Concat DPS, calculated from PhxLib.
						weaponText = (weaponText .. ", DPS: " .. UVD.LOUD_ThouCheck(math.floor(PhxLib.PhxWeapDPS(weapon).DPS + 0.5)))

						-- Check DamageRadius and concat.
						if weapon.DamageRadius > 0 then
							weaponText = (weaponText .. ", AoE: " .. UVD.LOUD_KiloCheck(weapon.DamageRadius * 20))
						end
					else
						if wepCategory == " Defense" then
							-- Display Countermeasure Targets as the weapon type.
							if weapon.TargetRestrictOnlyAllow then
								local utils = import('/lua/utilities.lua')
								weaponText = (utils.LOUD_TitleCase(weapon.TargetRestrictOnlyAllow) .. wepCategory)
							end

							-- If a weapon is a Countermeasure, we don't care about its damage or DPS, as it's all very small numbers purely for shooting projectiles.
							weaponText = (weaponText .. " {")

							-- Show RoF for Countermeasure weapons.
							if PhxLib.PhxWeapDPS(weapon).RateOfFire > 0 then
								weaponText = (weaponText .. " RoF: " .. string.format("%.2f", PhxLib.PhxWeapDPS(weapon).RateOfFire) .. "/s"):gsub("%.?0+$", "")
							end
						end
						-- Special case for Melee weapons, only showing Damage.
						if wepCategory == "Melee" then
							weaponText = (weaponText .. " { Dmg: " .. UVD.LOUD_ThouCheck(weapon.Damage))
						end
					end

					-- Check RateOfFire and concat.
					--[[(NOTE: Commented out for now. DPS can infer ROF well enough
					and we have limited real-estate in the rollover box
					until someone figures out how to extend its width limit.)
					if PhxLib.PhxWeapDPS(weapon).RateOfFire > 0 then
						weaponText = (weaponText .. ", RoF: " .. LOUDFORMAT("%.2f", weapon.RateOfFire) .. "/s"):gsub("%.?0+$", "")
					end
					--]]

					-- Check Min/Max Radius and concat.
					if weapon.MaxRadius > 0 then
						if weapon.MinRadius > 0 then
							weaponText = (weaponText .. ", Rng: " .. UVD.LOUD_KiloCheck(weapon.MinRadius * 20) .. "-" .. UVD.LOUD_KiloCheck(weapon.MaxRadius * 20))
						else
							weaponText = (weaponText .. ", Rng: " .. UVD.LOUD_KiloCheck(weapon.MaxRadius * 20))
						end
					end

					if weapon.MaxProjectileStorage then
						weaponText = weaponText .. ", Max Ammo: " .. weapon.MaxProjectileStorage
					end

					-- Finish text line.
					weaponText = (weaponText .. " }")

					-- Check duplicate weapons. We compare lots of values here,
					-- any slight difference should be considered a different weapon.
					if weapon.Damage == lastWeaponDmg and math.floor(PhxLib.PhxWeapDPS(weapon).DPS + 0.5) == lastWeaponDPS
					and weapon.ProjectilesPerOnFire == lastWeaponPPOF and weapon.DoTPulses == lastWeaponDoT
					and weapon.DamageRadius == lastWeaponDmgRad and weapon.MinRadius == lastWeaponMinRad
					and weapon.MaxRadius == lastWeaponMaxRad and weapon.DamageFriendly == lastWeaponFF
					and PhxLib.PhxWeapDPS(weapon).RateOfFire == lastWeaponROF and weapon.CollideFriendly == lastWeaponCF
					and weapon.TargetRestrictOnlyAllow == lastWeaponTarget then
						dupWeaponCount = dupWeaponCount + 1
						-- Remove the old line, to insert the new one with the updated weapon count.
						table.remove(textLines, table.getn(textLines))
						table.insert(textLines, string.format("%s (x%d)", weaponText, dupWeaponCount))
					else
						dupWeaponCount = 1
						-- Insert the textLine.
						table.insert(textLines, weaponText)
					end
				end
			end

			-- Set lastWeapon stuff.
			lastWeaponDmg = weapon.Damage
			lastWeaponDPS = math.floor(PhxLib.PhxWeapDPS(weapon).DPS + 0.5)
			lastWeaponPPOF = weapon.ProjectilesPerOnFire
			lastWeaponDoT = weapon.DoTPulses
			lastWeaponDmgRad = weapon.DamageRadius
			lastWeaponROF = PhxLib.PhxWeapDPS(weapon).RateOfFire
			lastWeaponMinRad = weapon.MinRadius
			lastWeaponMaxRad = weapon.MaxRadius
			lastWeaponFF = weapon.DamageFriendly
			lastWeaponCF = weapon.CollideFriendly
			lastWeaponTarget = weapon.TargetRestrictOnlyAllow
			lastWeaponNukeInDmg = weapon.NukeInnerRingDamage
			lastWeaponNukeInRad = weapon.NukeInnerRingRadius
			lastWeaponNukeOutDmg = weapon.NukeOuterRingDamage
			lastWeaponNukeOutRad = weapon.NukeOuterRingRadius
		end
		for _, tl in textLines do
			local wrapped = import('/lua/maui/text.lua').WrapText(tl, unitDisplay.weapons.Width(), function(curText) return unitDisplay.weapons:GetStringAdvance(curText) end)
			for _, line in wrapped do
				unitDisplay.weapons:AddItem(line)
			end
		end
	else
		unitDisplay.weaponsLabel:Hide()
		unitDisplay.weapons:Hide()
		unitDisplay.weapons.Height:Set(0)
	end
end

function ClearUnitDisplay()
	unitDisplay.backIcon:Hide()
	unitDisplay.icon:Hide()
	unitDisplay.stratIcon:Hide()
	unitDisplay.factionIcon:Hide()
	unitDisplay.name:SetText('')
	unitDisplay.shortDesc1:SetText('')
	unitDisplay.shortDesc2:SetText('')
	unitDisplay.longDesc:DeleteAllItems()
	unitDisplay.longDesc:Hide()
	unitDisplay.technicals:SetText('')
	unitDisplay.abilities.Height:Set(0)
	unitDisplay.abilities:Hide()
	unitDisplay.healthIcon:Hide()
	unitDisplay.health:SetText('')
	unitDisplay.shieldIcon:Hide()
	unitDisplay.shield:SetText('')
	unitDisplay.capIcon:Hide()
	unitDisplay.cap:SetText('')
	unitDisplay.massCostIcon:Hide()
	unitDisplay.mass:SetText('')
	unitDisplay.energyCostIcon:Hide()
	unitDisplay.energy:SetText('')
	unitDisplay.buildTimeIcon:Hide()
	unitDisplay.buildTime:SetText('')
	unitDisplay.buildPowerIcon:Hide()
	unitDisplay.fuelIcon:Hide()
	unitDisplay.fuelTime:SetText('')
	unitDisplay.storageLabel:Hide()
	unitDisplay.massStorageIcon:Hide()
	unitDisplay.massStorage:SetText('')
	unitDisplay.energyStorageIcon:Hide()
	unitDisplay.energyStorage:SetText('')
	unitDisplay.weaponsLabel:Hide()
	unitDisplay.weapons:DeleteAllItems()
	unitDisplay.weapons.Height:Set(0)
	unitDisplay.weapons:Hide()

	unitDisplay.prompt:Show()
end

function ToggleSetting(setting, checked)
	if checked then
		if setting == 'evenflow' then
			-- RATODO: Can't call the actual function in the hook file,
			-- but this just seems wasteful
			ApplyEvenflow()
		elseif setting == 'artillery' then
			ParseMerges('/mods/Artillery/hook/units')
		elseif setting == 'commanders' then
			ParseMerges('/mods/Enhanced Commanders/hook/units')
		elseif setting == 'nukes' then
			ParseMerges('/mods/Enhanced Nukes')
		end
	else
		-- Purge and repopulate allBlueprints
		allBlueprints = {}
		for _, dir in mainDirs do
			for _, file in DiskFindFiles(dir, '*_unit.bp') do
				local id = string.sub(file, string.find(file, '[%a%d]*_unit%.bp$'))
				id = string.sub(id, 1, string.len(id) - 8)
				safecall("UNIT DB: Loading BP "..file, doscript, file)
				allBlueprints[id] = temp
			end
		end
	end
	Filter()
	ClearUnitDisplay()
	listContainer:CalcVisible()
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
		filters['deathweapon'] ~= 1 or
		filters['emp'] ~= 1

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
		or (filters['faction'] == 3 and bp.General.FactionName ~= 'Aeon')
		or (filters['faction'] == 4 and bp.General.FactionName ~= 'Cybran')
		or (filters['faction'] == 5 and bp.General.FactionName ~= 'Seraphim') then
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
			or (filters['type'] == 6 and bp.General.Classification ~= 'RULEUC_Commander')
			or (filters['type'] == 3 and bp.Physics.MotionType ~= 'RULEUMT_Air')
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
			-- 0 is no, 1 is torp, 2 is TMD, 3 is SMD
			local hasCounter = 0
			-- 0 is no, 1 is explosion, 2 is air crash
			local hasDeathWeap = 0
			local hasEMP = false

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

					if filters['emp'] ~= 1 then
						if v.Buffs then
							for _, b in v.Buffs do
								if b.BuffType == 'STUN' then
									hasEMP = true
									break
								end
							end
						end
					end

					if v.RangeCategory == 'UWRC_DirectFire' then
						hasDirect = true
					elseif v.RangeCategory == 'UWRC_IndirectFire' then
						hasIndirect = true
					elseif v.RangeCategory == 'UWRC_AntiAir' then
						hasAA = true
					elseif v.RangeCategory == 'UWRC_AntiNavy' then
						hasTorp = true
					elseif v.TargetRestrictOnlyAllow == 'TORPEDO' then
						hasCounter = 1
					elseif v.TargetRestrictOnlyAllow == 'TACTICAL MISSILE' then
						hasCounter = 2
					elseif v.TargetRestrictOnlyAllow == 'STRATEGIC MISSILE' then
						hasCounter = 3
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
			or ((filters['countermeasures'] == 2 and hasCounter ~= 1)
			or (filters['countermeasures'] == 3 and hasCounter ~= 2)
			or (filters['countermeasures'] == 4 and hasCounter ~= 3)
			or (filters['countermeasures'] == 5 and hasCounter ~= 0))
			or ((filters['deathweapon'] == 2 and hasDeathWeap ~= 1)
			or (filters['deathweapon'] == 3 and hasDeathWeap ~= 2)
			or (filters['deathweapon'] == 4 and hasDeathWeap ~= 0))
			or ((filters['emp'] == 2 and not hasEMP)
			or (filters['emp'] == 3 and hasEMP)) then
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
	filters['emp'] = 1

	filters['amphib'] = 1
	filters['transport'] = 1
	filters['shield'] = 1
	filters['intel'] = 1
	filters['stealth'] = 1
end

function ApplyEvenflow()
	local factory_buildpower_ratio = 4

	for id,bp in allBlueprints do

		if bp.Categories then

			local max_mass, max_energy
			local alt_mass, alt_energy

			for i, cat in bp.Categories do

				local reportflag = false

				local oldtime = 0

				-- structures --
				if cat == 'STRUCTURE' then

					for j, catj in bp.Categories do

						if catj == 'TECH1' then

							max_mass = 5
							max_energy = 50

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass * 5
								alt_energy = bp.Economy.BuildCostEnergy/max_energy * 5

								local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

								if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime
									bp.Economy.BuildTime = best_adjust
									reportflag = true
								end
							end
						end

						if catj == 'TECH2' then

							max_mass = 10
							max_energy = 100

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass * 10
								alt_energy = bp.Economy.BuildCostEnergy/max_energy * 10

								local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

								if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime
									bp.Economy.BuildTime = best_adjust
									reportflag = true
								end
							end
						end

						if catj == 'TECH3' then

							max_mass = 15
							max_energy = 150

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass * 15
								alt_energy = bp.Economy.BuildCostEnergy/max_energy * 15

								local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

								if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime
									bp.Economy.BuildTime = best_adjust
									reportflag = true
								end
							end
						end

						if catj == 'EXPERIMENTAL' then

							max_mass = 60
							max_energy = 600

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass * 60
								alt_energy = bp.Economy.BuildCostEnergy/max_energy * 60

								local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

								if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime
									bp.Economy.BuildTime = best_adjust
									reportflag = true
								end
							end
						end

						-- factories would have immense self-upgrade speeds without this
						if catj == 'FACTORY' then

							-- this is not the best solution for factory upgrades since it doesn't
							-- quite follow the rules for factory built units - but it's close enough
							-- and reasonably balanced across the factory types

							if bp.General.UpgradesFrom ~= nil then
								bp.Economy.BuildTime = bp.Economy.BuildTime * 2.75
							end

						end

					end

					-- this covers MOBILE Factories - namely Cybran Eggs - which are structures themselves that produce mobile units
					if bp.Economy.BuildUnit then
						bp.Economy.BuildTime = bp.Economy.BuildTime * (1/2) * factory_buildpower_ratio
					end

				end

				-- units --
				if cat == 'MOBILE' then		-- ok lets handle all the factory built mobile units and mobile experimentals

					-- You'll notice that I allow factory built units to build with higher energy limits (scales up thru tiers - 20,30,45)
					-- this compensates somewhat for the division of their buildpower (in particular for the energy heavy air factories)
					for j, catj in bp.Categories do

						if catj == 'TECH1' then

							local buildpower = 40	-- default T1 factory buildpower

							max_mass = buildpower / factory_buildpower_ratio
							max_energy = (buildpower * 20) / factory_buildpower_ratio

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass		-- about 10 mass/second
								alt_energy = bp.Economy.BuildCostEnergy/max_energy	-- about 200 energy/second

								-- regardless of the mass & energy, a minimum build time of 1 second is required
								-- or else you get very wierd economy results when building the unit
								local best_adjust = math.max( 1, alt_mass, alt_energy)

								--LOG("*AI DEBUG id is "..repr(catj).." "..id.."  alt_mass is "..alt_mass.."  alt_energy is "..alt_energy.." Adjusting Buildtime from "..repr(bp.Economy.BuildTime).." to "..( best_adjust * buildpower ) )

								if math.ceil( best_adjust * buildpower ) ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime

									--LOG("*AI DEBUG id is "..repr(catj).." "..id.."  alt_mass is "..alt_mass.."  alt_energy is "..alt_energy.." Adjusting Buildtime from "..repr(bp.Economy.BuildTime).." to "..( best_adjust * buildpower ) )

									bp.Economy.BuildTime = best_adjust

									bp.Economy.BuildTime = math.ceil(bp.Economy.BuildTime * buildpower)

									reportflag = true
								end
							end
						end

						if catj == 'TECH2' then

							local buildpower = 70	-- default T2 factory buildpower

							max_mass = buildpower / factory_buildpower_ratio
							max_energy = (buildpower * 30) / factory_buildpower_ratio

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass       -- about 17.5 mass/second
								alt_energy = bp.Economy.BuildCostEnergy/max_energy  -- about 525 energy/second

								local best_adjust = math.max( 1, alt_mass, alt_energy)

								if math.ceil( best_adjust * buildpower ) ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime

									--LOG("*AI DEBUG id is "..repr(catj).." "..id.."  alt_mass is "..alt_mass.."  alt_energy is "..alt_energy.." Adjusting Buildtime from "..repr(bp.Economy.BuildTime).." to "..( best_adjust * buildpower ) )

									bp.Economy.BuildTime = best_adjust

									bp.Economy.BuildTime = math.ceil(bp.Economy.BuildTime * buildpower)

									reportflag = true
								end
							end
						end

						if catj == 'TECH3' then

							local buildpower = 100	-- default T3 factory buildpower

							max_mass = buildpower / factory_buildpower_ratio            -- about 25 mass/second
							max_energy = (buildpower * 45) / factory_buildpower_ratio   -- about 1125 energy/second

							if bp.Economy.BuildTime then

								alt_mass =  bp.Economy.BuildCostMass/max_mass
								alt_energy = bp.Economy.BuildCostEnergy/max_energy

								local best_adjust = math.max( 1, alt_mass, alt_energy)

								if math.ceil( best_adjust * buildpower ) ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime

									bp.Economy.BuildTime = best_adjust

									bp.Economy.BuildTime = math.ceil(bp.Economy.BuildTime * buildpower)

									reportflag = true
								end
							end
						end

						-- OK - a small problem here - No factory built experimentals - these will be the SACU built MOBILE units
						-- as engineers they have remarkable bulidpower rates for mass compared to factories - but lower energy rates
						-- that are only slightly improved over a T2 factory
						if catj == 'EXPERIMENTAL' then

							max_mass = 60
							max_energy = 600

							if bp.Economy.BuildTime then

								-- experimental units are not factory built so factory_buildpower_ratio is NO applied (we just use the default SACU buildpower (60)
								alt_mass =  (bp.Economy.BuildCostMass/max_mass) * 60
								alt_energy = (bp.Economy.BuildCostEnergy/max_energy) * 60

								local best_adjust = math.max( 1, alt_mass, alt_energy)

								if math.ceil( best_adjust ) ~= math.ceil(bp.Economy.BuildTime) then

									oldtime = bp.Economy.BuildTime

									bp.Economy.BuildTime = math.ceil(best_adjust)

									reportflag = true
								end
							end
						end
					end
				end
			end
		end
	end
end