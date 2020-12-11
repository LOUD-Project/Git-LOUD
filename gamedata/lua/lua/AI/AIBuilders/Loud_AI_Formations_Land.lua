--  Loud_AI_Land_Attack_Builders.lua
--- all platoon taskS for land combat units

local MIBC = '/lua/editor/MiscBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local BHVR = '/lua/ai/aibehaviors.lua'

local NotPrimaryBase = function( self,aiBrain,manager)

	if (not aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase) and (not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase) then
	
		return 650, false
		
	end

	return self.Priority, true
	
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
	
		return self.Priority, true
		
	end

	return 10, true
	
end

local MapSizeLargerThan20K = function(self,aiBrain)

    if ScenarioInfo.size[1] <= 1028 or ScenarioInfo.size[2] <= 1028 then
        return self.Priority, false
    else
        return 0, false
    end

end

-- used to group T3 artillery into platoons
BuilderGroup {BuilderGroupName = 'Land Formations - Artillery',
    BuildersType = 'PlatoonFormBuilder',
	
	Builder {BuilderName = 'T3 Artillery Formation',
        PlatoonTemplate = 'StrategicArtilleryStructure',
        Priority = 600,

        InstanceCount = 12,
        BuilderType = 'Any',
        
        BuilderConditions = {
            -- any strategic artillery --
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ARTILLERY * categories.STRUCTURE - categories.TACTICAL - categories.TECH2 - categories.TECH1 } },
        },
    },
}

-- used to group nuke launchers into platoons
BuilderGroup {BuilderGroupName = 'Land Formations - Nukes',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Nuke Silo Formation',
        PlatoonTemplate = 'T3Nuke',
        Priority = 600,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.STRATEGIC * categories.STRUCTURE * categories.NUKE } },
        },
    },
}

