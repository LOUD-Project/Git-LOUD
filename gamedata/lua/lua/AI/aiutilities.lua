--  File     :  /lua/AI/aiutilities.lua

local SUtils = import('/lua/ai/sorianutilities.lua')

local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDPARSE = ParseEntityCategory
local LOUDSORT = table.sort

local VDist2 = VDist2
local VDist2Sq = VDist2Sq


-- Adds an area to the brains MustScout table
function AIAddMustScoutArea( aiBrain, location )

	if location and ( not aiBrain:IsDefeated() ) then
	
		for _,v in aiBrain.IL.MustScout do
		
			-- If there's already a location to scout within 50 of this one, don't add it.
			if VDist2Sq(v.Position[1],v.Position[3], location[1],location[3]) < 2500 then
			
				return
				
			end
			
		end
		
		LOUDINSERT( aiBrain.IL.MustScout,	{ Position = location, TaggedBy = false	} )
		
	end
	
end

-- In this function we build a table of enemies and allies and insert their 'strength' value.
-- Originally based only on structure values
-- Now based upon ALL threat values
function AIPickEnemyLogic( self, brainbool )

	local allyEnemy = false
    local armyStrengthTable = {}
	local IsEnemy = IsEnemy
    local selfIndex = self.ArmyIndex
	
	local threattypes = {'StructuresNotMex','Land','Naval'} --'OverallNotAssigned'
    
	-- Just a note here - the position used when finding an enemy should likely
    -- be based on his CURRENT PRIMARY position - and not always the starting position
    -- this will help keep him focused upon what he's already achieved
    -- rather than just switching to a stronger opponent
    
    --local testposition = self.BuilderManagers[self.PrimaryLandBase].Position or self:GetStartVector3f()
    local testposition = self.BuilderManagers['MAIN'].Position or self:GetStartVector3f()
    
    for k,v in ArmyBrains do
	
        local armyindex = v.ArmyIndex
		
        if not v:IsDefeated() and selfIndex != armyindex and not IsAlly( selfIndex, armyindex) then
		
			if IsEnemy(selfIndex, armyindex) then
            
                local insertTable = { Enemy = true, Strength = 0, Position = false, Brain = k, Alias = v.Nickname }    
            
                for _,threattype in threattypes do
			
                    local threats = self:GetThreatsAroundPosition( self.BuilderManagers.MAIN.Position, 32, true, threattype, armyindex)
                
                    -- sort the threats for closest
                    table.sort( threats, function(a,b) return VDist2Sq(a[1],a[2],testposition[1],testposition[3]) < VDist2Sq(b[1],b[2],testposition[1],testposition[3]) end )
                
                    --LOG("*AI DEBUG "..self.Nickname.." "..threattype.." Threats from "..v.Nickname.." are "..repr(threats))
                    
                    for _,data in threats do

                        if data[3] > 60 then
                        
                            if not insertTable.Position then
                                -- use the closest position that reports enough threat
                                insertTable.Position = {data[1],0,data[2]}
                            end
                            
                            -- closer targets are worth more - much more
               
                            -- distance of this enemy from current PRIMARY position
                            local distance = VDist3( testposition, {data[1],0,data[2]} )
                
                            -- adjust the strength according to distance result against the maximum possible distance on this map
                            local threatWeight = math.exp((self.dist_comp/ distance )-1)

                            threatWeight = threatWeight * data[3]
                            
                            if threatWeight > 60 then
                                -- accumulate the total enemy strength from viable positions
                                insertTable.Strength = insertTable.Strength + threatWeight
                            end
                            
                        end
                    end

                    -- make sure the value is positive
                    insertTable.Strength = math.max( insertTable.Strength, 0)
			
                    if insertTable.Strength > 35 then
                        armyStrengthTable[armyindex] = insertTable
                    end
                end
			end
        end
    end
	
	--LOG("*AI DEBUG "..self.Nickname.." Str table is "..repr(armyStrengthTable))
	
    --local allyEnemy = self:GetAllianceEnemy(armyStrengthTable, mys)
	
    -- if targetoveride is true then allow target switching
    -- the only place I see that happening is with the Sorian
    -- AI Chat functions - otherwise default is false and 
    -- allied targets don't override this one
    if allyEnemy then -- and not self.targetoveride then
	
        LOG("*AI DEBUG Switching to allied enemy")
		
        self:SetCurrentEnemy( allyEnemy )
		
		self.CurrentEnemyIndex = self:GetCurrentEnemy().ArmyIndex
		
    else
	
        local findEnemy = false
        local currenemy = self:GetCurrentEnemy()
		
        -- if there is no current enemy - or the current enemy is not generating any threat - and we are not target overridden --
        if (not currenemy or brainbool) or (currenemy and not armyStrengthTable[currenemy:GetArmyIndex()]) and not self.targetoveride then
		
            findEnemy = true
			
        elseif currenemy then
		
            local cIndex = currenemy:GetArmyIndex()
			
            -- If our current enemy has been defeated or has less than 35 strength, we need a new enemy
            if currenemy:IsDefeated() or armyStrengthTable[cIndex].Strength < 35 then
			
                findEnemy = true
            end
        end
		
		if self.DrawPlanThread then 
		
			KillThread(self.DrawPlanThread)
            self.DrawPlanThread = nil
		end	
        
        --LOG("*AI DEBUG "..self.Nickname.." says findEnemy is "..repr(findEnemy))

        if findEnemy then
		
            local enemydistance = 0
            local enemyPosition = false
            local enemyStrength = 0
            local enemy = false
			
            for k,v in armyStrengthTable do
			
                -- Ignore allies 
                if not v.Enemy then
                    continue
                end

                -- store the highest value so far -- we'll pick this as the
                -- enemy once we've checked all the enemies
                if not enemy or v.Strength > enemyStrength then
				
                    enemydistance = VDist3( testposition, v.Position )
                    
                    enemyPosition = v.Position
					enemyStrength = v.Strength
                    
                    enemy = ArmyBrains[v.Brain]
                end
            end

            -- if we've picked an enemy and have a position for them
            if enemy and enemyPosition then
            
               	local GetEnemyUnitsInRect = import('/lua/loudutilities.lua').GetEnemyUnitsInRect
                
                -- collect all the enemy units within that IMAP grid
				-- just NOTE - this will report all units - even those you don't see
				local units = GetEnemyUnitsInRect( self, enemyPosition[1]-ScenarioInfo.IMAPRadius, enemyPosition[3]-ScenarioInfo.IMAPRadius, enemyPosition[1]+ScenarioInfo.IMAPRadius, enemyPosition[3]+ScenarioInfo.IMAPRadius)

				local counter = 0

				-- these accumulate the position values
                local x1 = 0
                local x2 = 0
                local x3 = 0

				-- loop thru only those that match the category filter
				for _,v in units do

					counter = counter + 1

					local unitPos = v:GetPosition()
                    
					if unitPos and not v.Dead then
						x1 = x1 + unitPos[1]
						x2 = x2 + unitPos[2]
						x3 = x3 + unitPos[3]
					end
				end
                
                if counter > 0 then
                
                    x1 = x1/counter
                    x2 = x2/counter
                    x3 = x3/counter
                
                    --LOG("*AI DEBUG The average position for "..repr(enemyPosition).." is at "..repr({ x1, x2, x3 }))
                
                    enemyPosition = { x1,x2,x3 }

                    -- If we don't have an enemy or it's different than the one we already have
                    if not self:GetCurrentEnemy() or self:GetCurrentEnemy() != enemy then
				
                        -- set this as our current enemy
                        self:SetCurrentEnemy( enemy )
					
                        -- remember this enemy index on the brain
                        self.CurrentEnemyIndex = self:GetCurrentEnemy().ArmyIndex
					
                        -- AI will announce the current target to allies
                        SUtils.AISendChat('allies', ArmyBrains[self:GetArmyIndex()].Nickname, 'targetchat', ArmyBrains[enemy:GetArmyIndex()].Nickname)
                        
                    end
                    
                    -- if we have an enemy and we dont have an attack goal or the goal is quite different from the one we already have
                    if self.CurrentEnemyIndex and ( (not self.AttackPlanGoal) or VDist3(self.AttackPlan.Goal, enemyPosition) > 100 ) then
                    
                        --LOG("*AI DEBUG "..self.Nickname.." Choosing enemy - " ..enemy.Nickname.." position is "..repr(enemyPosition).." at distance "..repr(enemydistance).." Strength is "..repr(enemyStrength) )
					
                        -- create a new attack plan
                        self:ForkThread( import('/lua/loudutilities.lua').AttackPlanner, enemyPosition)
                    end
                end
			end
        end
		

    end
	
