--
-- AIBrain Lua Module
--
    
    --LOG("*AI DEBUG ScenarioInfo is "..repr(ScenarioInfo.Options) )
    
	-- Enable LOUD debugging options
	LOG("*AI DEBUG Setting LOUD DEBUG & LOG options ")

    -- ENGINEER and FACTORY DEBUGS ---

    -- AI Engineers will be named according to the Builder they are running 
	ScenarioInfo.NameEngineers = false
	LOG("*AI DEBUG      Name Engineers is "..repr(ScenarioInfo.NameEngineers))

    -- engineers will dialog their decisions to the LOG --
    ScenarioInfo.EngineerDialog = false
    LOG("*AI DEBUG      Report Engineer Dialog is "..repr(ScenarioInfo.EngineerDialog))

    -- Factories will be named according to the builder they are currently running --
	ScenarioInfo.DisplayFactoryBuilds = false
	LOG("*AI DEBUG      Display Factory Builds is "..repr(ScenarioInfo.DisplayFactoryBuilds))


	
	-- ENGINEER, FACTORY and STRUCTURE UNIT UPGRADES --

    
    -- Each ACU will dialog Enhancement data and decisions to the LOG
	ScenarioInfo.ACUEnhanceDialog = false
	LOG("*AI DEBUG      Report  ACU Enhancement Dialog to Log is "..repr(ScenarioInfo.ACUEnhanceDialog))
	
    -- Each SACU will dialog Enhancement data and decisions to the LOG
	ScenarioInfo.SCUEnhanceDialog = false
	LOG("*AI DEBUG      Report  SCU Enhancement Dialog to Log is "..repr(ScenarioInfo.SCUEnhanceDialog))

    -- Each FACTORY will dialog Enhancement data and decisions to the LOG
	ScenarioInfo.FactoryEnhanceDialog = false
	LOG("*AI DEBUG      Report  Factory Enhancement Dialog to Log is "..repr(ScenarioInfo.FactoryEnhanceDialog))

    -- ALL STRUCTURES THAT UPGRADE - will report upgrade data and decisions to the LOG 
	ScenarioInfo.StructureUpgradeDialog = false
	LOG("*AI DEBUG      Report  Structure Upgrade Dialog to Log is "..repr(ScenarioInfo.StructureUpgradeDialog))



	-- ATTACK PLANS and STRENGTH RATIOS

    
    -- AI will display the route and goal of his current attack plan
	ScenarioInfo.DisplayAttackPlans = false
	LOG("*AI DEBUG      Display Attack Plan is "..repr(ScenarioInfo.DisplayAttackPlans))
    
    -- the AttackPlanner will dialog their selection and plotting data and decisions to the LOG
    ScenarioInfo.AttackPlanDialog = false
    LOG("*AI DEBUG      Attack Plan Dialog to log is "..repr(ScenarioInfo.AttackPlanDialog))

    -- the Intel thread will dialog calculated LAND,AIR and NAVAL ratios to the LOG file on each Intel Thread cycle
	ScenarioInfo.ReportRatios = false
	LOG("*AI DEBUG      Report Layer Ratios to Log is "..repr(ScenarioInfo.ReportRatios))



    -- INTEL/THREAT DATA -- MONITORS AND DEBUGS --

    
    -- AI will dialog Intel threat data and decisions to the LOG
    ScenarioInfo.IntelDialog = false
    LOG("*AI DEBUG      Report Intel Dialog is "..repr(ScenarioInfo.IntelDialog))
    
    -- AI will display color coded and relatively sized rings, on the map, for different types of threat
    -- the threats that are displayed (not all are) is controlled in PARSEINTELTHREAD
	ScenarioInfo.DisplayIntelPoints = false
	LOG("*AI DEBUG      Display Intel Points is "..repr(ScenarioInfo.DisplayIntelPoints))


    
    -- BASES AND BASE THREAT MONITORS --

    
    -- Each AI base will appear on the map with it's name - while active
	ScenarioInfo.DisplayBaseNames = false
	LOG("*AI DEBUG      Display Base Names is "..repr(ScenarioInfo.DisplayBaseNames))

    -- Each AI base will dialog its threat monitor data and decisions to the LOG
	ScenarioInfo.BaseMonitorDialog = false
	LOG("*AI DEBUG      Report Base Monitor Dialogs to Log is "..repr(ScenarioInfo.BaseMonitorDialog))

    -- Each AI base will draw a ring indicating the range of the base monitor - each time it checks for threat
	ScenarioInfo.DisplayBaseMonitors = false
	LOG("*AI DEBUG      Display Base Monitors is "..repr(ScenarioInfo.DisplayBaseMonitors))
    
    -- Each AI base will dialog Distress Responses to alerts raised by the base monitor
    ScenarioInfo.BaseDistressResponseDialog = false
    LOG("*AI DEBUG      Report Base Distress Dialogs is "..repr(ScenarioInfo.BaseDistressResponseDialog))

    -- The DeadBaseMonitor will dialog all bases being checked 
    ScenarioInfo.DeadBaseMonitorDialog = false
    LOG("*AI DEBUG      Report DeadBaseMonitor Dialog is "..repr(ScenarioInfo.DeadBaseMonitorDialog))
    
    -- AI will ping the map with the location of alerts raised by the base monitor
	ScenarioInfo.DisplayPingAlerts = false
	LOG("*AI DEBUG      Display Ping Alerts is "..repr(ScenarioInfo.DisplayPingAlerts))


	
    -- BASE PLATOON FORMATION AND PLATOON BEHAVIORS


    -- Each Base will dialog its Platoon Formation data and decisions to the LOG (pretty busy)
	ScenarioInfo.PlatoonDialog = false
	LOG("*AI DEBUG      Report  Platoon Dialog to Log is "..repr(ScenarioInfo.PlatoonDialog))
	
    -- ALL AI units will be named with the platoon (BuilderName) they are in (can be very crowded onscreen)
	ScenarioInfo.DisplayPlatoonMembership = false
	LOG("*AI DEBUG      Display Platoon Membership is "..repr(ScenarioInfo.DisplayPlatoonMembership))
    
    -- AI will display the platoon (Buildername) over the platoon every few seconds (not crowded but must look closely)
	ScenarioInfo.DisplayPlatoonPlans = false
	LOG("*AI DEBUG      Display Platoon Plans is "..repr(ScenarioInfo.DisplayPlatoonPlans))

    -- AI bases and platoons that respond to distress will dialog their data and decisions to the LOG
	ScenarioInfo.DistressResponseDialog = false
	LOG("*AI DEBUG      Report Distress Response Dialogs to Log is "..repr(ScenarioInfo.DistressResponseDialog))

    -- AI platoons that MERGE_INTO or MERGE_WITH will dialog their data and decisions to the LOG
	ScenarioInfo.PlatoonMergeDialog = false
	LOG("*AI DEBUG      Report Platoon Merge actions to log is "..repr(ScenarioInfo.PlatoonMergeDialog))

    -- TRANSPORT dialogs - report all transport activity to log file (this can be very busy)
	ScenarioInfo.TransportDialog = false
    LOG("*AI DEBUG      Transport Dialogs to Log is "..repr(ScenarioInfo.TransportDialog))
    
    -- PATHFINDING dialogs - report pathfinding failures to log (useful in debugging poorly marked maps and doing threat evaluation debugging)
    ScenarioInfo.PathFindingDialog = false
    LOG("*AI DEBUG      Pathfinding Dialogs to Log is "..repr(ScenarioInfo.PathFindingDialog))



    -- HARDCORE NERD DATA - only for those who really need to dig into the guts of how things work

    -- BEHAVIOR DIALOGS --

    -- follows the decision process of the AMPHIBFORCEAILOUD behavior (for LAND & AMPHIB only at this time)
    ScenarioInfo.AmphibForceDialog = false
    LOG("*AI DEBUG      AmphibForce Behavior Dialog is "..repr(ScenarioInfo.AmphibForceDialog))

    -- follows the decision process of the GUARDPOINT behavior (for LAND & AMPHIB only at this time)
    ScenarioInfo.GuardPointDialog = false
    LOG("*AI DEBUG      GuardPoint Behavior Dialog is "..repr(ScenarioInfo.GuardPointDialog))

    -- follows the decision process of the LANDFORCEAILOUD behavior (for LAND & AMPHIB only at this time)
    ScenarioInfo.LandForceDialog = false
    LOG("*AI DEBUG      LandForce Behavior Dialog is "..repr(ScenarioInfo.LandForceDialog))

    -- follows the decision process of NAVALFORCEAI behavior
    ScenarioInfo.NavalForceDialog = false
    LOG("*AI DEBUG      NavalForce Behavior Dialog is "..repr(ScenarioInfo.NavalForceDialog))    

    ScenarioInfo.NavalBombardDialog = false
    LOG("*AI DEBUG      NavalForce Bombardment Dialog is "..repr(ScenarioInfo.NavalBombardDialog))    
    
    ScenarioInfo.NukeDialog = false
    LOG("*AI DEBUG      Report  Nuke Dialog to Log is "..repr(ScenarioInfo.NukeDialog))



	-- BUFF dialog - show units being buffed and de-buffed (this can be pretty busy)
    -- this allows you to see the buff activity of things like adjacency, veteran, effect fields - when they are applied - and when they are removed
	ScenarioInfo.BuffDialog = false
	LOG("*AI DEBUG      Buff System Dialogs to Log is "..repr(ScenarioInfo.BuffDialog))
    
    -- INSTANCE COUNT dialogs - Instanced Builder count increase/decrease is dialoged to the LOG (very busy)
    -- this allows you to watch your instance count allocations - and see those that get filled up - or are barely used
    ScenarioInfo.InstanceDialog = false
    LOG("*AI DEBUG      Report Instance Counts to Log is "..repr(ScenarioInfo.InstanceDialog))

	-- PRIORITY dialogs - Builder priority changes are dialoged to the LOG - this will also report
    -- all the builders, at a base, in sorted order - for checking priority sequence
	ScenarioInfo.PriorityDialog = false
	LOG("*AI DEBUG      Report Priority Changes to Log is "..repr(ScenarioInfo.PriorityDialog))
	
	-- Projectile, Shield, Weapon and Nuke dialogs (VERY COSTLY)
    -- this allows you to see all kinds of details about the creation of, impacts caused by, projectiles, shields and weapons
    -- each has it's own switch here
    
	ScenarioInfo.ProjectileDialog = false
	LOG("*AI DEBUG      Report  Projectile Dialog to Log is "..repr(ScenarioInfo.ProjectileDialog))

    ScenarioInfo.ProjectileTrackingDialog = false
	LOG("*AI DEBUG      Report  Projectile Tracking Dialog to Log is "..repr(ScenarioInfo.ProjectileTrackingDialog))    

	ScenarioInfo.ShieldDialog = false
	LOG("*AI DEBUG      Report  Shield Dialog to Log is "..repr(ScenarioInfo.ShieldDialog))
	
	ScenarioInfo.WeaponDialog = false
	LOG("*AI DEBUG      Report  Weapon Dialog to Log is "..repr(ScenarioInfo.WeaponDialog))
    
    ScenarioInfo.WeaponStateDialog = false
    LOG("*AI DEBUG      Report  Weapon State Dialog to Log is "..repr(ScenarioInfo.WeaponStateDialog))


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

