--  scenarioutilities.lua

local loudUtils = import('/lua/loudutilities.lua')


function GetMarkers()
    return ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers
end

function GetMarker(name)
    return ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[name]
end

function MarkerToPosition(strMarker)
	return ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[strMarker].position
end

function AreaToRect(strArea)

    local area = ScenarioInfo.Env.Scenario.Areas[strArea]
    
    if not area then
        error('ERROR: Invalid area name')
    end
    
    local rectangle = area.rectangle
    return Rect(rectangle[1],rectangle[2],rectangle[3],rectangle[4])
end

function InRect( vectorPos, rect )
    return vectorPos[1] > rect.x0 and vectorPos[1] < rect.x1 and vectorPos[3] > rect.y0 and vectorPos[3] < rect.y1
	
end

function FindUnitGroup(strGroup,tblNode)

    if nil == tblNode then
        return nil
    end

    local tblResult = nil

    for strName, tblData in pairs(tblNode.Units) do

        if 'GROUP' == tblData.type then
            if strName == strGroup then
                tblResult = tblData
            else
                tblResult = FindUnitGroup(strGroup,tblData)
            end
        end

        if nil != tblResult then
            break
        end
    end

    return tblResult
end

function CreateInitialArmyGroup(strArmy, createCommander)

    local tblGroup = CreateArmyGroup( strArmy, 'INITIAL')
    local cdrUnit = false

    if createCommander and ( tblGroup == nil or 0 == table.getn(tblGroup) ) then

        local factionIndex = GetArmyBrain(strArmy):GetFactionIndex()
        local initialUnitName = import('/lua/factions.lua').Factions[factionIndex].InitialUnit

        cdrUnit = CreateInitialArmyUnit(strArmy, initialUnitName)

        if EntityCategoryContains(categories.COMMAND, cdrUnit) then

            if ScenarioInfo.Options['PrebuiltUnits'] == 'Off' then
                cdrUnit:HideBone(0, true)
                ForkThread(CommanderWarpDelay, cdrUnit, 3)
            end
        end
    end

    return tblGroup, cdrUnit
end

function CommanderWarpDelay(cdrUnit, delay)
    WaitSeconds(delay)
    cdrUnit:PlayCommanderWarpInEffect()
end

function CreateProps()

    LOG("*AI DEBUG Creating Props")

	local memstart = gcinfo()
	
    for i, tblData in pairs(ScenarioInfo.Env.Scenario['Props']) do
    
        if (ScenarioInfo.MetalWorld or ScenarioInfo.MassPointRNG) and tblData.type == "Mass" then
            continue
        else
            CreatePropHPR( tblData.prop, tblData.Position[1], tblData.Position[2], tblData.Position[3], tblData.Orientation[1], tblData.Orientation[2], tblData.Orientation[3] )
        end
    end
	
	-- we dont need the prop data anymore
	ScenarioInfo.Env.Scenario['Props'] = nil

	local temptable = {}
	local LOUDINSERT = table.insert
	local type = type

	for k,v in __blueprints do
		
		if v != nil then
			
			if type(k) == 'string' then
				
				temptable[k] = v

			else
				
				LOUDINSERT(temptable, v)

			end

		end

	end
    
    __blueprints = table.copy(temptable)
    
    temptable = {}

    LOG("*AI DEBUG __Blueprints initialized with "..table.getn(__blueprints))
   
    LOG("*AI DEBUG logging duplicate ID - used " .. ( (gcinfo()*1024) ) .. " bytes")
    
    local count = 0
    local countb = 0

    for id, bp in __blueprints do
    
        if id ~= bp.BlueprintId then

            __blueprints[id] = __blueprints[bp.BlueprintId]
            
            if string.find(bp.BlueprintId,"/props/") or string.find(bp.BlueprintId,"/effects/") then
            
                count = count + 1
                --LOG("*AI DEBUG removing "..bp.BlueprintId )
            
                __blueprints[bp.BlueprintId] = nil
                
                if string.find(bp.BlueprintId,"/effects/") then
                
                    countb = countb + 1
                    --LOG("*AI DEBUG removing "..id )
                
                    __blueprints[id] = nil
                    
                else
                
                    if string.find(bp.BlueprintId,"/trees/groups/") then
                    
                        __blueprints[id].SingleTreeDir = string.gsub(bp.BlueprintId, "[^/]*/[^/]*$", "")
                        
                    end
                    
                end
 
            end

        end
        
    end

    LOG("*AI DEBUG removed "..count.." blueprints by blueprintID and "..countb.." blueprints by id")

	temptable = {}

	for k,v in __blueprints do
		
		if v != nil then
		
			if type(k) == 'string' then
				
				temptable[k] = v

			else
				
				LOUDINSERT(temptable, v)

			end

		end

	end
    
    __blueprints = table.copy(temptable)
    
    temptable = nil

    LOG("*AI DEBUG __Blueprints rebuilt with "..table.getn(__blueprints))    
	
    LOG("*AI DEBUG After clearing duplicates - used ".. (gcinfo()*1024 ) .." bytes")
    
end

