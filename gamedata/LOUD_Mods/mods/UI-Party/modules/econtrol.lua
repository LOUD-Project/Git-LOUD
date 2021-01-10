local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local GameMain = import('/lua/ui/game/gamemain.lua')
local Group = import('/lua/maui/group.lua').Group
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local CommonUnits = import('/mods/CommonModTools/units.lua')
local LINQ = import('/mods/UI-Party/modules/linq.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local spendTypes = {
	PROD = "PROD",
	MAINT = "MAINT"
}

local workerTypes = {
	WORKING = "WORKING",
	PAUSED = "PAUSED"
}

local resourceTypes = {
	{ name = "Mass", econDataKey = "massConsumed" },
	{ name = "Energy", econDataKey = "energyConsumed" },
}

local unitTypes;

function GetUnitType(unit)
	local unitType = nil
	for _, ut in unitTypes do
		if EntityCategoryContains(ut.category, unit) then
			unitType = ut
			break
		end
	end

	if (unitType == nil) then
		unitType = unitTypes[table.getn(unitTypes)]
	end

	return unitType
end

function OnUnitBoxClick(self, event, unitBox)
	if event.Type == 'ButtonPress' then
		if event.Modifiers.Ctrl then
			if event.Modifiers.Right then
				EnablePaused(unitBox)
			else
				SelectPaused(unitBox)
			end
		else
			if event.Modifiers.Right then
				DisableWorkers(unitBox)
			else
				SelectWorkers(unitBox)
			end
		end
--[[
		if unitBox.workerType == workerTypes.WORKING then

			if event.Modifiers.Right then
				DisableWorkers(unitBox)
			else
				SelectWorkers(unitBox)
			end
		elseif unitBox.workerType == workerTypes.PAUSED then
			if event.Modifiers.Right then
				EnablePaused(unitBox)
			else
				SelectPaused(unitBox)
			end
		end
--]]
	end
end

function GetWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = nil
	if unitBox.spendType == spendTypes.PROD then
		workers = unitType.prodUnits
	elseif unitBox.spendType == spendTypes.MAINT then
		workers = unitType.maintUnits
	end
	return ValidateUnitsList(workers)
end

function DisableWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = GetWorkers(unitBox)
	if table.getn(workers) == 0 then

	else

		if unitBox.spendType == spendTypes.PROD then

			for k,v in unitType.prodUnits do
				table.insert(unitType.pausedProdUnits, v)
			end
			SetPaused(workers, true)

		elseif unitBox.spendType == spendTypes.MAINT then

			for k,v in unitType.maintUnits do
				table.insert(unitType.pausedMaintUnits, v)
			end
			DisableUnitsAbility(workers)

		end
	end
end

function SelectWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = GetWorkers(unitBox)
	SelectUnits(workers)
end

function GetPaused(unitBox)
	local unitType = unitBox.unitType
	local workers = nil

	if unitBox.spendType == spendTypes.PROD then
		workers = unitType.pausedProdUnits
	elseif unitBox.spendType == spendTypes.MAINT then
		workers = unitType.pausedMaintUnits
	end

	local stillPaused = {}
	for k,v in ValidateUnitsList(workers) do
		if GetIsPausedBySpendType({v}, unitBox.spendType) then
			table.insert(stillPaused, v)
		end
	end
	-- could check still working on same project here
	return stillPaused
end

function GetIsPausedBySpendType(units, spendType)
	if spendType == spendTypes.PROD then
		return GetIsPaused(units)
	elseif spendType == spendTypes.MAINT then
		return GetIsUnitAbilityEnabled(units)
	end
end


function EnablePaused(unitBox)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitBox.unitType
	if unitBox.spendType == spendTypes.PROD then
		SetPaused(pauseUnits, false)
		unitType.pausedProdUnits = {}
	elseif  unitBox.spendType == spendTypes.MAINT then
		EnableUnitsAbility(pauseUnits)
		unitType.pausedMaintUnits = {}
	end
	unitBox.SetOn(false)
end

function SelectPaused(unitBox)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitBox.unitType
	SelectUnits(pauseUnits)
end

--unitToggleRules = {
--    Shield =  0,
--    Weapon = 1, --?
--    Jamming = 2,
--    Intel = 3,
--    Production = 4, --?
--    Stealth = 5,
--    Generic = 6,
--    Special = 7,
--Cloak = 8,}

function GetOnValueForScriptBit(i)
	if i == 0 then return false end -- shield is weird and reversed... you need to set it to false to get it to turn off - unlike everything else
	return true
end

function DisableUnitsAbility(units)
    for i = 0,8 do
        ToggleScriptBit(units, i, not GetOnValueForScriptBit(i))
    end
end

function EnableUnitsAbility(units)
    for i = 0,8 do
        ToggleScriptBit(units, i, GetOnValueForScriptBit(i))
    end
end

function GetIsUnitAbilityEnabled(units)

	for i = 0,8 do
        if GetScriptBit(units, i) == GetOnValueForScriptBit(i) then
			return true
		end
    end
	return false
