--  File     :  /lua/altaiutilities.lua

local import = import

local AIUtils = import('/lua/ai/aiutilities.lua')

local LOUDCONCAT    = table.cat
local LOUDCOPY      = table.copy
local LOUDENTITY    = EntityCategoryContains
local LOUDEQUAL     = table.equal
local LOUDFLOOR     = math.floor
local LOUDGETN      = table.getn
local LOUDINSERT    = table.insert
local LOUDMERGED    = table.merged
local LOUDPARSE     = ParseEntityCategory
local LOUDREMOVE    = table.remove
local LOUDSORT      = table.sort

local ForkTo    = ForkThread

local VDist2    = VDist2
local VDist2Sq  = VDist2Sq
local VDist3    = VDist3

local WaitTicks = coroutine.yield

local AssignUnitsToPlatoon      = moho.aibrain_methods.AssignUnitsToPlatoon
local IsBeingBuilt              = moho.unit_methods.IsBeingBuilt
local IsIdleState               = moho.unit_methods.IsIdleState
local IsUnitState               = moho.unit_methods.IsUnitState
local GetFractionComplete       = moho.entity_methods.GetFractionComplete
local GetListOfUnits            = moho.aibrain_methods.GetListOfUnits
local GetNumUnitsAroundPoint    = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetPosition               = moho.entity_methods.GetPosition
local GetPlatoonPosition        = moho.platoon_methods.GetPlatoonPosition
local GetPlatoonUnits           = moho.platoon_methods.GetPlatoonUnits
local GetUnitsAroundPoint       = moho.aibrain_methods.GetUnitsAroundPoint
local PlatoonExists             = moho.aibrain_methods.PlatoonExists


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
-- position is NOT driven by the Attack Plan but by the source base of the engineer doing this job
-- added the check for 'allied' structures based on the baseradius in the engineer task
function AIFindBaseAreaForExpansion( aiBrain, locationType, radius, expradius, tMin, tMax, tRings, tType, eng)

    local BuilderManager    = aiBrain.BuilderManagers[locationType]
    local Position          = BuilderManager.Position or false
	
    -- this option (unused at the moment) allows us to base the checks on the engineers position
    -- you might use that on an engineer out in the field for example
	if eng then
		Position = eng
	end
  
	if Position then
    
        local VDist3 = VDist3

        local position, name
		local positions = {}

		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', Position, radius, tMin, tMax, tRings, tType))
		positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', Position, radius, tMin, tMax, tRings, tType))
	
		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )
	
		-- I put a check in here to eliminate not only the current position but any position within a range of the current position
		-- I expanded this concept further to base the exclusion radius upon map size
		-- The idea of this is to give the AI an emphasis on expanding his bases to cover a greater portion of the map rather
		-- than clumping up - this also avoids overlap of the army pools 
	
		-- cap the minimum baserange at 180
		local minimum_baserange = 180 + (ScenarioInfo.IMAPSize/4)
	
		local Brains = ArmyBrains
        local removed = false
    
		-- loop thru all the positions
		for m,marker in positions do
        
            position    = marker.Position
            name        = marker.Name
	
			removed = false
		
			-- check all the other brains to see if they own it already
			for index,brain in Brains do
            
                local Manager = brain.BuilderManagers
                
				-- if someone else owns it or the co-ordinates are the same as this brains 'MAIN' position -- 
				if Manager[name] or ( position[1] == Manager['MAIN'].Position[1] and position[3] == Manager['MAIN'].Position[3] ) then
					
					removed = true
					break
				end
			end
		
			if not removed then

				-- check if position is within range of my other bases
				for basename,base in aiBrain.BuilderManagers do
				
					-- ignore position if too close to existing counted bases (non-Sea)
					if (base.CountedBase and base.BaseType != 'Sea') and VDist3( base.Position, position ) < minimum_baserange then
					
						removed = true
						break
					end
				end
			
                -- check the location for allied structures at HALF the expansion radius --
				if not removed then
            
                    if GetNumUnitsAroundPoint( aiBrain, categories.STRUCTURE - categories.MASSEXTRACTION - categories.WALL, position, expradius/2, 'Ally') < 1 then

                        return position, name
                    end
                    
				end
                
			end
            
		end

	end

	return false, false
