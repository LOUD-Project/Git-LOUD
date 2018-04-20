--  File     :  /lua/altaiutilities.lua

local import = import

local AIUtils = import('/lua/ai/aiutilities.lua')

local LOUDCOPY = table.copy
local LOUDENTITY = EntityCategoryContains
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn

local LOUDPARSE = ParseEntityCategory
local LOUDREMOVE = table.remove
local LOUDSORT = table.sort
local ForkTo = ForkThread

local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local VDist3 = VDist3
local VDist3Sq = VDist3Sq

local WaitTicks = coroutine.yield

local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local BeenDestroyed = moho.entity_methods.BeenDestroyed
local IsUnitState = moho.unit_methods.IsUnitState
local GetUnitId = moho.unit_methods.GetUnitId

local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
local PlatoonExists = moho.aibrain_methods.PlatoonExists


local function NormalToBuildLocation(location)
	return {location[1], location[3], 0}
end
    
function AssistBody(self, eng, aiBrain)

    local assistData = self.PlatoonData.Assist
	
	local assisteeType = assistData.AssisteeType
	local locationType = eng.LocationType
	
    local assistee = false
	local assistRange = assistData.AssistRange or 80

    local beingBuilt = assistData.BeingBuiltCategories or categories.ALLUNITS
    local assisteeCat = assistData.AssisteeCategory or categories.ALLUNITS

	local ass_count = 0
	local beingbuiltcategory, assistList, platoonPos
	
	-- this function will locate units needing assistance of the specific type --
	local function GetAssistees( beingbuiltcategory )

		if assisteeType == 'Factory' then
	
			return aiBrain.BuilderManagers[locationType].FactoryManager:GetFactoriesWantingAssistance( beingbuiltcategory, assisteeCat )
		
		elseif assisteeType == 'Engineer' then
	
			return aiBrain.BuilderManagers[locationType].EngineerManager:GetEngineersWantingAssistanceWithBuilding( beingbuiltcategory, assisteeCat )
		
		elseif assisteeType == 'Structure' then
	
			return aiBrain.BuilderManagers[locationType].PlatoonFormManager:GetUnitsBeingBuilt( aiBrain, beingbuiltcategory, assisteeCat )
    
		elseif assisteeType == 'Any' then
		
			local list = {}
	
			list = table.cat( list, aiBrain.BuilderManagers[locationType].PlatoonFormManager:GetUnitsBeingBuilt( aiBrain, beingbuiltcategory, assisteeCat ))
		
			list = table.cat( list, aiBrain.BuilderManagers[locationType].EngineerManager:GetEngineersWantingAssistanceWithBuilding( beingbuiltcategory, assisteeCat ))

			return list
		
		end

		return {}
		
	end

	for k,catString in beingBuilt do

        beingbuiltcategory = catString

		assistList = GetAssistees( beingbuiltcategory )

        if LOUDGETN(assistList) > 0 then

			-- we'll use the base position rather than the engineer --
			platoonPos = aiBrain.BuilderManagers[locationType].Position or false
			
            LOUDSORT(assistList, function(a,b) return VDist3Sq( a:GetPosition(), platoonPos ) < VDist3Sq( b:GetPosition(), platoonPos ) end )

            for _,v in assistList do
			
				if not v.Dead then

					ass_count = ass_count + 1					
					
                    if VDist3(v:GetPosition(), platoonPos) <= assistRange then
					
                        assistee = v
                        break
						
                    else
					
						LOG("*AI DEBUG Assistee at "..repr(v:GetPosition()).." beyond eng from "..eng.LocationType.." at "..repr(platoonPos).." assist range of "..assistRange)
						break
						
					end
					
                end
				
            end
			
        end

        if assistee then
		
            break
			
        end
		
    end

    if assistee and not eng.Dead then

        self:Stop()
		
        IssueGuard( {eng}, assistee )

		if LOUDENTITY( categories.SUBCOMMANDER, eng ) then
		
			IssueGuard( {eng}, assistee )
			
		end

    else
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.Sync.id.." "..repr(self.BuilderName).." unable to find anything to assist")
	
        eng.AssistPlatoon = nil
		
    end
	
end

function UnfinishedBody(self, eng, aiBrain)

    local assistData = self.PlatoonData.Assist
    local assistee = false
    local beingBuilt = assistData.BeingBuiltCategories or categories.ALLUNITS
	
    local catString, category, assistList

    for _,catString in beingBuilt do

        category = catString
        assistList = FindUnfinishedUnits( aiBrain, self.BuilderLocation, category )

		if assistList then
			assistee = assistList
			break
        end
    end

    if assistee then
		
        self:Stop()

		eng.UnitBeingBuilt = assistee
        IssueGuard( {eng}, assistee )

	else
        eng.AssistPlatoon = nil
		LOG("*AI DEBUG "..aiBrain.Nickname.." Unfinished finds no units")
    end
end

-- get a replacment - note - if a replacement is weighted at 100 then you never see the original units
-- this function willl not always return a result if the weight is less than 100 on the custom unit
-- at which point - the stock unit will be selected - this works differently from the factory built units
-- as in that case - the stock unit is always part of the selection process - see FBM for details
function GetTemplateReplacement(building, faction, customunits)

	local rand = Random(1,100)
	local possibles = {}
	local counter = 0

	for k,v in customunits do
		if rand <= v[2] then
			possibles[counter+1] = v[1]
			counter = counter + 1
		end
	end

	if counter > 0 then
		rand = Random(1,counter)
		return { { building, possibles[rand], } }
	end

	return false
end



-- This function finds any kind of available large base position (either start or expansion)
-- that is not too close to any of our other 'counted' bases - DPs and Sea bases are ignored
function AIFindBaseAreaForExpansion( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
	
		Position = GetPlatoonPosition(eng) or false
		
	end
	
	if Position then
	
		local positions = {}

		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
	
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))
	
		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], aiBrain.BuilderManagers[locationType].Position[1],aiBrain.BuilderManagers[locationType].Position[3]) < VDist2Sq(b.Position[1],b.Position[3], aiBrain.BuilderManagers[locationType].Position[1],aiBrain.BuilderManagers[locationType].Position[3] ) end )
	
		-- I put a check in here to eliminate not only the current position but any position within a range of the current position
		-- I expanded this concept further to base the exclusion radius upon map size
		-- The idea of this is to give the AI an emphasis on expanding his bases to cover a greater portion of the map rather
		-- than clumping up - this also avoids overlap of the army pools 
	
		-- cap the minimum baserange at 250
		local minimum_baserange = 250
	
		local Brains = ArmyBrains
    
		-- loop thru all the positions
		for m,marker in positions do
	
			local removed = false
		
			-- check all the other brains to see if they own it already
			for index,brain in Brains do
			
				-- if someone else owns it or the co-ordinates are the same as this brains 'MAIN' position -- 
				if brain.BuilderManagers[marker.Name] or ( marker.Position[1] == brain.BuilderManagers['MAIN'].Position[1] and marker.Position[3] == brain.BuilderManagers['MAIN'].Position[3] ) then
					
					removed = true
					
					break
					
				end
				
			end
		
			if not removed then

				-- check if position is within range of other 'counted' bases
				for basename,base in aiBrain.BuilderManagers do
				
					-- ignore position if too close to existing counted bases (non-Sea)
					if (base.CountedBase and base.BaseType != 'Sea') and VDist3( base.Position, marker.Position ) < minimum_baserange then
					
						removed = true
						
						break
						
					end
					
				end
			
				if not removed then
				
					return marker.Position, marker.Name
					
				end
				
			end
			
		end
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." AIFIND BASE for EXPANSION finds no positions within range of "..repr(Position))	--.." - table is "..repr(positions))

	end

	return false, false
	
end

-- This functions serves the role of finding open Start/Expansion markers which currently have no base on them
-- it used to be different in that it allowed sharing -- but I no longer permit that --
function AIFindBaseAreaForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

	local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
	
        Position = GetPlatoonPosition(eng) or false
		
	end
	
	if Position then
	
		local positions = {}
	
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))	
	
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))

		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )

		local minimum_baserange = 225
    
		local Brains = ArmyBrains

		for m,marker in positions do
	
			local removed = false

			for index,brain in Brains do
			
				--LOG("*AI DEBUG "..aiBrain.Nickname.." testing "..repr(marker.Name).." at "..repr( NormalToBuildLocation( marker.Position )).." with "..brain.Nickname.." at "..repr( NormalToBuildLocation( brain.BuilderManagers['MAIN'].Position ) ))
        
				-- if someone else owns it or the co-ordinates are the same as this brains 'MAIN' position -- 
				if brain.BuilderManagers[marker.Name] or ( marker.Position[1] == brain.BuilderManagers['MAIN'].Position[1] and marker.Position[3] == brain.BuilderManagers['MAIN'].Position[3] ) then
			
					removed = true
				
					break
				
				end
			
			end
		
			if not removed then
			
				for basename, base in aiBrain.BuilderManagers do
			
					if (base.CountedBase and base.BaseType != 'Sea') and VDist3( base.Position, marker.Position ) < minimum_baserange then
				
						removed = true
						
						break
					
					end
				
				end
			
				if not removed then
			
					return marker.Position, marker.Name
				
				end
			
			end
		
		end
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." AIFIND BASE FOR DP finds no positions within range of "..repr(Position))	--.." - table is "..repr(positions))
	
	end

	return false, false
	
