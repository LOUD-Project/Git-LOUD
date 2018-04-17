--  Loud_AI_Experimental_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'

local LessThan20MinutesRemain = function(self, aiBrain)

	if aiBrain.VictoryTime then

		if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 20 ) ) then	-- less than 20 minutes left

			return 0, false

		end

	end

	return self.Priority, true

end

local LessThan30MinutesRemain = function(self, aiBrain)

	if aiBrain.VictoryTime then

		if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 30 ) ) then	-- less than 30 minutes left

			return 0, false

		end

	end

	return self.Priority, true

end

-- the key distinction here is that we don't want to be building Experimentals unless we have the army to back it up
-- this means we don't go experimental unless we have a decent army, air force or navy - so we use the ratios for that

-- alternatively, if we have the level of resources required - but not the force to back it up - we'll opt for nuke
-- or artillery over experimental - since they have no ratio requirement

-- Land Experimental are built using 4 definitions - the intention here is to have some economic control over which
-- ones get built - according to resource availability - lighter ones having lower eco needs

BuilderGroup {BuilderGroupName = 'Land Experimental Builders',
    BuildersType = 'EngineerBuilder',

-- This should be used for a light experimental - lowest eco requirements
    Builder {BuilderName = 'Land Experimental 1',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
		
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				Iterations = 1,			
                BuildStructures = {'T4LandExperimental1' },
				
            }
			
        }
		
    },
	
-- This one builds medium experimentals but has slightly higher eco needs
    Builder {BuilderName = 'Land Experimental 2',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4LandExperimental2'},
				
            }
			
        }
		
    },

-- This one builds heavy experimentals but has the highest eco needs
	Builder {BuilderName = 'Land Experimental 3',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.25 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 3,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4LandExperimental3' },
				
            }
			
        }
		
    },
	
-- This one builds the heaviest experiementals of all
	Builder {BuilderName = 'Land Experimental 4',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan30MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.25 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4LandExperimental4'},
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Land Experimentals - Expansions',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Exp 1 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 3,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,			
                BuildStructures = {'T4LandExperimental1'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Land Exp 2 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4LandExperimental2'},
				
            }
			
        }
		
    },
	
	Builder {BuilderName = 'Land Exp 3 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.25 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 3,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4LandExperimental3'},
				
            }
			
        }
		
    },
	
	Builder {BuilderName = 'Land Exp 4 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan30MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.25 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 8, 120, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 3,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4LandExperimental4'},
				
            }
			
        }
		
    },
	
}


BuilderGroup {BuilderGroupName = 'Air Experimental Builders - Land Map',
    BuildersType = 'EngineerBuilder',
	
-- Like the land experimentals - we Tier the AirExps in 2 groups 
-- We also have different priorities on land maps versus water maps - Air Exps more necessary on Water maps and trigger earlier
    Builder {BuilderName = 'Air Experimental - Land Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4AirExperimental1' },
				
            }
        }
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Land Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4AirExperimental2' },
				
            }
        }
    },
}	

BuilderGroup {BuilderGroupName = 'Air Experimental Builders - Water Map',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Experimental 1 - Water Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 50,
				
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				Iterations = 1,
				
                BuildStructures = { 'T4AirExperimental1' },
				
            }
        }
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Water Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
        },

        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 50,
				
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				Iterations = 1,
				
                BuildStructures = { 'T4AirExperimental2' },
				
            }
        }
    },
}

	
BuilderGroup {BuilderGroupName = 'Air Experimentals - Expansions - Land',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Experimental - Land Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4AirExperimental1' },
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Land Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = {'T4AirExperimental2'},
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Air Experimentals - Expansions - Water',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Experimental - Water Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },

        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = { 'T4AirExperimental1' },
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Water Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = { 'T4AirExperimental2' },
				
            }
			
        }
		
    },
	
}