end

function AISortMarkersFromLastPosWithThreatCheck(aiBrain, markerlist, maxNumber, tMin, tMax, tRings, tType, position)

	local LOUDREMOVE = table.remove
    
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
    
	-- sort this list from the starting position
    LOUDSORT(markerlist, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], startPosX,startPosZ) < VDist2Sq(b.Position[1],b.Position[3], startPosX,startPosZ) end)    

    local mlist = {}
	local counter = 0
	local threat, point

    while LOUDGETN(markerlist) > 0 do
    
        point = markerlist[1].Position    -- get first entry (closest) from MarkerList
        LOUDREMOVE(markerlist, 1)   -- remove the first entry from MarkerList
        
        if threatCheck then
		
			threat = aiBrain:GetThreatAtPosition( point, 0, true, 'AntiSurface')

			if threat > threatMax then
				break
			end
			
			if threat >= threatMin then
				mlist[counter+1] = point
				counter = counter + 1
			end
			
		else
			mlist[counter+1] = point
			counter = counter + 1
        end

		-- sort the list from the new position
        LOUDSORT(markerlist, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], point[1],point[3]) < VDist2Sq(b.Position[1],b.Position[3], point[1],point[3]) end)
		
		if counter >= maxNumber then
			break
		end
    end
	
	if counter > 0 then
		return mlist
	end
	
	return false