end

-- finds DP and EXPANSION BASE(regular not LARGE) markers - minimum range to ANY other LAND base is 200
function AIFindDefensivePointForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
	
		Position = GetPlatoonPosition(eng) or false
		
	end
	
    if Position and aiBrain.PrimaryLandAttackBase and aiBrain.AttackPlan.Goal then
	
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
		local test_range = VDist3( aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position, aiBrain.AttackPlan.Goal )	

		local positions = {}
	
		positions = table.cat( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', Position, radius, tMin, tMax, tRings, tType))
	
		positions = table.cat( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', Position, radius, tMin, tMax, tRings, tType))

		-- sort the positions by distance from Position --
		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )

		local Brains = ArmyBrains
	
		-- minimum range that a DP can be from an existing base -- Land	
		local minimum_baserange = 225

		-- so we now have a list of ALL the DP positions on the map	-- loop thru the list and eliminate any that are already in use 
		for m,marker in positions do
	
			local removed = false

			for index,brain in Brains do
			
				--LOG("*AI DEBUG "..aiBrain.Nickname.." testing "..repr(marker.Name).." at "..repr( NormalToBuildLocation( marker.Position )).." with "..brain.Nickname)
        		
				if brain.BuilderManagers[marker.Name] then
			
					removed = true

					break
				
				end
			
			end
		
			-- if it's still valid -- check my own bases and exclude anything too close to ANY existing base
			if not removed then

				for basename, base in aiBrain.BuilderManagers do
		
					if VDist3( base.Position, marker.Position ) < minimum_baserange or VDist3( aiBrain.AttackPlan.Goal, marker.Position ) > test_range then

						removed = true
						
						break
					
					end
				
				end

				if not removed then

					return marker.Position, marker.Name
				
				end	
			
			end
		
		end
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." AIFIND DP finds no positions within range of "..repr(Position))	--.." - table is "..repr(positions))
	
	end

	return false, false
	
end

-- finds Naval DPs - minimum range to ANY sea base is 200 - allows ALLIED base sharing --
function AIFindNavalDefensivePointForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
	
		Position = GetPlatoonPosition(eng) or false
		
	end
	
    if Position then

		local positions = {}
	
		local positions = table.cat(positions,AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Defensive Point', Position, radius, tMin, tMax, tRings, tType))

		-- sort the possible positions by distance -- 
		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )
	
		local Brains = ArmyBrains
	
		-- minimum range that a DP can be from an existing base -- Naval
		local minimum_baserange = 225
	
		-- so we now have a list of ALL the Naval DP positions on the map
		-- loop thru the list and eliminate any that are already in use by enemy AI 
		-- the DP differs from the normal base in that we want to allow sharing with allies
		-- note how I have to exclude my own brain as an ally to avoid sharing existing bases with myself
		for m,marker in positions do
	
			local removed = false

			for _,brain in Brains do
		
				-- if in use by another brain --
				if (not removed) and brain.BuilderManagers[marker.Name] then
				
					-- are they allied ?
					local ally = IsAlly(aiBrain.ArmyIndex, brain.ArmyIndex) or false
				
					-- if not allied then remove
					if not ally then

						removed = true
					
						break
					
					end
				
				end
			
			end
		
			-- if valid then range check it to OUR other SEA bases
			if (not removed) then

				for basename, base in aiBrain.BuilderManagers do
			
					-- if too close to ANY of our other existing bases
					if VDist3( base.Position, marker.Position ) < minimum_baserange then

						removed = true
						
						break
					
					end
				
				end
		
				if not removed then
		
					return marker.Position, marker.Name
			
				end	

			end

		end
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." AIFIND NAVAL DP finds no positions within range of "..repr(Position))	--.." - table is "..repr(positions))
		
	end

	return false, false
	
end

-- finds Naval Areas - minimum range to ANY sea base is 200 - NO ALLIED sharing --
function AIFindNavalAreaForExpansion( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
	
		Position = GetPlatoonPosition(eng) or false
		
	end
	
    if Position then

		local positions = {}
	
		local positions = table.cat(positions,AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Area', Position, radius, tMin, tMax, tRings, tType))

		-- sort the possible positions by distance -- 
		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )
	
		local Brains = ArmyBrains
	
		-- minimum range that a Naval Base can be from any existing base
		local minimum_baserange = 250
	
		-- so we now have a list of ALL the Naval DP positions on the map
		-- loop thru the list and eliminate any that are already in use by enemy AI 
		-- the DP differs from the normal base in that we want to allow sharing with allies
		-- note how I have to exclude my own brain as an ally to avoid sharing existing bases with myself
		for m,marker in positions do
	
			local removed = false

			for _,brain in Brains do
		
				-- if in use by another brain --
				if brain.BuilderManagers[marker.Name] then
				
					removed = true
					
					break
				
				end
			
			end
		
			-- if valid then range check it to OUR other SEA bases
			if (not removed) then

				for basename, base in aiBrain.BuilderManagers do
			
					-- if too close to one of our other existing 'Sea' bases
					if base.BaseType == 'Sea' and VDist3( base.Position, marker.Position ) < minimum_baserange then

						removed = true
						
						break
					
					end
		
				end

				if not removed then
		
					return marker.Position, marker.Name
			
				end						

			end
		
		end

	end

	return false, false
	
end





-- these functions check various types of markers that dont have any allied structures in radius of the given categories
-- it also threat checks the markers and will return the closest one that passes both tests
-- this one checks both Start and Large Expansion bases
function AIFindBasePointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
    if Position then
	
		local positions = {}
	
		-- both Start and Large Expansion Areas --
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
		
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))	

		-- sort by distance from Position
		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], Position[1], Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1], Position[3] ) end )
    
		-- loop and check unit counts - exit on first good --
		for _,v in positions do
		
			if GetNumUnitsAroundPoint( aiBrain, LOUDPARSE(category), v.Position, markerRadius, 'Ally') <= unitMax then
			
				return v.Position, v.Name
				
			end
			
		end
		
	end
	
	return false, false
	
end

-- as above but examines DPs and 'small' Expansion Areas
function AIFindDefensivePointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)
	
    local Position = aiBrain.BuilderManagers[locationType].Position or false

    if Position then
	
		local positions = {}
	
		-- both DPs and 'small' Expansion Areas --
		positions = table.cat( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', Position, radius, tMin, tMax, tRings, tType))
		
		positions = table.cat( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', Position, radius, tMin, tMax, tRings, tType))
    
		LOUDSORT( positions, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], Position[1],Position[3] ) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3]) end )

		for k,v in positions do
		
			if GetNumUnitsAroundPoint( aiBrain, LOUDPARSE(category), v.Position, markerRadius, 'Ally' ) <= unitMax then
			
				return v.Position, v.Name
				
			end	
			
		end
		
	end
	
	return false, false
	
end

-- as above but examines only LARGE Expansion Areas
function AIFindExpansionPointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)

    local Position = aiBrain.BuilderManagers[locationType].Position or false

    if Position then
	
		local positions = {}
	
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))

		LOUDSORT(positions, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )	
	
		local LOUDPARSE = ParseEntityCategory
		
		for k,v in positions do
		
			if AIUtils.GetNumberOfOwnUnitsAroundPoint( aiBrain, LOUDPARSE(category), v.Position, markerRadius ) <= unitMax then
			
				return v.Position, v.Name
				
			end
			
		end
		
	end
	
	return false, false
	
end

-- as above but for Naval DPs - new DPs must be better than current Primary
-- and there must be a water path between the current primary and the new choice
function AIFindNavalDefensivePointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
    if Position and  ( aiBrain.PrimarySeaAttackBase or aiBrain.PrimaryLandAttackBase ) and aiBrain.AttackPlan.Goal and ( aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position or aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position) then
	
		local test_range = false
		
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
		if aiBrain.PrimarySeaAttackBase then
		
			test_range = VDist3( aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position, aiBrain.AttackPlan.Goal )
			
		else
		
			test_range = VDist3( aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position, aiBrain.AttackPlan.Goal )
		
		end
	
		-- minimum range that a DP can be from an existing naval position
		local minimum_baserange = 250
		
		local positions = {}

		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Defensive Point', Position, radius, tMin, tMax, tRings, tType))
    
		LOUDSORT( positions, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], Position[1],Position[3] ) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3]) end )
    
		-- loop thru positions and do the structure/unit count check
		-- originally intended to insure that there are no allied units of same category within radius of this position
		for k,v in positions do
		
			-- must be able to path from current Primary to new position ( this deals with maps that have multiple water areas )
			local path, reason = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD( aiBrain, 'AttackPlanner', 'Water', aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position, v.Position, 1000, 250 )

			if not path then
				
				continue

			end		

			-- check if there are existing structures at the point
			if GetNumUnitsAroundPoint( aiBrain, LOUDPARSE(category), v.Position, markerRadius, 'Ally' ) <= unitMax then
			
				local reject = false
		
				-- check proximity to our existing bases --
				for basename, base in aiBrain.BuilderManagers do
	
					-- if too close to ANY of our other existing bases or further than our current primary sea attack base --
					if VDist3( base.Position, v.Position ) < minimum_baserange or VDist3( aiBrain.AttackPlan.Goal, v.Position ) > test_range then
						
						reject = true
						
						break
						
					end
					
				end
				
				
				if not reject then
				
					return v.Position, v.Name
					
				end
				
			end	
			
		end
		
	end

	return false, false
	
