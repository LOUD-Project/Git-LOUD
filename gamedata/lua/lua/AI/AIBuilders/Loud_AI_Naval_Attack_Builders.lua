--  Loud_AI_Naval_Attack_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'

local NotPrimaryBase = function( self,aiBrain,manager)

	if not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return 800, false
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

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .01 and aiBrain.NavalRatio < 6) then
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

        Priority = 700,
		
        InstanceCount = 7,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
		BuilderConditions = {

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},
			
		},
		
    },

}

BuilderGroup {BuilderGroupName = 'Sea Scout Formations - Small',
	BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Water Scout Formation - Small',
	
        PlatoonTemplate = 'T1WaterScoutForm',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ScoutingAI',

        Priority = 700,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
		BuilderConditions = {

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},
			
		},
		
    },
}


BuilderGroup {BuilderGroupName = 'Sea Attack Formations',
    BuildersType = 'PlatoonFormBuilder',
	
	-- goes after enemy mass extractors
    Builder {BuilderName = 'MEX Attack Naval',
	
        PlatoonTemplate = 'MassAttackNaval',
		
		PlatoonAIPlan = 'GuardPointAmphibious',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = IsEnemyNavalActive,
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.SUBMARINE }},
			
        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			MissionTime = 1200,		-- 20 minute mission			
			
			PointType = 'Unit',
			PointCategory = categories.ECONOMIC * categories.STRUCTURE,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 2000,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 2000,
			
			StrCategory = categories.STRUCTURE * categories.DEFENSE,
			StrRadius = 32,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 15,
			
			UntCategory = categories.NAVAL * categories.MOBILE,
			UntRadius = 64,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 20,
			
            PrioritizedCategories = { 'ECONOMIC','STRUCTURE' },
			
			GuardRadius = 45,
			GuardTimer = 10,
			
			MergeLimit = 18,
			
			AggressiveMove = true,
			
			AllowInWater = "Only",
			
			UseFormation = 'AttackFormation',
			
        },

    },	


    Builder {BuilderName = 'T1 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Small',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 700,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 1,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DEFENSIVEBOAT }},

        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
			MissionTime = 480,		-- 8 minute mission
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL MOBILE','ECONOMIC STRUCTURE', },
			
        },
		
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Aeon',
	
        PlatoonTemplate = 'SeaAttack Small',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 700,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 2,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},

        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
			MissionTime = 480,		-- 8 minute mission
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL MOBILE','ECONOMIC STRUCTURE', },
			
        },
		
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Small',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 700,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 3,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 2 } },
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.DEFENSIVEBOAT }},

        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
			MissionTime = 480,		-- 8 minute mission
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL MOBILE','ECONOMIC STRUCTURE', },
			
        },
		
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Small',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 700,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 4,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.SUBMARINE }},

        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
			MissionTime = 480,		-- 8 minute mission
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL MOBILE','ECONOMIC STRUCTURE', },
			
        },
		
    },

	
    Builder {BuilderName = 'T2 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Medium',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 705,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 1,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.DEFENSIVEBOAT }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
			
        },
	
    },
	
    Builder {BuilderName = 'T2 Sea Attack - Aeon',
	
        PlatoonTemplate = 'SeaAttack Medium',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 705,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 2,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
			
        },
	
    },
	
    Builder {BuilderName = 'T2 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Medium',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 705,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 3,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DEFENSIVEBOAT }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
			
        },
	
    },
	
    Builder {BuilderName = 'T2 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Medium',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 705,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 4,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.SUBMARINE }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 12,
			
			MissionTime = 720,		-- 12 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL', },
			
        },
	
    },

	
    Builder {BuilderName = 'T3 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Large',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 710,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 1,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},

        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1200,		-- 20 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
			
        },

    },
	
    Builder {BuilderName = 'T3 Sea Attack - Aeon',
	
        PlatoonTemplate = 'SeaAttack Large',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 710,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 2,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP - categories.xas0306}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.xas0306}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.DEFENSIVEBOAT }},

        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1200,		-- 20 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
			
        },

    },
	
    Builder {BuilderName = 'T3 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Large',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 710,

		PriorityFunction = IsPrimaryBase,
		
		FactionIndex = 3,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.DEFENSIVEBOAT }},

        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1200,		-- 20 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
			
        },

    },

    Builder {BuilderName = 'T3 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Large',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 710,

		PriorityFunction = IsPrimaryBase,

		FactionIndex = 4,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE }},
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1200,		-- 20 minute mission
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
			
        },

    },

	
    Builder {BuilderName = 'Sea Attack - Bombardment',
	
        PlatoonTemplate = 'SeaAttack Bombardment',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'BombardForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 810,

		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ LUTL, 'NavalStrengthRatioGreaterThan', { 2 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.BOMBARDMENT}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.CRUISER }},
			
        },
		
        BuilderData = {
			
			MissionTime = 1500,		-- 30 minute mission
			
			UseFormation = 'DMSCircleFormation',
			
			PrioritizedCategories = { 'ECONOMIC', 'FACTORY','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
			
        },

    },

	
    Builder {BuilderName = 'Naval Base Patrol',
	
        PlatoonTemplate = 'SeaAttack Medium - Base Patrol',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 710,
		
		PriorityFunction = IsEnemyNavalActive,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 75,
			
			PatrolTime = 300,	-- 5 minutes
			PatrolType = true,
			
        },
		
        BuilderConditions = {
		
			{ TBC, 'ThreatCloserThan', { 'LocationType', 500, 30, 'Naval' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},
			
        },
		
    },
	
    Builder {BuilderName = 'Naval Base Sub Patrol',
	
        PlatoonTemplate = 'SeaAttack Submarine - Base Patrol',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 710,
		
		PriorityFunction = IsEnemyNavalActive,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 75,
			
			PatrolTime = 300,	-- 5 minutes
			PatrolType = true,
			
        },
		
        BuilderConditions = {
		
			{ TBC, 'ThreatCloserThan', { 'LocationType', 500, 30, 'Naval' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
			
        },
		
    },

	
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
	
	Builder {BuilderName = 'Reinforce Primary - Naval',
	
        PlatoonTemplate = 'SeaAttack Reinforcement',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceNavalAI',
		
        Priority = 10,

		PriorityFunction = NotPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.SUBMARINE + categories.xes0102 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },    
    },
	
}