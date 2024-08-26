--  File     :  /lua/AI/aiutilities.lua

local SUtils = import('/lua/ai/sorianutilities.lua')

local TABLECAT = table.cat
local LOUDDEEPCOPY = table.deepcopy
local LOUDFLOOR = math.floor
local LOUDINSERT = table.insert
local LOUDMAX = math.max
local LOUDMIN = math.min
local LOUDPARSE = ParseEntityCategory
local LOUDREMOVE = table.remove
local LOUDSORT = table.sort
local VDist2Sq = VDist2Sq

local AIBrainMethods = moho.aibrain_methods

local GetNumUnitsAroundPoint = AIBrainMethods.GetNumUnitsAroundPoint
local GetThreatsAroundPosition = AIBrainMethods.GetThreatsAroundPosition
local GetThreatAtPosition = AIBrainMethods.GetThreatAtPosition
local GetUnitsAroundPoint = AIBrainMethods.GetUnitsAroundPoint

AIBrainMethods = nil

local GetAIBrain = moho.unit_methods.GetAIBrain

local GetFractionComplete = moho.entity_methods.GetFractionComplete
local GetPosition = moho.entity_methods.GetPosition	

local GetSurfaceHeight = GetSurfaceHeight 
local GetTerrainHeight = GetTerrainHeight

local SEARCHCATS = categories.ALLUNITS - categories.MASSEXTRACTION - categories.MASSSTORAGE - categories.MOBILE - categories.WALL

-- Adds an area to the brains MustScout table
function AIAddMustScoutArea( aiBrain, location )

    local gametime = LOUDFLOOR(GetGameTimeSeconds())
    local MustScoutList = aiBrain.IL.MustScout or false

	if location and MustScoutList then
        
        local VDist2Sq = VDist2Sq

		for k,v in MustScoutList do
        
            -- if the report is old - or someone took that job and died - remove it
            if gametime > (v.Created + 180) or v.TaggedBy.Dead then

                MustScoutList[k] = nil
                
            else
            
                -- if the job has NOT been taken
                if not v.TaggedBy then
		
                    -- but theres already a location to scout within 50 of this one
                    if VDist2Sq(v.Position[1],v.Position[3], location[1],location[3]) < 2500 then
			
                        -- dont add it
                        return
                    end
                end
            end
		end
		
        -- otherwise -- add it
		LOUDINSERT( aiBrain.IL.MustScout,	{ Created = GetGameTimeSeconds(), Position = location, TaggedBy = false	} )
	end
	
end

function AISortMarkersFromLastPosWithThreatCheck(aiBrain, markerlist, maxNumber, tMin, tMax, tRings, tType, position)

    local GetThreatAtPosition = GetThreatAtPosition

	local LOUDREMOVE = LOUDREMOVE
    local LOUDSORT = LOUDSORT
    
    local threatCheck = false
    local threatMax = 999999
    local threatMin = -999999
	
    if tMin and tMax and tRings then
        threatCheck = true
        threatMax = tMax
        threatMin = tMin
    end
 
    local startPosX, startPosZ
    
    if position then
        startPosX = position[1]
        startPosZ = position[3]
    else
		startPosX = aiBrain.StartPosX
		startPosZ = aiBrain.StartPosZ
	end

    local function SortVDist2Sq( a, b )
        local VDist2Sq = VDist2Sq
        return VDist2Sq(a.Position[1],a.Position[3], startPosX,startPosZ) < VDist2Sq(b.Position[1],b.Position[3], startPosX,startPosZ)
    end
    
	-- sort this list from the starting position
    LOUDSORT(markerlist, SortVDist2Sq)    

    local mlist = {}
	local counter = 0
    local point, threat

    while markerlist[1] do
    
        point = markerlist[1].Position    -- get first entry (closest) from MarkerList
        
        if threatCheck then
		
			threat = GetThreatAtPosition( aiBrain, point, 0, true, 'AntiSurface')

			if threat > threatMax then
				break
			end
			
			if threat >= threatMin then
				counter = counter + 1
				mlist[counter] = point
			end
			
		else
			counter = counter + 1
			mlist[counter] = point
        end

		if counter >= maxNumber then
			break
		end

        LOUDREMOVE(markerlist, 1)   -- remove the first entry from MarkerList

        local startPosX = point[1]
        local startPosZ = point[3]
        
		-- sort the list from the new position
        LOUDSORT(markerlist, SortVDist2Sq)

    end
	
	if counter > 0 then
		return mlist
	end
	
	return false
end