end


local hoverUnitType = nil
local selectedUnitType = nil

function OnClick(self, event, unitType)
	if event.Type == 'MouseExit' then
	if hoverUnitType ~= nil then
			hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
		end
		hoverUnitType = nil
	end
	if event.Type == 'MouseEnter' then
		hoverUnitType = unitType
	end
	if event.Type == 'ButtonPress' then

		if selectedUnitType ~= nil then
			selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
		end
		selectedUnitType = unitType
		UpdateSelectedUnitType(selectedUnitType)

		local allUnits = table.concat(unitType.prodUnits, unitType.maintUnits)
		SelectUnits(LINQ.ToArray(allUnits))
	end

	if hoverUnitType ~= nil then
		hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('11ffffff')
	end
	if selectedUnitType~= nil then
		selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('33ffffff')
	end

	return true
end

function UpdateSelectedUnitType(selectedUnitType)
	UIP.econtrol.ui.textLabel:SetText(selectedUnitType.name)
	--UIP.econtrol.ui.selectedTypeView.textLabel:SetText(selectedUnitType.name)
end


function GetEconData(unit)
	local mi = unit:GetMissileInfo()
	if (mi.nukeSiloBuildCount > 0 or mi.tacticalSiloBuildCount > 0) then
		-- special favour to silo stuff
		return unit:GetEconData()
	end

	if Sync.FixedEcoData ~= nil then
		local data = FixedEcoData[unit:GetEntityId()]
		return data;
	else
		-- legacy broken way, works in ui mod
		return unit:GetEconData()
	end
end

function DoUpdate()
	if UIP.GetSetting("showEcontrolResources") then
		UpdateResourcesUi();
	end
	UpdateMexesUi();
end

function UpdateResourcesUi()

	local units = CommonUnits.Get()

	for k, unitType in unitTypes do
		unitType.prodUnits = {}
		unitType.maintUnits = {}
	end

	-- Set unittype resource usages to 0
	for _, rType in resourceTypes do
		rType.usage = 0
		rType.maintUsage = 0
		for _, unitType in unitTypes do
			local unitTypeUsage = unitType.usage[rType.name]
			unitTypeUsage.usage = 0
			unitTypeUsage.maintUsage = 0
		end
	end

	-- fill unittype resources with real data
	for _, unit in units do
		local econData = GetEconData(unit)
		local unitToGetDataFrom = nil
		local isMaint = false

		if (econData == nil) then
			return;
		end

		if unit:GetFocus() then
			unitToGetDataFrom = unit:GetFocus()
			isMaint = false
		else
			unitToGetDataFrom = unit
			isMaint = true
		end

		local unitType = GetUnitType(unitToGetDataFrom)

		local unitHasUsage = false
		for _, rType in resourceTypes do
			local usage = econData[rType.econDataKey]

			if (usage > 0) then
				local unitTypeUsage = unitType.usage[rType.name]
				if (isMaint) then
					rType.maintUsage = rType.maintUsage + usage
					unitTypeUsage.maintUsage = unitTypeUsage.maintUsage + usage
				else
					rType.usage = rType.usage + usage
					unitTypeUsage.usage = unitTypeUsage.usage + usage
				end
				unitHasUsage = true
			end
		end

		if unitHasUsage then
			if (isMaint) then
				table.insert(unitType.maintUnits, unit)
			else
				table.insert(unitType.prodUnits, unit)
			end
		end
	end

	-- update ui
	local relayoutRequired = false
	for _, unitType in unitTypes do

		unitType.typeUi.maintUnitsBox.SetAltOn(table.getn(unitType.pausedMaintUnits) > 0)
		unitType.typeUi.prodUnitsBox.SetAltOn(table.getn(unitType.pausedProdUnits) > 0)

		for _, rType in resourceTypes do
			local unitTypeUsage = unitType.usage[rType.name]
			local rTypeUsageTotal = rType.usage + rType.maintUsage

			if rTypeUsageTotal == 0 then
				unitTypeUsage.bar.Width:Set(0)
				unitTypeUsage.maintBar.Width:Set(0)
				--unitTypeUsage.text:SetText("")
				--unitTypeUsage.maintText:SetText("")
				unitType.typeUi.prodUnitsBox.SetOn(false)
				unitType.typeUi.maintUnitsBox.SetOn(false)
			else
				local bv = unitTypeUsage.usage
				local bmv = unitTypeUsage.maintUsage
				local percentify = true
				if (percentify) then
					bv = bv / rTypeUsageTotal * 100
					bmv = bmv / rTypeUsageTotal * 100
				end

				bv = math.ceil(bv)
				bmv = math.ceil(bmv)

				if (bv > 0 and bv < 1) then bv = 1 end
				if (bmv > 0 and bmv < 1) then bmv = 1 end

				local shouldShow = bv + bmv > 0
				if (shouldShow and unitType.typeUi.uiRoot:IsHidden()) then
					unitType.typeUi.uiRoot:Show()
					unitType.typeUi.Clear()
					relayoutRequired = true
				end

				unitTypeUsage.bar.Width:Set(bv)
				unitTypeUsage.maintBar.Width:Set(bmv)
				local r = unitTypeUsage.bar.Right() + 1
				if bv == 0 then r = unitTypeUsage.bar.Left() end
				unitTypeUsage.maintBar.Left:Set(r)

				unitType.typeUi.prodUnitsBox.SetOn(bv > 0)
				unitType.typeUi.maintUnitsBox.SetOn(bmv > 0)

				-- 		unitTypeUsage.text:SetText(string.format("%4.0f", unitTypeUsage.usage))