function CreateResources()

	local memstart = gcinfo()
	
    local markers = GetMarkers()
    
	local Armies = ListArmies()
	local Starts = {}
    
    local coordsTbl = {}
    local newmarkers = {}

	for x = 1, 16 do
		if GetMarker('ARMY_'..x) then
			table.insert( Starts, 'ARMY_'..x )
		end
	end
    
    if ScenarioInfo.MetalWorld then
        LOG("*AI DEBUG MetalWorld DETECTED")
        
        -- we'll replace each existing mass point with 9
        -- but they'll be hidden
        coordsTbl = {
            { {-2,-2}, {-2, 2}, { 0, 0}, { 2,-2}, { 2, 2}, {-4, 0}, { 4, 0}, { 0,-4}, { 0, 4} },
        } 
    end
    
    if ScenarioInfo.MassPointRNG then
        LOG("*AI DEBUG MassPointRNG DETECTED")
        
        -- replace coordsTbl with data --
        -- randomly selected
        coordsTbl = {
            { {-2,-2}, {-2, 2}, { 2,-2}, { 2, 2}    },
            { {-2, 0}, { 0,-2}, { 2, 0}, { 0, 2}    },
            { { 0, 0}, {-2, 2}, { 2, 2}     },
            { {-2, 0}, { 0, 0}, { 2, 0}     },
            { { 0,-2}, { 0, 0}, { 0, 2}     },  
            { { 0,-2}, { 0, 2}  },
            { {-2, 0}, { 2, 0}  },
            { { 1, 1}, {-1,-1}  },
            { {-1, 1}, { 1,-1}  },
            { { 0, 0}   },
            { { 2, 0}   },
            { {-2, 0}   },
            { { 0,-2}   },
            { { 0, 2}   },
            { },
            { },
            { },
        } 
    end
    
    -- create the initial mass point list
    ScenarioInfo.StartingMassPointList = {}

	-- store the number of mass points on the map
	ScenarioInfo.NumMassPoints = 0

    ScenarioInfo.MassPointShare = 1
    
    local function CreateSingleResource(tblData)

        -- don't create Mass Points on MetalWorld
        if ScenarioInfo.MetalWorld and tblData.type == "Mass" then
            return
        end
        
        FlattenMapRect(tblData.position[1]-2, tblData.position[3]-2, 4, 4, tblData.position[2])

        CreateResourceDeposit( tblData.type, tblData.position[1], tblData.position[2], tblData.position[3],	tblData.size )

        -- fixme: texture names should come from editor
        local albedo, sx, sz, lod

        if tblData.type == "Mass" then

            albedo = "/env/common/splats/mass_marker.dds"
            sx = 2
            sz = 2
            lod = 100

            CreatePropHPR('/env/common/props/massDeposit01_prop.bp', tblData.position[1], tblData.position[2], tblData.position[3],	Random(0,360), 0, 0	)

        else

            albedo = "/env/common/splats/hydrocarbon_marker.dds"
            sx = 6
            sz = 6
            lod = 200

            CreatePropHPR('/env/common/props/hydrocarbonDeposit01_prop.bp',	tblData.position[1], tblData.position[2], tblData.position[3], Random(0,360), 0, 0 )

        end

        -- syntax reference -- Position, heading, texture name for albedo, sizex, sizez, LOD, duration, army, misc
        CreateSplat( tblData.position, 0, albedo, sx, sz, lod, 0, -1, 0	)

    end

    -- reports the percentage of mass points we'll remove at an Unused Start position
	local doit_value = tonumber(ScenarioInfo.Options.UnusedResources) or 1
    
    local count = 0
    
    LOG("*AI DEBUG Starting to Create/Relocate Resources ")  --..repr(ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers) )
    
    local AI = false
    
    -- test if there are any AI in the game
    for _, brain in ArmyBrains do
    
        if brain.BrainType == 'AI' and brain.Nickname != 'civilian' then
        
            AI = true
            LOG("*AI DEBUG AI on map - All AI and empty start locations will be resource relocated")
            break
        end
    end

    for i, tblData in ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers do

        count = count + 1

		tblData.hint = false

        if tblData.resource then

			-- assume we'll spawn the resource
			local doit = true
			
			-- loop thru all the Start positions
			for x = 1, table.getn(Starts) do
			
				local armyposition = MarkerToPosition(Starts[x])

                local AI_this_spot = false
                
                for _, brain in ArmyBrains do
                
                    if brain.Name == Starts[x] then
                    
                        if brain.BrainType == 'AI' then
                        
                            AI_this_spot = true

                        end
                    end
                end
				
				-- if the resource is within 55 of a start position it should be examined for removal
				if VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]) < 55 then
				
					for y = 1, table.getn(Armies) do
					
						-- if the position is being used keep it 
						if Armies[y] == Starts[x] then
							doit = true
							break
						end
						
						-- else turn it off
						doit = false
						
					end
					
					if not tblData.hint then
					
						-- Give me a log when a mass point is too close to a start position and needs to be moved
						-- only 4 points are permitted at a range of 35 - all others will be 55 or greater
						-- those closer than 38.5 will be put at 36 from the start - those greater will be pushed out to 55
						if doit and VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]) > 38.5 then
                        
                            local origdistance = VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3])
                        
                            if ScenarioInfo.Options.RelocateResources == 'on' or AI_this_spot then
						
                                if tblData.position[1] < armyposition[1] then
							
                                    tblData.position[1] = armyposition[1] - 39
							
                                elseif tblData.position[1] >= armyposition[1] then
						
                                    tblData.position[1] = armyposition[1] + 39
							
                                end
						
                                if tblData.position[3] < armyposition[3] then
						
                                    tblData.position[3] = armyposition[3] - 39
							
                                elseif tblData.position[3] >= armyposition[3] then
						
                                    tblData.position[3] = armyposition[3] + 39
							
                                end
						
                                tblData.position[2] = GetTerrainHeight( tblData.position[1], tblData.position[3] )
						
                                LOG("*AI DEBUG Mass Point "..repr(i).." moved to 55 "..repr(tblData.position).." from "..repr(origdistance) )
							
                                tblData.hint = true
                            
                            end

						elseif doit then
                        
                            local origdistance = VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3])
                        
                            if ScenarioInfo.Options.RelocateResources == 'on' or AI_this_spot then
						
                                -- fix the X co-ordinate 
                                if tblData.position[1] < armyposition[1] then
						
                                    tblData.position[1] = armyposition[1] - 25
							
                                elseif tblData.position[1] >= armyposition[1] then
						
                                    tblData.position[1] = armyposition[1] + 25
							
                                end
						
                                -- fix the Y co-ordinate
                                if tblData.position[3] < armyposition[3] then
						
                                    tblData.position[3] = armyposition[3] - 25
							
                                elseif tblData.position[3] >= armyposition[3] then
						
                                    tblData.position[3] = armyposition[3] + 25
							
                                end
						
                                tblData.position[2] = GetTerrainHeight( tblData.position[1], tblData.position[3] )
						
                                LOG("*AI DEBUG Mass Point "..repr(i).." moved to 35 "..repr(tblData.position).." from "..repr(origdistance) )
							
                                tblData.hint = true
                                
                            end
						
                        -- if there are AI then ALWAYS relocate unused start positions
                        --LOG("*AI DEBUG Army Position "..repr(armyposition).." is not being used - always relocate resources")
                        
						elseif not doit and VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]) > 38.5 then
                        
                            if ScenarioInfo.Options.RelocateResources == 'on' or AI then
                            
                                -- fix the X co-ordinate 
                                if tblData.position[1] < armyposition[1] then

                                    tblData.position[1] = armyposition[1] - 39
                                
                                elseif tblData.position[1] >= armyposition[1] then

                                    tblData.position[1] = armyposition[1] + 39

                                end

                                -- fix the Y co-ordinate
                                if tblData.position[3] < armyposition[3] then

                                    tblData.position[3] = armyposition[3] - 39

                                elseif tblData.position[3] >= armyposition[3] then

                                    tblData.position[3] = armyposition[3] + 39

                                end
						
                                tblData.position[2] = GetTerrainHeight( tblData.position[1], tblData.position[3] )
						
                                LOG("*AI DEBUG Mass Point "..repr(i).." moved to "..repr(tblData.position).." -- at unused start")

                                tblData.hint = true
 
                            end

                        elseif not doit then
                        
                            if ScenarioInfo.Options.RelocateResources == 'on' or AI then
                            
                                -- fix the X co-ordinate 
                                if tblData.position[1] < armyposition[1] then

                                    tblData.position[1] = armyposition[1] - 25
                                
                                elseif tblData.position[1] >= armyposition[1] then

                                    tblData.position[1] = armyposition[1] + 25

                                end

                                -- fix the Y co-ordinate
                                if tblData.position[3] < armyposition[3] then

                                    tblData.position[3] = armyposition[3] - 25

                                elseif tblData.position[3] >= armyposition[3] then

                                    tblData.position[3] = armyposition[3] + 25

                                end
						
                                tblData.position[2] = GetTerrainHeight( tblData.position[1], tblData.position[3] )
						
                                LOG("*AI DEBUG Mass Point "..repr(i).." moved to "..repr(tblData.position).." -- at unused start")

                                tblData.hint = true
 
                            end
                        
                        end
						
					else
					
						LOG("*AI DEBUG Mass Point "..repr(i).." at "..repr(tblData.position).." was already processed")
					
					end
					
				end
				
			end
			
			-- randomize so that the resources being turned off will appear a certain % of the time
			if not doit then
				
				local chance = Random(1,math.min(doit_value,99))

				-- keep it (always keep it on MetalWorld)
				if chance == doit_value or ScenarioInfo.MetalWorld then
				
					doit = true
					
				-- delete the resource point from the masterchain
				else
				
					LOG("*AI DEBUG Removing resource "..repr(i).." at "..repr(tblData.position))
                    
					ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[i] = nil
					
				end
				
			end	
			
			if doit then
            
                -- METAL WORLD --
                -- don't place mass point grahpic on MetalWorld
                -- but replace each existing point with 5
                if ScenarioInfo.MetalWorld and tblData.type == 'Mass' then
                
                    -- generate 5 points to replace the old single point
                    for _, coord in coordsTbl[math.random(1,table.getn(coordsTbl))] do
                        
                        local newttblsData = table.deepcopy(tblData)

                        newttblsData.position[1] = tblData.position[1] + coord[1]
                        newttblsData.position[3] = tblData.position[3] + coord[2]
                        newttblsData.position[2] = GetTerrainHeight(tblData.position[1],tblData.position[3])

                        -- put the new marker into the marker table
                        table.insert(newmarkers, newttblsData)

                    end

                    -- remove the source marker from original list
                    LOG("*AI DEBUG Removing original point "..repr(i).." at "..repr(tblData.position).." for METALWORLD")
                    
                    ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[i] = nil

                    continue
                    
                else
                
                    -- MASS POINT RNG --
                    if ScenarioInfo.MassPointRNG and tblData.type == 'Mass' then

                        -- randomly generate between 0 and 4 new points to replace the old one
                        for _, coord in coordsTbl[math.random(1,table.getn(coordsTbl))] do
                        
                            local newttblsData = table.deepcopy(tblData)
                            
                            newttblsData.position[1] = tblData.position[1] + coord[1]
                            newttblsData.position[3] = tblData.position[3] + coord[2]
                            newttblsData.position[2] = GetTerrainHeight(tblData.position[1],tblData.position[3])
                            
                            -- put the new marker into the marker table
                            table.insert(newmarkers, newttblsData)

                        end

                        -- remove the source marker from original list
                        LOG("*AI DEBUG Removing original point "..repr(i).." at "..repr(tblData.position).." for MassPointRNG")
                        
                        ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[i] = nil

                    end
			
                end
                
			end
            
        end

    end
    
    LOG("*AI DEBUG Reviewed "..repr(count).." markers in total")

    if newmarkers[1] then
    
        LOG("*AI DEBUG New markers were created")

        for _, data in newmarkers do
            table.insert(ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers, data)
        end
        
    end
    
    LOG("*AI DEBUG Checking for empty Start Positions and sanitizing markers")

	-- loop thru all the start positions and eliminate those which
	-- no longer have any resources within range 75 of them
    for i, tblData in ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers do
		
        if tblData.type == "Blank Marker" then
		
			local doit = false

			-- loop thru all the mass markers
			for j, massData in pairs(markers) do

				if massData.resource then
				
					-- if the resource is within 120 of a start position
					-- test it to see if that start position is being used
					if VDist2(massData.position[1],massData.position[3], tblData.position[1], tblData.position[3]) < 120 then
						--LOG("*AI DEBUG Start Position "..repr(i).." at "..repr(tblData.position).." has resources in range - keeping it")
						doit = true
						break
					end
				end
			end
			
			-- if no resources near start position then remove it
			if not doit then
            
				LOG("*AI DEBUG Removing Start Marker "..repr(i).." at "..repr(tblData.position))
                
				ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[i] = nil
			end	

        end

		if tblData.editorIcon then
			tblData.editorIcon = nil
		end
	
		if tblData.orientation then
			tblData.orientation = nil
		end
		
		if tblData.color then
			tblData.color = nil
		end
		
		if tblData.size and not tblData.resource then
			tblData.size = nil
		end
		
		if tblData.amount then
			tblData.amount = nil
		end
		
		if tblData.prop then
			tblData.prop = nil
		end
		
		if tblData.position then
		
			local a = tblData.position[1]
			local b = tblData.position[2]
			local c = tblData.position[3]
			tblData.position = { a, b, c }
			
		end
	
    end

    ScenarioInfo.Options.RelocateResources = nil
    
    markers = GetMarkers()
    
    LOG("*AI DEBUG Placing Resources on the map")
    
    -- put the resources onto the map
    for i, tblData in markers do
    
        if tblData.resource then

            CreateSingleResource(tblData)

        end
        
    end

    -- clear the marker list (forces a rebuild)
    -- at this point there shouldn't be ANY type of markers at this level of the data anyhow
    ScenarioInfo['Mass'] = nil

	-- store the number of mass points on the map
	ScenarioInfo.NumMassPoints = table.getn( import('/lua/ai/aiutilities.lua').AIGetMarkerLocations('Mass') )

	LOG("*AI DEBUG Storing Mass Points = "..ScenarioInfo.NumMassPoints)
    
    -- create the initial mass point list - this call will force the mass point marker list to be recreated
    ScenarioInfo.StartingMassPointList = table.copy(import('/lua/ai/aiutilities.lua').AIGetMarkerLocations('Mass'))

    LOG("*AI DEBUG Number of Players is "..ScenarioInfo.Options.PlayerCount)
    
    -- mass point share is how many mass points should be considered necessary before offensive actions can commence - max is 12 + number of players
    -- this is useful in driving offensive action on mass heavy maps where the mex count might be stupidly large or low player counts on large maps
    ScenarioInfo.MassPointShare = math.min( 12 + ScenarioInfo.Options.PlayerCount, math.floor(ScenarioInfo.NumMassPoints/ScenarioInfo.Options.PlayerCount) - 1)
    
    LOG("*AI DEBUG Player Mass Point Share is "..ScenarioInfo.MassPointShare)
  	
	LOG("*AI DEBUG Created Resources and used "..( (gcinfo() - memstart)*1024 ).." bytes")
	
