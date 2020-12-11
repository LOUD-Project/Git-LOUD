--  Loud_AI_Naval_Attack_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'

local NotPrimaryBase = function( self,aiBrain,manager)

	if not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return 650, false
	end

	return self.Priority, true
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.Priority, true
	end

	return 10, true
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function(self,aiBrain,manager)

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .01 and aiBrain.NavalRatio <= 10) then
		return self.Priority, true
	end

	return 10, true
	
end


BuilderGroup {BuilderGroupName = 'Sea Scout Formations',
	BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Water Scout Formation',
	
        PlatoonTemplate = 'T1WaterScoutForm',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ScoutingAI',

        Priority = 740,
		
        InstanceCount = 5,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},			
		},
    },
}

BuilderGroup {BuilderGroupName = 'Sea Scout Formations - Small',
	BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Water Scout Formation - Small',
	
        PlatoonTemplate = 'T1WaterScoutForm',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ScoutingAI',

        Priority = 740,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},			
		},
    },
}


BuilderGroup {BuilderGroupName = 'Naval Formations',
    BuildersType = 'PlatoonFormBuilder',
	
	-- we always hunt water MEX
    Builder {BuilderName = 'Sub Sea Attack MEX',
	
        PlatoonTemplate = 'MassAttackNaval',
		
		PlatoonAIPlan = 'GuardPointNaval',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        Priority = 750,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},

            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
        },
		
        BuilderData = {
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			MissionTime = 1500,		-- 25 minute mission			
			
			PointType = 'Unit',
			PointCategory = categories.ECONOMIC + categories.FACTORY,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 2000,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 2000,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE,
			StrRadius = 32,
			StrTrigger = false,
			StrMin = -1,
			StrMax = 12,
            
            ThreatMin = -999,
            ThreatMaxRatio = 1.2,
            ThreatRings = 0,
            ThreatType = 'AntiSub',
			
			UntCategory = categories.NAVAL * categories.MOBILE,
			UntRadius = 64,
			UntTrigger = false,
			UntMin = -1,
			UntMax = 12,
			
            PrioritizedCategories = { 'FACTORY','ECONOMIC' },
			
			GuardRadius = 40,
			GuardTimer = 6,
			
			MergeLimit = 18,
			
			AggressiveMove = true,
			
			AllowInWater = "Only",
			
			UseFormation = 'AttackFormation',
        },
    },	

    -- ALL the SEA ATTACK formations only appear when there is
    -- enemy Naval Activity and we are not yet totally dominant
    -- on the water (Naval Ratio < 8)
    Builder {BuilderName = 'T1 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 1,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },

            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			MissionTime = 600,		-- 10 minute mission
            SearchRadius = 180,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','ECONOMIC STRUCTURE', },
        },
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Aeon',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 2,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			MissionTime = 600,		-- 10 minute mission
            SearchRadius = 180,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','ECONOMIC STRUCTURE', },
        },
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 3,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 6,

			MissionTime = 600,		-- 10 minute mission
            SearchRadius = 180,     -- use Prioritized Categories as primary target selection
            
			UseFormation = 'AttackFormation',

			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','ECONOMIC STRUCTURE', },
        },
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 4,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			MissionTime = 600,		-- 10 minute mission
            SearchRadius = 180,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'AttackFormation',

			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','ECONOMIC STRUCTURE', },
        },
    },

	
    Builder {BuilderName = 'T2 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Medium',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 751,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 1,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 0, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
        },
    },
	
    Builder {BuilderName = 'T2 Sea Attack - Aeon',
	
        PlatoonTemplate = 'SeaAttack Medium',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 751,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 2,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 0, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
		
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',

			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
        },
    },
	
    Builder {BuilderName = 'T2 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Medium',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 751,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 3,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 0, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
        },
    },
	
    Builder {BuilderName = 'T2 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Medium',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 751,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 4,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
            { LUTL, 'PoolGreater', { 0, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',

			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
        },
    },

	
    Builder {BuilderName = 'T3 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 752,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 1,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
            { LUTL, 'PoolGreater', { 2, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1500,		-- 25 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
        },
    },
	
    Builder {BuilderName = 'T3 Sea Attack - Aeon',
	
        PlatoonTemplate = 'SeaAttack Large',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 752,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 2,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
            { LUTL, 'PoolGreater', { 2, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1500,		-- 25 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
        },
    },
	
    Builder {BuilderName = 'T3 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 752,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 3,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
            { LUTL, 'PoolGreater', { 2, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.DEFENSIVEBOAT }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1500,		-- 25 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
        },
    },

    Builder {BuilderName = 'T3 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 752,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 4,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
            { LUTL, 'PoolGreater', { 2, categories.BATTLESHIP }},
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
        },
		
        BuilderData = {
			DistressRange = 225,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1500,		-- 25 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection            
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
        },
    },

    -- NAVAL BOMBARDMENT only appears once significant control over
    -- the water has been achieved (Naval Ratio > 1.5) and continues
    -- regardless of if the enemy is active in the water or not
    Builder {BuilderName = 'Sea Attack - Bombardment',
	
        PlatoonTemplate = 'SeaAttack Bombardment',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'BombardForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 753,

		PriorityFunction = IsPrimaryBase,

        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { 1.5 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.BOMBARDMENT}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
        },
		
        BuilderData = {
			
			MissionTime = 1800,		-- 30 minute mission
			
			UseFormation = 'DMSCircleFormation',
			
			PrioritizedCategories = { 'ECONOMIC', 'FACTORY','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
        },
    },

    -- NAVAL BASE Patrols only appear if there is a NAVAL threat
    -- within 8km of the naval base - therefore these can still 
    -- form even if intel says no enemy naval activity.
--[[    
    Builder {BuilderName = 'Naval Base Patrol',
	
        PlatoonTemplate = 'SeaAttack Medium - Base Patrol',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 745,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderData = {
			DistressRange = 160,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 75,
			
			PatrolTime = 240,	-- 4 minutes
			PatrolType = true,
        },
		
        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 35, 'Naval' }},
        },
    },
--]]
	
    Builder {BuilderName = 'Naval Base Sub Patrol',
	
        PlatoonTemplate = 'SeaAttack Submarine - Base Patrol',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 745,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderData = {
			DistressRange = 160,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 75,
			
			PatrolTime = 240,	-- 4 minutes
			PatrolType = true,
        },
		
        BuilderConditions = {
            { LUTL, 'PoolGreater', { 6, categories.SUBMARINE + categories.xes0102 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 35, 'Naval' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
        },
    },

--[[	
	-- this is supressed for now - 
	Builder {BuilderName = 'T3 Sea Attack Nuke',
	
        PlatoonTemplate = 'SeaNuke',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 0,	--700,
		
        InstanceCount = 3,
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderData = {
		
			MergeLimit = 1,
			UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0, 
                PrimaryThreatTargetType = 'Naval',
                SecondaryThreatTargetType = 'Economy',
                SecondaryThreatWeight = 0.1,
                WeakAttackThreatWeight = 1,
                VeryNearThreatWeight = 10,
                NearThreatWeight = 5,
                MidThreatWeight = 1,                
                FarThreatWeight = 1,            
            },
			
        },
		
		BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.NUKE }},
			
        },
    },
--]]
	
	Builder {BuilderName = 'Reinforce Primary - Naval',
	
        PlatoonTemplate = 'SeaAttack Reinforcement',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'PlatoonWatchPrimarySeaAttackBase'} },
		
		PlatoonAIPlan = 'ReinforceNavalAI',
		
        Priority = 10,

		PriorityFunction = NotPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DESTROYER }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },    
    },
	
}