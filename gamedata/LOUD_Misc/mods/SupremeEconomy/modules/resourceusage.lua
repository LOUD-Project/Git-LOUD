local LayoutHelpers = import('/lua/maui/layouthelpers.lua') 
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Group = import('/lua/maui/group.lua').Group
local UIUtil = import('/lua/ui/uiutil.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')

local modFolder = 'SupremeEconomy'
local GetScore = import('/mods/' .. modFolder .. '/modules/mciscore.lua').GetScore
local GetAllUnits = import('/mods/' .. modFolder .. '/modules/mciallunits.lua').GetAllUnits
local CreateGrid = import('/mods/' .. modFolder .. '/modules/mcibuttons.lua').CreateGrid
local CreateGenericButton = import('/mods/' .. modFolder .. '/modules/mcibuttons.lua').CreateGenericButton

local LOUDINSERT = table.insert

function getNameFromBp(bp)

	local techLevel = false
    local levels = {TECH1 = 1,TECH2 = 2,TECH3 = 3}
	
    for i, v in bp.Categories do
	
        if levels[v] then
            techLevel = levels[v]
            break
        end
		
    end
	
    if techLevel then
        return LOCF("T%d %s", techLevel, bp.Description)
	else
		return LOC(bp.Description)
    end
	
end

local maxImages = 5
local grid = {}