end

-- modified this function to store the lists that would be generated for each type of marker
-- this means that each markertype only gets read and assembled ONCE for the entire session
function AIGetMarkerLocations(markerType)

	if ScenarioInfo.Env.Scenario.MasterChain[markerType] then
		return ScenarioInfo.Env.Scenario.MasterChain[markerType]
	end
	
    local markerlist = {}
	local counter = 0
    
    if markerType == 'Start Location' then
	
        local tempMarkers = AIGetMarkerLocations('Blank Marker')
		
        for k,v in tempMarkers do
		
            if string.sub(v.Name,1,5) == 'ARMY_' then 
                markerlist[counter+1] = { Position = {v.Position[1],v.Position[2],v.Position[3]}, Name = v.Name}
				counter = counter + 1
            end
        end 
    else
	
        local markers = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers  --GetMarkers()
		
        if markers then
		
            for k, v in markers do
			
                if v.type == markerType then
                    markerlist[counter+1] = { Position = {v.position[1],v.position[2],v.position[3]}, Name = k }
					counter = counter + 1
                end
            end
        end
    end

	ScenarioInfo.Env.Scenario.MasterChain[markerType] = markerlist

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
                markerlist[counter+1] = v
				counter = counter + 1
            end
        end
    end
	
    return markerlist
end

function AIGetMarkersAroundLocation( aiBrain, markerType, pos, radius, threatMin, threatMax, threatRings, threatType )

    local tempMarkers = ScenarioInfo.Env.Scenario.MasterChain[markerType] or AIGetMarkerLocations( markerType )
	
    local markerlist = {}
	local counter = 0
	
	local VDist2Sq = VDist2Sq
    local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
	local checkdistance = radius * radius
	
	if not tempMarkers then
		return {}
	end
	
	LOUDSORT(tempMarkers, function(a,b) return VDist2Sq( pos[1],pos[3], a.Position[1],a.Position[3] ) < VDist2Sq( pos[1],pos[3], b.Position[1],b.Position[3] ) end)

    for _,v in tempMarkers do
	
        if VDist2Sq( pos[1], pos[3], v.Position[1], v.Position[3] ) <= checkdistance then
		
            if not threatMin then
			
                markerlist[counter+1] = v
				counter = counter + 1
            else
			
                local threat = GetThreatAtPosition( aiBrain, v.Position, threatRings, true, threatType or 'Overall' )
				
                if threat >= threatMin and threat <= threatMax then
                    markerlist[counter+1] = v
					counter = counter + 1
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
	
    for k,v in positions do
	
        if aiBrain:GetNumUnitsAroundPoint( categories.ALLUNITS - categories.MASSEXTRACTION - categories.MASSSTORAGE - categories.MOBILE - categories.WALL, v.Position, 42, 'Ally' ) == 0 then
		
            markerlist[counter+1] = v
			counter = counter + 1
        end
    end
	
    return markerlist
end

function AIFindMarkerNeedsEngineer( aiBrain, pos, positions )

    local filterpositions = AIFilterAlliedBases( aiBrain, positions )
	
	LOUDSORT(filterpositions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], pos[1],pos[3]) < VDist2Sq(b.Position[1],b.Position[3], pos[1],pos[3]) end)
	
    for k,v in filterpositions do
	
        if not aiBrain.BuilderManagers[v.Name] then
		
			return v.Position,v.Name
        else
		
            local managers = aiBrain.BuilderManagers[v.Name]
			
            if managers.EngineerManager.EngineerList.Count == 0 and managers.FactoryManager:GetNumCategoryFactories(categories.FACTORY) < 1 then 
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
	positions = table.cat(positions, AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', point, radius, tMin, tMax, tRings, tType))
	
    LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], point[1],point[3]) < VDist2Sq(b.Position[1],b.Position[3], point[1],point[3]) end)
    
    for _,v in positions do
	
        local numUnits = GetNumberOfOwnUnitsAroundPoint( aiBrain, LOUDPARSE(category), v.Position, markerRadius )

        if numUnits <= unitMax then
			return v.Position, v.Name
        end
    end
	
    return false,nil