BuilderGroup {BuilderGroupName = 'Land Experimental Formations',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Exp Land Scathis',
	
        PlatoonTemplate = 'T4ExperimentalScathis',
		
		FactionIndex = 3,
		
        Priority = 800,
		
        InstanceCount = 4,
		
		BuilderConditions = {
		
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.url0401} },
			
        },
		
        BuilderType = 'Any',
		
        BuilderData = {

            PrioritizedCategories = { 'EXPERIMENTAL STRUCTURE ARTILLERY', 'EXPERIMENTAL STRUCTURE ECONOMIC', 'COMMAND', 'FACTORY LAND', 'MASSPRODUCTION', 'ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE' },
			
        },
		
    },
	
	Builder {BuilderName = 'Exp Land Group',
	
        PlatoonTemplate = 'T4ExperimentalLandGroup',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 700,
		
		-- this function alters the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 800, true
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT }},
			--{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 20, (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT }},
			
		},
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Land',
			DistressThreshold = 15,
			
            PrioritizedCategories = { 'SHIELD','STRUCTURE','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 2000,			-- only process hi-priority targets within 17.5 km
			
			MergeLimit = 120,				# controls trigger level at which merging is allowed - nil = original platoon size
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },
	
	Builder {BuilderName = 'Exp Land Group - Forced',
	
        PlatoonTemplate = 'T4ExperimentalLandGroup',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
		
		-- this function alters the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 802, true
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 8, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT }},
			
		},
		
        BuilderData = {

            PrioritizedCategories = { 'SHIELD','STRUCTURE','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 4000,			-- all targets
			
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
				return 800, true
			end
			
			return 10, true
			
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.LAND } },
			
        },
		
        BuilderData = {
		
            UseFormation = 'GrowthFormation',
			
        },
		
    },

}

BuilderGroup {BuilderGroupName = 'Air Experimental Formations',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Experimental Bombers',
	
        PlatoonTemplate = 'Experimental Bomber',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'},{BHVR, 'AirForceAILOUD'} },		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 900,
		
		-- this function turns the builder off --
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 900, true
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },        
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.EXPERIMENTAL * categories.BOMBER } },
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Land',
			DistressThreshold = 15,
            MergeLimit = 6,
            MissionTime = 360,
            PrioritizedCategories = {categories.EXPERIMENTAL * categories.STRUCTURE, categories.NUKE, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR, categories.ECONOMIC * categories.TECH3, categories.COMMAND},
			SearchRadius = 1000,
            UseFormation = 'BlockFormation',
			
        },
		
    },
	
    Builder {BuilderName = 'Experimental Gunships',
	
        PlatoonTemplate = 'Experimental Gunship',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'},{BHVR, 'AirForceAILOUD'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 900,
		
		-- this function turns the builder off --
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 900, true
			end
			
			return 10, true
			
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.AIR * categories.EXPERIMENTAL * categories.GROUNDATTACK } },
			
        },
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Land',
			DistressThreshold = 15,
            MergeLimit = 6,
            MissionTime = 480,
            PrioritizedCategories = {categories.EXPERIMENTAL * categories.STRUCTURE, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR, categories.NUKE, categories.ECONOMIC * categories.TECH3, categories.COMMAND},
			SearchRadius = 1250,
            UseFormation = 'BlockFormation',
			
        },
		
    },
	
	Builder {BuilderName = 'Czar Group',
	
        PlatoonTemplate = 'T4ExperimentalAirCzar',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },

		PlatoonAIPlan = 'CzarAttack',
		
		FactionIndex = 2,
		
        Priority = 900,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 900, true
			end
			
			return 10, true
			
		end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.uaa0310 } },
			
		},
		
        BuilderData = {
		
			DistressRange = 400,
			DistressTypes = 'Land',
			DistressThreshold = 40,

            PrioritizedCategories = { 'ANTIAIR STRUCTURE', 'COMMAND', 'ANTIAIR', 'EXPERIMENTAL', 'ENERGYPRODUCTION', 'FACTORY', 'STRUCTURE' }, -- list in order
			
        },
		
    },

	Builder {BuilderName = 'Czar Terror Attack',
	
        PlatoonTemplate = 'CzarTerrorAttack',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
		FactionIndex = 2,
		
		PlatoonAIPlan = 'CzarAttack',
		
        Priority = 900,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 900, true
			end
			
			return 10, true
			
		end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.uaa0310 } },
            { LUTL, 'AirStrengthRatioGreaterThan', { 6 } },
			
		},
		
        BuilderData = {

            PrioritizedCategories = { 'EXPERIMENTAL MOBILE -AIR', 'FACTORY STRUCTURE -TECH1', 'EXPERIMENTAL STRUCTURE', 'COMMAND' }, -- list in order
			
        },
		
    },

	
	Builder {BuilderName = 'Reinforce Primary - Air Experimental',
	
		PlatoonTemplate = 'ReinforceAirExperimental',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 10,
		
		PriorityFunction = function(self, aiBrain, manager)
			
			if not aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase and not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 800, true
			end
			
			return 10, true
		end,
	
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.EXPERIMENTAL } },
			
        },
		
        BuilderData = {
		
            UseFormation = 'GrowthFormation',
			
        },
		
	},
  	
}


	
BuilderGroup {BuilderGroupName = 'Satellite Builders',
    BuildersType = 'EngineerBuilder',
	
    -- Builder {BuilderName = 'Satellite Experimental',
        -- PlatoonTemplate = 'EngineerBuilderGeneral',
		-- PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        -- Priority = 0, 
        -- BuilderConditions = {
			-- { MIBC, 'FactionIndex', { 1, 2} },
            -- { LUTL, 'UnitCapCheckLess', { .95 } },
			-- { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 8, 160 }},
            -- { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.15 }},
			-- { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.EXPERIMENTAL * categories.ORBITALSYSTEM}},
			-- { UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ORBITALSYSTEM}},

        -- },
        -- BuilderType = 'Any',
        -- BuilderData = {
            -- Construction = {
				-- Radius = 45,
                -- NearBasePerimeterPoints = true,
				-- BasePerimeterOrientation = 'FRONT',
				-- Iterations = 1,
                -- BuildStructures = {
                    -- 'T4SatelliteExperimental',
                -- },
            -- }
        -- }
    -- },
}