--				local str = unitTypeUsage.usage
--				if (str == 0) then str = "" else str = string.format("%10.3f", str) end
--				unitTypeUsage.text:SetText(str)

--				local str = unitTypeUsage.maintUsage
--				if (str == 0) then str = "" else str = string.format("%10.3f", str) end
--				unitTypeUsage.maintText:SetText(str)
			end
		end
	end

	if relayoutRequired then
		local y = 0
		for _, unitType in unitTypes do
			if not unitType.typeUi.uiRoot:IsHidden() then
				unitType.typeUi.uiRoot:Top(y)
				LayoutHelpers.AtTopIn(unitType.typeUi.uiRoot, UIP.econtrol.ui, y)
				y = y + unitType.typeUi.uiRoot:Height()
			end
		end
		UIP.econtrol.ui.Height:Set(y)

	end
end

function UnitBox(typeUi, unitType, spendType, workerType)

	local group = Group(typeUi.uiRoot);
	group.Width:Set(20)
	group.Height:Set(22)

	local buttonBackgroundName = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
	local button = Bitmap(group, buttonBackgroundName)
	button.Width:Set(20)
	button.Height:Set(22)
	LayoutHelpers.AtLeftIn(button, group, 0)
	LayoutHelpers.AtVerticalCenterIn(button, group, 0)

	local check2 = Bitmap(group	)
	check2.Width:Set(12)
	check2.Height:Set(12)
	check2:InternalSetSolidColor('55ff0000')
	LayoutHelpers.AtLeftIn(check2, group, 4)
	LayoutHelpers.AtVerticalCenterIn(check2, group, 0)

	local check = Bitmap(group, '/textures/ui/uef/game/temp_textures/checkmark.dds')
	check.Width:Set(8)
	check.Height:Set(8)
	LayoutHelpers.AtLeftIn(check, group, 6)
	LayoutHelpers.AtVerticalCenterIn(check, group, 0)



	local unitBox = {
		group = group,
		button = button,
		check = check,
		unitType = unitType,
		spendType = spendType,
		workerType = workerType,
	};

	unitBox.SetOn = function(val)
		if val then
			check:Show()
		else
			check:Hide()
		end
	end

	unitBox.SetAltOn = function(val)
		if val then
			check2:Show()
		else
			check2:Hide()
		end
	end

	unitBox.SetOn(false);
	unitBox.SetAltOn(false);
	group.HandleEvent = function(self, event)
		OnUnitBoxClick(self, event, unitBox)
		return true;
	end

	return unitBox

end


local mexCategories = {}

function UpdateMexesUi()
	for _, category in mexCategories do
		category.units = {};
	end

	local units = CommonUnits.Get()

	for _, unit in units do
		if EntityCategoryContains(categories.MASSEXTRACTION, unit) then
			for _, category in mexCategories do
				if IsMexCategoryMatch(category, unit) then
					table.insert(category.units, unit)
					break;
				end
			end
		end
	end

	for _, category in mexCategories do

		local count = table.getn(category.units)
		local str = ""
		local alpha = 0.3
		if count > 0 then
			str = count
			alpha = 1
		end
		category.ui.countLabel:SetText(str)
		category.ui.stratIcon:SetAlpha(alpha)
		if category.ui.upgrIcon then category.ui.upgrIcon:SetAlpha(alpha) end
		if category.ui.pauseIcon then category.ui.pauseIcon:SetAlpha(alpha) end

		local sorted = GetUpgradingUnits(category)
		for i = 1, 10 do
			local u = sorted[i]
			SetMexCategoryProgress(category, i, u)
		end
	end
end

function GetUpgradingUnits(category)
	local units = LINQ.Where(category.units,
		function(k, u)
			return u:GetWorkProgress() < 1 and u:GetWorkProgress() > 0 
		end)
	units = LINQ.ToArray(units)
	local sorted = dosort(units, function(u) return u:GetWorkProgress() end)
	return sorted
end

function SetMexCategoryProgress(category, index, unit)
	if unit == nil then
		category.ui.bar1s[index]:Hide()
		category.ui.bar2s[index]:Hide()
	else
		category.ui.bar1s[index]:Show()
		category.ui.bar2s[index]:Show()
		category.ui.bar2s[index].Width:Set(22*unit:GetWorkProgress())
	end
