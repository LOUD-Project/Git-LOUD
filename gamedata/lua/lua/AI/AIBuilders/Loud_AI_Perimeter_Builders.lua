-- /lua/ai/Loud_AI_Perimeter_Builders.lua
-- Constructs Perimeter Defenses at Production Bases versus internal defenses 

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

-- Just a note -- many of these builders use the 'BasePerimeterSelection = true' function
-- This will direct the AI to build only one of these positions at a time -- selecting randomly
-- from the available positions (which depends upon the BasePerimeterOrientation)
-- This keeps the AI in check when building these expensive items rather than building
-- all the positions in a single go 
-- the only exception is the shields which, when they meet conditions, all positions will be produced

BuilderGroup {BuilderGroupName = 'T1 Perimeter Defenses',
    BuildersType = 'EngineerBuilder',
	

    Builder {BuilderName = 'T1 Perimeter PD - Small Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 795,
		
		
		PriorityFunction = function(self, aiBrain)
			
			if self.Priority != 0 then
			
				if (ScenarioInfo.size[1] >= 1028 or ScenarioInfo.size[2] >= 1028) then
					return 0, false
				end
				
				-- remove after 30 minutes
				if aiBrain.CycleTime > 1800 then
					return 0, false
				end
				
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEnergyIncome', { 400 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			-- dont have any advanced power built -- makes this gun obsolete
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.STRUCTURE - categories.TECH1 }},
			-- the 12 accounts for the 12 T1 Base PD that may get built in this ring
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 12, categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE, 50, 75}},
			
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T1 Perimeter AA - Small Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)
			
			if (ScenarioInfo.size[1] >= 1028 or ScenarioInfo.size[2] >= 1028) then
				return 0, false
			end
			
			-- remove after 30 minutes
			if aiBrain.CycleTime > 1800 then
				return 0, false
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEnergyIncome', { 400 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			-- dont have any advanced units
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE - categories.TECH1 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 12, categories.STRUCTURE * categories.ANTIAIR, 45, 75}},
			
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1AADefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T1 Perimeter PD - Large Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain)

			if self.Priority != 0 then
			
				if (ScenarioInfo.size[1] <= 1028 or ScenarioInfo.size[2] <= 1028) then
					return 0, false
				end
				
				-- remove after 30 minutes
				if aiBrain.CycleTime > 1800 then
					return 0, false
				end
				
			end
			
			return self.Priority		
			
		end,
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEnergyIncome', { 400 }},			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- dont have any advanced units
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE - categories.TECH1 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 12, categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE}},
			
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterSelection = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T1 Perimeter AA - Large Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 700,

		PriorityFunction = function(self, aiBrain)
			
			if (ScenarioInfo.size[1] <= 1028 or ScenarioInfo.size[2] <= 1028) then
				return 0, false
			end
			
			-- remove after 30 minutes
			if aiBrain.CycleTime > 1800 then
				return 0, false
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEnergyIncome', { 400 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
			-- dont have any advanced units
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE - categories.TECH1 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 12, categories.STRUCTURE * categories.ANTIAIR, 45, 75}},
			
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1AADefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T1 Perimeter AA - Response',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 10,

		PriorityFunction = function(self, aiBrain)
		
			-- remove after 30 minutes
			if aiBrain.CycleTime > 1800 then
				return 0, false
			end
			
			-- turn on after 8 minutes
			if aiBrain.CycleTime > 480 then
				return 800, true
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioLessThan', { 3 }},
			-- dont have any advanced units
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE - categories.TECH1 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.ANTIAIR, 45, 75}},
			
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
			
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1AADefense'},
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'T2 Perimeter Defenses',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T2 Perimeter TMD',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 740,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			-- check for less than 18 T2 TMD 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH2, 45, 85 }},
			
        },
		
		BuilderType = { 'T2','T3' },

        BuilderData = {
		
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T2MissileDefense'},
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T2 Perimeter Artillery',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
        Priority = 740,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			-- check for less than 27 Arty structures in perimeter
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 27, categories.STRUCTURE * categories.ARTILLERY * categories.TECH2, 45, 85 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T2Artillery'},
				
            }
			
        }
		
    },
	
--[[	
    Builder {BuilderName = 'T2 Perimeter PD',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 750,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
			
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			-- check perimeter for less than 36 T2 PD
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 36, categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE * categories.TECH2, 50, 80 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
            Construction = {
				Radius = 68,
				Iterations = 9,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
                BuildStructures = {
					'T2GroundDefense',
                },
            }
        }
    },
	
    Builder {BuilderName = 'T2 Perimeter AA',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 750,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'AirStrengthRatioLessThan', { 3 }},
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
			
			{ TBC, 'ThreatCloserThan', { 'LocationType', 450, 35, 'Air' }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			-- check perimeter for less than 18 T2 AA
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 24, categories.STRUCTURE * categories.ANTIAIR * categories.TECH2, 50, 80 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
            Construction = {
				Radius = 68,
				Iterations = 12,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
                BuildStructures = {
					'T2AADefense',
                    'T2AADefense',
                },
            }
        }
    },

    Builder {BuilderName = 'T2 Perimeter Wall',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 700,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			
			{ TBC, 'ThreatCloserThan', { 'LocationType', 450, 75, 'Land' }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 9, categories.DIRECTFIRE * categories.STRUCTURE, 60, 80 }},
        },
		
		BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				Radius = 68,
				AddRotations = 1,
				Iterations = 9,
                NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
                BuildStructures = {
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
					'T2Wall',
                },
            }
        }
    },