end

-- as above but checks ONLY Start positions
function AIFindStartPointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)
	
    local Position = aiBrain.BuilderManagers[locationType].Position or false

    if Position then
	
		local positions = {}
	
		positions = table.cat(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
    
		LOUDSORT( positions, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], Position[1],Position[3] ) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3]) end )
	
		for k,v in positions do
		
			if v.Position[1] == Position[1] and v.Position[3] == Position[3] then
			
				LOUDREMOVE( positions, k )
				
				break
				
			end
			
		end
    
		for _,v in positions do
		
			if GetNumUnitsAroundPoint( aiBrain, LOUDPARSE(category), v.Position, markerRadius, 'Ally' ) <= unitMax then
			
				return v.Position, v.Name
				
			end
			
		end
		
	end
	
	return false, false
	
end




-- finds a relatively safe area (one with the greatest number of specified allied units) within range
-- the runshield option multiplies the value of shields over other types and makes enemy shields more dangerous
-- if no safe point can be found, the base centre is reported --
function AIFindDefensiveAreaSorian( aiBrain, unit, category, range, runShield )

    if not unit.Dead then
	
        -- Build a grid to find units near
        local gridSize = range / 5
		
        if gridSize > 25 then
            gridSize = 25
        end
		
        local grid = {}
        local highPoint = false
        local highNum = -999999
		
        local unitPos = unit:GetPosition()
		
        local distance
		
        local startPosX, startPosZ = aiBrain:GetArmyStartPos()
		
        for i=-5,5 do
		
            for j=-5,5 do
			
                local height = GetTerrainHeight( startPosX - ( gridSize * i ), startPosZ - ( gridSize * j ) )
				
                if GetSurfaceHeight( startPosX - ( gridSize * i ), startPosZ - ( gridSize * j ) ) > height then
				
                    height = GetSurfaceHeight( startPosX - ( gridSize * i ), startPosZ - ( gridSize * j ) )
					
                end
				
                local checkPos = { startPosX - ( gridSize * i ), height, startPosZ - ( gridSize * j ) }
				
                local units = GetUnitsAroundPoint( aiBrain, category, checkPos, gridSize, 'Ally' )
				
                local tempNum = 0
				
                for _,v in units do
				
                    if ( LOUDENTITY( categories.TECH3, v ) and not runShield ) or ( LOUDENTITY( categories.TECH3, v ) and runShield and v:ShieldIsOn() ) then
					
                        tempNum = tempNum + 7
						
                    elseif ( LOUDENTITY( categories.TECH2, v ) and not runShield ) or ( LOUDENTITY( categories.TECH2, v ) and runShield and v:ShieldIsOn() ) then
					
                        tempNum = tempNum + 4
						
                    else
					
                        tempNum = tempNum + 1
						
                    end
					
                end
				
                local units = GetUnitsAroundPoint( aiBrain,categories.MOBILE, checkPos, gridSize, 'Enemy' )
				
                for _,v in units do
				
                    if LOUDENTITY( categories.TECH3, v ) then
					
                        tempNum = tempNum - 10
						
                    elseif LOUDENTITY( categories.TECH2, v ) then
					
                        tempNum = tempNum - 5
						
                    else
					
                        tempNum = tempNum - 2
						
                    end
					
                end
				
                if not highNum or tempNum > highNum then

					highNum = tempNum
					distance = VDist2( unitPos[1], unitPos[3], checkPos[1], checkPos[3] )
					highPoint = checkPos
					
                elseif tempNum == highNum then
				
                    local tempDist = VDist2( unitPos[1], unitPos[3], checkPos[1], checkPos[3] )
					
                    if tempDist < distance then
					
                        highNum = tempNum
                        highPoint = checkPos
						
                    end
					
                end
				
            end
			
        end
		
		--LOG("*AI DEBUG Found defensive point at "..repr(highPoint))
		
		if not highPoint then
			local x,z = aiBrain:GetArmyStartPos()
			return { x, 0, z }
		else
			return highPoint
		end
		
    else
        return { 0, 0, 0 }
    end
end



-- Takes a list of units & returns the number & size of the transport slots required to move it
function GetNumTransports(units)

	--LOG("*AI DEBUG Getting Number of transports required")
	
	local GetBlueprint = moho.entity_methods.GetBlueprint
	local transportsNeeded = false	-- used to keep from issuing false positive if no units are provided
    local transportslotsNeeded = { Small = 0, Medium = 0, Large = 0, }
	
    for _, v in units do
	
        if v and not v.Dead then
			
            if v.TransportClass == 1 then
				transportsNeeded = true
                transportslotsNeeded.Small = transportslotsNeeded.Small + 1.0
				
            elseif v.TransportClass == 2 then
				transportsNeeded = true
				transportslotsNeeded.Small = transportslotsNeeded.Small + 0.34
                transportslotsNeeded.Medium = transportslotsNeeded.Medium + 1.0
				
            elseif v.TransportClass == 3 then
				transportsNeeded = true
				transportslotsNeeded.Small = transportslotsNeeded.Small + 0.5
                transportslotsNeeded.Medium = transportslotsNeeded.Medium + 0.25
                transportslotsNeeded.Large = transportslotsNeeded.Large + 1.0
				
            else
			
				LOG("*AI DEBUG "..v:GetBlueprint().Description.." has no transportClass value")
				return false, nil
				
            end

		end
		
    end
	
    return transportsNeeded, transportslotsNeeded
	
end