end

-- This functions serves the role of finding open Start/Expansion markers which currently have no base on them
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

		local minimum_baserange = 200 + (ScenarioInfo.IMAPSize/4)
    
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
			
                -- check it against my own existing bases
				for basename, base in aiBrain.BuilderManagers do
			
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

-- finds DP and EXPANSION BASE(regular not LARGE) markers - minimum range to ANY other LAND base is 170
-- non-counted bases that operate as forward positions or intel gathering locations
function AIFindDefensivePointForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
		Position = eng
	end
	
    if Position and aiBrain.PrimaryLandAttackBase and aiBrain.AttackPlan.Goal then
        
		local Brains = ArmyBrains

		-- minimum range that a DP can be from an existing base -- Land	
		local minimum_baserange = 170 + (ScenarioInfo.IMAPSize/4)

        local removed = false
 
        local VDist3 = VDist3
	
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
        -- we'll use the current PRIMARY LAND BASE as the centrepoint for radius
        local test_position = aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position or Position
		local test_range = VDist3( test_position, aiBrain.AttackPlan.Goal )	

        local position
		local positions = {}

        -- first, we'll try to fill positions with those in the attack plan
        for k, v in aiBrain.AttackPlan.StagePoints do

            if k > 0 and k < aiBrain.AttackPlan.StageCount + 1 then

                -- the StagePoint must be on Land
                if aiBrain.AttackPlan.StagePoints[k].Type == 'Land' then

                    local basename = aiBrain.AttackPlan.StagePoints[k].Name
                    local position = aiBrain.AttackPlan.StagePoints[k].Position
                
                    -- check the nobody else already owns it
                    for index,brain in Brains do
                        if brain.BuilderManagers[basename] then
                            basename = false
                            break
                        end
                    end
                    
                    -- if not owned then insert it into the positions table
                    if basename then
                        LOUDINSERT( positions, { Name = basename, Position = table.copy(position) } )
                    end
                end    
            end
        end

        -- if we didn't get any attack plan positions then test all the markers
        if table.getn(positions) < 1 then
            positions = LOUDCONCAT( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', test_position, radius, tMin, tMax, tRings, tType))
            positions = LOUDCONCAT( positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', test_position, radius, tMin, tMax, tRings, tType))
        end

		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], test_position[1],test_position[3]) < VDist2Sq(b.Position[1],b.Position[3], test_position[1],test_position[3] ) end )

        --LOG("*AI DEBUG "..aiBrain.Nickname.." Primary Land base is "..repr(aiBrain.PrimaryLandAttackBase).." distance to goal is "..test_range)
       
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
		
			-- if it's still valid
            -- check my own bases and exclude anything too close to ANY existing base
            -- and a choice cannot be further away than my current range to the goal
			if not removed then

				for basename, base in aiBrain.BuilderManagers do
		
					if VDist3( base.Position, position ) < minimum_baserange then
                    
                        --LOG("AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for minimum range to an existing base "..VDist3( base.Position, position ) )

						removed = true
						break
                    end

                    if VDist3( aiBrain.AttackPlan.Goal, position ) > test_range then
                    
                        --LOG("AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for range greater than current primary range "..VDist3( aiBrain.AttackPlan.Goal, position ) )

						removed = true
						break
					end
				end

                -- this is the closest unused position
				if not removed then
					return position, marker.Name
				end	
			end
		end
	end

	return false, false
end

