--  scenarioutilities.lua


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

	local memstart = gcinfo()
	
    for i, tblData in pairs(ScenarioInfo.Env.Scenario['Props']) do
    
        if ScenarioInfo.MetalWorld and tblData.type == 'Mass' then
            continue
        else
            CreatePropHPR( tblData.prop, tblData.Position[1], tblData.Position[2], tblData.Position[3], tblData.Orientation[1], tblData.Orientation[2], tblData.Orientation[3] )
        end
    end
	
	-- we dont need the prop data anymore
	ScenarioInfo.Env.Scenario['Props'] = nil

end

function CreateResources()

	local memstart = gcinfo()
	
    local markers = GetMarkers()
	local Armies = ListArmies()
	local Starts = {}

	for x = 1, 16 do
		if GetMarker('ARMY_'..x) then
			table.insert( Starts, 'ARMY_'..x )
		end
	end
    
    if ScenarioInfo.MetalWorld then
        LOG("*AI DEBUG METALWORLD DETECTED")
    end
    
    -- create the initial mass point list
    ScenarioInfo.StartingMassPointList = {}

	-- store the number of mass points on the map
	ScenarioInfo.NumMassPoints = 0

    ScenarioInfo.MassPointShare = 1

	local doit_value = tonumber(ScenarioInfo.Options.UnusedResources) or 1
	
    for i, tblData in pairs(markers) do
	
		if tblData.orientation then
			tblData.orientation = nil
		end

		tblData.hint = false

		if tblData.editorIcon then
			tblData.editorIcon = nil
		end
	
        if tblData.resource then

			-- assume we'll spawn the resource
			local doit = true
			
			-- loop thru all the Start positions
			for x = 1, table.getn(Starts) do
			
				local armyposition = MarkerToPosition(Starts[x])
                
                local AI = false
                
                for _, brain in ArmyBrains do
                
                    if brain.Name == Starts[x] then
                    
                        if brain.BrainType == 'AI' then
                        
                            AI = true

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
						-- those closer than 37.6 will be put at 36 from the start - those greater than 37 will be pushed out to 55
						if doit and VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]) > 37.6 then
                        
                            if ScenarioInfo.Options.RelocateResources == 'on' or AI then
					
                                --LOG("*AI DEBUG Mass Point at distance "..VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]).." - Position "..repr(tblData.position).." too close (55) to Start position")
						
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
						
                                LOG("*AI DEBUG Mass Point moved to 55 "..repr(tblData.position))
							
                                tblData.hint = true
                            
                            end

						elseif doit then
                        
                            if ScenarioInfo.Options.RelocateResources == 'on' or AI then
					
                                --LOG("*AI DEBUG Mass Point at distance "..VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]).." - Position "..repr(tblData.position).." too near to Start position")
						
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
						
                                LOG("*AI DEBUG Mass Point moved to 35 "..repr(tblData.position))
							
                                tblData.hint = true
                                
                            end
						
						end
						
					else
					
						LOG("*AI DEBUG Mass Point at "..repr(tblData.position).." was already moved")
					
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
				
					LOG("*AI DEBUG Removing resource at "..repr(tblData.position))
					ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[i] = nil
					
				end
				
			end	
			
			if doit then
            
                -- don't place mass point grahpic on MetalWorld
                if ScenarioInfo.MetalWorld and tblData.type == 'Mass' then
                    
                    continue
                    
                else
			
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
			end
        end
		
		if tblData.prop then
			tblData.prop = nil
		end
		
		if tblData.color then
			tblData.color = nil
		end
		
		if tblData.size then
			tblData.size = nil
		end
		
		if tblData.amount then
			tblData.amount = nil
		end
		
		if tblData.position then
		
			local a = tblData.position[1]
			local b = tblData.position[2]
			local c = tblData.position[3]
			tblData.position = { a, b, c }
			
		end
		
    end
	
	-- loop thru all the start positions and eliminate those which
	-- no longer have any resources within range 75 of them
    for i, tblData in pairs(markers) do
		
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

    end

    ScenarioInfo.Options.RelocateResources = nil
	
	LOG("*AI DEBUG Created Resources and used "..( (gcinfo() - memstart)*1024 ).." bytes")
    
    -- create the initial mass point list
    ScenarioInfo.StartingMassPointList = table.copy(import('/lua/ai/aiutilities.lua').AIGetMarkerLocations('Mass'))

	-- store the number of mass points on the map
	ScenarioInfo.NumMassPoints = table.getn( import('/lua/ai/aiutilities.lua').AIGetMarkerLocations('Mass') )

	LOG("*AI DEBUG Storing Mass Points = "..ScenarioInfo.NumMassPoints)
    
    LOG("*AI DEBUG Number of Players is "..ScenarioInfo.Options.PlayerCount)
    
    ScenarioInfo.MassPointShare = math.floor(ScenarioInfo.NumMassPoints/ScenarioInfo.Options.PlayerCount)
    
    LOG("*AI DEBUG Player Mass Point Share is "..ScenarioInfo.MassPointShare)
	
