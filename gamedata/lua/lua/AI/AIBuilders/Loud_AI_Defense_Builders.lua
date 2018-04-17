-- /lua/ai/Loud_AI_Defense_Builders.lua
-- Constructs Base & Extractor Defenses

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function(self,aiBrain,manager)

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .01 and aiBrain.NavalRatio < 6) then
	
		return self.Priority, true	-- standard naval priority -- 

	end

	return 10, true
	
end


BuilderGroup {BuilderGroupName = 'Base Defenses',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T1 Base PD - Small Maps',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 700,
		
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
		
			{ EBC, 'GreaterThanEnergyIncome', { 240 }},
			-- dont build if we have built any advanced power -- obsolete
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.STRUCTURE - categories.TECH1 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE, 30, 50}},
			
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				Radius = 36,
                NearBasePerimeterPoints = true,
				ThreatMax = 30,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,	-- pick a random point from the 9 FRONT rotations

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1GroundDefense'},
				
            }
			
        }
		
    },	

    Builder {BuilderName = 'T2 Base PD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 24, categories.STRUCTURE * categories.DIRECTFIRE, 14, 38 }},
			
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T2 Base AA - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.ANTIAIR, 14, 38 }},
			
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 45,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2AADefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T2 Base TMD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 745,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH2, 14, 38 }},
			
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 45,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2MissileDefense' },
				
            }
			
        }
		
    },	

    Builder {BuilderName = 'T2 TML - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 745,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },			
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.TACTICALMISSILEPLATFORM * categories.STRUCTURE, 10, 40 }},			
			
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 45,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = {'T2StrategicMissile'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Base PD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 12, categories.STRUCTURE * categories.DIRECTFIRE * categories.TECH3, 15, 42 }},
			
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T3GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 Base AA - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750, 
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 12, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 15, 42 }},
			
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
				BuildStructures = {'T3AADefense' },
				
            }
			
        }
		
    },
	
	-- setup so that we always build one
    Builder {BuilderName = 'AntiNuke',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 900,
		
        BuilderConditions = {
		
			--{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
		    { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3 }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = {'T3StrategicMissileDefense'},
				
            }
			
        }
		
    },
	
	-- will build more if enemy has more than 1
    Builder {BuilderName = 'AntiNuke - Response',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 900,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3, 5, 45 }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 1, categories.NUKE * categories.SILO + categories.SATELLITE, 'Enemy' }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 30,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = {'T3StrategicMissileDefense'},
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Experimental Base Defenses',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Experimental PD',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
			{ LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.EXPERIMENTAL * categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE, 10, 40 }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T4GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'Experimental AA Defense',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},			
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.EXPERIMENTAL * categories.DEFENSE * categories.STRUCTURE * categories.ANTIAIR, 10, 40 }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 45,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T4AADefense'},
				
            }
			
        }
		
    },
	
}


BuilderGroup {BuilderGroupName = 'Base Defenses - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Base PD - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 12, categories.STRUCTURE * categories.DIRECTFIRE * categories.TECH2, 14, 48 }},
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T2 Base AA - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.ANTIAIR * categories.TECH2, 14, 48 }},
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 30,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2AADefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T2 Base TMD - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH2, 15, 48 }},
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 30,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2MissileDefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T2 TML - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.TACTICALMISSILEPLATFORM * categories.STRUCTURE, 15, 48 }},			
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
            Construction = {

				NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2StrategicMissile'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 Base AA - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750, 
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 15, 48 }},
			
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {

				NearBasePerimeterPoints = true,
				
				ThreatMax = 30,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				BuildStructures = {'T3AADefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 Base PD - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.TECH3 * categories.DIRECTFIRE, 15, 48 }},
			
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
			
				Radius = 1,			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3GroundDefense'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'AntiNuke - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 900,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3 }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3StrategicMissileDefense'},
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Experimental Base Defenses - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Experimental PD - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.EXPERIMENTAL * categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T4GroundDefense'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Experimental AA Defense - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.EXPERIMENTAL * categories.DEFENSE * categories.STRUCTURE * categories.ANTIAIR }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 45,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T4AADefense'},
				
            }
			
        }
		
    },
	
}


BuilderGroup {BuilderGroupName = 'Base Defenses - Naval',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Defenses Naval',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.ANTINAVY * categories.TECH2, 50, 85 }},
			
        },
		
		BuilderType = { 'T2','T3' },

        BuilderData = {
		
            Construction = {
			
				Radius = 63,
				AddRotations = 1,
                NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'NavalPerimeterDefenseTemplate',
				
                BuildStructures = {
					'T2AADefenseAmphibious',
					'T2NavalDefense',
					'T2MissileDefense',					
					'T2NavalDefense',					
                },
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Defenses Naval',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 50, 85 }},
			
        },
		
		BuilderType = { 'T3','SubCommander'},

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 63,
				AddRotations = 1,
                NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'NavalPerimeterDefenseTemplate',
				
                BuildStructures = {
					'T3AADefense',
					'T3NavalDefense',
				},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Base AA - Naval',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 720,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderConditions = {
		
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 1, 40 }},
			
        },
		
		BuilderType = { 'T3','SubCommander'},

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {

                NearBasePerimeterPoints = true,
				
				ThreatMax = 15,

				BasePerimeterSelection = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = {'T3AADefense'},
				
            }
			
        }
		
    },	

    Builder {BuilderName = 'Naval AntiNuke',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3 }},
			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
                NearBasePerimeterPoints = true,
				ThreatMax = 30,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = {'T3StrategicMissileDefense'},
				
            }
			
        }
		
    },
	
}