-- modified this function to store the lists that would be generated for each type of marker
-- this means that each markertype only gets read and assembled ONCE for the entire session
function AIGetMarkerLocations(markerType)

	if ScenarioInfo[markerType] then
		return ScenarioInfo[markerType]
	end
	
    local markerlist = {}
	local counter = 0
    
    if markerType == 'Start Location' then
	
        local tempMarkers = AIGetMarkerLocations('Blank Marker')
		
        for k,v in tempMarkers do
		
            if string.sub(v.Name,1,5) == 'ARMY_' then 
            
				counter = counter + 1
                markerlist[counter] = { Position = {v.Position[1],v.Position[2],v.Position[3]}, Name = v.Name}

            end
        end 
        
    else
	
        local markers = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers
		
        if markers then
		
            for k, v in markers do
			
                if v.type == markerType then
                
                    counter = counter + 1                
                    markerlist[counter] = { Position = {v.position[1],v.position[2],v.position[3]}, Name = k }
                    
                end
            end
        end
        
    end

	ScenarioInfo[markerType] = markerlist

    return markerlist
end

-- similar to the function above this function returns a list of markers (multiple types)
-- with the full marker data set and we dont store the results
-- the full data set is
-- adjacentTo
-- graph
-- name
-- position
-- type
function AIGetMarkerLocationsEx(aiBrain, markerType)

    local tempMarkers = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers
    local markerlist = {}
	local counter = 0
    
    if tempMarkers then
	
        for k, v in tempMarkers do
		
            if v.type == markerType then
			
                v.name = k
				counter = counter + 1                
                markerlist[counter] = v

            end
        end
    end
	
    return markerlist
end

function AIGetMarkersAroundLocation( aiBrain, markerType, pos, radius, threatMin, threatMax, threatRings, threatType )

    local tempMarkers = ScenarioInfo[markerType] or AIGetMarkerLocations( markerType )
	
	if not tempMarkers then
		return {}
	end
	
    local markerlist = {}
	local counter = 0
	
	local VDist2Sq = VDist2Sq
    local GetThreatAtPosition = GetThreatAtPosition
    
	local checkdistance = radius * radius
    local position, threat
	
	LOUDSORT(tempMarkers, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( pos[1],pos[3], a.Position[1],a.Position[3] ) < VDist2Sq( pos[1],pos[3], b.Position[1],b.Position[3] ) end)

    for _,v in tempMarkers do
	
        position = v.Position
        
        if VDist2Sq( pos[1], pos[3], position[1], position[3] ) <= checkdistance then
		
            if not threatMin then
            
				counter = counter + 1			
                markerlist[counter] = v
            else
			
                threat = GetThreatAtPosition( aiBrain, position, threatRings, true, threatType or 'Overall' )
				
                if threat >= threatMin and threat <= threatMax then
                
                    counter = counter + 1                
                    markerlist[counter] = v
				end
            end
			
        else
			break
		end
    end
	
	return markerlist
end

-- this function simply filters a list of positions down to those
-- that have NO allied structures within 42 ogrids (excluding extractors and storage)
function AIFilterAlliedBases( aiBrain, positions )

    local markerlist = {}
	local counter = 0
    
	local GetNumUnitsAroundPoint = GetNumUnitsAroundPoint
	
    for k,v in positions do
	
        if GetNumUnitsAroundPoint( aiBrain, SEARCHCATS, v.Position, 42, 'Ally' ) == 0 then
		
			counter = counter + 1
            markerlist[counter] = v

        end
        
    end
	
    return markerlist
end

function AIFindMarkerNeedsEngineer( aiBrain, pos, positions )

    local filterpositions = AIFilterAlliedBases( aiBrain, positions )
	
	LOUDSORT(filterpositions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], pos[1],pos[3]) < VDist2Sq(b.Position[1],b.Position[3], pos[1],pos[3]) end)
	
    for k,v in filterpositions do
	
        if not aiBrain.BuilderManagers[v.Name] then
		
			return v.Position,v.Name
        else
		
            local managers = aiBrain.BuilderManagers[v.Name]
			
            if managers.EngineerManager.EngineerList.Count == 0 and EntityCategoryCount( categories.FACTORY, managers.FactoryManager.FactoryList ) < 1 then 
				return v.Position,v.Name
            end
        end
    end
	
    return false, nil
end

-- since this function sorts by distance it will return the closest point that meets that unitMax condition
-- This is a variation on the one in AltAIUtils -- it uses a given point rather than a baseposition
-- now recognizes the standard Expansion Area as a Defensive Point
function AIFindDefensivePointNeedsStructureFromPoint( aiBrain, point, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)

    local positions = AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', point, radius, tMin, tMax, tRings, tType)
    
	positions = TABLECAT(positions, AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', point, radius, tMin, tMax, tRings, tType))

    LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], point[1],point[3]) < VDist2Sq(b.Position[1],b.Position[3], point[1],point[3]) end)
    
    local searchcats = LOUDPARSE(category)
    local numunits, position

    for _,v in positions do

        position = v.Position
        numUnits = GetNumberOfOwnUnitsAroundPoint( aiBrain, searchcats, position, markerRadius )

        if numUnits <= unitMax then
			return position, v.Name
        end
        
    end
	
    return false,nil
