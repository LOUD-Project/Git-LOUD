--**  File     :  /lua/AI/aiattackutilities.lua

local LOUDCOPY = table.copy
local LOUDPARSE = ParseEntityCategory
local LOUDSORT = table.sort

local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local WaitTicks = coroutine.yield

local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits

local ALLBUTWALLS = categories.ALLUNITS - categories.WALL
local SHIELDS = categories.SHIELD * categories.STRUCTURE

-- determines the max range of a naval platoon and returns the weapon arc and turret pitch range

function GetNavalPlatoonMaxRange(aiBrain, platoon)

    local maxRange = 0
	local selectedWeaponArc = 'none'
	local turretPitch = nil
    
    for _,unit in GetPlatoonUnits(platoon) do
    
        if not unit.Dead then
        
			for _,weapon in __blueprints[unit.BlueprintID].Weapon do
			
				-- weapon must be able to fire FROM the Water layer and not be a nuke
				if weapon.NukeWeapon or not weapon.FireTargetLayerCapsTable or not weapon.FireTargetLayerCapsTable.Water then
					continue
				end
        
				-- we'll exclude any weapon that can target the Air layer -- 
				local AttackAir = string.find(weapon.FireTargetLayerCapsTable.Water, 'Air', 1, true)
				local AttackSur = string.find(weapon.FireTargetLayerCapsTable.Water, 'Land',1, true)
            
				if (not AttackAir) and AttackSur and weapon.MaxRadius > maxRange then
				
					if weapon.BallisticArc == 'RULEUBA_LowArc' then
					
						selectedWeaponArc = 'low'
						turretPitch = weapon.TurretPitchRange
						
					elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
					
						selectedWeaponArc = 'high'
						turretPitch = weapon.TurretPitchRange
						
					elseif weapon.BallisticArc == 'RULEUBA_None' and weapon.TurretPitchRange > 0 then
					
						selectedWeaponArc = 'none'
						turretPitch = weapon.TurretPitchRange
						
					elseif weapon.BallisticArc == 'RULEUBA_None' then
					
						selectedWeaponArc = 'none'
						turretPitch = nil
						
					else
						continue
					end
					
					maxRange = weapon.MaxRadius
				end
			end
		end
    end
    
    if maxRange == 0 then
        return false,'none', nil
    end
	
    return maxRange, selectedWeaponArc, turretPitch
end

-- A change here to save a lot of processing - if the layer is already set just
-- return otherwise we'll pass thru and set the platoon layer by looking at every unit
function GetMostRestrictiveLayer(platoon)

	if platoon.Movementlayer then

        for _,v in GetPlatoonUnits(platoon) do
		
            if not v.Dead then
			
                return
				
            end
			
        end
		
    end
    
    platoon.MovementLayer = 'Air' 	-- default value for all to start
	
	local mType
	
    for _,v in GetPlatoonUnits(platoon) do
	
        if not v.Dead then
		
            mType = __blueprints[v.BlueprintID].Physics.MotionType
			
            if ( mType == 'RULEUMT_AmphibiousFloating' or mType == 'RULEUMT_Hover' or mType == 'RULEUMT_Amphibious' ) and ( platoon.MovementLayer == 'Air' or platoon.MovementLayer == 'Water' ) then
			
                platoon.MovementLayer = 'Amphibious'

            elseif (mType == 'RULEUMT_Water' or mType == 'RULEUMT_SurfacingSub') and ( platoon.MovementLayer ~= 'Water' ) then
			
                platoon.MovementLayer = 'Water'
                break   --Nothing more restrictive than water, since there should be no mixed land/water platoons
				
            elseif mType == 'RULEUMT_Air' and platoon.MovementLayer == 'Air' then
			
                platoon.MovementLayer = 'Air'

            elseif ( mType == 'RULEUMT_Biped' or mType == 'RULEUMT_Land' ) and platoon.MovementLayer ~= 'Land' then
			
                platoon.MovementLayer = 'Land'
                break   --Nothing more restrictive than land, since there should be no mixed land/water platoons
                
            end
            
        end
        
    end
	
    return
