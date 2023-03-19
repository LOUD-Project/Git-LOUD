--  File     :  /lua/altaiutilities.lua

local import = import

local AIUtils = import('/lua/ai/aiutilities.lua')

local LOUDCOPY = table.copy
local LOUDENTITY = EntityCategoryContains
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn

local LOUDCONCAT = table.cat
local LOUDEQUAL = table.equal
local LOUDINSERT = table.insert
local LOUDPARSE = ParseEntityCategory
local LOUDREMOVE = table.remove
local LOUDSORT = table.sort

local ForkTo = ForkThread

local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local WaitTicks = coroutine.yield

local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon

local IsBeingBuilt = moho.unit_methods.IsBeingBuilt
local IsUnitState = moho.unit_methods.IsUnitState

local GetFractionComplete = moho.entity_methods.GetFractionComplete
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetPosition = moho.entity_methods.GetPosition
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint

local IsIdleState = moho.unit_methods.IsIdleState

local PlatoonExists = moho.aibrain_methods.PlatoonExists


local function NormalToBuildLocation(location)
	return {location[1], location[3], 0}
end
    
function AssistBody(self, eng, aiBrain)

    local assistData = self.PlatoonData.Assist
	
	local assisteeType = assistData.AssisteeType
	local locationType = eng.LocationType
    local BuilderManager = aiBrain.BuilderManagers[locationType]
	
    local assistee = false
	local assistRange = assistData.AssistRange or 80

    local beingBuilt = assistData.BeingBuiltCategories or categories.ALLUNITS
    local assisteeCat = assistData.AssisteeCategory or categories.ALLUNITS

	local ass_count = 0
	local beingbuiltcategory, assistList, platoonPos
    
    local GetPosition = GetPosition
    
    local VDist3 = VDist3
    local LOUDV3Sq = VDist3Sq
	
	-- this function will locate units needing assistance of the specific type --
	local function GetAssistees( beingbuiltcategory )

		if assisteeType == 'Factory' then
	
			return BuilderManager.FactoryManager:GetFactoriesWantingAssistance( beingbuiltcategory, assisteeCat )
		
		elseif assisteeType == 'Engineer' then
	
			return BuilderManager.EngineerManager:GetEngineersWantingAssistanceWithBuilding( beingbuiltcategory, assisteeCat )
		
		elseif assisteeType == 'Structure' then
	
			return BuilderManager.PlatoonFormManager:GetUnitsBeingBuilt( aiBrain, beingbuiltcategory, assisteeCat )
    
		elseif assisteeType == 'Any' then
		
			local list = {}
	
			list = LOUDCONCAT( list, BuilderManager.PlatoonFormManager:GetUnitsBeingBuilt( aiBrain, beingbuiltcategory, assisteeCat ))
		
			list = LOUDCONCAT( list, BuilderManager.EngineerManager:GetEngineersWantingAssistanceWithBuilding( beingbuiltcategory, assisteeCat ))

			return list
		end

		return {}
	end

	for k,catString in beingBuilt do

        beingbuiltcategory = catString

		assistList = GetAssistees( beingbuiltcategory )

        if assistList[1] then

			-- we'll use the base position rather than the engineer --
			platoonPos = BuilderManager.Position or false
 			
            LOUDSORT( assistList, function(a,b) local GetPosition = GetPosition local LOUDV3Sq = LOUDV3Sq return LOUDV3Sq( GetPosition(a), platoonPos) < LOUDV3Sq( GetPosition(b), platoonPos) end )

            for _,v in assistList do
			
				if not v.Dead then

					ass_count = ass_count + 1					
					
                    if VDist3( GetPosition(v), platoonPos) <= assistRange then
					
                        assistee = v
                        break
						
                    else
					
						--LOG("*AI DEBUG Assistee at "..repr(v:GetPosition()).." beyond eng from "..eng.LocationType.." at "..repr(platoonPos).." assist range of "..assistRange)
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
        eng.AssistPlatoon = nil
    end
	
end

function UnfinishedBody(self, eng, aiBrain)

    local assistData = self.PlatoonData.Assist

    local beingBuilt = assistData.BeingBuiltCategories or categories.ALLUNITS
    local range = assistData.Range or 80
    
    local position = aiBrain.BuilderManagers[self.BuilderLocation].Position
	
    local category, assistList
    

    local function FindUnfinishedUnits(category)

        local GetFractionComplete = GetFractionComplete
	
        local unfinished = GetUnitsAroundPoint( aiBrain, category, position, range or 80, 'Ally' )
	
        for num, unit in unfinished do
        
            if GetFractionComplete(unit) < 1 and GetGuards(aiBrain, unit) < 1 then 
                return unit
            end
            
        end
	
        return false
	
    end
    
    for _,category in beingBuilt do

        assistList = FindUnfinishedUnits(category)

		if assistList then
			break
        end
        
    end

    if assistList then
		
        self:Stop()

		eng.UnitBeingBuilt = assistList
        IssueGuard( {eng}, assistList )

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
			counter = counter + 1
			possibles[counter] = v[1]

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
-- position is NOT driven by the Attack Plan but by the source base of the engineer doing this job
function AIFindBaseAreaForExpansion( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local BuilderManager = aiBrain.BuilderManagers[locationType]
    local Position = BuilderManager.Position or false
	
    -- this option (unused at the moment) allows us to base the checks on the engineers position
    -- you might use that on an engineer out in the field for example
	if eng then
		Position = eng
	end
	
	if Position then
    
        local VDist3 = VDist3

        local position
		local positions = {}

		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
	
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))
	
		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], BuilderManager.Position[1],BuilderManager.Position[3]) < VDist2Sq(b.Position[1],b.Position[3], BuilderManager.Position[1],BuilderManager.Position[3] ) end )
	
		-- I put a check in here to eliminate not only the current position but any position within a range of the current position
		-- I expanded this concept further to base the exclusion radius upon map size
		-- The idea of this is to give the AI an emphasis on expanding his bases to cover a greater portion of the map rather
		-- than clumping up - this also avoids overlap of the army pools 
	
		-- cap the minimum baserange at 165
		local minimum_baserange = 165
	
		local Brains = ArmyBrains
        local removed = false
    
		-- loop thru all the positions
		for m,marker in positions do
        
            position = marker.Position
	
			removed = false
		
			-- check all the other brains to see if they own it already
			for index,brain in Brains do
			
				-- if someone else owns it or the co-ordinates are the same as this brains 'MAIN' position -- 
				if brain.BuilderManagers[marker.Name] or ( position[1] == brain.BuilderManagers['MAIN'].Position[1] and position[3] == brain.BuilderManagers['MAIN'].Position[3] ) then
					
					removed = true
					break
				end
			end
		
			if not removed then

				-- check if position is within range of other 'counted' bases
				for basename,base in aiBrain.BuilderManagers do
				
					-- ignore position if too close to existing counted bases (non-Sea)
					if (base.CountedBase and base.BaseType != 'Sea') and VDist3( base.Position, position ) < minimum_baserange then
					
						removed = true
						break
					end
				end
			
				if not removed then
				
					return position, marker.Name
				end
			end
		end

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

        local VDist3 = VDist3

        local position
		local positions = {}
	
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))	
	
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))

		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )

		local minimum_baserange = 200
    
		local Brains = ArmyBrains
        
        local removed = false

		for m,marker in positions do
	
            position = marker.Position
			removed = false

			for index,brain in Brains do
        
				-- if someone else owns it or the co-ordinates are the same as this brains 'MAIN' position -- 
				if brain.BuilderManagers[marker.Name] or ( position[1] == brain.BuilderManagers['MAIN'].Position[1] and position[3] == brain.BuilderManagers['MAIN'].Position[3] ) then
			
					removed = true
				
					break
				end
			end
		
			if not removed then
			
				for basename, base in aiBrain.BuilderManagers do
			
					if (base.CountedBase and base.BaseType != 'Sea') and VDist3( base.Position, position ) < minimum_baserange then
				
						removed = true
						
						break
					end
				end
			
				if not removed then
					return position, marker.Name
				end
			end
		end

	end

	return false, false
end