end

-- return the position of the closest marker of a given type
-- return false if there are none --
function AIGetClosestMarkerLocation(aiBrain, markerType, startX, startZ, extraTypes)

    local markerlist = ScenarioInfo[markerType] or AIGetMarkerLocations(markerType)
    
    if extraTypes then
	
        for _, pType in extraTypes do
		
            markerlist = TABLECAT(markerlist, ScenarioInfo[pType] or AIGetMarkerLocations(pType) )
        end
    end
	
	if markerlist[1] then
    
		LOUDSORT(markerlist, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3],startX,startZ) < VDist2Sq(b.Position[1],b.Position[3],startX,startZ) end)

		return markerlist[1].Position, markerlist[1].Name
	end
	
	return false,nil
end

function AIGetClosestThreatMarkerLoc(aiBrain, markerType, startX, startZ, threatMin, threatMax, rings, threatType)

    local markerlist = ScenarioInfo[markerType] or AIGetMarkerLocations(markerType)

    local GetThreatAtPosition = GetThreatAtPosition
    
    LOUDSORT(markerlist, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3],startX,startZ) < VDist2Sq(b.Position[1],b.Position[3],startX,startZ) end)
    
    local position, threat

    for k, v in markerlist do
	
        position = v.Position
        threat = GetThreatAtPosition( aiBrain, position, rings, true, threatType or 'Overall')
        
        if threat >= threatMin and threat <= threatMax then
			return position, v.Name
        end
        
    end
	
    return false, nil
end

-- added optional range and location values for more flexible use
-- if provided they'll override the values that come from the EM 
-- allows us to do local reclaiming outside of the base managers radius
function AIGetReclaimablesAroundLocation( aiBrain, locationType, range, location )

    if aiBrain.BuilderManagers[locationType] then
	
        local radius = range or aiBrain.BuilderManagers[locationType].EngineerManager.Radius
        local position = location or aiBrain.BuilderManagers[locationType].Position

		return GetReclaimablesInRect( Rect( position[1] - radius, position[3] - radius, position[1] + radius, position[3] + radius ) )
	end
	
	return false
end

-- this will return a list of only your units within radius --
function GetOwnUnitsAroundPoint( aiBrain, category, location, radius )
	
	local GetUnitsAroundPoint = GetUnitsAroundPoint
	local GetFractionComplete = GetFractionComplete

    local mlist = {}
	local counter = 0
    local ArmyIndex = aiBrain.ArmyIndex
	
	if category and location and radius then
	
		local units = GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) or {}
	
		for k,v in units do
	
			if (not v.Dead) and GetFractionComplete(v) == 1 and v.Army == ArmyIndex then

				counter = counter + 1            
				mlist[counter] = v
			end
		end
	end
	
    return mlist
end

-- this will return a list of ALL Allied units (yours and allies)
function GetAlliedUnitsAroundPoint( aiBrain, category, location, radius )
	
	local GetUnitsAroundPoint = GetUnitsAroundPoint
	local GetFractionComplete = GetFractionComplete

    local mlist = {}
	local counter = 0
	
	if category and location and radius then
	
		local units = GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) or {}
	
		for k,v in units do
	
			if (not v.Dead) and GetFractionComplete(v) == 1 then
            
				counter = counter + 1
				mlist[counter] = v
			end
		end
	end
	
    return mlist
end

function GetOwnUnitsAroundPointWithThreatCheck( aiBrain, category, location, radius, tmin, tmax, rings, tType )
	
	local GetUnitsAroundPoint = GetUnitsAroundPoint
	local GetThreatAtPosition = GetThreatAtPosition
	local GetFractionComplete = GetFractionComplete
    local GetPosition = GetPosition	
	
    local mlist = {}
	local counter = 0
    local threat
    local ArmyIndex = aiBrain.ArmyIndex

    for k,v in GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) do
	
        if (not v.Dead) and GetFractionComplete(v) == 1 and v.Army == ArmyIndex then

			if tmin and tmax then
			
				threat = GetThreatAtPosition( aiBrain, GetPosition(v), rings or 1, true, tType or 'Overall' )
				
				if threat >= tmin and threat <= tmax then
			
					counter = counter + 1
					mlist[counter] = v
				end
				
			else

				counter = counter + 1			
				mlist[counter] = v
            end
        end
    end
	
    return mlist
	
end

function GetNumberOfOwnUnitsAroundPoint( aiBrain, category, location, radius )
	
	local GetUnitsAroundPoint = GetUnitsAroundPoint
	local GetFractionComplete = GetFractionComplete
    local ArmyIndex = aiBrain.ArmyIndex
	
	local counter = 0
	
    for k,v in GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) do
	
        if not v.Dead then
		
			if GetFractionComplete(v) == 1 and v.Army == ArmyIndex then
				counter = counter + 1
			end
        end
    end
	
    return counter
