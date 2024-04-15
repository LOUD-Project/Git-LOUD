--  /lua/editor/UnitCountBuildConditions.lua
--  AI Platoon Build Conditions

local import = import

local AIFindBrainTargetAroundPoint = import('/lua/ai/aiutilities.lua').AIFindBrainTargetAroundPoint

local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
local GetNumberOfOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetNumberOfOwnUnitsAroundPoint

local AltAIUtils = import('/lua/ai/altaiutilities.lua')

local AIFindBaseAreaForExpansion                = AltAIUtils.AIFindBaseAreaForExpansion
local AIFindBaseAreaForDP                       = AltAIUtils.AIFindBaseAreaForDP
local AIFindDefensivePointForDP                 = AltAIUtils.AIFindDefensivePointForDP
local AIFindDefensivePointNeedsStructure        = AltAIUtils.AIFindDefensivePointNeedsStructure
local AIFindExpansionPointNeedsStructure        = AltAIUtils.AIFindExpansionPointNeedsStructure
local AIFindStartPointNeedsStructure            = AltAIUtils.AIFindStartPointNeedsStructure
local AIFindBasePointNeedsStructure             = AltAIUtils.AIFindBasePointNeedsStructure
local AIFindNavalAreaForExpansion               = AltAIUtils.AIFindNavalAreaForExpansion
local AIFindNavalDefensivePointNeedsStructure   = AltAIUtils.AIFindNavalDefensivePointNeedsStructure

AltAIUtils = nil

local NumCatUnitsInArea = import('/lua/scenarioframework.lua').NumCatUnitsInArea
local AreaToRect = import('/lua/sim/scenarioutilities.lua').AreaToRect

local AIBrainMethods = moho.aibrain_methods

local GetCurrentUnits           = AIBrainMethods.GetCurrentUnits
local GetListOfUnits            = AIBrainMethods.GetListOfUnits
local GetNumUnitsAroundPoint    = AIBrainMethods.GetNumUnitsAroundPoint
local GetThreatAtPosition       = AIBrainMethods.GetThreatAtPosition
local GetUnitsAroundPoint       = AIBrainMethods.GetUnitsAroundPoint

local GetPosition = moho.entity_methods.GetPosition	
local IsUnitState = moho.unit_methods.IsUnitState

local PlatoonCategoryCount = moho.platoon_methods.PlatoonCategoryCount
local PlatoonCategoryCountAroundPosition = moho.platoon_methods.PlatoonCategoryCountAroundPosition

local LOUDCOPY = table.copy
local LOUDENTITY = EntityCategoryContains
local EntityCategoryCount = EntityCategoryCount
local EntityCategoryFilterDown = EntityCategoryFilterDown
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDMIN = math.min

local LOUDPARSE = ParseEntityCategory
local LOUDSORT = table.sort
local LOUDTYPE = type

local MATHMAX = math.max

local VectorCached = { 0, 0, 0 }

local DEFENSESTRUCTURES = categories.STRUCTURE * categories.DEFENSE
local EXTRACTORS = categories.MASSEXTRACTION - categories.TECH1
local SHIELDSTRUCTURES = categories.STRUCTURE * categories.SHIELD - categories.TECH2

local factory = categories.FACTORY * categories.STRUCTURE
local landfactory = categories.LAND * factory
local airfactory = categories.AIR * factory
local seafactory = categories.NAVAL * factory
local allunits = categories.ALLUNITS
    
local function GetNumCategoryBeingBuiltByEngineers( EM, category, engCategory )

    local counter = 0
    local beingBuiltUnit
    local IsUnitState = IsUnitState
    local LOUDENTITY = LOUDENTITY
    
    local EngineerList = EM.EngineerList

    for _,v in EntityCategoryFilterDown( engCategory, EngineerList ) do
		
        if not v.Dead and IsUnitState( v, 'Building' ) then
            
            beingBuiltUnit = v.UnitBeingBuilt
			
			if beingBuiltUnit and not beingBuiltUnit.Dead then
            
				if LOUDENTITY( category, beingBuiltUnit ) then
					counter = counter + 1
				end
			end
		end
    end

    return counter