end

function dosort(t, func)
	local keys = {}
	for k, _ in t do keys[table.getn(keys) + 1] = k end
	table.sort(keys, function(a,b) return func(t[a]) > func(t[b]) end)
	local sorted = {}
	local i = 1
    while keys[i] do
        sorted[i] = t[keys[i]]
        i = i + 1
    end
	return sorted;
end

function IsMexCategoryMatch(mexCategory, unit)

	if unit.isUpgradee then
		return false
	end

	if not EntityCategoryContains(mexCategory.categories, unit) then
		return false
	end

	if unit.isUpgrader ~= mexCategory.isUpgrading then
		return false
	end

	if mexCategory.isPaused ~= nil then
		if GetIsPaused({ unit }) ~= mexCategory.isPaused then
			return false
		end
	end

	return true

end

local hoverMexCategoryType
function OnMexCategoryUiClick(self, event, category)
	if event.Type == 'MouseExit' then
	if hoverMexCategoryType ~= nil then
			hoverMexCategoryType.ui:InternalSetSolidColor('aa000000')
		end
		hoverMexCategoryType = nil
	end
	if event.Type == 'MouseEnter' then
		hoverMexCategoryType = category
	end
	if event.Type == 'ButtonPress' then

		if event.Modifiers.Right then
			if category.isPaused ~= nil then
				if event.Modifiers.Ctrl then
					local sorted = GetUpgradingUnits(category)
					local best = sorted[1]

					if category.isPaused then
						-- unpause the best
						SetPaused({ best }, false)
					else
						-- pause all except the best
						local worst = sorted[table.getn(sorted)]
						SetPaused({ worst }, true)
					end
				else
					SetPaused(category.units, not category.isPaused)
				end
			end
		else
			if event.Modifiers.Ctrl then
				local sorted = GetUpgradingUnits(category)
				local best = sorted[1]
				SelectUnits({ best })
			else
				SelectUnits(category.units)
				UIP.econtrol.ui.textLabel:SetText(category.name)
			end
		end
	end

	if hoverMexCategoryType ~= nil then
		hoverMexCategoryType.ui:InternalSetSolidColor('11ffffff')
	end

	return true

end

