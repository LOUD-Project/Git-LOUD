--# Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

--# This is the sim-specific top-level lua initialization file. It is run at initialization time
--# to set up all lua state for the sim.

--# Initialization order within the sim:

--#   1. __blueprints is filled in from preloaded data

--#   2. simInit.lua [this file] runs. It sets up infrastructure necessary to make Lua classes work etc.

--#   if starting a new session:

--    3a. ScenarioInfo is setup with info about the scenario

--#   4a. SetupSession() is called

--#   5a. Armies, brains, recon databases, and other underlying game facilities are created

--#   6a. BeginSession() is called, which loads the actual scenario data and starts the game

--#  otherwise (loading a old session):

--#   3b. The saved lua state is deserialized


--# Do global init and set up common global functions
doscript '/lua/globalInit.lua'

--LOG("*DEBUG Mohodata simInit")

WaitTicks = coroutine.yield

# setup Buff systems
LOG("*AI DEBUG     Setup BUFF system structure")
doscript '/lua/system/BuffBlueprints.lua'

LOG("*AI DEBUG     Loading Adjacency Buff functions")
# load adjacency buff functions
import('/lua/sim/adjacencybufffunctions.lua')	

LOG("*AI DEBUG     Loading Buff Blueprint Definitions")
# Load buff definitions
import( '/lua/sim/buffdefinitions.lua')

LOG("*AI DEBUG     Loading Adjacency Buff Definitions")
# Load Adjacency Buff definitions 
import('/lua/sim/adjacencybuffs.lua')
	
function WaitSeconds(n)
    WaitTicks(math.max(1, n * 10))
end


--# Set up the sync table and some globals for use by scenario functions
doscript '/lua/SimSync.lua'

--# SetupSession will be called by the engine after ScenarioInfo is set
--# but before any armies are created.
function SetupSession()

    ArmyBrains = {}

	--# ScenarioInfo.Env is the environment that the save file and scenario script file are loaded into.
    ScenarioInfo.Env = import('/lua/scenarioenvironment.lua')
	
	-- some default functions
    doscript('/lua/dataInit.lua')
	
    -- Load the scenario save (map markers) and script files
	-- The save file creates a table named "Scenario" in ScenarioInfo.Env,
    -- containing most of the save data. We'll copy it up to a top-level global.

    --LOG('Loading save file: ',ScenarioInfo.save)
    doscript(ScenarioInfo.save, ScenarioInfo.Env)
    --LOG('Loading script file: ',ScenarioInfo.script)
    doscript(ScenarioInfo.script, ScenarioInfo.Env)
	
    ResetSyncTable()
end

--# OnCreateArmyBrain() is called by the engine as the brains are created, and we
--# use it to store off various useful bits of info.
function OnCreateArmyBrain(index, brain, name, nickname)

    import('/lua/sim/scenarioutilities.lua').InitializeStartLocation(name)
    import('/lua/sim/scenarioutilities.lua').SetPlans(name)
	
    LOG(string.format("OnCreateArmyBrain %d %s %s",index,name,nickname))
	
    ArmyBrains[index] = brain
    ArmyBrains[index].Name = name
    ArmyBrains[index].Nickname = nickname

    InitializeArmyAI(name)
end

function InitializePrebuiltUnits(name)
    ArmyInitializePrebuiltUnits(name)
end