local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDSTRING = string.find

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local unpack = unpack

local ForkThread = ForkThread
local WaitTicks = coroutine.yield

local GetBlueprint = moho.entity_methods.GetBlueprint
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GetTerrainHeight = GetTerrainHeight

local IsPlaying = false
local CurrentVOPlaying = false

local factions = {'UEF', 'Aeon', 'Cybran', 'Seraphim'}

-- List of AI cheat multipliers to map against per-AI lobby setting
-- Only for backwards compatibility

--[[
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
--]]

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


-- this function will bring debug switch settings into the SIM from the UI
function SetAIDebug(data)

    if type(data.Active) ~= 'boolean' then
        WARN("SETAIDEBUG: illegal On argument, returning")
        return
    end
    
    LOG("*AI DEBUG SETAIDEBUG data is "..repr(data))

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

            'DisplayBaseNames',
            'BaseMonitorDialog',
            'DisplayBaseMonitors',
            'BaseDistressResponseDialog',
            'DeadBaseMonitorDialog',
            'DisplayPingAlerts',
            
            'DisplayAttackPlans',
            'AttackPlanDialog',
            'ReportRatios',

            'IntelDialog',
            'DisplayIntelPoints',

            'PlatoonDialog',
            'DisplayPlatoonMembership',
            'DisplayPlatoonPlans',
            'DistressResponseDialog',
            'PlatoonMergeDialog',
            'TransportDialog',
            'PathFindingDialog',

            'AmphibForceDialog',
            'GuardPointDialog',
            'LandForceDialog',
            'NavalForceDialog',
            'NavalBombardDialog',
            'NukeDialog',

            'BuffDialog',
            'InstanceDialog',
            'PriorityDialog',
            'ProjectileDialog',
            'ProjectileTrackingDialog',
            'ShieldDialog',
            'WeaponDialog',
            'WeaponStateDialog',
        }

        if not table.find(legalVars, data.Switch) then
            WARN("SETAIDEBUG: Illegal Var passed, returning")
            return
        end

        ScenarioInfo[data.Switch] = data.Active

        if data.Switch == 'DisplayAttackPlans' then
        
            local BRAINS = ArmyBrains
        
            if data.Active then
            
                local LoudUtils = import('/lua/loudutilities.lua')
                
                for i, brain in BRAINS do
                
                    if brain.BrainType == 'AI' and not brain.DrawPlanThread then
                        brain.DrawPlanThread = ForkThread(LoudUtils.DrawPlanNodes, brain)
                    end
                end
                
            else
            
                for i, brain in BRAINS do
                
                    if brain.BrainType == 'AI' and brain.DrawPlanThread then
                        KillThread(brain.DrawPlanThread)
                        brain.DrawPlanThread = nil
                    end
                end
            end
        end

        if data.Switch == 'DisplayIntelPoints' then
        
            local BRAINS = ArmyBrains
        
            if data.Active then
            
                local LoudUtils = import('/lua/loudutilities.lua')

                for i, brain in BRAINS do
                
                    LOG("*AI DEBUG "..brain.Nickname.." BrainType is "..repr(brain.BrainType).." Civilian is "..repr(ArmyIsCivilian(brain.ArmyIndex)) )
                
                    if brain.BrainType == 'AI' and not ArmyIsCivilian(brain.ArmyIndex) and not brain.IntelDebugThread then
                        brain.IntelDebugThread = ForkThread( LoudUtils.DrawIntel, brain, 50)
                    end
                end
                
            else
            
                for i, brain in BRAINS do
                
                    if brain.BrainType == 'AI' and brain.IntelDebugThread then
                    
                        LOG("*AI DEBUG "..brain.Nickname.." DrawIntel thread stopped")

                        KillThread(brain.IntelDebugThread)
                        brain.IntelDebugThread = nil
                    end
                end
            end
        end
        
    elseif data.ThreatType then
        
        if not ScenarioInfo.ThreatTypes then
            ScenarioInfo.ThreatTypes = {}
        end
        
        if not ScenarioInfo.ThreatTypes[data.ThreatType] then
            ScenarioInfo.ThreatTypes[data.ThreatType] = {}
        end
        
        ScenarioInfo.ThreatTypes[data.ThreatType].Active = data.Active
        ScenarioInfo.ThreatTypes[data.ThreatType].Color = data.Color

    end