-- finds DP and EXPANSION BASE(regular not LARGE) markers - minimum range to ANY other LAND base is 180
-- non-counted bases that operate as forward positions or intel gathering locations
function AIFindDefensivePointForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
		Position = eng
	end
	
    if Position and aiBrain.PrimaryLandAttackBase and aiBrain.AttackPlan.Goal then

        local VDist3 = VDist3
	
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
        -- we'll use the current PRIMARY LAND BASE as the centrepoint for radius
        local test_position = aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position or Position
		local test_range = VDist3( test_position, aiBrain.AttackPlan.Goal )	

        local position
		local positions = {}
	
		positions = LOUDCONCAT( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', test_position, radius, tMin, tMax, tRings, tType))
	
		positions = LOUDCONCAT( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', test_position, radius, tMin, tMax, tRings, tType))

		-- sort the positions by distance from Position --
		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], test_position[1],test_position[3]) < VDist2Sq(b.Position[1],b.Position[3], test_position[1],test_position[3] ) end )

		local Brains = ArmyBrains

		-- minimum range that a DP can be from an existing base -- Land	
		local minimum_baserange = 180

        local removed = false
        
		-- so we now have a list of ALL the DP positions on the map	-- loop thru the list and eliminate any that are already in use 
		for m,marker in positions do
	
            position = marker.Position
			removed = false

			for index,brain in Brains do

				if brain.BuilderManagers[marker.Name] then
                    
					removed = true
					break
				end
			end
		
			-- if it's still valid -- check my own bases and exclude anything too close to ANY existing base
			if not removed then

				for basename, base in aiBrain.BuilderManagers do
		
					if VDist3( base.Position, position ) < minimum_baserange or VDist3( aiBrain.AttackPlan.Goal, position ) > test_range then

						removed = true
						break
					end
				end

				if not removed then

					return position, marker.Name
				end	
			end
		end
	end

	return false, false
end

-- finds Naval DPs - minimum range to ANY sea base is 200 - allows ALLIED base sharing --
function AIFindNavalDefensivePointForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
		Position = eng
	end
	
    if Position then

        local VDist3 = VDist3
        
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
        -- we'll use the current PRIMARY LAND BASE as the centrepoint for radius
        local test_position = aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position or Position
		local test_range = VDist3( test_position, aiBrain.AttackPlan.Goal )	

        local position
		local positions = {}
	
		local positions = LOUDCONCAT(positions,AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Defensive Point', test_position, radius, tMin, tMax, tRings, tType))

		-- sort the possible positions by distance from the test_position -- 
		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], test_position[1],test_position[3]) < VDist2Sq(b.Position[1],b.Position[3], test_position[1],test_position[3] ) end )
	
		local Brains = ArmyBrains
	
		-- minimum range that a DP can be from an existing base -- Naval
		local minimum_baserange = 200
        
        local removed = false
	
		-- so we now have a list of ALL the Naval DP positions on the map
		-- loop thru the list and eliminate any that are already in use by enemy AI 
		-- the DP differs from the normal base in that we want to allow sharing with allies
		-- note how I have to exclude my own brain as an ally to avoid sharing existing bases with myself
		for m,marker in positions do
	
            position = marker.Position
			removed = false

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
					if VDist3( base.Position, position ) < minimum_baserange then

						removed = true
						break
					end
				end
		
				if not removed then
		
					return position, marker.Name
				end	
			end
		end
	end

	return false, false
end

-- finds Naval Areas - minimum range to ANY sea base is 200 - NO ALLIED sharing --
function AIFindNavalAreaForExpansion( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
		Position = eng
	end
	
    if Position then 
    
        local VDist3 = VDist3

        local position
		local positions = {}
	
		local positions = LOUDCONCAT(positions,AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Area', Position, radius, tMin, tMax, tRings, tType))

		-- sort the possible positions by distance -- 
		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )
	
		local Brains = ArmyBrains
	
		-- minimum range that a Naval Base can be from any existing base
		local minimum_baserange = 200
        
        local removed = false
	
		-- so we now have a list of ALL the Naval DP positions on the map
		-- loop thru the list and eliminate any that are already in use by enemy AI 
		-- the DP differs from the normal base in that we want to allow sharing with allies
		-- note how I have to exclude my own brain as an ally to avoid sharing existing bases with myself
		for m,marker in positions do
	
            position = marker.Position
			removed = false

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
					if base.BaseType == 'Sea' and VDist3( base.Position, position ) < minimum_baserange then

						removed = true
						break
					end
				end

				if not removed then
                
					return position, marker.Name
				end						
            end
		end
	end
    
    LOG("*AI DEBUG "..aiBrain.Nickname.." finds no NAVALAREA ")

	return false, false
end


-- these functions check various types of markers that dont have any allied structures in radius of the given categories
-- it also threat checks the markers and will return the closest one that passes both tests
-- this one checks both Start and Large Expansion bases
function AIFindBasePointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
    if Position then

        local catcheck = LOUDPARSE(category)

        local position
		local positions = {}
	
		-- both Start and Large Expansion Areas --
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
		
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))	

		-- sort by distance from Position
		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Position[1], Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1], Position[3] ) end )
    
		-- loop and check unit counts - exit on first good --
		for _,v in positions do
        
            position = v.Position
		
			if GetNumUnitsAroundPoint( aiBrain, catcheck, position, markerRadius, 'Ally') <= unitMax then
			
				return position, v.Name
			end
		end
	end
	
	return false, false
end

-- as above but examines DPs and 'small' Expansion Areas
function AIFindDefensivePointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)
	
    local Position = aiBrain.BuilderManagers[locationType].Position or false

    if Position then

        local catcheck = LOUDPARSE(category)
        
        local position
		local positions = {}
	
		-- both DPs and 'small' Expansion Areas --
		positions = LOUDCONCAT( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', Position, radius, tMin, tMax, tRings, tType))
		
		positions = LOUDCONCAT( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', Position, radius, tMin, tMax, tRings, tType))
    
		LOUDSORT( positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( a.Position[1],a.Position[3], Position[1],Position[3] ) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3]) end )

		for _,v in positions do
        
            position = v.Position
		
			if GetNumUnitsAroundPoint( aiBrain, catcheck, position, markerRadius, 'Ally' ) <= unitMax then

				return position, v.Name
			end	
		end
	end
	
	return false, false
end

-- as above but examines only LARGE Expansion Areas
function AIFindExpansionPointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)

    local Position = aiBrain.BuilderManagers[locationType].Position or false

    if Position then

        local catcheck = LOUDPARSE(category)
        
        local position
		local positions = {}
	
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))

		LOUDSORT( positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )	
		
		for k,v in positions do
        
            position = v.Position
		
			if AIUtils.GetNumberOfOwnUnitsAroundPoint( aiBrain, catcheck, position, markerRadius ) <= unitMax then

				return position, v.Name
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
		
        local VDist2 = VDist2
        local VDist3 = VDist3
        
		local test_range = false
        local test_position = false
        
        local Goal = LOUDCOPY(aiBrain.AttackPlan.Goal)
		
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
        -- and we'll use the current PRIMARY base as the centre of our test range
		if aiBrain.PrimarySeaAttackBase then
		
            test_position = aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position
			test_range = VDist3( test_position, Goal )
		else
            test_position = aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position or false
			test_range = VDist3( test_position, Goal )
		end
	
		-- minimum range that a DP can be from an existing naval position
		local minimum_baserange = 200
		
        local catcheck = LOUDPARSE(category)
        
        local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD
        local PrimarySeaAttackBasePosition = aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position 
        
        local position
		local positions = {}

        local path, reason, reject

		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Defensive Point', test_position or Position, radius, tMin, tMax, tRings, tType))
    
		LOUDSORT( positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( a.Position[1],a.Position[3], test_position[1],test_position[3] ) < VDist2Sq(b.Position[1],b.Position[3], test_position[1],test_position[3]) end )
    
		-- loop thru positions and do the structure/unit count check
		-- originally intended to insure that there are no allied units of same category within radius of this position
		for k,v in positions do

            position = v.Position
            
			-- must be able to path from current Sea Primary to new position
            -- this prevents the AI from trying to locate naval DPs on another body of water
			path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, 'AttackPlanner', 'Water', PrimarySeaAttackBasePosition, position, 9999, 250 )

			if not path then
				continue
			end		

			-- check if there are existing structures at the point
			if GetNumUnitsAroundPoint( aiBrain, catcheck, position, markerRadius, 'Ally' ) <= unitMax then
			
				reject = false
		
				-- check proximity to OUR existing bases --
				for basename, base in aiBrain.BuilderManagers do
				
					if base.EngineerManager.Active then

						-- if too close to ANY of our other existing bases or further than our current primary sea attack base --
						if VDist2( base.Position[1],base.Position[3], position[1],position[3] ) < minimum_baserange or VDist2( Goal[1],Goal[3], position[1],position[3] ) > test_range then
						
							reject = true
							break
						end
					end
				end
				
				if not reject then
					return position, v.Name
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

        local catcheck = LOUDPARSE(category)
        
        local position
		local positions = {}
	
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
    
		LOUDSORT( positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( a.Position[1],a.Position[3], Position[1],Position[3] ) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3]) end )
	
		for k,v in positions do
        
            position = v.Position
		
			if position[1] == Position[1] and position[3] == Position[3] then
			
				LOUDREMOVE( positions, k )
				break
			end
		end
    
		for _,v in positions do
		
			if GetNumUnitsAroundPoint( aiBrain, catcheck, position, markerRadius, 'Ally' ) <= unitMax then

				return position, v.Name
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
		
        local unitPos = GetPosition(unit)
		
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




