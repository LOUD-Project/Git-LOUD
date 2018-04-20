#**  File     :  /lua/ai/Loud_AI_Air_Attack_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'


local NotPrimaryBase = function( self,aiBrain,manager)

	if (not aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase) and (not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase)  then
		return 700, false
	end

	return self.Priority, true
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.Priority, true
	end

	return 10, true
end


BuilderGroup {BuilderGroupName = 'Air Hunt Formations',
    BuildersType = 'PlatoonFormBuilder',
	
	-- this will forward ANY bombers to the primary land attack base
    Builder {BuilderName = 'Reinforce Bomber Squadron',
	
        PlatoonTemplate = 'BomberReinforce',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 1,
        Priority = 10,
		
		PriorityFunction = NotPrimaryBase,
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
            LocationType = 'LocationType',
			
        },
		
        BuilderType = 'Any',
		
    },  
	
	-- this will forward ANY Gunships to either primary land or sea attack base
    Builder {BuilderName = 'Reinforce Gunship Squadron',
	
        PlatoonTemplate = 'GunshipReinforce',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },

        InstanceCount = 1,
        Priority = 10,

		PriorityFunction = NotPrimaryBase,

        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.GROUNDATTACK }},
			
        },
		
        BuilderData = {
		
            LocationType = 'LocationType',
			
        },    
		
        BuilderType = 'Any',
    },

	-- this will forward ALL Fighters to either primary land or sea attack base
    Builder {BuilderName = 'Reinforce Fighter Squadron',
	
        PlatoonTemplate = 'FighterReinforce',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 1,
        Priority = 10,

		PriorityFunction = NotPrimaryBase,
		
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        }, 
		
        BuilderType = 'Any',		
    },
	
	-- small groups kept close to home for defensive work and distress response
    Builder {BuilderName = 'Hunt Bombers Defensive',
	
        PlatoonTemplate = 'BomberAttackSmall',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 700,
        InstanceCount = 4,
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Land',
			DistressThreshold = 4,
			
			LocationType = 'LocationType',
			
            MergeLimit = 12,
			
            MissionTime = 150,
			
            PrioritizedCategories = {categories.MOBILE - categories.AIR, categories.ENGINEER, categories.STRUCTURE},
			
			SearchRadius = 150,	
			
            UseFormation = 'AttackFormation',
			
        },
		
        BuilderType = 'Any',
		
    },

    Builder {BuilderName = 'Hunt Gunships Defensive',
	
        PlatoonTemplate = 'GunshipAttackSmall',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 700,
        InstanceCount = 4,

        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.GROUNDATTACK }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Land',
			DistressThreshold = 4,
			LocationType = 'LocationType',
            MergeLimit = 24,
            MissionTime = 150,
            PrioritizedCategories = {categories.MOBILE - categories.AIR, categories.MASSEXTRACTION, categories.INTELLIGENCE - categories.AIR, categories.ENGINEER},
			SearchRadius = 125,
            UseFormation = 'AttackFormation',
			
        },
		
        BuilderType = 'Any',
    },
	
	-- medium sized group for close targets and distress response
    Builder {BuilderName = 'Hunt Bombers Local',
	
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 700,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioLessThan', { 3 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 9, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			DistressRange = 350,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			LocationType = 'LocationType',
			
            MergeLimit = 20,
			
            MissionTime = 180,
			
            PrioritizedCategories = { categories.MOBILE - categories.AIR, categories.MASSEXTRACTION, categories.ENERGYPRODUCTION - categories.TECH1, categories.FACTORY},
			
			SearchRadius = 200,
			
            UseFormation = 'AttackFormation',
			
        },
		
        BuilderType = 'Any',
    },

    Builder {BuilderName = 'Hunt Gunships Local',
	
        PlatoonTemplate = 'GunshipAttack',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 700,
		
        InstanceCount = 2,

        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 15, categories.AIR * categories.GROUNDATTACK }},
			
        },
		
        BuilderData = {
		
			DistressRange = 300,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			LocationType = 'LocationType',
            MergeLimit = 64,
            MissionTime = 180,
            PrioritizedCategories = {categories.GROUNDATTACK, categories.EXPERIMENTAL - categories.AIR, categories.MOBILE - categories.AIR, categories.ECONOMIC, categories.ENGINEER, categories.NUKE, categories.DEFENSE - categories.WALL},
			SearchRadius = 200,
            UseFormation = 'AttackFormation',
			
        },
		
        BuilderType = 'Any',
    },	
	
	-- large group for most targets on 20k maps and distress response
	-- only run if the unit based triggers for the SUPER groups are all false
    Builder {BuilderName = 'Hunt Bombers Large',
	
        PlatoonTemplate = 'BomberAttack Large',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 700,

		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },  
			
			-- none of the SUPER triggers can be true
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, (categories.OPTICS + categories.ORBITALSYSTEM) * categories.STRUCTURE, 'Enemy' }},
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ARTILLERY * categories.STRUCTURE - categories.TECH2, 'Enemy' }},
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},			
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 28, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			DistressRange = 450,
			DistressTypes = 'Land',
			DistressThreshold = 20,
			LocationType = 'LocationType',
            MergeLimit = 64,
            MissionTime = 420,
            PrioritizedCategories = {categories.COMMAND, categories.SUBCOMMANDER, categories.MOBILE - categories.AIR, categories.MASSEXTRACTION, categories.SHIELD, categories.FACTORY, categories.ECONOMIC - categories.TECH1},
			SearchRadius = 375,
            UseFormation = 'AttackFormation',
			
        },
		
        BuilderType = 'Any',
    },
	
    Builder {BuilderName = 'Hunt Gunships Large',
	
        PlatoonTemplate = 'GunshipAttack',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 700,

		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },  
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 15, categories.AIR * categories.GROUNDATTACK }},
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Land',
			DistressThreshold = 15,
			LocationType = 'LocationType',
            MergeLimit = 64,
            MissionTime = 480,
            PrioritizedCategories = {categories.COMMAND, categories.SUBCOMMANDER, categories.MOBILE - categories.AIR, categories.MASSEXTRACTION, categories.SHIELD, categories.FACTORY, categories.ECONOMIC - categories.TECH1},
			SearchRadius = 350,
            UseFormation = 'AttackFormation',
			
        },
		
        BuilderType = 'Any',
    },
	
	-- ALL SUPER groups are specifically targeted and come into play when the selected targets are available
	-- the DO NOT respond to distress calls	-- they'll search for targets upto 30km away
	-- they all have short mission timers so they go - fight - and go home
    Builder {BuilderName = 'Hunt Bombers - Nuke Antinuke',
	
        PlatoonTemplate = 'BomberAttack Super',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},						
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 28, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.NUKE + categories.ANTIMISSILE - categories.TECH2, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR},
			SearchRadius = 1000,
            UseFormation = 'AttackFormation',
			
        },
    },
	
    Builder {BuilderName = 'Hunt Bombers - Optics',
	
        PlatoonTemplate = 'BomberAttack Super',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, (categories.OPTICS + categories.ORBITALSYSTEM) * categories.STRUCTURE, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 28, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = { (categories.OPTICS + categories.ORBITALSYSTEM) * categories.STRUCTURE},
			SearchRadius = 1000,
            UseFormation = 'AttackFormation',
			
        },
		
    },
	
    Builder {BuilderName = 'Hunt Bombers - Artillery',
	
        PlatoonTemplate = 'BomberAttack Super',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ARTILLERY * categories.STRUCTURE - categories.TECH2, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 28, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.ARTILLERY * categories.STRUCTURE - categories.TECH2, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR},
			SearchRadius = 1000,
            UseFormation = 'AttackFormation',
			
        },
		
    },
	
    Builder {BuilderName = 'Hunt Bombers - Economic Experimental',
	
        PlatoonTemplate = 'BomberAttack Super',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 28, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.ECONOMIC * categories.EXPERIMENTAL, categories.MASSFABRICATION},
			SearchRadius = 1000,
            UseFormation = 'AttackFormation',
			
        },
    },
	
}

