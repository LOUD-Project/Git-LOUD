--
-- AIBrain Lua Module
--

	-- Enable LOUD debugging options
	LOG("*AI DEBUG Setting LOUD DEBUG & LOG options ")


    --- ENGINEER and FACTORY DEBUGS ---


    -- AI Engineers will be named according to the Builder they are running 
	ScenarioInfo.NameEngineers = false
	LOG("*AI DEBUG		Name Engineers is "..repr(ScenarioInfo.NameEngineers))

    -- engineers will dialog their decisions to the LOG --
    ScenarioInfo.EngineerDialog = false
    LOG("*AI DEBUG      Report Engineer Dialog is "..repr(ScenarioInfo.EngineerDialog))

    -- Factories will be named according to the builder they are currently running --
	ScenarioInfo.DisplayFactoryBuilds = false
	LOG("*AI DEBUG		Display Factory Builds is "..repr(ScenarioInfo.DisplayFactoryBuilds))


	
	-- ENGINEER, FACTORY and STRUCTURE UNIT UPGRADES --

    
    -- Each ACU will dialog Enhancement data and decisions to the LOG
	ScenarioInfo.ACUEnhanceDialog = false
	LOG("*AI DEBUG		Report  ACU Enhancement Dialog to Log is "..repr(ScenarioInfo.ACUEnhanceDialog))
	
    -- Each SACU will dialog Enhancement data and decisions to the LOG
	ScenarioInfo.SCUEnhanceDialog = false
	LOG("*AI DEBUG		Report  SCU Enhancement Dialog to Log is "..repr(ScenarioInfo.SCUEnhanceDialog))

    -- Each FACTORY will dialog Enhancement data and decisions to the LOG
	ScenarioInfo.FactoryEnhanceDialog = false
	LOG("*AI DEBUG		Report  Factory Enhancement Dialog to Log is "..repr(ScenarioInfo.FactoryEnhanceDialog))

    -- ALL STRUCTURES THAT UPGRADE - will report upgrade data and decisions to the LOG 
	ScenarioInfo.StructureUpgradeDialog = false
	LOG("*AI DEBUG		Report  Structure Upgrade Dialog to Log is "..repr(ScenarioInfo.StructureUpgradeDialog))



	-- ATTACK PLANS and STRENGTH RATIOS

    
    -- AI will display the route and goal of his current attack plan
	ScenarioInfo.DisplayAttackPlans = false
	LOG("*AI DEBUG		Display Attack Plan is "..repr(ScenarioInfo.DisplayAttackPlans))
    
    -- the AttackPlanner will dialog their selection and plotting data and decisions to the LOG
    ScenarioInfo.AttackPlanDialog = false
    LOG("*AI DEBUG      Attack Plan Dialog to log is "..repr(ScenarioInfo.AttackPlanDialog))

    -- the Intel thread will dialog calculated LAND,AIR and NAVAL ratios to the LOG file on each Intel Thread cycle
	ScenarioInfo.ReportRatios = false
	LOG("*AI DEBUG		Report Layer Ratios to Log is "..repr(ScenarioInfo.ReportRatios))



    -- INTEL/THREAT DATA -- MONITORS AND DEBUGS --

    
    -- AI will dialog Intel threat data and decisions to the LOG
    ScenarioInfo.IntelDialog = false
    LOG("*AI DEBUG      Report Intel Dialog is "..repr(ScenarioInfo.IntelDialog))
    
    -- AI will display color coded and relatively sized rings, on the map, for different types of threat
    -- the threats that are displayed (not all are) is controlled in PARSEINTELTHREAD
	ScenarioInfo.DisplayIntelPoints = false
	LOG("*AI DEBUG		Display Intel Points is "..repr(ScenarioInfo.DisplayIntelPoints))


    
    -- BASES AND BASE THREAT MONITORS --

    
    -- Each AI base will appear on the map with it's name - while active
	ScenarioInfo.DisplayBaseNames = false
	LOG("*AI DEBUG		Display Base Names is "..repr(ScenarioInfo.DisplayBaseNames))

    -- Each AI base will dialog its threat monitor data and decisions to the LOG
	ScenarioInfo.BaseMonitorDialog = false
	LOG("*AI DEBUG		Report Base Monitor Dialogs to Log is "..repr(ScenarioInfo.BaseMonitorDialog))

    -- Each AI base will draw a ring indicating the range of the base monitor - each time it checks for threat
	ScenarioInfo.DisplayBaseMonitors = false
	LOG("*AI DEBUG		Display Base Monitors is "..repr(ScenarioInfo.DisplayBaseMonitors))
    
    -- Each AI base will dialog Distress Responses to alerts raised by the base monitor
    ScenarioInfo.BaseDistressResponseDialog = false
    LOG("*AI DEBUG      Report Base Distress Dialogs is "..repr(ScenarioInfo.BaseDistressResponseDialog))

    -- The DeadBaseMonitor will dialog all bases being checked 
    ScenarioInfo.DeadBaseMonitorDialog = false
    LOG("*AI DEBUG      Report DeadBaseMonitor Dialog is "..repr(ScenarioInfo.DeadBaseMonitorDialog))
    
    -- AI will ping the map with the location of alerts raised by the base monitor
	ScenarioInfo.DisplayPingAlerts = false
	LOG("*AI DEBUG		Display Ping Alerts is "..repr(ScenarioInfo.DisplayPingAlerts))


	
    -- BASE PLATOON FORMATION AND PLATOON BEHAVIORS


    -- Each Base will dialog its Platoon Formation data and decisions to the LOG (pretty busy)
	ScenarioInfo.PlatoonDialog = false
	LOG("*AI DEBUG		Report  Platoon Dialog to Log is "..repr(ScenarioInfo.PlatoonDialog))
	
    -- ALL AI units will be named with the platoon (BuilderName) they are in (can be very crowded onscreen)
	ScenarioInfo.DisplayPlatoonMembership = false
	LOG("*AI DEBUG		Display Platoon Membership is "..repr(ScenarioInfo.DisplayPlatoonMembership))
    
    -- AI will display the platoon (Buildername) over the platoon every few seconds (not crowded but must look closely)
	ScenarioInfo.DisplayPlatoonPlans = false
	LOG("*AI DEBUG		Display Platoon Plans is "..repr(ScenarioInfo.DisplayPlatoonPlans))

    -- AI bases and platoons that respond to distress will dialog their data and decisions to the LOG
	ScenarioInfo.DistressResponseDialog = false
	LOG("*AI DEBUG		Report Distress Response Dialogs to Log is "..repr(ScenarioInfo.DistressResponseDialog))

    -- AI platoons that MERGE_INTO or MERGE_WITH will dialog their data and decisions to the LOG
	ScenarioInfo.PlatoonMergeDialog =  false
	LOG("*AI DEBUG		Report Platoon Merge actions to log is "..repr(ScenarioInfo.PlatoonMergeDialog))

    -- TRANSPORT dialogs - report all transport activity to log file (this can be very busy)
	ScenarioInfo.TransportDialog = false
    LOG("*AI DEBUG      Transport Dialogs to Log is "..repr(ScenarioInfo.TransportDialog))
    
    -- PATHFINDING dialogs - report pathfinding failures to log (useful in debugging poorly marked maps and doing threat evaluation debugging)
    ScenarioInfo.PathFindingDialog = false
    LOG("*AI DEBUG      Pathfinding Dialogs to Log is "..repr(ScenarioInfo.PathFindingDialog))



    -- HARDCORE NERD DATA - only for those who really need to dig into the guts of how things work

    
	-- PRIORITY dialogs - Builder priority changes are dialoged to the LOG
	ScenarioInfo.PriorityDialog = false
	LOG("*AI DEBUG		Report Priority Changes to Log is "..repr(ScenarioInfo.PriorityDialog))

    -- INSTANCE COUNT dialogs - Instanced Builder count increase/decrease is dialoged to the LOG (very busy)
    ScenarioInfo.InstanceDialog = false
    LOG("*AI DEBUG      Report Instance Counts to Log is "..repr(ScenarioInfo.InstanceDialog))

	-- UNIT BUFF dialog - show units being buffed and de-buffed (this can be pretty busy)
	ScenarioInfo.BuffDialog = false
	LOG("*AI DEBUG		Buff System Dialogs to Log is "..repr(ScenarioInfo.BuffDialog))
	
	-- Projectile, Shield and Weapon dialogs (VERY COSTLY)
	ScenarioInfo.ProjectileDialog = false
	LOG("*AI DEBUG		Report  Projectile Dialog to Log is "..repr(ScenarioInfo.ProjectileDialog))
	
	ScenarioInfo.ShieldDialog = false
	LOG("*AI DEBUG		Report  Shield Dialog to Log is "..repr(ScenarioInfo.ShieldDialog))
	
	ScenarioInfo.WeaponDialog = false
	LOG("*AI DEBUG		Report  Weapon Dialog to Log is "..repr(ScenarioInfo.WeaponDialog))