end

-- return the position of the closest marker of a given type
-- return false if there are none --
function AIGetClosestMarkerLocation(aiBrain, markerType, startX, startZ, extraTypes)

    local markerlist = ScenarioInfo.Env.Scenario.MasterChain[markerType] or AIGetMarkerLocations(markerType)
    
    if extraTypes then
	
        for _, pType in extraTypes do
		
            markerlist = table.cat(markerlist, ScenarioInfo.Env.Scenario.MasterChain[pType] or AIGetMarkerLocations(pType) )
        end
    end
	
	if LOUDGETN(markerlist) > 0 then
    
		LOUDSORT(markerlist, function(a,b) return VDist2Sq(a.Position[1],a.Position[3],startX,startZ) < VDist2Sq(b.Position[1],b.Position[3],startX,startZ) end)

		return markerlist[1].Position, markerlist[1].Name
	end
	
	return false,nil
end

function AIGetClosestThreatMarkerLoc(aiBrain, markerType, startX, startZ, threatMin, threatMax, rings, threatType)

    local markerlist = ScenarioInfo.Env.Scenario.MasterChain[markerType] or AIGetMarkerLocations(markerType)

    local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
    
    LOUDSORT(markerlist, function(a,b) return VDist2Sq(a.Position[1],a.Position[3],startX,startZ) < VDist2Sq(b.Position[1],b.Position[3],startX,startZ) end)

    for k, v in markerlist do
	
        local threat = GetThreatAtPosition( aiBrain, v.Position, rings, true, threatType or 'Overall')
        
        if threat >= threatMin and threat <= threatMax then
			return v.Position, v.Name
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
	
	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	local GetFractionComplete = moho.entity_methods.GetFractionComplete

    local mlist = {}
	local counter = 0
	
	if category and location and radius then
	
		local units = GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) or {}
	
		for k,v in units do
	
			if (not v.Dead) and GetFractionComplete(v) == 1 and v.Sync.army == aiBrain.ArmyIndex then
				mlist[counter+1] = v
				counter = counter + 1
			end
		end
	end
	
    return mlist
end

-- this will return a list of ALL Allied units (yours and allies)
function GetAlliedUnitsAroundPoint( aiBrain, category, location, radius )
	
	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	local GetFractionComplete = moho.entity_methods.GetFractionComplete

    local mlist = {}
	local counter = 0
	
	if category and location and radius then
	
		local units = GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) or {}
	
		for k,v in units do
	
			if (not v.Dead) and GetFractionComplete(v) == 1 then
				mlist[counter+1] = v
				counter = counter + 1
			end
		end
	end
	
    return mlist
end

function GetOwnUnitsAroundPointWithThreatCheck( aiBrain, category, location, radius, tmin, tmax, rings, tType )
	
	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
	--local GetAIBrain = moho.unit_methods.GetAIBrain
	local GetFractionComplete = moho.entity_methods.GetFractionComplete
	
    local mlist = {}
	local counter = 0

    for k,v in GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) do
	
        if (not v.Dead) and GetFractionComplete(v) == 1 and v.Sync.army == aiBrain.ArmyIndex then

			if tmin and tmax then
			
				local threat = GetThreatAtPosition( aiBrain, v:GetPosition(), rings or 1, true, tType or 'Overall' )
				
				if threat >= tmin and threat <= tmax then
			
					mlist[counter+1] = v
					counter = counter + 1
					
				end
				
			else
			
				mlist[counter+1] = v
				counter = counter + 1
				
            end
			
        end
		
    end
	
    return mlist
	
end

function GetNumberOfOwnUnitsAroundPoint( aiBrain, category, location, radius )
	
	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	local GetFractionComplete = moho.entity_methods.GetFractionComplete
	
	local counter = 0
	
    for k,v in GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' ) do
	
        if not v.Dead then
		
			if GetFractionComplete(v) == 1 and v.Sync.army == aiBrain.ArmyIndex then
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
    local mType = unit:GetBlueprint().Physics.MotionType
	
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
    
    local testCat = category
	
    if type(testCat) == 'string' then
        testCat = LOUDPARSE( testCat )
    end

    local targetUnits = aiBrain:GetUnitsAroundPoint( testCat, position, maxRange, 'Enemy' )
    
    local retUnit = false
    local distance = false
	
    for num, unit in targetUnits do
	
        if not unit.Dead then
		
            local unitPos = unit:GetPosition()
			local newdist = VDist2( position[1],position[3], unitPos[1],unitPos[3] )
			
            if not retUnit or newdist < distance then
                retUnit = unit
                distance = newdist
            end
        end
    end

    return retUnit