end

-- Mex upgrade limit increases at set times to avoid early eco issues with upgrading too many at once
function MexUpgradeLimitSwitch( aiBrain )
    repeat
        WaitTicks(100)
    until aiBrain.CycleTime > 420

    aiBrain.MexUpgradeLimit = 2

    repeat
        WaitTicks(100)
    until aiBrain.CycleTime > 720

    aiBrain.MexUpgradeLimit = 4
end

function InitializeArmies()
	
	--Loop through active mods
	for i, m in __active_mods do

        -- Some custom Scenario variables to support certain mods
        
        if m.name == 'Metal World' then
            LOG("*AI DEBUG METAL WORLD Installed")
            ScenarioInfo.MetalWorld = true
        end
        
        if m.name == 'Mass Point RNG' then
            LOG("*AI DEBUG Mass Point RNG Installed")
            ScenarioInfo.MassPointRNG = true
        end
        
        if m.name == 'LOUD Debug Tools' then
            LOG("*AI DEBUG LOUD AI Debug Tools Installed")
            
        end

        -- Some custom Scenario variables to support certain mods
	
		if m.name == 'BlackOps Adv Command Units for LOUD' then
			LOG("*AI DEBUG BOACU installed")
			ScenarioInfo.BOACU_Installed = true
		end

		if m.name == 'BlackOps Unleashed Units for LOUD' then
			LOG("*AI DEBUG BOU installed")
			ScenarioInfo.BOU_Installed = true
		end
		
		if m.name == 'LOUD Integrated Storage' then
			LOG("*AI DEBUG LOUD Integrated Storage installed")
			ScenarioInfo.LOUD_IS_Installed = true
		end
    
    end

    import('/lua/sim/scenarioutilities.lua').CreateResources() 

    import('/lua/sim/scenarioutilities.lua').CreateProps() 

    ScenarioInfo.biggestTeamSize = 0

    local tblGroups = {}
    local tblArmy = ListArmies()

    local civOpt = ScenarioInfo.Options.CivilianAlliance
    local bCreateInitial = ShouldCreateInitialArmyUnits()
    
    for _,army in tblArmy do
    
        -- release some data we don't need anymore
        ScenarioInfo.ArmySetup[army].BadMap = nil
        ScenarioInfo.ArmySetup[army].LEM = nil
        ScenarioInfo.ArmySetup[army].MapVersion = nil
        ScenarioInfo.ArmySetup[army].Ready = nil
        ScenarioInfo.ArmySetup[army].StartSpot = nil
       
        if not ScenarioInfo.ArmySetup[army].Civilian then

            local brain = GetArmyBrain(army)

            if brain.BrainType == 'AI' then
                loudUtils.AddCustomUnitSupport( brain )
            end
        end
    
    end

    -- setup teams and civilians, add custom units, wrecks
    -- call out to Initialize SkirimishSystems (a great deal of AI setup)
    for iArmy, strArmy in pairs(tblArmy) do

        local tblData = ScenarioInfo.Env.Scenario.Armies[strArmy]
        local armyIsCiv = ScenarioInfo.ArmySetup[strArmy].Civilian

        tblGroups[ strArmy ] = {}

        if tblData then

            -- setup neutral/enemy status of civlians --
            -- and allied status of other players --
            for iEnemy, strEnemy in pairs(tblArmy) do
			
                local enemyIsCiv = ScenarioInfo.ArmySetup[strEnemy].Civilian

                -- if another army and you AND they are NOT NEUTRAL civilians --
                if iArmy != iEnemy and strArmy != 'NEUTRAL_CIVILIAN' and strEnemy != 'NEUTRAL_CIVILIAN' then

                    if (armyIsCiv or enemyIsCiv) and civOpt == 'neutral' then
                        SetAlliance( iArmy, iEnemy, 'Neutral')
                    else
                        SetAlliance( iArmy, iEnemy, 'Enemy')
                    end
                
                    -- in order to be ALLIED - players must be on specific teams --
                    if ScenarioInfo.ArmySetup[strArmy].Team != 1 then
                    
                        if ScenarioInfo.ArmySetup[strArmy].Team == ScenarioInfo.ArmySetup[strEnemy].Team then
                            SetAlliance( iArmy, iEnemy, 'Ally')
                        end
                        
                    end
                    
                -- if only they are NEUTRAL civilians
                elseif strArmy == 'NEUTRAL_CIVILIAN' or strEnemy == 'NEUTRAL_CIVILIAN' then
				
                    SetAlliance( iArmy, iEnemy, 'Neutral')
                end
                
            end

            SetArmyEconomy( strArmy, tblData.Economy.mass, tblData.Economy.energy)

            if not armyIsCiv then

                local brain = GetArmyBrain(strArmy)

                InitializeTeams( brain )
                
                InitializeSkirmishSystems( brain )

            end
   
        end
        
    end
    
    LOG("MAP SETUP START")
    
    for iArmy, army in tblArmy do
    
        local armyIsCiv = ScenarioInfo.ArmySetup[army].Civilian  
        local tblData = ScenarioInfo.Env.Scenario.Armies[army]
      
        if tblData then

            if (not armyIsCiv and bCreateInitial) or (armyIsCiv and civOpt != 'removed') then
			
                local commander = (not ScenarioInfo.ArmySetup[army].Civilian)
                local cdrUnit
				
                tblGroups[army], cdrUnit = CreateInitialArmyGroup( army, commander)
				
                if commander and cdrUnit and ArmyBrains[iArmy].Nickname then
                    cdrUnit:SetCustomName( ArmyBrains[iArmy].Nickname )
                end
                
            end

            local wreckageGroup = FindUnitGroup('WRECKAGE', ScenarioInfo.Env.Scenario.Armies[army].Units)
            
            -- if there is wreckage to be created --
            if wreckageGroup then
			
                local platoonList, tblResult, treeResult = CreatePlatoons( army, wreckageGroup )
				
                for num,unit in tblResult do
                    -- all wrecks created here get 1800 second lifetime (30 minutes)
                    unit:CreateWreckageProp(0, 1800)
                    unit:Destroy()
                end
                
            end
        
        end
   
    end
   
    if ScenarioInfo.Env.Scenario.Areas.AREA_1 then
    
        LOG("*AI DEBUG ScenarioInfo Map is "..repr(ScenarioInfo.Env.Scenario.Areas) )
    
        import('/lua/scenarioframework.lua').SetPlayableArea( 'AREA_1', false )
        
    end
    
    LOG("MAP SETUP END")
    
    ScenarioInfo.Configurations = nil
    
    LOG("TEAM SETUP START")
   
    ScenarioInfo.TeamMassPointList = {}
    
	-- 3+ Teams Unit Cap Fix, setting up the Unit Cap part of SetupAICheat,
    -- get each AI to build it's scouting locations
	-- now that we know what is the number of armies in the biggest team.                 
	for _, strArmy in tblArmy do

        local armyIsCiv = ScenarioInfo.ArmySetup[strArmy].Civilian
        
        local aiBrain = GetArmyBrain(strArmy)
		
		local StartPosX, StartPosZ = aiBrain:GetArmyStartPos()
		
		aiBrain.StartPosX = StartPosX
		aiBrain.StartPosZ = StartPosZ

        local place = aiBrain:GetStartVector3f()

        ForkThread( function() WaitTicks(70) FlushIntelInRect(place[1]-200,place[3]-200,place[1]+200,place[3]+200) end )

        if aiBrain.BrainType == 'AI' and not armyIsCiv then

            aiBrain.OutnumberedRatio = math.max( 1, ScenarioInfo.biggestTeamSize/aiBrain.TeamSize )

            -- each brain can store a different amount of points, based upon team size, player count and OutnumberedRatio
            aiBrain.MassPointShare = math.min( 12 + ScenarioInfo.Options.PlayerCount, math.floor(ScenarioInfo.NumMassPoints/ScenarioInfo.Options.PlayerCount) - 1)

            if aiBrain.OutnumberedRatio >= aiBrain.CheatValue then
                aiBrain.MassPointShare = math.min( math.floor(ScenarioInfo.NumMassPoints/ScenarioInfo.Options.PlayerCount) + 1, math.floor(aiBrain.MassPointShare * (aiBrain.OutnumberedRatio/aiBrain.CheatValue)))
            end

            import('/lua/ai/aiutilities.lua').SetupAICheat( aiBrain )

            if aiBrain.Personality == 'loud' then

                --- Create the SelfUpgradeIssued counter
                --- holds the number of units that have recently issued a self-upgrade
                --- is used to limit the # of self-upgrades that can be issued in a given time
                --- to avoid having more than X units trying to upgrade at once
                aiBrain.UpgradeIssued = 0
                aiBrain.MexUpgradeActive = 0

                aiBrain.MexUpgradeLimit = 1
                ForkThread( MexUpgradeLimitSwitch, aiBrain )

                aiBrain.UpgradeIssuedLimit = 1
                aiBrain.UpgradeIssuedPeriod = 225

                --- if outnumbered increase the number of simultaneous upgrades allowed
                --- and/or reduce the waiting period by 1.5 seconds ( about 10% )
                if aiBrain.OutnumberedRatio > 1.0 then
	
                    aiBrain.UpgradeIssuedLimit = aiBrain.UpgradeIssuedLimit + 1

                    --- if really outnumbered
                    if aiBrain.OutnumberedRatio >= 1.5 then

                        aiBrain.UpgradeIssuedPeriod = aiBrain.UpgradeIssuedPeriod - 15

                        --- if really badly outnumbered
                        if aiBrain.OutnumberedRatio >= 2.0 then

                            aiBrain.UpgradeIssuedLimit = aiBrain.UpgradeIssuedLimit + 1
                            aiBrain.UpgradeIssuedPeriod = aiBrain.UpgradeIssuedPeriod - 15
                        
                            if aiBrain.OutnumberedRatio >= 4.0 then

                                aiBrain.UpgradeIssuedLimit = aiBrain.UpgradeIssuedLimit + 1
                                aiBrain.UpgradeIssuedPeriod = aiBrain.UpgradeIssuedPeriod - 15

                            end
                        end
                    end
                end

                aiBrain.UpgradeIssuedPeriod = math.floor(aiBrain.UpgradeIssuedPeriod * ( 1 / aiBrain.MajorCheatModifier ))

                LOG("     "..aiBrain.Nickname.." Upgrade Issue Limit is "..aiBrain.UpgradeIssuedLimit.." simultaneous upgrades" ) 
                LOG("     "..aiBrain.Nickname.." Upgrade Issue Delay is "..aiBrain.UpgradeIssuedPeriod.." ticks between upgrades")
            
                loudUtils.BuildScoutLocations(aiBrain)

                if not ScenarioInfo.TeamMassPointList[aiBrain.Team] then
                
                    ScenarioInfo.TeamMassPointList[aiBrain.Team] = {}

                    -- each team is intially allocated the entire mass point list
                    if ScenarioInfo.StartingMassPointList[1] then
                        ScenarioInfo.TeamMassPointList[aiBrain.Team] = table.copy(ScenarioInfo.StartingMassPointList)
                    end

                end
            
                aiBrain.StartingMassPointList = {}  -- initialize starting mass point list for this brain

                if aiBrain.OutnumberedRatio > 1.5 and (aiBrain.VeterancyMult < aiBrain.OutnumberedRatio) then
        
                    local AISendChat = import('/lua/ai/sorianutilities.lua').AISendChat
        
                    ForkThread( AISendChat, 'enemies', aiBrain.Nickname, "WOW - Why dont you just beat me with a stick?" )
                    ForkThread( AISendChat, 'enemies', aiBrain.Nickname, "You Outnumber me "..tostring(aiBrain.OutnumberedRatio).." to 1 !")
                    ForkThread( AISendChat, 'enemies', aiBrain.Nickname, "And all you give me is a "..tostring(aiBrain.VeterancyMult).." bonus?")
        
                end

                -- start the spawn wave thread for cheating AI --
                aiBrain.WaveThread = ForkThread(import('/lua/loudutilities.lua').SpawnWaveThread, aiBrain)

            end
            
            import('/lua/ai/aiutilities.lua').SetupAICheatUnitCap( aiBrain, ScenarioInfo.biggestTeamSize )

		end
        
    end
    
    LOG("TEAM SETUP END")
    
    LOG("TEAM MASSPOINT SELECT START")
    
    for k, v in ScenarioInfo.TeamMassPointList do
    
        LOG("     Process Mass Points for team "..repr(k))
        
        local count = 0
        local apply = true
        
        while apply do

            apply = false
            
            for a, brain in ArmyBrains do
            
                if ScenarioInfo.TeamMassPointList[brain.Team] and count < brain.MassPointShare then

                    if brain.BrainType == 'AI' and brain.Team == k and brain.StartingMassPointList then
            
                        if count == 0 then
                            LOG("        "..brain.Nickname.." storing "..brain.MassPointShare.." Mass Points" )
                        end
                
                        local Position = { brain.StartPosX, 0, brain.StartPosZ }

                        -- sort the list for closest
                        table.sort(ScenarioInfo.TeamMassPointList[brain.Team], function(a,b) return VDist3( a.Position, Position ) < VDist3( b.Position, Position) end )
                        
                        -- take the closest one and remove it from master list
                        table.insert( brain.StartingMassPointList, table.remove( ScenarioInfo.TeamMassPointList[brain.Team], 1 ))
                        
                        apply = true    

                    end

                end
            
            end
            
            count = count + 1
        
        end

    end
    
    LOG("TEAM MASSPOINT SELECT END")

    loudUtils.StartAdaptiveCheatThreads()
   
    ScenarioInfo.StartingMassPointList = nil
    ScenarioInfo.TeamMassPointList = nil
    
    ScenarioInfo.Options.AIResourceSharing = nil
    ScenarioInfo.Options.AIFactionColor = nil
    
    return tblGroups
	
