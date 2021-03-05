--  Loud_AI_Engineer_Intel_Builders.lua
--- Builds all intelligence gathering units such
--- as air and land scouts, radar, sonar & optics 

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

BuilderGroup {BuilderGroupName = 'Engineer Radar Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Radar Engineer Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',

				MaxThreat = 30,
                
                BuildStructures = { 'T1Radar' },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Sonar Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sonar Engineer',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderType = { 'T2' },
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYSONAR * categories.INTELLIGENCE }},
			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.MOBILESONAR * categories.INTELLIGENCE * categories.TECH3 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
        },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = { 'T2Sonar' },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Counter Intel Builders',
    BuildersType = 'EngineerBuilder',

}


BuilderGroup {BuilderGroupName = 'Engineer Optics Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Optics Cybran',
    
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		FactionIndex = 3,
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 650,
        
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.OPTICS }},
        },
		
        BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
				Radius = 1,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				Iterations = 1,
                BuildStructures = { 'T3Optics' },
            }
        }
    },
    
    Builder {BuilderName = 'Optics Aeon',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		FactionIndex = 2,
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 700,
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
            { LUTL, 'UnitCapCheckLess', { .75 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.OPTICS }},
        },
		
        BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
				Radius = 1,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				Iterations = 1,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
                BuildStructures = { 'T3Optics' },
            }
        }
    },
}