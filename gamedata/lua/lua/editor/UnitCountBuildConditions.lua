--  /lua/editor/UnitCountBuildConditions.lua
--  AI Platoon Build Conditions

local import = import

local AIFindBrainTargetAroundPoint = import('/lua/ai/aiutilities.lua').AIFindBrainTargetAroundPoint

local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
local GetNumberOfOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetNumberOfOwnUnitsAroundPoint

local AIFindBaseAreaForExpansion = import('/lua/ai/altaiutilities.lua').AIFindBaseAreaForExpansion
local AIFindBaseAreaForDP = import('/lua/ai/altaiutilities.lua').AIFindBaseAreaForDP
local AIFindDefensivePointForDP = import('/lua/ai/altaiutilities.lua').AIFindDefensivePointForDP
local AIFindDefensivePointNeedsStructure = import('/lua/ai/altaiutilities.lua').AIFindDefensivePointNeedsStructure
local AIFindExpansionPointNeedsStructure = import('/lua/ai/altaiutilities.lua').AIFindExpansionPointNeedsStructure
local AIFindStartPointNeedsStructure = import('/lua/ai/altaiutilities.lua').AIFindStartPointNeedsStructure
local AIFindBasePointNeedsStructure = import('/lua/ai/altaiutilities.lua').AIFindBasePointNeedsStructure
local AIFindNavalAreaForExpansion = import('/lua/ai/altaiutilities.lua').AIFindNavalAreaForExpansion
local AIFindNavalDefensivePointNeedsStructure = import('/lua/ai/altaiutilities.lua').AIFindNavalDefensivePointNeedsStructure

local NumCatUnitsInArea = import('/lua/scenarioframework.lua').NumCatUnitsInArea
local AreaToRect = import('/lua/sim/scenarioutilities.lua').AreaToRect

local GetCurrentUnits = moho.aibrain_methods.GetCurrentUnits
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint

local PlatoonCategoryCount = moho.platoon_methods.PlatoonCategoryCount
local PlatoonCategoryCountAroundPosition = moho.platoon_methods.PlatoonCategoryCountAroundPosition

local LOUDENTITY = EntityCategoryContains
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDPARSE = ParseEntityCategory
local LOUDTYPE = type
local VDist3 = VDist3

function PreBuiltBase(aiBrain)
	return aiBrain.PreBuilt
end

function NotPreBuilt(aiBrain)
	return not aiBrain.PreBuilt
end

function HaveGreaterThanUnitsWithCategory(aiBrain, numReq, testCat, idleReq)

	return GetCurrentUnits(aiBrain,testCat) > numReq
end

function HaveLessThanUnitsWithCategory(aiBrain, numReq, testCat, idleReq)

    return GetCurrentUnits(aiBrain,testCat) < numReq
end

function HaveLessThanUnitsAsPercentageOfUnitCap(aiBrain, Percentage, testCat, idleReq)

	local numReq = GetArmyUnitCap(aiBrain.ArmyIndex) * (Percentage/100)

    return GetCurrentUnits(aiBrain,testCat) < numReq
end

function HaveLessThanUnitsForMapSize(aiBrain, sizetable, testCat, idleReq)
	
    -- use the largest map dimension to determine which size selection we'll use for the number required
	local numReq = math.max(sizetable[ScenarioInfo.size[1]], sizetable[ScenarioInfo.size[2]])
	
    return GetCurrentUnits(aiBrain,testCat) < numReq
end

function ExistingBasesHaveGreaterThanFactory( aiBrain, basetype, numReq, category )

	for k,v in aiBrain.BuilderManagers do
	
		if (basetype == 'All' or basetype == v.BaseType) and v.FactoryManager.FactoryList and v.CountedBase then

			if numReq > EntityCategoryCount( category, v.FactoryManager.FactoryList ) then
				return false
			end	
		end
	end

	return true
end