-- This function attempts to locate the required number of transports to move the platoon.
-- Modified to restrict the use of out of gas transports and to keep transports moving back to a base when not in use
-- Will now also limit transport selection to those within 16 km
function GetTransports( platoon, aiBrain)

	local LOUDENTITY = EntityCategoryContains
	local LOUDGETN = table.getn
	local WaitTicks = coroutine.yield
	
	local counter = 0
	local IsEngineer = platoon:PlatoonCategoryCount( categories.ENGINEER ) > 0
	
	--LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." getting transports")

	-- this call will tell us if transports can be used and how many slots we'll need
	-- it will only return false if there is an untransportable unit in the units
    local CanUseTransports, neededTable = GetNumTransports( GetPlatoonUnits(platoon) ) 
	
    if not CanUseTransports then
		LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." cannot use transports in GetTransports")
        return false, false
    end
	
	platoon.UsingTransport = true	-- this will keep the platoon from doing certain things while it's looking for transport
	
	-- COLLECTION PHASE -- if UEF or Cybran - they have additional transportation units
	local Special = false
	
	if aiBrain.FactionIndex == 1 or aiBrain.FactionIndex == 3 then
		Special = true
	end
	
    local pool = aiBrain.TransportPool
	local armypool = aiBrain.ArmyPool
	
	local armypooltransports = false
	local TransportPoolTransports = false
	
	-- build table of transports available to engineers - allow use of T1/T2  plus Gunships for UEF
	if IsEngineer then
	
		TransportPoolTransports = EntityCategoryFilterDown( categories.AIR * categories.TRANSPORTFOCUS - categories.TECH3, GetPlatoonUnits(pool) )
		
		if Special then
			armypooltransports = EntityCategoryFilterDown( categories.uea0203, GetPlatoonUnits(armypool) )
		end
		
	-- else build a table of all transports - allow UEF and Cybrans to use additional transport units (T2 Gunship, Experimental Transport)
	else
	
		TransportPoolTransports = EntityCategoryFilterDown( categories.AIR * categories.TRANSPORTFOCUS, GetPlatoonUnits(pool) )
		
		if Special then
			-- get the T2 gunships and Gargantua - we can't use the specific ID since if BO is not turned on it would cause an error - we use a general lookup instead
			armypooltransports = EntityCategoryFilterDown( categories.uea0203 + (categories.AIR * categories.EXPERIMENTAL * categories.TRANSPORTFOCUS), GetPlatoonUnits(armypool) )
		end
		
	end
	
	-- OK - so we now have 2 lists of units and we want to make sure the 'specials' get utilized first
	-- so we'll add the specials to the Available list first, and then the standard ones
	-- in this way, the specials will get utilized first, making good use of both the UEF T2 gunship
	-- and the Cybran Gargantuan
	local AvailableTransports = {}
	
	counter = 0
	
	if PlatoonExists(aiBrain,platoon) then

		if armypooltransports and LOUDGETN(armypooltransports) > 0 then
		
			-- I loop in here to limit the number of army pool transports we take to 12
			local tcount = 0
		
			for _,trans in armypooltransports do
			
				if not trans.InUse then
				
					AvailableTransports[counter + 1] = trans
					counter = counter + 1

					-- this puts specials into the transport pool -- occurs to me that they
					-- may get stuck in here if it turns out we cant use transports
					AssignUnitsToPlatoon( aiBrain, pool, {trans}, 'Support','none')
					
					tcount = tcount + 1
				
					if tcount == 12 then
						break
					end
					
				end
				
			end
			
		end
		
		if TransportPoolTransports and LOUDGETN(TransportPoolTransports) > 0 then
		
			for _,trans in TransportPoolTransports do
			
				if not trans.InUse then
				
					AvailableTransports[counter + 1] = trans
					counter = counter + 1
					
				end
				
			end
			
		end
		
	end
	
	armypooltransports = nil
	TransportPoolTransports = nil
	
	local transportcount = counter
	
	counter = 0	
	
	local location = false
	
	if PlatoonExists(aiBrain,platoon) then
		
		for _,u in GetPlatoonUnits(platoon) do
		
			if not u.Dead then
				counter = counter + 1
			end
			
		end

		if counter > 0 then
			location = table.copy(GetPlatoonPosition(platoon))
		end
	end	
	
	-- if we cant find any transports or land platoon has died or is empty
	if transportcount < 1 or counter < 1 then
		
		if counter < 1 then
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." No Units to transport from "..repr(platoon.BuilderName).." "..counter )
			
		end

		if not location then
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." finds no platoon position")
			
		end
		
		if transportcount > 0 then
		
			-- send all transports back into pool - which covers the specials (ie. UEF Gunships) 
			ForkThread( ReturnTransportsToPool, aiBrain, AvailableTransports, true )
		end

		platoon.UsingTransport = false
		
		return false, false
	end

	
    local transports = {}			-- this will hold the data for all of the eligible transports

	-- we assume we cannot use tranports
	local CanUseTransports = false
	
	-- we'll accumulate the slots from all transports
	-- this will allow us to save a bunch of effort if we simply dont have enough transport capacity
	-- without having to do a lot of processing
	local Collected = { Large = 0, Medium = 0, Small = 0 }
	
	counter = 0

	local GetFuelRatio = moho.unit_methods.GetFuelRatio
	local IsBeingBuilt = moho.unit_methods.IsBeingBuilt
	local GetPosition = moho.entity_methods.GetPosition
	local out_of_range = false

	-- now we filter out those that dont pass muster
	for k,transport in AvailableTransports do
		
		if not transport.Dead then
		
			-- use only those that are not in use, not being built and have > 50% fuel and > 70% health
			if (not transport.InUse) and (not IsBeingBuilt(transport)) and GetFuelRatio(transport) > .50 and transport:GetHealthPercent() > .70  then
			
				-- use only those which are not already busy or are not loading already
				if not IsUnitState( transport, 'Busy') and not IsUnitState( transport, 'TransportLoading') then
				
					-- deny use of T1 transport to platoons needing more than 1 large transport
					if (not IsEngineer) and LOUDENTITY( categories.TECH1, transport ) and neededTable.Large > 1 then
					
						continue
						
					-- insert available transport into list of usable transports
					else
					
						local unitPos = GetPosition(transport)
						local range = VDist2( unitPos[1],unitPos[3], location[1], location[3] )

						-- limit to 18 km range -- this insures that transport wont expire before loading takes place
						-- as loading has a 120 second time limit --
						if range < 1800 then
			
							local id = GetUnitId(transport)
				
							if not aiBrain.TransportSlotTable[id] then
								AIUtils.GetNumTransportSlots(transport, aiBrain)
							end

							transports[counter+1] = { Unit = transport, Distance = range, Slots = table.copy(aiBrain.TransportSlotTable[id]) }
							counter = counter + 1

							Collected.Large = Collected.Large + transports[counter].Slots.Large
							Collected.Medium = Collected.Medium + transports[counter].Slots.Medium
							Collected.Small = Collected.Small + transports[counter].Slots.Small

							-- if we have enough carrying capacity for each type then CanUseTransports is true
							if Collected.Large >= neededTable.Large and Collected.Medium >= neededTable.Medium and Collected.Small >= neededTable.Small then
								CanUseTransports = true
							end
							
						else
						
							--LOG("*AI DEBUG "..aiBrain.Nickname.." transport out of range at "..range)
							out_of_range = true
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end

	if not CanUseTransports then
	
		if not out_of_range then
		
			if not IsEngineer then
			
				-- let the brain know we couldn't fill a transport request by a ground platoon
				aiBrain.NeedTransports = true
				
			end
			
		end
		
		-- send all transports back into pool - which covers the specials (ie. UEF Gunships) 
		ForkThread( ReturnTransportsToPool, aiBrain, AvailableTransports, true )
		
		platoon.UsingTransport = false
		
        return false, false
		
	end
	
	Collected = nil
	
	-- ASSIGNMENT PHASE -- 
	-- at this point we have a list of all the eligible transports in range in the TRANSPORTS table
	AvailableTransports = nil	-- we dont need this anymore
	
	local transportplatoon = false	
	
    if CanUseTransports and counter > 0 then
	
		CanUseTransports = false
		counter = 0
		
		-- sort the available transports by range --
		LOUDSORT(transports, function(a,b) return a.Distance < b.Distance end )
		
        -- loop thru the transports and assess how many units of each size can be carried
		-- assign each transport to the transport platoon until the needs are filled
		-- after that, mark each remaining transport as not InUse
        for _,v in transports do
		
			local transport = v.Unit
			local AvailableSlots = v.Slots

			-- if we still need transport capacity and this transport is in the Transport or Army Pool
            if not transport.Dead and (not CanUseTransports) and (transport.PlatoonHandle == aiBrain.TransportPool or transport.PlatoonHandle == aiBrain.ArmyPool ) then
			
				-- mark the transport as InUse
				transport.InUse = true
				
				-- count the number of transports used
				counter = counter + 1
			
				-- create a platoon for the transports
				if not transportplatoon then
				
					local ident = Random(10000,99999)
					transportplatoon = aiBrain:MakePlatoon('TransportPlatoon '..tostring(ident),'none')
					
					transportplatoon.PlanName = 'TransportUnits '..tostring(ident)
					transportplatoon.BuilderName = 'Load and Transport '..tostring(ident)
					
				end
				
				AssignUnitsToPlatoon( aiBrain, transportplatoon, {transport}, 'Support', 'BlockFormation')

				IssueClearCommands({transport})
				
				--transport:SetCustomName(transportplatoon.PlanName)
				
				IssueMove( {transport}, location )

                while neededTable.Large >= 1 and AvailableSlots.Large >= 1 do
				
                    neededTable.Large = neededTable.Large - 1.0
					
                    AvailableSlots.Large = AvailableSlots.Large - 1.0
					AvailableSlots.Medium = AvailableSlots.Medium - 0.25
                    AvailableSlots.Small = AvailableSlots.Small - 0.34
					
				end
				
                while neededTable.Medium >= 1 and AvailableSlots.Medium >= 1 do
				
                    neededTable.Medium = neededTable.Medium - 1.0
					
                    AvailableSlots.Medium = AvailableSlots.Medium - 1.0
					AvailableSlots.Small = AvailableSlots.Small - 0.34
					
                end
				
                while neededTable.Small >= 1 and AvailableSlots.Small >= 1 do
				
                    neededTable.Small = neededTable.Small - 1.0
					
					if Special then
						AvailableSlots.Medium = AvailableSlots.Medium - .10 -- yes .1 so that UEF Gunship wont be able to carry more than 1 unit
					end
					
                    AvailableSlots.Small = AvailableSlots.Small - 1.0
                end
				
				-- if no more slots are needed signal that we have all the transport we require
                if neededTable.Small < 1 and neededTable.Medium < 1 and neededTable.Large < 1 then
				
                    CanUseTransports = true
					
                end
				
			end
			
        end

    end

	-- one last check for the validity of both unit and transport platoons
	if CanUseTransports and counter > 0 then

		counter = 0
		
		local location = false
		
		if PlatoonExists(aiBrain, platoon) then
			
			for _,u in GetPlatoonUnits(platoon) do
			
				if not u.Dead then
					counter = counter + 1
				end
				
			end
			
			if counter > 0 then
				location = table.copy(GetPlatoonPosition(platoon))
			end
			
		end

		if not transportplatoon or counter < 1 then
		
			if not transportplatoon then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." transportplatoon dead after assignmnet "..repr(transportplatoon))
				
			else
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." unit platoon dead after assignment ")
				
			end
			
			CanUseTransports = false

		end
		
	end
	
	transports = nil
	
	-- if we need more transport then fail (I no longer permit partial transportation)
	-- or if some other situation (dead units) -- send the transports back to the pool
    if not CanUseTransports or counter < 1 then

		if transportplatoon then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..transportplatoon.BuilderName.." Returned To Pool ")
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." Still needed "..neededTable.Large.." Lrg "..neededTable.Medium.." Med "..neededTable.Small.." Small slots")
			
			ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true )
			
		end

		platoon.UsingTransport = false
		
        return false, false
		
    else
		
        platoon.UsingTransport = true
		
        return counter, transportplatoon
		
    end
	
end