end

function InitializeTeams(self)
	
	-- store which team we're on
    if ScenarioInfo.ArmySetup[self.Name].Team == 1 then
        self.Team = -1 * self.ArmyIndex  -- no team specified
    else
        self.Team = ScenarioInfo.ArmySetup[self.Name].Team  -- specified team number
    end

    local Opponents = 0
    local TeamSize = 1
    local BiggestTeamSize = 1

    -- calculate team sizes
    for index, playerInfo in ArmyBrains do
    
        if ArmyIsCivilian(playerInfo.ArmyIndex) or index == self.ArmyIndex then continue end

        if IsAlly( index, self.ArmyIndex) then 
            TeamSize = TeamSize + 1
        else
            Opponents = Opponents + 1
        end
        
        if TeamSize > BiggestTeamSize then
            BiggestTeamSize = TeamSize
        end

    end

	local color = ScenarioInfo.ArmySetup[self.Name].WheelColor

	SetArmyColor(self.ArmyIndex, color[1], color[2], color[3])

	-- Don't need WheelColor anymore, so delete it
	ScenarioInfo.ArmySetup[self.Name].WheelColor = nil

    if ScenarioInfo.Options.AIFactionColor == 'on' and self.BrainType ~= 'Human' then
        -- These colours are based on the lobby faction dropdown icons
        if self.FactionIndex == 1 then
            SetArmyColor(self.ArmyIndex, 44, 159, 200)
        elseif self.FactionIndex == 2 then
            SetArmyColor(self.ArmyIndex, 104, 171, 77)
        elseif self.FactionIndex == 3 then
            SetArmyColor(self.ArmyIndex, 255, 0, 0)
        elseif self.FactionIndex == 4 then
            SetArmyColor(self.ArmyIndex, 254, 189, 44)
        end
    end

    -- number of Opponents in the game
    self.NumOpponents = Opponents

    -- default outnumbered ratio
    self.OutnumberedRatio = 1

    -- number of players in the game 
    self.Players = ScenarioInfo.Options.PlayerCount

    self.TeamSize = TeamSize

    if self.TeamSize >= ScenarioInfo.biggestTeamSize then
		ScenarioInfo.biggestTeamSize = TeamSize		
	end

