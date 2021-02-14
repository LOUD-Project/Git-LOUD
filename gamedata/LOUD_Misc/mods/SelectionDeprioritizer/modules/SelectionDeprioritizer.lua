local savedPrefs = nil
local isEnabled = true			-- starts enabled or not?
local filterAssisters = true	-- filter all assisters or not?
local filterDomains = true		-- filter by domain or not?
local filterExotics = true		-- filter by exotics or not?

local domainCategories = { "NAVAL", "LAND", "AIR" }
local exoticBlueprintIds = {} 
local exoticAssistBlueprintIds = {}

local logEnabled = false
function SDLOG(msg)
	if logEnabled then
		LOG("SELDEPRIO: "..msg)
	end
end

if logEnabled then
	LOG("Selection Deprioriziter Initializing..")
end

function setExoticBlueprintIds(ids)
	exoticBlueprintIds = ids
end

function setExoticAssistBlueprintIds(ids)
	exoticAssistBlueprintIds = ids
end

function setDomainCategories(cats)
	domainCategories = cats
end

function setSavedPrefs(prefs, verbose)
	savedPrefs = prefs
	isEnabled = savedPrefs['General']['isEnabled']
	filterAssisters = savedPrefs['General']['filterAssisters'] and isEnabled
	filterDomains = savedPrefs['General']['filterDomains'] and isEnabled
	filterExotics = savedPrefs['General']['filterExotics'] and isEnabled
end

function arrayContains(arr, val)
	for _, v in ipairs(arr) do
		if v == val then 
			return true
		end
	end
	return false
end

function isExotic(unit)
	local blueprintId = unit:GetBlueprint().BlueprintId
	local isEx = arrayContains(exoticBlueprintIds, blueprintId)
	SDLOG(blueprintId .. " = " .. tostring(isEx))
	return isEx
end

function isExoticAssist(unit)
	local blueprintId = unit:GetBlueprint().BlueprintId
	local isExAs = arrayContains(exoticAssistBlueprintIds, blueprintId)
	SDLOG(blueprintId .. " = " .. tostring(isExAs))
	return isExAs
end

function isMixedExoticness(units)
	local exoticFound
	local regularFound
	for entityid, unit in units do
		local isEx = isExotic(unit)
		local isExAs = isExoticAssist(unit) 
		if isEx or isExAs then
			exoticFound = true
		else
			regularFound = true
		end
	end

	return exoticFound and regularFound
end

function isAssisting(unit)
	local guardedUnits = unit:GetGuardedEntity()
	return guardedUnits ~= nil
end

function filterToRegulars(units)
	local filtered = {}
	local changed = false
	for id, unit in units do
		local isEx = isExotic(unit)
		local isExAs = isExoticAssist(unit)
		if isExAs then
			isExAs = isAssisting(unit)
		end
		
		if not isEx and not isExAs then
			table.insert(filtered, unit)
		else
			changed = true
		end
	end
	return filtered, changed
end

function getDomain(unit)	
	for i, domain in ipairs(domainCategories) do
		if unit:IsInCategory(domain) then 
			return domain
		end
	end
end

function getDomains(units)
	local domains = {}
	for entityid, unit in units do
		local domain = getDomain(unit)		
		if domain ~= nil then 
			domains[domain] = true
		end
	end

	domains.count = 0
	for i, domain in ipairs(domainCategories) do
		if domains[domain] ~= nil then 
			domains.count = domains.count + 1
		end
	end

	domains.isMixed = domains.count > 1

	return domains
end

function getFirstDomain(domains)
	for i, domain in ipairs(domainCategories) do
		if domains[domain] ~= nil then 
			return domain
		end
	end
	return nil
end

function filterToDomain(units, requiredDomain)
	local filtered = {}
	local changed = false
	for id, unit in units do
		local domain = getDomain(unit)
		if domain == requiredDomain then
			table.insert(filtered, unit)
		else
			changed = true
		end
	end
	return filtered, changed
end

local dblClickStart = false
local dblClickUnit = nil
function isDoubleclick(selection)
	-- a double click is if
	--   the first click is just one unit
	--   and the second click contains the same unit

	local result = false
	if dblClickStart then
		dblClickStart = false
		for index, unit in selection do
			if unit == dblClickUnit then
				SDLOG("Double Click")
				result = true
			end
		end
	end

	dblClickStart = table.getn(selection) == 1
	if dblClickStart then
		SDLOG("Double Click start?")
		for index, unit in selection do
			dblClickUnit = unit
		end
	end

	return result
end

function filterToNonAssisters(selection)
	local changed = false
	local filtered = {}

	-- if its a double click on an assister, select all fellow assisters
	if isDoubleclick(selection) and dblClickUnit:GetGuardedEntity() then
		SDLOG("-- double click detected")

		for index, unit in selection do
			local isSame = unit:GetGuardedEntity() == dblClickUnit:GetGuardedEntity()

			if isSame then
				SDLOG("found a brother")
				table.insert(filtered,unit)
			else
				changed = true
				SDLOG("didnt find brother")
			end
		end
	else
		if selection and table.getn(selection) > 1 then
			local guardedUnit = selection[1]:GetGuardedEntity()
			local allSame = true
			for index, unit in selection do
				if unit:GetGuardedEntity() then
					SDLOG("found assister")
					if unit:GetGuardedEntity() != guardedUnit then
						allSame = false
					end
					changed = true
				else
					allSame = false
					SDLOG("not an assister")
					table.insert(filtered,unit)
				end
			end

			if allSame then
				changed = false
			end
		end
	end

	if changed then
		return filtered, changed
	else
		return selection, false
	end
end

function Deselect(selection)

	if IsKeyDown('Shift') then
		return selection, false
	end

	local changed, domainChanged, exoticChanged, assistersChanged

	if filterDomains then 
		local domains = getDomains(selection)
		if domains.isMixed then
			SDLOG("Mixed Domains")
			domain = getFirstDomain(domains)
			if domain ~= nil then 
				SDLOG("limit to " .. domain)
				selection, domainChanged = filterToDomain(selection, domain)
			end
		else
			SDLOG("Not Mixed Domains")
		end
	end

	if filterExotics then
		local isMixedExotic = isMixedExoticness(selection)
		if isMixedExotic then
			SDLOG("Mixed Exotic")
			selection, exoticChanged = filterToRegulars(selection)
		else
			SDLOG("Not Mixed Exotic")
		end
	end

	if filterAssisters then
		SDLOG("Filter Assisters")
		selection, assistersChanged = filterToNonAssisters(selection)
	end

	changed = domainChanged or exoticChanged or assistersChanged

	return selection, changed
end

-- if shift do nothing
-- selection contains mixed domains - filter to one domain
-- selection contains mix of exotics and regulars - filter to regulars