end

local function GetNumCategoryBeingBuiltByFactories( FBM, category, facCategory )

	local counter = 0
    local beingBuiltUnit
    local IsUnitState = IsUnitState
    local LOUDENTITY = LOUDENTITY
    
    local FactoryList = FBM.FactoryList
	
	for _,v in EntityCategoryFilterDown( facCategory, FactoryList ) do
		
		if v.Dead then
			continue
		end

		if not IsUnitState( v, 'Upgrading' ) and not IsUnitState( v, 'Building' ) then
			continue
		end

		beingBuiltUnit = v.UnitBeingBuilt	
		
		if not beingBuiltUnit or beingBuiltUnit.Dead then
			continue
		end

		if not LOUDENTITY( category, beingBuiltUnit ) then
			continue
		end

		counter = counter + 1
	end

	return counter    
end


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
	local numReq = MATHMAX(sizetable[ScenarioInfo.size[1]], sizetable[ScenarioInfo.size[2]])
	
    return GetCurrentUnits(aiBrain,testCat) < numReq
end

function ExistingBasesHaveGreaterThanFactory( aiBrain, basetype, numReq, category )

	for k,v in aiBrain.BuilderManagers do
    
        local FactoryList = v.FactoryManager.FactoryList
	
		if (basetype == 'All' or basetype == v.BaseType) and FactoryList and v.CountedBase then

			if numReq > EntityCategoryCount( category, FactoryList ) then
				return false
			end	
		end
	end

	return true
end

function HaveLessThanUnitsInCategoryBeingBuilt(aiBrain, numunits, category)

	local LOUDENTITY = LOUDENTITY
	local IsUnitState = IsUnitState
	
    local unitlist = GetListOfUnits(aiBrain, categories.CONSTRUCTION, false )
	local numBuilding = 0
	
    for _,unit in unitlist do
    
        local UnitBeingBuilt = unit.UnitBeingBuilt
	
        if not unit.Dead and IsUnitState( unit, 'Building') then
		
            if UnitBeingBuilt and not UnitBeingBuilt.Dead and LOUDENTITY( category, UnitBeingBuilt ) then
				numBuilding = numBuilding + 1	
            end
        end

		-- hmm -- seems odd that we would test construction units that are NOT in a building state - but we do
		-- this was likely to be a test of the engineers build queue
		
		if not unit.Dead and not IsUnitState( unit,'Building') then

            if UnitBeingBuilt and not UnitBeingBuilt.Dead and LOUDENTITY( category, UnitBeingBuilt ) then
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

    -- NOTE: This returns true for actual DP markers AND Expansion Marker (as opposed to Large Expansion Marker)
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

    local BM = aiBrain.BuilderManagers[locationType]

	if BM.EngineerManager then
		return GetNumUnitsAroundPoint( aiBrain, testCat, BM.Position, BM.EngineerManager.Radius, 'Ally') < unitCount
	end
    
	return false
end

function UnitsLessAtLocationInRange( aiBrain, locationType, unitCount, testCat, rangemin, rangemax)

    local BM = aiBrain.BuilderManagers[locationType]

    
	if BM.EngineerManager.Active then

		local managerposition = BM.Position
		local numUnits = 0
        local GetPosition = GetPosition
        local VDist2Sq = VDist2Sq
		
		local units = GetUnitsAroundPoint( aiBrain, testCat, managerposition, rangemax, 'Ally' )
		
		local rangetest = rangemin * rangemin
        local pos
        
		for _, v in units do
        
			pos = GetPosition(v)
            
			if VDist2Sq( managerposition[1],managerposition[3], pos[1],pos[3] ) >= rangetest then
				numUnits = numUnits + 1
			end
            
		end
        
		return numUnits < unitCount
	end
    
	return false