function HaveLessThanUnitsInCategoryBeingBuilt(aiBrain, numunits, category)

	local LOUDENTITY = EntityCategoryContains
	
    local unitlist = GetListOfUnits(aiBrain, categories.CONSTRUCTION, false )
	local numBuilding = 0
	
    for _,unit in unitlist do
	
        if not unit.Dead and unit:IsUnitState('Building') then
		
            if unit.UnitBeingBuilt and not unit.UnitBeingBuilt.Dead and LOUDENTITY( category, unit.UnitBeingBuilt ) then
				numBuilding = numBuilding + 1	
            end
        end

		-- hmm -- seems odd that we would test construction units that are NOT in a building state - but we do
		-- this was likely to be a test of the engineers build queue
		
		if not unit.Dead and not unit:IsUnitState('Building') then

            if unit.UnitBeingBuilt and not unit.UnitBeingBuilt.Dead and LOUDENTITY( category, unit.UnitBeingBuilt ) then
				numBuilding = numBuilding + 1	
            end
		end

		-- exit as soon as we pass the trigger
		if numBuilding > numunits then
			return false
		end
    end
    
	return true
end

--  Base Area Needs Engineer -- used on both Start and Expansion markers
-- returns true if there is an available position
function BaseAreaForExpansion( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType )

    if AIFindBaseAreaForExpansion( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType) then
	
        return true
    end
	
    return false
end

-- used to find start and Expansion markers that may be taken already
function BaseAreaForDP( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType )

    if AIFindBaseAreaForDP( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType) then
	
        return true
    end
	
    return false
end

-- used to find available Active DP positions
function DefensivePointForExpansion( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType )

    if AIFindDefensivePointForDP( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType) then
	
        return true
    end
	
    return false
end

-- used to find available Naval Area positions
function NavalAreaForExpansion( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType )

	if AIFindNavalAreaForExpansion( aiBrain, locationType, locationRadius, threatMin, threatMax, threatRings, threatType) then
        return true
    end
    
    return false
end

function DefensivePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )

    if AIFindDefensivePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType ) then
        return true
    end
    
    return false    
end

function NavalDefensivePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )

    if AIFindNavalDefensivePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType ) then
        return true
    end
    
    return false    
end

function ExpansionPointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )

    if AIFindExpansionPointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType ) then
        return true
    end
    
    return false    
end

function StartingPointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )
    
    if AIFindStartPointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType ) then
        return true
    end
    
    return false    
end

function BasePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )
    
    if AIFindBasePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType ) then
        return true
    end
    
    return false    
end

function UnitsLessAtLocation( aiBrain, locationType, unitCount, testCat )

	if aiBrain.BuilderManagers[locationType].EngineerManager then
		return GetNumUnitsAroundPoint( aiBrain, testCat, aiBrain.BuilderManagers[locationType].Position, aiBrain.BuilderManagers[locationType].EngineerManager.Radius, 'Ally') < unitCount
	end
    
	return false
end

function UnitsLessAtLocationInRange( aiBrain, locationType, unitCount, testCat, rangemin, rangemax)

	if aiBrain.BuilderManagers[locationType].EngineerManager.Active then

		local managerposition = aiBrain.BuilderManagers[locationType].Position
		local numUnits = 0
		
		local units = GetUnitsAroundPoint( aiBrain, testCat, managerposition, rangemax, 'Ally' )
		
		local rangetest = rangemin * rangemin
        
		for _, v in units do
			local pos = v:GetPosition()
			if VDist2Sq( managerposition[1],managerposition[3], pos[1],pos[3] ) >= rangetest then
				numUnits = numUnits + 1
			end
		end
		return numUnits < unitCount
	end
    
	return false
end

function UnitsGreaterAtLocation( aiBrain, locationType, unitCount, testCat )

	if aiBrain.BuilderManagers[locationType].EngineerManager then
		return GetNumUnitsAroundPoint( aiBrain, testCat, aiBrain.BuilderManagers[locationType].Position, aiBrain.BuilderManagers[locationType].EngineerManager.Radius, 'Ally') > unitCount
	end
    
	return false
end

function UnitsGreaterAtLocationInRange( aiBrain, locationType, unitCount, testCat, rangemin, rangemax)

	if aiBrain.BuilderManagers[locationType].EngineerManager then
	
		local managerposition = aiBrain.BuilderManagers[locationType].Position
		local numUnits = 0
		
		local units = GetUnitsAroundPoint( aiBrain, testCat, managerposition, rangemax, 'Ally' )
		
		local rangetest = rangemin * rangemin
        
		for _, v in units do
			local pos = v:GetPosition()
			if VDist2Sq( managerposition[1],managerposition[3], pos[1],pos[3] ) >= rangetest then
				numUnits = numUnits + 1
			end
		end
        
		return numUnits > unitCount
	end
    
	return false