local import = import


local SetBaseRallyPoints = import('/lua/loudutilities.lua').SetBaseRallyPoints

local SetPrimaryLandAttackBase = import('/lua/loudutilities.lua').SetPrimaryLandAttackBase
local SetPrimarySeaAttackBase = import('/lua/loudutilities.lua').SetPrimarySeaAttackBase

--LOG('aibrain_methods.__index = ',moho.aibrain_methods.__index,' ',repr(moho.aibrain_methods))

local CreateEngineerManager = import('/lua/sim/EngineerManager.lua').CreateEngineerManager
local CreateFactoryBuilderManager = import('/lua/sim/FactoryBuilderManager.lua').CreateFactoryBuilderManager
local CreatePlatoonFormManager = import('/lua/sim/PlatoonFormManager.lua').CreatePlatoonFormManager

--local SUtils = import('/lua/ai/sorianutilities.lua')
--local StratManager = import('/lua/sim/StrategyManager.lua')

local LOUDINSERT = table.insert
local LOUDSTRING = string.find

local ForkThread = ForkThread
local WaitTicks = coroutine.yield

local GetBlueprint = moho.entity_methods.GetBlueprint
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits

local IsPlaying = false
local CurrentVOPlaying = false

local factions = {'UEF', 'Aeon', 'Cybran', 'Seraphim'}

-- List of AI cheat multipliers to map against per-AI lobby setting
-- Only for backwards compatibility

local aiMults = {
    0.8,
    0.9,
    1.0,
    1.05,
    1.075,
    1.1,
    1.125,
    1.15,
    1.175,
    1.2,
    1.225,
    1.25,
    1.275,
    1.3,
    1.325,
    1.35,
    1.375,
    1.4,
    1.45,
    1.5,
    1.6,
    1.75,
    2.0,
    2.5
}

-- VO Timeout and Replay Durations

local VOReplayTime = {
    OnTransportFull = 1,
    OnUnitCapLimitReached = 60,
    --OnFailedUnitTransfer = 10,
    --OnPlayNoStagingPlatformsVO = 5,
    OnCommanderUnderAttackVO = 20,
    ExperimentalDetected = 75,
    --ExperimentalUnitDestroyed = 5,
    FerryPointSet = 5,
    BaseUnderAttack = 30,
    UnderAttack = 60,
    EnemyForcesDetected = 120,
    NuclearLaunchInitiated = 5,
    NuclearLaunchDetected = 10,
}

local CustomVOReplayTime = {
	--MassCritical = 300,
	--EnergyDangerous = 30,
	--MassDangerous = 90,
	--MassDepleted = 180,
	--EnergyDepleted = 120,
	--UnitStartBeingBuilt = 1,
	--UnitComplete = 1,
	EnemyUnitDetected = 28,
	UnitUnderAttack = 20,
	--UnitHealthAt = 20,
	--UnitDestroyed = 3,
	--ProjectileIntercepted = 1,
	--Defeated = 1,
	}
	
	
Marker = function(mType, mposition)

	return {type=mType, position=mposition}
	
end

function locals()

	local variables = {}
	local idx = 1
	
	while true do
	
		local ln, lv = debug.getlocal(2, idx)
		
		if ln ~= nil then
		
			variables[ln] = lv
			
		else
		
			break
			
		end
		
		idx = 1 + idx
		
	end
	
	return variables
	
end 

function upvalues()

	local variables = {}
	local idx = 1
	local func = debug.getinfo(2, "f").func
	
	while true do 
	
		local ln, lv = debug.getupvalue(func, idx)
		
		if ln ~= nil then
		
			variables[ln] = lv
			
		else
		
			break
			
		end
		
		idx = 1 + idx
		
	end
	
	return variables
	
end 

function SetAIDebug(data)

    if type(data.Active) ~= 'boolean' then
        WARN("SETAIDEBUG: illegal On argument, returning")
        return
    end

    LOG("SETAIDEBUG: Call w/ "..repr(data))

    if data.Switch then
        -- This branch mutates ScenarioInfo directly, so it has to be foolproof.
        -- Validate everything

        local legalVars = {
            'NameEngineers',
            'EngineerDialog',
            'DisplayFactoryBuilds',
            'ACUEnhanceDialog',
            'SCUEnhanceDialog',
            'FactoryEnhanceDialog',
            'StructureUpgradeDialog',
            'DisplayAttackPlans',
            'AttackPlanDialog',
            'ReportRatios',
            'IntelDialog',
            'DisplayIntelPoints',
            'DisplayBaseNames',
            'BaseMonitorDialog',
            'DisplayBaseMonitors',
            'BaseDistressResponseDialog',
            'DeadBaseMonitorDialog',
            'DisplayPingAlerts',
            'PlatoonDialog',
            'DisplayPlatoonMembership',
            'DisplayPlatoonPlans',
            'DistressResponseDialog',
            'PlatoonMergeDialog',
            'TransportDialog',
            'PathFindingDialog',
            'PriorityDialog',
            'InstanceDialog',
            'BuffDialog',
            'ProjectileDialog',
            'ShieldDialog',
            'WeaponDialog',
        }

        if not table.find(legalVars, data.Switch) then
            WARN("SETAIDEBUG: Illegal Var passed, returning")
            return
        end

        ScenarioInfo[data.Switch] = data.Active
        
        LOG("SETAIDEBUG: "..repr(data.Switch).." "..repr(ScenarioInfo[data.Switch]))

        if data.Switch == 'DisplayAttackPlans' then
        
            if data.Active then
            
                local LoudUtils = import('/lua/loudutilities.lua')
                
                for i, brain in ArmyBrains do
                
                    if brain.BrainType == 'AI' and not brain.DrawPlanThread then
                        brain.DrawPlanThread = ForkThread(LoudUtils.DrawPlanNodes, brain)
                    end
                end
                
            else
            
                for i, brain in ArmyBrains do
                
                    if brain.BrainType == 'AI' and brain.DrawPlanThread then
                        KillThread(brain.DrawPlanThread)
                        brain.DrawPlanThread = nil
                    end
                end
            end
        end

        if data.Switch == 'DisplayIntelPoints' then
        
            if data.Active then
            
                local LoudUtils = import('/lua/loudutilities.lua')

                for i, brain in ArmyBrains do
                
                    --LOG("*AI DEBUG "..brain.Nickname.." BrainType is "..repr(brain.BrainType).." Civilian is "..repr(ArmyIsCivilian(brain.ArmyIndex)) )
                
                    if brain.BrainType == 'AI' and not ArmyIsCivilian(brain.ArmyIndex) and not brain.IntelDebugThread then
                        brain.IntelDebugThread = brain:ForkThread(LoudUtils.DrawIntel)
                    end
                end
                
            else
            
                for i, brain in ArmyBrains do
                
                    if brain.BrainType == 'AI' and brain.IntelDebugThread then
                    
                        --LOG("*AI DEBUG "..brain.Nickname.." DrawIntel thread stopped")

                        KillThread(brain.IntelDebugThread)
                        brain.IntelDebugThread = nil
                    end
                end
            end
        end
        
    elseif data.ThreatType then
    
        local LoudUtils = import('/lua/loudutilities.lua')

        -- local table
        -- if data.Table == 1 then
        --     table = LoudUtils.threatColor
        -- else
        --     table = LoudUtils.threatColor2
        -- end

        -- if data.Active then
        --     table[data.ThreatType] = data.Color
        -- else
        --     table[data.ThreatType] = nil
        -- end

        if data.Active then
            LoudUtils.intelChecks[data.ThreatType][6] = true
        else
            LoudUtils.intelChecks[data.ThreatType][6] = false
        end
        
        LOG("SETAIDEBUG: "..repr(LoudUtils.intelChecks[data.ThreatType]))
        -- LOG("SETAIDEBUG: New threatColor tables: ")
        -- LOG("SETAIDEBUG: 1 -> "..repr(LoudUtils.threatColor))
        -- LOG("SETAIDEBUG: 2 -> "..repr(LoudUtils.threatColor2))
    end
