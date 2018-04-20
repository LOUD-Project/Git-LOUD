--  /lua/ai/Loud_AI_Shield_Builders.lua
--  Constructs Shields at Bases (but not DPs)

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

BuilderGroup {BuilderGroupName = 'Shields',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Base - Inner',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4+ factories at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE}},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayoutInner',
                BuildStructures = {
                    'T2ShieldDefense',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },
	
    Builder {BuilderName = 'Shields - Base - Outer',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4 inner shields
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 3, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
			-- and less than 8 shields in the Base - Outer ring
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD, 16, 45 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
                BuildStructures = {
                    'T3ShieldDefense',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },
	
	Builder {BuilderName = 'Shield Augmentations',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 750,
		
		InstanceCount = 2,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 10, categories.STRUCTURE * categories.SHIELD, 0,45 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
                BuildStructures = {
					'EnergyStorage',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Shields - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Base - Inner - IS ',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4+ factories at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE}},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayoutInner',
                BuildStructures = {
                    'T2ShieldDefense',
                },
            }
        }
    },
	
    Builder {BuilderName = 'Shields - Base - Outer - IS',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4 inner shields
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 3, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
			-- and less than 8 shields in the Base - Outer ring
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD, 16, 45 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
                BuildStructures = {
                    'T3ShieldDefense',
                },
            }
        }
    },	
}

BuilderGroup {BuilderGroupName = 'Shields - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Expansion - Inner',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4+ factories at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE}},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                BuildStructures = {
                    'T2ShieldDefense',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },

    Builder {BuilderName = 'Shields - Expansion - Outer',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4 inner shields
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 3, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
			-- and less than 8 shields in the Base - Outer ring
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD, 16, 45 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                BuildStructures = {
                    'T3ShieldDefense',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Shields - Expansions - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Expansion - Inner - IS ',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4+ factories at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE}},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {
                    'T2ShieldDefense',
                },
            }
        }
    },	
	
    Builder {BuilderName = 'Shields - Expansion - Outer - IS',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		InstanceCount = 1,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- must have 4 inner shields
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 3, categories.STRUCTURE * categories.SHIELD, 5, 16 }},
			-- and less than 8 shields in the Base - Outer ring
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD, 16, 45 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 30,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                BuildStructures = {
                    'T3ShieldDefense',
                },
            }
        }
    },	
}

BuilderGroup {BuilderGroupName = 'Shields - Experimental',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Experimental Shield',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

		-- this should turn this off if there is less than 30 minutes left in the game
		PriorityFunction = function(self, aiBrain)
			
			if aiBrain.VictoryTime then
			
				if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 45 ) ) then	-- less than 45 minutes left
				
					return 0, true
					
				end

			end
			
			return self.Priority, false
		
		end,
		
        Priority = 750,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 5, categories.ENERGYPRODUCTION * categories.TECH3 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			-- must have at least 1 Experimental level defense ?
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.DEFENSE * categories.STRUCTURE }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.SHIELD }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				MaxThreat = 45,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayoutInner',
				
                BuildStructures = {
					'T4ShieldDefense',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Shields - Experimental - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Experimental Shield - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 5, categories.ENERGYPRODUCTION * categories.TECH3 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			-- must have at least 1 Experimental level defense ?
			--{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.DEFENSE * categories.STRUCTURE }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.SHIELD }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 45,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                BuildStructures = {
					'T4ShieldDefense',
                },
            }
        }
    },
}