end

function CheckUnitPathingEx( destPos, curlocation, unit )

    if unit.Dead then
        return false
    end
	
    local pathingType = 'Land'
    
    local mType = __blueprints[unit.BlueprintID].Physics.MotionType
	
    if mType == 'RULEUMT_AmphibiousFloating' or mType == 'RULEUMT_Hover' or mType == 'RULEUMT_Amphibious' then
	
        pathingType = 'Amphibious'
		
    elseif mType == 'RULEUMT_Water' or mType == 'RULEUMT_SurfacingSub' then
	
        pathingType = 'Water'
		
    elseif mType == 'RULEUMT_Air' then
	
        return true
		
    end

    local surf = GetSurfaceHeight( destPos[1], destPos[3] )
    local terr = GetTerrainHeight( destPos[1], destPos[3] )
    local land = terr >= surf
    local result = false
    
    local finalPos = {destPos[1], terr, destPos[3] }
    local bestGoal = curlocation
    
    if land then
	
        if pathingType == 'Land' or pathingType == 'Amphibious' then
		
            result, bestGoal = unit:CanPathTo( finalPos )                   
			
        end
		
    else
	
        if pathingType == 'Water' or pathingType == 'Amphibious' then
		
            result, bestGoal = unit:CanPathTo( finalPos )  
        end
		
    end
	
    return result
	
end

function AIFindBrainTargetAroundPoint( aiBrain, position, maxRange, category )

    if not position or not maxRange then
        return false
    end
    
    local GetPosition = GetPosition	
    local LOUDPARSE = LOUDPARSE
    local type = type
    local VDist2Sq = VDist2Sq
    
    local testCat = category
	
    if type(testCat) == 'string' then
        testCat = LOUDPARSE( testCat )
    end

    local targetUnits = GetUnitsAroundPoint( aiBrain, testCat, position, maxRange, 'Enemy' )
    
    local retUnit = false
    local distance = false
    
    local unitPos, newdist
	
    for num, unit in targetUnits do
	
        if not unit.Dead then
		
            unitPos = GetPosition(unit)
			newdist = VDist2Sq( position[1],position[3], unitPos[1],unitPos[3] )
			
            if not retUnit or newdist < distance then
                retUnit = unit
                distance = newdist
            end
        end
    end

    return retUnit
end

function RandomLocation(x,z, value)

    local GetSurfaceHeight = GetSurfaceHeight
    local GetTerrainHeight = GetTerrainHeight
    
	local Random = Random
	local r_value = value or 20

    local finalX = x + Random(-r_value, r_value)
	
	-- there is potential here for a hung loop if the random value cannot overcome the map boundary
    while finalX <= 0 or finalX >= ScenarioInfo.size[1] do
	
        finalX = x + Random(-r_value, r_value)
    end
	
    local finalZ = z + Random(-r_value, r_value)
	
    while finalZ <= 0 or finalZ >= ScenarioInfo.size[2] do
	
        finalZ = z + Random(-r_value, r_value)
    end
	
    local height = GetTerrainHeight( finalX, finalZ )
	
    if GetSurfaceHeight( finalX, finalZ ) > height then
	
        height = GetSurfaceHeight( finalX, finalZ )
		
    end
	
    return { finalX, height, finalZ }
end

-- This function just returns the distance to the closest IMAP threat position that exceeds the threatCutoff
function GetThreatDistance(aiBrain, position, threatCutoff )

    local VDist2Sq = VDist2Sq
    
    local threatTable = GetThreatsAroundPosition( aiBrain, position, 4, true, 'StructuresNotMex')
    
    local closestHighThreat = 999999
    local dist
	
    for k,v in threatTable do

        if v[3] > threatCutoff then
		
            dist = VDist2Sq( v[1], v[2], position[1], position[3] )
			
            if not closestHighThreat or dist < closestHighThreat then
			
                closestHighThreat = dist
	        end
			
        else
		
			break
		end
		
    end
	
    return closestHighThreat
end