end

function InitializeArmies()

    local loudUtils = import('/lua/loudutilities.lua')

    ScenarioInfo.biggestTeamSize = 0
    
    local function InitializeSkirmishSystems(self)
	
		-- store which team we're on
        if ScenarioInfo.ArmySetup[self.Name].Team == 1 then
            self.Team = -1 * self.ArmyIndex  -- no team specified
        else
            self.Team = ScenarioInfo.ArmySetup[self.Name].Team  -- specified team number
        end
        
        local Opponents = 0
        local TeamSize = 1

        for index, playerInfo in ArmyBrains do
    
            if ArmyIsCivilian(playerInfo.ArmyIndex) or index == self.ArmyIndex then continue end

            if IsAlly( index, self.ArmyIndex) then 
                TeamSize = TeamSize + 1
            else
                Opponents = Opponents + 1
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
        
        LOG("*AI DEBUG "..self.Nickname.." Team "..self.Team.." Teamsize is "..TeamSize.." Opponents is "..Opponents)
        
        self.TeamSize = TeamSize
		
		if self.TeamSize > ScenarioInfo.biggestTeamSize then
			ScenarioInfo.biggestTeamSize = TeamSize		
		end
    
        -- don't do anything else for a human player
        if self.BrainType == 'Human' then
            return
        end

        if ScenarioInfo.Options.AIResourceSharing == 'off' then
            self:SetResourceSharing(false)
        elseif ScenarioInfo.Options.AIResourceSharing == 'aiOnly' then
            local allPlayersAI = true
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

		-- build table of scout locations and set some starting threat at all enemy locations
		loudUtils.BuildScoutLocations(self)

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
		
		-- Create the SelfUpgradeIssued counter
		-- holds the number of units that have recently issued a self-upgrade
		-- is used to limit the # of self-upgrades that can be issued in a given time
		-- to avoid having more than X units trying to upgrade at once
		self.UpgradeIssued = 0
		self.UpgradeIssuedLimit = 1
		self.UpgradeIssuedPeriod = 225

		-- set the base radius according to map size -- affects platoon formation radius and base alert radius
		local mapSizex = ScenarioInfo.size[1]
		local BuilderRadius = math.max(100, (mapSizex/16)) -- should give a range between 100 and 256+
		local BuilderRadius = math.min(BuilderRadius, 140) -- and then limit it to no more than 140
		
		local RallyPointRadius = 49	-- create automatic rally points at 49 from centre
		
		-- Set the NeedTransports flag -- used when the AI tries to air transport units and cannot find enough transport
		-- this brings factory platoons online to build more (more than standard)
		self.NeedTransports = nil
		
		-- Set the flag that notes if an expansion base is being setup -- when an engineer takes on an expansion task, he'll set this flag to true
		-- when he dies or starts building the new base, he'll set it back to false
		-- we use this to keep the AI from doing more than one expansion at a time
		self.BaseExpansionUnderway = false
		
		-- level AI starting locations
		--loudUtils.LevelStartBaseArea(self:GetStartVector3f(), RallyPointRadius )
		
        -- Create the Builder Managers for the MAIN base
        self:AddBuilderManagers(self:GetStartVector3f(), BuilderRadius, 'MAIN', false, RallyPointRadius, true, 'FRONT')
		
		-- turn on the PrimaryLandAttackBase flag for MAIN
		self.BuilderManagers.MAIN.PrimaryLandAttackBase = true
		self.PrimaryLandAttackBase = 'MAIN'
        
        -- Create the Strategy Manager (disabled) from the Sorian AI
        --self.BuilderManagers.MAIN.StrategyManager = StratManager.CreateStrategyManager(self, 'MAIN', self:GetStartVector3f(), 100)
		
        -- create Persistent Pool platoons -- and store the handle on the brain
        -- for isolating transports
        local transportplatoon = self:MakePlatoon('TransportPool','none')
		
        transportplatoon:UniquelyNamePlatoon('TransportPool') 
		transportplatoon.BuilderName = 'Transport Pool'
        transportplatoon.UsingTransport = true      -- never review this platoon during a merge

		self.TransportPool = transportplatoon
        
        -- for isolating structures (used by LOUD AI)
        local structurepool = self:MakePlatoon('StructurePool','none')
		
        structurepool:UniquelyNamePlatoon('StructurePool')
		structurepool.BuilderName = 'Structure Pool'
        structurepool.UsingTransport = true     -- insures that it never gets reviewed in a merge operation
		
		self.StructurePool = structurepool
        
        -- for isolating aircraft low on fuel (used by LOUD AI)
        local refuelpool = self:MakePlatoon('RefuelPool','none')
		
        refuelpool:UniquelyNamePlatoon('RefuelPool')
		refuelpool.BuilderName = 'Refuel Pool'
        refuelpool.UsingTransport = true        -- never gets reviewed in a merge --
		
		self.RefuelPool = refuelpool
		
		-- the standard Army Pool
		local armypool = self:GetPlatoonUniquelyNamed('ArmyPool')
		
		armypool:UniquelyNamePlatoon('ArmyPool')
		armypool.BuilderName = 'ArmyPool'
		
		self.ArmyPool = armypool
		

		-- Start the Dead Base Monitor
		self:ForkThread1( loudUtils.DeadBaseMonitor )
		
        -- Start the Enemy Picker
        self:ForkThread1( loudUtils.PickEnemy )
		
		-- Start the Path Generator
		self:ForkThread1( loudUtils.PathGeneratorThread )
		
        -- start PlatoonDistressMonitor
        self:ForkThread1( loudUtils.PlatoonDistressMonitor )

		-- start watching the intel data
		self:ForkThread1( loudUtils.ParseIntelThread )

		-- record the starting unit cap	
		-- caps of 1000+ trigger some conditions
		self.StartingUnitCap = GetArmyUnitCap(self.ArmyIndex)
  
		if self.CheatingAI then
			import('/lua/ai/aiutilities.lua').SetupAICheat( self )
		end
		
		local PlayerDiff = (self.NumOpponents or 1)/(self.Players - self.NumOpponents)		
 
		-- if outnumbered increase the number of simultaneous upgrades allowed
		-- and reduce the waiting period by 2 seconds ( about 10% )
		if PlayerDiff > 1.0 then
	
			self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
			self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20
            
            -- if really outnumbered do this a second time
            if PlayerDiff > 1.5 then
            
                self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20
                
                -- if really badly outnumbered then we do it a 3rd time
                if PlayerDiff > 2.0 then
                
                    self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
                    self.UpgradeIssuedPerio = self.UpgradeIssuedPeriod - 20
                    
                end
            
            end
	
		end

    end

    local tblGroups = {}
    local tblArmy = ListArmies()

    local civOpt = ScenarioInfo.Options.CivilianAlliance
    local bCreateInitial = ShouldCreateInitialArmyUnits()
    
    -- setup teams and civilians, add custom units, wrecks
    -- call out to Initialize SkirimishSystems (a great deal of AI setup)
    for iArmy, strArmy in pairs(tblArmy) do
    
        -- release some data we don't need anymore
        ScenarioInfo.ArmySetup[strArmy].BadMap = nil
        ScenarioInfo.ArmySetup[strArmy].LEM = nil
        ScenarioInfo.ArmySetup[strArmy].MapVersion = nil
        ScenarioInfo.ArmySetup[strArmy].Ready = nil
        ScenarioInfo.ArmySetup[strArmy].StartSpot = nil

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
			
			-- if this is an AI (but not civilian)        
            if GetArmyBrain(strArmy).BrainType == 'AI' and (not armyIsCiv) then
                loudUtils.AddCustomUnitSupport(GetArmyBrain(strArmy))
            end
            
            SetArmyEconomy( strArmy, tblData.Economy.mass, tblData.Economy.energy)
            
            if not armyIsCiv then
                -- this insures proper setting of teammate counts and
                -- calculation of the largest team size for ALL players (human and AI)
                InitializeSkirmishSystems( GetArmyBrain(strArmy) )
            end

            if (not armyIsCiv and bCreateInitial) or (armyIsCiv and civOpt != 'removed') then
			
                local commander = (not ScenarioInfo.ArmySetup[strArmy].Civilian)
                local cdrUnit
				
                tblGroups[strArmy], cdrUnit = CreateInitialArmyGroup( strArmy, commander)
				
                if commander and cdrUnit and ArmyBrains[iArmy].Nickname then
                    cdrUnit:SetCustomName( ArmyBrains[iArmy].Nickname )
                end
                
            end

            local wreckageGroup = FindUnitGroup('WRECKAGE', ScenarioInfo.Env.Scenario.Armies[strArmy].Units)
            
            -- if there is wreckage to be created --
            if wreckageGroup then
			
                local platoonList, tblResult, treeResult = CreatePlatoons(strArmy, wreckageGroup )
				
                for num,unit in tblResult do
                    -- all wrecks created here get 1800 second lifetime (30 minutes)
                    unit:CreateWreckageProp(0, 1800)
                    unit:Destroy()
                end
                
            end
            
        end
        
    end

	
    import('/lua/sim/scenarioutilities.lua').CreateProps()
    
    import('/lua/sim/scenarioutilities.lua').CreateResources()
	
   
    ScenarioInfo.TeamMassPointList = {}
    
	--3+ Teams Unit Cap Fix, setting up the Unit Cap part of SetupAICheat,
	-- now that we know what is the number of armies in the biggest team.                 
	for _, strArmy in tblArmy do

        local armyIsCiv = ScenarioInfo.ArmySetup[strArmy].Civilian
        local aiBrain = GetArmyBrain(strArmy)

        if aiBrain.BrainType == 'AI' and not armyIsCiv then
			
            import('/lua/ai/aiutilities.lua').SetupAICheatUnitCap( aiBrain, ScenarioInfo.biggestTeamSize )
            
            if not ScenarioInfo.TeamMassPointList[aiBrain.Team] then
            
                LOG("*AI DEBUG Creating Starting Mass Point List for Team "..aiBrain.Team)
                
                ScenarioInfo.TeamMassPointList[aiBrain.Team] = {}
                
                if ScenarioInfo.StartingMassPointList[1] then
                
                    ScenarioInfo.TeamMassPointList[aiBrain.Team] = table.copy(ScenarioInfo.StartingMassPointList)
                    
                end

            end
            
            aiBrain.StartingMassPointList = {}  -- initialize starting mass point list for this brain
            
            aiBrain.MassPointShare = ScenarioInfo.MassPointShare

		end
        
    end
    
    for k, v in ScenarioInfo.TeamMassPointList do
    
        LOG("*AI DEBUG Processing "..ScenarioInfo.MassPointShare.." TeamMassPoints for team "..repr(k))
        
        local count = 0
        
        while count < ScenarioInfo.MassPointShare do
        
            for a, brain in ArmyBrains do
        
                
                if brain.BrainType == 'AI' and brain.Team == k then
                
                    local Position = { brain.StartPosX, 0, brain.StartPosZ }

                    -- sort the list for closest
                    table.sort(ScenarioInfo.TeamMassPointList[brain.Team], function(a,b) return VDist3( a.Position, Position ) < VDist3( b.Position, Position) end )
                    
                    -- take the closest one and remove it from master list
                    table.insert( brain.StartingMassPointList, table.remove( ScenarioInfo.TeamMassPointList[brain.Team], 1 ))

                end
            
            end
            
            count = count + 1
        
        end

        for a, brain in ArmyBrains do
        
            if brain.BrainType == 'AI' and brain.Team == k then
                LOG("*AI DEBUG "..brain.Nickname.." StartingMassPointList is "..repr(brain.StartingMassPointList))
            end
            
        end
        
    end

    loudUtils.StartAdaptiveCheatThreads()
    
    loudUtils.StartSpeedProfile()
   
    ScenarioInfo.StartingMassPointList = nil
    ScenarioInfo.TeamMassPointList = nil
    
    ScenarioInfo.Options.AIResourceSharing = nil
    ScenarioInfo.Options.AIFactionColor = nil
    
    return tblGroups
	
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
            unit = safecall( "Cant load unit", CreateUnitHPR, tblData.type, strArmy, tblData.Position[1], tblData.Position[2], tblData.Position[3], tblData.Orientation[1], tblData.Orientation[2], tblData.Orientation[3] )
			
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