-- Ok -- this routine allowed me to get some control over the reliability of loading units onto transport
-- I have to say, the lack of a GETUNITSTATE function really made this tedious but here is the jist of what I've found
-- Some transports will randomly report false to TransportHasSpaceFor even when completely empty -- causing them to fail to load units
-- just to note, the same also seems to apply to AIRSTAGINGPLATFORMS
-- I was eventually able to determine that two states are most important in this process --
-- TransportLoading for the transports
-- WaitingForTransport for the units 
-- Essentially if the transport isn't Moving or TransportLoading then something is wrong
-- If a unit is not WaitingForTransport then it too has had loading interrupted 
-- however - I have noticed that transports will continue to report 'loading' even when all the units to be loaded are dead 
function WatchUnitLoading( transport, units, aiBrain )
	
	local unitsdead = false
	local loading = true
	
	local reloads = 0
	local reissue = 0
	local newunits = table.copy(units)
	
	local GetPosition = moho.entity_methods.GetPosition
	local watchcount = 0

	IssueClearCommands( {transport} )
	
	-- move the transport towards the units
	--IssueMove( {transport}, units[1]:GetPosition())	
	
	--WaitTicks(5)

	-- here is where we issue the Load command to the transport --
	safecall("Unable to IssueTransportLoad", IssueTransportLoad, units, transport )

	-- loop here while the transport is alive and loading is underway
	-- there is another trigger (watchcount) which will force loading
	-- to false after 150 seconds
	while (not unitsdead) and loading do
	
		watchcount = watchcount + 3.0
		
		if watchcount > 150 then
		
			loading = false
			break
			
		end
		
		WaitTicks(30)
		
		local tempunits = {}
		local counter = 0

		if not transport.Dead and ( not IsUnitState(transport,'Moving') or IsUnitState(transport,'TransportLoading') ) then
		
			unitsdead = true
			loading = false
	
			-- loop thru the units and pick out those that are not yet 'attached'
			-- also detect if all units to be loaded are dead
			for _,u in newunits do
		
				if not BeenDestroyed(u) then
				
					-- we have some live units
					unitsdead = false
			
					if not IsUnitState( u, 'Attached') then
					
						loading = true
						tempunits[counter+1] = u
						counter = counter + 1
						
					end
					
				end
				
			end
		
			-- if all dead or all loaded or unit platoon no longer exists, RTB the transport
			if unitsdead or (not loading) or reloads > 20 then
			
				if unitsdead then
				
					transport.InUse = false
					transport.WatchLoadingThread = nil
					
					return ReturnTransportsToPool( aiBrain, {transport}, true )
					
				end
				
				loading = false
				
			end
			
		end

		-- issue reloads to unloaded units if transport is not moving and not loading units
		if not (transport.Dead or BeenDestroyed(transport)) and (loading and not (IsUnitState( transport, 'Moving') or IsUnitState( transport, 'TransportLoading'))) then

			reloads = reloads + 1
			reissue = reissue + 1
			tempunits = {}
			counter = 0
			
			for k,u in tempunits do
			
				if not (u.Dead or BeenDestroyed(u)) and not IsUnitState( u, 'Attached') then

					-- if the unit is not attached and the transport has space for it or it's a UEF Gunship (TransportHasSpaceFor command is unreliable)
					if (not transport.Dead) and transport:TransportHasSpaceFor(u) then
					
						IssueClearCommands({u})
					
						if reissue > 1 then
						
							Warp( u, GetPosition(transport) )
							reissue = 0
							
						end
						
						tempunits[counter + 1] = u
						counter = counter + 1
					
					-- if the unit is not attached and the transport does NOT have space for it - turn off loading flag and clear the tempunits list
					elseif (not transport.Dead) and (not transport:TransportHasSpaceFor(u)) and (not EntityCategoryContains(categories.uea0203,transport)) then

						loading = false
						tempunits = nil
						break
			
					elseif (not transport.Dead) and EntityCategoryContains(categories.uea0203,transport) then

						loading = false
						tempunits = nil
						break
						
					end	
					
				end
				
			end
			
			if counter > 0 then
			
				IssueStop( tempunits )
				
				IssueClearCommands( {transport} )
				
				local goload = safecall("Unable to IssueTransportLoad", IssueTransportLoad, tempunits, transport )
				
				LOG("*AI DEBUG "..aiBrain.Nickname.." goload is "..repr(goload).." for "..transport:GetBlueprint().Description)
				
				ForkTo( AISendPing, transport:GetPosition(),'alert', aiBrain.ArmyIndex )
				
				newunits = table.copy(tempunits)
				
			else
			
				loading = false
				
			end
			
		end
		
	end
	
	IssueClearCommands( {transport} )
	
	-- have the transport guard his loading spot until everyone else has loaded up
	IssueGuard( {transport}, transport:GetPosition() )
	
	transport.WatchLoadingThread = nil
	
end

function WatchTransportTravel( transport, destination, aiBrain )
	
	local unitsdead = false
	local watchcount = 0
	
	local GetPosition = moho.entity_methods.GetPosition	
	
	transport.StuckCount = 0
	transport.LastPosition = table.copy(GetPosition(transport))
	
	while (not unitsdead) do
	
		WaitTicks(18)
		watchcount = watchcount + 1.8
		
		
		if not transport.Dead then
		
			-- major distress call -- 
			if transport.PlatoonHandle.DistressCall then
			
				-- reassign destination and begin immediate drop --
				-- this really needs to be sensitive to the platoons layer
				-- and find an appropriate marker to drop at -- 
				destination = GetPosition(transport)
				break
				
			end
			
			-- someone in transport platoon is close - begin the drop -
			if transport.PlatoonHandle.AtGoal then
			
				break
				
			end
			
			unitsdead = true

			for _,u in transport:GetCargo() do
			
				if not BeenDestroyed(u) then
				
					unitsdead = false
					break
					
				end
				
			end

			-- if all dead except UEF Gunship RTB the transport
			if unitsdead and not EntityCategoryContains(categories.uea0203,transport) then
			
				transport.StuckCount = nil
				transport.LastPosition = nil
				transport.WatchTravelThread = nil
				
				return ReturnTransportsToPool( aiBrain, {transport}, true )
				
			end
		
			-- is the transport still close to its last position bump the stuckcount
			if transport.LastPosition then
			
				if VDist2(transport.LastPosition[1], transport.LastPosition[3], GetPosition(transport)[1],GetPosition(transport)[3]) < 6 then
				
					transport.StuckCount = transport.StuckCount + 1
					
				else
				
					transport.StuckCount = 0
					
				end
				
			end

			if (transport:IsIdleState() or transport.StuckCount > 8) then
		
				if transport.StuckCount > 8 then
				
					transport.StuckCount = 0
					
				end

				IssueClearCommands( {transport} )
				IssueMove( {transport}, destination )
				
			end
		
			-- this needs some examination -- it should signal the entire transport platoon - not just itself --
			if VDist2(GetPosition(transport)[1], GetPosition(transport)[3], destination[1],destination[3]) < 100 then
			
				transport.PlatoonHandle.AtGoal = true
				
			end
		
			transport.LastPosition = table.copy(transport:GetPosition())
			
		end
		
	end
	
	if not transport.Dead then
	
		IssueClearCommands( {transport} )

		if not transport.Dead then
		
			transport.StuckCount = nil
			transport.LastPosition = nil
			transport.WatchTravelThread = nil
			transport.WatchUnloadThread = transport:ForkThread(WatchUnitUnload, transport:GetCargo(), destination, aiBrain )
			
		end
		
	end
	
end

function WatchUnitUnload( transport, unitlist, destination, aiBrain )
	
	local unitsdead = false
	local unloading = true
	
	local watchcount = 0
	
	IssueTransportUnload( {transport}, destination)

	while (not unitsdead) and unloading do
		
		WaitTicks(16)
		watchcount = watchcount + 1.6
		
		if not transport.Dead then
	
			unitsdead = true
			unloading = false
		
			-- do we have loaded units
			for _,u in unitlist do
		
				if not BeenDestroyed(u) then
				
					unitsdead = false
				
					if IsUnitState( u, 'Attached') then
					
						unloading = true
						break
						
					end
					
				end
				
			end

			if unitsdead or not unloading then
			
				if unitsdead or not transport.ReturnToPoolCallbackSet then
				
					transport.WatchUnloadThread = nil
					transport.InUse = false
					
					return ReturnTransportsToPool( aiBrain, {transport}, true )
					
				end
				
			end

			if unloading and (not transport:IsUnitState('TransportUnloading')) then

				if watchcount >= 15 then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(transport.Sync.id).." "..repr(transport.PlatoonHandle.BuilderName).." FAILS TO UNLOAD after 40 seconds")
					break			
					
				elseif watchcount >= 10 then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(transport.Sync.id).." "..repr(transport.PlatoonHandle.BuilderName).." watched unload for 25 seconds")
					IssueTransportUnload( {transport}, transport:GetPosition())
					
				elseif watchcount > 5 then
				
					IssueTransportUnload( {transport}, transport:GetPosition())
					
				end
				
			end
			
		end
		
	end
	
	transport.WatchUnloadThread = nil
	transport.InUse = false
	
end