end

-- this is the score keeping thread 
-- it rotates thru all the brains and fills in each armies score details
-- the rate of score updating is controlled within
function CollectCurrentScores()

	local ArmyScore = {}
	local Brains = ArmyBrains
	
	local LOUDFLOOR = math.floor
	local LOUDGETN = LOUDGETN
    
	local ScoreInterval = 51	-- time, in ticks, between score updates

	-- all the scores update every ScoreInterval period so
	-- calculate how much time each brain can utilize of that
	local braindelay = LOUDFLOOR( ScoreInterval / LOUDGETN(Brains) )

	-- Initialize the score data stucture for each brain
    for index = 1, LOUDGETN(Brains) do
    
        if Brains[index].Nickname == 'civilian' then
            continue
        end
	
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
    local SetArmyStat = moho.aibrain_methods.SetArmyStat
    
	local GetBlueprintStat = moho.aibrain_methods.GetBlueprintStat
	local WaitTicks = coroutine.yield
	
	local massSpent, energySpent, massValueDestroyed, massValueLost, energyValueDestroyed, energyValueLost
	local mass_total, mass_used, mass_total_waste, energy_total, energy_used, energy_total_waste
	local Unit_massSpent, Unit_energySpent
	
	local energyValueCoefficient = 25
	
	local resourceProduction, resource_waste, unitProduction, battle_kills, battle_losses
	local battleResults, score
    
    local lastmasstotal = {}
    local lastenergytotal = {}
    local lastscore = {}
    local badflag = {}
    
    for index, brain in Brains do
    
        lastmasstotal[index] = 0
        lastenergytotal[index] = 0
        lastscore[index] = 0
        badflag[index] = false
    
    end
	
	-- launch the loop that will keep the scores sync'd 
	ForkThread( SyncCurrentScores, Brains, ArmyScore, ScoreInterval )

	-- loop for the entire session
    while true do

        for index, brain in Brains do
 
            -- no need to update civilian score
            if brain.Nickname == 'civilian' then
                continue
            end

			mass_total = GetArmyStat( brain,"Economy_TotalProduced_Mass",0.0).Value
            
			mass_used = GetArmyStat( brain, "Economy_Output_Mass", 0.0).Value
			mass_total_waste = GetArmyStat( brain,"Economy_AccumExcess_Mass",0.0).Value
            
            if mass_total > 1 and lastmasstotal[index] <= mass_total then

                lastmasstotal[index] = mass_total

                badflag[index] = false

            else
                
                if not badflag[index] then

                    --LOG("*AI DEBUG Fixing mass_total "..mass_total.." with "..lastmasstotal[index] )

                    badflag[index] = true
                end
                
                mass_total = lastmasstotal[index]
                
                SetArmyStat( brain,"Economy_TotalProduced_Mass", mass_total )

            end
			
			energy_total = GetArmyStat( brain,"Economy_TotalProduced_Energy",0.0).Value

			energy_used = GetArmyStat( brain, "Economy_Output_Energy", 0.0).Value
			energy_total_waste = GetArmyStat( brain, "Economy_AccumExcess_Energy",0.0).Value
			
            if energy_total > 1 and lastenergytotal[index] <= energy_total then
            
                lastenergytotal[index] = energy_total
                
            else

                energy_total = lastenergytotal[index]

                SetArmyStat( brain,"Economy_TotalProduced_Energy", energy_total )

            end
            
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
			
			if score > 1 then
            
                lastscore[index] = score

			else
                score = lastscore[index] or 0
            end
            
			ArmyScore[index].general.score = LOUDFLOOR(score)

            ArmyScore[index].general.mass = mass_total
            ArmyScore[index].general.energy = energy_total

            ArmyScore[index].general.currentunits.count = GetArmyStat( brain, "UnitCap_Current", 0.0).Value
            ArmyScore[index].general.currentcap.count = GetArmyStat( brain, "UnitCap_MaxCap", 0.0).Value

            ArmyScore[index].general.kills.count = GetArmyStat( brain, "Enemies_Killed", 0.0).Value

            ArmyScore[index].general.kills.mass = massValueDestroyed
            ArmyScore[index].general.kills.energy = energyValueDestroyed

            ArmyScore[index].general.built.count = GetArmyStat( brain, "Units_History", 0.0).Value

            ArmyScore[index].general.built.mass = Unit_massSpent
            ArmyScore[index].general.built.energy = Unit_energySpent

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
		   
            ArmyScore[index].resources.massin.total = mass_total

            ArmyScore[index].resources.massin.rate = GetArmyStat( brain, "Economy_Income_Mass", 0.0).Value

            ArmyScore[index].resources.massout.total = massSpent

            ArmyScore[index].resources.massout.rate = GetArmyStat( brain, "Economy_Output_Mass", 0.0).Value
            ArmyScore[index].resources.massover = GetArmyStat( brain, "Economy_AccumExcess_Mass", 0.0).Value

            ArmyScore[index].resources.energyin.total = energy_total

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

	local braincount = LOUDGETN(Brains)

    local LOUDDEEPCOPY = table.deepcopy
    local WaitTicks = WaitTicks
    
    local A,lastA

    while true do
	
	    WaitTicks(ScoreInterval)  	
		
		for index = 1, braincount do
        
            if Brains[index].Nickname == 'civilian' then
                continue
            end
            
            -- try and catch the -ve massin bug --
            if ArmyScore[index].resources.massin.total > 0 then
            
                A = ArmyScore[index]

                lastA = LOUDDEEPCOPY(A)

            else

                --LOG("*AI DEBUG fixing massin total "..repr(A.resources.massin.total))

                A = LOUDDEEPCOPY(lastA)

            end
		
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
			
		end

		Sync.FullScoreSync = true		

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
        
        self.AirBias = 1
        self.AirRatio = 0.01
        self.LandRatio = 0.01
        self.NavalRatio = 0.01
		
		-- store the faction index (1 = UEF, 2 = Aeon, 3 = Cybran, 4 = Seraphim)
		self.FactionIndex = self:GetFactionIndex()
		
		-- store the faction name ( UEF, Aeon, Cybran, Seraphim )
		self.FactionName = factions[self.FactionIndex]
		
		self.BuilderManagers = {}		
		
		self.PingCallbackList = {}
        
        -- this is a LOUD data element for storing unpacked platoon templates
        self.PlatoonTemplates = {}

        -- all AI are technically 'cheaters' now --
        self.CheatingAI = true

		-- Store the cheat value (ie. 1.1 = 10% cheat)
		local s = ScenarioInfo.ArmySetup[self.Name].Mult
		local m
        