end

function UnitsGreaterAtLocation( aiBrain, locationType, unitCount, testCat )

    local BM = aiBrain.BuilderManagers[locationType]

	if BM.EngineerManager then
		return GetNumUnitsAroundPoint( aiBrain, testCat, BM.Position, BM.EngineerManager.Radius, 'Ally') > unitCount
	end
    
	return false
end

-- modified to use the bases 'rally point radius' if rangemax is set to false
function UnitsGreaterAtLocationInRange( aiBrain, locationType, unitCount, testCat, rangemin, rangemax)

    local BM = aiBrain.BuilderManagers[locationType]

	if BM.EngineerManager then
	
		local managerposition = BM.Position
		local numUnits = 0
        local GetPosition = GetPosition
        local VDist2Sq = VDist2Sq
        
        if not rangemax then 
            rangemax = BM.RallyPointRadius
        end
		
		local units = GetUnitsAroundPoint( aiBrain, testCat, managerposition, rangemax, 'Ally' )
		
		local rangetest = rangemin * rangemin
        local pos
        
		for _, v in units do
        
			pos = GetPosition(v)
            
			if VDist2Sq( managerposition[1],managerposition[3], pos[1],pos[3] ) >= rangetest then
				numUnits = numUnits + 1
			end
		end
        
		return numUnits > unitCount
	end
    
	return false
end

function HaveGreaterThanUnitsWithCategoryAndAlliance(aiBrain, numReq, testCat, alliance)
	return GetNumUnitsAroundPoint( aiBrain, testCat, VectorCached, 999999, alliance ) > numReq
end

function HaveLessThanUnitsWithCategoryAndAlliance(aiBrain, numReq, testCat, alliance)
	return GetNumUnitsAroundPoint( aiBrain, testCat, VectorCached, 999999, alliance ) < numReq
end

function HaveLessThanUnitsWithCategoryAndAllianceInRange(aiBrain, numReq, testCat, alliance, range)
	return GetNumUnitsAroundPoint( aiBrain, testCat, VectorCached, range, alliance ) < numReq
end

function PoolLess( aiBrain, unitCount, testCat)
	return PlatoonCategoryCount( aiBrain.ArmyPool, testCat ) < unitCount
end

function PoolGreater( aiBrain, unitCount, testCat)
	return PlatoonCategoryCount( aiBrain.ArmyPool, testCat ) > unitCount
end

function PoolLessAtLocation( aiBrain, locationType, unitCount, testCat)

    local BM = aiBrain.BuilderManagers[locationType]
    local numUnits = PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, testCat, BM.Position, BM.Radius)

    -- the PlatoonCategoryCountAroundPosition includes units under construction
    -- we must remove those from the unit count
	if numUnits > 0 then
	
		numUnits = numUnits - GetNumCategoryBeingBuiltByEngineers( BM.EngineerManager, testCat, categories.ENGINEER)
		numUnits = numUnits - GetNumCategoryBeingBuiltByFactories( BM.FactoryManager, testCat, factory)

		return numUnits < unitCount
	end
    
	return true
end

function PoolGreaterAtLocation( aiBrain, locationType, unitCount, testCat)

    local BM = aiBrain.BuilderManagers[locationType]

	if BM != nil then

		local numUnits = PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, testCat, BM.Position, BM.Radius)
	
		numUnits = numUnits - GetNumCategoryBeingBuiltByEngineers( BM.EngineerManager, testCat, categories.ENGINEER)
		numUnits = numUnits - GetNumCategoryBeingBuiltByFactories( BM.FactoryManager, testCat, factory)

		return numUnits > unitCount
	end
    
	return false
end

function EngineerLessAtLocation( aiBrain, locationType, unitCount, testCat)

    if aiBrain.OutnumberedRatio >= 2 then
        unitCount = unitCount + 2
    elseif aiBrain.OutnumberedRatio > 1 then
        unitCount = unitCount + 1
    end
    
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
    local EntityCategoryCount = EntityCategoryCount
	
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
    return EntityCategoryCount( unitCategory, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) >= EntityCategoryCount( unitCategory2, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList )
end

function FactoryRatioLessAtLocation( aiBrain, locationType, unitCategory, unitCategory2)
    return EntityCategoryCount( unitCategory, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) < EntityCategoryCount( unitCategory2, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList )
end

function FactoryRatioGreaterAtLocation( aiBrain, locationType, unitCategory, unitCategory2)
    return EntityCategoryCount( unitCategory, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) > EntityCategoryCount( unitCategory2, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList )
end

 
local function GetNumberOfUnitsBeingBuilt( aiBrain, location, buildingCategory, builderCategory, range)

    local BM = aiBrain.BuilderManagers[location]

    local filterUnits = GetOwnUnitsAroundPoint( aiBrain, builderCategory, BM.Position, range or BM.Radius )

    local LOUDENTITY = LOUDENTITY
    local LOUDGETN = LOUDGETN
	local IsUnitState = IsUnitState

	local counter = 0

    for k,v in filterUnits do
		
		if not v.DesiresAssist or not v.UnitBeingBuilt then
			
			continue

		end

        if (not IsUnitState(v, 'Building') and not IsUnitState(v, 'Upgrading')) then
			
            continue

        end

        if not LOUDENTITY( buildingCategory, v.UnitBeingBuilt ) then
			
            continue

        end
            
        if v.NumAssistees and LOUDGETN( v:GetGuards() ) >= v.NumAssistees then
			
            continue

        end

        counter = counter + 1

    end

	return counter

end
	


function BuildingLessAtLocation( aiBrain, locationType, unitCount, testCat, builderCat)
    return GetNumberOfUnitsBeingBuilt( aiBrain, locationType, testCat, builderCat or allunits) < unitCount
end

function BuildingGreaterAtLocation( aiBrain, locationType, unitCount, testCat, builderCat)
    return GetNumberOfUnitsBeingBuilt( aiBrain, locationType, testCat, builderCat or allunits) > unitCount
end

function BuildingGreaterAtLocationAtRange( aiBrain, locationType, unitCount, testCat, builderCat, range)
    return GetNumberOfUnitsBeingBuilt( aiBrain, locationType, testCat, builderCat or allunits) > unitCount
end

function LocationFactoriesBuildingLess( aiBrain, locationType, unitCount, testCat, facCat)
    return GetNumCategoryBeingBuiltByFactories( aiBrain.BuilderManagers[locationType].FactoryManager, testCat, facCat or factory) < unitCount
end

function LocationFactoriesBuildingGreater( aiBrain, locationType, unitCount, testCat, facCat)
    return GetNumCategoryBeingBuiltByFactories( aiBrain.BuilderManagers[locationType].FactoryManager, testCat, facCat or factory) > unitCount
end

-- is there an engineer, at this base, building unitCategory, needing assistance, within unitRange of the base
function LocationEngineerNeedsBuildingAssistanceInRange( aiBrain, locationType, unitCategory, engCat, unitRange )

    local GetPosition = GetPosition
	local VDist2 = VDist2

    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    local engineerManagerPos = aiBrain.BuilderManagers[locationType].Position
    
	local engUnits = nil
	local numUnits = 0
	
	if engineerManager.Active then
		-- find all the engineers in this base, of this engCat, building something in unitCategory
    	engUnits, numUnits = engineerManager:GetEngineersWantingAssistanceWithBuilding( unitCategory, engCat )
	end
	
	-- if there are units lets range check
	if numUnits > 0 then

		for _,v in engUnits do
		
			if VDist2( engineerManagerPos[1], engineerManagerPos[3], GetPosition(v)[1], GetPosition(v)[3] ) <= unitRange then
			
				return true
			end
		end
	end
	
    return false
end