BuilderGroup {BuilderGroupName = 'Land Formations - Scouts',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Land Scout Formation - Aeon',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 2,
        Priority = 800,
        InstanceCount = 6,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = true,
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - UEF',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 1,
        Priority = 800,
        InstanceCount = 5,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = true,
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - Cybran',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 3,
        Priority = 800,
        InstanceCount = 6,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = true,
			HoldFireOnPatrol = false, -- not needed since they don't have a weapon
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - Sera',
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 4,
        Priority = 800,
        InstanceCount = 5,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = false,	-- unlike other scouts, by being stationary they become cloaked
			HoldFireOnPatrol = true,	-- so we also hold fire when we are on our patrol station
        },
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Land Formations - Land Only Map',
    BuildersType = 'PlatoonFormBuilder',
    
    -- this is the VENTING attack -- no odds required
    -- primarily looking for fights with units before fixed enemy positions
    Builder {BuilderName = 'Land Attack - Unit Forced',
	
        PlatoonTemplate = 'LandAttackHugeNW',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 802,
		
		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 69, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 10,

			MergeLimit = 160,	-- controls merging with others - nil = original platoon size
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE'},		# controls target selection
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
        },
    },

	-- this is the primary economic attack platoon
    -- formed when odds are relatively even (>0.9)
    -- specifically target economic targets then bases
    Builder {BuilderName = 'MEX Attack Land - Large',
	
        PlatoonTemplate = 'T3MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 801,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
            
            { LUTL, 'PoolGreater', { 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			-- economic targets within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.ECONOMIC, 1000 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1000,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 15,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 40,
			
            PrioritizedCategories = { 'ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE','LAND MOBILE','ENGINEER'},
			
			GuardRadius = 75,
			GuardTimer = 30,
			
			MergeLimit = 100,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },
 	
	-- if team does not have it's share of extractors 
    -- attack enemy MASSEXTRACTION postions within 20k
    -- no odds required --
    Builder {BuilderName = 'MEX Attack Land Large Need Mass',
	
        PlatoonTemplate = 'T3MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 801,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ LUTL, 'NeedTeamMassPointShare', {}},
            
            { LUTL, 'PoolGreater', { 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			-- enemy mass production within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1000 }},
            
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Land', 200 }},            

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1000,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 72,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 12,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 30,
			
            PrioritizedCategories = { 'MASSPRODUCTION','ECONOMIC','FACTORY','DEFENSE STRUCTURE','SHIELD','LAND MOBILE','ENGINEER'},
			
			GuardRadius = 75,
			GuardTimer = 15,
			
			MergeLimit = 100,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },
   
	-- modest sized base attack platoon
    -- forms when odds ok at (>.9)
    -- focused on bases first -- no distance restriction
    Builder {BuilderName = 'Land Attack Large NW',
	
        PlatoonTemplate = 'T3LandAttackNW',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
            
            { LUTL, 'PoolGreater', { 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
		
			MergeLimit = 120,
			
            PrioritizedCategories = { 'FACTORY','DEFENSE STRUCTURE','ECONOMIC','DEFENSE'},		# controls target selection
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
        },
	},
	
	-- This Attacks are more modest in size, only deployed when we have a landstrength advantage.
	-- Notice how this platoon focuses on more specific categories. 
	-- modest sized production attack platoon
    -- forms when odds are good at (>1)
    -- focused on production first -- no distance restriction
    Builder {BuilderName = 'Land Attack Large',
	
        PlatoonTemplate = 'T3LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
            
            { LUTL, 'PoolGreater', { 28, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
            { LUTL, 'PoolGreater', { 6, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 28, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
		
			MergeLimit = 95,
			
            PrioritizedCategories = { 'FACTORY','DEFENSE STRUCTURE','ECONOMIC','DEFENSE'},		# controls target selection 
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
        },
	},
	
	-- another modest sized attack platoon
    -- forms when odds are hohum (>.8) but more of them
    -- focus on economic structures within 25km
    Builder {BuilderName = 'MEX Attack Land',
	
        PlatoonTemplate = 'T2MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 4,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },

			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Land', 200 }},            
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
            
            -- as an attack platoon - it needs to be streamlined - so no more minimum AA component -- we'll see if thats more effective
			--{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 150,
			PointMax = 1250,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 75,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 10,
            
            ThreatMaxRatio = 1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 75,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 24,
			
            PrioritizedCategories = { 'ENGINEER','MASSPRODUCTION','FACTORY','DEFENSE STRUCTURE','SHIELD','ECONOMIC'},
			
			GuardRadius = 100,
			GuardTimer = 33,
			
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
			
        },
    },
	
	-- another MASSEXTRACTION attack but smaller
    -- formed when team does not have it's mass share
    -- attacks MASSPRODUCTION positions within 15 km
    Builder {BuilderName = 'MEX Attack Land Need Mass',
	
        PlatoonTemplate = 'T2MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'NeedTeamMassPointShare', {}},

			-- enemy mass points within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1000 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
		
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1000,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 75,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 8,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 75,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 18,
			
            PrioritizedCategories = { 'MASSPRODUCTION','ECONOMIC','DIRECTFIRE','LAND MOBILE','ENGINEER'},
			
			GuardRadius = 50,
			GuardTimer = 5,
			
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },
    
	-- Small Version of Mex Attack Land Need Mass, this is more for "Early Raiding"
	-- another MASSEXTRACTION attack but smaller
    -- formed when team does not have it's mass share
    -- attacks MASSPRODUCTION positions within 15 km
	Builder {BuilderName = 'MEX Attack Small Land Need Mass',
	
        PlatoonTemplate = 'T1MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'NeedTeamMassPointShare', {}},

			-- enemy mass points within 15km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1000 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
		
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 750,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 750,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 30,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 2,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 30,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 6,
			
            PrioritizedCategories = { 'MASSPRODUCTION','ECONOMIC','ENGINEER'},
			
			GuardRadius = 60,
			GuardTimer = 15,
			
			MergeLimit = 25,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },

	-- attack enemy ANTIAIR STRUCTURES with small groups
    -- forms when odds are modest(>0.8) 
    Builder {BuilderName = 'AA Attack Land',
	
        PlatoonTemplate = 'T1MassAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
        
        PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 4,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
            
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Land', 200 }},            

			-- enemy AA structures within 15km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.ANTIAIR * categories.STRUCTURE, 1750 }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = categories.ANTIAIR * categories.STRUCTURE,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1750,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1750,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMaxRatio = 1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 6,
			
            PrioritizedCategories = { 'ANTIAIR STRUCTURE','DEFENSE STRUCTURE','ECONOMIC','ENGINEER','STRUCTURE -WALL','LAND MOBILE'},
			
			GuardRadius = 80,
			GuardTimer = 20,
			
			MergeLimit = 32,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },

}

BuilderGroup {BuilderGroupName = 'Land Formations - Water Map',
    BuildersType = 'PlatoonFormBuilder',
	
	-- this is the water map Land Attack used for venting
	-- available at ALL types of bases
    Builder {BuilderName = 'T3 Land Attack - Water Map',
	
        PlatoonTemplate = 'T3LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
        
        --PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			MergeLimit = 85,
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE'},		# controls target selection
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
        },
    },

    Builder {BuilderName = 'T2 Land Attack - Water Map',
	
        PlatoonTemplate = 'T2LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
        
        --PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			MergeLimit = 60,
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE'},		# controls target selection
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
        },
    },
    
    Builder {BuilderName = 'T1 Land Attack - Water Map',
	
        PlatoonTemplate = 'T1LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
        
        --PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			MergeLimit = 35,
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE'},		# controls target selection
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
        },
    },

	-- attack enemy mass points when team needs mass point share
    Builder {BuilderName = 'MEX Attack Large Need Mass',
	
        PlatoonTemplate = 'T3MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 801,
        
        PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'NeedTeamMassPointShare', {}},
            { LUTL, 'UnitCapCheckLess', { .95 } },
            
            { LUTL, 'PoolGreater', { 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			-- enemy mass points within 15km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1250 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 44, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = 'MASSEXTRACTION',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 50,
			PointMax = 1250,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 12,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 64,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 30,
			
            PrioritizedCategories = { 'ENGINEER','MASSPRODUCTION','FACTORY','SHIELD','ECONOMIC','DEFENSE STRUCTURE'},
			
			GuardRadius = 75,
			GuardTimer = 30,
			
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },

	-- goes after enemy mass extractors
    Builder {BuilderName = 'MEX Attack Water',
	
        PlatoonTemplate = 'T1MassAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = 'MASSEXTRACTION',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1250,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 10,
			
            PrioritizedCategories = { 'ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE','ENGINEER'},
			
			GuardRadius = 75,
			GuardTimer = 32,
			
			MergeLimit = 40,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
	},

	-- go after AA structures
    Builder {BuilderName = 'AA Attack Water',
	
        PlatoonTemplate = 'T1MassAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
        
        PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		            
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
            { LUTL, 'UnitCapCheckLess', { .95 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = categories.ANTIAIR * categories.STRUCTURE,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1500,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMaxRatio = 1,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 50,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 6,
			
            PrioritizedCategories = { 'ANTIAIR STRUCTURE','DEFENSE STRUCTURE','ECONOMIC','ENGINEER','STRUCTURE -WALL','LAND MOBILE'},
			
			GuardRadius = 45,
			GuardTimer = 12,
			
			MergeLimit = 32,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
	},
}

BuilderGroup {BuilderGroupName = 'Land Formations - Experimentals',
    BuildersType = 'PlatoonFormBuilder',
	
    -- Basically a balls to the wall experimental venting attack
    -- will take whatever loose units around the base it can
    -- focused upon engaging units first
	Builder {BuilderName = 'Exp Group - Forced',
	
        PlatoonTemplate = 'T4ExperimentalGroup',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 802,
		
		-- this function alters the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method != 'Amphibious' then
					return 802, true
				end
			end
			
			return 10, true
		end,
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 10, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT }},
		},
		
        BuilderData = {

            PrioritizedCategories = { 'LAND MOBILE','SHIELD','STRUCTURE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 1500,			-- all targets upto 30k
			
			MergeLimit = 120,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },	
	
	Builder {BuilderName = 'Exp Group Amphibious - Forced',
	
        PlatoonTemplate = 'T4ExperimentalGroupAmphibious',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)
		
			-- effectively - if this is a primary base - and the attack plan requires amphibious attack --			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method == 'Amphibious' then
					return 802, true
				end
			end
			
			return 10, true
		end,
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 10, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT }},
		},
		
        BuilderData = {

            PrioritizedCategories = { 'ECONOMIC','SHIELD','STRUCTURE','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 2500,			-- all targets
			
			MergeLimit = 120,				# controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },	
	
	Builder {BuilderName = 'Exp Group Amphibious',
	
        PlatoonTemplate = 'T4ExperimentalGroupAmphibious',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
			
			-- effectively - if this is a primary base - and the attack plan requires amphbious attack --
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method == 'Amphibious' then
					return 800, true
				end
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 10, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT }},
		},
		
        BuilderData = {
		
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
            PrioritizedCategories = { 'SHIELD','STRUCTURE','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 1500,			-- only process hi-priority targets within 30km
			
			MergeLimit = 120,				# controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },

	Builder {BuilderName = 'Exp Group',
	
        PlatoonTemplate = 'T4ExperimentalGroup',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method != 'Amphibious' then
					return 800, true
				end
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 10, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 12, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
		
		},
		
        BuilderData = {
		
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
            PrioritizedCategories = { 'SHIELD','STRUCTURE','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 1500,			-- only process hi-priority targets within 30km
			
			MergeLimit = 120,				# controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },

	Builder {BuilderName = 'Reinforce Primary - Land Experimental',
	
		PlatoonTemplate = 'ReinforceLandExperimental',

        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },

		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },

		PlatoonAIPlan = 'ReinforceAmphibAI',

        Priority = 10,

		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, manager)

			if not aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase and not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 650, true
			end

			return 10, true
		end,

        InstanceCount = 2,

        BuilderType = 'Any',

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 } },
        },

        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
    },