-- This function attempts to locate the required number of transports to move the platoon.
-- Modified to restrict the use of out of gas transports and to keep transports moving back to a base when not in use
-- Will now also limit transport selection to those within 16 km
function GetTransports( platoon, aiBrain)

    if platoon.UsingTransport then
        return false, false
    end

	local IsEngineer = platoon:PlatoonCategoryCount( categories.ENGINEER ) > 0
    
    local TransportDialog = ScenarioInfo.TransportDialog or false

	-- COLLECTION PHASE --
    -- first step is to collect available transports
    
    -- denotes if faction has 'special' transport units
	local Special = false
	
	if aiBrain.FactionIndex == 1 then
		Special = true
	end
	
    local transportpool = aiBrain.TransportPool
	local armypool = aiBrain.ArmyPool
	
	local armypooltransports = {}
	local TransportPoolTransports = false
	
	-- build table of transports for engineers - only T1/T2
	if IsEngineer then
	
		TransportPoolTransports = EntityCategoryFilterDown( (categories.AIR * categories.TRANSPORTFOCUS) - categories.TECH3 - categories.EXPERIMENTAL, GetPlatoonUnits(transportpool) )
    else

		TransportPoolTransports = EntityCategoryFilterDown( categories.AIR * categories.TRANSPORTFOCUS, GetPlatoonUnits(transportpool) )
    end
    
	-- get the T2 gunships --
	if Special then
		armypooltransports = EntityCategoryFilterDown( categories.uea0203, GetPlatoonUnits(armypool) )
	end
    
    -- if there are no transports available - we're done
    if (armypooltransports and LOUDGETN(armypooltransports) < 1) and (TransportPoolTransports and LOUDGETN(TransportPoolTransports) < 1) then
        return false, false
    end


	local CanUseTransports = false	-- used to keep from issuing false positive if no units are provided
	local neededTable = { Small = 0, Medium = 0, Large = 0, Total = 0 }
	
	for _, v in GetPlatoonUnits(platoon) do
	
		if v and not v.Dead then
			
			if v.TransportClass == 1 then
				CanUseTransports = true
				neededTable.Small = neededTable.Small + 1.0
                neededTable.Total = neededTable.Total + 1
				
			elseif v.TransportClass == 2 then
				CanUseTransports = true
				neededTable.Small = neededTable.Small + 0.34
				neededTable.Medium = neededTable.Medium + 1.0
                neededTable.Total = neededTable.Total + 1                    
				
			elseif v.TransportClass == 3 then
                CanUseTransports = true
				neededTable.Small = neededTable.Small + 0.5
				neededTable.Medium = neededTable.Medium + 0.25
				neededTable.Large = neededTable.Large + 1.0
                neededTable.Total = neededTable.Total + 1

			else
				LOG("*AI DEBUG "..v:GetBlueprint().Description.." has no transportClass value")
			end
		end	
	end

    if not CanUseTransports then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." cannot use transports in GetTransports")
        end
        
        return false, false
    end


	local LOUDCOPY = LOUDCOPY
	local LOUDENTITY = LOUDENTITY
    
    local VDist2 = VDist2
    
	local WaitTicks = WaitTicks
    
    local GetPlatoonPosition = GetPlatoonPosition

    
	platoon.UsingTransport = true	-- this will keep the platoon from doing certain things while it's looking for transport
	
	-- OK - so we now have 2 lists of units and we want to make sure the 'specials' get utilized first
	-- so we'll add the specials to the Available list first, and then the standard ones
	-- in this way, the specials will get utilized first, making good use of both the UEF T2 gunship
	-- and the Cybran Gargantuan
	local AvailableTransports = {}
    local transportcount = 0

    -- collect a list of all available transports
	if PlatoonExists(aiBrain,platoon) then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." getting available transports")
        end

		if armypooltransports[1] then

			for _,trans in armypooltransports do
            
                if IsBeingBuilt(trans) then
                    continue
                end
			
				if not trans.InUse then
                
                    if not trans.Assigning then
                    
                        transportcount = transportcount + 1				
                        AvailableTransports[transportcount] = trans

                        -- this puts specials into the transport pool -- occurs to me that they
                        -- may get stuck in here if it turns out we cant use transports
                        AssignUnitsToPlatoon( aiBrain, transportpool, {trans}, 'Support','none')
                    
                        -- limit collection of armypool transports to 15
                        if transportcount == 15 then
                            break
                        end
                    end
                    
				else
                    if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..trans.EntityID.." in ArmyPool in Use or Assigning during collection")
                    end
                end
			end
		end
		
		if TransportPoolTransports[1] then

			for _,trans in TransportPoolTransports do
            
                if IsBeingBuilt(trans) then
                    continue
                end
                
				if not trans.InUse then
                
                    if not trans.Assigning then
                
                        transportcount = transportcount + 1
                        AvailableTransports[transportcount] = trans

                    end
                    
				else
                
                    if TransportDialog then
                    
                        if trans.InUse then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..trans.EntityID.." in Use during collection")
                        end
                        if trans.Assigning then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..trans.EntityID.." Assigning during collection")
                        end
                        
                    end
                end
			end
		end
	end
	
    -- we no longer need the source lists
	armypooltransports = nil
	TransportPoolTransports = nil

    -- the platoon may have died while we did all this
	local location = false
	
    -- recheck the platoon and store the platoon location
    -- if no location then platoon may be dead/disbanded
	if PlatoonExists(aiBrain,platoon) then
		
		for _,u in GetPlatoonUnits(platoon) do
			if not u.Dead then
                location = LOUDCOPY(GetPlatoonPosition(platoon))
                break
			end
		end
	end	
	
	-- if we cant find any transports or platoon has no location
	if transportcount < 1 or not location then

		if not location then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." finds no platoon position")
            end
            
       		if transportcount > 0 then
                -- send all transports back into pool - which covers the specials (ie. UEF Gunships) 
                ForkThread( ReturnTransportsToPool, aiBrain, AvailableTransports, true )
            end
		end

		if transportcount < 1 then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." no transport available")
            end
        end

		platoon.UsingTransport = false
		
		return false, false
	end

	
    local transports = {}			-- this will hold the data for all of the eligible transports

	-- we assume we cannot use tranports
	CanUseTransports = false
	
	-- we'll accumulate the slots from all transports
	-- this will allow us to save a bunch of effort if we simply dont have enough transport capacity
	-- without having to do a lot of processing
	local Collected = { Large = 0, Medium = 0, Small = 0 }

	local GetFuelRatio = moho.unit_methods.GetFuelRatio
	local IsBeingBuilt = IsBeingBuilt
	local GetPosition = GetPosition
	
	local out_of_range = false
	
	-- Returns the number of slots the transport has available
	-- Originally, this function just counted the number of attachpoint bones of each size on the model
	-- however, this does not seem to work correctly - ie. UEF T3 Transport
	-- says it has 12 Large Attachpoints but will only carry 8 large units
	-- so I replaced that with some hardcoded values to improve performance, as each new transport
	-- unit comes into play, I'll cache those values on the brain so I never have to look them up again
	-- setup global table to contain Transport values- in this way we always have a reference to them
	-- without having to reread the bones or do all the EntityCategory checks from below
	local function GetNumTransportSlots( unit )
	
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
				bones.Large = 8
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
				bones.Medium = 10
				bones.Small = 28

			-- BrewLAN Seraphim transport
			elseif bones.Small == 0 and (categories.ssa0306 and EntityCategoryContains( categories.ssa0306, unit)) then
				bones.Large = 7
				bones.Medium = 15
				bones.Small = 32
				
			end
		
			aiBrain.TransportSlotTable[id] = bones

			return bones
		end
	end
    
    local counter = 0
    local unitPos, range, id
    
    local IsUnitState = IsUnitState

	-- now we filter out those that dont pass muster
	for k,transport in AvailableTransports do
    
        -- we have enough transport collected
        if CanUseTransports then
            break
        end
		
		if not transport.Dead then
        
            --if TransportDialog then
              --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." "..transport:GetBlueprint().Description.." being reviewed ")
            --end
            
			-- use only those that are not in use, not being built and have > 50% fuel and > 70% health
			if (not transport.InUse) and (not transport.Assigning) and (not IsBeingBuilt(transport)) and ( GetFuelRatio(transport) == -1 or GetFuelRatio(transport) > .50) and transport:GetHealthPercent() > .70  then
            
				-- use only those which are not already busy or are not loading already
				if (not IsUnitState( transport, 'Busy')) and (not IsUnitState( transport, 'TransportLoading')) then

					-- deny use of T1 transport to platoons needing more than 1 large transport
					if (not IsEngineer) and LOUDENTITY( categories.TECH1, transport ) and neededTable.Large > 1 then
					
						continue
						
					-- insert available transport into list of usable transports
					else
					
						unitPos = GetPosition(transport)
						range = VDist2( unitPos[1],unitPos[3], location[1], location[3] )

						-- limit to 18 km range -- this insures that transport wont expire before loading takes place
						-- as loading has a 120 second time limit --
						if range < 1800 then
                            
                            -- mark the transport as being assigned 
                            -- to prevent it from being picked up in another transport collection
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." marked for assignment")
                            end
                            
                            transport.Assigning = true
			
							id = transport.BlueprintID

                            -- add the transports slots to the collected table
							if not aiBrain.TransportSlotTable[id] then
								GetNumTransportSlots( transport )
							end

							counter = counter + 1
							transports[counter] = { Unit = transport, Distance = range, Slots = LOUDCOPY(aiBrain.TransportSlotTable[id]) }

							Collected.Large = Collected.Large + transports[counter].Slots.Large
							Collected.Medium = Collected.Medium + transports[counter].Slots.Medium
							Collected.Small = Collected.Small + transports[counter].Slots.Small

							-- if we have enough collected capacity for each type then CanUseTransports is true which will break us out of collection
							if Collected.Large >= neededTable.Large and Collected.Medium >= neededTable.Medium and Collected.Small >= neededTable.Small then
								CanUseTransports = true
							end

						else
                        
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." rejected - out of range at "..range)
                            end
                            
							out_of_range = true
						end
					end
				end
                
			else
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport "..transport.EntityID.." rejected -  In Use "..repr(transport.InUse).." - Assigning "..repr(transport.Assigning).." - BeingBuilt "..repr(IsBeingBuilt(transport)).." or Low Fuel/Health")
                end
                
                if not transport.Dead then
                    ForkThread( ReturnTransportsToPool, aiBrain, {transport}, true )
                end
                AvailableTransports[k] = nil
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
        
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." unable to locate enough transport")
        end
		
        AvailableTransports = aiBrain:RebuildTable(AvailableTransports)
        
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
        
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." assigning units to transports")
        end
		
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
                    transportplatoon.UsingTransport = true      -- keep this platoon from being reviewed in a merge
                    
                    if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." created for service ")
                    end
				end
				
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." adds transport "..transport.EntityID)
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
            
            -- mark each transport (used or not) as no longer in Assignment
            transport.Assigning = false
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
				location = LOUDCOPY(GetPlatoonPosition(platoon))
			end
		end

		if not transportplatoon or counter < 1 then
		
            if TransportDialog then
            
                if not transportplatoon then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." transport platoon dead after assignmnet "..repr(transportplatoon))
                else
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." unit platoon dead after assignment ")
                end
            end
			
			CanUseTransports = false
		end
	end
	
	transports = nil
	
	-- if we need more transport then fail (I no longer permit partial transportation)
	-- or if some other situation (dead units) -- send the transports back to the pool
    if not CanUseTransports or counter < 1 then

		if transportplatoon then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." cannot be serviced by "..transportplatoon.BuilderName )
            end
            
            for _,transport in GetPlatoonUnits(transportplatoon) do

                -- unmark the transport
                transport.InUse = false
                
                if not transport.Dead then
                    -- and return it to the transport pool
                    ForkTo( ReturnTransportsToPool, aiBrain, {transport}, true )
                end
            end
		end

		platoon.UsingTransport = false
		
        return false, false
    else
		
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." "..transportplatoon.BuilderName.." authorized for use" )
        end

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
function WatchUnitLoading( transport, units, aiBrain, UnitPlatoon)

    local TransportDialog = ScenarioInfo.TransportDialog or false
	
	local unitsdead = true
	local loading = false
	
	local reloads = 0
	local reissue = 0
	local newunits = LOUDCOPY(units)
	
	local GetPosition = GetPosition
	local watchcount = 0
    
    transport.Loading = true

	IssueClearCommands( {transport} )
	
    -- At this point we really should safepath to the position
	IssueMove( {transport}, GetPosition(units[1]) )
    
    --if TransportDialog then
      --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." transport "..transport.EntityID.." moving to "..repr(units[1]:GetPosition()).." for pickup - distance "..VDist3( transport:GetPosition(), units[1]:GetPosition()))
    --end
	
	WaitTicks(5)
	
	for _,u in newunits do
	
		if not u.Dead then
		
			unitsdead = false
			loading = true
		
			-- here is where we issue the Load command to the transport --
			safecall("Unable to IssueTransportLoad units are "..repr(units), IssueTransportLoad, newunits, transport )
			
			break
		end
	end

	local tempunits = {}
	local counter = 0
	
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." begins loading")
    end
    
	-- loop here while the transport is alive and loading is underway
	-- there is another trigger (watchcount) which will force loading
	-- to false after 210 seconds
	while (not unitsdead) and loading do
	
		watchcount = watchcount + 1.3

		if watchcount > 210 then
        
            WARN("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." ABORTING LOAD - watchcount "..watchcount)
            
			loading = false
            
            transport.InUse = false
            transport.Loading = nil
            
            ForkTo ( ReturnTransportsToPool, aiBrain, {transport}, true )
			break
		end
		
		WaitTicks(14)
		
		tempunits = {}
		counter = 0

        -- check for death of transport - and verify that units are still awaiting load
		if (not transport.Dead) and transport.Loading and ( not IsUnitState(transport,'Moving') or IsUnitState(transport,'TransportLoading') ) then
		
			unitsdead = true
			loading = false
	
			-- loop thru the units and pick out those that are not yet 'attached'
			-- also detect if all units to be loaded are dead
			for _,u in newunits do
		
				if not u.Dead then
				
					-- we have some live units
					unitsdead = false
			
					if not IsUnitState( u, 'Attached') then
					
						loading = true
						counter = counter + 1
						tempunits[counter] = u
					end
				end
			end
		
			-- if all dead or all loaded or unit platoon no longer exists, RTB the transport
			if unitsdead or (not loading) or reloads > 20 then
			
				if unitsdead then
				
					transport.InUse = false
                    transport.Loading = nil

					ForkTo ( ReturnTransportsToPool, aiBrain, {transport}, true )
                    return
				end
				
				loading = false
			end
		end

		-- issue reloads to unloaded units if transport is not moving and not loading units
		if (not transport.Dead) and (loading and not (IsUnitState( transport, 'Moving') or IsUnitState( transport, 'TransportLoading'))) then

			reloads = reloads + 1
			reissue = reissue + 1
			newunits = false
			counter = 0
			
			for k,u in tempunits do
			
				if (not u.Dead) and not IsUnitState( u, 'Attached') then

					-- if the unit is not attached and the transport has space for it or it's a UEF Gunship (TransportHasSpaceFor command is unreliable)
					if (not transport.Dead) and transport:TransportHasSpaceFor(u) then
					
						IssueClearCommands({u})
					
						if reissue > 1 then
                        
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport"..transport.EntityID.." Warping unit "..u.EntityID.." to transport ")
						
							Warp( u, GetPosition(transport) )
							reissue = 0
						end
						
						if not newunits then
							newunits = {}
						end
                        
						counter = counter + 1						
						newunits[counter] = u

					
					-- if the unit is not attached and the transport does NOT have space for it - turn off loading flag and clear the tempunits list
					elseif (not transport.Dead) and (not transport:TransportHasSpaceFor(u)) and (not EntityCategoryContains(categories.uea0203,transport)) then

						loading = false
						newunits = false
						break
			
					elseif (not transport.Dead) and EntityCategoryContains(categories.uea0203,transport) then

						loading = false
						newunits = false
						break
						
					end	
				end
			end
			
			if newunits and counter > 0 then
			
				if reloads > 1 then
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." Reloading "..counter.." units - reload "..reloads)
				end
			
				IssueStop( newunits )
				
				IssueClearCommands( {transport} )
				
				local goload = safecall("Unable to IssueTransportLoad", IssueTransportLoad, newunits, transport )
				
				if goload then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." reloads is "..reloads.." goload is "..repr(goload).." for "..transport:GetBlueprint().Description)
					
					--ForkTo( AISendPing, GetPosition(transport),'warning', aiBrain.ArmyIndex )
				end
				
			else
			
				loading = false
			end
		end
        
	end

    if TransportDialog then
    
        if transport.Dead then
            -- at this point we should find a way to reprocess the units this transport was responsible for
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." Transport "..transport.EntityID.." dead during WatchLoading")
        else
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." completes load in "..watchcount)
        end
        
    end

    if transport.InUse then
    
        IssueClearCommands( {transport} )
    
        if (not transport.Dead) then

            if not unitsdead then
            
                -- have the transport guard his loading spot until everyone else has loaded up
                IssueGuard( {transport}, GetPosition(transport) )
                
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." begins to loiter after load")
                end
                
            else
			
				transport.InUse = false
                transport.Loading = nil
                
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." aborts load - unitsdead is "..repr(unitsdead).." watchcount is "..watchcount)
                end

                ForkTo ( ReturnTransportsToPool, aiBrain, {transport}, true )
                return
            end
        end
        
    end
    
	transport.Loading = nil