-- 3+ Teams Unit Cap Fix : That part is moved away from the main SetupAICheat 
-- to do it after we figured out how many armies are in the biggest team
function SetupAICheatUnitCap(aiBrain, biggestTeamSize)

	-- set unit cap and veterancy multiplier --
	if ScenarioInfo.Options.CapCheat == "unlimited" then
	
		aiBrain.IgnoreArmyCaps = true
		
		SetIgnoreArmyUnitCap(aiBrain.ArmyIndex, true)
		
		SetArmyUnitCap( aiBrain.ArmyIndex, 99999)

        LOG("     "..aiBrain.Nickname.." Unit cap set to Unlimited")
		
	elseif ScenarioInfo.Options.CapCheat == "cheatlevel" then

        local initialCap = tonumber(ScenarioInfo.Options.UnitCap) or 750

        local cheatCap = initialCap * aiBrain.CheatValue * (math.max(aiBrain.OutnumberedRatio,1))
        
        SetArmyUnitCap( aiBrain.ArmyIndex, math.floor(cheatCap) )
        
        LOG("     "..aiBrain.Nickname.." Unit cap set to "..cheatCap.." from "..initialCap.." based on cheat ("..aiBrain.CheatValue..") & OutnumberedRatio" )
        
    else

        if aiBrain.OutnumberedRatio > 1 then

            local initialCap = tonumber(ScenarioInfo.Options.UnitCap) or 750

            -- unit cap is increased by the outnumbered ratio --
            local cheatCap = initialCap * (math.max(aiBrain.OutnumberedRatio,1))
        
            SetArmyUnitCap( aiBrain.ArmyIndex, math.floor(cheatCap) )
        
            LOG("     "..aiBrain.Nickname.." Unit cap set to "..cheatCap.." from "..initialCap.." based on OutnumberedRatio only")
            
        end
       
    end

	-- record the starting unit cap
	-- caps of 1000+ trigger some conditions
	aiBrain.StartingUnitCap = GetArmyUnitCap(aiBrain.ArmyIndex)

	-- start the spawn wave thread for cheating AI --
    aiBrain.WaveThread = ForkThread(import('/lua/loudutilities.lua').SpawnWaveThread, aiBrain)
    
end

-- This function creates the cheats used by the AI
-- now creates buffs for EACH AI -- allowing us to have independant mutlipliers and supporting the
-- more recent adaptive cheat multipliers which require this to work properly
function SetupAICheat(aiBrain)

    LOG("     "..aiBrain.Nickname.." Standard Cheat is "..aiBrain.CheatValue)

    if aiBrain.OutnumberedRatio > 1 then 
        LOG("     "..aiBrain.Nickname.."  OutnumberedRatio "..aiBrain.OutnumberedRatio)
    end
  
	--- resource rate cheat buff
    local newbuff = LOUDDEEPCOPY(Buffs['CheatIncome'])
    newbuff.Name = 'CheatIncome'..aiBrain.ArmyIndex
	newbuff.Affects.EnergyProduction.Mult = aiBrain.CheatValue
	newbuff.Affects.MassProduction.Mult = aiBrain.CheatValue
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name        = newbuff.Name,
            BuffType    = newbuff.BuffType,
            Stacks      = newbuff.Stacks,
            Duration    = newbuff.Duration,
            Affects     = newbuff.Affects,
        }
    end

	--- build rate cheat
    local newbuff = LOUDDEEPCOPY(Buffs['CheatBuildRate'])
    newbuff.Name = 'CheatBuildRate'..aiBrain.ArmyIndex
    newbuff.Affects.BuildRate.Mult = math.max( 1.0, aiBrain.CheatValue )
    
    LOG("     "..aiBrain.Nickname.."  Resource mult is "..aiBrain.CheatValue)


    if aiBrain.Personality != 'loud' then

        LOG("     "..aiBrain.Nickname.." BuildRate mult is "..newbuff.Affects.BuildRate.Mult)

        if not Buffs[newbuff.Name] then
		
            BuffBlueprint {
                Name = newbuff.Name,
                BuffType = newbuff.BuffType,
                Stacks = newbuff.Stacks,
                Duration = newbuff.Duration,
                Affects = newbuff.Affects,
            }
        end

        return
    end


    --- Veterancy mult is always 1 or higher
    aiBrain.VeterancyMult = LOUDMAX( 1, aiBrain.CheatValue)
    --- Minor cheat value
    aiBrain.MinorCheatModifier = (LOUDMAX( 0, aiBrain.CheatValue - 1.0 ) * 0.34) + 1.0
    --- Major cheat value
    aiBrain.MajorCheatModifier = (LOUDMAX( -0.2, aiBrain.CheatValue - 1.0 ) * 0.65) + 1.0
    
    -- the Outnumbered condition increases a cheating AI's build rate and affects the sub modifiers
    if aiBrain.OutnumberedRatio > aiBrain.CheatValue then
        
        LOG("     "..aiBrain.Nickname.." Cheats modified due to OutnumberedRatio")

        newbuff.Affects.BuildRate.Mult = aiBrain.CheatValue * math.min( aiBrain.OutnumberedRatio, aiBrain.MajorCheatModifier )
        
        aiBrain.MajorCheatModifier = (aiBrain.MajorCheatModifier * aiBrain.MinorCheatModifier)
        
        aiBrain.MinorCheatModifier = (aiBrain.MinorCheatModifier * aiBrain.MinorCheatModifier)
    end

    LOG("     "..aiBrain.Nickname.." BuildRate mult is "..newbuff.Affects.BuildRate.Mult)
    LOG("     "..aiBrain.Nickname.." Minor Cheat "..aiBrain.MinorCheatModifier.."  Major Cheat is "..aiBrain.MajorCheatModifier)

	--- reduce mass/energy used when maintaining
    local modifier = 1.0 - aiBrain.MajorCheatModifier
    
    modifier = LOUDMAX( -0.50, modifier )               -- cap the reduction at 50%

    LOG("     "..aiBrain.Nickname.." Maintenance mult (Major) is "..modifier)
    
	newbuff.Affects.EnergyMaintenance.Add = modifier
	newbuff.Affects.EnergyActive.Add = modifier
	newbuff.Affects.MassActive.Add = modifier

    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end

    --- ACU intel range buff - same as cheat bonus
    newbuff = LOUDDEEPCOPY(Buffs['CheatCDROmni'])
    newbuff.Name = 'CheatCDROmni'..aiBrain.ArmyIndex
	newbuff.Affects.VisionRadius.Mult = aiBrain.CheatValue
    newbuff.Affects.WaterVisionRadius.Mult = aiBrain.CheatValue
	newbuff.Affects.OmniRadius.Mult = aiBrain.CheatValue

    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end
	
	modifier = aiBrain.MinorCheatModifier
    LOG("     "..aiBrain.Nickname.." Intel mult (Minor) is "..modifier)    

    --- Intel buff - affects vision, radar, sonar, omni
    newbuff = LOUDDEEPCOPY(Buffs['CheatIntel'])
    newbuff.Name = 'CheatIntel'..aiBrain.ArmyIndex

	newbuff.Affects.VisionRadius.Mult = modifier
    newbuff.Affects.WaterVisionRadius.Mult = modifier
	newbuff.Affects.RadarRadius.Mult = modifier
	newbuff.Affects.OmniRadius.Mult = modifier
	newbuff.Affects.SonarRadius.Mult = modifier
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end
	    
	--- ACU storage cheat -- increases storage by the multiplier for the first few minutes of game
    newbuff = LOUDDEEPCOPY(Buffs['CheatCDREnergyStorage'])
    newbuff.Name = 'CheatCDREnergyStorage'..aiBrain.ArmyIndex
	newbuff.Affects.EnergyStorage.Mult = LOUDMAX( aiBrain.CheatValue - 1, 0.01)
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end

    newbuff = LOUDDEEPCOPY(Buffs['CheatCDRMassStorage'])
    newbuff.Name = 'CheatCDRMassStorage'..aiBrain.ArmyIndex
	newbuff.Affects.MassStorage.Mult = LOUDMAX( aiBrain.CheatValue - 1, 0.01)
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end

	modifier = aiBrain.MinorCheatModifier
    LOG("     "..aiBrain.Nickname.." HP/Regen mult (Minor) is "..modifier)    
    
	--- HP buff - alter unit HP, shield HP and regen rates
    newbuff = LOUDDEEPCOPY(Buffs['CheatALL'])
    newbuff.Name = 'CheatALL'..aiBrain.ArmyIndex
   
	newbuff.Affects.MaxHealth.Mult = modifier
    newbuff.Affects.MaxHealth.DoNoFill = false   --- prevents health from being added upon creation
	newbuff.Affects.RegenPercent.Mult = modifier
	newbuff.Affects.ShieldRegeneration.Mult = modifier
	newbuff.Affects.ShieldHealth.Mult = modifier

    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end