end

--	Gets the name of the closest pathing node (within radius distance of location) on the layer we specify.
--	Returns:  true/false and position of closest node
function GetClosestPathNodeInRadiusByLayer(location, layer)

	local nodes = ScenarioInfo.PathGraphs['RawPaths'][layer] or false
	
	if nodes then

		local LayerLimits = { Air = 300, Amphibious = 200, Land = 160, Water = 250 }
		local radius = LayerLimits[layer]

		-- sort the markers for this layer by closest to location
		LOUDSORT( nodes, function(a,b) return VDist2Sq(a.position[1],a.position[3], location[1],location[3]) < VDist2Sq(b.position[1],b.position[3], location[1],location[3]) end )

		-- if the first result is within radius then respond
		if VDist2Sq( nodes[1].position[1],nodes[1].position[3], location[1],location[3]) <= (radius*radius) then
			return true, nodes[1].position
        end
        
	end

	return false, nil
end

--	This function uses Graph Node markers in the map to fill in some global data for pathfinding - generally only runs once
--	Returns: A table of graphs. Table format is: 
--           ScenarioInfo.PathGraphs -> Graph Layer -> Graph Name          -> Marker Name -> Marker Data
--							ie.		  'Amphibious' -> 'DefaultAmphibious' -> 'AmphPN11'  -> various data about that node

-- AUGUST 2016 - REVISION - removed the Graph Name from the data structure so we have as follows;
--							ie.       'Amphibious' -> 'AmphPN11'  -> data about that node
-- ceased storing the graph name in the RawPaths table since it wasn't used
function GetPathGraphs()

    local LOUDINSERT = table.insert

    if not ScenarioInfo.PathGraphs then 
		
		local AIGetMarkerLocationsEx = import('/lua/ai/aiutilities.lua').AIGetMarkerLocationsEx
        local InWaterCheck = LocationInWaterCheck

		-- create the persistent tables --
		ScenarioInfo.PathGraphs = { ['RawPaths'] = {}, ['Air'] = {}, ['Amphibious'] = {}, ['Land'] = {}, ['Water'] = {} }
		ScenarioInfo.BadPaths = { ['Air'] = {}, ['Amphibious'] = {}, ['Land'] = {}, ['Water'] = {} }
    
		-- get all the marker data for the 4 layers --
		local markerGroups = {
			Land = AIGetMarkerLocationsEx( nil,'Land Path Node') or {},
			Water = AIGetMarkerLocationsEx( nil,'Water Path Node') or {},
			Air = AIGetMarkerLocationsEx( nil, 'Air Path Node') or {},
			Amphibious = AIGetMarkerLocationsEx( nil,'Amphibious Path Node') or {},
		}
		
		local adj, newadj, counter
	
		-- parse the marker data into our persistent tables --
		-- by processing each of the 4 layers
		for k, v in markerGroups do
		
			for _, marker in v do
            
				ScenarioInfo.PathGraphs[k] = ScenarioInfo.PathGraphs[k] or {}
				ScenarioInfo.PathGraphs['RawPaths'][k] = ScenarioInfo.PathGraphs['RawPaths'][k] or {}
            
				-- parse the marker and build table of adjacent nodes --
				adj = STR_GetTokens(marker.adjacentTo, ' ')
				newadj = {}
				counter = 1
				
				for _,v in adj do
					newadj[counter] = v
					counter = counter + 1
				end
                
                -- record if a position is in the water or not 
                -- this is used in pathfinding to give preference to certain movements for
                -- amphibious platoons
                local water = false
                
                if InWaterCheck( {marker.position[1], marker.position[2], marker.position[3]} ) then
                    water = true
                end
				
				-- sort the adjacent nodes by name
				LOUDSORT(newadj)

				ScenarioInfo.PathGraphs[k][marker.name] = { marker.name, position = {marker.position[1],marker.position[2],marker.position[3]}, adjacent = LOUDCOPY(newadj), InWater = water }
				
				LOUDINSERT(ScenarioInfo.PathGraphs['RawPaths'][k], { position = { marker.position[1],marker.position[2],marker.position[3] }, node = marker.name } )
			end
		end

		local mapsizex = ScenarioInfo.size[1]
		local mapsizez = ScenarioInfo.size[2]

		-- What we'll do here is calculate the distance between adjacent points in the graph
		-- and store it with the adjacent points - this will eliminate the need to do
		-- calculations during pathfinding - as it's all done up front
		counter = 0
		
		local badpoint,x,y,z
		
		for gk, graph in ScenarioInfo.PathGraphs do
		
			if gk != 'RawPaths' then
			
				for mn, mdata in graph do	--marker do
				
					badpoint = false
					
					x,y,z = unpack(mdata.position)

					if x<0 or y<0 or z<0 or x>mapsizex or z>mapsizez then
						LOG("*AI DEBUG marker "..repr(mn).." is outside map boundaries!")
						continue
					end
				
					-- a point MUST be connected to something
					if not mdata.adjacent[1] then
						badpoint = true
					end
					
					for k, adj in mdata.adjacent do
					
						if ScenarioInfo.PathGraphs[gk][adj] then
					
							if badpoint then
								badpoint = false
							end
						
							counter = counter + 1
						
							local DComp = math.floor( VDist2( mdata.position[1],mdata.position[3], ScenarioInfo.PathGraphs[gk][adj].position[1], ScenarioInfo.PathGraphs[gk][adj].position[3] ) )
						
							ScenarioInfo.PathGraphs[gk][mn].adjacent[k] = { adj, DComp }
						else
						
							WARN("*AI DEBUG adjacent marker "..repr(gk).." "..repr(adj).." reports no position in data for "..repr(mn))
							mdata.adjacent[k] = nil	-- the adjacent node does not exist -- remove it from the RawPaths data --
                            
						end
                        
					end

					if badpoint then
						LOG("*AI DEBUG marker "..repr(mn).." at position "..repr(mdata.position).." has no ajacent connections")
					end
				end
			end
		end
    end

    return ScenarioInfo.PathGraphs or {}