end

function WatchTransportTravel( transport, destination, aiBrain, UnitPlatoon )

    local TransportDialog = ScenarioInfo.TransportDialog or false	
    
	local unitsdead = false
	local watchcount = 0
	
	local GetPosition = GetPosition
    
    local VDist2 = VDist2
    
    local WaitTicks = WaitTicks
	
	transport.StuckCount = 0
	transport.LastPosition = LOUDCOPY(GetPosition(transport))
    transport.Travelling = true
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." starts travelwatch")
    end
	
	while (not transport.Dead) and (not unitsdead) and transport.Travelling do
	
		--if not transport.Dead then
			
			-- major distress call -- 
			if transport.PlatoonHandle.DistressCall then
			
				-- reassign destination and begin immediate drop --
				-- this really needs to be sensitive to the platoons layer
				-- and find an appropriate marker to drop at -- 
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." DISTRESS ends travelwatch after "..watchcount)
                end
                
				destination = GetPosition(transport)
                break
			end
			
			-- someone in transport platoon is close - begin the drop -
			if transport.PlatoonHandle.AtGoal then
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." ARRIVE ends travelwatch after "..watchcount)
                end
            
				break
			end
        
			unitsdead = true

			for _,u in transport:GetCargo() do
			
				if not u.Dead then
				
					unitsdead = false
					break
				end
			end

			-- if all dead except UEF Gunship RTB the transport
			if unitsdead and not EntityCategoryContains(categories.uea0203,transport) then
			
				transport.StuckCount = nil
				transport.LastPosition = nil
				transport.Travelling = false

                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." UNITS DEAD ends travelwatch after "..watchcount)
                end

				ForkTo( ReturnTransportsToPool, aiBrain, {transport}, true )
                return
			end
		
			-- is the transport still close to its last position bump the stuckcount
			if transport.LastPosition then
			
				if VDist2(transport.LastPosition[1], transport.LastPosition[3], GetPosition(transport)[1],GetPosition(transport)[3]) < 6 then
				
					transport.StuckCount = transport.StuckCount + 0.5
				else
					transport.StuckCount = 0
				end
			end

			if ( IsIdleState(transport) or transport.StuckCount > 8 ) then
		
				if transport.StuckCount > 8 then
				
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." StuckCount in WatchTransportTravel to "..repr(destination) )				
					transport.StuckCount = 0
				end

				IssueClearCommands( {transport} )
				IssueMove( {transport}, destination )
			end
		
			-- this needs some examination -- it should signal the entire transport platoon - not just itself --
			if VDist2(GetPosition(transport)[1], GetPosition(transport)[3], destination[1],destination[3]) < 100 then
 			
				transport.PlatoonHandle.AtGoal = true

			else

                transport.LastPosition = LOUDCOPY(transport:GetPosition())
            end
    
            if not transport.PlatoonHandle.AtGoal then
                WaitTicks(11)
                watchcount = watchcount + 1
            end
            
		--end

	end

	if not transport.Dead then
	
		IssueClearCommands( {transport} )

		if not transport.Dead then
		
			transport.StuckCount = nil
			transport.LastPosition = nil
			transport.Travelling = nil

			transport.WatchUnloadThread = transport:ForkThread( WatchUnitUnload, transport:GetCargo(), destination, aiBrain, UnitPlatoon )
		end
	end
	
