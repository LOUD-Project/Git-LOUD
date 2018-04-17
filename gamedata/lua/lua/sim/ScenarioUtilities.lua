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
        CreatePropHPR( tblData.prop, tblData.Position[1], tblData.Position[2], tblData.Position[3], tblData.Orientation[1], tblData.Orientation[2], tblData.Orientation[3] )
    end
	
	-- we dont need the prop data anymore
	ScenarioInfo.Env.Scenario['Props'] = nil
	
	LOG("*AI DEBUG Created Props and used "..( (gcinfo() - memstart)*1024 ).." bytes")
end

function CreateResources()

	local memstart = gcinfo()
	
    local markers = GetMarkers()
	local Armies = ListArmies()
	local Starts = {}
	
	LOG("*AI DEBUG Armies is "..repr(Armies))
	
	for x = 1, 16 do
		if GetMarker('ARMY_'..x) then
			table.insert( Starts, 'ARMY_'..x )
		end
	end
	
	LOG("*AI DEBUG Start positions are "..repr(Starts))
	
	local doit_value = tonumber(ScenarioInfo.Options.UnusedResources) or 1
	
	LOG("*AI DEBUG Unused Start Resources value is "..doit_value)
	
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
				
				-- if the resource is within 60 of a start position it should be examined for removal
				if VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]) < 55 then
				
					-- is the start position is being used
					for y = 1, table.getn(Armies) do
						-- keep it 
						if Armies[y] == Starts[x] then
							doit = true
							break
						end
						-- else turn it off
						doit = false
					end
					
					if not tblData.hint then
					
						-- Give me a log when a mass point is too close to a start position and needs to be moved
						-- those closer than 37 will be put at 36 from the start - those greater than 37 will be pushed out to 55
						if doit and VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]) > 37 then
					
							LOG("*AI DEBUG Mass Point at distance "..VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]).." - Position "..repr(tblData.position).." too close (55) to Start position")
						
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
						
							LOG("*AI DEBUG Mass Point moved to "..repr(tblData.position))
							
							tblData.hint = true

						elseif doit then
					
							LOG("*AI DEBUG Mass Point at distance "..VDist2(armyposition[1],armyposition[3], tblData.position[1], tblData.position[3]).." - Position "..repr(tblData.position).." too near to Start position")
						
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
						
							LOG("*AI DEBUG Mass Point moved to "..repr(tblData.position))
							
							tblData.hint = true
						
						end
						
					else
					
						LOG("*AI DEBUG Mass Point at "..repr(tblData.position).." was already moved")
					
					end
					
				end
				
			end
			
			-- randomize so that the resources being turned off will appear a certain % of the time
			if not doit then
				
				local chance = Random(1,math.min(doit_value,99))

				-- keep it 
				if chance == doit_value then
					doit = true
				-- delete the resource point from the masterchain
				else
					LOG("*AI DEBUG Removing resource at "..repr(tblData.position))
					ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[i] = nil
				end
			end	
			
			if doit then
				FlattenMapRect(tblData.position[1]-2, tblData.position[3]-2, 4, 4, tblData.position[2])
		
				CreateResourceDeposit( tblData.type, tblData.position[1], tblData.position[2], tblData.position[3],	tblData.size )

				-- fixme: texture names should come from editor
				local albedo, sx, sz, lod
				
				if tblData.type == "Mass" then
					albedo = "/env/common/splats/mass_marker.dds"
					sx = 2
					sz = 2
					lod = 100
					--LOG("*AI DEBUG Creating prop at "..repr(tblData.position))
					CreatePropHPR(
						'/env/common/props/massDeposit01_prop.bp',
						tblData.position[1], tblData.position[2], tblData.position[3],
						Random(0,360), 0, 0
					)
				else
					albedo = "/env/common/splats/hydrocarbon_marker.dds"
					sx = 6
					sz = 6
					lod = 200
					CreatePropHPR(
						'/env/common/props/hydrocarbonDeposit01_prop.bp',
						tblData.position[1], tblData.position[2], tblData.position[3],
						Random(0,360), 0, 0
					)
				end

				CreateSplat(
					tblData.position,           # Position
					0,                          # Heading (rotation)
					albedo,                     # Texture name for albedo
					sx, sz,                     # SizeX/Z
					lod,                        # LOD
					0,                          # Duration (0 == does not expire)
					-1 ,                         # army (-1 == not owned by any single army)
					0
				)
			
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
	
	LOG("*AI DEBUG Created Resources and used "..( (gcinfo() - memstart)*1024 ).." bytes")
	