-- finds Naval DPs - minimum range to ANY sea base is 240
function AIFindNavalDefensivePointForDP( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)

    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
	if eng then
		Position = eng
	end
	
    if Position and aiBrain.PrimarySeaAttackBase and aiBrain.AttackPlan.Goal then
        
		local Brains = ArmyBrains

		-- minimum range that a DP can be from an existing base -- Naval
		local minimum_baserange = 200 + (ScenarioInfo.IMAPSize/4)

        local removed = false
 
        local VDist3 = VDist3
        
		-- this is the range that the current primary base is from the goal - new bases must be closer than this
        -- we'll use the current PRIMARY LAND BASE as the centrepoint for radius
        local test_position = aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position
		local test_range = VDist3( test_position, aiBrain.AttackPlan.Goal )	

        local position
		local positions = {}

        -- first, we'll try to fill positions with those in the attack plan
        for k, v in aiBrain.AttackPlan.StagePoints do

            if k > 0 and k < aiBrain.AttackPlan.StageCount + 1 then

                -- the StagePoint must be on Land
                if aiBrain.AttackPlan.StagePoints[k].Type == 'Amphibious' then

                    local basename = aiBrain.AttackPlan.StagePoints[k].Name
                    local position = aiBrain.AttackPlan.StagePoints[k].Position
                
                    -- check the nobody else already owns it
                    for index,brain in Brains do
                        if brain.BuilderManagers[basename] then
                            basename = false
                            break
                        end
                    end
                    
                    -- if not owned then insert it into the positions table
                    if basename then
                        LOUDINSERT( positions, { Name = basename, Position = table.copy(position) } )
                    end
                end    
            end
        end
        
        if table.getn(positions) < 1 then
            local positions = LOUDCONCAT(positions,AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Defensive Point', test_position, radius, tMin, tMax, tRings, tType))
        end

		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], test_position[1],test_position[3]) < VDist2Sq(b.Position[1],b.Position[3], test_position[1],test_position[3] ) end )
	
		-- so we now have a list of ALL the Naval DP positions on the map
		-- loop thru the list and eliminate any that are already in use
        -- or that aren't closer to the Goal position
		for m,marker in positions do
	
            position = marker.Position
			removed = false

			for _,brain in Brains do
		
				-- if in use by another brain --
				if (not removed) and brain.BuilderManagers[marker.Name] then

					removed = true
					break
				end
			end
		
			-- if valid then range check it to OUR other bases
            -- with naval bases hosting amphibious units, we must be careful of overlap with ALL types of bases
			if (not removed) then

				for basename, base in aiBrain.BuilderManagers do
		
					if VDist3( base.Position, position ) < minimum_baserange then
                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for minimum range to an existing base "..VDist3( base.Position, position ) )

						removed = true
						break
                    end

                    if VDist3( aiBrain.AttackPlan.Goal, position ) > test_range then
                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for range greater than current primary range "..VDist3( aiBrain.AttackPlan.Goal, position ) )

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