end

-- this is the score keeping thread 
-- it rotates thru all the brains and fills in each armies score details
-- the rate of score updating is controlled within
function CollectCurrentScores()

	local ArmyScore = {}
	local Brains = ArmyBrains
	
	local LOUDFLOOR = math.floor
	local LOUDGETN = table.getn
	local ScoreInterval = 50	-- time, in ticks, between score updates

	-- all the scores update every ScoreInterval period so
	-- calculate how much time each brain can utilize of that
	local braindelay = LOUDFLOOR( ScoreInterval / LOUDGETN(Brains) )

	-- Initialize the score data stucture for each brain
    for index = 1, LOUDGETN(Brains) do
	
       ArmyScore[index] = { general = { score = 0, mass = 0, energy = 0, kills = {}, built = {}, lost = {}, currentunits = {}, currentcap = {} },
							units = { cdr = {}, land = {}, air = {}, naval = {}, structures = {}, experimental = {}, },
							resources = { massin = {}, massout = {}, energyin = {}, energyout = {} }
		}

       --## General scores ##
       ArmyScore[index].general.kills.count = 0
       ArmyScore[index].general.kills.mass = 0
       ArmyScore[index].general.kills.energy = 0
	   
       ArmyScore[index].general.built.count = 0
       ArmyScore[index].general.built.mass = 0
       ArmyScore[index].general.built.energy = 0
	   
       ArmyScore[index].general.lost.count = 0
       ArmyScore[index].general.lost.mass = 0
       ArmyScore[index].general.lost.energy = 0
	   
       ArmyScore[index].general.currentunits.count = 0
	   
       ArmyScore[index].general.currentcap.count = 0

       --## unit scores ##
       ArmyScore[index].units.cdr.kills = 0
       ArmyScore[index].units.cdr.built = 0
       ArmyScore[index].units.cdr.lost = 0
	   
       ArmyScore[index].units.land.kills = 0
       ArmyScore[index].units.land.built = 0
       ArmyScore[index].units.land.lost = 0
	   
       ArmyScore[index].units.air.kills = 0
       ArmyScore[index].units.air.built = 0
       ArmyScore[index].units.air.lost = 0
	   
       ArmyScore[index].units.naval.kills = 0
       ArmyScore[index].units.naval.built = 0
       ArmyScore[index].units.naval.lost = 0
	   
       ArmyScore[index].units.structures.kills = 0
       ArmyScore[index].units.structures.built = 0
       ArmyScore[index].units.structures.lost = 0
	   
       ArmyScore[index].units.experimental.kills = 0
       ArmyScore[index].units.experimental.built = 0
       ArmyScore[index].units.experimental.lost = 0

       --## resource scores ##
       ArmyScore[index].resources.massin.total = 0
       ArmyScore[index].resources.massin.rate = 0
	   
       ArmyScore[index].resources.massout.total = 0
       ArmyScore[index].resources.massout.rate = 0
	   
       ArmyScore[index].resources.massover = 0
	   
       ArmyScore[index].resources.energyin.total = 0
       ArmyScore[index].resources.energyin.rate = 0
	   
       ArmyScore[index].resources.energyout.total = 0
       ArmyScore[index].resources.energyout.rate = 0
	   
       ArmyScore[index].resources.energyover = 0
	   
    end

	-- local the main functions
	local GetArmyStat = moho.aibrain_methods.GetArmyStat
	local GetBlueprintStat = moho.aibrain_methods.GetBlueprintStat
	local WaitTicks = coroutine.yield
	
	local massSpent, energySpent, massValueDestroyed, massValueLost, energyValueDestroyed, energyValueLost
	local mass_total, mass_used, mass_total_waste, energy_total, energy_used, energy_total_waste
	local Unit_massSpent, Unit_energySpent
	
	local energyValueCoefficient = 25
	
	local resourceProduction, resource_waste, unitProduction, battle_kills, battle_losses
	local battleResults, score
	
	-- launch the loop that will keep the scores sync'd 
	ForkThread( SyncCurrentScores, Brains, ArmyScore, ScoreInterval )

	-- loop for the entire session
    while true do

        for index, brain in Brains do

			mass_total = GetArmyStat( brain,"Economy_TotalProduced_Mass",0.0).Value
			mass_used = GetArmyStat( brain, "Economy_Output_Mass", 0.0).Value
			mass_total_waste = GetArmyStat( brain,"Economy_AccumExcess_Mass",0.0).Value
			
			energy_total = GetArmyStat( brain,"Economy_TotalProduced_Energy",0.0).Value
			energy_used = GetArmyStat( brain, "Economy_Output_Energy", 0.0).Value
			energy_total_waste = GetArmyStat( brain, "Economy_AccumExcess_Energy",0.0).Value
			
			massSpent = GetArmyStat( brain,"Economy_TotalConsumed_Mass",0.0).Value
			Unit_massSpent = GetArmyStat( brain,"Units_MassValue_Built",0.0).Value
			
			energySpent = GetArmyStat( brain, "Economy_TotalConsumed_Energy",0.0).Value
			Unit_energySpent = GetArmyStat( brain,"Units_EnergyValue_Built",0.0).Value
			
			massValueDestroyed = GetArmyStat( brain,"Enemies_MassValue_Destroyed",0.0).Value
			massValueLost = GetArmyStat( brain,"Units_MassValue_Lost",0.0).Value
			
			energyValueDestroyed = GetArmyStat( brain,"Enemies_EnergyValue_Destroyed",0.0).Value
			energyValueLost = GetArmyStat( brain, "Units_EnergyValue_Lost",0.0).Value

			-- resources account for 20% of score -- discounted by resource waste
			resourceProduction = ( mass_total + (energy_total / energyValueCoefficient) ) * 0.20
			resource_waste = ( mass_total_waste + (energy_total_waste / energyValueCoefficient) ) * 0.20
			
			-- units built account for 35% of score
			unitProduction = ( Unit_massSpent + (Unit_energySpent / energyValueCoefficient) ) * 0.35
			
			-- combat results account for 35% of score
			battle_kills = ( massValueDestroyed + (energyValueDestroyed / energyValueCoefficient) )
			battle_losses = ( massValueLost + (energyValueLost / energyValueCoefficient) )
			
			battleResults = ( battle_kills - battle_losses ) * 0.35

			-- score calculated
			score = resourceProduction - resource_waste + unitProduction + battleResults
			
			if score < 0 then 
				score = 0
			end
			
			ArmyScore[index].general.score = LOUDFLOOR(score)

           ArmyScore[index].general.mass = GetArmyStat( brain, "Economy_TotalProduced_Mass", 0.0).Value
           ArmyScore[index].general.energy = GetArmyStat( brain, "Economy_TotalProduced_Energy", 0.0).Value
           ArmyScore[index].general.currentunits.count = GetArmyStat( brain, "UnitCap_Current", 0.0).Value
           ArmyScore[index].general.currentcap.count = GetArmyStat( brain, "UnitCap_MaxCap", 0.0).Value

           ArmyScore[index].general.kills.count = GetArmyStat( brain, "Enemies_Killed", 0.0).Value
           ArmyScore[index].general.kills.mass = massValueDestroyed
           ArmyScore[index].general.kills.energy = energyValueDestroyed

           ArmyScore[index].general.built.count = GetArmyStat( brain, "Units_History", 0.0).Value
           ArmyScore[index].general.built.mass = GetArmyStat( brain, "Units_MassValue_Built", 0.0).Value
           ArmyScore[index].general.built.energy = GetArmyStat( brain, "Units_EnergyValue_Built", 0.0).Value
           ArmyScore[index].general.lost.count = GetArmyStat( brain, "Units_Killed", 0.0).Value
           ArmyScore[index].general.lost.mass = massValueLost
           ArmyScore[index].general.lost.energy = energyValueLost

           ArmyScore[index].units.land.kills = GetBlueprintStat( brain, "Enemies_Killed", categories.LAND)
           ArmyScore[index].units.land.built = GetBlueprintStat( brain, "Units_History", categories.LAND)
           ArmyScore[index].units.land.lost = GetBlueprintStat( brain, "Units_Killed", categories.LAND)

           ArmyScore[index].units.air.kills = GetBlueprintStat( brain, "Enemies_Killed", categories.AIR)
           ArmyScore[index].units.air.built = GetBlueprintStat( brain, "Units_History", categories.AIR)
           ArmyScore[index].units.air.lost = GetBlueprintStat( brain, "Units_Killed", categories.AIR)
		   
           ArmyScore[index].units.naval.kills = GetBlueprintStat( brain, "Enemies_Killed", categories.NAVAL)
           ArmyScore[index].units.naval.built = GetBlueprintStat( brain, "Units_History", categories.NAVAL)
           ArmyScore[index].units.naval.lost = GetBlueprintStat( brain, "Units_Killed", categories.NAVAL)

           ArmyScore[index].units.cdr.kills = GetBlueprintStat( brain, "Enemies_Killed", categories.COMMAND)
           ArmyScore[index].units.cdr.built = GetBlueprintStat( brain, "Units_History", categories.COMMAND)
           ArmyScore[index].units.cdr.lost = GetBlueprintStat( brain, "Units_Killed", categories.COMMAND)
		   
           ArmyScore[index].units.experimental.kills = GetBlueprintStat( brain, "Enemies_Killed", categories.EXPERIMENTAL)
           ArmyScore[index].units.experimental.built = GetBlueprintStat( brain, "Units_History", categories.EXPERIMENTAL)
           ArmyScore[index].units.experimental.lost = GetBlueprintStat( brain, "Units_Killed", categories.EXPERIMENTAL)

           ArmyScore[index].units.structures.kills = GetBlueprintStat( brain, "Enemies_Killed", categories.STRUCTURE)
           ArmyScore[index].units.structures.built = GetBlueprintStat( brain, "Units_History", categories.STRUCTURE)
           ArmyScore[index].units.structures.lost = GetBlueprintStat( brain, "Units_Killed", categories.STRUCTURE)
		   
           ArmyScore[index].resources.massin.total = GetArmyStat( brain, "Economy_TotalProduced_Mass", 0.0).Value
           ArmyScore[index].resources.massin.rate = GetArmyStat( brain, "Economy_Income_Mass", 0.0).Value
           ArmyScore[index].resources.massout.total = massSpent
           ArmyScore[index].resources.massout.rate = GetArmyStat( brain, "Economy_Output_Mass", 0.0).Value
           ArmyScore[index].resources.massover = GetArmyStat( brain, "Economy_AccumExcess_Mass", 0.0).Value

           ArmyScore[index].resources.energyin.total = GetArmyStat( brain, "Economy_TotalProduced_Energy", 0.0).Value
           ArmyScore[index].resources.energyin.rate = GetArmyStat( brain, "Economy_Income_Energy", 0.0).Value
           ArmyScore[index].resources.energyout.total = energySpent
           ArmyScore[index].resources.energyout.rate = GetArmyStat( brain, "Economy_Output_Energy", 0.0).Value
           ArmyScore[index].resources.energyover = GetArmyStat( brain, "Economy_AccumExcess_Energy", 0.0).Value
		   
           WaitTicks(braindelay)
        end
    end
	