function FactoryCapCheck(aiBrain, locationType, factoryType)

    local catCheck = false
	
    if factoryType == 'LAND' then
        catCheck = landfactory
    elseif factoryType == 'AIR' then
        catCheck = airfactory
    elseif factoryType == 'SEA' then
        catCheck = seafactory
    elseif factoryType == 'GATE' then
        catCheck = categories.GATE
    else
        WARN('*AI WARNING: Invalid factorytype - ' .. factoryType)
        return false
    end
	
    local BM = aiBrain.BuilderManagers[locationType]
    local factoryManager = BM.FactoryManager
	local numUnits = 0
	
	if factoryManager.Active == true then
		-- this should give you the total number of factories at this location
		numUnits = EntityCategoryCount( catCheck, factoryManager.FactoryList )

		local engineerManager = BM.EngineerManager

		numUnits = numUnits + GetNumCategoryBeingBuiltByEngineers( engineerManager, catCheck, allunits )
	end

    if numUnits < BM.BaseSettings.FactoryCount[factoryType] then
		return true
	end
	
    return false
end


local T1 = categories.TECH1
local T2 = categories.TECH2
local T3 = categories.TECH3

function BelowEngineerCapCheck(aiBrain, locationType, techLevel)

    local catCheck = false
    local capmult = 500     -- for every 500 units add 1
    local caplimit = 1
	
    if techLevel == 'Tech1' then
	
        catCheck = T1
		
    elseif techLevel == 'Tech2' then
	
        catCheck = T2
        capmult = 300
        caplimit = 3
		
    elseif techLevel == 'Tech3' then
	
        catCheck = T3
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

    local BM = aiBrain.BuilderManagers[locationType]	
	local capCheck = BM.BaseSettings.EngineerCount[techLevel]

    -- always use the largest value - so even if the cheat level is less than 1 - we'll have the usual number of engineers
    capCheck = MATHMAX(capCheck, LOUDFLOOR(capCheck * ((aiBrain.CheatValue) * (aiBrain.CheatValue))))

	if aiBrain.StartingUnitCap > 1000 then
	
        -- at 1000+ units add 1 engineer for every capmult - up to the cap limit --
		capCheck = capCheck + LOUDMIN( 1 + LOUDFLOOR(( aiBrain.StartingUnitCap - 1000) / capmult ), caplimit)
	end

	return EntityCategoryCount( catCheck, BM.EngineerManager.EngineerList ) < capCheck
end

function AboveEngineerCapCheck(aiBrain, locationType, techLevel)

    local catCheck = false
    local capmult = 500
	
    if techLevel == 'Tech1' then
	
        catCheck = T1
		
    elseif techLevel == 'Tech2' then
	
        catCheck = T2
        capmult = 300
		
    elseif techLevel == 'Tech3' then
	
        catCheck = T3
        capmult = 250
		
    elseif techLevel == 'SCU' then
	
        catCheck = categories.SUBCOMMANDER
        capmult = 200
		
    else
	
        WARN('*AI WARNING: Invalid techLevel - ' .. techLevel)
        return false
    end
    
    local BM = aiBrain.BuilderManagers[locationType]
	local capCheck = BM.BaseSettings.EngineerCount[techLevel]
    
    -- multiply the engineer limit by the AI multiplier - but insure it's never less than minimum (if multiplier is less than 1)
    capCheck = MATHMAX( capCheck, LOUDFLOOR(capCheck * ( (aiBrain.CheatValue) * (aiBrain.CheatValue) )) )

	if aiBrain.StartingUnitCap > 1000 then
	
        -- at 1000+ units add 1 engineer for every capmult - up to a limit of 5 --
		capCheck = capCheck + MATHMAX( 1 + LOUDFLOOR(( aiBrain.StartingUnitCap - 1000) / capmult ), 5) 
	end

	return EntityCategoryCount( catCheck, BM.EngineerManager.EngineerList ) >= capCheck
end

