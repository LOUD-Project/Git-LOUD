--  Loud_AI_Naval_Attack_Builders.lua

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local TBC   = '/lua/editor/ThreatBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'
local BHVR  = '/lua/ai/aibehaviors.lua'

local NotPrimaryBase = function( self,aiBrain,manager)

	if aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.OldPriority or self.Priority, true
	end

	return 650, true
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.OldPriority or self.Priority, true
	end

	return 10, true
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function(self,aiBrain,manager)

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .011 and aiBrain.NavalRatio <= 10) then
		return self.OldPriority or self.Priority, true
	end

	return 10, true
	
end

local PlatoonCategoryCount                  = moho.platoon_methods.PlatoonCategoryCount
local PlatoonCategoryCountAroundPosition    = moho.platoon_methods.PlatoonCategoryCountAroundPosition

local BATTLESHIP    = categories.BATTLESHIP
local BOMBARD       = categories.BOMBARDMENT
local CRUISER       = categories.CRUISER
local DEFENSIVE     = categories.DEFENSIVEBOAT
local DESTROYER     = categories.DESTROYER
local FRIGATE       = categories.FRIGATE
local SUBMARINE     = categories.SUBMARINE + categories.xes0102

BuilderGroup {BuilderGroupName = 'Sea Scout Formations',
	BuildersType = 'PlatoonFormBuilder',

    Builder {BuilderName = 'Water Scout Formation',
	
        PlatoonTemplate = 'T1WaterScoutForm',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'}  },

		PlatoonAddPlans = { 'DistressResponseAI', 'PlatoonCallForHelpAI' },		

		PlatoonAIPlan = 'ScoutingAI',

        Priority = 740,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 740 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, SUBMARINE, manager.Location, manager.Radius ) < 7 then
                    return 10,true
                else
                    return 740,true
                end
                
            else
                return 10, true
            end
        end,

        InstanceCount = 5,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
		},
    },
}

BuilderGroup {BuilderGroupName = 'Sea Scout Formations - Small',
	BuildersType = 'PlatoonFormBuilder',

    Builder {BuilderName = 'Water Scout Formation - Small',
	
        PlatoonTemplate = 'T1WaterScoutForm',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAddPlans = { 'DistressResponseAI', 'PlatoonCallForHelpAI' },		

		PlatoonAIPlan = 'ScoutingAI',

        Priority = 740,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 740 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, SUBMARINE, manager.Location, manager.Radius ) < 7 then
                    return 10,true
                else
                    return 740,true
                end
                
            else
                return 10, true
            end
        end,

        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
		},
    },
}