end

-- and this function will apply them to units as they are created
function ApplyCheatBuffs(unit)

	local LOUDENTITY = EntityCategoryContains

    -- Cheatbuffs are NOT applied to Insignificant units or NUKE/ANTI-NUKE units --
	if not LOUDENTITY( categories.INSIGNIFICANTUNIT, unit) and not LOUDENTITY((categories.NUKE + categories.ANTIMISSILE) * categories.SILO, unit ) then
    
        local aiBrain = GetAIBrain(unit)
        local ArmyIndex = aiBrain.ArmyIndex

		local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff
        local RemoveBuff = import('/lua/sim/buff.lua').RemoveBuff

		ApplyBuff(unit, 'CheatBuildRate'..ArmyIndex)		
		ApplyBuff(unit, 'CheatIncome'..ArmyIndex)
        
        if aiBrain.Personality == 'loud' then
		
            ApplyBuff(unit, 'CheatIntel'..ArmyIndex)

            ApplyBuff(unit, 'CheatALL'..ArmyIndex)
            
            ApplyBuff(unit, 'CheatMOBILE')
        
            -- Engineers have additional buffs --
            if LOUDENTITY( categories.ENGINEER, unit) then
		
                ApplyBuff(unit, 'CheatENG')
		
                if LOUDENTITY( categories.COMMAND, unit ) then 
            
                    -- if AI team is outnumbered, increase starting resources to match those of largest team
                    if aiBrain.OutnumberedRatio > 1 then

                        local outnumberratio = aiBrain.OutnumberedRatio

                        local buffDef = Buffs['CheatCDREnergyStorage'..ArmyIndex]
                        local buffAffects = buffDef.Affects
                    
                        -- this will add the difference of the outnumbered ratio to the MULT of of the cheat value
                        -- so if outnumbered 2 to 1 -- with a 10% cheat - the mult will be set to 1.1 which will 
                        -- result in a bonus equal to the starting value (ie. - 5000) plus another 10% (total 5500)
                        buffAffects.EnergyStorage.Mult = LOUDMAX( aiBrain.CheatValue - 1, 0) + (outnumberratio - 1)
                    
                        buffDef = Buffs['CheatCDRMassStorage'..ArmyIndex]
                        buffAffects = buffDef.Affects
                        buffAffects.MassStorage.Mult = LOUDMAX( aiBrain.CheatValue - 1, 0) + (outnumberratio - 1)

                        ApplyBuff(unit, 'CheatIncome'..ArmyIndex)  -- 2nd instance of resource cheat for ACU

                        ApplyBuff(unit, 'CheatCDREnergyStorage'..ArmyIndex)
                
                    end

                    ApplyBuff(unit, 'CheatCDROmni'..ArmyIndex)
                
                    if aiBrain.OutnumberedRatio > 1 then

                        -- because the 2nd Storage buff will remove the first we'll wait 45 seconds
                        WaitTicks(450)
                
                        RemoveBuff( unit, 'CheatCDREnergyStorage'..ArmyIndex )
                
                        ApplyBuff(unit, 'CheatCDRMassStorage'..ArmyIndex)
                    end
                end
            end
            
        end
	end