end

function WatchUnitUnload( transport, unitlist, destination, aiBrain, UnitPlatoon )

    local TransportDialog = ScenarioInfo.TransportDialog or false
  
    local WaitTicks = WaitTicks
	
	local unitsdead = false
	local unloading = true

    transport.Unloading = true
    
    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." unloadwatch begins")
    end
	
	IssueTransportUnload( {transport}, destination)
    
    WaitTicks(4)
	
	local watchcount = 0.3

	while (not unitsdead) and unloading and (not transport.Dead) do
	
		unitsdead = true
		unloading = false
	
        if not transport.Dead then
		
			-- do we have loaded units
			for _,u in unitlist do
		
				if not u.Dead then
				
					unitsdead = false
				
					if IsUnitState( u, 'Attached') then
					
						unloading = true
						break
					end
				end
			end

            -- in this case unitsdead can mean that OR that we've unloaded - either way we're done
			if unitsdead or not unloading then

                if TransportDialog then
                    
                    if not transport.Dead then
                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." unloadwatch complete after "..watchcount.." seconds")
				
                        transport.InUse = false
                        transport.Unloading = nil
                        
                        if not transport.ReturnToPoolCallbackSet then
                            ForkTo( ReturnTransportsToPool, aiBrain, {transport}, true )
                        end
                        
                    else
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." dead during unload")
                    end
                end

			end

            -- watch the count and try to force the unload
			if unloading and (not transport:IsUnitState('TransportUnloading')) then

				if watchcount >= 12 then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." FAILS TO UNLOAD after "..watchcount.." seconds")
                    
					break			
					
				elseif watchcount >= 8 then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." transport "..transport.EntityID.." watched unload for "..watchcount.." seconds")
                    
					IssueTransportUnload( {transport}, GetPosition(transport))
					
				elseif watchcount > 4 then
				
					IssueTransportUnload( {transport}, GetPosition(transport))
				end
			end
		end
        
		WaitTicks(6)
		watchcount = watchcount + 0.5

	end
   
    transport.Unloading = nil
	transport.InUse = false