BuilderGroup {BuilderGroupName = 'Point Guard Air Formations',
    BuildersType = 'PlatoonFormBuilder',

    -- forms patrols around a base and distress response
    Builder {BuilderName = 'Home Fighter Squadron',
	
        PlatoonTemplate = 'FighterSquadron',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        Priority = 710,
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 360,
			DistressTypes = 'Air',
			DistressThreshold = 6,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'BASE',
			PointSourceSelf = true,
			PointFaction = 'Self',
			PointRadius = 150,
			PointSort = 'Closest',
			PointMin = 0,
			PointMax = 150,
			
			StrCategory = nil,
			StrRadius = 50,
			StrTrigger = false,
			StrMin = 0,
			StrMax = 0,
			
			UntCategory = nil,
			UntRadius = 50,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 0,
			
            PrioritizedCategories = {'AIR MOBILE -INTELLIGENCE'},
			
			GuardRadius = 400,
			GuardTimer = 120,
			
			MissionTime = 180,
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 95,
			
        },    
    },
	
	-- forms patrols around vacant DPs (within 5k) and distress response
    Builder {BuilderName = 'Standard Fighter Squadron DP',
	
        PlatoonTemplate = 'FighterSquadron',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 700,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Air',
			DistressThreshold = 6,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',		-- find closest DP marker within 200-500 --
			PointCategory = { 'Defensive Point', 'Naval Defensive Point' },
			PointSourceSelf = true,
			PointFaction = 'Self',
			PointRadius = 750,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 750,
			
			StrCategory = categories.AIRSTAGINGPLATFORM - categories.MOBILE,	-- go only to those that DONT have an airstaging pad --
			StrRadius = 50,
			StrTrigger = true,
			StrMin = -1,		--<< notice use of negative values to induce a NOT condition
			StrMax = -1,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,	-- and those that have less than 20 there already
			UntRadius = 90,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 20,
			
            PrioritizedCategories = {'AIR EXPERIMENTAL', 'TRANSPORTFOCUS', 'BOMBER', 'GROUNDATTACK', 'AIR MOBILE -OVERLAYOMNI'},
			
			GuardRadius = 300,
			GuardTimer = 120,	-- patrol there for 2 minutes --
			
			MissionTime = 360,	-- 6 minutes --
			
			MergeLimit = 50,	-- merge upto 50 units
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 40,
			
        },    
    },
	
    Builder {BuilderName = 'Home Gunship Squadron',
	
        PlatoonTemplate = 'GunshipSquadron',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 700,
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.GROUNDATTACK }},
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Land',
			DistressThreshold = 6,
            LocationType = 'LocationType',
			PointType = 'Marker',
			PointCategory = 'BASE',
			PointSourceSelf = true,
			PointFaction = 'Self',
			PointRadius = 150,
			PointSort = 'Closest',
			PointMin = 0,
			PointMax = 150,
			StrCategory = nil,
			StrRadius = 50,
			StrTrigger = false,
			StrMin = 0,
			StrMax = 0,
			UntCategory = nil,
			UntRadius = 50,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 0,
            PrioritizedCategories = {'GROUNDATTACK, LAND MOBILE, MASSEXTRACTION, STRUCTURE -WALL, AIR MOBILE -HIGHALTAIR, NAVAL MOBILE', },
			GuardRadius = 280,
			GuardTimer = 150,
			MissionTime = 210,
			MergeLimit = 60,
			AggressiveMove = true,
			UseFormation = 'GrowthFormation',
			SetPatrol = true,
			PatrolRadius = 85,
			
        },    
    },

	-- forms  patrols around Expansion Base markers
    Builder {BuilderName = 'Standard Fighter Squadron Expansion',
	
        PlatoonTemplate = 'FighterSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 0,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 1250,
			DistressTypes = 'Air',
			DistressThreshold = 5,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'Large Expansion Area',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 250,
			PointMax = 4000,
			
			StrCategory = categories.AIRSTAGINGPLATFORM - categories.MOBILE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 6,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,
			UntRadius = 90,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 50,
			
            PrioritizedCategories = {'AIR EXPERIMENTAL', 'TRANSPORTFOCUS', 'BOMBER', 'GROUNDATTACK', 'AIR MOBILE -OVERLAYOMNI'},
			
			GuardRadius = 375,
			GuardTimer = 600,
			
			MergeLimit = 50,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 75,
			
        },    
    },

	-- forms patrols around Mass points that are open
    Builder {BuilderName = 'Standard Fighter Squadron Mass Point',
	
        PlatoonTemplate = 'FighterSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 0,
		
		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			
			{ EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 150, 1, 'AntiAir', 1 }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 1024,
			DistressTypes = 'Air',
			DistressThreshold = 10,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'Mass',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 750,
			PointSort = 'Closest',
			PointMin = 250,
			PointMax = 750,
			
			StrCategory = categories.MASSEXTRACTION,
			StrRadius = 10,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 0,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,
			UntRadius = 90,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 20,
			
            PrioritizedCategories = {'AIR EXPERIMENTAL', 'TRANSPORTFOCUS', 'BOMBER', 'GROUNDATTACK', 'AIR MOBILE -OVERLAYOMNI'},
			
			GuardRadius = 250,
			GuardTimer = 90,
			
			MergeLimit = 50,
			
			AggressiveMove = false,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 55,
			
        },
	},

    Builder {BuilderName = 'Standard Gunship Squadron Mass Point',
	
        PlatoonTemplate = 'GunshipSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 700,
		
		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.GROUNDATTACK }},
			{ EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 30, 1, 'AntiAir', 1 }},
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Air',
			DistressThreshold = 8,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',			
			PointCategory = 'Mass',
			PointSourceSelf = true,			
			PointFaction = 'Ally',	 		
			PointRadius = 750,		    	
			PointSort = 'Closest',			
			PointMin = 200,					
			PointMax = 750,
			
			StrCategory = categories.MASSEXTRACTION,
			StrRadius = 10,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 15,
			
			UntCategory = (categories.AIR * categories.GROUNDATTACK) - categories.EXPERIMENTAL,
			UntRadius = 90,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 16,
			
            PrioritizedCategories = {'GROUNDATTACK, LAND MOBILE, MASSEXTRACTION, STRUCTURE -WALL'},
			
			GuardRadius = 200,
			GuardTimer = 120,
			
			MergeLimit = 50,
			
			AggressiveMove = false,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 55,
			
        },
	},
}