end

function HaveGreaterThanUnitsWithCategoryAndAlliance(aiBrain, numReq, testCat, alliance)
	return GetNumUnitsAroundPoint( aiBrain, testCat, Vector(0,0,0), 999999, alliance ) > numReq
end

function HaveLessThanUnitsWithCategoryAndAlliance(aiBrain, numReq, testCat, alliance)
	return GetNumUnitsAroundPoint( aiBrain, testCat, Vector(0,0,0), 999999, alliance ) < numReq
end

function PoolLess( aiBrain, unitCount, testCat)
	return PlatoonCategoryCount( aiBrain.ArmyPool, testCat ) < unitCount
end

function PoolGreater( aiBrain, unitCount, testCat)
	return PlatoonCategoryCount( aiBrain.ArmyPool, testCat ) > unitCount
end

function PoolLessAtLocation( aiBrain, locationType, unitCount, testCat)

    local numUnits = PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, testCat, aiBrain.BuilderManagers[locationType].Position, aiBrain.BuilderManagers[locationType].Radius)
	
	if numUnits > 0 then
	
		local engbeingbuilt = aiBrain.BuilderManagers[locationType].EngineerManager:GetNumCategoryBeingBuilt(testCat, categories.ENGINEER)
		local facbeingbuilt = aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryBeingBuilt(testCat, categories.FACTORY)
	
		numUnits = numUnits - (engbeingbuilt + facbeingbuilt)
		
		return numUnits < unitCount
	end
    
	return true
end

function PoolGreaterAtLocation( aiBrain, locationType, unitCount, testCat)

	if aiBrain.BuilderManagers[locationType] != nil then

		local numUnits = PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, testCat, aiBrain.BuilderManagers[locationType].Position, aiBrain.BuilderManagers[locationType].Radius)

		local engbeingbuilt = aiBrain.BuilderManagers[locationType].EngineerManager:GetNumCategoryBeingBuilt(testCat, categories.ENGINEER)
		local facbeingbuilt = aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryBeingBuilt(testCat, categories.FACTORY)
	
		return numUnits - (engbeingbuilt + facbeingbuilt) > unitCount
	end
    
	return false
end

function EngineerLessAtLocation( aiBrain, locationType, unitCount, testCat)
	return EntityCategoryCount( testCat, aiBrain.BuilderManagers[locationType].EngineerManager.EngineerList ) < unitCount
end

function EngineerGreaterAtLocation( aiBrain, locationType, unitCount, testCat)
	return EntityCategoryCount( testCat, aiBrain.BuilderManagers[locationType].EngineerManager.EngineerList ) > unitCount
end

-- I add these two functions to simplify the task of getting an
-- overall factory count to augment the functions that allow you
-- to get a similar count but only at a specific location
function FactoriesGreaterThan( aiBrain, unitCount, testCat )

	local result = 0
	
	for k,v in aiBrain.BuilderManagers do
		result = result + EntityCategoryCount( testCat, v.FactoryManager.FactoryList )
	end
    
	return result > unitCount
end

function FactoriesLessThan( aiBrain, unitCount, testCat )

	local result = 0
	
	for k,v in aiBrain.BuilderManagers do
		result = result + EntityCategoryCount( testCat, v.FactoryManager.FactoryList )
	end
    
	return result < unitCount
end

function FactoryLessAtLocation( aiBrain, locationType, unitCount, testCat)
	return EntityCategoryCount( testCat, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) < unitCount
end

function FactoryGreaterAtLocation( aiBrain, locationType, unitCount, testCat)
	return EntityCategoryCount( testCat, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) > unitCount	
end

function FactoryRatioGreaterOrEqualAtLocation( aiBrain, locationType, unitCategory, unitCategory2)
    return aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryFactories(unitCategory) >= aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryFactories(unitCategory2)
end

function FactoryRatioLessAtLocation( aiBrain, locationType, unitCategory, unitCategory2)
    return aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryFactories(unitCategory) < aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryFactories(unitCategory2)
end

function FactoryRatioGreaterAtLocation( aiBrain, locationType, unitCategory, unitCategory2)
    return aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryFactories(unitCategory) > aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryFactories(unitCategory2)
end