end

function InitializeSkirmishSystems(self)
    
    -- don't do anything else for a human player
    if self.BrainType == 'Human' then
        return
    end

    if ScenarioInfo.Options.AIResourceSharing == 'off' then
        
        self:SetResourceSharing(false)

    elseif ScenarioInfo.Options.AIResourceSharing == 'aiOnly' then

        for i, playerInfo in ArmyBrains do
            
            -- If this AI is allied to a human, disable resource sharing
            if IsAlly(i, self.ArmyIndex) and playerInfo.BrainType == 'Human' then
                
                self:SetResourceSharing(false)
                break
            end
        end

    else
        self:SetResourceSharing(true)
    end

    -- Create the Condition monitor
    self.ConditionsMonitor = import('/lua/sim/BrainConditionsMonitor.lua').CreateConditionsMonitor(self)

    -- Create the Economy Data structures and start Economy monitor thread
    self:ForkThread1(loudUtils.EconomyMonitor)

    -- Base counters
    self.NumBases = 0
    self.NumBasesLand = 0
	self.NumBasesNaval = 0

	-- Veterancy multiplier
	self.VeterancyMult = 1.0

	-- set the base radius according to map size -- affects platoon formation radius and base alert radius
	local mapSizex = ScenarioInfo.size[1]

	local BuilderRadius = math.max(90, (mapSizex/16)) -- should give a range between 90 and 256+
	local BuilderRadius = math.min(BuilderRadius, 140) -- and then limit it to no more than 140

	local RallyPointRadius = 49	-- create automatic rally points at 49 from centre

	-- Set the flag that notes if an expansion base is being setup -- when an engineer takes on an expansion task, he'll set this flag to true
	-- when he dies or starts building the new base, he'll set it back to false
	-- we use this to keep the AI from doing more than one expansion at a time
	self.BaseExpansionUnderway = false

    --- create Persistent Pool platoons

    -- for isolating structures (used by LOUD AI)
    local structurepool = self:MakePlatoon('StructurePool','none')

    structurepool:UniquelyNamePlatoon('StructurePool')
    structurepool.BuilderName = 'Struc'
    structurepool.UsingTransport = true     -- insures that it never gets reviewed in a merge operation

	self.StructurePool = structurepool

    --- for isolating aircraft low on fuel (used by LOUD AI)
    local refuelpool = self:MakePlatoon('RefuelPool','none')

    refuelpool:UniquelyNamePlatoon('RefuelPool')
    refuelpool.BuilderName = 'Refuel'
    refuelpool.UsingTransport = true        -- never gets reviewed in a merge --

	self.RefuelPool = refuelpool

	--- the standard Army Pool
	local armypool = self:GetPlatoonUniquelyNamed('ArmyPool')

	armypool:UniquelyNamePlatoon('ArmyPool')
	armypool.BuilderName = 'Army'

	self.ArmyPool = armypool

	-- Start the Dead Base Monitor
	self:ForkThread1( loudUtils.DeadBaseMonitor )

    -- Start the Enemy Picker (AttackPlanner, etc)
    self.EnemyPickerThread = self:ForkThread( loudUtils.PickEnemy )

	-- Start the Path Generator
	self:ForkThread1( loudUtils.PathGeneratorThread )

    -- start PlatoonDistressMonitor
    self:ForkThread1( loudUtils.PlatoonDistressMonitor )

	-- start watching the intel data
	self:ForkThread1( loudUtils.ParseIntelThread )

	-- record the starting unit cap	
	-- caps of 1000+ trigger some conditions
	self.StartingUnitCap = GetArmyUnitCap(self.ArmyIndex)

    self:ForkThread( self.AddBuilderManagers, self:GetStartVector3f(), BuilderRadius, 'MAIN', false, RallyPointRadius, true, 'FRONT')