end

function SetArmyPoolBuff(aiBrain, AIMult)

    if not aiBrain.OriginalUpgradeIssuedPeriod then
        aiBrain.OriginalUpgradeIssuedPeriod = aiBrain.UpgradeIssuedPeriod
    end

    -- alter the AI's delay between upgrades by an additional amount equal to 25% of the AI Mult
    -- but no reductions (this formula differs from the base calcuation at game start)
    -- it compounds over time but at a more subtle rate
    modifier = math.max( 0, AIMult - 1.0 )
    modifier = 0.25 * modifier
    modifier = 1.0 + modifier
	
	-- reduce the waiting period between upgrades
	aiBrain.UpgradeIssuedPeriod = math.floor(aiBrain.OriginalUpgradeIssuedPeriod * ( 1 / modifier ))
    
    LOG("*AI DEBUG "..aiBrain.Nickname.." Upgrade Issue Delay is "..aiBrain.UpgradeIssuedPeriod.." ticks - due to Cheat")

    local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff
    local RemoveBuff = import('/lua/sim/buff.lua').RemoveBuff


    -- Modify Buildrate buff
    local buffDef = Buffs['CheatBuildRate'..aiBrain.ArmyIndex]
    local buffAffects = buffDef.Affects

    buffAffects.BuildRate.Mult = AIMult
    
    local modifier = math.min(0, 1 - AIMult)
    modifier = 0.67 * modifier
    modifier = math.max( -0.60, modifier )

	buffAffects.EnergyMaintenance.Add = modifier
	buffAffects.EnergyActive.Add = modifier
	buffAffects.MassActive.Add = modifier    


    -- Modify CheatIncome buff
    buffDef = Buffs['CheatIncome'..aiBrain.ArmyIndex]
    buffAffects = buffDef.Affects

    buffAffects.EnergyProduction.Mult = AIMult
    buffAffects.MassProduction.Mult = AIMult
    
    -- Modify CheatIntel buff
    buffDef = Buffs['CheatIntel'..aiBrain.ArmyIndex]
    buffAffects = buffDef.Affects
    
	buffAffects.VisionRadius.Mult = AIMult
    buffAffects.WaterVisionRadius.Mult = AIMult
	buffAffects.RadarRadius.Mult = AIMult
	buffAffects.OmniRadius.Mult = AIMult
	buffAffects.SonarRadius.Mult = AIMult
    
    -- Modify CheatALL buff
    buffDef = Buffs['CheatALL'..aiBrain.ArmyIndex]
    buffAffects = buffDef.Affects
    
    local modifier = math.max(0, AIMult - 1.0)
    modifier = 0.34 * modifier
    modifier = 1.0 + modifier

	buffAffects.MaxHealth.Mult = modifier
    buffAffects.MaxHealth.DoNoFill = false   -- prevents health from being added upon creation
	buffAffects.RegenPercent.Mult = modifier
	buffAffects.ShieldRegeneration.Mult = modifier
	buffAffects.ShieldHealth.Mult = modifier

    -- loop thru all the units for this AI --
    if aiBrain.BrainType == 'AI' then

        local ArmyIndex = aiBrain.ArmyIndex
        local allUnits = aiBrain:GetListOfUnits(categories.ALLUNITS, false, false)
    
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Setting Army Pool Buff to "..repr(AIMult).." at time "..GetGameTimeSeconds() )

        for _, unit in allUnits do

            -- Remove old build rate and income buffs
            -- the logic here is simple - if you don't have the buff to remove
            -- then you don't get a buff to add
            if RemoveBuff(unit, 'CheatIncome'..ArmyIndex, true) then -- true = removeAllCounts then
                ApplyBuff(unit, 'CheatIncome'..ArmyIndex)
            end
            
            if RemoveBuff(unit, 'CheatBuildRate'..ArmyIndex, true) then -- true = removeAllCounts
                ApplyBuff(unit, 'CheatBuildRate'..ArmyIndex)
            end
            
            if RemoveBuff(unit, 'CheatIntel'..ArmyIndex, true) then
                ApplyBuff(unit, 'CheatIntel'..ArmyIndex)
            end
            
            if RemoveBuff(unit, 'CheatALL'..ArmyIndex, true) then
                ApplyBuff(unit, 'CheatALL'..ArmyIndex)
            end
        end
    end