--]]	
}

BuilderGroup {BuilderGroupName = 'T3 Perimeter Defenses',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T3 Perimeter PD',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 2,
		
        Priority = 750,
		
        BuilderConditions = {
		
			{ LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check outer perimeter for maximum T3 PD
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 45, categories.STRUCTURE * categories.DIRECTFIRE * categories.TECH3, 55, 95 }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				ThreatMax = 30,	

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3GroundDefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Perimeter AA',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 2,
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },		
			{ LUTL, 'AirStrengthRatioLessThan', { 3 }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check outer perimeter for maximum T3 AA
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 36, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 55, 88 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				ThreatMax = 25,	
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3AADefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Perimeter Shields',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			-- check the outer perimeter for shields
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.SHIELD, 60, 88 }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3ShieldDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T4 Perimeter AA',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 730,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'AirStrengthRatioLessThan', { 3 }},			
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ANTIAIR, 50, 88 }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            NumAssistees = 4,
			
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,

				BasePerimeterOrientation = 'FRONT',				
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T4AADefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T4 Perimeter PD',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 730,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.STRUCTURE * categories.EXPERIMENTAL * categories.DIRECTFIRE, 50, 88 }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T4GroundDefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'AntiNuke Perimeter',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 730,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3, 50, 88 }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 1, categories.NUKE * categories.SILO + categories.SATELLITE, 'Enemy' }},
			
        },
		
		BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3StrategicMissileDefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Sera Perimeter Restoration Field',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		FactionIndex = 4,

        Priority = 730,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.bsb4205, 50, 88 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'RestorationField'},
				
            }
			
        }
		
    },
	
}

-- shield augmentation comes in the form of storage around shields which (in LOUD)
-- provides size, strength and recharge bonuses
BuilderGroup {BuilderGroupName = 'Perimeter Shield Augmentation',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T3 Perimeter Shield Augmentation',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 750,
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check the outer perimeter for shields
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 6, categories.STRUCTURE * categories.SHIELD, 60, 80 }},
			-- check outer perimeter for storage
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 54, categories.ENERGYSTORAGE * categories.TECH3, 60, 80 }}, 
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
                },
            }
        }
    },
}

-- the picket line is the outermost belt of defense - usually just AA
BuilderGroup {BuilderGroupName = 'Picket Line Defenses',
	BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T3 Picket AA',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 750,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- must have less than 27 T3 AA in picket positions
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 36, (categories.STRUCTURE * categories.ANTIAIR) * categories.TECH3, 90, 120 }},
        },
		
		BuilderType = { 'T3' },

        BuilderData = {
            Construction = {
			
				Radius = 100,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {
					'T3AADefense',
                    'T3AADefense',
					'T3AADefense',
                },
            }
        }
    },			
}


BuilderGroup {BuilderGroupName = 'T2 Perimeter Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Perimeter PD - Expansion',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 710,
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},
			
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check perimeter for less than 24 T2 PD
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.DIRECTFIRE * categories.TECH2, 46, 75 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },		

        BuilderData = {
            Construction = {
			
				AddRotations = 1,			
				Radius = 55,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {
                    'T2GroundDefense',
					'T2GroundDefense',
                },
            }
        }
    },
	
    Builder {BuilderName = 'T2 Perimeter AA - Expansion',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 710,
        BuilderConditions = {
			{ LUTL, 'AirStrengthRatioLessThan', { 3 }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 450, 35, 'Air' }},

			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check perimeter for less than 24 T2 AA
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.ANTIAIR * categories.TECH2, 46, 75 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {
					'T2AADefense',
                    'T2AADefense',
					'T2MissileDefense',
                },
            }
        }
    },
	
    Builder {BuilderName = 'T2 Perimeter TMD - Expansion',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		InstanceCount = 1,
        Priority = 710,
        BuilderConditions = {
			{ LUTL, 'AirStrengthRatioLessThan', { 3 }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 450, 35, 'Air' }},

			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check perimeter for less than 24 T2 AA
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH2, 46, 75 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {
					'T2MissileDefense',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'T3 Perimeter Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T3 Perimeter PD - Expansion',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 700,
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },			
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check outer perimeter for maximum T3 PD
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.DIRECTFIRE * categories.STRUCTURE * categories.TECH3, 46, 75 }},

        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {
					'T3GroundDefense',
                    'T3GroundDefense',
                },
            }
        }
    },
	
    Builder {BuilderName = 'T3 Perimeter AA - Expansion',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 700,
        BuilderConditions = {
			{ LUTL, 'AirStrengthRatioLessThan', { 3 }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 450, 35, 'Air' }},
			
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check outer perimeter for maximum T3 AA
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, (categories.STRUCTURE * categories.ANTIAIR) * categories.TECH3, 46, 75 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
            Construction = {
			
				AddRotations = 1,
				Radius = 55,
				
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {
					'T3AADefense',
                    'T3AADefense',
                },
            }
        }
    },

    Builder {BuilderName = 'T3 Perimeter Shields - Expansion',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 700,
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },			
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			-- check outer perimeter for maximum T3 PD
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.SHIELD * categories.STRUCTURE, 46, 75 }},

        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {
					'T3ShieldDefense',
                },
            }
        }
    },

}