function BuildingLessAtLocation( aiBrain, locationType, unitCount, testCat, builderCat)
	return aiBrain.BuilderManagers[locationType].PlatoonFormManager:GetNumberOfUnitsBeingBuilt( aiBrain, testCat, builderCat or categories.ALLUNITS) < unitCount
end

function BuildingGreaterAtLocation( aiBrain, locationType, unitCount, testCat, builderCat)
	return aiBrain.BuilderManagers[locationType].PlatoonFormManager:GetNumberOfUnitsBeingBuilt( aiBrain, testCat, builderCat or categories.ALLUNITS)  > unitCount
end

function BuildingGreaterAtLocationAtRange( aiBrain, locationType, unitCount, testCat, builderCat, range)
	return aiBrain.BuilderManagers[locationType].PlatoonFormManager:GetNumberOfUnitsBeingBuilt( aiBrain, testCat, builderCat or categories.ALLUNITS, range)  > unitCount
end

function LocationFactoriesBuildingLess( aiBrain, locationType, unitCount, testCat, facCat)
    return aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryBeingBuilt(testCat, facCat or categories.FACTORY) < unitCount
end

function LocationFactoriesBuildingGreater( aiBrain, locationType, unitCount, testCat, facCat)
    return aiBrain.BuilderManagers[locationType].FactoryManager:GetNumCategoryBeingBuilt(testCat, facCat or categories.FACTORY) > unitCount
end

-- is there an engineer, at this base, building unitCategory, needing assistance, within unitRange of the base
function LocationEngineerNeedsBuildingAssistanceInRange( aiBrain, locationType, unitCategory, engCat, unitRange )

	local LOUDGETN = table.getn
	local VDist2 = VDist2

    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    local engineerManagerPos = aiBrain.BuilderManagers[locationType].Position
    
	local engUnits = nil
	local numUnits = 0
	
	if engineerManager.Active then
		-- find all the engineers in this base, of this engCat, building something in unitCategory
    	engUnits = engineerManager:GetEngineersWantingAssistanceWithBuilding( unitCategory, engCat )
		numUnits = LOUDGETN(engUnits)
	end
	
	-- if there are units lets range check
	if numUnits > 0 then

		for _,v in engUnits do
		
			if VDist2( engineerManagerPos[1], engineerManagerPos[3], v:GetPosition()[1], v:GetPosition()[3] ) <= unitRange then
			
				return true
			end
		end
	end
	
    return false
end

function FactoryCapCheck(aiBrain, locationType, factoryType)

    local catCheck = false
	
    if factoryType == 'LAND' then
        catCheck = categories.LAND * categories.FACTORY * categories.STRUCTURE
    elseif factoryType == 'AIR' then
        catCheck = categories.AIR * categories.FACTORY * categories.STRUCTURE
    elseif factoryType == 'SEA' then
        catCheck = categories.NAVAL * categories.FACTORY * categories.STRUCTURE
    elseif factoryType == 'GATE' then
        catCheck = categories.GATE
    else
        WARN('*AI WARNING: Invalid factorytype - ' .. factoryType)
        return false
    end
	
    local factoryManager = aiBrain.BuilderManagers[locationType].FactoryManager
	local numUnits = 0
	
	if factoryManager.Active == true then
		-- this should give you the total number of factories at this location
		numUnits = factoryManager:GetNumCategoryFactories(catCheck)

		local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager

		numUnits = numUnits + engineerManager:GetNumCategoryBeingBuilt( catCheck, categories.ALLUNITS )
	end

    if numUnits < aiBrain.BuilderManagers[locationType].BaseSettings.FactoryCount[factoryType] then
		return true
	end
	
    return false
end