end

--	Checks to see if platoon can path to destination using path graphs. Used to save precious precious CPU cycles compared to CanPathTo
--	Note - this is a very efficient check - BUT - it has one glaring flaw - it doesnt tell you if you can path between the two points
--	You may very well be on the same layer (ie. - land) but you could be seperated by a geographical barrier - only the CanPathTo check 
--	can tell you that with any certainty
function CanGraphTo( unitposition, destinationposition, layer )

	-- if there is a layer node within range of start position
    if GetClosestPathNodeInRadiusByLayer( unitposition, layer or 'Land') then
	
		-- see if there is a layer node within range of the destination
		return GetClosestPathNodeInRadiusByLayer( destinationposition, layer or 'Land')
    end
	
	return false, nil
end

-- this is a rather broad function that fills several flexible needs
-- it is exclusively used by GuardPoint behaviors
function FindPointMeetsConditions( self, aiBrain, PointType, PointCategory, PointSource, PointRadius, PointSort, PointFaction, DistMin, DistMax, shouldcheckAvoidBases, StrCategory, StrRadius, StrMin, StrMax, UntCategory, UntRadius, UntMin, UntMax, allowinwater, threatmin, threatmax, threattype)
	
	local platpos = GetPlatoonPosition(self)

	if not platpos then
		return false
	end
    
    local ThreatMaxIMAPAdjustment = 1
    
    -- maps less than or greater than 20K alter the effect of the ThreatMax value
    if ScenarioInfo.IMAPSize < 60 then
    
        ThreatMaxIMAPAdjustment = 0.8
        
    elseif ScenarioInfo.IMAPSize > 120 then
    
        ThreatMaxIMAPAdjustment = 1.2
        
    elseif ScenarioInfo.IMAPSize > 250 then
    
        ThreatMaxIMAPAdjustment = 1.66
        
    end
    
    -- adjust allowed threat by size of IMAP blocks
    local threatmax = threatmax * ThreatMaxIMAPAdjustment
	
	local AIGetMarkerLocations = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
	local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
	
	local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint

	local LOUDV2 = VDist2
	local LOUDV3 = VDist3
	
	-- Checks radius around base to see if marker is sufficiently far away
	-- this function is used to filter out positions that
	-- might be within an Allied partners base (or his own)
	local function AvoidsBases( markerPos, shouldcheckAvoidBases, baseRadius )
	
		-- if AvoidBases flag is true then do the check 
        if shouldcheckAvoidBases == true then 
        
            local Brains = ArmyBrains
		
			-- loop thru all brains
			for _, brain in Brains do
			
				-- if not defeated and it's ourselves or an Ally
				if not brain:IsDefeated() and ( aiBrain.ArmyIndex == brain.ArmyIndex or IsAlly(aiBrain.ArmyIndex, brain.ArmyIndex)) then
				
					-- loop thru his bases
					for _,base in brain.BuilderManagers do
					
						-- if position is within the radius then return false (avoid this position)
						if VDist2Sq(base.Position[1], base.Position[3], markerPos[1], markerPos[3]) < (baseRadius * baseRadius) then
						
							return false
						end
                        
					end
                    
				end
                
			end
            
		end
		
		-- position is ok (not within radius of an Allied base)
        return true
    end	
	
	if PointType == 'Unit' and type(PointCategory) == 'string' then
		PointCategory = LOUDPARSE(PointCategory)
	end
	
	if type(StrCategory) == 'string' then
		StrCategory = LOUDPARSE(StrCategory)
	end
	
	if type(UntCategory) == 'string' then
		UntCategory = LOUDPARSE(UntCategory)
	end
	
	--- Assemble the basic list of points either for Units or Markers and then for Self or not Self within that
	-- filter for distance now and filter for Allied bases if AvoidBases is true

	-- I factor the platoons distance to the points as part of the distance sorting
	-- this insures that when seeking points when it's out in the field, it will
	-- select points closest or furthest from itself depending upon the Pointsort value
	
	local pointlist = {}
	local positions = {}
	local counter = 1

	local pos, distance, platdistance
    
    local function PositionInPlayableArea(intelpoint)
    
        if ScenarioInfo.MapData.PlayableRect then
        
            local PlayableArea = ScenarioInfo.MapData.PlayableRect
            
            if intelpoint[1] < PlayableArea[1] or intelpoint[1] > PlayableArea[3] then
                return false
            end
            
            if intelpoint[3] < PlayableArea[2] or intelpoint[3] > PlayableArea[4] then
                return false
            end

        end
        
        return true
    end
	
	-- find positions -- 
	if PointType == 'Unit' then
	
		if PointFaction == 'Self' then
			pointlist = GetOwnUnitsAroundPoint( aiBrain, PointCategory, PointSource, PointRadius )
		else
            if PointFaction == 'Enemy' then
                pointlist = GetUnitsAroundPoint( aiBrain, PointCategory, PointSource, PointRadius, 'Enemy' )
            else
                pointlist = GetUnitsAroundPoint( aiBrain, PointCategory, PointSource, PointRadius, 'Ally' )
            end
		end
 
        -- filter out points by distance from source --
		for k,v in pointlist do
		
			pos = v:GetPosition()
            
			distance = LOUDV2(PointSource[1],PointSource[3], pos[1],pos[3])

			if distance >= DistMin and distance <= DistMax then
            
                -- how far is the platoon from that target
                platdistance = LOUDV2(platpos[1],platpos[3], pos[1],pos[3])            
			
				-- check if in range of Allied Base
				if AvoidsBases( pos, shouldcheckAvoidBases, DistMin) then
                
                    -- if not too close to Allied base - store it with both distances -
					positions[counter] = {pos[1], pos[2], pos[3], distance, platdistance } 
					counter = counter + 1
				end
                
			end
            
		end
		
	elseif PointType == 'Marker' then

		if PointCategory != 'BASE' then

			-- added support for multiple point categories
			-- so we can now feed it a string or a table of strings
			local CheckCategory
			
			if type(PointCategory) == 'string' then
				CheckCategory = { PointCategory }
			else
				CheckCategory = LOUDCOPY( PointCategory )
			end
			
			for _,cat in CheckCategory do
				pointlist = table.cat(pointlist, ScenarioInfo.Env.Scenario.MasterChain[ cat ] or AIGetMarkerLocations( cat ) )
			end
		
			if pointlist[1] and PointSource then

				-- sort the list by distance from source 
				LOUDSORT( pointlist, function(a,b) return LOUDV2(PointSource[1],PointSource[3],a.Position[1],a.Position[3]) < LOUDV2( PointSource[1],PointSource[3],b.Position[1],b.Position[3] ) end)
				
				for k,v in pointlist do
               
                    -- point must be in Playable Area --
                    if PositionInPlayableArea(v.Position) then
				
                        -- calculate the distance to the point from the PointSource
                        distance = LOUDV2( PointSource[1],PointSource[3], v.Position[1],v.Position[3] )
					
                        if distance <= DistMax then
					
                            if distance >= DistMin then
					
                                -- check if in range of Allied Base
                                if AvoidsBases( v.Position, shouldcheckAvoidBases, DistMin ) then
						
                                    -- the distance between the platoon and the PointSource
                                    platdistance = LOUDV2(platpos[1],platpos[3], v.Position[1],v.Position[3])

                                    -- insert it into the list of possible choices --
                                    positions[counter] = {v.Position[1], v.Position[2], v.Position[3], distance, platdistance }
							
                                    counter = counter + 1
                                end
                                
                            end
                            
                        else
                        
                            break -- beyond max distance stop checking --
                        end
                        
                    end
                    
                end
                
            end
            
		else
			-- using BASE as the pointsource tells us that our present base is inserted into the list - distance is 0
			-- and it will be the ONLY entry in the point list
			positions[counter] = { PointSource[1], PointSource[2], PointSource[3], 0, 0 }
			counter = counter + 1
		end
	end

	-- if there are positions to check --
	if counter > 1 then
	
		local previous = nil

		--- Filter points for duplications, underwater and general threatlevels
		-- The duplicate check removes the flaw that has items that are upgrading appear twice in the list
		for k,v in positions do
       
			-- filter out targets in the water
			if allowinwater == "false" then
			
				if (GetTerrainHeight(v[1], v[3])) <= (GetSurfaceHeight(v[1], v[3]) - 1) then
					positions[k]=nil
					counter = counter - 1
					continue
				end
			end
			
			-- only allow targets that are in the water
			if allowinwater == "Only" then
				if (GetTerrainHeight( v[1], v[3] )) > (GetSurfaceHeight( v[1], v[3] ) - 1) then

					positions[k] = nil
					counter = counter - 1
					continue
				end
			end
       
			-- threat checks can be bypassed entirely with these values
			if threatmin != -999999 and threatmax != 999999 then
			
				local threatatpoint = GetThreatAtPosition( aiBrain, {v[1],v[2],v[3]}, 2, true, threattype )
	
				if (threatatpoint < threatmin or threatatpoint > threatmax) then

                    -- remove this position from list
					positions[k]=nil
					counter = counter - 1
					
					-- track the position thas was just checked
					previous = v 	-- to prevent duplicates
					continue
				else
                    -- record threat at the position
                    positions[k][6] = threatatpoint
                end
			end

			-- structure count check --
	
			if StrCategory then
			
				if self:GuardPointStructureCheck(  aiBrain, v, StrCategory, StrRadius, PointFaction, StrMin, StrMax) then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." Find Point for "..self.BuilderName.." removes position "..repr(v).." for structures at "..repr(StrRadius).." - max is "..StrMax )
  
					positions[k] = nil
					counter = counter - 1
					continue
				end
			end
			
			-- unit count check --
			if UntCategory then
			
				if self:GuardPointUnitCheck( aiBrain, v, UntCategory, UntRadius, PointFaction, UntMin, UntMax) then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." Find Point for "..self.BuilderName.." removes position "..repr(v).." for units at "..repr(UntRadius).." - max is "..UntMax )
  
					positions[k] = nil
					counter = counter - 1
					continue
				end
                
			end	
            
		end

    end 

	--- Sort according to distance
	if counter > 1 then
	
		positions = aiBrain:RebuildTable(positions)
		
		if PointSort == 'Closest' then
        
            -- sort by safest + closest
            LOUDSORT(positions, function(a,b)   return (a[6]+ (a[4]+a[5])) <  (b[6]+ (b[4]+b[5]))  end)

			--LOUDSORT(positions, function(a,b)	return (a[4]+a[5]) < (b[4]+b[5]) end)
			
		elseif PointSort == 'Furthest' then
		
			LOUDSORT(positions, function(a,b)	return (a[4]-a[5]) > (b[4]-b[5]) end)
		
        else
        
            -- sort by safest + closest
            LOUDSORT(positions, function(a,b)   return (a[6]+ (a[4]+a[5])) <  (b[6]+ (b[4]+b[5]))  end)
            
        end
		
		return {positions[1]}
	end
	
	return false