end

-- this function collects all the score data for each player and passes it to the SYNC table
-- the update interval is passed from the calling function CollectCurrentScores
function SyncCurrentScores( Brains, ArmyScore, ScoreInterval )

	local braincount = table.getn(Brains)

    while true do
	
	    WaitTicks(ScoreInterval)  	
		
		for index = 1, braincount do
		
			local A = ArmyScore[index]
		
			Sync.Score[index] = { 	general = { currentunits = { count = 0 }, currentcap = { count = 0 }, kills = { count = 0, mass = 0, energy = 0}, built = { count = 0, mass = 0, energy = 0}, lost = { count = 0, mass = 0, energy = 0} },
									units = { cdr = { kills = 0, built = 0, lost = 0}, land = { kills = 0, built = 0, lost = 0}, air = { kills = 0, built = 0, lost = 0}, naval = { kills = 0, built = 0, lost = 0}, structures = { kills = 0, built = 0, lost = 0}, experimental = { kills = 0, built = 0, lost = 0} },
									resources = { massin = {total = 0, rate = 0}, massout = {total = 0, rate = 0}, massover = 0, energyin = {total = 0, rate = 0}, energyout = { total = 0, rate = 0}, energyover = 0 }
			}

			Sync.Score[index].general.currentunits.count = A.general.currentunits.count
			Sync.Score[index].general.currentcap.count = A.general.currentcap.count

			--## General scores ##
			Sync.Score[index].general.score = A.general.score
			Sync.Score[index].general.mass = A.general.mass
			Sync.Score[index].general.energy = A.general.energy
			
			Sync.Score[index].general.kills.count = A.general.kills.count
			Sync.Score[index].general.kills.mass = A.general.kills.mass
			Sync.Score[index].general.kills.energy = A.general.kills.energy

			Sync.Score[index].general.built.count = A.general.built.count
			Sync.Score[index].general.built.mass = A.general.built.mass
			Sync.Score[index].general.built.energy = A.general.built.energy

			Sync.Score[index].general.lost.count = A.general.lost.count
			Sync.Score[index].general.lost.mass = A.general.lost.mass
			Sync.Score[index].general.lost.energy = A.general.lost.energy

			--## unit scores ##
			Sync.Score[index].units.cdr.kills = A.units.cdr.kills
			Sync.Score[index].units.cdr.built = A.units.cdr.built
			Sync.Score[index].units.cdr.lost = A.units.cdr.lost

			Sync.Score[index].units.land.kills =A.units.land.kills
			Sync.Score[index].units.land.built = A.units.land.built
			Sync.Score[index].units.land.lost = A.units.land.lost

			Sync.Score[index].units.air.kills = A.units.air.kills
			Sync.Score[index].units.air.built = A.units.air.built
			Sync.Score[index].units.air.lost = A.units.air.lost

			Sync.Score[index].units.naval.kills = A.units.naval.kills
			Sync.Score[index].units.naval.built = A.units.naval.built
			Sync.Score[index].units.naval.lost = A.units.naval.lost

			Sync.Score[index].units.structures.kills = A.units.structures.kills
			Sync.Score[index].units.structures.built = A.units.structures.built
			Sync.Score[index].units.structures.lost = A.units.structures.lost
			
			Sync.Score[index].units.experimental.kills = A.units.experimental.kills
			Sync.Score[index].units.experimental.built = A.units.experimental.built
			Sync.Score[index].units.experimental.lost = A.units.experimental.lost

			--## resource scores ##
			Sync.Score[index].resources.massin.total = A.resources.massin.total
			Sync.Score[index].resources.massin.rate = A.resources.massin.rate

			Sync.Score[index].resources.massout.total = A.resources.massout.total
			Sync.Score[index].resources.massout.rate = A.resources.massout.rate
			Sync.Score[index].resources.massover = A.resources.massover

			Sync.Score[index].resources.energyin.total = A.resources.energyin.total
			Sync.Score[index].resources.energyin.rate = A.resources.energyin.rate

			Sync.Score[index].resources.energyout.total = A.resources.energyout.total
			Sync.Score[index].resources.energyout.rate = A.resources.energyout.rate
			Sync.Score[index].resources.energyover = A.resources.energyover
			
			Sync.FullScoreSync = true
			
		end
		
    end
	
end