function BelowEngineerCapCheck(aiBrain, locationType, techLevel)

    local catCheck = false
    local capmult = 500     -- for every 500 units add 1
    local caplimit = 1
	
    if techLevel == 'Tech1' then
	
        catCheck = categories.TECH1
		
    elseif techLevel == 'Tech2' then
	
        catCheck = categories.TECH2
        capmult = 300
        caplimit = 3
		
    elseif techLevel == 'Tech3' then
	
        catCheck = categories.TECH3
        capmult = 250
        caplimit = 5
		
    elseif techLevel == 'SCU' then
	
        catCheck = categories.SUBCOMMANDER
        capmult = 200
        caplimit = 10
		
    else
	
        WARN('*AI WARNING: Invalid techLevel - ' .. techLevel)
        return false
    end
	
	local capCheck = aiBrain.BuilderManagers[locationType].BaseSettings.EngineerCount[techLevel]

    -- always use the largest value - so even if the cheat level is less than 1 - we'll have the usual number of engineers
    capCheck = math.max(capCheck, math.floor(capCheck * ((aiBrain.CheatValue) * (aiBrain.CheatValue))))

	if aiBrain.StartingUnitCap > 1000 then
	
        -- at 1000+ units add 1 engineer for every capmult - up to the cap limit --
		capCheck = capCheck + math.min( 1 + math.floor(( aiBrain.StartingUnitCap - 1000) / capmult ), caplimit)
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Engineer "..repr(techLevel).." at "..repr(locationType).." is "..capCheck)
	end

	return EntityCategoryCount( catCheck, aiBrain.BuilderManagers[locationType].EngineerManager.EngineerList ) < capCheck
end

function AboveEngineerCapCheck(aiBrain, locationType, techLevel)

    local catCheck = false
    local capmult = 500
	
    if techLevel == 'Tech1' then
	
        catCheck = categories.TECH1
		
    elseif techLevel == 'Tech2' then
	
        catCheck = categories.TECH2
        capmult = 300
		
    elseif techLevel == 'Tech3' then
	
        catCheck = categories.TECH3
        capmult = 250
		
    elseif techLevel == 'SCU' then
	
        catCheck = categories.SUBCOMMANDER
        capmult = 200
		
    else
	
        WARN('*AI WARNING: Invalid techLevel - ' .. techLevel)
        return false
    end
	
	local capCheck = aiBrain.BuilderManagers[locationType].BaseSettings.EngineerCount[techLevel]
    
    -- multiply the engineer limit by the AI multiplier - but insure it's never less than minimum (if multiplier is less than 1)
    capCheck = math.max( capCheck, math.floor(capCheck * ( (aiBrain.CheatValue) * (aiBrain.CheatValue) )) )

	if aiBrain.StartingUnitCap > 1000 then
	
        -- at 1000+ units add 1 engineer for every capmult - up to a limit of 5 --
		capCheck = capCheck + math.max( 1 + math.floor(( aiBrain.StartingUnitCap - 1000) / capmult ), 5) 
	end

	return EntityCategoryCount( catCheck, aiBrain.BuilderManagers[locationType].EngineerManager.EngineerList ) >= capCheck
end

function AdjacencyCheck( aiBrain, locationType, category, radius, testUnit )

	local LOUDGETN = table.getn

	local LOUDPARSE = ParseEntityCategory
	local LOUDTYPE = type
	
	local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt

    local position = aiBrain.BuilderManagers[locationType].Position
    local testCat = category
    
    if LOUDTYPE(category) == 'string' then
        testCat = LOUDPARSE(category)
    end
    
    local reference  = GetOwnUnitsAroundPoint( aiBrain, testCat, position, radius )
	
    if not reference or LOUDGETN(reference) == 0 then 
	    return false
	end
    
    local template = {}
	local counter = 0
	
    local unitSize = aiBrain:GetUnitBlueprint( testUnit ).Physics
    
    for k,v in reference do
	
        if not v.Dead then

            local targetSize = v:GetBlueprint().Physics
            local targetPos = table.copy(v.CachePosition)
			
            targetPos[1] = targetPos[1] - (targetSize.SkirtSizeX* 0.5)
            targetPos[3] = targetPos[3] - (targetSize.SkirtSizeZ* 0.5)
			
            #-- Top/bottom of unit
            for i=0,((targetSize.SkirtSizeX* 0.5)-1) do
                local testPos = { targetPos[1] + 1 + (i * 2), targetPos[3]-(unitSize.SkirtSizeZ* 0.5), 0 }
                local testPos2 = { targetPos[1] + 1 + (i * 2), targetPos[3]+targetSize.SkirtSizeZ+(unitSize.SkirtSizeZ* 0.5), 0 }
                template[counter+1] = testPos
                template[counter+2] = testPos2
				counter = counter + 2
            end
            #-- Sides of unit
            for i=0,((targetSize.SkirtSizeZ* 0.5)-1) do
                local testPos = { targetPos[1]+targetSize.SkirtSizeX + (unitSize.SkirtSizeX* 0.5), targetPos[3] + 1 + (i * 2), 0 }
                local testPos2 = { targetPos[1]-(unitSize.SkirtSizeX* 0.5), targetPos[3] + 1 + (i*2), 0 }
                template[counter+1] = testPos
                template[counter+2] = testPos2
				counter = counter + 2
            end
        end
    end
    
    for k,v in template do
        if CanBuildStructureAt( aiBrain, testUnit, { v[1], 0, v[2] } ) then
            return true
        end
    end
    
    return false