--		if type(s) == "string" then
			m = tonumber(ScenarioInfo.ArmySetup[self.Name].Mult)
--		else
	--		m = aiMults[ScenarioInfo.ArmySetup[self.Name].Mult]
--		end
        
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
                
                -- custom AI settings - check for plan file 
                -- bypass if the file is not available and use
                -- LOUD AI natively
                if DiskGetFileInfo(planName) then

                    LOG("*AI DEBUG Creating AI with plan "..repr(planName))

                    self.AIPlansList = import(planName).AIPlansList
		
                    self.CurrentPlan = self.AIPlansList[self.FactionIndex][1]
                    
                end
				
			end

			-- go get and set a plan for MAIN
			if self:IsOpponentAIRunning() then

				ForkThread( import('/lua/ai/aiarchetype-managerloader.lua').ExecutePlan, self )

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

        local resourceStructure
        local resourceStructures = {}

        local initialUnit
        local initialUnits = {}

        local posX, posY = self:GetArmyStartPos()

        if factionIndex == 1 then
		
			resourceStructure = 'UEB1103'
			initialUnit = 'UEB1101'
			
        elseif factionIndex == 2 then
		
			resourceStructure = 'UAB1103'
			initialUnit = 'UAB1101'
			
        elseif factionIndex == 3 then
		
			resourceStructure = 'URB1103'
			initialUnit = 'URB1101'
			
		elseif factionIndex == 4 then
		
			resourceStructure = 'XSB1103'
			initialUnit = 'XSB1101'
			
        end
        
        local mult = 2
        
        if self.OutnumberedRatio >= 2 then
            mult = 4
        end

        for index = 1, mult do
            table.insert( resourceStructures, resourceStructure )
            table.insert( initialUnits, initialUnit )
        end

        LOG("*AI DEBUG "..self.Nickname.." Spawn PreBuilt Units is "..repr(initialUnits))

        if resourceStructures then
        
            mult = 0
		
    		-- place resource structures down
    		for _, v in resourceStructures do
			
                local unit = self:CreateResourceBuildingNearest(v, posX, posY)
				
                if unit != nil and unit:GetBlueprint().Physics.FlattenSkirt then
				
                    unit:CreateTarmac(true, true, true, false, false)
					
                end
				
				-- AI may have upgrade threads to run - delay them so they dont all happen on same tick
				if self.BrainType != 'Human' then
				
					unit:ForkThread( function(unit) mult = mult + 1 WaitTicks( 1 + (mult*75)) unit:LaunchUpgradeThread(self) end )

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

        --- record that brain had prebuilt units
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
		
        TrashAdd( self.Trash, thread )
		
        return thread
		
    end,
    
    -- this version does NOT return the handle
    ForkThread1 = function(self, fn)
	
        TrashAdd( self.Trash, ForkThread(fn, self))
		
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
				
					local units = GetListOfUnits( self, categories.ALLUNITS -categories.SUBCOMMANDER - categories.WALL - categories.COMMAND, false)
					
					import('/lua/SimUtils.lua').TransferUnitsOwnership( units, v:GetArmyIndex())
					
				end
				
			end
			
			WaitTicks(5)
			
			local killacu = GetListOfUnits( self, categories.ALLUNITS, false)
			
            for index,unit in killacu do
			
                unit:Kill()
				
            end
			
        end	
		
        SetArmyOutOfGame(self.ArmyIndex)
		
        LOUDINSERT( Sync.GameResult, { self.ArmyIndex, "defeat" } )
		
        import('/lua/SimPing.lua').OnArmyDefeat(self.ArmyIndex)
       
		if self.BuilderManagers then
			
			-- put in for LOUD AI so that I can clear the BuilderManager for a human player
			if self.BrainType != 'Human' then

				LOG("*AI DEBUG Shutting down AI "..self.Nickname)
                
                --LOG("*AI DEBUG AIBrain at shutdown is "..repr(self))
                
                self.AirRatio = nil
                self.LandRatio = nil
                self.NavalRatio = nil
                
                self.BadReclaimables = nil
                self.BaseAlertSounded = nil
                self.BaseExpansionUnderway = nil
                
                self.CurrentPlan = nil
				
				self.ConditionsMonitor.Trash:Destroy()
				
				self.ConditionsMonitor:Destroy()
				
				self.ConditionsMonitor = nil
			
				for k,v in self.BuilderManagers do
				
					if ScenarioInfo.DisplayBaseNames or self.DisplayBaseNames or self.BuilderManagers[k].MarkerID then
					
						ForkThread( import('/lua/loudutilities.lua').RemoveBaseMarker, self, k, self.BuilderManagers[k].MarkerID)
						
					end
					
					-- remove the dynamic rally points
					import('/lua/loudutilities.lua').RemoveBaseRallyPoints( self, v.BaseName, v.BaseType, v.RallyPointRadius )
				
					v.EngineerManager:SetEnabled(self,false)
					v.FactoryManager:SetEnabled(self,false)
					v.PlatoonFormManager:SetEnabled(self,false)
					
					v.FactoryManager:Destroy()
                    v.FactoryManager.BuilderData = nil
					v.PlatoonFormManager:Destroy()
                    v.PlatoonFormManager.BuilderData = nil
					v.EngineerManager:Destroy()
                    v.EngineerManager.BuilderData = nil
                    
					--v.StrategyManager:Destroy()
					
                    v.PrimaryLandAttackBase = nil
                    v.PrimarySeaAttackBase = nil
                    
                    self.BuilderManagers[k] = nil
					
				end
                
                self.LastPrimaryLandAttackBase = nil
                self.LastPrimarySeaAttackBase = nil
                
                self.MainBaseDead = nil
                
                self.NumBases = nil
                self.NumBasesLand = nil
                self.NumBasesNaval = nil

                self.PrimaryLandAttackBase = nil
                self.PrimaryLandAttackBaseDistance = nil
                self.PrimarySeaAttackBase = nil
                self.PrimarySeaAttackBaseDistance = nil

				if self.PathCacheThread then
				
					KillThread(self.PathCacheThread)
					
					if self.PathCache then
					
						self.PathCache = nil
						
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
                
                self.PingCallbackList = nil
                
                self.PlatoonDistress = nil
                self.PlatoonTemplates = nil
				
                if self.RefuelPool then
                    self:DisbandPlatoon(self.RefuelPool)
                end
                
				self:DisbandPlatoon(self.StructurePool)
                
                if self.TransportPool then
                    self:DisbandPlatoon(self.TransportPool)
                end
				
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
			
			if self.Trash then

				self.Trash:Destroy()
				
			end
			
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
	
        if GetFocusArmy() == self.ArmyIndex then
		
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
	
		if GetFocusArmy() == self.ArmyIndex then
		
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
            EngineerManager     = CreateEngineerManager(self, baseName, position, radius),
            FactoryManager      = CreateFactoryBuilderManager(self, baseName, position, basetype),
            PlatoonFormManager  = CreatePlatoonFormManager(self, baseName, position, radius),
			
        }

		if ScenarioInfo.BaseMonitorDialog then
            LOG("*AI DEBUG "..self.Nickname.." "..repr(baseName).." Created")
        end
        
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
	
		--LOG("*AI DEBUG "..self.Nickname.." OnIntelChange for "..repr(reconType).." blip is "..repr(GetBlueprint(blip).Description).." val is "..repr(val))
		
    end,

    TotalCheat = function(self)
        return (self.CheatValue or 1) + (self.FeedbackCheat or 0) + (self.TimeCheat or 0)
    end

}

--[[
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
--]]

--[[

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