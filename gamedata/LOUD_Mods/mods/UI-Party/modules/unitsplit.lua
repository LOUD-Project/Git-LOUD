local LINQ = import('/mods/UI-Party/modules/linq.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local UnitLock = import('/mods/ui-party/modules/unitlock.lua')

local selectionsClearGroupCycle = true
local lastSelectedGroup
local groups

function GetAveragePoint(units)
	local x = LINQ.Average(units, function(k, v) return v:GetPosition()[1] end)
	local y = LINQ.Average(units, function(k, v) return v:GetPosition()[2] end)
	local z = LINQ.Average(units, function(k, v) return v:GetPosition()[3] end)
	local pos = { x, y, z }
	return pos
end

function GetPriorityUnits(ungroupedUnits)
	local maxVal = LINQ.Max(ungroupedUnits, function(k, v) return v:GetBlueprint().Economy.BuildCostMass end)
	return LINQ.Where(ungroupedUnits, function(k, v) return v:GetBlueprint().Economy.BuildCostMass == maxVal end)
end

function FindUnitFurtherestFromAllPoints(units, avoidancePoints)
	local bestD = -1
	local bestU = nil

	for _, uv in units do
		local thisUnitClosestPoint = 10000
		for _, pv in avoidancePoints do
			local d = VDist3(uv:GetPosition(), pv)
			if d < thisUnitClosestPoint then
				thisUnitClosestPoint = d
			end
		end

		if thisUnitClosestPoint > bestD then
			bestD = thisUnitClosestPoint
			bestU = uv
		end
	end

	return bestU;
end

function FindNearestToGroup(units, groups)
	local bestD = 10000
	local bestU
	local bestG

	for _, uv in units do
		for _, gv in groups do
			local d = VDist3(uv:GetPosition(), gv.Center)
			if d < bestD then
				bestD = d
				bestU = uv
				bestG = gv
			end
		end
	end
	local result = {Unit = bestU, Group = bestG}
	return result
end

function FindNearestToPos(groups, pos)
	local bestD = 10000
	local bestG

	for _, gv in groups do
		local d = VDist3(gv.Center, pos)
		if d < bestD then
			bestD = d
			bestG = gv
		end
	end
	return bestG
end

function SplitGroups(desiredGroups)
	local selection = GetSelectedUnits()
	if selection == nil then
		return nil
	end
	local ungroupedUnits = {}
	for k, v in selection do
		ungroupedUnits[k] = v
	end
	if ungroupedUnits == nil then return end

	local avg = GetAveragePoint(ungroupedUnits)
	groups = {}

	-- START A GROUP
	local priorityUnits = {}
	while table.getn(groups) < desiredGroups do
		if not LINQ.Any(priorityUnits) then priorityUnits = GetPriorityUnits(ungroupedUnits) end
		if not LINQ.Any(priorityUnits) then
			-- UIPLOG("Not enough units to make another group")
			break
		end

		local avoidancePoints = { avg }
		if Any(groups) then
			avoidancePoints = LINQ.Select(groups, function(k, v) return v.Center end)
		end

		local unit = FindUnitFurtherestFromAllPoints(priorityUnits, avoidancePoints)

		LINQ.RemoveByValue(ungroupedUnits, unit)
		LINQ.RemoveByValue(priorityUnits, unit)

		local group = {}
		group.Name = LINQ.Count(groups) + 1
		group.Center = unit:GetPosition()
		group.Units = { unit }
		table.insert(groups, group)
	end

	-- SHUNK UNITS INTO GROUPS
	while Any(ungroupedUnits) do
		local nextGroups = LINQ.Copy(groups)

		while Any(ungroupedUnits) and Any(nextGroups) do

			if not Any(priorityUnits) then priorityUnits = GetPriorityUnits(ungroupedUnits) end
			local t = FindNearestToGroup(priorityUnits, nextGroups)

			LINQ.RemoveByValue(nextGroups, t.Group)

			table.insert(t.Group.Units, t.Unit)
			t.Group.Center = GetAveragePoint(t.Group.Units);
		end
	end

	-- REORDER GROUPS TO BE NEAR MOUSE
	-- (annoying bug here where very different position if you slightly move
	-- mouse before/after end-drag)
	local sortedGroups = {}
	local mpos = GetMouseWorldPos()
	while LINQ.Any(groups) do
		local best = FindNearestToPos(groups, mpos)
		LINQ.RemoveByValue(groups, best)
		table.insert(sortedGroups, best)
	end
	groups = sortedGroups
	local gnum = 1
	for _, gv in groups do
		gv.Name = gnum
		gnum = gnum + 1
	end

	SelectGroup(LINQ.First(groups).name)
end

function DontClearCycle(a)
	selectionsClearGroupCycle = false
	a()
	selectionsClearGroupCycle = true
end

function SelectGroup(name, appendToExistingSelection)
	if name > LINQ.Count(groups) then
		UIP.PlayErrorSound()
		name = 1
	end
	if name < 1 then
		UIP.PlayErrorSound()
		name = LINQ.Count(groups)
	end

	local group = groups[name]
	lastSelectedGroup = group
	if group == nil then return end

	DontClearCycle(function()
		local newSelection = group.Units

		if appendToExistingSelection then
			newSelection = table.concat(newSelection, GetSelectedUnits())
		end

		SetSelectedUnits(LINQ.ToArray(newSelection))
	end)
end

function SetSelectedUnits(units)
	UnitLock.IgnoreLocksWhile(function()
		SelectUnits(units)
	end)
end

function SelectNextGroup()
	if lastSelectedGroup ~= nil then
		local appendToExistingSelection = IsKeyDown("Shift")
		SelectGroup(lastSelectedGroup.Name + 1, appendToExistingSelection)
	else
		SplitGroups(100)
	end
end

function ReselectSplitUnits()
	local units = {}
	for _, v in groups do
		units = table.concat(units, v.Units)
	end
	SetSelectedUnits(LINQ.ToArray(units))
end

function ReselectOrderedSplitUnits()
	local units = {}
	for _, v in groups do
		if v.Name <= lastSelectedGroup.Name then
			units = table.concat(units, v.Units)
		end
	end
	SetSelectedUnits(LINQ.ToArray(units))
end

function SelectPrevGroup()
	if lastSelectedGroup ~= nil then
		SelectGroup(lastSelectedGroup.Name - 1)
	else
		SplitGroups(100)
	end
end

function SelectionChanged()
	if selectionsClearGroupCycle then
		lastSelectedGroup = nil
	end
end

function SelectNextLandUnitsGroupByRole()
	if lastSelectedGroup ~= nil then
		local appendToExistingSelection = IsKeyDown("Shift")
		SelectGroup(lastSelectedGroup.Name + 1, appendToExistingSelection)
	else
		SplitLandUnitsByRole()
	end
end

function SplitLandUnitsByRole()
	local units = GetSelectedUnits()
	if units == nil or table.getn(units) == 0 then
		ConExecute("Ui_SelectByCategory +inview MOBILE LAND")
	end

	local groupDefns = {
		{
		  Name = 1,
		  testFn= function(u)
			return u:IsInCategory("DIRECTFIRE") and not u:IsInCategory("ENGINEER") and not u:IsInCategory("SCOUT") and not u:IsInCategory("del0204") and not u:IsInCategory("drl0204") and not u:IsInCategory("xrl0302") -- mongoose and hoplite and firebeetle
		  end,
		  Units = {}
		},
		{
		  Name = 2,
		  testFn= function(u)
			return u:IsInCategory("INDIRECTFIRE") or u:IsInCategory("del0204") or u:IsInCategory("drl0204") -- mongoose and hoplite
		  end,
		  Units = {}
		},
		{
		  Name = 3,
		  testFn= function(u)
			return not u:IsInCategory("ENGINEER") and (not u:IsInCategory("DIRECTFIRE") or u:IsInCategory("SCOUT") or u:IsInCategory("xrl0302")) -- fire beetle
		  end,
		  Units = {}
		}
	}

	-- Give lock a chance to run
	ForkThread(function()
		units = GetSelectedUnits()

		for _, uv in units do
			local found = false
			for _, gv in groupDefns do
				if (not found and gv.testFn(uv)) then
					table.insert(gv.Units, uv)
					found = true
				end
			end
		end

		local nonEmptyGroups = {}
		for _, gv in groupDefns do
			if (gv.Units.any()) then
				table.insert(nonEmptyGroups, gv)
			end
		end

		groups = nonEmptyGroups
		if (groups.any()) then
			SelectGroup(groups.first().Name)
		else
			SelectUnits({})
		end

	end)
end