-- This function actually loads and moves units on transports using a safe path to the location desired
-- Just a personal note - this whole transport thing is a BITCH
-- This was one of the first tasks I tackled and years later I still find myself coming back to it again and again - argh
function UseTransports( aiBrain, transports, location, UnitPlatoon, IsEngineer)

	local LOUDENTITY = EntityCategoryContains
	local LOUDGETN = table.getn
	local LOUDINSERT = table.insert

	local WaitTicks = coroutine.yield
	
	local PlatoonExists = moho.aibrain_methods.PlatoonExists
	local GetBlueprint = moho.entity_methods.GetBlueprint
	
    local transportTable = {}	
	local counter = 0
	
	-- check the transport platoon and count - load the transport table
	-- process any toggles (stealth, etc.) the transport may have
	if PlatoonExists( aiBrain, transports ) then

		for _,v in GetPlatoonUnits(transports) do
		
			if not v.Dead then
			
				if v:TestToggleCaps('RULEUTC_StealthToggle') then
					v:SetScriptBit('RULEUTC_StealthToggle', false)
				end
				
				if v:TestToggleCaps('RULEUTC_CloakToggle') then
					v:SetScriptBit('RULEUTC_CloakToggle', false)
				end
				
				if v:TestToggleCaps('RULEUTC_IntelToggle') then
					v:SetScriptBit('RULEUTC_IntelToggle', false)
				end
			
				local slots = table.copy( aiBrain.TransportSlotTable[ GetUnitId(v) ] )
		
				transportTable[counter + 1] = {	Transport = v, LargeSlots = slots.Large, MediumSlots = slots.Medium, SmallSlots = slots.Small, Units = { ["Small"] = {}, ["Medium"] = {}, ["Large"] = {} } }
				counter = counter + 1
				
			end
			
		end
		
	end
	
	if counter < 1 then
		return false
    end

	-- This routine allocates the units to specific transports
	-- Units are injected on a TransportClass basis ( 3 - 2 - 1 )
	-- As each unit is assigned - the transport has its remaining slot count
	-- reduced & the unit is added to the list assigned to that transport
	local function SortUnitsOnTransports( transportTable, unitTable )

		local leftoverUnits = {}
	
		for num, unit in unitTable do
		
			local transSlotNum = 0
			local remainingLarge = 0
			local remainingMed = 0
			local remainingSml = 0
		
			local TransportClass = 	unit.TransportClass
			
			-- pick the transport with the greatest number of appropriate slots left
			for tNum, tData in transportTable do
			
				if tData.LargeSlots >= remainingLarge and TransportClass == 3 then
				
					transSlotNum = tNum
					remainingLarge = tData.LargeSlots
					remainingMed = tData.MediumSlots
					remainingSml = tData.SmallSlots
					
				elseif tData.MediumSlots >= remainingMed and TransportClass == 2 then
				
					transSlotNum = tNum
					remainingLarge = tData.LargeSlots
					remainingMed = tData.MediumSlots
					remainingSml = tData.SmallSlots
					
				elseif tData.SmallSlots >= remainingSml and TransportClass == 1 then
				
					transSlotNum = tNum
					remainingLarge = tData.LargeSlots
					remainingMed = tData.MediumSlots
					remainingSml = tData.SmallSlots
					
				end
				
			end
			
			if transSlotNum > 0 then

				-- assign the large units
				-- notice how we reduce the count of the lower slots as we use up larger ones
				-- and we do the same to larger slots as we use up smaller ones - this was not the 
				-- case before - and caused errors leaving units unassigned - or over-assigned
				if TransportClass == 3 and remainingLarge >= 1.0 then
				
					transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 1.0
					transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 0.25
					transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 0.50
					
					-- add the unit to the Large list for this transport
					LOUDINSERT( transportTable[transSlotNum].Units.Large, unit )
					
				elseif TransportClass == 2 and remainingMed >= 1.0 then
				
					transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 0.1
					transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 1.0
					transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 0.34
					
					-- add the unit to the Medium list for this transport
					LOUDINSERT( transportTable[transSlotNum].Units.Medium, unit )
					
				elseif TransportClass == 1 and remainingSml >= 1.0 then
				
					transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 0.1	-- yes .1 - for UEF T2 gunships
					transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
					
					-- add the unit to the list for this transport
					LOUDINSERT( transportTable[transSlotNum].Units.Small, unit )
					
				else
				
					--WARN("*AI DEBUG "..unit:GetAIBrain().Nickname.." FOUND TRANSPORT NOT ENOUGH SLOTS for "..unit:GetBlueprint().Description)
					
					LOUDINSERT(leftoverUnits, unit)
					
				end
				
			else
			
				--LOG('*AI DEBUG: NO TRANSPORT FOUND')
				LOUDINSERT(leftoverUnits, unit)
				
			end
			
		end

		return transportTable, leftoverUnits
		
	end	

	-- tables that hold those units which are NOT loaded yet
	-- broken down by their TransportClass size
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
	
	counter = 0

	-- check the unit platoon, load the unit remaining tables, and count
	if PlatoonExists( aiBrain, UnitPlatoon) then
	
		-- load the unit remaining tables according to TransportClass size
		for k, v in GetPlatoonUnits(UnitPlatoon) do
	
			if v and not v.Dead then

				counter = counter + 1

				if v.TransportClass == 3 then
				
					LOUDINSERT( remainingSize3, v )
					
				elseif v.TransportClass == 2 then
				
					LOUDINSERT( remainingSize2, v )
					
				elseif v.TransportClass == 1 then
				
					LOUDINSERT( remainingSize1, v )
					
				else
				
					WARN("*AI DEBUG "..aiBrain.Nickname.." Cannot transport "..GetBlueprint(v).Description)
					counter = counter - 1  -- take it back
					
				end
			
				if IsUnitState( v, 'Attached') then
				
					LOG("*AI DEBUG unit "..v:GetBlueprint().Description.." is attached at "..repr(v:GetPosition()))
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
					
				end
				
			end
			
		end
		
	end

	-- if units were assigned - sort them and tag them for specific transports
	if counter > 0 then
	
		-- flag the unit platoon as busy
		UnitPlatoon.UsingTransport = true
	
		local leftoverUnits = {}
		local currLeftovers = {}
	
		-- assign the large units - note how we come back with leftoverunits here
		transportTable, leftoverUnits = SortUnitsOnTransports( transportTable, remainingSize3 )
		
		-- assign the medium units - but this time we come back with currleftovers
		transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize2 )
	
		-- and we move any currleftovers into the leftoverunits table
		for k,v in currLeftovers do
		
			if not v.Dead then
			
				LOUDINSERT(leftoverUnits, v)
				
			end
			
		end
		
		currLeftovers = {}
	
		-- assign the small units - again coming back with currleftovers
		transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize1 )
	
		-- again adding currleftovers to the leftoverunits table
		for k,v in currLeftovers do
		
			if not v.Dead then
			
				LOUDINSERT(leftoverUnits, v)
				
			end
			
		end
		
		currLeftovers = {}
	
		if LOUDGETN(leftoverUnits) > 0 then
		
			transportTable, currLeftovers = SortUnitsOnTransports( transportTable, leftoverUnits )
			
		end
	
	
		-- send any leftovers to RTB --
		if LOUDGETN(currLeftovers) > 0 then
		
			for _,v in currLeftovers do
			
				IssueClearCommands({v})
				
			end
	
			local ident = Random(1,999999)
			local returnpool = aiBrain:MakePlatoon('RTB - Excess in SortingOnTransport'..tostring(ident), 'none')
		
			AssignUnitsToPlatoon( aiBrain, returnpool, currLeftovers, 'Unassigned', 'None' )
			
			returnpool.PlanName = 'ReturnToBaseAI'
			returnpool.BuilderName = 'SortUnitsOnTransportsLeftovers'..tostring(ident)
			
			returnpool:SetAIPlan('ReturnToBaseAI',aiBrain)
			
		end
		
	end

	remainingSize3 = nil
    remainingSize2 = nil
    remainingSize1 = nil


	-- At this point all units should be assigned to a given transport or dismissed
	local loading = false
	
	-- loop thru the transports and order the units to load onto them	
    for k, data in transportTable do
	
		local loadissued = false
		local unitstoload = false
		
		counter = 0
		
		-- look for dead/missing units in this transports unit list
		-- and those that may somehow be attached already
        for size,unitlist in data.Units do
		
			for u,v in unitlist do
			
				if v and not v.Dead then

					if not unitstoload then
						unitstoload = {}
					end
					
					unitstoload[counter+1] = v
					counter = counter + 1
					
				else
				
					data.Units[size][u] = nil
					
				end
				
			end
			
		end

		-- if units are assigned to this transport
        if LOUDGETN( data.Units["Large"] ) > 0 then
		
            IssueClearCommands( data.Units["Large"] )
			
			loadissued = true
			
		end
		
		if LOUDGETN( data.Units["Medium"] ) > 0 then
		
            IssueClearCommands( data.Units["Medium"] )
		
			loadissued = true
			
		end
		
		if LOUDGETN( data.Units["Small"] ) > 0 then
		
            IssueClearCommands( data.Units["Small"] )
			
			loadissued = true
			
		end
		
		if not loadissued or not unitstoload then
		
			-- RTP any transport with nothing to load
			ForkTo( ReturnTransportsToPool, aiBrain, {data.Transport}, true )
			
		else
		
			local transport = data.Transport
			
			transport.InUse = true
		
			transport.WatchLoadingThread = transport:ForkThread( WatchUnitLoading, unitstoload, aiBrain )
			
			loading = true
			
		end
		
    end
	
	-- if loading has been issued watch it here
	if loading then
	
		if UnitPlatoon.WaypointCallback then
		
			--LOG("*AI DEBUG "..UnitPlatoon.BuilderName.." killing Waypoint Callback ")
		
			KillThread( UnitPlatoon.WaypointCallback )
			
			UnitPlatoon.WaypointCallback = nil
			
			UnitPlatoon.MovingToWaypoint = nil
			
		end
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." loading "..UnitPlatoon.BuilderName.." data is "..repr(UnitPlatoon))
	
		local loadwatch = true	
		
		while loadwatch do
		
			WaitTicks(11)
			
			loadwatch = false
			
			if PlatoonExists( aiBrain, transports) then
		
				for _,t in GetPlatoonUnits(transports) do
			
					if not t.Dead and t.WatchLoadingThread then
				
						loadwatch = true
						break
					
					end
				
				end
			
			end
		
		end
		
	end
	
	--LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." loadwatch complete")
	
	if not PlatoonExists(aiBrain, transports) then
		
		return false
		
	end

	-- Any units that failed to load send back to pool thru RTB
	if PlatoonExists( aiBrain, UnitPlatoon ) then
	
		local returnpool = false

		for k,v in GetPlatoonUnits(UnitPlatoon) do
	
			if v and (not v.Dead) then
		
				if not IsUnitState( v, 'Attached') then

					if not returnpool then
					
						local ident = Random(100000,999999)
						returnpool = aiBrain:MakePlatoon('FailTransportLoad'..tostring(ident), 'none' )
						
						returnpool.PlanName = 'ReturnToBaseAI'
						
						if not string.find(UnitPlatoon.BuilderName, 'FailLoad') then
						
							returnpool.BuilderName = 'FailLoad '..UnitPlatoon.BuilderName
							
						else
						
							returnpool.BuilderName = UnitPlatoon.BuilderName
							
						end
						
					end
				
					IssueClearCommands( {v} )
				
					-- there are simply places where a transport can't or won't pick up a unit - and the unit can't move to the transport
					if PlatoonExists( aiBrain, transports ) then
					
						Warp( v, transports:GetPlatoonPosition() )
						
					end

					AssignUnitsToPlatoon( aiBrain, returnpool, {v}, 'Attack', 'None' )
			
				end
				
			end
			
		end
	
		if returnpool then
		
			returnpool:SetAIPlan('ReturnToBaseAI', aiBrain )
			
		end
		
	end

	counter = 0
	
	-- count number of loaded transports and send empty ones home
	if PlatoonExists( aiBrain, transports ) then
	
		for k,v in GetPlatoonUnits(transports) do
	
			if v and (not v.Dead) and LOUDGETN(v:GetCargo()) == 0 then
			
				ForkTo( ReturnTransportsToPool, aiBrain, {v}, true )

				transports[k] = nil
			
			else
				counter = counter + 1
			end
			
		end	
		
	end

	-- plan the move and send them on their way
	if counter > 0 then
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." plot transport movement ")
	
		local platpos = GetPlatoonPosition(transports) or false
		
		if platpos then
	
			-- I use the number of transports as a multiplier so that large transport groups will accept larger threat levels
			-- essentially giving each transport an air threat level of 14
			local safePath, reason = transports.PlatoonGenerateSafePathToLOUD(aiBrain, transports, 'Air', platpos, location, counter * 13, 240)
		
			if not safePath then
				LOG("*AI DEBUG "..aiBrain.Nickname.." USETRANSPORTS finds no safe path to "..repr(location).." using threat of "..counter * 13)
			end
		
			if PlatoonExists( aiBrain, transports) then
		
				IssueClearCommands( GetPlatoonUnits(transports) )

				if safePath and aiBrain.CycleTime > 720 then 
			
					local prevposition = GetPlatoonPosition(transports) or false
		
					for _,p in safePath do
				
						if prevposition then

							local Direction = import('/lua/utilities.lua').GetDirectionInDegrees( prevposition, p )
					
							IssueFormMove( GetPlatoonUnits(transports), p, 'AttackFormation', Direction)
						
							prevposition = p
					
						end
					
					end
				
				else
			
					-- go direct ?? -- what ?
					IssueFormMove( GetPlatoonUnits(transports), location, 'AttackFormation', import('/lua/utilities.lua').GetDirectionInDegrees( GetPlatoonPosition(transports), location )) 
				
				end
			
				for _,v in GetPlatoonUnits(transports) do
		
					if not v.Dead then
			
						v.WatchTravelThread = v:ForkThread(WatchTransportTravel, location, aiBrain)		
				
					end
			
				end
				
			end
		
		end
		
	end
	
	local transporters = GetPlatoonUnits(transports) or false
	
	-- if there are loaded, moving transports, watch them while traveling
	if transporters and LOUDGETN(transporters) != 0 then
	
		-- this sets up the transports platoon ability to call for help and to detect major threats to itself
		-- we'll also use it to signal an 'abort transport' capability using the DistressCall field
		transports:ForkThread( transports.PlatoonCallForHelpAI, aiBrain )
		
		transports.AtGoal = false -- flag to allow unpathed unload of the platoon
		
		local travelwatch = true
		
		-- loop here until all transports signal travel complete
		-- each transport should be running the WatchTravel thread
		-- until it dies, the units it is carrying die or it gets to target
		while travelwatch do
		
			WaitTicks(9) -- we run twice as hot as the watchtravel thread so we catch it quickly

			travelwatch = false
		
			for _,t in transporters do
			
				if t.WatchTravelThread and not t.Dead then
				
					travelwatch = true
					break
					
				end
				
			end
			
		end
		
    end

	transporters = GetPlatoonUnits(transports) or false
	
	-- watch the transports until they signal unloaded or dead
	if transporters and LOUDGETN(transporters) != 0 then
		
		local unloadwatch = true
		
		while unloadwatch do
		
			WaitTicks(10)
			
			unloadwatch = false
		
			for _,t in GetPlatoonUnits(transports) do
			
				if t.WatchUnloadThread and not t.Dead then
				
					unloadwatch = true
					break
					
				end
				
			end
			
		end
		
    end
	
	if not PlatoonExists(aiBrain,UnitPlatoon) then
        return false
    end
	
	UnitPlatoon.UsingTransport = false
	
	return true
	