function CreateMexesUi(uiRoot)
	mexCategories = {
		{ name = "T1 idle", categories = categories.TECH1, isUpgrading = false, isPaused = nil, icon = "icon_structure1_mass" },
		{ name = "T1 upgrading paused", categories = categories.TECH1, isUpgrading = true, isPaused = true, icon = "icon_structure1_mass" },
		{ name = "T1 upgrading", categories = categories.TECH1, isUpgrading = true, isPaused = false, icon = "icon_structure1_mass" },
		{ name = "T2 idle", categories = categories.TECH2, isUpgrading = false, isPaused = nil, icon = "icon_structure2_mass"},
		{ name = "T2 upgrading paused", categories = categories.TECH2, isUpgrading = true, isPaused = true, icon = "icon_structure2_mass" },
		{ name = "T2 upgrading", categories = categories.TECH2, isUpgrading = true, isPaused = false, icon = "icon_structure2_mass" },
		{ name = "T3", categories = categories.TECH3, isUpgrading = false, isPaused = nil, icon = "icon_structure3_mass" },
	}

	local mexRoot = Bitmap(uiRoot)
	mexRoot.Width:Set(table.getn(categories)*24-2)
	mexRoot.Height:Set(22)
	--mexRoot:InternalSetSolidColor('aa00ff00')
	LayoutHelpers.AtLeftIn(mexRoot, uiRoot, 0)
	LayoutHelpers.AtTopIn(mexRoot, uiRoot, -72)

	for k, category in mexCategories do
		local categoryUi = Bitmap(mexRoot)
		categoryUi.HandleEvent = function(self, event) return OnMexCategoryUiClick(self, event, category) end
		categoryUi.Width:Set(22)
		categoryUi.Height:Set(50)
		categoryUi:InternalSetSolidColor('aa000000')
		--categoryUi:InternalSetSolidColor('aa00ffff')
		LayoutHelpers.AtLeftIn(categoryUi, mexRoot, (k-1) * 24)
		LayoutHelpers.AtTopIn(categoryUi, mexRoot, 0)

		categoryUi.stratIcon = Bitmap(categoryUi)
		local iconName = '/textures/ui/common/game/strategicicons/' .. category.icon .. '_rest.dds'
		categoryUi.stratIcon:SetTexture(iconName)
		categoryUi.stratIcon.Height:Set(categoryUi.stratIcon.BitmapHeight)
		categoryUi.stratIcon.Width:Set(categoryUi.stratIcon.BitmapWidth)
		categoryUi.stratIcon:SetAlpha(0.3)
		LayoutHelpers.AtLeftIn(categoryUi.stratIcon, categoryUi, (22-categoryUi.stratIcon.Width())/2)
		LayoutHelpers.AtTopIn(categoryUi.stratIcon, categoryUi,(16 + 24-categoryUi.stratIcon.Height())/2)

		if (category.isPaused) then
			categoryUi.pauseIcon = Bitmap(categoryUi)
			iconName = '/textures/ui/common/game/strategicicons/pause_rest.dds'
			categoryUi.pauseIcon:SetTexture(iconName)
			categoryUi.pauseIcon.Height:Set(24)
			categoryUi.pauseIcon.Width:Set(24)
			categoryUi.pauseIcon:SetAlpha(0.3)
			LayoutHelpers.AtLeftIn(categoryUi.pauseIcon, categoryUi, (22-categoryUi.pauseIcon.Width())/2)
			LayoutHelpers.AtTopIn(categoryUi.pauseIcon, categoryUi, 8 + 0)
		end

		if (category.isUpgrading) then
			categoryUi.upgrIcon = Bitmap(categoryUi)
			iconName = '/mods/ui-party/textures/upgrade.dds'
			categoryUi.upgrIcon:SetTexture(iconName)
			categoryUi.upgrIcon.Height:Set(8)
			categoryUi.upgrIcon.Width:Set(8)
			categoryUi.upgrIcon:SetAlpha(0.3)
			LayoutHelpers.AtLeftIn(categoryUi.upgrIcon, categoryUi, (22-categoryUi.upgrIcon.Width())/2+6)
			LayoutHelpers.AtTopIn(categoryUi.upgrIcon, categoryUi, 12 + 8)
		end

		categoryUi.countLabel = UIUtil.CreateText(categoryUi, "0", 9, UIUtil.bodyFont)
		categoryUi.countLabel.Width:Set(5)
		categoryUi.countLabel.Height:Set(5)
		categoryUi.countLabel:SetNewColor('ffaaaaaa')
		categoryUi.countLabel:DisableHitTest()
		LayoutHelpers.AtLeftIn(categoryUi.countLabel, categoryUi, 9)
		LayoutHelpers.AtTopIn(categoryUi.countLabel, categoryUi, 1)

		categoryUi.bar1s = {}
		categoryUi.bar2s = {}
		for i = 1, 10 do
			local bar1 = Bitmap(categoryUi)
			bar1.Width:Set(22)
			bar1.Height:Set(2)
			bar1:InternalSetSolidColor('1100ff00')
			LayoutHelpers.AtLeftIn(bar1, categoryUi, 0)
			LayoutHelpers.AtTopIn(bar1, categoryUi, 50 - i * 2)

			local bar2 = Bitmap(categoryUi)
			bar2.Width:Set(2)
			bar2.Height:Set(2)
			bar2:InternalSetSolidColor('3300ff00')
			LayoutHelpers.AtLeftIn(bar2, categoryUi, 0)
			LayoutHelpers.AtTopIn(bar2, categoryUi, 50 - i * 2)

			table.insert(categoryUi.bar1s, bar1)
			table.insert(categoryUi.bar2s, bar2)
		end
		category.ui = categoryUi
	end
end