end

function UnitCapCheckGreater(aiBrain, percent)
	if aiBrain.IgnoreArmyCaps then
		return false
	end
    
    return ( GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) ) > percent 
end

function UnitCapCheckLess(aiBrain, percent)
	if aiBrain.IgnoreArmyCaps then
		return true
	end
    
	return ( GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) ) < percent 	
end

function CheckUnitRange(aiBrain, locationType, unitType, category, factionIndex)

    -- Find the unit's blueprint
    local template = import('/lua/buildingtemplates.lua').BuildingTemplates[factionIndex or aiBrain.FactionIndex]
    local buildingId = false
    
    for k,v in template do
        if v[1] == unitType then
            buildingId = v[2]
            break
        end
    end
    
    local bp = GetUnitBlueprintByName(buildingId)
    local range = false
    
    for k,v in bp.Weapon do
        if not range or v.MaxRadius > range then
            range = v.MaxRadius
        end
    end
    
    -- Check around basePosition for StructureThreat
    local unit = AIFindBrainTargetAroundPoint( aiBrain, aiBrain.BuilderManagers[locationType].Position, range, category )
    
    if unit then
        return true
    end
    
    return false
end

function BaseCount(aiBrain, checkNum, compareType)
	return CompareBody(aiBrain.NumBases, checkNum, compareType)
end


function IsBaseExpansionUnderway(aiBrain, bool)
	return bool == aiBrain.BaseExpansionUnderway
end

function ExpansionBaseCount(aiBrain, checkNum, compareType)
    return CompareBody(aiBrain.NumBasesLand, checkNum, compareType)
end

function NavalBaseCount(aiBrain, checkNum, compareType)
    return CompareBody(aiBrain.NumBasesNaval, checkNum, compareType)
end

function CompareBody( numOne, numTwo, compareType )
    if compareType == '>' then
        if numOne > numTwo then
            return true
        end
    elseif compareType == '<' then
        if numOne < numTwo then
            return true
        end
    elseif compareType == '>=' then
        if numOne >= numTwo then
            return true
        end
    elseif compareType == '<=' then
        if numOne <= numTwo then
            return true
        end
    else
        error('*AI ERROR: Invalid compare type: ' .. compareType)
        return false
    end
    
    return false
end


function ACUNeedsUpgrade(aiBrain, upgrade)
	
    for k,v in GetListOfUnits(aiBrain, categories.COMMAND, false ) do

        if not v:HasEnhancement( upgrade ) then
            return true
        end
    end
	
    return false
end

function ACUHasUpgrade(aiBrain, upgrade)

    for k,v in GetListOfUnits(aiBrain, categories.COMMAND, false ) do
	
        if v:HasEnhancement( upgrade ) then
            return true
		end
    end
	
    return false
end


function ArmyNeedsTransports(aiBrain)
    return aiBrain.NeedTransports
end

function DamagedStructuresInArea(aiBrain, locationtype)

	if aiBrain.BuilderManagers[locationtype] then

		local Structures = GetOwnUnitsAroundPoint( aiBrain, categories.STRUCTURE, aiBrain.BuilderManagers[locationtype].Position, 80 )
		table.sort( Structures, function(a,b) return a:GetHealthPercent() < b:GetHealthPercent() end)

		for k,v in Structures do
			if not v.Dead and v:GetHealthPercent() < .8 and not v.BeingReclaimed then
				return true
			end
		end
	end
    
    return false
end

function UnfinishedUnits(aiBrain, locationType, category)	

	if aiBrain.BuilderManagers[locationType] then
	
		local unfinished = GetOwnUnitsAroundPoint(aiBrain, category, aiBrain.BuilderManagers[locationType].Position, 80 )
	
		for num, unit in unfinished do
			if unit:GetFractionComplete() < 1 and GetGuards(aiBrain, unit) < 1 then
				LOG("*AI DEBUG Unfinished unit detected")
				return true
			end
		end
	end
    
	return false