end

function RandomLocation(x,z, value)
	
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

-- Returns the number of slots the transport has available
-- Originally, this function just counted the number of attachpoint bones of each size on the model
-- however, this does not seem to work correctly - ie. UEF T3 Transport
-- says it has 12 Large Attachpoints but will only carry 6 large units
-- so I replaced that with some hardcoded values to improve performance, as each new transport
-- unit comes into play, I'll cache those values on the brain so I never have to look them up again
	-- setup global table to contain Transport values- in this way we always have a reference to them
	-- without having to reread the bones or do all the EntityCategory checks from below
function GetNumTransportSlots(unit, aiBrain)
	
	if not aiBrain.TransportSlotTable then
	
		aiBrain.TransportSlotTable = {}
		
	end
	
	local id = unit.BlueprintID
	
	if aiBrain.TransportSlotTable[id] then
	
		return aiBrain.TransportSlotTable[id]
		
	else
	
		local EntityCategoryContains = EntityCategoryContains
	
		local bones = { Large = 0, Medium = 0, Small = 0,}
	
		if EntityCategoryContains( categories.xea0306, unit) then
			bones.Large = 6
			bones.Medium = 10
			bones.Small = 24

		elseif EntityCategoryContains( categories.uea0203, unit) then
			bones.Large = 0
			bones.Medium = 1
			bones.Small = 1
			
		elseif EntityCategoryContains( categories.uea0104, unit) then
			bones.Large = 3
			bones.Medium = 6
			bones.Small = 14
			
		elseif EntityCategoryContains( categories.uea0107, unit) then
			bones.Large = 1
			bones.Medium = 2
			bones.Small = 6
			
			
		elseif EntityCategoryContains( categories.uaa0107, unit) then
			bones.Large = 1
			bones.Medium = 3
			bones.Small = 6

		elseif EntityCategoryContains( categories.uaa0104, unit) then
			bones.Large = 3
			bones.Medium = 6
			bones.Small = 12

			
		elseif EntityCategoryContains( categories.ura0107, unit) then
			bones.Large = 1
			bones.Medium = 2
			bones.Small = 6

		elseif EntityCategoryContains( categories.ura0104, unit) then
			bones.Large = 2
			bones.Medium = 4
			bones.Small = 10
			
			
		elseif EntityCategoryContains( categories.xsa0107, unit) then
			bones.Large = 1
			bones.Medium = 4
			bones.Small = 8

		elseif EntityCategoryContains( categories.xsa0104, unit) then
			bones.Large = 4
			bones.Medium = 8
			bones.Small = 16
		
		-- BO Aeon transport
		elseif bones.Small == 0 and (categories.baa0309 and EntityCategoryContains( categories.baa0309, unit)) then
			bones.Large = 6
			bones.Medium = 10
			bones.Small = 16
		
		-- BO Cybran transport
		elseif bones.Small == 0 and (categories.bra0309 and EntityCategoryContains( categories.bra0309, unit)) then
			bones.Large = 3
			bones.Medium = 12
			bones.Small = 14
			
		-- BrewLan Cybran transport
		elseif bones.Small == 0 and (categories.sra0306 and EntityCategoryContains( categories.sra0306, unit)) then
			bones.Large = 4
			bones.Medium = 8
			bones.Small = 16
		
		-- Gargantua
		elseif bones.Small == 0 and (categories.bra0409 and EntityCategoryContains( categories.bra0409, unit)) then
			bones.Large = 20
			bones.Medium = 4
			bones.Small = 4
		
		-- BO Sera transport
		elseif bones.Small == 0 and (categories.bsa0309 and EntityCategoryContains( categories.bsa0309, unit)) then
			bones.Large = 8
			bones.Medium = 12
			bones.Small = 28

		-- BrewLAN Seraphim transport
		elseif bones.Small == 0 and (categories.ssa0306 and EntityCategoryContains( categories.ssa0306, unit)) then
			bones.Large = 7
			bones.Medium = 15
			bones.Small = 32
			
			
			
		end
		
		aiBrain.TransportSlotTable[id] = bones
		
		--LOG ("*AI DEBUG Global Transport Slot table is now "..repr(aiBrain.TransportSlotTable) )
		return bones
	end

end