end

-- This gets called whenever a unit failed to unload properly - rare
-- Forces the unload & RTB the unit
function ReturnUnloadedUnitToPool( aiBrain, unit )

	local attached = true
	
	if not unit.Dead then
	
		IssueClearCommands( {unit} )

		local ident = Random(1,999999)
		local returnpool = aiBrain:MakePlatoon('ReturnToPool'..tostring(ident), 'none')

		AssignUnitsToPlatoon( aiBrain, returnpool, {unit}, 'Unassigned', 'None' )
		returnpool.PlanName = 'ReturnToBaseAI'
		returnpool.BuilderName = 'FailedUnload'

		while attached and not unit.Dead do
			attached = false
	
			if IsUnitState( unit, 'Attached') then
				attached = true
			end
		
			WaitTicks(20)
		end

		returnpool:SetAIPlan('ReturnToBaseAI', aiBrain )
		
	end
	
	return
end

-- This utility should get called anytime a transport finishes unloading units
-- it will force the transport into the Transport pool & pass control over to the RTP utility
function AssignTransportToPool( unit, aiBrain )

	if not unit.Dead then
	
		IssueClearCommands( {unit} )
		
		WaitTicks(1)
		
		local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." ATTP for "..unit:GetBlueprint().Description)
		
		-- if not in need of repair or fuel -- 
		if not ProcessAirUnits( unit, aiBrain ) then

			if not unit.ReturnToPoolCallbackSet then

				unit:AddUnitCallback( function(unit)
		
					if table.getn(unit:GetCargo()) == 0 then
				
						if unit.WatchUnloadThread then
					
							KillThread(unit.WatchUnloadThread)
							unit.WatchUnloadThread = nil
						
						end
					
						ForkTo( AssignTransportToPool, unit, aiBrain )
					
					end
				
				end, 'OnTransportDetach')
			
				unit.ReturnToPoolCallbackSet = true
			end
			
			AssignUnitsToPlatoon( aiBrain, aiBrain.TransportPool, {unit}, 'Support','')
		
			unit.PlatoonHandle = aiBrain.TransportPool
		
			unit.InUse = false			

			return ReturnTransportsToPool( aiBrain, {unit}, true )
			
		end
		
	end
	
end
	