--[[	
    Builder {BuilderName = 'Exp Land Scathis',

        PlatoonTemplate = 'T4ExperimentalScathis',

		FactionIndex = 3,

        Priority = 800,

		-- this function alters the builder 
		PriorityFunction = function(self, aiBrain, manager)

			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 802, true
			end

			return 10, true
		end,

        InstanceCount = 4,

		BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.url0401} },
        },

        BuilderType = 'Any',

        BuilderData = {
            PrioritizedCategories = { 'EXPERIMENTAL STRUCTURE ARTILLERY', 'EXPERIMENTAL STRUCTURE ECONOMIC', 'COMMAND', 'FACTORY LAND', 'MASSPRODUCTION', 'ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE' },
        },
    },
--]]
}


-- On Water Maps the Amphib formations will carry most of the big combat load
BuilderGroup {BuilderGroupName = 'Land Formations - Amphibious',
    BuildersType = 'PlatoonFormBuilder',
	
	-- this is the VENTING attack for amphibious maps
    Builder {BuilderName = 'Amphib Attk - Unit Forced',
	
        PlatoonTemplate = 'AmphibAttackHuge',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 803,
		
		PriorityFunction = IsPrimaryBase,

		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 60, (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT }},
        },
		
        BuilderData = {
        
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE'},		# controls target selection
			
			MaxAttackRange = 3000,			-- only process hi-priority targets within 60km
			
			MergeLimit = 120,				-- controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = false,
			
			UseFormation = 'GrowthFormation',
        },
    },
	
	-- large attack at 17.5 km
    Builder {BuilderName = 'Amphib Attk Large',
	
        PlatoonTemplate = 'T3AmphibAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        Priority = 802,
		
		PriorityFunction = IsPrimaryBase,

		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 48, (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT }},
        },
		
        BuilderData = {
		
            PrioritizedCategories = { 'FACTORY','STRUCTURE','ECONOMIC','DEFENSE','SHIELD','ENGINEER'},		# controls target selection
			
			MaxAttackRange = 1500,			-- only process hi-priority targets within 30km
			
			MergeLimit = 100,				# controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			UseFormation = 'GrowthFormation',
        },
    },
    
	-- general attack at 15km 
    Builder {BuilderName = 'Amphib Attk',
	
        PlatoonTemplate = 'T2AmphibAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        Priority = 801,
		
		PriorityFunction = IsPrimaryBase,

		RTBLocation = 'Any',		
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT }},
		},
		
        BuilderData = {
		
            PrioritizedCategories = { 'FACTORY','STRUCTURE','ECONOMIC','DEFENSE','SHIELD','ENGINEER'},		# controls target selection
			
			MaxAttackRange = 1000,			-- only process hi-priority targets within 20km
			
			MergeLimit = 60,				# controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = false,
			
			UseFormation = 'GrowthFormation',
        },
    },

	-- attack extractors within 15km 
    Builder {BuilderName = 'Amphib MEX Attack',
	
        PlatoonTemplate = 'T1AmphibAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
        
        PriorityFunction = IsPrimaryBase,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 12, (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT }},
        },
		
        BuilderData = {
			DistressRange = 135,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			PointType = 'Unit',
			PointCategory = 'MASSEXTRACTION',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 800,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 800,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE - categories.TECH1,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 8,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER - categories.TECH1),
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 12,
			
            PrioritizedCategories = { 'ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE','ENGINEER'},
			
			GuardRadius = 80,
			GuardTimer = 25,
			
			MergeLimit = 38,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
	},
    
	Builder {BuilderName = 'Reinforce Primary - Amphibious',
	
        PlatoonTemplate = 'ReinforceAmphibiousPlatoon',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceAmphibAI',
		
        Priority = 10,

		PriorityFunction = NotPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 12, (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT }},
            
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Land', 200 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },  
    },    
}