-- This function just returns the distance to the closest IMAP threat position that exceeds the threatCutoff
function GetThreatDistance(aiBrain, position, threatCutoff )

    local threatTable = aiBrain:GetThreatsAroundPosition( position, 4, true, 'StructuresNotMex')
    local closestHighThreat = 999999
	
    for k,v in threatTable do

        if v[3] > threatCutoff then
		
            local dist = VDist2( v[1], v[2], position[1], position[3] )
			
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

	local PlayerDiff = (biggestTeamSize or 1)/(aiBrain.TeamSize)
    
    aiBrain.OutnumberedRatio = PlayerDiff
   

	-- set unit cap and veterancy multiplier --
	if ScenarioInfo.Options.CapCheat == "unlimited" then
	
		aiBrain.IgnoreArmyCaps = true
		
		SetIgnoreArmyUnitCap(aiBrain.ArmyIndex, true)
		
		SetArmyUnitCap( aiBrain.ArmyIndex, 99999)

        LOG("*AI DEBUG "..aiBrain.Nickname.." Unit cap set to Unlimited")
		
	elseif ScenarioInfo.Options.CapCheat == "cheatlevel" then

        local initialCap = tonumber(ScenarioInfo.Options.UnitCap) or 750

        local cheatCap = initialCap * aiBrain.CheatValue * (math.max(PlayerDiff,1))
        
        SetArmyUnitCap( aiBrain.ArmyIndex, math.floor(cheatCap) )
        
        LOG("*AI DEBUG "..aiBrain.Nickname.." Unit cap set to "..cheatCap.." from base of "..initialCap)
    end
    
    if aiBrain.OutnumberedRatio > 1 then 
        LOG("*AI DEBUG "..aiBrain.Nickname.." OutnumberedRatio is "..aiBrain.OutnumberedRatio)
    end

	-- record the starting unit cap
	-- caps of 1000+ trigger some conditions
	aiBrain.StartingUnitCap = GetArmyUnitCap(aiBrain.ArmyIndex)

	-- start the spawn wave thread for cheating AI --
    aiBrain.WaveThread = ForkThread(import('/lua/loudutilities.lua').SpawnWaveThread, aiBrain)
end