end	

-- this function locates a target for a squad within a given range and list of priority target types
-- returning an actual unit and its position -- modified to include the nolayercheck option
function FindTargetInRange( self, aiBrain, squad, maxRange, attackcategories, nolayercheck )

	local PlatoonExists = moho.aibrain_methods.PlatoonExists	
	
	-- check if platoon exists --
    local position = GetPlatoonPosition(self) or false
    
	if not position or not maxRange then
		return false,false
	end
	
    if PlatoonExists( aiBrain, self) then

        -- are there any enemy units ?
        if aiBrain:GetNumUnitsAroundPoint( ALLBUTWALLS, position, maxRange, 'Enemy' ) < 1 then
            return false, false
        end

		-- the intent of this function is to make sure that we don't try and respond over mountains
		-- and rivers and other serious terrain blockages -- these are generally identified by
        -- a rapid elevation change over a very short distance
		local function CheckBlockingTerrain( pos, targetPos )  
        
            if self.MovementLayer == 'Air' then
                return false
            end
	
			-- This gives us the number of approx. 6 ogrid steps in the distance
			local steps = math.floor( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 6 )
	
			local xstep = (pos[1] - targetPos[1]) / steps -- how much the X value will change from step to step
			local ystep = (pos[3] - targetPos[3]) / steps -- how much the Y value will change from step to step
			
			local lastpos = {pos[1], 0, pos[3]}
	
			-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
			for i = 0, steps do
	
				if i > 0 then
		
					local nextpos = { pos[1] - (xstep * i), 0, pos[3] - (ystep * i)}
			
					-- Get height for both points
					local lastposHeight = GetTerrainHeight( lastpos[1], lastpos[3] )
                    
                    local InWater = lastposHeight < (GetSurfaceHeight( lastpos[1], lastpos[3] ) - 1)
                    
					local nextposHeight = GetTerrainHeight( nextpos[1], nextpos[3] )
					
					-- if more than 3.6 ogrids change in height over 6 ogrids distance
					if math.abs(lastposHeight - nextposHeight) > 3.6 or InWater then
						
						-- we are obstructed
						return true
					end
					
					lastpos = nextpos
                end
			end
	
			return false
		end
	
        local GetPosition = moho.entity_methods.GetPosition
        local CanAttackTarget = moho.platoon_methods.CanAttackTarget
        local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
        local EntityCategoryFilterDown = EntityCategoryFilterDown
        local VDist2Sq = VDist2Sq
	
		local enemyunits = GetUnitsAroundPoint( aiBrain, ALLBUTWALLS, position, maxRange, 'Enemy')

		-- sort them by distance
		LOUDSORT(enemyunits, function(a,b) return VDist2Sq( GetPosition(a)[1],GetPosition(a)[3], position[1],position[3] ) < VDist2Sq( GetPosition(b)[1],GetPosition(b)[3], position[1],position[3]) end)

		for _,v in attackcategories do

			-- filter for the desired category
			for _, u in EntityCategoryFilterDown( v, enemyunits) do

				if not u.Dead then
				
					-- if can attack this kind of target and get somewhere close to it ? (I don't like this function)
					if CanAttackTarget( self, squad, u ) then

						if nolayercheck then 
							return u, GetPosition(u)
                        end

						if CanGraphTo( position, GetPosition(u), self.MovementLayer ) and not CheckBlockingTerrain( position, GetPosition(u)) then
							return u, GetPosition(u)
                        end
                        
                    end
                    
				end
                
			end
			
		end
        
	end
	
	return false, false
end

-- This function locates a target within specific parameters around a specific location or around the platoon
-- targets are threat filtered and range filtered (both MAX and MIN) allowing 'banded' searches
-- any shields within a targets vicinity increase it's threat --
-- This function can use a great deal of CPU so be careful
function AIFindTargetInRangeInCategoryWithThreatFromPosition( aiBrain, position, platoon, squad, minRange, maxRange, attackcategories, threatself, threattype, threatradius)

	-- if position not supplied use platoon position or exit
    if not position then
	
        position = LOUDCOPY(GetPlatoonPosition(platoon))
		
		if not position then
			return false,false
		end
    end
	
	-- are there any enemy units ?
	if aiBrain:GetNumUnitsAroundPoint( ALLBUTWALLS, position, maxRange, 'Enemy' ) < 1 then
		return false, false
	end

	local minimumrange = (minRange * minRange)
	
    local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
	
	local AIGetThreatLevelsAroundPoint = function(unitposition)

		if threattype == 'AntiAir' then
		
			return GetThreatAtPosition( aiBrain, unitposition, 0, true, 'AntiAir')	--airthreat
			
		elseif threattype == 'AntiSurface' then
		
			return GetThreatAtPosition( aiBrain, unitposition, 0, true, 'AntiSurface')	--surthreat
			
		elseif threattype == 'AntiSub' then
		
			return GetThreatAtPosition( aiBrain, unitposition, 0, true, 'AntiSub')	--subthreat
			
		elseif threattype == 'Economy' then
		
			return GetThreatAtPosition( aiBrain, unitposition, 0, true, 'Economy')	--ecothreat
			
		else
		
			return GetThreatAtPosition( aiBrain, unitposition, 0, true, 'Overall')	--airthreat + ecothreat + surthreat + subthreat
		end
	end
	
	-- get all the enemy units around this point (except walls)
	local enemyunits = GetUnitsAroundPoint( aiBrain, ALLBUTWALLS, position, maxRange, 'Enemy' )

    if not enemyunits[1] then
        return false, false
    end

	local CanAttackTarget = moho.platoon_methods.CanAttackTarget

	local LOUDSORT = table.sort
	local VDist2Sq = VDist2Sq
	local VDist2 = VDist2
	
    -- get a count of all shields within the list
	local shieldcount = EntityCategoryCount( SHIELDS, enemyunits )
    
	local retUnit, rePosition, bestthreat, targetUnits
    
	-- loop thru each of our attack categories
	for _,category in attackcategories do
	
		retUnit = false
		retPosition = false

		-- filter the enemy units down to a specific category
		targetUnits = EntityCategoryFilterDown( category, enemyunits )
		
		if targetUnits[1] then		

			-- sort them by distance -- 
			LOUDSORT( targetUnits, function(a,b) return VDist2Sq(a:GetPosition()[1],a:GetPosition()[3], position[1],position[3]) < VDist2Sq(b:GetPosition()[1],b:GetPosition()[3], position[1],position[3]) end)
		
			local unitchecks, checkspertick, unitposition
			local enemythreat, enemyshields, totalshieldvalueattarget
            
            local lastget = 0    -- debug value to monitor threat checks --
            local gets = 0       -- how many times the threatcheck was the same
			
			unitchecks = 0
			checkspertick = 6   -- this is the performance critical value -- 
		
			-- loop thru the targets
			for _,u in targetUnits do
				
				unitposition = u:GetPosition()
			
				-- if target is not dead and it's outside the minimum range
				if (not u.Dead) and VDist2Sq(unitposition[1],unitposition[3], position[1],position[3]) >= minimumrange then
                
                    -- only count it as a unit being checked if we actually have to process it
                    unitchecks = unitchecks + 1
                    
					-- if can attack this type of target
					if CanAttackTarget( platoon,'Attack',u ) then
					
						enemythreat = AIGetThreatLevelsAroundPoint(unitposition)

                        -- monitor the number of times the getthreat call was the same
                        if lastget != 0 and enemythreat == lastget then
                            gets = gets + 1
                        end
                        
                        lastget = enemythreat
                        
						-- if threat is less than threatself
						if enemythreat <= threatself then						

							-- check and adjust threat for shields
							if shieldcount > 0 then
					
								enemyshields = GetUnitsAroundPoint( aiBrain, SHIELDS, unitposition, 100, 'Enemy')
								
								LOUDSORT(enemyshields, function(a,b) return VDist2Sq(a:GetPosition()[1],a:GetPosition()[3], unitposition[1],unitposition[3]) < VDist2Sq(b:GetPosition()[1],b:GetPosition()[3], unitposition[1],unitposition[3]) end)
							
								totalshieldvalueattarget = 0
							
                                for _,s in enemyshields do
                                
                                    -- if the shield is On and it covers the target
                                    if s:ShieldIsOn() and VDist2(s:GetPosition()[1],s:GetPosition()[3],unitposition[1],unitposition[3]) < s.MyShield.Size then
                                        enemythreat = enemythreat + (s.MyShield:GetHealth() * .01)	-- threat plus 1% of shield strength
                                    end
                                    
                                end
                                
                            end
					
							-- cap low end of threat so we dont chase low value targets
							if enemythreat < ( threatself * .20) then
								enemythreat = ( threatself * .20)
							end
						
							if (not retUnit) or enemythreat < bestthreat then

								retUnit = u
								retPosition = LOUDCOPY(unitposition)
								bestthreat = enemythreat
                                unitchecks = 0
								break
							end
						end
					end
			
                    -- dont check too many targets per tick
                    if unitchecks >= checkspertick then
                        WaitTicks(1)
                        unitchecks = 0
                    end                    
				end
			end

			if retUnit and not retUnit.Dead then
				return retUnit,retPosition
			else
				retUnit = false
			end
		end
	end
	
	return false,false
end
	
-- this simply tells you if a point is in the water
-- which Air units don't care about
-- and is simply just a comparison between terrain height and surface height
-- if the terrain height is lower - then this is a water co-ordinate
function InWaterCheck(platoon)

	if platoon.MovementLayer == 'Air' then
		return false
	end
	
	local platPos = GetPlatoonPosition(platoon)
	
	return GetTerrainHeight(platPos[1], platPos[3]) < GetSurfaceHeight(platPos[1], platPos[3])
end

function LocationInWaterCheck(position)
	return GetTerrainHeight(position[1], position[3]) < GetSurfaceHeight(position[1], position[3])
end

function AIFindNumberOfUnitsBetweenPoints( aiBrain, start, finish, unitCat, stepby, alliance)

	local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint

    if type(unitCat) == 'string' then
        unitCat = ParseEntityCategory(unitCat)
    end

	local returnNum = 0
	
	-- number of steps to take based on distance divided by stepby ( min. 1)
	
	-- break the distance up into equal steps BUT each step is 125% of the stepby distance (so we reduce the overlap)
	local steps = math.floor( VDist2(start[1], start[3], finish[1], finish[3]) / (stepby * 1.25) ) + 1
	
	local xstep, ystep
	
	-- the distance of each step
	xstep = (start[1] - finish[1]) / steps
	ystep = (start[3] - finish[3]) / steps
	
	for i = 1, steps do
		returnNum = returnNum + GetNumUnitsAroundPoint( aiBrain, unitCat, { start[1] - (xstep * i), 0, start[3] - (ystep * i) }, stepby, alliance )
	end
	
	return returnNum
end