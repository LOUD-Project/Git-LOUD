--   /lua/ai/Loud_AI_Artillery_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'


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


BuilderGroup {BuilderGroupName = 'Artillery Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Artillery T3',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan20MinutesRemain,

        BuilderConditions = {

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, (categories.ARTILLERY * categories.STRUCTURE) - categories.TECH2 }},
            { UCBC, 'CheckUnitRange', { 'LocationType', 'T3Artillery', (categories.STRUCTURE * categories.TECH3) - categories.MASSEXTRACTION - categories.MASSSTORAGE} },
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
			
				Radius = 52,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
                BuildStructures = {
                    'T3Artillery',
                },
            }
        }
    },
	
	-- this platoon covers Mavor, Scathis, Ylonna Oss & Salvation
    Builder {BuilderName = 'Artillery Experimental',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan30MinutesRemain,

		InstanceCount = 1,
		
        BuilderConditions = {
	
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.ueb2401 + categories.xab2307 + categories.url0401 + categories.xsb2401 }},

        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 6,
			
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
                BuildStructures = {
                    'T4Artillery',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Artillery Builders - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Artillery T3 Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan20MinutesRemain,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, (categories.ARTILLERY * categories.STRUCTURE) - categories.TECH2 }},

            { UCBC, 'CheckUnitRange', { 'LocationType', 'T3Artillery', categories.STRUCTURE - categories.MASSEXTRACTION - categories.TECH1} },
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
            Construction = {
			
				Radius = 48,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
                BuildStructures = {
                    'T3Artillery',
                },
            }
        }
    },

    Builder {BuilderName = 'Artillery Experimental Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan30MinutesRemain,

		InstanceCount = 1,
		
        BuilderConditions = {

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.ueb2401 + categories.xab2307 + categories.url0401 + categories.xsb2401 }},

        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 6,
			
            Construction = {
			
				Radius = 46,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,

                BuildStructures = {
                    'T4Artillery',
                },
            }
        }
    },
}


BuilderGroup {BuilderGroupName = 'Nuke Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Nuke Silo',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan30MinutesRemain,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.NUKE * categories.STRUCTURE }},			

        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Nuke Builders - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Nuke Silo - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan30MinutesRemain,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, (categories.STRUCTURE * categories.SHIELD) }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.NUKE * categories.STRUCTURE }},			

        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
			
				Radius = 1,

				NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },
}



BuilderGroup {BuilderGroupName = 'Artillery Formations',
    BuildersType = 'PlatoonFormBuilder',
	
	Builder {BuilderName = 'T3 Artillery Formation',
        PlatoonTemplate = 'StrategicArtilleryStructure',
        Priority = 600,
        InstanceCount = 12,
        BuilderType = 'Any',
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ARTILLERY * categories.STRUCTURE - categories.TECH2 } },
        },
    },
}

BuilderGroup {BuilderGroupName = 'Nuke Formations',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Nuke Silo Formation',
        PlatoonTemplate = 'T3Nuke',
        Priority = 800,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.STRATEGIC * categories.STRUCTURE * categories.NUKE } },
        },
    },
}

