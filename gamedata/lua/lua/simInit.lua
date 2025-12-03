--# Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

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


LOG("*DEBUG simInit begins" )





InitialRegistration = true


-- global init and set up common functions
doscript '/lua/globalInit.lua'

WaitTicks = coroutine.yield

LOG("*AI DEBUG     Setup Platoon Template Structure")
-- Load Platoon Template systems
doscript '/lua/system/GlobalPlatoonTemplate.lua'

LOG("*AI DEBUG     Setup Builder Template Structure")
-- Load Builder system
doscript '/lua/system/GlobalBuilderTemplate.lua'

LOG("*AI DEBUG     Setup Builder Group Structure")
-- Load Builder Group systems
doscript '/lua/system/GlobalBuilderGroup.lua'

LOG("*AI DEBUG     Setup BaseBuilder Template Structure")
-- Load Global Base Templates
doscript '/lua/system/GlobalBaseTemplate.lua'

-- setup Buff systems
LOG("*AI DEBUG     Setup BUFF system structure")
doscript '/lua/system/BuffBlueprints.lua'

LOG("*AI DEBUG     Loading Adjacency Buff functions")
-- load adjacency buff functions
import('/lua/sim/adjacencybufffunctions.lua')	

LOG("*AI DEBUG     Loading Buff Blueprint Definitions")
-- Load buff definitions
import( '/lua/sim/buffdefinitions.lua')

LOG("*AI DEBUG     Loading Adjacency Buff Definitions")
-- Load Adjacency Buff definitions 
import('/lua/sim/adjacencybuffs.lua')

InitialRegistration = false

local debounced = false
local counter = {}

function trace(event, line)

    if not debounced then

        local info = debug.getinfo(2)
        local source = info.source or 'unknown'
        local name = info.name or info.what or'unknown'

        counter[source] = counter[source] or {}
        counter[source][name] = (counter[source][name] or 0) + 1

        if math.mod(counter[source][name], 250000) == 0 or (GetGameTick() >= 15091) then

            --if (GetGameTick() >= 15091) then
              --  LOG(debug.traceback())
            --end        
            
            LOG( GetGameTick(), string.format('trace: %s:%s called %d times (%s/%s)', source, name, counter[source][name], tostring(event), tostring(line)))
        end

        --if math.mod(counter[source][name], 100000) == 0 then
          --  repr(info)
            --LOG(string.format('trace: %s:%s called %d times', source, name, counter[source][name]))
            --LOG(string.format('trace: %s:%s called %d times (%s/%s)', source, name, counter[source][name], tostring(event), tostring(line)))
        --end

    end

end

--debug.sethook(trace, "count")
--debug.sethook(trace, "line")

function WaitSeconds(n)
    if n < 1 then
        n = .1
    end
    WaitTicks(math.max(1, n*10))
end

-- Set up the sync table and globals
doscript '/lua/SimSync.lua'


-- SetupSession will be called by the engine after ScenarioInfo is set
-- but before any armies are created.
function SetupSession()

    _G.AITarget = nil
    _G.MetaImpact = nil

    --LOG("*AI DEBUG Preference is "..repr(_G) )

    LOG("*AI DEBUG SetupSession " )
   
    ArmyBrains = {}

	-- ScenarioInfo.Env is the environment that the save file and scenario script file are loaded into.
    ScenarioInfo.Env = import('/lua/scenarioenvironment.lua')
	
	-- default functions
    doscript('/lua/dataInit.lua')
	
    -- Load the scenario save (map markers) and script files
	-- The save file creates a table named "Scenario" in ScenarioInfo.Env,
    -- containing most of the save data. We'll copy it up to a top-level global.
    
    LOG('Loading script file: ',ScenarioInfo.script)
    doscript(ScenarioInfo.script, ScenarioInfo.Env)
	
    LOG('Loading save file: ',ScenarioInfo.save)
    doscript(ScenarioInfo.save, ScenarioInfo.Env)

    ResetSyncTable()

end

-- OnCreateArmyBrain() is called by the engine as the brains are created
function OnCreateArmyBrain(index, brain, name, nickname)

    import('/lua/sim/scenarioutilities.lua').InitializeStartLocation(name)
    import('/lua/sim/scenarioutilities.lua').SetPlans(name)

    ArmyBrains[index] = brain
    ArmyBrains[index].Name = name
    ArmyBrains[index].Nickname = nickname

    InitializeArmyAI(name)
end

function InitializePrebuiltUnits(name)
    ArmyInitializePrebuiltUnits(name)
end

-- BeginSession will be called by the engine after the armies are created (but without
-- any units yet) and we're ready to start the game. It's responsible for setting up
-- the initial units and any other gameplay state we need.
function BeginSession()

    LOG("*AI DEBUG BeginSession Starts")

    -- Pass ScenarioInfo into OnPopulate() and OnStart() for backwards compatibility
    ScenarioInfo.Env.OnPopulate(ScenarioInfo)
    ScenarioInfo.Env.OnStart(ScenarioInfo)
    
    --import("/lua/sim/MarkerUtilities.lua")

    local focusarmy = GetFocusArmy()
	
    if focusarmy >= 0 and ArmyBrains[focusarmy] then
        LocGlobals.PlayerName = ArmyBrains[focusarmy].Nickname
    end

    -- Look for teams
    local teams = {}
	
    for name,army in ScenarioInfo.ArmySetup do
        if army.WheelColor != nil then
            army.PlayerColor = army.WheelColor
            army.ArmyColor = army.WheelColor
        end
        
        if army.Team > 1 then
            if not teams[army.Team] then
                teams[army.Team] = {}
            end
            table.insert(teams[army.Team], army.ArmyIndex)
        end
    end

    if ScenarioInfo.Options.TeamLock == 'locked' then
        -- Specify that the teams are locked.  Parts of the diplomacy dialog will be disabled.
        ScenarioInfo.TeamGame = true
        Sync.LockTeams = true
    end

    local buildRestrictions = nil
	
    if ScenarioInfo.Options.RestrictedCategories then
	
        local restrictedUnits = import('/lua/ui/lobby/restrictedunitsdata.lua').restrictedUnits
		
        for index, restriction in ScenarioInfo.Options.RestrictedCategories do
		
            local restrictedCategories = nil
			
			--LOG("*AI DEBUG Here is the restricted data "..repr(restrictedUnits[restriction].categories))
			
            for index, cat in restrictedUnits[restriction].categories do
			
				-- if that category actually exists
				if categories[cat] then
			
					if restrictedCategories == nil then
					
						restrictedCategories = categories[cat]
						
					else
					
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
    local markers = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers
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

    end

    -- scorekeeping loop
    ForkThread(import('/lua/aibrain.lua').CollectCurrentScores)

    -- victory conditions
    ForkThread(import('/lua/victory.lua').CheckVictory, ScenarioInfo)

    -- Performance log --
    --ForkThread(import('/lua/loudutilities.lua').LogGamePerformanceData)
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

LOG("*AI DEBUG SimInit completed")