function AdjacencyCheck( aiBrain, locationType, category, radius, testUnit )

    local LOUDCOPY = LOUDCOPY
	local LOUDGETN = LOUDGETN
	local LOUDPARSE = LOUDPARSE
	local LOUDTYPE = LOUDTYPE
	
	local CanBuildStructureAt = AIBrainMethods.CanBuildStructureAt

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

    local unitSize = __blueprints[testUnit].Physics
    
    local testPos, testPos2
    
    -- SO -- if we check each position as we make it - we don't have to 
    -- table the results and process them afterwards - and we can take
    -- advantage of the VectorCached method to do it
    
    -- so this will make a table of ALL the positions which CAN be used
    -- for adjacency -- note that it's not checking those positions as 
    -- it goes along
    for k,v in reference do
	
        if not v.Dead then

            local targetSize = __blueprints[v.BlueprintID].Physics
            
            local targetPos = v.CachePosition
			
            targetPos[1] = targetPos[1] - (targetSize.SkirtSizeX* 0.5)
            targetPos[3] = targetPos[3] - (targetSize.SkirtSizeZ* 0.5)
			
            -- Top/bottom of unit
            for i=0,((targetSize.SkirtSizeX* 0.5)-1) do
            
                testPos = { targetPos[1] + 1 + (i * 2), targetPos[3]-(unitSize.SkirtSizeZ* 0.5), 0 }
                testPos2 = { targetPos[1] + 1 + (i * 2), targetPos[3]+targetSize.SkirtSizeZ+(unitSize.SkirtSizeZ* 0.5), 0 }
                
                template[counter+1] = testPos
                template[counter+2] = testPos2
				counter = counter + 2
            end
            
            -- Sides of unit
            for i=0,((targetSize.SkirtSizeZ* 0.5)-1) do
            
                testPos = { targetPos[1]+targetSize.SkirtSizeX + (unitSize.SkirtSizeX* 0.5), targetPos[3] + 1 + (i * 2), 0 }
                testPos2 = { targetPos[1]-(unitSize.SkirtSizeX* 0.5), targetPos[3] + 1 + (i*2), 0 }
                
                template[counter+1] = testPos
                template[counter+2] = testPos2
				counter = counter + 2
            end
        end
    end
    
    -- now we'll check ALL of the possible positions and take the
    -- first one that actually works -- kind of wasteful really --
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
        
		LOUDSORT( Structures, function(a,b) return a:GetHealthPercent() < b:GetHealthPercent() end)

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

	local engs = GetUnitsAroundPoint(aiBrain, categories.ENGINEER, GetPosition(Unit), 15, 'Ally' )
	local count = 0
    
	local UpgradesFrom = __blueprints[Unit.BlueprintID].General.UpgradesFrom
    
	for k,v in engs do
		if v.UnitBeingBuilt == Unit and v != Unit then
			count = count + 1
		end
	end
    
	if UpgradesFrom and UpgradesFrom != 'none' then -- Used to filter out upgrading units
    
		local oldCat = LOUDPARSE(UpgradesFrom)
		local oldUnit = GetUnitsAroundPoint(aiBrain, oldCat, GetPosition(Unit), 0, 'Ally' )
        
		if oldUnit then
			count = count + 1
		end
	end
    
	return count
end

function MassExtractorHasStorageAndLessDefense(aiBrain, locationType, mindistance, maxdistance, minstorageunits, maxdefenses, defensecategory)

    local position = aiBrain.BuilderManagers[locationType].Position
    local VDist2Sq = VDist2Sq
    
    local mexposition, distance
	
	for _,v in GetOwnUnitsAroundPoint(aiBrain, EXTRACTORS, position, maxdistance) do
	
		mexposition = v.CachePosition
        
		distance = VDist2Sq( position[1],position[3], mexposition[1],mexposition[3])
		
		if distance >= (mindistance*mindistance) then
        
            -- Integrated Storage Installed - always yes --
            if ScenarioInfo.LOUD_IS_Installed then
                minstorageunits = 0
            end
			
			if GetNumberOfOwnUnitsAroundPoint(aiBrain, categories.MASSSTORAGE, mexposition, 5) >= minstorageunits then

				return GetNumUnitsAroundPoint(aiBrain, defensecategory, mexposition, 20, 'Ally') < maxdefenses
			end
		end
	end
    
	return false