end

-- this function has been revised to factor in the value of friendly units --
function AIFindBrainNukeTargetInRangeSorian( aiBrain, launcher, maxRange, atkPri, nukeCount, oldTarget )

	local EntityCategoryContains = EntityCategoryContains

    local GetUnitsAroundPoint = GetUnitsAroundPoint
    local GetPosition = GetPosition
    
    local VDist2Sq = VDist2Sq
    local VDist3 = VDist3
	
	local massCost = 15000	-- target must be worth at least this much mass

	local function CheckCost( pos )
	
		local massValue = 0
		
		-- calc the mass value of allied units (negative)
		for k,v in GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.WALL, pos, 32, 'Ally' ) do
		
			if not v.Dead then
				massValue = massValue - __blueprints[v.BlueprintID].Economy.BuildCostMass
			end
		end
		
		-- and the mass value of enemy units (positive)
		for k,v in GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.WALL, pos, 32, 'Enemy' ) do
		
			if not v.Dead then
				massValue = massValue + __blueprints[v.BlueprintID].Economy.BuildCostMass
			end	
		end
		
		LOG("*AI DEBUG "..aiBrain.Nickname.." gets value of "..repr(massValue).." for nuke target at "..repr(pos))
		
		return massValue > massCost
    end
	
	local position = GetPosition(launcher)
	
    local targetUnits = GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.WALL, position, maxRange, 'Enemy' )
	
	local category, retUnit, retPostion, retAntis, distance
	local unitPos, antinukes, dupTarget
	
    for k,v in atkPri do
	
        category = ParseEntityCategory( v )
        retUnit = false
		retPosition = false
		retAntis = 0
        distance = false
		
        for num, unit in targetUnits do
		
            if not unit.Dead and EntityCategoryContains( category, unit ) then
			
                unitPos = GetPosition(unit)

				antiNukes = SUtils.NumberofUnitsBetweenPoints(aiBrain, position, unitPos, categories.ANTIMISSILE * categories.SILO, 90, 'Enemy')
				
				if not CheckCost( unitPos ) then
					continue
				end
				
				dupTarget = false

				for x,z in oldTarget do
				
					if unit == z or (not z.Dead and VDist3( GetPosition(z), unitPos ) < 30) then
						dupTarget = true
					end
				end
                
                local Brains = ArmyBrains
				
				for k,v in Brains do
				
					if IsAlly( v.ArmyIndex, aiBrain.ArmyIndex ) or ( aiBrain.ArmyIndex == v.ArmyIndex ) then
						
						if VDist2Sq( v.StartPosX, v.StartPosZ, unitPos[1], unitPos[3]) < (220*220) then
							dupTarget = true
						end
					end
				end
				
                if (not retUnit or (distance and VDist3( position, unitPos ) < distance)) and ((antiNukes + 2 < nukeCount or antiNukes == 0) and not dupTarget) then
				
                    retUnit = unit
					retPosition = unitPos
					retAntis = antiNukes
                    distance = VDist3( position, unitPos )
					
				elseif (not retUnit or (distance and VDist3( position, unitPos ) < distance)) and not dupTarget then
				
					for i=-1,1 do
					
						for j=-1,1 do
						
							if i ~= 0 and j~= 0 then
							
								local pos = {unitPos[1] + (i * 10), 0, unitPos[3] + (j * 10)}
								
								antiNukes = SUtils.NumberofUnitsBetweenPoints(aiBrain, position, pos, categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, 90, 'Enemy')
								
								if (antiNukes + 2 < nukeCount or antiNukes == 0) then
									retUnit = unit
									retPosition = pos
									retAntis = antiNukes
									distance = VDist3( position, unitPos )
								end
							end
							
							if retUnit then
								break
							end
							
						end
						
						if retUnit then
							break
						end
					end
                end
            end
        end
		
        if retUnit then
		
            return retUnit, retPosition, retAntis
        end
		
    end
	
    return false
end