end

function CreatePlatoons( strArmy, tblNode, tblResult, platoonList, currPlatoon, treeResult, balance )

    tblResult = tblResult or {}
    platoonList = platoonList or {}
    treeResult = treeResult or {}
    currPlatoon = currPlatoon or false
	
    local treeLocal = {}

    if nil == tblNode then
        return nil
    end

    local brain = GetArmyBrain(strArmy)
    local armyIndex = brain:GetArmyIndex()
    local currTemplate
    local numRows
    local reversePlatoon = false
    local reverseRows
    local reverseTemplate
	
    if nil ~= tblNode.platoon and '' != tblNode.platoon and tblNode ~= currPlatoon
        and not platoonList[tblNode.platoon] then
        currTemplate = ScenarioInfo.Env.Scenario.Platoons[tblNode.platoon]
        if currTemplate then
            platoonList[tblNode.platoon] = brain:MakePlatoon('', currTemplate[2])
            platoonList[tblNode.platoon].squadCounter = {}
            currPlatoon = tblNode.platoon
        end
    end
	
    if currPlatoon then
        currTemplate = ScenarioInfo.Env.Scenario.Platoons[currPlatoon]
        numRows = table.getn(currTemplate)
    end

    local unit = nil

    for strName, tblData in pairs(tblNode.Units) do
    
        if 'GROUP' == tblData.type then
            
            platoonList, tblResult, treeResult[strName] = CreatePlatoons(strArmy, tblData, tblResult, platoonList, currPlatoon, treeResult[strName], balance)  

        else
            if categories[tblData.type] then
                unit = CreateUnitHPR( tblData.type, strArmy, tblData.Position[1], tblData.Position[2], tblData.Position[3], tblData.Orientation[1], tblData.Orientation[2], tblData.Orientation[3] )
			else
                unit = false
            end
            
			if unit then
				if unit:GetBlueprint().Physics.FlattenSkirt then
					unit:CreateTarmac(true, true, true, false, false)
				end
				
				table.insert(tblResult, unit)
				
				treeResult[strName] = unit
				
				if ScenarioInfo.UnitNames[armyIndex] then
					ScenarioInfo.UnitNames[armyIndex][strName] = unit
				end
				
				unit.UnitName = strName
				
				if tblData.platoon ~= nil and tblData.platoon ~= '' and tblData.platoon ~= currPlatoon then
					reversePlatoon = currPlatoon
					reverseRows = numRows
					reverseTemplate = currTemplate
					
					if not platoonList[tblData.platoon] then
						currTemplate = ScenarioInfo.Env.Scenario.Platoons[tblData.platoon]
						platoonList[tblData.platoon] = brain:MakePlatoon('', currTemplate[2])
						platoonList[tblData.platoon].squadCounter = {}
					end
					
					currPlatoon = tblData.platoon
					currTemplate = ScenarioInfo.Env.Scenario.Platoons[currPlatoon]
					numRows = table.getn(currTemplate)
				end
				
				if currPlatoon then
					local i = 3
					local inserted = false
					while i <= numRows and not inserted do
					
						if platoonList[currPlatoon].squadCounter[i] == nil then
							platoonList[currPlatoon].squadCounter[i] = 0
						end
						
						if tblData.type == currTemplate[i][1] and platoonList[currPlatoon].squadCounter[i] < currTemplate[i][3] then
						
							platoonList[currPlatoon].squadCounter[i] = platoonList[currPlatoon].squadCounter[i] + 1
							brain:AssignUnitsToPlatoon(platoonList[currPlatoon],{unit},currTemplate[i][4],currTemplate[i][5] )
							inserted = true
						end
						
						i = i + 1
					end
					
					if reversePlatoon then
						currPlatoon = reversePlatoon
						numRows = reverseRows
						currTemplate = reverseTemplate
						reversePlatoon = false
					end
				end
            
				if balance then
					--Accumulate for one tick so we don't get too much overhead from thread switching...
					--ScenarioInfo.LoadBalance.Accumulator = ScenarioInfo.LoadBalance.Accumulator + timePerChild
					ScenarioInfo.LoadBalance.Accumulator = ScenarioInfo.LoadBalance.Accumulator + 1
                
					if ScenarioInfo.LoadBalance.Accumulator > ScenarioInfo.LoadBalance.UnitThreshold then
						WaitSeconds(0)
						ScenarioInfo.LoadBalance.Accumulator = 0
					end
				end
			end
		end
    end

    return platoonList, tblResult, treeResult