BuilderGroup {BuilderGroupName = 'Sea Experimental Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sea Experimental 1',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 47,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental1' },
				
            }
        }
    },
	
    Builder {BuilderName = 'Sea Experimental 2',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 47,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental2' },
				
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Sea Experimental Builders - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sea Experimental 1 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 36,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental1' },
				
            }
        }
    },
	
    Builder {BuilderName = 'Sea Experimental 2 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 36,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental2' },
				
            }
        }
    },
	
}


BuilderGroup {BuilderGroupName = 'Economic Experimental Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1, 1 }},
		   
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
				Radius = 52,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 3,
				
				Iterations = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
                    'T4EconExperimental',
					
					'T3ShieldDefense',
					'T3ShieldDefense',
					
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					
					'T3ShieldDefense',
					'T3ShieldDefense',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Economic Experimental Defense Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 52,
				
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 3,
				
				Iterations = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'T2ShieldDefense',
					'T2ShieldDefense',
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					'T2ShieldDefense',
					'T2ShieldDefense',
					
					'T4EconExperimental',	-- this is here so that engies will assist the experimental build if it's not done already
					
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',

--					'T3TeleportJammer',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Economic Experimental Defense Builders - LOUD_IS',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Economic Experimental Defenses - IS',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,

		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 52,
				
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 3,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					
					'T4EconExperimental',	-- this is here so that engies will assist the experimental build if it's not done already or the engy is destroyed while building paragon
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Economic Experimental Builders - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,
		
		PriorityFunction = LessThan30MinutesRemain,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
		   
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 10, (categories.STRUCTURE * categories.SHIELD) }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
                NearBasePerimeterPoints = true,			
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',

                BuildStructures = { 'T4EconExperimental' },
				
            }
        }
    },

}

BuilderGroup {BuilderGroupName = 'Economic Experimental Builders Naval',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental Naval',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan30MinutesRemain,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
                NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = { 'T4EconExperimental' },
				
            }
        }
    },

}