BuilderGroup {BuilderGroupName = 'Air Formations - Water Map',

	BuildersType = 'PlatoonFormBuilder',

    Builder {BuilderName = 'Home Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoSquadron',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        Priority = 700,
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
			
        },
		
        BuilderData = {
		
			DistressRange = 600,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',			-- either Unit or Marker
			PointCategory = 'BASE',
			PointSourceSelf = true,			-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Self',	 		-- must be either Ally, Enemy or Self - determines which Structures and Units to check
			PointRadius = 150,				-- controls the finding of points based upon distance from PointSource
			PointSort = 'Closest',			-- options are Closest or Furthest
			PointMin = 1,					-- allows you to filter found points by range from PointSource
			PointMax = 150,					-- as above
			
			StrCategory = nil,				
			StrRadius = 50,
			StrTrigger = false,				
			StrMin = 0,
			StrMax = 0,
			
			UntCategory = nil,				
			UntRadius = 50,
			UntTrigger = false,				
			UntMin = 0,
			UntMax = 0,
			
            PrioritizedCategories = {'NAVAL MOBILE, NAVAL STRUCTURE'},
			
			GuardRadius = 700,				-- controls the range at which platoon will engage targets
			GuardTimer = 180,				-- controls period that platoon will guard the point before looking for another
			
			MergeLimit = 36,				-- controls trigger level at which merging is prohibited - nil = original platoon size
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 125,
			MissionTime = 400,
			
        },    
    },
	
    Builder {BuilderName = 'Naval Base Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        Priority = 710,
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
			{ UCBC, 'NavalBaseCount', { 0, '>' } },
			
        },
		
        BuilderData = {
		
			DistressRange = 600,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'Naval Area',
			
			PointSourceSelf = true,
			PointFaction = 'Self',
			
			PointRadius = 1024,
			PointSort = 'Closest',
			PointMin = 150,
			PointMax = 1024,
			
			StrCategory = categories.STRUCTURE * categories.FACTORY * categories.NAVAL,
			StrRadius = 75,
			StrTrigger = true,
			StrMin = 1,
			StrMax = 99,
			
			UntCategory = nil,
			UntRadius = 50,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 0,
			
            PrioritizedCategories = {'NAVAL MOBILE, NAVAL STRUCTURE'},
			
			GuardRadius = 550,
			GuardTimer = 240,
			MergeLimit = 48,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 125,
			MissionTime = 480,
			
        },    
    },
 	
    Builder {BuilderName = 'Reinforce Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoReinforce',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 10,
		
		-- this function removes the builder 
		PriorityFunction = NotPrimaryBase,

        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.HIGHALTAIR * categories.ANTINAVY } },
			
        },
		
        BuilderData = {
		
            LocationType = 'LocationType',
			
        },    
    }, 	
    

    -- Naval Flotilla Air Groups
    ----------------------------
    Builder {BuilderName = 'Naval Fighter Squadron',
	
        PlatoonTemplate = 'FighterSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        Priority = 0,	--700,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CARRIER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 500,
			DistressTypes = 'Air',
			DistressThreshold = 15,
			
            LocationType = 'LocationType',
			
			PointType = 'Unit',
			PointCategory = categories.CARRIER,
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 200,
			PointMax = 9999999,
			
			StrCategory = categories.CARRIER,
			StrRadius = 65,
			StrTrigger = true,
			StrMin = 1,
			StrMax = 12,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 50,
			
            PrioritizedCategories = {'AIR MOBILE'},
			
			GuardRadius = 300,
			GuardTimer = 360,
			
			MergeLimit = 50,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			SetPatrol = true,
			PatrolRadius = 60,
			
        },    
    },     
	
    Builder {BuilderName = 'Naval Gunship Squadron',
	
        PlatoonTemplate = 'GunshipSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 0,	--700,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.GROUNDATTACK }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + categories.CARRIER }},
        },
		
        BuilderData = {
		
            LocationType = 'LocationType',
			DistressRange = 300,
			PointType = 'Unit',
			PointCategory = categories.CARRIER,
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 200,
			PointMax = 9999999,
			StrCategory = categories.CARRIER,
			StrRadius = 65,
			StrTrigger = true,
			StrMin = 1,
			StrMax = 12,
			UntCategory = (categories.AIR * categories.GROUNDATTACK) - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL,
			UntRadius = 50,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 24,
            PrioritizedCategories = {'NAVAL MOBILE -SUBMERSIBLE', 'GROUNDATTACK', 'LAND MOBILE', 'STRUCTURE'},
			GuardRadius = 250,
			GuardTimer = 400,
			MergeLimit = 30,
			AggressiveMove = true,
			UseFormation = 'AttackFormation',
			
        },    
    },
	
    Builder {BuilderName = 'Naval Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        InstanceCount = 5,
		
        BuilderType = 'Any',
		
        Priority = 0,	--710,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + (categories.NAVAL * categories.CARRIER)}},
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Naval',
			DistressThreshold = 15,
            LocationType = 'LocationType',
			PointType = 'Unit',
			PointCategory = categories.CARRIER,
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 200,
			PointMax = 9999999,
			StrCategory = (categories.NAVAL * categories.CARRIER),
			StrRadius = 65,
			StrTrigger = true,
			StrMin = 1,
			StrMax = 12,
			UntCategory = categories.HIGHALTAIR * categories.ANTINAVY,
			UntRadius = 50,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 48,
            PrioritizedCategories = {'NAVAL MOBILE','NAVAL STRUCTURE'},
			GuardRadius = 225,
			GuardTimer = 420,
			MergeLimit = 48,
			AggressiveMove = true,
			UseFormation = 'AttackFormation',
        },    
    }, 
	
	-- torpedo bomber groups kept close to home for defensive work and distress response
	-- a short term formation that will merge up into larger groups
    Builder {BuilderName = 'Hunt Torps Defensive',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 710,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.HIGHALTAIR * categories.ANTINAVY } },
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			LocationType = 'LocationType',
            MergeLimit = 24,
            MissionTime = 150,
            PrioritizedCategories = {categories.SUBMARINE, categories.STRUCTURE, categories.MOBILE - categories.AIR},
			SearchRadius = 200,	
            UseFormation = 'AttackFormation',
			
        },
    },
	
	-- ALL these torpedo bomber groups are very specifically targeted and only come into play when the selected targets are available
	-- this first one hunts nukes and antinukes - but will go after mobile experimentals as well
    Builder {BuilderName = 'Hunt Torps - Nuke Antinuke',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },			
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 360,
            PrioritizedCategories = {categories.NUKE + categories.ANTIMISSILE - categories.TECH2, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR},
			SearchRadius = 500,
            UseFormation = 'AttackFormation',
			
        },
    },
	
	-- this one goes after sonar
    Builder {BuilderName = 'Hunt Torps - Sonar',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.SONAR * categories.STRUCTURE, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 360,
            PrioritizedCategories = { (categories.OPTICS + categories.ORBITALSYSTEM) * categories.STRUCTURE},
			SearchRadius = 500,
            UseFormation = 'AttackFormation',
			
        },
    },

	-- self explanatory - goes after Economic experimentals - but also massfabrication
    Builder {BuilderName = 'Hunt Torps - Economic Experimental',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
			
        },
		
        BuilderData = {
		
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 600,
            PrioritizedCategories = {categories.ECONOMIC * categories.EXPERIMENTAL, categories.MASSFABRICATION},
			SearchRadius = 500,
            UseFormation = 'AttackFormation',
			
        },
    },		    
}