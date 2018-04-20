--  Loud_AI_Factory_Builders.lua
--- tasks for building additional factories and gates

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

BuilderGroup {BuilderGroupName = 'Factory Construction',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory Rebuild',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 990,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ MIBC, 'GreaterThanGameTime', { 210 } },
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.LAND - categories.GATE }},			
			
        },
		
        BuilderType = { 'Commander','T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1LandFactory'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Air Factory Rebuild',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 990,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ MIBC, 'GreaterThanGameTime', { 210 } },
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.AIR }},			
			
        },
		
        BuilderType = { 'Commander','T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1AirFactory'},
				
            }
			
        }
		
    },	
	
    Builder {BuilderName = 'Land Factory Balance',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.LAND * categories.TECH1 }},
            { UCBC, 'FactoryRatioGreaterOrEqualAtLocation', { 'LocationType', categories.AIR, categories.LAND } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.78, 20, 1.02, 1.02 }},

        },
		
        BuilderType = { 'Commander','T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1LandFactory' },
				
            }
			
        }
		
    },
    
	-- Note how Air Factories have higher priority but are limited by the Ratio Check
	-- this insures that when eco conditions are met - this will get reviewed ahead of land factories
    Builder {BuilderName = 'Air Factory Balance',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 801,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.AIR * categories.TECH1 }},
            { UCBC, 'FactoryRatioGreaterOrEqualAtLocation', { 'LocationType', categories.LAND, categories.AIR } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.73, 25, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'Commander','T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1AirFactory' },
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Factory Construction - Expansions',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory Rebuild - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 990,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.FACTORY }},
        },
		
        BuilderType = {'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1LandFactory' },
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Land Factory Balance - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 755,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.LAND * categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 20, 1.02, 1.02 }},
			
        },
		
        BuilderType = {'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1LandFactory' },
				
            }
			
        }
		
    },

    Builder {BuilderName = 'Air Factory Balance - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.AIR * categories.TECH1 }},
            { UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', categories.AIR, categories.LAND } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.75, 25, 1.02, 1.02 }},
			
        },
		
        BuilderType = {'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 30,
				
                BuildStructures = { 'T1AirFactory' },
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Naval Factory Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Naval Factory Builder',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
			
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'SEA' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.NAVAL * categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.78, 20, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1SeaFactory' },
				
            },
			
        },
		
    },
	
}


-- In the Standard base, the Gate is built to the rear of base -- see radius	
BuilderGroup {BuilderGroupName = 'Quantum Gate Construction',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 980,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.GATE }},
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.GATE }},
			
        },
		
        BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
			
				Radius = 42,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 30,

                BuildStructures = {'T3QuantumGate'},
				
            }
			
        }
		
    },
	
}

-- In a small base, the Gate is tucked into the interior -- note the radius value
BuilderGroup {BuilderGroupName = 'Quantum Gate Construction - Small Base',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 980,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.GATE }},
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.GATE }},
			
        },
		
        BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
			
				Radius = 18,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 45,

                BuildStructures = {'T3QuantumGate' },
				
            }
			
        }
		
    },
	
}