end

-- This function actually loads and moves units on transports using a safe path to the location desired
-- Just a personal note - this whole transport thing is a BITCH
-- This was one of the first tasks I tackled and years later I still find myself coming back to it again and again - argh
function UseTransports( aiBrain, transports, location, UnitPlatoon, IsEngineer )

    local TransportDialog = ScenarioInfo.TransportDialog or false

	local LOUDCOPY = LOUDCOPY
	local LOUDENTITY = LOUDENTITY
	local LOUDGETN = LOUDGETN
	local LOUDINSERT = LOUDINSERT

	local WaitTicks = WaitTicks
	
	local PlatoonExists = PlatoonExists
	local GetBlueprint = moho.entity_methods.GetBlueprint
    local GetPlatoonPosition = GetPlatoonPosition
    local GetPlatoonUnits = GetPlatoonUnits

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
			
				local slots = LOUDCOPY( aiBrain.TransportSlotTable[v.BlueprintID] )
		
				counter = counter + 1
				transportTable[counter] = {	Transport = v, LargeSlots = slots.Large, MediumSlots = slots.Medium, SmallSlots = slots.Small, Units = { ["Small"] = {}, ["Medium"] = {}, ["Large"] = {} } }

			end
		end
	end
	
	if counter < 1 then
    
        UnitPlatoon.UsingTransport = false
        
		return false
    end

	-- This routine allocates the units to specific transports
	-- Units are injected on a TransportClass basis ( 3 - 2 - 1 )
	-- As each unit is assigned - the transport has its remaining slot count
	-- reduced & the unit is added to the list assigned to that transport
	local function SortUnitsOnTransports( transportTable, unitTable )

		local leftoverUnits = {}
        local count = 0
	
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
					count = count + 1
					leftoverUnits[count] = unit
				end
			else
                count = count + 1
				leftoverUnits[count] = unit
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
        counter = 0
	
		-- assign the large units - note how we come back with leftoverunits here
		transportTable, leftoverUnits = SortUnitsOnTransports( transportTable, remainingSize3 )
		
		-- assign the medium units - but this time we come back with currleftovers
		transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize2 )
	
		-- and we move any currleftovers into the leftoverunits table
		for k,v in currLeftovers do
		
			if not v.Dead then
                counter = counter + 1
				leftoverUnits[counter] = v
			end
		end
		
		currLeftovers = {}
	
		-- assign the small units - again coming back with currleftovers
		transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize1 )
	
		-- again adding currleftovers to the leftoverunits table
		for k,v in currLeftovers do
		
			if not v.Dead then
                counter = counter + 1
				leftoverUnits[counter] = v
			end
		end
		
		currLeftovers = {}
	
		if leftoverUnits[1] then
			transportTable, currLeftovers = SortUnitsOnTransports( transportTable, leftoverUnits )
		end
	
	
		-- send any leftovers to RTB --
		if currLeftovers[1] then
		
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
    local loadissued, unitstoload, transport
	
	-- loop thru the transports and order the units to load onto them	
    for k, data in transportTable do
	
		loadissued = false
		unitstoload = false
		
		counter = 0
		
		-- look for dead/missing units in this transports unit list
		-- and those that may somehow be attached already
        for size,unitlist in data.Units do
		
			for u,v in unitlist do
			
				if v and not v.Dead then

					if not unitstoload then
						unitstoload = {}
					end

					counter = counter + 1					
					unitstoload[counter] = v

				else
					data.Units[size][u] = nil
				end
			end
		end

		-- if units are assigned to this transport
        if data.Units["Large"][1] then
		
            IssueClearCommands( data.Units["Large"] )
			
			loadissued = true
		end
		
		if data.Units["Medium"][1] then
		
            IssueClearCommands( data.Units["Medium"] )
		
			loadissued = true
		end
		
		if data.Units["Small"][1] then
		
            IssueClearCommands( data.Units["Small"] )
			
			loadissued = true
		end
		
		if not loadissued or not unitstoload then
        
            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..repr(transports.BuilderName).." transport "..data.Transport.EntityID.." no load issued or units to load")
            end
		
			-- RTP any transport with nothing to load
			ForkTo( ReturnTransportsToPool, aiBrain, {data.Transport}, true )
		else
			transport = data.Transport
			
			transport.InUse = true
            transport.Assigning = false

			transport.WatchLoadingThread = transport:ForkThread( WatchUnitLoading, unitstoload, aiBrain, UnitPlatoon )
			
			loading = true
		end
    end
	
	-- if loading has been issued watch it here
	if loading then

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." loadwatch begins" )
        end    

		if UnitPlatoon.WaypointCallback then

			KillThread( UnitPlatoon.WaypointCallback )
			
			UnitPlatoon.WaypointCallback = nil
            
            if UnitPlatoon.MovingToWaypoint then
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(UnitPlatoon.BuilderName).." "..repr(UnitPlatoon.BuilderInstance).." MOVINGTOWAYPOINT cleared by transport ")
                UnitPlatoon.MovingToWaypoint = nil
            end

		end
	
		local loadwatch = true	
		
		while loadwatch do
		
			WaitTicks(8)
			
			loadwatch = false
			
			if PlatoonExists( aiBrain, transports) then
		
				for _,t in GetPlatoonUnits(transports) do
			
					if not t.Dead and t.Loading then
				
						loadwatch = true
					else
                        if t.WatchLoadingThread then
                            KillThread (t.WatchLoadingThread)
                            t.WatchLoadingThread = nil
                        end
                    end
				end
			end
		end
	end

    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." loadwatch complete")
	end
    
	if not PlatoonExists(aiBrain, transports) then
    
        UnitPlatoon.UsingTransport = false
        
		return false
	end

	-- Any units that failed to load send back to pool thru RTB
    -- this one really only occurs when an inbound transport is killed
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

        --if TransportDialog then
          --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." plot transport movement ")
        --end
	
		local platpos = GetPlatoonPosition(transports) or false
		
		if platpos then

			local airthreatMax = counter * 4.2
			
			airthreatMax = airthreatMax + ( airthreatMax * math.log10(counter))

            local safePath, reason, pathlength, pathcost = transports.PlatoonGenerateSafePathToLOUD(aiBrain, transports, 'Air', platpos, location, airthreatMax, 256)

            if TransportDialog then
            
                if not safePath then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." no safe path to "..repr(location).." using threat of "..airthreatMax)
                else
                    
                    if GetFocusArmy() == aiBrain.ArmyIndex then
                        ForkTo ( import('/lua/loudutilities.lua').DrawPath, platpos, safePath, location )
                    end
                    
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." has path to "..repr(location).." - length "..repr(pathlength).." - reason "..reason.." - cost "..pathcost)

                end
            end
		
			if PlatoonExists( aiBrain, transports) then
		
				IssueClearCommands( GetPlatoonUnits(transports) )
				
				IssueMove( GetPlatoonUnits(transports), GetPlatoonPosition(transports))

				if safePath then 

					local prevposition = GetPlatoonPosition(transports) or false
                    local Direction
		
					for _,p in safePath do
				
						if prevposition then

							Direction = import('/lua/utilities.lua').GetDirectionInDegrees( prevposition, p )
					
							IssueFormMove( GetPlatoonUnits(transports), p, 'AttackFormation', Direction)
						
							prevposition = p
						end
					end
                    
				else
                
					if TransportDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." goes direct to "..repr(location))
                    end
			
					-- go direct ?? -- what ?
					IssueFormMove( GetPlatoonUnits(transports), location, 'AttackFormation', import('/lua/utilities.lua').GetDirectionInDegrees( GetPlatoonPosition(transports), location )) 

				end

				if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." starts travelwatch to "..repr(location))
                end
			
				for _,v in GetPlatoonUnits(transports) do
		
					if not v.Dead then
						v.WatchTravelThread = v:ForkThread(WatchTransportTravel, location, aiBrain, UnitPlatoon)		
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
        -- threat trigger is based on number of transports
		transports:ForkThread( transports.PlatoonCallForHelpAI, aiBrain, LOUDGETN(transporters) )
		
		transports.AtGoal = false -- flag to allow unpathed unload of the platoon
      
		local travelwatch = true
		
		-- loop here until all transports signal travel complete
		-- each transport should be running the WatchTravel thread
		-- until it dies, the units it is carrying die or it gets to target
		while travelwatch and PlatoonExists( aiBrain, transports ) do

			travelwatch = false

			WaitTicks(4)
            
			for _,t in GetPlatoonUnits(transports) do
			
				if t.Travelling and not t.Dead then
				
					travelwatch = true
                --else
                  --  if t.WatchTravelThread then
                    --    KillThread(t.WatchTravelThread)
                      --  t.WatchTravelThread = nil
                    --end
				end
			end

		end

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." travelwatch complete")
        end
    end

	transporters = GetPlatoonUnits(transports) or false
	
	-- watch the transports until they signal unloaded or dead
	if transporters and LOUDGETN(transporters) != 0 then
    
        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." unloadwatch begins")
        end    
		
		local unloadwatch = true
        local unloadcount = 0 
		
		while unloadwatch do
		
			WaitTicks(5)
            unloadcount = unloadcount + .4
			
			unloadwatch = false
		
			for _,t in GetPlatoonUnits(transports) do
			
				if t.Unloading and not t.Dead then
				
					unloadwatch = true
                else
                    if t.WatchUnloadThread then
                        KillThread(t.WatchUnloadThread)
                        t.WatchUnloadThread = nil
                    end
				end
			end
		end

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transports.BuilderName.." unloadwatch complete after "..unloadcount.." seconds")
        end
        
        for _,t in GetPlatoonUnits(transports) do
        
            if not t.ReturnToPoolCallbackSet then

                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." "..transport.PlatoonHandle.BuilderName.." Transport "..transport.EntityID.." has no RTP Callback set")

                ForkTo( ReturnTransportsToPool, aiBrain, {t}, true )
            end
        end
    end
	
	if not PlatoonExists(aiBrain,UnitPlatoon) then
        return false
    end
	
	UnitPlatoon.UsingTransport = false

    if TransportDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..UnitPlatoon.BuilderName.." Transport complete ")
    end
	
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
                WaitTicks(20)
			end

		end

		returnpool:SetAIPlan('ReturnToBaseAI', aiBrain )
	end
	
	return