-- finds Naval Areas - minimum range to ANY sea base is 200
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

		LOUDSORT(positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Position[1],Position[3]) < VDist2Sq(b.Position[1],b.Position[3], Position[1],Position[3] ) end )
	
		local Brains = ArmyBrains
	
		-- minimum range that a Naval Base can be from ANY existing base
		local minimum_baserange = 200 + (ScenarioInfo.IMAPSize/8)
        
        local distance_from_base = false
        local distance_from_threat = false
        local threatresult = 1
        local removed = false
        
        local choices = {}

		-- so we now have a list of ALL the Naval Area positions on the map
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
            
            if not removed then

                -- range check against our other Sea bases
				for basename, base in aiBrain.BuilderManagers do

                    distance_from_base = VDist3( base.Position, position )
                    threat_distance = 0

					-- too close to one of our other bases
					if distance_from_base < minimum_baserange then
                    
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." finds position "..repr(position).." too close to "..basename.." at "..distance_from_base )

						removed = true
						break
					end
                end
            end

            -- if still valid now we'll check threat and threat distance
            if not removed then

                -- distance from origin of engineer -- valued - closer is best - lower
                distance_from_base = LOUDFLOOR(VDist3( Position, position )) / minimum_baserange

                local threatTable = aiBrain:GetThreatsAroundPosition( position, ScenarioInfo.IMAPBlocks + 2, true, tType)
                
                LOUDSORT( threatTable, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a[1],a[2], position[1],position[3]) < VDist2Sq(b[1],b[2], position[1],position[3] ) end )
                
                threatresult = distance_from_base

                for _,v in threatTable do
 
                    -- ignore any cells below tMax --
                    if v[3] > tMax then

                        -- the further threat is away - the better - lower
                        threatdistance = minimum_baserange / LOUDFLOOR( VDist2( v[1],v[2], position[1], position[3] ))

                        -- multiplied by relation to max threat allowed -- 
                        threatdistance = math.max( 1, v[3]/tMax ) * threatdistance * distance_from_base
                    
                        if threatdistance > threatresult then
                            threatresult = threatdistance
                        end
                    
                    end

                end
			end

			if not removed then
               
                LOUDINSERT( choices, {  DistThreatFactor = threatresult, Name = marker.Name, Position = position } )

			end						

		end
        
        if choices[1] then
        
            LOUDSORT( choices, function(a,b) return a.DistThreatFactor < b.DistThreatFactor end )
            
            return choices[1].Position, choices[1].Name
        end
	end
    
    --LOG("*AI DEBUG "..aiBrain.Nickname.." finds no NAVALAREA ")

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

    local GetClosestPathNode            = import('/lua/ai/aiattackutilities.lua').GetClosestPathNodeInRadiusByLayer
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD
 
    local Position = aiBrain.BuilderManagers[locationType].Position or false
	
    --LOG("*AI DEBUG "..aiBrain.Nickname.." "..locationType.." with radius "..radius.." marker radius "..markerRadius.." Units "..unitMax.." tMin "..tMin.." tMax "..tMax.." Rings "..tRings.." type "..tType.." on tick "..GetGameTick())
  	
    if Position and ( aiBrain.PrimarySeaAttackBase or aiBrain.PrimaryLandAttackBase ) and aiBrain.AttackPlan.Goal and ( aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position or aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position) then
        
        local AttackPlan    = aiBrain.AttackPlan
        local AttackGoal    = table.copy(AttackPlan.Goal)
        
        -- this gives us a Goal of the closest water node to the Attack Plan goal
        local reason, Goal = GetClosestPathNode( AttackGoal,'Water' )
        
        if not Goal then
            LOG("*AI DEBUG "..aiBrain.Nickname.." fails to find Path Node near Attack Plan Goal for Naval DP")
            return false, false
        end
        
		local Brains = ArmyBrains
        local catcheck = LOUDPARSE(category)
	
		-- minimum range that a DP can be from an existing naval position
		local minimum_baserange = 170 + (ScenarioInfo.IMAPSize/4)
       
        local position
		local positions = {}
        local removed
		local test_range = false
        local test_position = false
		
        local VDist2 = VDist2
        local VDist3 = VDist3
        
        local path, pathlength
 		
		-- this is the path distance that the current base is from the goal - new bases must be closer than this
		if aiBrain.PrimarySeaAttackBase then
            test_position = aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].Position
			path, reason, test_range = PlatoonGenerateSafePathToLOUD( aiBrain, 'AttackPlannerNavDP', 'Water', test_position, Goal, 99999, 200 )
		else
            test_position = aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].Position or false
			path, reason, test_range = PlatoonGenerateSafePathToLOUD( aiBrain, 'AttackPlannerNavDP', 'Amphibious', test_position, Goal, 99999, 185 )
		end
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." path to Goal "..repr(Goal).." from "..repr(test_position).." reason "..reason.." range "..test_range)
 
        -- first, we'll try to fill positions with those in the attack plan
        for k, v in AttackPlan.StagePoints do

            if k > 0 and k < AttackPlan.StageCount + 1 then

                -- the StagePoint must be Amphibious (Water)
                if AttackPlan.StagePoints[k].Type == 'Amphibious' then

                    local basename = AttackPlan.StagePoints[k].Name
                    local position = AttackPlan.StagePoints[k].Position
                
                    -- check that nobody else already owns it
                    for index,brain in Brains do
                        if brain.BuilderManagers[basename] then
                            basename = false
                            break
                        end
                    end
                    
                    for _, base in aiBrain.BuilderManagers do
		
                        if VDist3( base.Position, position ) < minimum_baserange then
                    
                            --LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(basename).." for minimum range to an existing base "..VDist3( base.Position, position ) )

                            basename = false
                            break
						end
                    end
                    
                    -- if not owned then insert it into the positions table
                    if basename then
                        LOUDINSERT( positions, { Name = basename, Position = table.copy(position) } )
                    end
                end    
            end
        end
        
        if table.getn(positions) < 1 then
            positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Defensive Point', test_position or Position, radius, tMin, tMax, tRings, tType))
            positions = LOUDCONCAT(positions, AIUtils.AIGetMarkersAroundLocation( aiBrain, 'Naval Area', test_position or Position, radius, tMin, tMax, tRings, tType))
        end
    
		LOUDSORT( positions, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( a.Position[1],a.Position[3], test_position[1],test_position[3] ) < VDist2Sq(b.Position[1],b.Position[3], test_position[1],test_position[3]) end )
        
		-- loop thru positions and do the structure/unit count check
		-- intended to insure that there are no allied units of same category within radius of this position
		for m,marker in positions do

            position = marker.Position
            removed = false

			for _,brain in Brains do
		
				-- if in use by another brain --
				if (not removed) and brain.BuilderManagers[marker.Name] then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." owned by "..brain.Nickname )

					removed = true
					break
				end
			end
            
            if not removed then

                -- must be able to path from current Primary to new position and it must be 10% closer than existing base
                -- also prevents the AI from trying to locate naval DPs on an unconnected body of water
                path, reason, pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, 'AttackPlanner', 'Water', test_position, position, 99999, 250 )

                if not path or pathlength > (test_range *.9) then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for pathlength "..pathlength.." vs "..test_range*.9)
                    
                    continue
                end		
            end

			-- check if there are existing structures at the point
            -- and if the position meets the range parameters for existing bases or being closer to the goal
			if (not removed) and GetNumUnitsAroundPoint( aiBrain, catcheck, position, markerRadius, 'Ally' ) <= unitMax then

				for basename, base in aiBrain.BuilderManagers do
		
					if VDist3( base.Position, position ) < minimum_baserange then
                    
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for minimum range to an existing base "..VDist3( base.Position, position ) )

						removed = true
						break
                    end

                    if VDist3( AttackGoal, position ) > test_range then
                    
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." removed "..repr(marker.Name).." for range greater than current primary range "..VDist3( AttackGoal, position ) )

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

