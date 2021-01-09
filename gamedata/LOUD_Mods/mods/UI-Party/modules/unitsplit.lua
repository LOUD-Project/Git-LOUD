local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local UnitLock = import('/mods/ui-party/modules/unitlock.lua')

local selectionsClearGroupCycle = true
local lastSelectedGroup
local groups

function GetAveragePoint(units)

	local x = units.avg(function(k,v) return v:GetPosition()[1] end)
	local y = units.avg(function(k,v) return v:GetPosition()[2] end)
	local z = units.avg(function(k,v) return v:GetPosition()[3] end)
	local pos = { x, y, z}
	return pos
end

function GetPriorityUnits(ungroupedUnits)
	local maxVal = ungroupedUnits.max(function(k,v) return v:GetBlueprint().Economy.BuildCostMass end)
	return ungroupedUnits.where(function(k,v) return v:GetBlueprint().Economy.BuildCostMass == maxVal end)
end

function FindUnitFurtherestFromAllPoints(units, avoidancePoints)
	local bestD = -1
	local bestU = nil
	units.foreach(function(uk,uv)
		local thisUnitClosestPoint = 10000
		avoidancePoints.foreach(function(pk,pv)
			local d = VDist3(uv:GetPosition(), pv)
			if d < thisUnitClosestPoint then
				thisUnitClosestPoint = d
			end
		end)

		if thisUnitClosestPoint > bestD then
			bestD = thisUnitClosestPoint
			bestU = uv
		end
	end)

	return bestU;
end

 function FindNearestToGroup(units, groups)
	local bestD = 10000
	local bestU
	local bestG
	units.foreach(function(uk,uv)
		groups.foreach(function(gk,gv)
			local d = VDist3(uv:GetPosition(), gv.Center)
			if d < bestD then
				bestD = d
				bestU = uv
				bestG = gv
			end
		end)
	end)
	local result = {Unit = bestU, Group = bestG}
	return result
end

function FindNearestToPos(groups, pos)
	local bestD = 10000
	local bestG
	groups.foreach(function(gk,gv)
		local d = VDist3(gv.Center, pos)
		if d < bestD then
			bestD = d
			bestG = gv
		end
	end)
	return bestG
end

function SplitGroups(desiredGroups)
	local selection = GetSelectedUnits()
	if selection == nil then
		return nil
	end
	local ungroupedUnits = from(selection).copy()
	if ungroupedUnits == nil then return end

	local avg = GetAveragePoint(ungroupedUnits)
	groups = from({})

	-- START A GROUP
	local priorityUnits = from({})
	while groups.count() < desiredGroups do
		if not priorityUnits.any() then priorityUnits = GetPriorityUnits(ungroupedUnits) end
		if not priorityUnits.any() then
			UIPLOG("Not enough units to make another group'")
			break
		end

		local avoidancePoints = from({ avg })
		if groups.any() then
			avoidancePoints = groups.select(function(k,v) return v.Center end)
		end

		local unit = FindUnitFurtherestFromAllPoints(priorityUnits, avoidancePoints)

		ungroupedUnits.removeByValue(unit)
		priorityUnits.removeByValue(unit)

		local group = {}
		group.Name = groups.count()+1
		group.Center = unit:GetPosition()
		group.Units = from({ unit })
		groups.addValue(group);
	end


	-- SHUNK UNITS INTO GROUPS
	while ungroupedUnits.any() do

		local nextGroups = groups.copy()

		while ungroupedUnits.any() and nextGroups.any() do

			if not priorityUnits.any() then priorityUnits = GetPriorityUnits(ungroupedUnits) end
			local t = FindNearestToGroup(priorityUnits, nextGroups)

			nextGroups.removeByValue(t.Group)

			ungroupedUnits.removeByValue(t.Unit)
			priorityUnits.removeByValue(t.Unit)

			t.Group.Units.addValue(t.Unit)
			t.Group.Center = GetAveragePoint(t.Group.Units);
		end
	end

	-- REORDER GROUPS TO BE NEAR MOUSE (annoying bug here where very different position if you slightly move mouse before/after end-drag)
	local sortedGroups = from({})
	local mpos = GetMouseWorldPos()
	while groups.any() do
		local best = FindNearestToPos(groups, mpos)
		groups.removeByValue(best)
		sortedGroups.addValue(best)
	end
	groups = sortedGroups
	local gnum = 1
	groups.foreach(function(gk, gv)
		gv.Name = gnum
		gnum = gnum + 1
	end)

	SelectGroup(groups.first().Name)

end


function DontClearCycle(a)
	selectionsClearGroupCycle = false
	a()
	selectionsClearGroupCycle = true
end

function SelectGroup(name, appendToExistingSelection)
	if name > groups.count() then
		UIP.PlayErrorSound()
		name = 1
	end
	if name < 1 then
		UIP.PlayErrorSound()
		name = groups.count()
	end

	local group = groups.get(name)
	lastSelectedGroup = group
	if group == nil then return end

	DontClearCycle(function()
		local newSelection = group.Units

		if appendToExistingSelection then
			newSelection = newSelection
				.concat(from(GetSelectedUnits()))
		end

		SetSelectedUnits(newSelection.toArray())
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
	local units = from({})
	groups.foreach(function(k,v)
		units = units.concat(v.Units)
	end)
	SetSelectedUnits(units.toArray())
end

function ReselectOrderedSplitUnits()
	local units = from({})
	groups.foreach(function(k,v)
		if v.Name <= lastSelectedGroup.Name then
			units = units.concat(v.Units)
		end
	end)
	SetSelectedUnits(units.toArray())
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
		  Units = from({})
		},
		{
		  Name = 2,
		  testFn= function(u)
			return u:IsInCategory("INDIRECTFIRE") or u:IsInCategory("del0204") or u:IsInCategory("drl0204") -- mongoose and hoplite
		  end,
		  Units = from({})
		},
		{
		  Name = 3,
		  testFn= function(u)
			return not u:IsInCategory("ENGINEER") and (not u:IsInCategory("DIRECTFIRE") or u:IsInCategory("SCOUT") or u:IsInCategory("xrl0302")) -- fire beetle
		  end,
		  Units = from({})
		}
	};

	-- Give lock a chance to run
	ForkThread(function()
		units = GetSelectedUnits()

		from(units).foreach(function(uk,uv)
			local found = false
			for gk, gv in groupDefns do
				if (not found and gv.testFn(uv)) then
					gv.Units.addValue(uv)
					found = true
				end
			end
		end);

		local nonEmptyGroups = from({})
		for gk, gv in groupDefns do
			if (gv.Units.any()) then
				nonEmptyGroups.addValue(gv)
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