end

-- This utility should get called anytime a transport finishes unloading units
-- it will force the transport into the Transport pool & pass control over to the RTP utility
function AssignTransportToPool( unit, aiBrain )

    -- this sets up the OnTransportDetach callback so that
    -- this function runs EVERY time a transport drops units
	if not unit.ReturnToPoolCallbackSet then

		unit:AddUnitCallback( function(unit)
	
			if LOUDGETN(unit:GetCargo()) == 0 then

				if unit.WatchUnloadThread then
					KillThread(unit.WatchUnloadThread)
					unit.WatchUnloadThread = nil
				end

				ForkTo( AssignTransportToPool, unit, aiBrain )

			end
            
		end, 'OnTransportDetach')

		unit.ReturnToPoolCallbackSet = true
	end

    -- if the unit is not already in the transport Pool --
	if not unit.Dead and (not unit.PlatoonHandle != aiBrain.TransportPool) then

		IssueClearCommands( {unit} )

		local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits

		-- if not in need of repair or fuel -- 
		if not ProcessAirUnits( unit, aiBrain ) then
            
            if aiBrain.TransportPool then
                AssignUnitsToPlatoon( aiBrain, aiBrain.TransportPool, {unit}, 'Support','')
            else
                return
            end
            
            unit.InUse = false
            unit.Assigning = false        

			unit.PlatoonHandle = aiBrain.TransportPool
            
            if not IsBeingBuilt(unit) then
                ForkTo( ReturnTransportsToPool, aiBrain, {unit}, true )
                return
            end
		end
        
	else
    
        if not unit.Dead and (not IsBeingBuilt(unit)) then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Transport "..unit.EntityID.." already in Transport Pool")
        end
    end
    
    unit.InUse = false
    unit.Assigning = false    
end
	
--  This routine should get transports on the way back to an existing base 
--  BEFORE adding them back to the Transport Pool
function ReturnTransportsToPool( aiBrain, units, move )

    local TransportDialog = ScenarioInfo.TransportDialog or false

    local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits
    
    local unitcount = 0

	-- make sure all units are unloaded
    for k,v in units do

        if IsBeingBuilt(v) then
            units[v] = nil
            continue
        end

        if TransportDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..v.EntityID.." Returning to Pool  InUse is "..repr(v.InUse) )
        end
    
        if v.WatchLoadingThread then
            KillThread( v.WatchLoadingThread)
            v.WatchLoadingThread = nil
        end
        
        if v.WatchTravelThread then
            KillThread( v.WatchTravelThread)
            v.WatchTravelThread = nil
        end
        
        if v.WatchUnloadThread then
            KillThread( v.WatchUnloadThread)
            v.WatchUnloadThread = nil
        end
        
        if v.Dead then
        
            if TransportDialog then
                --LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..v.EntityID.." dead during Return to Pool")
            end
            
            units[v] = nil
            continue
        end
        
        unitcount = unitcount + 1

		-- unload any units it might have
		if EntityCategoryContains( categories.TRANSPORTFOCUS + categories.uea0203, v ) then

            if LOUDGETN(v:GetCargo()) > 0 then

                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..v.EntityID.." has unloaded units")
                end
				
                local unloadedlist = v:GetCargo()
				
                IssueTransportUnload(v, v:GetPosition())
				
                WaitTicks(3)
				
                for _,unloadedunit in unloadedlist do
                    ForkTo(ReturnUnloadedUnitToPool,aiBrain,unloadedunit)
                end
            end

            v.InUse = nil

            v.Assigning = nil

            -- if the transport needs refuel or repair
            -- remove it from further processing
            if ProcessAirUnits( v, aiBrain) then
                units[k] = nil
            end
        end
        
    end

	if unitcount > 0 and move then

		units = aiBrain:RebuildTable(units)

        local unitposition, baseposition, safepath, reason
        
        local VDist3 = VDist3
	
		for k,v in units do
		
			if v and not v.Dead and (not v.InUse) and (not v.Assigning) then

                local returnpool = aiBrain:MakePlatoon('TransportRTB'..tostring(v.EntityID), 'none')
                
                returnpool.BuilderName = 'TransportRTB'..tostring(v.EntityID)
                returnpool.PlanName = returnpool.BuilderName

                AssignUnitsToPlatoon( aiBrain, returnpool, {v}, 'Unassigned', '')
                
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." Transport "..v.EntityID.." assigned" )
                end

                v.PlatoonHandle = returnpool
                
                unitposition = v:GetPosition()

                baseposition = import('/lua/loudutilities.lua').AIFindClosestBuilderManagerPosition( aiBrain, unitposition)

                if baseposition then
                    x = baseposition[1]
                    z = baseposition[3]
                else
                    return
                end

                baseposition = AIUtils.RandomLocation(x,z)

                IssueClearCommands( {v} )

                if VDist3( baseposition, unitposition ) > 100 then

                    local safePath, reason = returnpool.PlatoonGenerateSafePathToLOUD(aiBrain, returnpool, 'Air', unitposition, baseposition, 20, 256)

                    if safePath then

                        if TransportDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." Transport "..v.EntityID.." gets RTB path of "..repr(safePath))
                        end

                        -- use path
                        for _,p in safePath do
                            IssueMove( {v}, p )
                        end
                    else
                        if TransportDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." Transport "..v.EntityID.." no safe path for RTB -- home -- after drop - going direct")
                        end

                        -- go direct -- possibly bad
                        IssueMove( {v}, baseposition )
                    end
                else
                    IssueMove( {v}, baseposition)
                end

				-- move the unit to the correct pool - pure transports to Transport Pool
				-- all others -- including temporary transports (UEF T2 gunship) to Army Pool
				if not v.Dead then
				
					if LOUDENTITY( categories.TRANSPORTFOCUS - categories.uea0203, v ) then
                    
                        if v.PlatoonHandle != aiBrain.TransportPool then
                            
                            if TransportDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..v.PlatoonHandle.BuilderName.." transport "..v.EntityID.." now in the Transport Pool  InUse is "..repr(v.InUse))
                            end

                            AssignUnitsToPlatoon( aiBrain, aiBrain.TransportPool, {v}, 'Support', '' )

                            v.PlatoonHandle = aiBrain.TransportPool
                            v.InUse = false
                            v.Assigning = false                            
                        end
					else
                    
                        if TransportDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..v.PlatoonHandle.BuilderName.." assigned unit "..v.EntityID.." "..v:GetBlueprint().Description.." to the Army Pool" )
                        end

						AssignUnitsToPlatoon( aiBrain, aiBrain.ArmyPool, {v}, 'Unassigned', '' )

						v.PlatoonHandle = aiBrain.ArmyPool
       					v.InUse = false
                        v.Assigning = false
					end
				end
			end
		end
	end
	
	if not aiBrain.CheckTransportPoolThread then
		aiBrain.CheckTransportPoolThread = ForkThread( CheckTransportPool, aiBrain )
	end