BuilderGroup {BuilderGroupName = 'Naval Formations',
    BuildersType = 'PlatoonFormBuilder',

	-- we always hunt water MEX
    Builder {BuilderName = 'Sub Sea Attack MEX',
	
        PlatoonTemplate = 'MassAttackNaval',
		
		PlatoonAIPlan = 'GuardPointNaval',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'DistressResponseAI', 'PlatoonCallForHelpAI' },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 750 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, SUBMARINE, manager.Location, manager.Radius ) < 7 then
                    return 10,true
                else
                    return 750,true
                end
                
            else
                return 10, true
            end
        end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
        },
		
        BuilderData = {
			DistressRange = 160,
            DistressReactionTime = 32,
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
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


    -- SEA ATTACK formations only appear when there is enemy Naval Activity
    -- T1 Sea Attack only forms when Naval Ratio < 4 to conserve units for bigger formations when ratio is higher
    Builder {BuilderName = 'T1 Sea Attack - UEF',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 750 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, FRIGATE, manager.Location, manager.Radius ) < 5 then
                    return 10,true
                else
                    return 750,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 1,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 4 } },

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 160,
            DistressReactionTime = 32,            
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

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 750 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, FRIGATE, manager.Location, manager.Radius ) < 5 then
                    return 10,true
                else
                    return 750,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 2,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 4 } },            
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 160,
            DistressReactionTime = 32,            
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
			MissionTime = 600,		-- 10 minute mission
            SearchRadius = 180,     -- use Prioritized Categories as primary target selection
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','ECONOMIC STRUCTURE', },
        },
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Cybran',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 750 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, FRIGATE, manager.Location, manager.Radius ) < 5 then
                    return 10,true
                else
                    return 750,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 3,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 4 } },            

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 160,
            DistressReactionTime = 32,            
			DistressTypes = 'Naval',
			DistressThreshold = 8,

			MissionTime = 600,		-- 10 minute mission
            SearchRadius = 180,     -- use Prioritized Categories as primary target selection
            
			UseFormation = 'AttackFormation',

			PrioritizedCategories = { 'NAVAL FACTORY','NAVAL MOBILE','ECONOMIC STRUCTURE', },
        },
    },
	
    Builder {BuilderName = 'T1 Sea Attack - Sera',
	
        PlatoonTemplate = 'SeaAttack Small',

		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAIPlan = 'AttackForceAI',

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        Priority = 750,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 750 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, FRIGATE, manager.Location, manager.Radius ) < 5 then
                    return 10,true
                else
                    return 750,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 4,

        InstanceCount = 3,

		RTBLocation = 'Any',

        BuilderType = 'Any',

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 4 } },

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, CRUISER }},
        },
		
        BuilderData = {
			DistressRange = 160,
            DistressReactionTime = 32,            
			DistressTypes = 'Naval',
			DistressThreshold = 8,
			
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 751 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 1 then
                    return 10,true
                else
                    return 751,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 1,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 185,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 751 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 1 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 751,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 2,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, DEFENSIVE }},
        },
		
        BuilderData = {
		
			DistressRange = 185,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 751 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 1 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 751,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 3,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 185,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 751 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 1 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 751,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 4,
		
        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
        },
		
        BuilderData = {
			DistressRange = 185,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 752 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 3 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 752,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 1,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, BATTLESHIP }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 225,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 752 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 3 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 752,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 2,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 225,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 752 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 3 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 752,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 3,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, DEFENSIVE }},
        },
		
        BuilderData = {
			DistressRange = 225,
            DistressReactionTime = 32,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 752 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BATTLESHIP ) < 3 then
                    return 10,true
                elseif PlatoonCategoryCount( aiBrain.ArmyPool, SUBMARINE ) < 6 then
                    return 10,true
                else
                    return 752,true
                end
                
            else
                return 10, true
            end
        end,

		FactionIndex = 4,
		
        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, BATTLESHIP}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, DESTROYER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, CRUISER }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, FRIGATE }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, SUBMARINE }},
        },
		
        BuilderData = {
			DistressRange = 225,
            DistressReactionTime = 32,            
			DistressTypes = 'Naval',
			DistressThreshold = 15,
			
			MissionTime = 1500,		-- 25 minute mission
            SearchRadius = 220,     -- use Prioritized Categories as primary target selection            
			
			UseFormation = 'GrowthFormation',
			
			PrioritizedCategories = { 'NAVAL','SUBCOMMANDER','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND', },
        },
    },

    -- NAVAL BOMBARDMENT
    Builder {BuilderName = 'Sea Attack - Local Raiding',
	
        PlatoonTemplate = 'SeaAttack Local',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'BombardForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 752,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 752 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, FRIGATE, manager.Location, manager.Radius ) < 5 then
                    return 10,true
                else
                    return 752,true
                end
                
            else
                return 10, true
            end
        end,

        InstanceCount = 1,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { 0.5 } },
            { LUTL, 'NavalStrengthRatioLessThan', { 1.5 } },
        },
		
        BuilderData = {
        
            BombardRange = 30,
            
            MergeLimit = 12,
            
            MissionRadius = 750,    -- radius for target position acquisition
			
			MissionTime = 720,		-- 12 minute mission
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'ECONOMIC','ENGINEER','NAVAL','LAND' },
        },
    },

    Builder {BuilderName = 'Sea Attack - Coastal Raiding',
	
        PlatoonTemplate = 'SeaAttack Raiding',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'BombardForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 753,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 753 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, FRIGATE, manager.Location, manager.Radius ) < 5 then
                    return 10,true
                else
                    return 753,true
                end
                
            else
                return 10, true
            end
        end,

		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { 1.5 } },
        },
		
        BuilderData = {
        
            BombardRange = 32,
            
            MergeLimit = 12,
            
            MissionRadius = 1200,
			
			MissionTime = 1500,		-- 25 minute mission
			
			UseFormation = 'AttackFormation',
			
			PrioritizedCategories = { 'ECONOMIC','FACTORY','ENGINEER','DEFENSE','NAVAL','LAND' },
        },
    },
    
    Builder {BuilderName = 'Sea Attack - Bombardment',
	
        PlatoonTemplate = 'SeaAttack Bombardment',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'BombardForceAI',		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 754,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 754 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, BOMBARD ) < 4 then
                    return 10,true
                else
                    return 754,true
                end
                
            else
                return 10, true
            end
        end,

        InstanceCount = 3,
		
		RTBLocation = 'Any',
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { 4 } },
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, BOMBARD}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, CRUISER }},
        },
		
        BuilderData = {
        
            BombardRange = 100,
            
            MissionRadius = 1800,
			
			MissionTime = 2700,		-- 45 minute mission
			
			UseFormation = 'LOUDClusterFormation',
			
			PrioritizedCategories = { 'ECONOMIC', 'FACTORY','EXPERIMENTAL NAVAL','EXPERIMENTAL STRUCTURE','EXPERIMENTAL LAND','NAVAL','LAND' },
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
			{ TBC, 'ThreatCloserThan', { 'LocationType', 250, 75, 'Naval' }},
        },
    },
--]]
	
    Builder {BuilderName = 'Naval Base Sub Patrol',
	
        PlatoonTemplate = 'SeaAttack Submarine - Base Patrol',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 745,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, SUBMARINE, manager.Location, manager.Radius ) < 4 then
                return 10,true
            else
                return 745,true
            end
        end,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 250, 75, 'Naval' }},
        },
		
        BuilderData = {
			DistressRange = 200,
            DistressReactionTime = 32,
			DistressTypes = 'Naval',
			DistressThreshold = 6,
			
			BasePerimeterOrientation = '',
			
			Radius = 75,
			
			PatrolTime = 240,	-- 4 minutes
			PatrolType = true,
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
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 250, 'Naval', 300 }},            
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },    
    },
	
}