BuilderGroup {BuilderGroupName = 'Misc Engineer Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Staging',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM }},
			
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = false,
			
			Construction = {
			
				Radius = 50,			
                NearBasePerimeterPoints = true,
				
				ThreatMax = 30,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3AirStagingComplex',
				
                BuildStructures = {'T2AirStagingPlatform'},
				
            }
			
        }
		
    },	
	
    Builder {BuilderName = 'T3 Teleport Jamming',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 0,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			-- trigger this build if enemy has an Aeon scry device
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.AEON * categories.OPTICS * categories.STRUCTURE, 'Enemy' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ANTITELEPORT * categories.STRUCTURE * categories.TECH3 }},
			
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			Construction = {
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
                BuildStructures = {'T3TeleportJammer'},
				
            }
			
        }
		
    },	
	
}

BuilderGroup {BuilderGroupName = 'Misc Engineer Builders - Small Base',
    BuildersType = 'EngineerBuilder',

	
    Builder {BuilderName = 'Air Staging - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM }},
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
			DesiresAssist = false,
			
			Construction = {
			
				Radius = 40,			
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3AirStagingComplex',
				
                BuildStructures = {'T2AirStagingPlatform'},
				
            }
			
        }
		
    },	
	
    Builder {BuilderName = 'T3 Teleport Jamming - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 0,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			-- trigger this build if enemy has an Aeon scry device
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.AEON * categories.OPTICS * categories.STRUCTURE, 'Enemy' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ANTITELEPORT * categories.STRUCTURE * categories.TECH3 }},
			
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			Construction = {
				
				MaxThreat = 45,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = {'T3TeleportJammer'},
				
            }
			
        }
		
    },	
	
}

BuilderGroup {BuilderGroupName = 'Misc Engineer Builders - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Staging - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM }},
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
			DesiresAssist = true,
			
			Construction = {
			
                NearBasePerimeterPoints = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2AirStagingPlatform'},
				
            }
			
        }
		
    },	
	
    Builder {BuilderName = 'T2 Radar Jamming - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.COUNTERINTELLIGENCE * categories.STRUCTURE }},
			
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
		
			Construction = {
			
				Radius = 1,			
				NearBasePerimeterPoints = true,
				
				MaxThreat = 30,
				
				BasePerimeterOrientation = 'FRONT',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2RadarJammer'},
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Teleport Jamming - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 0,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			-- trigger this build if enemy has an Aeon scry device
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.AEON * categories.OPTICS * categories.STRUCTURE, 'Enemy' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ANTITELEPORT * categories.STRUCTURE * categories.TECH3 }},

        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			Construction = {
			
				Radius = 1,
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3TeleportJammer' },
				
            }
			
        }
		
    },	
	
}

BuilderGroup {BuilderGroupName = 'Misc Engineer Builders - Naval',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Naval AirStaging',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 720,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM }},
			
        },
		
		BuilderType = { 'T2','T3' },

        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = {'T2AirStagingPlatform' },
            }
			
        }
		
    },	
	
}


BuilderGroup {BuilderGroupName = 'Mass Adjacency Defenses',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Extractor Defense',
	
        PlatoonTemplate = 'MassAdjacencyDefenseEngineer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'MassExtractorHasStorageAndLessDefense', { 'LocationType', 150, 1000, 2, 4, categories.STRUCTURE * categories.DEFENSE }},

        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				LoopBuild = true,
				
				MinRadius = 150,
				Radius = 1000,
				
				MinStorageUnits = 2,
				MaxDefenseStructures = 4,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {
                    'T2AADefense',
					'T2GroundDefense',
                    'T2AADefense',
					'T2GroundDefense',
                }
            }
        }
    },
	
    Builder {BuilderName = 'T3 Extractor Defense',
	
        PlatoonTemplate = 'MassAdjacencyDefenseEngineer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
			{ LUTL, 'NeedTeamMassPointShare', {}},
            { LUTL, 'UnitCapCheckLess', { .65 } },			
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'MassExtractorHasStorageAndLessDefense', { 'LocationType', 150, 1000, 3, 3, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 }},
			
        },
		
        BuilderType = {'T3'},
		
        BuilderData = {
		
            Construction = {
			
				MinRadius = 150,
				Radius = 1000,
				
				MinStorageUnits = 3,
				MaxDefenseStructures = 3,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {
                    'T3AADefense',
					'T3GroundDefense',
					'T3AADefense',
                    'T2MissileDefense',
					'T1MassCreation',
					'T3ShieldDefense',
                }
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Mass Adjacency Defenses - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Extractor Defense - LOUD_IS',
	
        PlatoonTemplate = 'MassAdjacencyDefenseEngineer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'MassExtractorInRangeHasLessThanDefense', { 'LocationType', 150, 1000, 4 }},

        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				LoopBuild = true,
				
				MinRadius = 150,
				Radius = 1000,
				
				MinStorageUnits = 0,
				MaxDefenseStructures = 4,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {
                    'T2AADefense',
					'T2GroundDefense',
                    'T2AADefense',
					'T2GroundDefense',
                }
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T3 Extractor Defense - LOUD_IS',
	
        PlatoonTemplate = 'MassAdjacencyDefenseEngineer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
		
			{ LUTL, 'NeedTeamMassPointShare', {}},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'MassExtractorInRangeHasLessThanDefense', { 'LocationType', 150, 1000, 4 }},
        },
		
        BuilderType = {'T3'},
		
        BuilderData = {
		
            Construction = {
			
				MinRadius = 150,
				Radius = 1000,
				
				MinStorageUnits = 0,
				MaxDefenseStructures = 4,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {
                    'T3AADefense',
					'T3GroundDefense',
					'T3AADefense',
                    'T2MissileDefense',
					'T1MassCreation',
					'T3ShieldDefense',
                }
				
            }
			
        }
		
    },
	
}