function buildUi()
	local a, b = pcall( function()
		UIP.econtrol = {}
		unitTypes = {
			{ name = "T1 Land Units", category = categories.LAND * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land1_generic", spacer = 0 },
			{ name = "T2 Land Units", category = categories.LAND * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land2_generic", spacer = 0 },

			{ name = "T3 Land Units", category = categories.LAND * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land3_generic", spacer = 20 },
			{ name = "T1 Air Units", category = categories.AIR * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter1_generic", spacer = 0 },
			{ name = "T2 Air Units", category = categories.AIR * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter2_generic", spacer = 0 },

			{ name = "T3 Air Units", category = categories.AIR * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter3_generic", spacer = 20 },
			{ name = "T1 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship1_generic", spacer = 0 },
			{ name = "T2 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship2_generic", spacer = 0 },
			{ name = "T3 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship3_generic", spacer = 20 },

			{ name = "Shields", category = categories.STRUCTURE * categories.SHIELD, icon = "icon_structure_shield", spacer = 0 },
			{ name = "Radar Stations", category = categories.STRUCTURE * categories.RADAR + categories.STRUCTURE * categories.OMNI, icon = "icon_structure_intel", spacer = 0  },
			{ name = "Sonar", category = categories.STRUCTURE * categories.SONAR + categories.MOBILESONAR, icon = "icon_structure_intel", spacer = 0  },
			{ name = "Stealth", category = categories.STRUCTURE * categories.COUNTERINTELLIGENCE, icon = "icon_structure_intel", spacer = 20 },

			{ name = "Energy production", category = categories.STRUCTURE * categories.ENERGYPRODUCTION, icon = "icon_structure1_energy", spacer = 0 },
			{ name = "Mass extraction", category = categories.MASSEXTRACTION + categories.MASSSTORAGE, icon = "icon_structure1_mass", spacer = 0 },
			{ name = "Mass fabrication", category = categories.STRUCTURE * categories.MASSFABRICATION, icon = "icon_structure1_mass", spacer = 20 },

			{ name = "Silos", category = categories.SILO, icon = "icon_structure_missile", spacer = 0 },
			{ name = "Factories", category = categories.STRUCTURE * categories.FACTORY - categories.GATE, icon = "icon_factory_generic", spacer = 0 },
			{ name = "Military", category = categories.STRUCTURE * categories.DEFENSE + categories.STRUCTURE * categories.STRATEGIC, icon = "icon_structure_directfire", spacer = 0 },
			{ name = "Experimentals", category = categories.EXPERIMENTAL, icon = "icon_experimental_generic", spacer = 0 },
			{ name = "ACU", category = categories.COMMAND, icon = "icon_commander_generic", spacer = 0 },
			{ name = "SACU", category = categories.SUBCOMMANDER, icon = "icon_commander_generic", spacer = 0 },
			{ name = "Engineers", category = categories.ENGINEER, icon = "icon_land_engineer", spacer = 20 },

			{ name = "Everything", category = categories.ALLUNITS, icon = "strat_attack_ping", spacer = 0 },
		}

		for _, unitType in unitTypes do
			unitType.usage = { }
			unitType.pausedProdUnits = { }
			unitType.pausedMaintUnits = { }
		end

		local col0 = 0
		local col1 = col0 + 20
		local col2 = col1 + 20
		local col3 = col2 + 20
		local col4 = col3 + 105
		local col5 = col4 + 20
		local col6 = col5 + 20
		local col7 = col6 + 20
		local col8 = 0
		local col9 = col8 + 20
		local col10 = col9 + 105

		local dragger = import('/mods/UI-Party/modules/ui.lua').buttons.dragButton
		local uiRoot = Bitmap(dragger)
		UIP.econtrol.ui = uiRoot
		uiRoot.Width:Set(42)
		uiRoot.Width:Set(0)
		uiRoot.Height:Set(100)
		uiRoot.Depth:Set(99)
		uiRoot:DisableHitTest()
		LayoutHelpers.AtLeftIn(uiRoot, dragger, 0)
		LayoutHelpers.AtTopIn(uiRoot, dragger,120)

		uiRoot.textLabel = UIUtil.CreateText(uiRoot, 'ECOntrol', 15, UIUtil.bodyFont)
		uiRoot.textLabel.Width:Set(10)
		uiRoot.textLabel.Height:Set(9)
		uiRoot.textLabel:SetNewColor('white')
		uiRoot.textLabel:DisableHitTest()
		LayoutHelpers.AtLeftIn(uiRoot.textLabel, uiRoot, 0)
		LayoutHelpers.AtTopIn(uiRoot.textLabel, uiRoot, -95)

		function CreateText(text, x)

			local t = UIUtil.CreateText(uiRoot, text, 9, UIUtil.bodyFont)
			t.Width:Set(5)
			t.Height:Set(5)
			t:SetNewColor('ffaaaaaa')
			t:DisableHitTest()
			LayoutHelpers.AtLeftIn(t, uiRoot, x)
			LayoutHelpers.AtTopIn(t, uiRoot, -12)
		end

		if UIP.GetSetting("showEcontrolResources") then
			CreateText("B", col0+5)
			CreateText("U", col1+5)
	--		CreateText("C", col2+5)
			CreateText("Resources", col3)

			for _, unitType in unitTypes do

				local typeUi = { }
				unitType.typeUi = typeUi

				typeUi.uiRoot = Bitmap(uiRoot)
				typeUi.uiRoot.HandleEvent = function(self, event) return OnClick(self, event, unitType) end
				typeUi.uiRoot.Width:Set(col4)
				typeUi.uiRoot.Height:Set(22)
				typeUi.uiRoot:InternalSetSolidColor('aa000000')
				typeUi.uiRoot:Hide()
				LayoutHelpers.AtLeftIn(typeUi.uiRoot, uiRoot, 0)
				LayoutHelpers.AtTopIn(typeUi.uiRoot, uiRoot, 0)

				typeUi.stratIcon = Bitmap(typeUi.uiRoot)
				local iconName = '/textures/ui/common/game/strategicicons/' .. unitType.icon .. '_rest.dds'
				typeUi.stratIcon:SetTexture(iconName)
				typeUi.stratIcon.Height:Set(typeUi.stratIcon.BitmapHeight)
				typeUi.stratIcon.Width:Set(typeUi.stratIcon.BitmapWidth)
				LayoutHelpers.AtLeftIn(typeUi.stratIcon, typeUi.uiRoot, col2 + (20-typeUi.stratIcon.Width())/2)
				LayoutHelpers.AtVerticalCenterIn(typeUi.stratIcon, typeUi.uiRoot, 0)

				typeUi.prodUnitsBox = UnitBox(typeUi, unitType, spendTypes.PROD, workerTypes.WORKING)
				LayoutHelpers.AtLeftIn(typeUi.prodUnitsBox.group, typeUi.uiRoot, col0)
				LayoutHelpers.AtVerticalCenterIn(typeUi.prodUnitsBox.group, typeUi.uiRoot, 0)

				typeUi.maintUnitsBox = UnitBox(typeUi, unitType, spendTypes.MAINT, workerTypes.WORKING)
				LayoutHelpers.AtLeftIn(typeUi.maintUnitsBox.group, typeUi.uiRoot, col1)
				LayoutHelpers.AtVerticalCenterIn(typeUi.maintUnitsBox.group, typeUi.uiRoot, 0)

				typeUi.Clear = function()
					typeUi.prodUnitsBox.check:Hide()
					typeUi.maintUnitsBox.check:Hide()
				end

				typeUi.massBar = Bitmap(typeUi.uiRoot)
				typeUi.massBar.Width:Set(10)
				typeUi.massBar.Height:Set(1)
				typeUi.massBar:InternalSetSolidColor('lime')
				typeUi.massBar:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.massBar, typeUi.uiRoot, col3)
				LayoutHelpers.AtTopIn(typeUi.massBar, typeUi.uiRoot, 8)

				typeUi.massMaintBar = Bitmap(typeUi.uiRoot)
				typeUi.massMaintBar.Width:Set(10)
				typeUi.massMaintBar.Height:Set(1)
				typeUi.massMaintBar:InternalSetSolidColor('cyan')
				typeUi.massMaintBar:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.massMaintBar, typeUi.uiRoot, col3)
				LayoutHelpers.AtTopIn(typeUi.massMaintBar, typeUi.uiRoot, 8)

--[[
				typeUi.massText = UIUtil.CreateText(typeUi.uiRoot, 'M', 9, UIUtil.bodyFont)
				typeUi.massText.Width:Set(10)
				typeUi.massText.Height:Set(9)
				typeUi.massText:SetNewColor('lime')
				typeUi.massText:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.massText, typeUi.uiRoot, col3)
				LayoutHelpers.AtVerticalCenterIn(typeUi.massText, typeUi.uiRoot)



				typeUi.massMaintText = UIUtil.CreateText(typeUi.uiRoot, 'M', 9, UIUtil.bodyFont)
				typeUi.massMaintText.Width:Set(10)
				typeUi.massMaintText.Height:Set(9)
				typeUi.massMaintText:SetNewColor('cyan')
				typeUi.massMaintText:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.massMaintText, typeUi.uiRoot, col4)
				LayoutHelpers.AtVerticalCenterIn(typeUi.massMaintText, typeUi.uiRoot)
--]]
				typeUi.energyBar = Bitmap(typeUi.uiRoot)
				typeUi.energyBar.Width:Set(10)
				typeUi.energyBar.Height:Set(1)
				typeUi.energyBar:InternalSetSolidColor('yellow')
				typeUi.energyBar:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.energyBar, typeUi.uiRoot, col3)
				LayoutHelpers.AtTopIn(typeUi.energyBar, typeUi.uiRoot, 11)

				typeUi.energyMaintBar = Bitmap(typeUi.uiRoot)
				typeUi.energyMaintBar.Width:Set(10)
				typeUi.energyMaintBar.Height:Set(1)
				typeUi.energyMaintBar:InternalSetSolidColor('orange')
				typeUi.energyMaintBar:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.energyMaintBar, typeUi.uiRoot, col3)
				LayoutHelpers.AtTopIn(typeUi.energyMaintBar, typeUi.uiRoot, 11)

--[[
				typeUi.energyText = UIUtil.CreateText(typeUi.uiRoot, 'E', 9, UIUtil.bodyFont)
				typeUi.energyText.Width:Set(10)
				typeUi.energyText.Height:Set(9)
				typeUi.energyText:SetNewColor('yellow')
				typeUi.energyText:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.energyText, typeUi.uiRoot, col5)
				LayoutHelpers.AtVerticalCenterIn(typeUi.energyText, typeUi.uiRoot)

				typeUi.energyMaintText = UIUtil.CreateText(typeUi.uiRoot, 'E', 9, UIUtil.bodyFont)
				typeUi.energyMaintText.Width:Set(10)
				typeUi.energyMaintText.Height:Set(9)
				typeUi.energyMaintText:SetNewColor('orange')
				typeUi.energyMaintText:DisableHitTest()
				LayoutHelpers.AtLeftIn(typeUi.energyMaintText, typeUi.uiRoot, col6)
				LayoutHelpers.AtVerticalCenterIn(typeUi.energyMaintText, typeUi.uiRoot)
--]]

				unitType.usage["Mass"] = {
					bar = typeUi.massBar,
					maintBar = typeUi.massMaintBar,
					text = typeUi.massText,
					maintText = typeUi.massMaintText,
				}

				unitType.usage["Energy"] = {
					bar = typeUi.energyBar,
					maintBar = typeUi.energyMaintBar,
					text = typeUi.energyText,
					maintText = typeUi.energyMaintText,
				}

				typeUi.massBar:Hide()
				typeUi.massMaintBar:Hide()
				typeUi.energyBar:Hide()
				typeUi.energyMaintBar:Hide()

			end
		end