-- This function creates the cheats used by the AI
-- now creates buffs for EACH AI -- allowing us to move ahead
-- with AI having independant mutlipliers and supporting the
-- more recent adaptive cheat multipliers which require this
-- to work properly
function SetupAICheat(aiBrain, biggestTeamSize)

    LOG("*AI DEBUG "..aiBrain.Nickname.." SetupAICheat for ArmyIndex "..repr(aiBrain.ArmyIndex).." Value "..aiBrain.CheatValue)

    -- Veterancy mult is always 1 or higher
    aiBrain.VeterancyMult = math.max( 1, aiBrain.CheatValue)

	-- CREATE THE BUFFS THAT WILL BE USED BY THE AI
    local modifier = 1

	-- build rate cheat
    local newbuff = table.deepcopy(Buffs['CheatBuildRate'])
    
    newbuff.Name = 'CheatBuildRate'..aiBrain.ArmyIndex
    
    newbuff.Affects.BuildRate.Mult = aiBrain.CheatValue
	
	-- reduce mass/energy used when building and maintaining
	-- but only at 75% of the multiplier (ie. at 1.1 this would be a 7.5% reduction
    -- and only when multiplier > 1
    -- so this value will always be 0 or negative
    -- put a floor of -0.60 on this -- since we're reaching near zero consumption
    modifier = math.min(0, 1 - aiBrain.CheatValue)
    modifier = 0.75 * modifier
    modifier = math.max( -0.60, modifier )

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


	-- resource rate cheat buff
    newbuff = table.deepcopy(Buffs['CheatIncome'])
    
    newbuff.Name = 'CheatIncome'..aiBrain.ArmyIndex
	newbuff.Affects.EnergyProduction.Mult = aiBrain.CheatValue
	newbuff.Affects.MassProduction.Mult = aiBrain.CheatValue
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end


	-- intel range cheat -- increases intel ranges by the multiplier
    newbuff = table.deepcopy(Buffs['CheatIntel'])
    
    newbuff.Name = 'CheatIntel'..aiBrain.ArmyIndex
	newbuff.Affects.VisionRadius.Mult = aiBrain.CheatValue
    newbuff.Affects.WaterVisionRadius.Mult = aiBrain.CheatValue    
	newbuff.Affects.RadarRadius.Mult = aiBrain.CheatValue
	newbuff.Affects.OmniRadius.Mult = aiBrain.CheatValue
	newbuff.Affects.SonarRadius.Mult = aiBrain.CheatValue
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end


    -- ACU intel range buff
    newbuff = table.deepcopy(Buffs['CheatCDROmni'])
    
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
	
    
	-- storage cheat -- increases storage by the multiplier - only used on the ACU
    newbuff = table.deepcopy(Buffs['CheatEnergyStorage'])
    
    newbuff.Name = 'CheatEnergyStorage'..aiBrain.ArmyIndex
	newbuff.Affects.EnergyStorage.Mult = math.max( aiBrain.CheatValue - 1, 0)
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end

    
    newbuff = table.deepcopy(Buffs['CheatMassStorage'])
    
    newbuff.Name = 'CheatMassStorage'..aiBrain.ArmyIndex
	newbuff.Affects.MassStorage.Mult = math.max( aiBrain.CheatValue - 1, 0)
    
    if not Buffs[newbuff.Name] then
		
        BuffBlueprint {
            Name = newbuff.Name,
            BuffType = newbuff.BuffType,
            Stacks = newbuff.Stacks,
            Duration = newbuff.Duration,
            Affects = newbuff.Affects,
        }
    end
    
	-- overall cheat buff -- applied at 40% of the multiplier
	-- alter unit health, shield health and regen rates
    
	-- reduce the delay period between upgrades
    -- and only when multiplier => 1
    newbuff = table.deepcopy(Buffs['CheatALL'])
    
    newbuff.Name = 'CheatALL'..aiBrain.ArmyIndex
	
	modifier = math.max( 0, aiBrain.CheatValue - 1.0 )
	modifier = 0.4 * modifier
	modifier = 1.0 + modifier

	newbuff.Affects.MaxHealth.Mult = modifier
    newbuff.Affects.MaxHealth.DoNoFill = true   -- prevents health from being added upon creation
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

	
	-- reduce the waiting period between upgrades by 50% of the AIMult
	aiBrain.UpgradeIssuedPeriod = math.floor(aiBrain.UpgradeIssuedPeriod * ( 1 / modifier ))
    
    --LOG("*AI DEBUG "..aiBrain.Nickname.." Upgrade Issued period(delay) is "..aiBrain.UpgradeIssuedPeriod)
    
end


-- and this function will apply them to units as they are created
function ApplyCheatBuffs(unit)

	local LOUDENTITY = EntityCategoryContains

    -- Cheatbuffs are NOT applied to Insignificant units or NUKE/ANTI-NUKE units --
	if not LOUDENTITY( categories.INSIGNIFICANTUNIT, unit) and not LOUDENTITY((categories.NUKE + categories.ANTIMISSILE) * categories.SILO, unit ) then
    
        local aiBrain = unit:GetAIBrain()
        
        --LOG("*AI DEBUG "..brain.Nickname.." Applying Cheat Buffs to "..unit:GetBlueprint().Description)

		local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff
        local RemoveBuff = import('/lua/sim/buff.lua').RemoveBuff

		ApplyBuff(unit, 'CheatBuildRate'..aiBrain.ArmyIndex)		
		ApplyBuff(unit, 'CheatIncome'..aiBrain.ArmyIndex)
		ApplyBuff(unit, 'CheatIntel'..aiBrain.ArmyIndex)

		ApplyBuff(unit, 'CheatALL'..aiBrain.ArmyIndex)
        
        -- Engineers have additional buffs --
		if LOUDENTITY( categories.ENGINEER, unit) then
		
			ApplyBuff(unit, 'CheatENG')
		
			if LOUDENTITY( categories.COMMAND, unit ) then 
            
                -- if AI team is outnumbered, increase starting resources to match those of largest team
                if aiBrain.OutnumberedRatio > 1 then

                    local outnumberratio = aiBrain.OutnumberedRatio

                    local buffDef = Buffs['CheatEnergyStorage'..aiBrain.ArmyIndex]
                    local buffAffects = buffDef.Affects
                    
                    buffAffects.EnergyStorage.Mult = math.max( aiBrain.CheatValue - 1, 0) * outnumberratio
                    
                    buffDef = Buffs['CheatMassStorage'..aiBrain.ArmyIndex]
                    buffAffects = buffDef.Affects
                    buffAffects.MassStorage.Mult = math.max( aiBrain.CheatValue - 1, 0) * outnumberratio

                    ApplyBuff(unit, 'CheatIncome'..aiBrain.ArmyIndex)  -- 2nd instance of resource cheat for ACU
                end

                ApplyBuff(unit, 'CheatEnergyStorage'..aiBrain.ArmyIndex)

				ApplyBuff(unit, 'CheatCDROmni'..aiBrain.ArmyIndex)

                -- because the 2nd Storage buff will remove the first we'll wait 40 seconds
                WaitTicks(400)
                
                RemoveBuff( unit, 'CheatEnergyStorage'..aiBrain.ArmyIndex )
                
                ApplyBuff(unit, 'CheatMassStorage'..aiBrain.ArmyIndex)
			end
		end
	end
end

function SetArmyPoolBuff(aiBrain, AIMult)

    local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff
    local RemoveBuff = import('/lua/sim/buff.lua').RemoveBuff


    -- Modify Buildrate buff
    local buffDef = Buffs['CheatBuildRate'..aiBrain.ArmyIndex]
    local buffAffects = buffDef.Affects

    buffAffects.BuildRate.Mult = AIMult

    -- Modify CheatIncome buff
    buffDef = Buffs['CheatIncome'..aiBrain.ArmyIndex]
    buffAffects = buffDef.Affects

    buffAffects.EnergyProduction.Mult = AIMult
    buffAffects.MassProduction.Mult = AIMult

    -- loop thru all the units for this AI --
    if aiBrain.BrainType == 'AI' then

        local allUnits = aiBrain:GetListOfUnits(categories.ALLUNITS, false, false)
    
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Setting Army Pool Buff to "..repr(AIMult).." at time "..GetGameTimeSeconds() )

        for _, unit in allUnits do

            -- Remove old build rate and income buffs
            -- the logic here is simple - if you don't have the buff to remove
            -- then you don't get a buff to add
            if RemoveBuff(unit, 'CheatIncome'..aiBrain.ArmyIndex, true) then -- true = removeAllCounts then
                ApplyBuff(unit, 'CheatIncome'..aiBrain.ArmyIndex)
            end
            
            if RemoveBuff(unit, 'CheatBuildRate'..aiBrain.ArmyIndex, true) then -- true = removeAllCounts
                ApplyBuff(unit, 'CheatBuildRate'..aiBrain.ArmyIndex)
            end
        end
    end
end

-- this function has been revised to factor in the value of friendly units --
function AIFindBrainNukeTargetInRangeSorian( aiBrain, launcher, maxRange, atkPri, nukeCount, oldTarget )

	local GetBlueprint = moho.entity_methods.GetBlueprint
    local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	
	local massCost = 15000	-- target must be worth at least this much mass

	local function CheckCost( pos )
	
		local massValue = 0
		
		-- calc the mass value of allied units (negative)
		for k,v in GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.WALL, pos, 32, 'Ally' ) do
		
			if not v.Dead then
				massValue = massValue - GetBlueprint(v).Economy.BuildCostMass
			end
		end
		
		-- and the mass value of enemy units (positive)
		for k,v in GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.WALL, pos, 32, 'Enemy' ) do
		
			if not v.Dead then
				massValue = massValue + GetBlueprint(v).Economy.BuildCostMass
			end	
		end
		
		LOG("*AI DEBUG "..aiBrain.Nickname.." gets value of "..repr(massValue).." for nuke target at "..repr(pos))
		
		return massValue > massCost
    end
	
	local position = launcher:GetPosition()
	
    local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS - categories.WALL, position, maxRange, 'Enemy' )
	
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
			
                unitPos = unit:GetPosition()

				antiNukes = SUtils.NumberofUnitsBetweenPoints(aiBrain, position, unitPos, categories.ANTIMISSILE * categories.SILO, 90, 'Enemy')
				
				if not CheckCost( unitPos ) then
					continue
				end
				
				dupTarget = false
				
				local XZDistanceTwoVectors = import('/lua/utilities.lua').XZDistanceTwoVectors
				
				for x,z in oldTarget do
				
					if unit == z or (not z.Dead and XZDistanceTwoVectors( z:GetPosition(), unitPos ) < 30) then
						dupTarget = true
					end
				end
				
				for k,v in ArmyBrains do
				
					if IsAlly( v.ArmyIndex, aiBrain.ArmyIndex ) or ( aiBrain.ArmyIndex == v.ArmyIndex ) then
						
						if VDist2Sq( v.StartPosX, v.StartPosZ, unitPos[1], unitPos[3]) < (220*220) then
							dupTarget = true
						end
					end
				end
				
                if (not retUnit or (distance and XZDistanceTwoVectors( position, unitPos ) < distance)) and ((antiNukes + 2 < nukeCount or antiNukes == 0) and not dupTarget) then
				
                    retUnit = unit
					retPosition = unitPos
					retAntis = antiNukes
                    distance = XZDistanceTwoVectors( position, unitPos )
					
				elseif (not retUnit or (distance and XZDistanceTwoVectors( position, unitPos ) < distance)) and not dupTarget then
				
					for i=-1,1 do
					
						for j=-1,1 do
						
							if i ~= 0 and j~= 0 then
							
								local pos = {unitPos[1] + (i * 10), 0, unitPos[3] + (j * 10)}
								
								antiNukes = SUtils.NumberofUnitsBetweenPoints(aiBrain, position, pos, categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, 90, 'Enemy')
								
								if (antiNukes + 2 < nukeCount or antiNukes == 0) then
									retUnit = unit
									retPosition = pos
									retAntis = antiNukes
									distance = XZDistanceTwoVectors( position, unitPos )
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