end

function GetGuards(aiBrain, Unit)
	local engs = GetUnitsAroundPoint(aiBrain, categories.ENGINEER, Unit:GetPosition(), 15, 'Ally' )
	local count = 0
	local UpgradesFrom = Unit:GetBlueprint().General.UpgradesFrom
    
	for k,v in engs do
		if v.UnitBeingBuilt == Unit and v != Unit then
			count = count + 1
		end
	end
    
	if UpgradesFrom and UpgradesFrom != 'none' then -- Used to filter out upgrading units
		local oldCat = LOUDPARSE(UpgradesFrom)
		local oldUnit = GetUnitsAroundPoint(aiBrain, oldCat, Unit:GetPosition(), 0, 'Ally' )
		if oldUnit then
			count = count + 1
		end
	end
    
	return count
end

function MassExtractorHasStorageAndLessDefense(aiBrain, locationType, mindistance, maxdistance, minstorageunits, maxdefenses, defensecategory)

    local position = aiBrain.BuilderManagers[locationType].Position
	
	for _,v in GetOwnUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION - categories.TECH1, position, maxdistance) do
	
		local mexposition = table.copy(v:GetPosition())
		local distance = VDist2Sq( position[1],position[3], mexposition[1],mexposition[3])
		
		if distance >= (mindistance*mindistance) then
			
			if GetNumberOfOwnUnitsAroundPoint(aiBrain, categories.MASSSTORAGE, mexposition, 5) >= minstorageunits then

				return GetNumUnitsAroundPoint(aiBrain, defensecategory, mexposition, 20, 'Ally') < maxdefenses
			end
		end
	end
    
	return false
end

function MassExtractorInRangeHasLessThanStorage(aiBrain, locationType, mindistance, maxdistance, storageunits, startX, startZ)

    local pos = aiBrain.BuilderManagers[ locationType ].Position
	
	-- get your own extractors around the point
	local Mexs = GetOwnUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION - categories.TECH1, pos, maxdistance)
	
	for k,v in Mexs do
		local mexposition = v:GetPosition()
		local distance = VDist2Sq( pos[1],pos[3], mexposition[1],mexposition[3] )
		
		if distance >= (mindistance*mindistance) and distance <= (maxdistance*maxdistance) then
			-- get the storage units around that point
			local STORS = GetOwnUnitsAroundPoint(aiBrain, categories.MASSSTORAGE, mexposition, 5)
			
			if LOUDGETN(STORS) < storageunits then
				return true
			end
		end
	end
    
	return false
end

function MassExtractorInRangeHasLessThanDefense(aiBrain, locationType, mindistance, maxdistance, defenseunits, threatmin, threatmax, threatrings)

    local pos = aiBrain.BuilderManagers[ locationType ].Position
	
	-- get your own extractors around the point
	for k,v in GetOwnUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION, pos, maxdistance) do
	
		local mexposition = v:GetPosition()
		local distance = VDist3( pos, mexposition )
        local threat = 0
		
		if distance >= mindistance and distance <= maxdistance then
        
            if threatmin or threatmax then
                threat = aiBrain:GetThreatAtPosition( mexposition, threatrings or 0, true, 'AntiSurface')
            else
                threatmin = 0
                threatmax = 999999
            end
            
			-- get the units around that point
			if GetNumUnitsAroundPoint(aiBrain, categories.STRUCTURE * categories.DEFENSE, mexposition, 20, 'Ally') < defenseunits then
            
                if threat >= threatmin and threat <= threatmax then
                    return true
                end
			end
		end
	end
    
	return false
end

function ShieldDamaged(aiBrain, locationType)

	local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	
    if not engineerManager then
        return false
    end
	
	local shields = aiBrain:GetUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD - categories.TECH2, engineerManager.Location, engineerManager.Radius, 'Ally' )
	
	for num, unit in shields do
	
		if not unit.Dead and unit:ShieldIsOn() then
		
			shieldPercent = (unit.MyShield:GetHealth() / unit.MyShield:GetMaxHealth())
			
			if shieldPercent < 1 then
				return true
			end
		end
	end
    
	return false
end