end

function CreateArmyGroup(strArmy,strGroup,wreckage, balance)

    local brain = GetArmyBrain(strArmy)
	
    -- for this process we will turn off the cap limits, create the units, and then turn it back on
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
	
    local platoonList, tblResult, treeResult = CreatePlatoons(strArmy, FindUnitGroup( strGroup, ScenarioInfo.Env.Scenario.Armies[strArmy].Units ), nil, nil, nil, nil, balance )

    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    
    if tblResult == nil and strGroup ~= 'INITIAL' then
        error('SCENARIO UTILITIES WARNING: No units found for for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
    end
    
    if wreckage then
    
        for num, unit in tblResult do
            unit:CreateWreckageProp(0, 1800)
            unit:Destroy()
        end
        
        return
    end
    
    return tblResult, treeResult, platoonList
end

function FlattenTreeGroup( strArmy, strGroup, tblData, unitGroup )
    tblData = tblData or FindUnitGroup( strGroup, ScenarioInfo.Env.Scenario.Armies[strArmy].Units )
    unitGroup = unitGroup or {}
    for strName, tblData in pairs(tblData.Units) do
        if 'GROUP' == tblData.type then
            FlattenTreeGroup( strArmy, strGroup, tblData, unitGroup )
        else
            table.insert( unitGroup, tblData )
        end
    end
    return unitGroup
end

function RebuildDataTable(table)
    local newTable = {}
    for k,v in table do
        local checkType = type(v.value)
        if type(v.value) == 'table' then
            newTable[v.name] = RebuildDataTable(v.value)
        else
            newTable[v.name] = v.value
        end
    end
    return newTable
end

function InitializeStartLocation(strArmy)
    local start = GetMarker(strArmy)
    if start then
        SetArmyStart(strArmy, start.position[1], start.position[3])
    else
        GenerateArmyStart(strArmy)
    end
end

function SetPlans(strArmy)
    if ScenarioInfo.Env.Scenario.Armies[strArmy] then
        SetArmyPlans(strArmy, ScenarioInfo.Env.Scenario.Armies[strArmy].plans)
    end
end