end

function MassExtractorInRangeHasLessThanStorage(aiBrain, locationType, mindistance, maxdistance, storageunits, startX, startZ)

    local pos = aiBrain.BuilderManagers[ locationType ].Position
    local VDist2Sq = VDist2Sq
    
    local mexposition, distance, STORS
	
	-- get your own extractors around the point
	local Mexs = GetOwnUnitsAroundPoint(aiBrain, EXTRACTORS, pos, maxdistance)
	
	for k,v in Mexs do
    
		mexposition = v.CachePosition
        
		distance = VDist2Sq( pos[1],pos[3], mexposition[1],mexposition[3] )
		
		if distance >= (mindistance*mindistance) and distance <= (maxdistance*maxdistance) then
        
			-- get the storage units around that point
			STORS = GetOwnUnitsAroundPoint(aiBrain, categories.MASSSTORAGE, mexposition, 5)
            
            -- Integrated Storage Installed - we always have enough storage
            if ScenarioInfo.LOUD_IS_Installed then
                storageunits = 0
            end
			
			if LOUDGETN(STORS) < storageunits then
				return true
			end
		end
	end
    
	return false
end

function MassExtractorInRangeHasLessThanEnergy(aiBrain, locationType, mindistance, maxdistance, energyunits, startX, startZ)

    local pos = aiBrain.BuilderManagers[ locationType ].Position
    local VDist2Sq = VDist2Sq
    
    local mexposition, distance, STORS
	
	-- get your own extractors around the point
	local Mexs = GetOwnUnitsAroundPoint(aiBrain, EXTRACTORS, pos, maxdistance)
	
	for k,v in Mexs do
    
		mexposition = v.CachePosition
        
		distance = VDist2Sq( pos[1],pos[3], mexposition[1],mexposition[3] )
		
		if distance >= (mindistance*mindistance) and distance <= (maxdistance*maxdistance) then
        
			-- get the storage units around that point
			STORS = GetOwnUnitsAroundPoint(aiBrain, categories.ENERGYPRODUCTION * categories.TECH1, mexposition, 5)
			
			if LOUDGETN(STORS) < energyunits then
				return true
			end
		end
	end
    
	return false
end


function MassExtractorInRangeHasLessThanDefense(aiBrain, locationType, mindistance, maxdistance, defenseunits, threatmin, threatmax, threatrings)

    local pos = aiBrain.BuilderManagers[ locationType ].Position
    
    local GetThreatAtPosition = GetThreatAtPosition

    local VDist3 = VDist3
    
    local mexposition, distance, threat
	
	-- get your own extractors around the point
	for k,v in GetOwnUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION, pos, maxdistance) do
	
		mexposition = v.CachePosition
        
		distance = VDist3( pos, mexposition )
        threat = 0
		
		if distance >= mindistance and distance <= maxdistance then
        
            if threatmin or threatmax then
                threat = GetThreatAtPosition( aiBrain, mexposition, threatrings or 0, true, 'AntiSurface')
            else
                threatmin = 0
                threatmax = 999999
            end
            
			-- get the units around that point
			if GetNumUnitsAroundPoint(aiBrain, DEFENSESTRUCTURES, mexposition, 20, 'Ally') < defenseunits then
            
                if threat >= threatmin and threat <= threatmax then
                    return true
                end
			end
		end
	end
    
	return false
end


function ShieldDamaged(aiBrain, locationType)

	local BM = aiBrain.BuilderManagers[locationType]
	
    if not BM then
        return false
    end
	
	local shields = GetUnitsAroundPoint( aiBrain, SHIELDSTRUCTURES, BM.Position, BM.Radius, 'Ally' )
	
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