--  This routine should get transports on the way back to an existing base 
--  BEFORE adding them back to the Transport Pool
function ReturnTransportsToPool( aiBrain, units, move )

    local unit = false

	-- make sure all units are unloaded
    for k,v in units do
	
        if v and v.Dead then
		
			units[k] = nil
			
		elseif v and v.Sync.id and ((not unit) or unit == nil) then

			unit = v

			-- unload any units it might have
			if EntityCategoryContains(categories.TRANSPORTFOCUS,v) and table.getn(v:GetCargo()) > 0 then
				
				local unloadedlist = v:GetCargo()
				
				IssueTransportUnload(v, v:GetPosition())
				
				WaitTicks(3)
				
				for _,unloadedunit in unloadedlist do
				
					ForkTo(ReturnUnloadedUnitToPool,aiBrain,unloadedunit)
					
				end
				
			end
			
		end
		
    end
	
	if not unit or unit == nil then
	
		return
		
	end
	
    local x = aiBrain.StartPosX
	local z = aiBrain.StartPosZ
	
	local baseposition = import('/lua/loudutilities.lua').AIFindClosestBuilderManagerPosition( aiBrain, unit:GetPosition())
	
	if baseposition then
	
		x = baseposition[1]
		z = baseposition[3]
		
	end
	
    local position = AIUtils.RandomLocation(x,z)
	
	local unit = false
	local unitcount = 0
	
	if move then

		units = aiBrain:RebuildTable(units)	
	
		for k,v in units do
		
			if v and not v.Dead then
			
				IssueClearCommands( {v} )
				unitcount = unitcount + 1
				
				if not unit then
					unit = v
				end
				
			elseif v and v.Dead then
			
				units[k] = nil
				
			end
			
		end
		
		if unitcount > 0 then
		
			units = aiBrain:RebuildTable(units)
			
			local safePath, reason = aiBrain.TransportPool.PlatoonGenerateSafePathToLOUD(aiBrain, unit.PlatoonHandle, 'Air', unit:GetPosition(), position, 14 * unitcount, 240)
			
			if safePath then
			
				-- use path
				for _,p in safePath do
					IssueMove( units, p )
				end
				
			else
			
				-- go direct -- possibly bad
				IssueMove( units, position )
				
			end
	
			for k,unit in units do
	
				-- move the units to the correct pool - pure transports to Transport Pool
				-- all others -- including temporary transports (UEF T2 gunship) to Army Pool
				if not unit.Dead then
				
					if LOUDENTITY( categories.TRANSPORTFOCUS - categories.uea0203, unit ) then
			
						AssignUnitsToPlatoon( aiBrain, aiBrain.TransportPool, {unit}, 'Support', '' )
						
						unit.PlatoonHandle = aiBrain.TransportPool
			
					else
					
						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit:GetBlueprint().Description.." added to Army Pool")
				
						AssignUnitsToPlatoon( aiBrain, aiBrain.ArmyPool, {unit}, 'Unassigned', '' )
						
						unit.PlatoonHandle = aiBrain.ArmyPool
				
					end
			
					unit.InUse = false
	
				end
		
			end
			
		end
	
	end
	
	
	if not aiBrain.CheckTransportPoolThread then
	
		aiBrain.CheckTransportPoolThread = ForkThread( CheckTransportPool, aiBrain )
		
	end
	
end

-- This utility will traverse all true transports to insure they are in the TransportPool
function CheckTransportPool( aiBrain )

	local TransportPool = aiBrain.TransportPool

	-- get all idle, fully built transports except UEF gunship --
	local unitlist = aiBrain:GetListOfUnits(((categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203)), true, true)
	
	for k,v in unitlist do
	
		if v and v.PlatoonHandle != TransportPool and v:GetFractionComplete() == 1 then
		
			local platoon = v.PlatoonHandle or false
			local oldplatoonname = false
			
			if platoon then
				oldplatoonname = platoon.BuilderName or false
			end
			
			if (not v:IsIdleState()) or v.InUse or (platoon and PlatoonExists(aiBrain,platoon)) then
			
				if not v:IsIdleState() then
					continue
				end
				
				if platoon.CreationTime and (aiBrain.CycleTime - platoon.CreationTime) < 360 then
					continue
				end
				
			end
			
			IssueClearCommands( {v} )
			
			if v.WatchLoadingThread then
			
				LOG("*AI DEBUG Killing Watch Loading thread in CheckTransportPool")
				KillThread(v.WatchLoadingThread)
				v.WatchLoadingThread = nil
				
			end
			
			if v.WatchTravelThread then
			
				LOG("*AI DEBUG Killing Watch Travel Thread in CheckTransportPool")
				KillThread(v.WatchTravelThread)
				v.WatchTravelThread = nil
				
			end
			
			if platoon and PlatoonExists(aiBrain,platoon) then
			
				if platoon != aiBrain.ArmyPool and platoon != aiBrain.RefuelPool then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." disbanding old "..repr(platoon.BuilderName).." platoon")
					aiBrain:DisbandPlatoon(platoon)
					
				end
			end

			ForkTo( AssignTransportToPool, v, aiBrain )
			
		end
		
		v.InUse = false
	end
	
	aiBrain.CheckTransportPoolThread = nil
end

function GetGuards( aiBrain, Unit)

	local engs = GetUnitsAroundPoint( aiBrain, categories.ENGINEER, Unit:GetPosition(), 20, 'Ally' )
	local count = 0
	local UpgradesFrom = Unit:GetBlueprint().General.UpgradesFrom
	
	for k,v in engs do
	
		if v:GetUnitBeingBuilt() == Unit and v != Unit then
			count = count + 1
		end
		
	end
	
	if UpgradesFrom and UpgradesFrom != 'none' then -- Used to filter out upgrading units
	
		local oldCat = LOUDPARSE(UpgradesFrom)
		local oldUnit = GetUnitsAroundPoint( aiBrain, oldCat, Unit:GetPosition(), 0, 'Ally' )
		
		if oldUnit then
			count = count + 1
		end
		
	end
	
	return count
end

function FindUnfinishedUnits( aiBrain, locationType, buildCat )

	local GetFractionComplete = moho.entity_methods.GetFractionComplete
	
	local unfinished = GetUnitsAroundPoint( aiBrain, buildCat, aiBrain.BuilderManagers[locationType].Position, 80, 'Ally' )
	
	for num, unit in unfinished do
		if GetFractionComplete(unit) < 1 and GetGuards(aiBrain, unit) < 1 then 
			return unit
		end
	end
	
	return false
	
end

--	This function will return threat and distance data from entries in the HighPriorityList
--	Returns:
--		A list of data with the following elements
--			Position	- a 3D position vector
--			Threats		- four of them: AirThreat, EcoThreat, SubThreat & SurThreat
--			Distance	- # of ogrids to the position based upon location
--			Type		- the class of threat (StructuresNotMex, Experimental, Commander, Air, Land, etc.)
--			LastScouted - gametime when position was last scouted
function GetHiPriTargetList(aiBrain, location)

    local threatlist = table.copy(aiBrain.IL.HiPri)

	LOUDSORT( threatlist, function(a,b) return VDist2Sq(a.Position[1],a.Position[3],location[1],location[3]) < VDist2(b.Position[1],b.Position[3],location[1],location[3]) end )	

	local intelresolution = ScenarioInfo.IntelResolution

	intelresolution = math.min( 64, intelresolution )
	
	local targetlist = {}
	local counter = 0
	
	local GetBlueprint = moho.entity_methods.GetBlueprint
	local VDist2 = VDist2Sq

	local checkspertick = 2
	local checks = 0
	
	local prev_position = {}
	
    for _,threat in threatlist do
	
		if table.equal( threat.Position, prev_position ) then
		
			continue
			
		end

		if checks > 2 then
		
			WaitTicks(1)
			checks = 1
			
		else
		
			checks = checks + 1
			
		end
	
		local targets = GetUnitsAroundPoint(aiBrain, categories.ALLUNITS - categories.WALL, threat.Position, intelresolution, 'Enemy')
		
		local allthreat = 0.0
		local airthreat = 0.0
		local ecothreat = 0.0
		local subthreat = 0.0
		local surthreat = 0.0

		if targets then
		
			for _, target in targets do
			
				if not target.Dead then
				
					local bp = GetBlueprint(target).Defense
					
					airthreat = airthreat + bp.AirThreatLevel
					ecothreat = ecothreat + bp.EconomyThreatLevel
					subthreat = subthreat + bp.SubThreatLevel
					surthreat = surthreat + bp.SurfaceThreatLevel
					
				end
				
			end
			
			allthreat = ecothreat + subthreat + surthreat + airthreat
			
		end
		
		if threat.Position and allthreat > 0 then
		
			targetlist[counter+1] = { Position = threat.Position, Type = threat.Type, LastScouted = threat.LastScouted,  Distance = VDist2(location[1],location[3], threat.Position[1],threat.Position[3]), Threats = { Air = airthreat, Eco = ecothreat, Sub = subthreat, Sur = surthreat, All = allthreat} }
			
			counter = counter + 1
			
			prev_position = table.copy(threat.Position)
			
		end
		
    end
	
	return targetlist
end

-- this function will ping the map and/or put markers on the map
function AISendPing( position, pingType, army, message )

	local note = false
	
	if message then
		note = message
	end

	local PingTypes = {
       alert = {Lifetime = 5, Mesh = 'alert_marker', Ring = '/game/marker/ring_yellow02-blur.dds', ArrowColor = 'yellow', Sound = 'UEF_Select_Radar'},
       move = {Lifetime = 4, Mesh = 'move', Ring = '/game/marker/ring_blue02-blur.dds', ArrowColor = 'blue', Sound = 'Cybran_Select_Radar'},
       attack = {Lifetime = 5, Mesh = 'attack_marker', Ring = '/game/marker/ring_red02-blur.dds', ArrowColor = 'red', Sound = 'Aeon_Select_Radar'},
       marker = {Lifetime = 2, Ring = '/game/marker/ring_yellow02-blur.dds', ArrowColor = 'yellow', Sound = 'UI_Main_IG_Click', Marker = true},
	   warning = {Lifetime = 4, Mesh = 'alert_marker', Ring = '/game/marker/ring_blue02-blur.dds', ArrowColor = 'blue', Sound = 'UI_Main_IG_Click'},
	}

	if PingTypes[pingType] then
	if not note then
			-- standard map pings --
		import('/lua/simping.lua').SpawnPing( table.merged( {Owner = army - 1, Type = pingType, Location = position} , PingTypes[pingType] ) )
	else
			-- ping the map and place a marker --
		return import('/lua/simping.lua').SpawnPing( table.merged( {Owner = army - 1, Type = pingType, Location = position, Name = note, Color = 'ffe80a0a'} , PingTypes[pingType] ) )
		end
	end
end
