--  Loud_AI_Engineer_Factory_Builders.lua
--- tasks for building additional factories and gates

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

-- this function will turn a builder on if there are no factories
local HaveZeroFactories = function( self, aiBrain )

    if aiBrain.CycleTime > 90 then
	
        if table.getn( aiBrain:GetListOfUnits( categories.FACTORY, false, true )) < 1 then
	
            return 990, true
		
        end
        
    end

	return self.Priority, false

end

-- In LOUD, construction of new factories is controlled by three things
-- the cap check, which comes from the BaseTemplateFile, controls the max number of factories by type
-- the balance between land and air factories -- we try to keep them in lock step with each other
-- the eco conditions -- sufficient storage -- and an economy that's been positive for a while
BuilderGroup {BuilderGroupName = 'Engineer Factory Construction',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory Rebuild',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroFactories,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
        },
		
        BuilderType = { 'Commander','T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 50,
				
                BuildStructures = {'T1LandFactory'},
            }
        }
    },
	
    Builder {BuilderName = 'Air Factory Rebuild',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroFactories,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
        },
		
        BuilderType = { 'Commander','T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 50,
				
                BuildStructures = {'T1AirFactory'},
            }
        }
    },	
    
    Builder {BuilderName = 'Land Factory Balance',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.LAND * categories.TECH1 }},
            { UCBC, 'FactoryRatioGreaterOrEqualAtLocation', { 'LocationType', categories.AIR, categories.LAND } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
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
	-- this insures that when eco conditions are met - this will get built ahead of land factories
    Builder {BuilderName = 'Air Factory Balance',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 801,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.AIR * categories.TECH1 }},
            { UCBC, 'FactoryRatioGreaterOrEqualAtLocation', { 'LocationType', categories.LAND, categories.AIR } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
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

BuilderGroup {BuilderGroupName = 'Engineer Factory Construction - Expansions',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory Rebuild - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroFactories,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
        },
		
        BuilderType = {'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 50,
				
                BuildStructures = {'T1LandFactory' },
            }
        }
    },
	
    Builder {BuilderName = 'Land Factory Balance - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 755,
        
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.LAND * categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
        },
		
        BuilderType = {'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 50,
				
                BuildStructures = {'T1LandFactory' },
            }
        }
    },

    Builder {BuilderName = 'Air Factory Balance - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR' }},
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.AIR * categories.TECH1 }},
            { UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', categories.AIR, categories.LAND } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
        },
		
        BuilderType = {'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 50,
				
                BuildStructures = { 'T1AirFactory' },
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Factory Construction - Naval',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Naval Factory Builder',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'SEA' }},
            
            -- this was intended to minimize naval factory spam by
            -- only adding another factory if we had less than 2 T1 already here
            -- in practice - this sometimes just forced the creation of another
            -- naval yard if available
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 4, categories.NAVAL * categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.02 }},
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
                NearBasePerimeterPoints = true,
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
				ThreatMax = 50,
				
                BuildStructures = {'T1SeaFactory' },
            },
        },
    },

}


-- In the Standard base, the Gate is built to the rear of base -- see radius	
BuilderGroup {BuilderGroupName = 'Engineer Quantum Gate Construction',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 980,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.TECH3 * categories.GATE }},
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.TECH3 * categories.GATE }},
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
				
				ThreatMax = 50,

                BuildStructures = {'T3QuantumGate'},
            }
        }
    },
	
}

-- In a small base, the Gate is tucked into the interior -- note the radius value
BuilderGroup {BuilderGroupName = 'Engineer Quantum Gate Construction - Small Base',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 980,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.TECH3 * categories.GATE }},
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.TECH3 * categories.GATE }},
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
				
				ThreatMax = 50,

                BuildStructures = {'T3QuantumGate' },
            }
        }
    },
	
}