--# BeginSession will be called by the engine after the armies are created (but without
--# any units yet) and we're ready to start the game. It's responsible for setting up
--# the initial units and any other gameplay state we need.
function BeginSession()

    local focusarmy = GetFocusArmy()
	
    if focusarmy>=0 and ArmyBrains[focusarmy] then
        LocGlobals.PlayerName = ArmyBrains[focusarmy].Nickname
    end

    -- Pass ScenarioInfo into OnPopulate() and OnStart() for backwards compatibility
    ScenarioInfo.Env.OnPopulate(ScenarioInfo)
    ScenarioInfo.Env.OnStart(ScenarioInfo)

    -- Look for teams
    local teams = {}
	
    for name,army in ScenarioInfo.ArmySetup do
        if army.Team > 1 then
            if not teams[army.Team] then
                teams[army.Team] = {}
            end
            table.insert(teams[army.Team],army.ArmyIndex)
        end
    end

    if ScenarioInfo.Options.TeamLock == 'locked' then
        -- Specify that the teams are locked.  Parts of the diplomacy dialog will be disabled.
        ScenarioInfo.TeamGame = true
        Sync.LockTeams = true
    end

    -- if build restrictions chosen, set them up
    local buildRestrictions = nil
	
    if ScenarioInfo.Options.RestrictedCategories then
	
        local restrictedUnits = import('/lua/ui/lobby/restrictedunitsdata.lua').restrictedUnits
		
        for index, restriction in ScenarioInfo.Options.RestrictedCategories do
		
            local restrictedCategories = nil
			
			LOG("*AI DEBUG Here is the restricted data "..repr(restrictedUnits[restriction].categories))
			
            for index, cat in restrictedUnits[restriction].categories do
			
				-- if that category actually exists
				if categories[cat] then
			
					if restrictedCategories == nil then
					
						--LOG("*AI DEBUG Adding restriction "..repr(cat))
					
						restrictedCategories = categories[cat]
						
					else
					
						--LOG("*AI DEBUG Adding restriction "..repr(cat))
					
						restrictedCategories = restrictedCategories + categories[cat]
						
					end
					
				end
				
			end
			
            if buildRestrictions == nil then
			
                buildRestrictions = restrictedCategories
				
            else
			
                buildRestrictions = buildRestrictions + restrictedCategories
				
            end
			
        end
		
    end
	
	--LOG("*AI DEBUG FINAL RESTRICTIONS ARE "..repr(buildRestrictions))

    if buildRestrictions then
	
        local tblArmies = ListArmies()
		
        for index, name in tblArmies do
		
            AddBuildRestriction(index, buildRestrictions)
			
        end
    else
		ScenarioInfo.Options.RestrictedCategories = false
	end

    -- Set up the teams we found
    for team,armyIndices in teams do
	
        for k,index in armyIndices do
		
            for k2,index2 in armyIndices do

				SetAlliance( index, index2, 'Ally')

            end
			
            ArmyBrains[index].RequestingAlliedVictory = true
        end
    end
    
    -- Create any effect markers on map
    local markers = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers	--import('/lua/sim/scenarioutilities.lua').GetMarkers()
    local Entity = import('/lua/sim/Entity.lua').Entity
    local EffectTemplate = import ('/lua/EffectTemplates.lua')
	
    if markers then
	
		local counter = 0
		
        for k, v in markers do
		
            if v.type == 'Effect' then
				
				counter = counter + 1
				
                local EffectMarkerEntity = Entity()
				
                Warp( EffectMarkerEntity, v.position )   
				
                EffectMarkerEntity:SetOrientation(OrientFromDir(v.orientation), true)   
				
                for k, v in EffectTemplate [v.EffectTemplate] do        
					CreateEmitterAtBone(EffectMarkerEntity,-2,-1,v):ScaleEmitter(v.scale or 1):OffsetEmitter(v.offset.x or 0, v.offset.y or 0, v.offset.z or 0)
				end
            end
        end
		
		if counter > 0 then
			LOG("*AI DEBUG Created "..repr(counter).." EFFECT entities")
		end
    end

    -- start the runtime scorekeeping loop
    ForkThread(import('/lua/aibrain.lua').CollectCurrentScores)

    -- start watching for victory conditions
    ForkThread(import('/lua/victory.lua').CheckVictory, ScenarioInfo)	
end

function OnPostLoad()

	import('/lua/scenarioframework.lua').OnPostLoad()
    import('/lua/simobjectives.lua').OnPostLoad()
    import('/lua/sim/simuistate.lua').OnPostLoad()
    import('/lua/simping.lua').OnArmyChange()
    import('/lua/simpinggroup.lua').OnPostLoad()
    import('/lua/simdialogue.lua').OnPostLoad()
    import('/lua/simsync.lua').OnPostLoad()
	
    if GetFocusArmy() != -1 then
        Sync.SetAlliedVictory = ArmyBrains[GetFocusArmy()].RequestingAlliedVictory or false
    end
end

Prefetcher = CreatePrefetchSet()

function DefaultPrefetchSet()
    local set = { models = {}, anims = {}, d3d_textures = {} }

#    for k,file in DiskFindFiles('/units/*.scm') do
#        table.insert(set.models,file)
#    end

#    for k,file in DiskFindFiles('/units/*.sca') do
#        table.insert(set.anims,file)
#    end

#    for k,file in DiskFindFiles('/units/*.dds') do
#        table.insert(set.d3d_textures,file)
#    end

    return set
end

Prefetcher:Update(DefaultPrefetchSet())

for k,file in DiskFindFiles('/lua/ai/platoontemplates', '*.lua') do
    import(file)
end

for k,file in DiskFindFiles('/lua/ai/aibuilders', '*.lua') do
    import(file)
end

for k,file in DiskFindFiles('/lua/ai/aibasetemplates', '*.lua') do
    import(file)
end