local unitClasses = {
	{name="T1 Land Units",  category = categories.LAND * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER },
	{name="T2 Land Units",  category = categories.LAND * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER },
	{name="T3 Land Units",  category = categories.LAND * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER },
	{name="T1 Air Units",   category = categories.AIR * categories.BUILTBYTIER1FACTORY * categories.MOBILE  },
	{name="T2 Air Units",   category = categories.AIR * categories.BUILTBYTIER2FACTORY * categories.MOBILE  },
	{name="T3 Air Units",   category = categories.AIR * categories.BUILTBYTIER3FACTORY * categories.MOBILE  },
	{name="T1 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER1FACTORY * categories.MOBILE  },
	{name="T2 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER2FACTORY * categories.MOBILE  },
	{name="T3 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER3FACTORY * categories.MOBILE  },
	{name="Shields", category = categories.STRUCTURE * categories.SHIELD },
	{name="Radar Stations", category = categories.STRUCTURE * categories.RADAR },
	{name="Energy production", category = categories.STRUCTURE * categories.ENERGYPRODUCTION },
	{name="Mass extraction", category = categories.MASSEXTRACTION + categories.MASSSTORAGE },
	{name="Mass fabrication", category = categories.STRUCTURE * categories.MASSFABRICATION },
	{name="Factories", category = categories.STRUCTURE * categories.FACTORY},
}

function GetClassForUnit(unit)

	for _, class in unitClasses do
	
		if EntityCategoryContains(class.category, unit) then
			return class.name
		end
		
	end
	
	return nil
end

function UpdateResourceUsage()

	local units = GetAllUnits()
	local dataTypes = { "massConsumed", "energyConsumed" }
	local topUnitsData = {energyConsumed = {},massConsumed = {}}
	local unitsToBeSelected = {}
	local unitsWorkedUpon = {}
	local workProgressOnUnit = {}
	local unitNames = {}
	local CONSTRUCTION = "R"
	local CONSUMPTION = "C"
	local consumptionTypes = {}
	
	for index, unit in units do
	
		econData = unit:GetEconData()
		
		-- filter out units that do not use resources
		local usesResources = false
		
		for dataType, unitTable in topUnitsData do
		
			if econData[dataType] != 0 then
				usesResources = true
			end
			
		end
		
		if usesResources then
			-- assign a proper key and other misc stuff related to the construction/consumption difference
			
			local unitToGetDataFrom
			local prefix
			local consType
			
			if unit:GetFocus() then
				prefix = "-CONSTR- "
				unitToGetDataFrom = unit:GetFocus()
				consType = CONSTRUCTION
				workProgressOnUnit[unit:GetFocus():GetEntityId()] = unit:GetWorkProgress() --it should be only set in the context of the "name" generated"
			else
				prefix = ""
				unitToGetDataFrom = unit
				consType = CONSUMPTION
				workProgressOnUnit[unit:GetEntityId()] = unit:GetWorkProgress() --it should be only set in the context of the "name" generated"
			end
			
			local unitclass = GetClassForUnit(unitToGetDataFrom)
			
			if unitclass then
				name = prefix .. unitclass
				unitNames[name] = unitclass
			else
				name = prefix .. getNameFromBp(unitToGetDataFrom:GetBlueprint())
				unitNames[name] = getNameFromBp(unitToGetDataFrom:GetBlueprint())
			end
			
			if not unitsWorkedUpon[name] then
				unitsWorkedUpon[name] = {}
			end
			
			LOUDINSERT(unitsWorkedUpon[name], unitToGetDataFrom)
			
			consumptionTypes[name] = consType
			
			-- insert the unit as to be selected when the corresponding button is pressed
			if unitsToBeSelected[name] == nil then
				unitsToBeSelected[name] = {}
			end
			
			LOUDINSERT(unitsToBeSelected[name], unit)
		
			-- fill out the table that will be used to display the resource using units
			for dataType, unitTable in topUnitsData do
			
				if econData[dataType] != 0 then
					topUnitsData[dataType][name] = (topUnitsData[dataType][name] or 0) + econData[dataType]
				end
				
			end
			
		end
		
	end
	
	local dtIndex = 1
	
	for _, dataType in dataTypes do
	
		unitTable = topUnitsData[dataType]
		
		-- sort according to resource usage
		local sortedTable = {}
		
		for name, data in unitTable do
			LOUDINSERT(sortedTable,{name=name, data=data})
		end
		
		table.sort(sortedTable, function(a,b) return a.data > b.data end)
		
		-- hide all buttons
		for index = 1, maxImages do
			local button = grid[dtIndex][index]
			button:Hide()
		end
		
		for index, info in sortedTable do
		
			if index <= maxImages then
			
				local button = grid[dtIndex][index]
				
				-- setup the new tooltip
				local tooltipText
				
				if consumptionTypes[info.name] == CONSTRUCTION then
					tooltipText = "Select all units that are constructing " .. unitNames[info.name] .. "."
				else
					tooltipText = "Select units."
				end
				
				ToolTip.AddControlTooltip(button, {text=unitNames[info.name], body=tooltipText})
				
				-- assign units that will be selected when the button is clicked
				button.units = unitsToBeSelected[info.name]
				
				local unitWithMostProgress = nil
				local maxWorkProgress = -1
				
				for _, unit in unitsWorkedUpon[info.name] do
				
					if workProgressOnUnit[unit:GetEntityId()] > maxWorkProgress then
					
						maxWorkProgress = workProgressOnUnit[unit:GetEntityId()]
						unitWithMostProgress = unit
						
					end
					
				end
				
				if maxWorkProgress != 0 then
					button.progress:SetValue(maxWorkProgress)
					button.progress.Height:Set(3)
				else
					button.progress.Height:Set(0)
				end
				
				button.count:SetText(table.getsize(unitsToBeSelected[info.name]))
				
				-- display the income
				button.income:SetText("-" .. info.data)
				
				-- set the texture that corresponds to the unit
				local iconName1 = GameCommon.GetUnitIconPath(unitWithMostProgress:GetBlueprint())
				
				button.icon:SetTexture(iconName1)
				
				-- show the button
				button:Show()
				
				-- show the construction marker
				if consumptionTypes[info.name] == CONSTRUCTION then
					button.marker:Show()
				else
					button.marker:Hide()
				end
				
			end
			
		end
		
		dtIndex = dtIndex + 1
		
	end
	
end

function CreateModUI(isReplay, parent)

	local xPosition = 5
	local yPosition = 180
	
	grid = CreateGrid(parent, xPosition, yPosition, 2, maxImages, CreateGenericButton)
	
	local resourceIconHeight = 32
	
	local img = Bitmap(parent)
	
	img.Width:Set(resourceIconHeight/58 * 70)
	img.Height:Set(resourceIconHeight)
	img:SetTexture(UIUtil.UIFile('/game/resources/mass_btn_up.dds'))
	
	LayoutHelpers.CenteredAbove(img, grid[1][1], 0)
	
	local count = 1
	
	img.Update = function(self)
		print("OnUpdate".. count)
		count = count + 1
	end
	
	img.OnFrame = function(self)
		print("OnFrame".. count)
		count = count + 1
	end
	
	local img = Bitmap(parent)
	
	img.Width:Set(resourceIconHeight)
	img.Height:Set(resourceIconHeight)
	img:SetTexture(UIUtil.UIFile('/game/resources/energy_btn_up.dds'))
	
	LayoutHelpers.CenteredAbove(img, grid[2][1], 0)
	
	GameMain.AddBeatFunction(UpdateResourceUsage)
	
end