AIBrain = Class(moho.aibrain_methods) {

    OnCreateHuman = function(self, planName)
	
        self.BrainType = 'Human'		
	
		self.Trash = TrashBag()

		self.ArmyIndex = self:GetArmyIndex()
		
		-- store the faction index (1 = UEF, 2 = Aeon, 3 = Cybran, 4 = Seraphim)
		self.FactionIndex = self:GetFactionIndex()
		
		-- store the faction name ( UEF, Aeon, Cybran, Seraphim )
		self.FactionName = factions[self.FactionIndex]

		self.BuilderManagers = {}		
		self.PingCallbackList = {}
		
        --self:InitializeVO()
		
		VOReplayTime = table.merged(VOReplayTime, CustomVOReplayTime)
		
        if not self.VOTable then
		
            self.VOTable = {}
			
        end

		self.BuilderManagers['MAIN'] = { Position = self:GetStartVector3f() }
		self.BuilderManagers['MAIN'].CountedBase = true
		
    end,

    OnCreateAI = function(self, planName)
	
		self.BrainType = 'AI'		
		
        self.Trash = TrashBag()

		self.ArmyIndex = self:GetArmyIndex()
		
		-- store the faction index (1 = UEF, 2 = Aeon, 3 = Cybran, 4 = Seraphim)
		self.FactionIndex = self:GetFactionIndex()
		
		-- store the faction name ( UEF, Aeon, Cybran, Seraphim )
		self.FactionName = factions[self.FactionIndex]
		
		self.BuilderManagers = {}		
		
		--self.TriggerList = {}
		--self.IntelTriggerList = {}
		
		self.PingCallbackList = {}
        
        -- this is a LOUD data element for storing unpacked
        -- platoon templates
        self.PlatoonTemplates = {}
        
		self.IgnoreArmyCaps = false

        -- all AI are technically 'cheaters' now --
        self.CheatingAI = true

		-- Store the cheat value (ie. 1.1 = 10% cheat)
		local s = ScenarioInfo.ArmySetup[self.Name].Mult
		local m
		if type(s) == "string" then
			m = tonumber(ScenarioInfo.ArmySetup[self.Name].Mult)
		else
			m = aiMults[ScenarioInfo.ArmySetup[self.Name].Mult]
		end
        if m then 
            m = math.max(0.1, m)
            m = math.min(m, 99)
        end
        self.CheatValue = m -- Should never be modified
        
		-- 1 for fixed, 2 for feedback, 3 for time, 4 for both
		self.Adaptive = ScenarioInfo.ArmySetup[self.Name].ACT

        if self.Adaptive == 2 or self.Adaptive == 4 then
            self.FeedbackCheat = 0
        end
        if self.Adaptive == 3 or self.Adaptive == 4 then
            self.TimeCheat = 0
        end
		
        local civilian = false
        
        for name,data in ScenarioInfo.ArmySetup do
		
            if name == self.Name then
			
                civilian = data.Civilian
                
				break
            end
        end

		if not civilian then

			if planName and planName != '' then
			
				self.AIPlansList = import(planName).AIPlansList
		
				self.CurrentPlan = self.AIPlansList[self.FactionIndex][1]
				
			end

			-- go get and set a plan for MAIN
			if self:IsOpponentAIRunning() then
			
				self.CurrentPlan = '/lua/ai/aiarchetype-managerloader.lua'
				self.CurrentPlanScript = import(self.CurrentPlan)
				
				-- start the plan
				ForkThread( self.CurrentPlanScript.ExecutePlan, self )

                -- Subscribe to ACT if .Adaptive dictates such
                import('/lua/loudutilities.lua').SubscribeToACT(self)
			end
		else
        
            -- Civilians are NOT Cheating AI
            self.CheatingAI = false
            
        end
    end,

	OnSpawnPreBuiltUnits = function(self)
	
        local factionIndex = self.FactionIndex
        local resourceStructures = nil
        local initialUnits = {}
        local posX, posY = self:GetArmyStartPos()
        
        --LOG("*AI DEBUG ScenarioInfo is "..repr(ScenarioInfo))
--[[        
        if ScenarioInfo.BOACU_Installed then

            if factionIndex == 1 then
			
                initialUnits = { 'EAL0001', 'ERL0001', 'ESL0001' }
            
            elseif factionIndex == 2 then
			
                initialUnits = { 'ERL0001', 'EEL0001', 'ESL0001' }
            
            elseif factionIndex == 3 then
			
                initialUnits = { 'EAL0001', 'EEL0001', 'ESL0001' }
            
            elseif factionIndex == 4 then
			
                initialUnits = { 'EAL0001', 'ERL0001', 'EEL0001' }
                
            end
        
        end
--]]        
        LOG("*AI DEBUG initialUnits is "..repr(initialUnits))

        if factionIndex == 1 then
		
			resourceStructures = { 'UEB1103', 'UEB1103' }
            
			initialUnits = table.merged(initialUnits,{ 'UEB1101','UEB1101' })
			
        elseif factionIndex == 2 then
		
			resourceStructures = { 'UAB1103', 'UAB1103' }
            
			initialUnits = table.merged(initialUnits,{ 'UAB1101','UAB1101' })
            
			
        elseif factionIndex == 3 then
		
			resourceStructures = { 'URB1103', 'URB1103' }
            
			initialUnits = table.merged(initialUnits,{ 'URB1101','URB1101' })
            
			
		elseif factionIndex == 4 then
		
			resourceStructures = { 'XSB1103', 'XSB1103' }
            
			initialUnits = table.merged(initialUnits,{ 'XSB1101','XSB1101' })
			
        end

        if resourceStructures then
		
    		-- place resource structures down
    		for k, v in resourceStructures do
			
                local unit = self:CreateResourceBuildingNearest(v, posX, posY)
				
                if unit != nil and unit:GetBlueprint().Physics.FlattenSkirt then
				
                    unit:CreateTarmac(true, true, true, false, false)
					
                end
				
				-- AI may have upgrade threads to run
				if self.BrainType != 'Human' then
				
					unit:LaunchUpgradeThread(self)
					
				end
				
    		end
			
    	end

		if initialUnits then
		
    		-- place initial units down
    		for k, v in initialUnits do
			
                local unit = self:CreateUnitNearSpot(v, posX, posY)
				
                if unit != nil and unit:GetBlueprint().Physics.FlattenSkirt then
				
                    unit:CreateTarmac(true, true, true, false, false)
					
                end
				
    		end
			
    	end
		
		self.PreBuilt = true

    end,

    AddPingCallback = function(self, callback, pingType)
	
        if callback and pingType then
		
            LOUDINSERT( self.PingCallbackList, { CallbackFunction = callback, PingType = pingType } )
			
        end
		
    end,

    DoPingCallbacks = function(self, pingData)
	
        for k,v in self.PingCallbackList do
		
            v.CallbackFunction( self, pingData )
			
        end
		
    end,

    ForkThread = function(self, fn, ...)

        local thread = ForkThread(fn, self, unpack(arg))
		
        self.Trash:Add(thread)
		
        return thread
		
    end,
    
    ForkThread1 = function(self, fn)
	
        self.Trash:Add(ForkThread(fn, self))
		
    end,

    OnDestroy = function(self)
	
        if self.BuilderManagers then
		
            self.ConditionsMonitor:Destroy()
			
            for k,v in self.BuilderManagers do
			
				v.EngineerManager:SetEnabled(self,false)
				v.FactoryManager:SetEnabled(self,false)
				v.PlatoonFormManager:SetEnabled(self,false)
                v.FactoryManager:Destroy()
                v.PlatoonFormManager:Destroy()
                v.EngineerManager:Destroy()
                --v.StrategyManager:Destroy()
            end
			
        end
        
        if self.Trash then
		
            self.Trash:Destroy()
			
        end

    end,

    OnDefeat = function(self)
	
		-- this local function will turn over units to allied players
		-- and kill any that are not transferred
        local function KillArmy()
		
			for k,v in ArmyBrains do
			
				-- only transfer to human allies still in game --
				if v.BrainType != 'AI' and ( IsAlly(self.ArmyIndex, v:GetArmyIndex() ) and self.ArmyIndex != v:GetArmyIndex() and not v:IsDefeated()) then
				
					local units = self:GetListOfUnits(categories.ALLUNITS -categories.SUBCOMMANDER - categories.WALL - categories.COMMAND, false)
					
					import('/lua/SimUtils.lua').TransferUnitsOwnership( units, v:GetArmyIndex())
					
				end
				
			end
			
			WaitTicks(5)
			
			local killacu = self:GetListOfUnits(categories.ALLUNITS, false)
			
            for index,unit in killacu do
			
                unit:Kill()
				
            end
			
        end	
		
        SetArmyOutOfGame(self.ArmyIndex)
		
        LOUDINSERT( Sync.GameResult, { self.ArmyIndex, "defeat" } )
		
        --import('/lua/SimUtils.lua').UpdateUnitCap()
        import('/lua/SimPing.lua').OnArmyDefeat(self.ArmyIndex)
       
		if self.BuilderManagers then
			
			-- put in for LOUD AI so that I can clear the BuilderManager for a human player
			if self.BrainType != 'Human' then

				LOG("*AI DEBUG Shutting down AI "..self.Nickname)
				
				self.ConditionsMonitor.Trash:Destroy()
				
				self.ConditionsMonitor:Destroy()
				
				self.ConditionsMonitor = nil
			
				for k,v in self.BuilderManagers do
				
					if ScenarioInfo.DisplayBaseNames or aiBrain.DisplayBaseNames or aiBrain.BuilderManagers[k].MarkerID then
					
						ForkThread( import('/lua/loudutilities.lua').RemoveBaseMarker, self, k, self.BuilderManagers[k].MarkerID)
						
					end
					
					-- remove the dynamic rally points
					import('/lua/loudutilities.lua').RemoveBaseRallyPoints( self, v.BaseName, v.BaseType, v.RallyPointRadius )
				
					v.EngineerManager:SetEnabled(self,false)
					v.FactoryManager:SetEnabled(self,false)
					v.PlatoonFormManager:SetEnabled(self,false)
					
					v.FactoryManager:Destroy()
					v.PlatoonFormManager:Destroy()
					v.EngineerManager:Destroy()
					--v.StrategyManager:Destroy()
					
                    v.PrimaryLandAttackBase = false
					
				end
			
				if self.PathCacheThread then
				
					KillThread(self.PathCacheThread)
					
					if self.PathCache then
					
						self.PathCache = {}
						
					end
					
				end
				
				-- Kill WaveSpawn thread if exists
				if self.WaveThread then

					LOG("*AI DEBUG Kill WaveSpawn Thread")
					
					KillThread(self.WaveThread)

					self.WaveThread = nil

				end

				-- Kill DrawPlanThread if exists
				if self.DrawPlanThread then
					
					KillThread(self.DrawPlanThread)
					
					self.DrawPlanThread = nil
					
				end

				if self.AttackPlanMonitorThread then
				
					KillThread(self.AttackPlanMonitorThread)
					
					self.AttackPlanMonitorThread = nil
					
				end

				self.AttackPlan = nil
				self.EcoData = nil
				self.EnemyData = nil
				self.IL = nil
				self.PathRequests = nil
				
				self:DisbandPlatoon(self.RefuelPool)
				self:DisbandPlatoon(self.StructurePool)
				self:DisbandPlatoon(self.TransportPool)
				
				if self.ArmyPool.AIThread then
				
					KillThread(self.ArmyPool.AIThread)
					
					self.ArmyPool.Trash:Destroy()
					self:DisbandPlatoon(self.ArmyPool)
					
				end
				
				self.ArmyPool = nil
				self.RefuelPool = nil
				self.StructurePool = nil
				self.TransportPool = nil
				self.TransportSlotTable = nil
				
			end

	        ForkThread(KillArmy)

			self.BuilderManagers = nil
			self.CurrentPlanScript = nil
			
			if self.Trash then
			
				self.Trash:Destroy()
				
			end
			
			LOG("*AI DEBUG Shut down complete "..repr(self))
			
        end

	end,
	
    OnVictory = function(self)
	
        LOUDINSERT( Sync.GameResult, { self.ArmyIndex, "victory" } )
		
    end,

    OnDraw = function(self)
	
        LOUDINSERT(Sync.GameResult, { self.ArmyIndex, "draw" })
		
    end,

    IsDefeated = function(self)
	
        return ArmyIsOutOfGame(self.ArmyIndex)
		
    end,

	-- This Sorian function is intended to have the AI respond to 
	-- pings coming from a Human Ally - presently disabled 
	DoAIPing = function(self, pingData)
	
		--local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
		
		--if string.find(per, 'sorian') then
			--if pingData.Type then
				--SUtils.AIHandlePing(self, pingData)
			--end
		--end
		
    end,	

	PlayVOSound = function(self, sound, string, marker)
	
		--play only for my army
		if GetFocusArmy() == self.ArmyIndex then
		
			if CurrentVOPlaying != string then
		
				-- wait for the previous VO to finish
				while IsPlaying do
			
					WaitTicks(8)
				
				end

				-- extract sound and send to UI
				local cue,bank = GetCueBank(sound)

				if not Sync.UnitData.VOs then
			
					Sync.UnitData.VOs = {}
				
				end

				LOUDINSERT(Sync.UnitData.VOs, {Cue=cue, Bank=bank, Text=string, Marker=marker})

				-- wait for end of delay
				local time = VOReplayTime[string] or 30

				IsPlaying = true
				CurrentVOPlaying = string
			
				WaitTicks(60)
				IsPlaying = false
				CurrentVOPlaying = false

				if time - 6 < 1 then
			
					time = 7
				
				end

				WaitTicks((time - 6)*10)
			
				if self.VOTable[string] then
			
					self.VOTable[string] = nil
				
				end
			
			else
				LOG("*AI DEBUG VO "..repr(string).." is already playing")			
			end

		end
		
	end,

    OnTransportFull = function(self)

        if GetFocusArmy() == self.ArmyIndex then

            local warningVoice = Sound { Bank = 'XGG', Cue = 'Computer_TransportIsFull', }

            if self.VOTable and not self.VOTable['OnTransportFull'] then
			
                self.VOTable['OnTransportFull'] = ForkThread(self.PlayVOSound, self, warningVoice, 'OnTransportFull')
				
            end

        end
		
    end,

    OnUnitCapLimitReached = function(self)
	
        if GetFocusArmy() == self.ArmyIndex then

            local warningVoice = nil
            local factionIndex = self.FactionIndex
			
            if factionIndex == 1 then
			
                warningVoice = Sound { Bank = 'COMPUTER_UEF_VO', Cue = 'UEFComputer_CommandCap_01298' }
				
            elseif factionIndex == 2 then
			
                warningVoice = Sound { Bank = 'COMPUTER_AEON_VO', Cue = 'AeonComputer_CommandCap_01298' }
				
            elseif factionIndex == 3 then
			
                warningVoice = Sound { Bank = 'COMPUTER_CYBRAN_VO', Cue = 'CybranComputer_CommandCap_01298' }
				
            end

            if self.VOTable and not self.VOTable['OnUnitCapLimitReached'] then
			
                self.VOTable['OnUnitCapLimitReached'] = ForkThread(self.PlayVOSound, self, warningVoice, 'OnUnitCapLimitReached')
				
            end
			
        end
		
    end,

    OnFailedUnitTransfer = function(self)
	
        if GetFocusArmy() == self.ArmyIndex then

            local warningVoice = Sound { Bank = 'XGG', Cue = 'Computer_Computer_CommandCap_01298',}

            if self.VOTable and not self.VOTable['OnFailedUnitTransfer'] then
			
                self.VOTable['OnFailedUnitTransfer'] = ForkThread(self.PlayVOSound, self, warningVoice, 'OnFailedUnitTransfer')
				
            end
			
        end
		
    end,

    OnPlayNoStagingPlatformsVO = function(self)
	
        if GetFocusArmy() == self.ArmyIndex then

            local Voice = Sound { Bank = 'COMPUTER_UEF_VO', Cue = 'UEFComputer_CommandCap_01298' }

            if self.VOTable and not self.VOTable['OnPlayNoStagingPlatformsVO'] then
			
                self.VOTable['OnPlayNoStagingPlatformsVO'] = ForkThread(self.PlayVOSound, self, Voice, 'OnPlayNoStagingPlatformsVO')
				
            end
			
        end
		
    end,

	EnemyUnitDetected = function(self, sound, position)

		self.VOTable['EnemyUnitDetected'] = ForkThread(self.PlayVOSound, self, sound, 'EnemyUnitDetected', Marker('alertred', position))

	end,

	UnitUnderAttack = function(self, sound, position)
	
		if self.VOTable and not self.VOTable['UnitUnderAttack'] then
		
			self.VOTable['UnitUnderAttack'] = ForkThread(self.PlayVOSound, self, sound, 'UnitUnderAttack', Marker('alertred', position))
			
		end
		
	end,
	
	AllyUnitUnderAttack = function(self, sound, position)
	
		if self.VOTable and not self.VOTable['UnitUnderAttack'] then
		
			self.VOTable['UnitUnderAttack'] = ForkThread(self.PlayVOSound, self, sound, 'UnitUnderAttack', Marker('alertyellow', position))
			
		end
		
	end,
	
    ExperimentalDetected = function(self, sound)
	
		if self.VOTable and not self.VOTable['ExperimentalDetected'] then
		
            self.VOTable['ExperimentalDetected'] = ForkThread(self.PlayVOSound, self, sound, 'ExperimentalDetected')
			
        end
		
    end,

    EnemyForcesDetected = function(self, sound)
	
        if self.VOTable and not self.VOTable['EnemyForcesDetected'] then
		
            self.VOTable['EnemyForcesDetected'] = ForkThread(self.PlayVOSound, self, sound, 'EnemyForcesDetected')

        end
		
    end,

    FerryPointSet = function(self,sound)
	
        if self.VOTable and not self.VOTable['FerryPointSet'] then
		
            self.VOTable['FerryPointSet'] = ForkThread(self.PlayVOSound, self, sound, 'FerryPointSet')
			
        end
		
    end,

    UnderAttack = function(self,sound)
	
        if self.VOTable and not self.VOTable['UnderAttack'] then
		
            self.VOTable['UnderAttack'] = ForkThread(self.PlayVOSound, self, sound, 'UnderAttack')
			
        end
		
    end,
    
    OnPlayCommanderUnderAttackVO = function(self)
	
        if GetFocusArmy() == self:GetArmyIndex() then
		
            local Voice = Sound { Bank = 'XGG', Cue = 'Computer_Computer_Commanders_01314' }

            if self.VOTable and not self.VOTable['OnCommanderUnderAttackVO'] then
			
                self.VOTable['OnCommanderUnderAttackVO'] = ForkThread(self.PlayVOSound, self, Voice, 'OnCommanderUnderAttackVO')
				
            end
			
        end
		
    end,    

    BaseUnderAttack = function(self,sound)
	
        if self.VOTable and not self.VOTable['BaseUnderAttack'] then
		
            self.VOTable['BaseUnderAttack'] = ForkThread(self.PlayVOSound, self, sound, 'BaseUnderAttack')
			
        end
		
    end,

    NuclearLaunchDetected = function(self, sound)
	
		if GetFocusArmy() == self:GetArmyIndex() then
		
			local Voice = Sound { Bank = 'XGG',	Cue = 'Computer_Computer_MissileLaunch_01351' }

			if self.VOTable and not self.VOTable['NuclearLaunchDetected'] then
			
				self.VOTable['NuclearLaunchDetected'] = ForkThread(self.PlayVOSound, self, Voice, 'NuclearLaunchDetected')
				
			end
			
        end
		
    end,

    ExperimentalUnitDestroyed = function(self,sound)
	
        if self.VOTable and not self.VOTable['ExperimentalUnitDestroyed'] then
		
            self.VOTable['ExperimentalUnitDestroyed'] = ForkThread(self.PlayVOSound, self, sound, 'ExperimentalUnitDestroyed')
			
		end
		
    end,

    AddBuilderManagers = function(self, position, radius, baseName, useCenter, rallypointradius, countedbase, rallypointorientation )
	
		local basetype = "Land"
	
		-- this insures that the position stored for each manager has all 3 components
		position[2] = GetTerrainHeight( position[1], position[3] )
		
		-- gets the water surface as opposed to seabed for naval positions
		-- this allows us to do unique things for either Land or Naval bases
        if GetSurfaceHeight( position[1], position[3] ) > position[2] then
		
            position[2] = GetSurfaceHeight( position[1], position[3] )
			
			basetype = "Sea"
        end

		--LOG("*AI DEBUG "..self.Nickname.." Setting up Managers for "..repr(baseName).." counted is "..repr(countedbase))
		
		-- add the buildermanager record to this brain
        self.BuilderManagers[baseName] = {
		
			BaseName = baseName,
			BaseType = basetype,
            
            -- The CountedBase flag indicates if this base is Production Base(counted)
			CountedBase = countedbase,
			
            -- The nofactorycount value increases every 25 seconds when there are no ENGINEERS OR FACTORIES at a 'counted'(production base)
            -- This is NOT used for 'non-counted' bases ( all forms of DP) - which only die when ALL structures are destroyed --
            
			-- we set it to 2 so if the initial structures don't last we'll kill the base in about 3 minutes 
            -- otherwise a production base will last upto 4 minutes afetr all ENGINEERS & FACTORIES are destroyed
            -- in the hope that another engineer will arrive to continue the base operations
            nofactorycount = 2,						-- keeps track of how many sequential DeadBaseMonitor checks reported 'no factories'
			
            Position = table.copy(position),		-- stores the location of this base for quick reference
			
            PrimaryLandAttackBase = false,				-- a new base is never the primary until assigned
			PrimarySeaAttackBase = false,
			
			RallyPointRadius = rallypointradius or 50,
			
			Radius = radius,
		
			-- setup the 3 builders
            EngineerManager = CreateEngineerManager(self, baseName, position, radius),
            FactoryManager = CreateFactoryBuilderManager(self, baseName, position, basetype),
            PlatoonFormManager = CreatePlatoonFormManager(self, baseName, position, radius),
			
        }
        
		-- increment the total number of bases used by this brain
		self.NumBases = self.NumBases + 1
        
        -- increment the base counter for production bases (those that have factories)
		if countedbase then
		
			if basetype == "Sea" then	
				self.NumBasesNaval = self.NumBasesNaval + 1
			else
				self.NumBasesLand = self.NumBasesLand + 1
			end

		end

		-- this call will calculate the Rally Point positions for this base
		-- we do it here (just after creating the BuilderManagers record) since it relies upon data from within that table (as opposed to doing it during it's creation)
		self.BuilderManagers[baseName].RallyPoints = SetBaseRallyPoints( self, baseName, basetype, rallypointradius, rallypointorientation )
		
		-- start the BaseMonitor process for this base
		self.BuilderManagers[baseName].EngineerManager:BaseMonitorSetup( self )
		
        -- check if we need to assign new primary attack bases
		SetPrimaryLandAttackBase(self)
		SetPrimarySeaAttackBase(self)
    end,

    GetStartVector3f = function(self)
	
        local startX, startZ = self:GetArmyStartPos()

        return { startX, GetTerrainHeight( startX, startZ ), startZ }
    end,

    AbandonedByPlayer = function(self)
	
		LOG("*AI DEBUG Abandoned by Player "..self.Nickname)
		
        if not IsGameOver() then
		
            self:OnDefeat()
			
        end
		
    end,

	RebuildTable = function(self, oldtable)
	
		local temptable = {}
		local LOUDINSERT = table.insert
		local type = type
		
		for k,v in oldtable do
		
			if v != nil then
			
				if type(k) == 'string' then
				
					temptable[k] = v
					
				else
				
					LOUDINSERT(temptable, v)
					
				end
				
			end
			
		end
		
		return temptable
		
	end,

	OnIntelChange = function(self, blip, reconType, val)
	
		--LOG("*AI DEBUG "..self.Nickname.." OnIntelChange for "..repr(reconType).." blip is "..repr(blip).." val is "..repr(val))
		
    end,

    TotalCheat = function(self)
        return self.CheatValue + (self.FeedbackCheat or 0) + (self.TimeCheat or 0)
    end

}

--[[

    EvaluateAIPlanList = function(self)
	
		local AIPlansList =	{
			-- EARTH Faction Plans
			{ '/lua/ai/aiarchetype-managerloader.lua', },
			-- AEON Faction Plans
			{ '/lua/ai/aiarchetype-managerloader.lua', },
			-- CYBRAN Faction Plans
			{ '/lua/ai/aiarchetype-managerloader.lua', },
			-- SERAPHIM Faction Plans
			{ '/lua/ai/aiarchetype-managerloader.lua', },
		}

        if self:IsOpponentAIRunning() then

            local bestPlan = nil
            local bestValue = 0
            --for i,u in AIPlansList[self.FactionIndex] do
				-- gets the best Starting Base Plan
                --local value = self:EvaluatePlan(u)
				local value = import('/lua/ai/aiarchetype-managerloader.lua').EvaluatePlan(self)
                if value > bestValue then
                    bestPlan = '/lua/ai/aiarchetype-managerloader.lua'	--u
                    bestValue = value
                end
            --end

            if bestPlan then
				self.CurrentPlan = bestPlan
                local bPlan = import(bestPlan)
                if bPlan != self.CurrentPlanScript then
                    self.CurrentPlanScript = import(bestPlan)
                end
            end
		end
		self.AIPlansList = nil
    end,
    
    EvaluateAIThread = function(self)
		LOG("*AI DEBUG EvaluateAIThread for "..self.Nickname)
		
        local personality = self:GetPersonality()
        local factionIndex = self.FactionIndex
        
        while self.ConstantEval do
            self:EvaluateAIPlanList()
            local delay = personality:AdjustDelay(100, 2)
            WaitTicks(delay)
				end
		if not self.ConstantEval then
			self:EvaluateAIPlanList()
			end
    end,

    EvaluatePlan = function(self,  planName )
        local plan = import(planName)
        if plan then
            return plan.EvaluatePlan(self)
        else
            LOG('*WARNING: TRIED TO IMPORT PLAN NAME ', repr(planName), ' BUT IT ERRORED OUT IN THE AI BRAIN.')
            return 0
		end
    end,

    ExecuteAIThread = function(self)
	
        local personality = self:GetPersonality()

        local delay = personality:AdjustDelay(20, 4)
        WaitTicks(delay)
    end,

    ExecutePlan = function(self)
        self.CurrentPlanScript.ExecutePlan(self)
    end,
    GetEngineerManagerUnitsBeingBuilt = function(self, category)
        local unitCount = 0
        for k,v in self.BuilderManagers do
            unitCount = unitCount + v.EngineerManager:GetNumCategoryBeingBuilt( category, categories.ALLUNITS )
		end
        return unitCount
	end,

    GetManagerCount = function(self, Type)

        local count = 0
		
        for k,v in self.BuilderManagers do
            if Type then
				#-- count any starting areas but EXCLUDE the MAIN base
                if Type == 'Start Location' and not ( (LOUDSTRING(k, 'ARMY_')) or (LOUDSTRING(k, 'MAIN')) ) then
                    continue
				#-- count Naval Areas
                elseif Type == 'Naval Area' and not ( LOUDSTRING(k, 'Naval Area') ) then
                    continue
				#-- count Expansion Areas
                elseif Type == 'Expansion Area' and not ( (LOUDSTRING(k,'Expansion Area')) or (LOUDSTRING(k, 'EXPANSION_AREA')) ) then
                    continue
                end
            end
        
            if v.EngineerManager:GetNumCategoryUnits(categories.ENGINEER) < 1 and v.FactoryManager:GetNumCategoryFactories(categories.FACTORY) < 1 then
                continue
            end
            
            count = count + 1
        end
        return count
    end,

    GetFactoriesBeingBuilt = function(self)
        local unitCount = 0
        local LOUDGETN = table.getn
		
        #-- Units queued up
        for k,v in self.BuilderManagers do
            unitCount = unitCount + LOUDGETN( v.EngineerManager:GetEngineersQueued( 'T1LandFactory' ) )
        end
        return unitCount
    end,

    #-----------------------------------------------------
    # In this function we get our 'strength' and compare
    # it to our allies (if we have any).  If our strength
    # is less than our allies - then we return the current
    # enemy of our ally - note: this doesn't actually switch
    # your target - just gives you the value of your allies
    # current enemy.
	# I've since discovered that the GetHighestThreatPosition
	# will only return values for enemies - not allies so
	# this function simply does NOT work
    #------------------------------------------------------
    GetAllianceEnemy = function(self, armyStrengthTable, mystrength, myenemy)
	
        local result = false
        
        local pos, mystrength = self:GetHighestThreatPosition( 2, true, 'Structures', self:GetArmyIndex() )
		
		LOG("*AI DEBUG GetAllianceEnemy mystrength is "..repr(pos).." - "..mystrength)
        
        for k,v in armyStrengthTable do
        
            -- it's an enemy, ignore
            if v.Enemy then
                continue
            end
            
            -- Ally too weak
			LOG("*AI DEBUG GetAllianceEnemy Ally strength is "..v.Strength)
			
            if v.Strength < mystrength then
                continue
            end
            
            -- If the brain has an enemy, it's our new enemy
            local enemy = v.Brain:GetCurrentEnemy()
			
            if enemy and not enemy:IsDefeated() and v.Strength > highStrength then
			
                highStrength = v.Strength
                result = v.Brain:GetCurrentEnemy()
				
            end
        end
        
        return result
    end,

    IgnoreArmyUnitCap = function(self, val)
        self.IgnoreArmyCaps = val
        SetIgnoreArmyCap(self, val)
    end,

    InitializeEconomyState = function(self)
    end,
	
    --------- System for playing VOs to the Player ----------
    InitializeVO = function(self)
	
		VOReplayTime = table.merged(VOReplayTime, CustomVOReplayTime)
        if not self.VOTable then
            self.VOTable = {}
        end
    end,

    ImportScenarioArmyPlans = function(self, planName)
	
        if planName and planName != '' then
            return import(planName).AIPlansList
        else
            return nil
        end
    end,


    -- Called when recon data changes for enemy units (e.g. A unit comes into line of sight)
    -- Params
    --   blip: the unit (could be fake) in question
    --   type: 'LOSNow', 'Radar', 'Sonar', or 'Omni'
    --   val: true or false
    -- calls callback function with blip it saw.

    OnIntelChange = function(self, blip, reconType, val)

		function GetSkirtRect(blip)
			local x, y, z = unpack(blip:GetPosition())
			local x0,z0,x1,z1 = GetBlipSkirtRect(blip)
			x0,z0,x1,z1 = math.floor(x0),math.floor(z0),math.ceil(x1),math.ceil(z1)
			return x0, z0, x1-x0, z1-z0
		end

		function GetBlipSkirtRect(blip)
			local bp = blip:GetBlueprint()
			local x, y, z = unpack(blip:GetPosition())
			local fx = (x - bp.Footprint.SizeX*.5)
			local fz = (z - bp.Footprint.SizeZ*.5)
			local sx = fx + bp.Physics.SkirtOffsetX
			local sz = fz + bp.Physics.SkirtOffsetZ
			return sx, sz, sx+bp.Physics.SkirtSizeX, sz+bp.Physics.SkirtSizeZ
		end
	
		function ClearIntel(self, blip, reconType)
			local minX, minZ, maxX, maxZ = GetSkirtRect(blip)
			FlushIntelInRect(minX, minZ, maxX, maxZ)
		end
		
		local blipId = blip:GetEntityId()
	
		-LOG("*AI DEBUG "..self.Nickname.." reports "..repr(blipId).." "..repr(GetBlueprint(blip).Description).." as "..repr(reconType).." with value "..repr(val))
        
        if LOUDGETN(self.IntelTriggerList) > 0 then
		
			LOG("*AI DEBUG OnIntelChange to "..repr(reconType).." for "..repr(val))
			local LOUDENTITY = EntityCategoryContains
			local GetAIBrain = moho.entity_methods.GetAIBrain
			local GetBlueprint = moho.entity_methods.GetBlueprint
			local GetSource = moho.blip_methods.GetSource
		
            for k, v in self.IntelTriggerList do
                if LOUDENTITY(v.Category, GetBlueprint(blip).BlueprintId ) and v.Type == reconType and v.Value == val then
                    
                    if ( not v.Blip or v.Blip == GetSource(blip) ) and v.TargetAIBrain == GetAIBrain(blip) then
                        v.CallbackFunction(blip)
                    
                        if v.OnceOnly then
                            self.IntelTriggerList[k] = nil
                        end
                    end
                    
                end
            end
			
        end
		

		
		if reconType !='Omni' and blipId.InCloakField then
			LOG("*AI DEBUG Unit in cloak")
			ClearIntel(self, blip, reconType)
			
		end
		
    end,
	
    OnStatsTrigger = function(self, triggerName)
		LOG("*AI DEBUG "..self.Nickname.." OnStatsTrigger "..repr(triggerName))
		local LOUDREMOVE = table.remove
        for k, v in self.TriggerList do
            if v.Name == triggerName then
                if v.CallingObject then
                    if not v.CallingObject:BeenDestroyed() then
                        v.CallbackFunction(v.CallingObject)
                    end
                else
                    v.CallbackFunction(self)
                end
                LOUDREMOVE(self.TriggerList, k)
            end
        end
    end,
    PlayVOSound = function(self, sound, string)
		PlayVOSound(self, sound, string, nil)
    end,
    SetConstantEvaluate = function(self, eval)
        if eval == true and self.ConstantEval == false then
            self.ConstantEval = eval
            ForkThread1(self.EvaluateAIThread, self )
        end
        self.ConstantEval = eval
    end,
	T4ThreatMonitorTimeout = function(self, threattypes)
		WaitTicks(1800)
		for k,v in threattypes do
			self.T4ThreatFound[v] = false
		end
	end,
--    INTEL TRIGGER SPEC
--    {
--        CallbackFunction = <function>,
--        Type = 'LOS'/'Radar'/'Sonar'/'Omni',
--        Blip = true/false,
--        Value = true/false,
--        Category: blip category to match
--        OnceOnly: fire onceonly
--        TargetAIBrain: AI Brain of the army you want it to trigger off of.
--    },
    SetupArmyIntelTrigger = function(self, triggerSpec)
        LOUDINSERT(self.IntelTriggerList, triggerSpec)
    end,
--]]