end

-- This utility will traverse all true transports to insure they are in the TransportPool
-- and a perfunctory cleanup on the path requests reply table for dead platoons
function CheckTransportPool( aiBrain )

    local ArmyPool = aiBrain.ArmyPool
    local RefuelPool = aiBrain.RefuelPool
    local StructurePool = aiBrain.StructurePool
	local TransportPool = aiBrain.TransportPool
    
    local TransportDialog = ScenarioInfo.TransportDialog
    
	local IsIdleState = IsIdleState
    
    local PlatoonExists = PlatoonExists

	-- get all idle, fully built transports except UEF gunship --
	local unitlist = GetListOfUnits( aiBrain,(categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203), true, true)
    
    local platoon, oldplatoonname
	
	for k,v in unitlist do
        
		if v and v.PlatoonHandle != TransportPool and v.PlatoonHandle != RefuelPool and GetFractionComplete(v) == 1 then
		
			platoon = v.PlatoonHandle or false
			oldplatoonname = false
			
			if platoon then
				oldplatoonname = platoon.BuilderName or false
			end
			
			if (not IsIdleState(v)) or v.InUse or v.Assigning or (platoon and PlatoonExists(aiBrain,platoon)) then
			
				if not IsIdleState(v) then
					continue
				end
				
				if platoon.CreationTime and (aiBrain.CycleTime - platoon.CreationTime) < 360 then
					continue
				end
			end
			
			IssueClearCommands( {v} )
			
			if v.WatchLoadingThread then
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Killing Watch Loading thread - transport "..v.EntityID.." in CheckTransportPool")
                end
                
				KillThread(v.WatchLoadingThread)
				v.WatchLoadingThread = nil
			end
			
			if v.WatchTravelThread then
            
                if TransportDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Killing Watch Travel thread - transport "..v.EntityID.." in CheckTransportPool")
                end            

				KillThread(v.WatchTravelThread)
				v.WatchTravelThread = nil
			end
			
			if platoon and PlatoonExists(aiBrain,platoon) then
			
				if platoon != ArmyPool and platoon != RefuelPool and platoon != StructurePool then
				
					aiBrain:DisbandPlatoon(platoon)
				end
			end

            if TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Assigning Transport "..v.EntityID.." to Pool in CheckTransportPool")
            end
            
			ForkTo( AssignTransportToPool, v, aiBrain )

        end
	end
	
	aiBrain.CheckTransportPoolThread = nil
    
    local gametime = math.floor(GetGameTimeSeconds())

    -- this loop just clears the reply queue of pathfinding replies
    -- I know - this isn't the most suitable place for this function
    for k,v in aiBrain.PathRequests['Replies'] do

        if ((not type(k)=='string') and not PlatoonExists( aiBrain, k )) or (k.CreationTime and (gametime > k.CreationTime + 180)) then
        
            aiBrain.PathRequests['Replies'][k] = nil
        end
    end
    
end

function GetGuards( aiBrain, Unit)

	local engs = GetUnitsAroundPoint( aiBrain, categories.ENGINEER, GetPosition(Unit), 20, 'Ally' )
	local count = 0
	local UpgradesFrom = __blueprints[Unit.BlueprintID].General.UpgradesFrom

	for k,v in engs do
	
		if v.UnitBeingBuilt == Unit and v != Unit then
			count = count + 1
		end
		
	end
	
	if UpgradesFrom and UpgradesFrom != 'none' then -- Used to filter out upgrading units
	
		local oldCat = LOUDPARSE(UpgradesFrom)
		local oldUnit = GetUnitsAroundPoint( aiBrain, oldCat, GetPosition(Unit), 0, 'Ally' )
		
		if oldUnit then
			count = count + 1
		end
		
	end
	
	return count
end

--	This function will return threat and distance data from entries in the HighPriorityList
--	Returns:
--		A list of data with the following elements
--			Position	- a 3D position vector
--			Threats		- four of them: AirThreat, EcoThreat, SubThreat & SurThreat
--			Distance	- # of ogrids to the position based upon location
--			Type		- the class of threat (StructuresNotMex, Experimental, Commander, Air, Land, etc.)
--			LastScouted - gametime when position was last scouted

-- We are basically re-checking the work that was done to put this data into the HiPri list to get
-- refreshed position and strength values - May 2019
function GetHiPriTargetList(aiBrain, location)

    if not location then
        return {}
    end

	local LOUDCOPY = LOUDCOPY
	local LOUDEQUAL = LOUDEQUAL
	local WaitTicks = WaitTicks

    local threatlist = LOUDCOPY(aiBrain.IL.HiPri)
	
	local GetEnemyUnitsInRect = import('/lua/loudutilities.lua').GetEnemyUnitsInRect
	
	-- this defines the 'box' that we'll use around the threat position to find enemy units
	-- it varies with the map size and is set in the PARSEINTEL thread
	local IMAPRadius = ScenarioInfo.IMAPRadius
	
	local ALLBPS = __blueprints
    local checks = 0
	local counter = 0
	local prev_position = {}
	local targetlist = {}	

	local allthreat, airthreat, bp, ecothreat, newPos, subthreat, surthreat, targets, unitcount, unitPos, x1, x2, x3
    local TPosition

	LOUDSORT( threatlist, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3],location[1],location[3]) < VDist2Sq(b.Position[1],b.Position[3],location[1],location[3]) end )

    for _,threat in threatlist do
        
        TPosition = threat.Position
	
		if LOUDEQUAL( TPosition, prev_position ) then
			continue
		end
		
		targets = GetEnemyUnitsInRect( aiBrain, TPosition[1]-IMAPRadius, TPosition[3]-IMAPRadius, TPosition[1]+IMAPRadius, TPosition[3]+IMAPRadius)
		
		airthreat = 0.0
		ecothreat = 0.0
		subthreat = 0.0
		surthreat = 0.0
		
		unitPos = false
		x1 = 0
		x2 = 0
		x3 = 0
		unitcount = 0
		newPos = false
		
		if targets then

			checks = checks + 1		

			for _, target in targets do
			
				if not target.Dead then
				
					unitPos = target:GetCachePosition()
					
					if unitPos then
                    
                        unitcount = unitcount + 1
                        
						x1 = x1 + unitPos[1]
						x2 = x2 + unitPos[2]
						x3 = x3 + unitPos[3]
					
                        bp = ALLBPS[target.BlueprintID].Defense
					
                        airthreat = airthreat + bp.AirThreatLevel
                        ecothreat = ecothreat + bp.EconomyThreatLevel
                        subthreat = subthreat + bp.SubThreatLevel
                        surthreat = surthreat + bp.SurfaceThreatLevel
                    end
				end
			end
			
			newPos = { x1/unitcount, x2/unitcount, x3/unitcount }
			allthreat = ecothreat + subthreat + surthreat + airthreat
		end
		
		if newPos and allthreat > 0 then
			
			counter = counter + 1		
			targetlist[counter] = { Position = newPos, Type = threat.Type, LastScouted = threat.LastScouted,  Distance = VDist2(location[1],location[3], TPosition[1],TPosition[3]), Threats = { Air = airthreat, Eco = ecothreat, Sub = subthreat, Sur = surthreat, All = allthreat} }

			prev_position = LOUDCOPY(TPosition)
		end

		if checks > 2 then
			WaitTicks(1)
			checks = 0
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