-- Guard Markers/Structures --
-- these are mostly early platoons - designed to skirmish
-- focused on mass points, extractors, DPs and Expansions
-- these platoons usually stop once the AI has attained his share of mass point control
BuilderGroup {BuilderGroupName = 'Land Formations - Point Guards',
    BuildersType = 'PlatoonFormBuilder',

    
	Builder {BuilderName = 'Extractor Attack',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
        
        RTBLocation = 'Any',

        InstanceCount = 5,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'NeedTeamMassPointShare', {}},
            
            { LUTL, 'UnitCapCheckLess', { .75 } },

			-- enemy mass points within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1000 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
		
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 4,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1000,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE,
			StrRadius = 30,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 2,
            
            ThreatMaxRatio = 0.9,
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER),
			UntRadius = 30,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 6,
			
            PrioritizedCategories = { 'MASSPRODUCTION','ECONOMIC','ENGINEER'},
			
			GuardRadius = 75,
			GuardTimer = 25,
			
			MergeLimit = 25,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },
    
	-- Platoon designed to go to empty mass points within 15km and stay there until an extractor is built
	-- runs until AI team has its share of mass points
    Builder {BuilderName = 'Mass Point Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ LUTL, 'NeedTeamMassPointShare', {}},
            
            { LUTL, 'UnitCapCheckLess', { .75 } },

			-- empty mass point within 15km with less than 45 threat 
			{ EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 1000, 0, 75, 1, 'AntiSurface', 1 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			DistressRange = 175,
			DistressTypes = 'Land',
			DistressThreshold = 2,
			
			PointType = 'Marker',			-- either Unit or Marker
			PointCategory = 'Mass',
			PointSourceSelf = true,			-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 		-- must be Self, Ally or Enemy - determines which Structures and Units to check
			PointRadius = 1000,		    	-- controls the finding of points based upon distance from PointSource
			PointSort = 'Closest',			-- options are Closest or Furthest
			PointMin = 150,					-- filter points by range from PointSource
			PointMax = 1000,
			
			StrCategory = categories.MASSEXTRACTION,		-- filter points based upon presence of units/strucutres at point
			StrRadius = 5,
			StrTrigger = true,				-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 0,
            
            ThreatMin = 0,
            ThreatMaxRatio = 0.8,
            ThreatRings = 1,
			
			UntCategory = categories.LAND * categories.MOBILE - categories.ENGINEER,		-- secondary filter on units/structures at point
			UntRadius = 45,
			UntTrigger = true,				-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 10,
			
            AssistRange = 3,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},		-- target selection when at point --
			
			GuardRadius = 75,				-- range at which platoon will engage targets
			GuardTimer = 180,				-- period that platoon will guard the point unless triggers are met
			
			MissionTime = 960,				-- platoon will operate 15 minutes then RTB
			
			MergeLimit = 20,				-- level to which merging is allowed
			
			AggressiveMove = false,
			
			AllowInWater = false,
			
			AvoidBases = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },
	
    Builder {BuilderName = 'MEX Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
        Priority = 0,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,

        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ LUTL, 'NeedTeamMassPointShare', {}},
            
            { LUTL, 'UnitCapCheckLess', { .65 } },

			-- we have a mass extractor within 2-15km with less than 4 defense structures 
            { UCBC, 'MassExtractorInRangeHasLessThanDefense', { 'LocationType', 125, 750, 4, 0, 100, 1 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL }},			
        },
		
        BuilderData = {
			DistressRange = 105,
			DistressTypes = 'Land',
			DistressThreshold = 3,
			
			PointType = 'Unit',					-- either Unit or Marker
			PointCategory = categories.MASSEXTRACTION,
			PointSourceSelf = false,			-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 			-- must be either Ally or Enemy - determines which Structures and Units to check
			PointRadius = 999999,				-- finding of points based upon distance from PointSource
			PointSort = 'Closest',				-- options are Closest or Furthest
			PointMin = 125,						-- filter points by range from PointSource
			PointMax = 750,
			
			StrCategory = categories.DEFENSE * categories.STRUCTURE,		-- filter points based upon presence of units/strucutres at point
			StrRadius = 20,
			StrTrigger = true,				-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 4,
            
            ThreatMin = 2.5,                  -- pick points with at least this threat
            ThreatMaxRatio = 1,                -- and no more than this
            ThreatRings = 2,                -- at this range

			UntCategory = (categories.LAND * categories.MOBILE - categories.ENGINEER) - categories.SCOUT - categories.EXPERIMENTAL,
			UntRadius = 35,
			UntTrigger = true,				-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 28,

            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},		# controls target selection
			
			AssistRange = 3,
			
			GuardRadius = 75,				-- range at which platoon will engage targets
			GuardTimer = 150,				-- platoon will guard 2.5 minutes
			
			MissionTime = 900,				-- platoon will operate 15 minutes
			
			MergeLimit = 16,				-- unit count at which merging is denied
			
			AggressiveMove = false,
			
			AllowInWater = false,
			
			AvoidBases = true,
			
			UseFormation = 'BlockFormation',
        },
    },

	-- This platoon will go to the closest DP that has no defense structures & guard it 
    Builder {BuilderName = 'DP Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI', },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },

            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1250, 0, 100, 0, 'AntiSurface' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 8,
			
			PointType = 'Marker',
			PointCategory = 'Defensive Point',
			PointSourceSelf = true,			# true AI will use its base as source
			PointFaction = 'Ally',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 999999,
			
			StrCategory = categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE,
			StrRadius = 60,
			StrTrigger = true,				-- structure parameters trigger an end to guardtimer
			StrMin = 0,
			StrMax = 4,
            
            ThreatMin = 0,                  -- pick points with at least 1 threat
            ThreatMaxRatio = 1,
            ThreatRings = 1,                -- at this range

			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE),
			UntRadius = 60,
			UntTrigger = true,				-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 10,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},
			
			GuardRadius = 80,
			GuardTimer = 480,
			
			MergeLimit = 25,
			
			AggressiveMove = true,
			
			UseFormation = 'BlockFormation',
        },
    },
	
    Builder {BuilderName = 'DP Guard Artillery',
	
        PlatoonTemplate = 'T2PointGuardArtillery',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI', },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			--{ LUTL, 'LandStrengthRatioLessThan', { 0.8 } },	-- was 3
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			-- a DP marker with less than 75 enemy threat
            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1250, 0, 100, 0, 'AntiSurface' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
		
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 8,
			
			PointType = 'Marker',
			PointCategory = 'Defensive Point',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 999999,
			
			StrCategory = categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 8,
            
            ThreatMin = 0,
            ThreatMaxRatio = 0.8,
            ThreatRings = 0,

			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE),
			UntRadius = 60,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 15,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},
			
			GuardRadius = 80,
			GuardTimer = 480,
			
			MergeLimit = 10,
			
			AggressiveMove = true,
			
			UseFormation = 'BlockFormation',
        },
    },

    Builder {BuilderName = 'Start Guard',
	
        PlatoonTemplate = 'T2MassGuard',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 801,
		
		PriorityFunction = IsPrimaryBase,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			-- a starting point within 15km that has <= 6 non-economic structures within 60 and no more than 100 threat
            { UCBC, 'StartingPointNeedsStructure', { 'LocationType', 1250, 'STRUCTURE -ECONOMIC', 60, 6, 0, 100, 0, 'AntiSurface' }},
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
		
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			PointType = 'Marker',
			PointCategory = 'Blank Marker',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1250,
			
			StrCategory = categories.STRUCTURE - categories.ECONOMIC,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 6,
            
            ThreatMin = 0,
            ThreatMaxRatio = 1,
            ThreatRings = 0,

			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE),
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 24,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','ECONOMIC', 'STRUCTURE','ENGINEER'},
			
			GuardRadius = 80,
			GuardTimer = 900,
			
			MergeLimit = 45,
			
			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'BlockFormation',
        },
    }, 
	
    Builder {BuilderName = 'Start Guard Artillery',
	
        PlatoonTemplate = 'T2PointGuardArtillery',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,	--755
		
		PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 0.8 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
            { UCBC, 'StartingPointNeedsStructure', { 'LocationType', 1000, 'STRUCTURE -ECONOMIC', 60, 6, 0, 100, 0, 'AntiSurface' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
		
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 8,
			
			PointType = 'Marker',
			PointCategory = 'Blank Marker',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 250,
			PointMax = 1000,
			
			StrCategory = categories.STRUCTURE - categories.ECONOMIC,
			StrRadius = 60,
			StrTrigger = true,					-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 6,
            
            ThreatMin = 0,                  -- pick points with at least 5 threat
            
            ThreatRings = 1,                -- at this range
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE),
			UntRadius = 60,
			UntTrigger = true,					-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 24,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},
			
			GuardRadius = 75,
			GuardTimer = 900,
			
			MergeLimit = 50,
			
			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'AttackFormation',
        },
    }, 
	
    Builder {BuilderName = 'Expansion Guard',
	
        PlatoonTemplate = 'T1MassGuard',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 801,
		
		PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { UCBC, 'ExpansionPointNeedsStructure', { 'LocationType', 1250, 'STRUCTURE -ECONOMIC', 60, 6, 0, 100, 0, 'AntiSurface' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
		
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			PointType = 'Marker',				-- either Unit or Marker
			PointCategory = 'Large Expansion Area',
			PointSourceSelf = true,				-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 			-- must be either Ally or Enemy - determines which Structures and Units to check
			PointRadius = 1250,					-- controls the finding of points based upon distance from PointSource
			PointSort = 'Closest',				-- options are Closest or Furthest
			PointMin = 250,						-- allows you to filter found points by range from PointSource
			PointMax = 1250,
			
			StrCategory = categories.STRUCTURE - categories.ECONOMIC,		-- filter points based upon units/strucutres at point
			StrRadius = 60,
			StrTrigger = true,					-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 6,
            
            ThreatMin = 0,
            ThreatMaxRatio = 1,
            ThreatRings = 0,                -- at this range
			
			UntCategory = categories.LAND * categories.MOBILE * categories.DIRECTFIRE,		-- secondary filter on presence of units/structures at point
			UntRadius = 60,
			UntTrigger = true,					-- unit parameters trigger an early end to guardtimer
			UntMin = 0,
			UntMax = 45,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},		-- controls target selection
			
			GuardRadius = 75,					-- range at which platoon will engage targets
			GuardTimer = 1200,					-- period that platoon will guard the point 
			
			MergeLimit = 45,					-- limit to which unit merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    }, 

    Builder {BuilderName = 'Expansion Guard Artillery',
	
        PlatoonTemplate = 'T2PointGuardArtillery',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = IsPrimaryBase,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'LandStrengthRatioLessThan', { 1 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
            { UCBC, 'ExpansionPointNeedsStructure', { 'LocationType', 1000, 'STRUCTURE -ECONOMIC', 75, 6, 0, 100, 0, 'AntiSurface' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
		
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			PointType = 'Marker',
			PointCategory = 'Large Expansion Area',
			PointSourceSelf = true,				-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 			-- must be either Ally or Enemy - determines which Structures and Units to check
			PointRadius = 1000,					-- finding of points based upon distance from PointSource
			PointSort = 'Closest',				-- Closest or Furthest
			PointMin = 250,						-- filter found points by range from PointSource
			PointMax = 1000,
			
			StrCategory = categories.STRUCTURE - categories.ECONOMIC,		-- filter points upon presence of units/strucutres at point
			StrRadius = 75,
			StrTrigger = true,					-- structure parameters trigger an end to guardtimer
			StrMin = 0,
			StrMax = 6,
            
            ThreatMin = 0,
            ThreatMaxRatio = 0.8,
            ThreatRings = 0,                -- at this range
			
			UntCategory = (categories.LAND * categories.MOBILE * categories.DIRECTFIRE),		-- secondary filter on units/structures at point
			UntRadius = 60,
			UntTrigger = true,					-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 24,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE','ENGINEER'},
			
			GuardRadius = 75,				-- range at which platoon will engage targets
			GuardTimer = 600,				-- period that platoon will guard the point 
			
			MergeLimit = 50,				-- trigger level to which merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'AttackFormation',
			
        },
    }, 	
}

-- Land Formations - Base Guards --
-- essentially patrols around the base --
-- new patrols are suspended once a base is under alert
BuilderGroup {BuilderGroupName = 'Land Formations - Base Guards',
	BuildersType = 'PlatoonFormBuilder',
	
	-- in general - we want base guards before anything else
    -- but there must be a land threat within 9km of base
    Builder {BuilderName = 'Base Guard Patrol',
	
        PlatoonTemplate = 'BaseGuardMedium',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
		InstanceCount = 2,
		
        Priority =  805,
		
        BuilderType = 'Any',
		
        BuilderConditions = { 
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 300, 150, 'Land' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 14, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS - categories.ENGINEER - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 4,
			
			BasePerimeterOrientation = '',
			
			Radius = 72,
			
			PatrolTime = 300,
			PatrolType = true,
        },
    }, 
    
    -- AA base patrols appear if our air ratio is below 3
    Builder {BuilderName = 'Base Guard Patrol - AA',
	
        PlatoonTemplate = 'BaseGuardAAPatrol',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority =  805,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ LUTL, 'AirStrengthRatioLessThan', { 1 }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 90,
			DistressTypes = 'Air',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 72,
			
			PatrolTime = 300,
			PatrolType = true,
        },
    }, 

--[[    
    Builder {BuilderName = 'Base Guard Patrol - AA - Response',
	
        PlatoonTemplate = 'BaseGuardAAPatrol',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority =  800,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioLessThan', { 3 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 90,
			DistressTypes = 'Air',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 75,
			
			PatrolTime = 210,
			PatrolType = true,
        },
    },
-]]

}

-- Reinforcement Formation --
-- move Units to the PRIMARY Base --
-- these only run when a base is NOT the PRIMARY
-- and are suspended when the base is under alert or has threat nearby
BuilderGroup {BuilderGroupName = 'Land Formations - Reinforcement',
	BuildersType = 'PlatoonFormBuilder',
    
	Builder {BuilderName = 'Reinforce Primary - Directfire',
	
        PlatoonTemplate = 'ReinforceLandPlatoonDirect',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceLandAI',
		
        Priority = 10,
		
		PriorityFunction = NotPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL }},
            
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Land', 200 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },    
    },
    
	Builder {BuilderName = 'Reinforce Primary - Indirectfire',
	
        PlatoonTemplate = 'ReinforceLandPlatoonIndirect',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceLandAI',
		
        Priority = 10,
		
		PriorityFunction = NotPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'PoolGreater', { 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},
            
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Land', 200 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
    },


}