-- this function will ping the map and/or put markers on the map
function AISendPing( position, pingType, army, message )

	local note = false
	
	if message then
		note = message
	end

	local PingTypes = {
       alert    = {Lifetime = 5, Mesh = 'alert_marker', Ring = '/game/marker/ring_yellow02-blur.dds', ArrowColor = 'yellow', Sound = 'UEF_Select_Radar'},
       attack   = {Lifetime = 5, Mesh = 'attack_marker', Ring = '/game/marker/ring_red02-blur.dds', ArrowColor = 'red', Sound = 'Aeon_Select_Radar'},
       marker   = {Lifetime = 2, Ring = '/game/marker/ring_yellow02-blur.dds', ArrowColor = 'yellow', Sound = 'UI_Main_IG_Click', Marker = true},
       move     = {Lifetime = 4, Mesh = 'move', Ring = '/game/marker/ring_blue02-blur.dds', ArrowColor = 'blue', Sound = 'Cybran_Select_Radar'},
	   warning  = {Lifetime = 4, Mesh = 'alert_marker', Ring = '/game/marker/ring_blue02-blur.dds', ArrowColor = 'blue', Sound = 'UI_Main_IG_Click'},
	}

	if PingTypes[pingType] then
	
		if not note then
		
			-- standard map pings --
			return import('/lua/simping.lua').SpawnPing( LOUDMERGED( {Owner = army - 1, Type = pingType, Location = position} , PingTypes[pingType] ) )
			
		else
			-- ping the map and place a marker --
			return import('/lua/simping.lua').SpawnPing( LOUDMERGED( {Owner = army - 1, Type = pingType, Location = position, Name = note, Color = 'ffe80a0a'} , PingTypes[pingType] ) )
			
		end
	end
	
end