end

function InitializeArmies()

    local function InitializeSkirmishSystems(self)
	
		-- store which team we're on
		self.Team = ScenarioInfo.ArmySetup[self.Name].Team
    
        -- don't do anything else for a human player
        if self.BrainType == 'Human' then
            return
        end

		--LOG("*AI DEBUG "..self.Nickname.." Initializing Skirmish Systems "..repr(ScenarioInfo))
		--LOG("*AI DEBUG "..self.Nickname.." Initial Brain info is "..repr(self))
		
		-- build table of scout locations and set some starting threat at all enemy locations
		import('/lua/loudutilities.lua').BuildScoutLocations(self)

        -- Create the Condition monitor
        self.ConditionsMonitor = import('/lua/sim/BrainConditionsMonitor.lua').CreateConditionsMonitor(self)

        -- Create the Economy Data structures and start Economy monitor thread
        self:ForkThread1(import('/lua/loudutilities.lua').EconomyMonitor)
		
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
		self.UpgradeIssuedLimit = 2
		self.UpgradeIssuedPeriod = 225

		-- set the base radius according to map size -- affects platoon formation radius and base alert radius
		local mapSizex = ScenarioInfo.size[1]
		local BuilderRadius = math.max(100, (mapSizex/16))	#-- should give a range between 100 and 256+
		local BuilderRadius = math.min(BuilderRadius, 140)	#-- and then limit it to no more than 140
		
		local RallyPointRadius = 49		#-- create automatic rally points at 49 from centre
		
		-- Set the NeedTransports flag -- used when the AI tries to air transport units and cannot find enough transport
		-- this brings factory platoons online to build more (more than standard)
		self.NeedTransports = false
		
		-- Set the flag that notes if an expansion base is being setup -- when an engineer takes on an expansion task, he'll set this flag to true
		-- when he dies or starts building the new base, he'll set it back to false
		-- we use this to keep the AI from doing more than one expansion at a time
		self.BaseExpansionUnderway = false
		
		-- level AI starting locations
		--import('/lua/loudutilities.lua').LevelStartBaseArea(self:GetStartVector3f(), RallyPointRadius )
		
        -- Create the Builder Managers for the MAIN base
        self:AddBuilderManagers(self:GetStartVector3f(), BuilderRadius, 'MAIN', false, RallyPointRadius, true, 'FRONT')
		
		-- turn on the PrimaryLandAttackBase flag for MAIN
		self.BuilderManagers.MAIN.PrimaryLandAttackBase = true
		self.PrimaryLandAttackBase = 'MAIN'
        
        -- Create the Strategy Manager (disabled) from the Sorian AI
        --self.BuilderManagers.MAIN.StrategyManager = StratManager.CreateStrategyManager(self, 'MAIN', self:GetStartVector3f(), 100)
		
        -- create Persistent Pool platoons -- and store the handle on the brain
        -- for isolating transports
        local transportplatoon = self:MakePlatoon('test','none')
		
        transportplatoon:UniquelyNamePlatoon('TransportPool') 
		transportplatoon.BuilderName = 'Transport Pool'

		self.TransportPool = transportplatoon
        
        -- for isolating structures (used by LOUD AI)
        local structurepool = self:MakePlatoon('test','none')
		
        structurepool:UniquelyNamePlatoon('StructurePool')
		structurepool.BuilderName = 'Structure Pool'
		
		self.StructurePool = structurepool
        
        -- for isolating aircraft low on fuel (used by LOUD AI)
        local refuelpool = self:MakePlatoon('test','none')
		
        refuelpool:UniquelyNamePlatoon('RefuelPool')
		refuelpool.BuilderName = 'Refuel Pool'
		
		self.RefuelPool = refuelpool
		
		-- the standard Army Pool
		local armypool = self:GetPlatoonUniquelyNamed('ArmyPool')
		
		armypool:UniquelyNamePlatoon('ArmyPool')
		armypool.BuilderName = 'ArmyPool'
		
		self.ArmyPool = armypool
		

		-- Start the Dead Base Monitor
		self:ForkThread1( import('/lua/loudutilities.lua').DeadBaseMonitor )
		
        -- Start the Enemy Picker
        self:ForkThread1( import('/lua/loudutilities.lua').PickEnemy )
		
		-- Start the Path Generator
		self:ForkThread1( import('/lua/loudutilities.lua').PathGeneratorThread )
		
        -- start PlatoonDistressMonitor
        self:ForkThread1( import('/lua/loudutilities.lua').PlatoonDistressMonitor )

		-- start watching the intel data
		self:ForkThread1( import('/lua/loudutilities.lua').ParseIntelThread )

		-- record the starting unit cap	
		-- caps of 1000+ trigger some conditions
		self.StartingUnitCap = GetArmyUnitCap(self.ArmyIndex)
		
		-- turn on resource sharing
		self:SetResourceSharing(true)
		
		if self.CheatingAI then
			import('/lua/ai/aiutilities.lua').SetupAICheat( self )
		end
		
		local PlayerDiff = (self.NumOpponents or 1)/(self.Players - self.NumOpponents)		
		
		-- if outnumbered increase the number of simultaneous upgrades allowed
		-- and reduce the waiting period by 2 seconds ( about 10% )
		if PlayerDiff > 1.0 then
	
			self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
			self.UpgradeIssuedPeriod = self.UpgradeIssuedPeriod - 20
	
		end

    end

    local tblGroups = {}
    local tblArmy = ListArmies()

    local civOpt = ScenarioInfo.Options.CivilianAlliance

    local bCreateInitial = ShouldCreateInitialArmyUnits()
	
    import('/lua/sim/scenarioutilities.lua').CreateProps()
    import('/lua/sim/scenarioutilities.lua').CreateResources()
	
    for iArmy, strArmy in pairs(tblArmy) do

        local tblData = ScenarioInfo.Env.Scenario.Armies[strArmy]
        local armyIsCiv = ScenarioInfo.ArmySetup[strArmy].Civilian

        tblGroups[ strArmy ] = {}

        if tblData then

            SetArmyEconomy( strArmy, tblData.Economy.mass, tblData.Economy.energy)
			
			-- if this is an AI (but not civilian)
            if GetArmyBrain(strArmy).BrainType == 'AI' and not armyIsCiv then
			
                InitializeSkirmishSystems( GetArmyBrain(strArmy) )
				
				import('/lua/loudutilities.lua').AddCustomUnitSupport(GetArmyBrain(strArmy))
				
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
			
            if wreckageGroup then
			
                local platoonList, tblResult, treeResult = CreatePlatoons(strArmy, wreckageGroup )
				
                for num,unit in tblResult do
                    unit:CreateWreckageProp(0)
                    unit:Destroy()
                end
				
            end

            for iEnemy, strEnemy in pairs(tblArmy) do
			
                local enemyIsCiv = ScenarioInfo.ArmySetup[strEnemy].Civilian

                if iArmy != iEnemy and strArmy != 'NEUTRAL_CIVILIAN' and strEnemy != 'NEUTRAL_CIVILIAN' then
				
                    if (armyIsCiv or enemyIsCiv) and civOpt == 'neutral' then
					
                        SetAlliance( iArmy, iEnemy, 'Neutral')
						
                    else
					
                        SetAlliance( iArmy, iEnemy, 'Enemy')
                    end
					
                elseif strArmy == 'NEUTRAL_CIVILIAN' or strEnemy == 'NEUTRAL_CIVILIAN' then
				
                    SetAlliance( iArmy, iEnemy, 'Neutral')
					
                end
				
            end
			
        end
		
    end

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
            unit:CreateWreckageProp()
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