--[[
		local selectedTypeView = Bitmap(uiRoot)
		uiRoot.selectedTypeView = selectedTypeView
		selectedTypeView.Width:Set(col10)
		selectedTypeView.Height:Set(250)
		LayoutHelpers.AtLeftIn(selectedTypeView, uiRoot, col7)
		LayoutHelpers.AtTopIn(selectedTypeView, uiRoot, 0)
		selectedTypeView:SetSolidColor("aa000000")


		selectedTypeView.textLabel = UIUtil.CreateText(selectedTypeView, 'Unit Type', 15, UIUtil.bodyFont)
		selectedTypeView.textLabel.Width:Set(10)
		selectedTypeView.textLabel.Height:Set(9)
		selectedTypeView.textLabel:SetNewColor('white')
		selectedTypeView.textLabel:DisableHitTest()
		LayoutHelpers.AtLeftIn(selectedTypeView.textLabel, selectedTypeView, 5)
		LayoutHelpers.AtTopIn(selectedTypeView.textLabel, selectedTypeView, -31)


		for i = 0,8 do

			local typeUi = { }

			typeUi.uiRoot = Bitmap(selectedTypeView)
			--typeUi.uiRoot.HandleEvent = function(self, event) return OnClick(self, event, unitType) end
			typeUi.uiRoot.Width:Set(col10)
			typeUi.uiRoot.Height:Set(22)
			typeUi.uiRoot:InternalSetSolidColor('ff000000')
			LayoutHelpers.AtLeftIn(typeUi.uiRoot, selectedTypeView, 0)
			LayoutHelpers.AtTopIn(typeUi.uiRoot, selectedTypeView,i*22)

			typeUi.stratIcon = Bitmap(typeUi.uiRoot)
			iconName = '/textures/ui/common/game/strategicicons/icon_land1_generic_rest.dds'
			typeUi.stratIcon:SetTexture(iconName)
			typeUi.stratIcon.Height:Set(typeUi.stratIcon.BitmapHeight)
			typeUi.stratIcon.Width:Set(typeUi.stratIcon.BitmapWidth)
			LayoutHelpers.AtLeftIn(typeUi.stratIcon, typeUi.uiRoot, col8 + (20-typeUi.stratIcon.Width())/2)
			LayoutHelpers.AtVerticalCenterIn(typeUi.stratIcon, typeUi.uiRoot, 0)

			typeUi.massBar = Bitmap(typeUi.uiRoot)
			typeUi.massBar.Width:Set(10)
			typeUi.massBar.Height:Set(1)
			typeUi.massBar:InternalSetSolidColor('lime')
			typeUi.massBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massBar, typeUi.uiRoot, col9)
			LayoutHelpers.AtTopIn(typeUi.massBar, typeUi.uiRoot, 6)

			typeUi.massMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.massMaintBar.Width:Set(10)
			typeUi.massMaintBar.Height:Set(1)
			typeUi.massMaintBar:InternalSetSolidColor('cyan')
			typeUi.massMaintBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massMaintBar, typeUi.uiRoot, col9)
			LayoutHelpers.AtTopIn(typeUi.massMaintBar, typeUi.uiRoot, 6)

			typeUi.energyBar = Bitmap(typeUi.uiRoot)
			typeUi.energyBar.Width:Set(10)
			typeUi.energyBar.Height:Set(1)
			typeUi.energyBar:InternalSetSolidColor('yellow')
			typeUi.energyBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energyBar, typeUi.uiRoot, col9)
			LayoutHelpers.AtTopIn(typeUi.energyBar, typeUi.uiRoot, 10)

			typeUi.energyMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.energyMaintBar.Width:Set(10)
			typeUi.energyMaintBar.Height:Set(1)
			typeUi.energyMaintBar:InternalSetSolidColor('orange')
			typeUi.energyMaintBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energyMaintBar, typeUi.uiRoot, col9)
			LayoutHelpers.AtTopIn(typeUi.energyMaintBar, typeUi.uiRoot, 10)

		end
--]]

		CreateMexesUi(uiRoot)

		UIP.econtrol.beat = DoUpdate
		GameMain.AddBeatFunction(UIP.econtrol.beat)

		DoUpdate()
	end)

	if not a then
		WARN("UI PARTY RESULT: ", a, b)
	end
end

function setEnabled(value)
	-- Tear down old ui
	if rawget(UIP, "econtrol") ~= nil then
		if UIP.econtrol.ui then UIP.econtrol.ui:Destroy() end
		if UIP.econtrol.beat then GameMain.RemoveBeatFunction(UIP.econtrol.beat) end
		UIP.econtrol = nil
	end

	-- Build new ui
	if value then
		buildUi()
	end
end
