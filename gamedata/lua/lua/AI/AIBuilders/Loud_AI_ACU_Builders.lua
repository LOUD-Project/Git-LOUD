--- File     :  /lua/ai/Loud_AI_ACU_Builders.lua
--- tasks for ACU (Bob) including initial starting build and adding additional factories

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local BHVR = '/lua/ai/aibehaviors.lua'
local LUTL = '/lua/loudutilities.lua'

-- imbedded into the Builder
local First30Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 1800 then
		return 0, false
	end
	
	return self.Priority, true
end

-- Some notes here about the syntax of the Construction section of the builder task

-- There are several options that control 'where' structures are built but most 
-- important to the AI is the base template file - the base template file can have many
-- sections in it, each of which will detail the location of specific structures
-- the code will loop thru the BuildStructures specified to find a match - which in turn will
-- tell it the location relative to the centre point of the base -- if a location is already
-- used the code will continue looping to find the next match and thus the next location

-- By utilizing the NearBasePerimeter = true option, we force the code to build
-- the structuress according to the order listed in the file specified by BaseTemplate
-- therefore, you'll see this in many places, and it allows us to accurately determine
-- sequence, and take better advantage of adjacency bonuses -- especially early in game

-- Note: Keep in mind that lua data tables, while read in the order you see them, stores them
-- in keyed order, which is what makes this necessary

-- Special note - it will also rotate the entire template to orient FRONT 

-- if we dont use this, the AI will still utilize the locations specified in the BaseTemplate
-- but it will always choose one closest to the Location position -- from centre out

-- Also, note the use of the BuilderType = {'Commander'},
-- This new feature seperates the commanders tasks from the other engineers
-- saving both from processing tasks they can never do, or dont want them to do


--  COMMANDER STARTS BASE
BuilderGroup {BuilderGroupName = 'Loud Initial ACU Builders',
    BuildersType = 'EngineerBuilder',
	
--  All of these builders will get removed almost immediately but the ACU will select one of them first	
--  Also note: This is the only place where the CommanderThread gets launched
	
	-- If there is an enemy base with 500 always start with a Land factory
    Builder {BuilderName = 'CDR Initial Threat Nearby',
	
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'CommanderThread'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        PlatoonTemplate = 'CommanderBuilder',
		
        Priority = 999,
	
		-- this function removes the builder (like original function BuildOnce)
		PriorityFunction = function(self, aiBrain)
			return 0, false
		end,
		
        BuilderConditions = {
			-- Greater than 50 economy threat closer than 10km
			{ TBC, 'ThreatCloserThan', { 'LocationType', 500, 50, 'Economy' }},
        },
		
        BuilderType = { 'Commander' },
	
        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
                BuildStructures = {'T1LandFactory'}
				
            }
			
        }
		
    },

	-- Otherwise let map size determine to build Land or Air factory first
    Builder {BuilderName = 'CDR Initial Large Map',
	
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'CommanderThread'}, },

		PlatoonAIPlan = 'EngineerBuildAI',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 998,
	
		-- this function removes the builder (like original function BuildOnce)
		PriorityFunction = function(self, aiBrain)
			return 0, false
		end,
		
        BuilderConditions = {
			{ MIBC, 'MapGreaterThan', { 1024 } },
        },

        BuilderType = { 'Commander' },
	
        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
                BuildStructures = {'T1AirFactory'}
				
            }
			
        }
		
    },
	
	
    Builder {BuilderName = 'CDR Initial Small Map',
	
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'CommanderThread'}, },
		
		PlatoonAIPlan = 'EngineerBuildAI',
        PlatoonTemplate = 'CommanderBuilder',
		
        Priority = 998,
	
		-- this function removes the builder (like original function BuildOnce)
		PriorityFunction = function(self, aiBrain)
			return 0, false
		end,
		
        BuilderConditions = {
			{ MIBC, 'MapLessThan', { 1028 } },
        },
		
        BuilderType = { 'Commander' },
	
        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
                BuildStructures = {'T1LandFactory'}
            }
			
        }
		
    },
	
}

	--  COMMANDER TASKS AFTER START
BuilderGroup {BuilderGroupName = 'ACU Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'CDR - T1 Power',
	
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerBuildAI',
		
        Priority = 780,
		
		PriorityFunction = First30Minutes,
		
        BuilderConditions = { 
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'LessEconEnergyStorageCurrent', { 6000 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 45, 0 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.STRUCTURE - categories.TECH1 }},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = {'T1EnergyProduction'},
				
            }
			
        }
		
    },

    Builder {BuilderName = 'CDR Reclaim Mass',
	
        PlatoonTemplate = 'CommanderReclaim',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 750,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
		
			{ EBC, 'LessThanEconMassStorageRatio', { 20 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
			
        },
		
        BuilderData = {
			ReclaimTime = 45,
			ReclaimType = 'Mass',
        },

    },	
	
    Builder {BuilderName = 'CDR Assist Factory Upgrade',
	
        PlatoonTemplate = 'CommanderAssist',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.FACTORY }},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 100,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY,
				BeingBuiltCategories = {categories.FACTORY},
                Time = 75,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'CDR Assist Mass Upgrade',
	
        PlatoonTemplate = 'CommanderAssist',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 755,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.MASSPRODUCTION, categories.MASSPRODUCTION, 80 }},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 80,
				AssisteeType = 'Structure',
				AssisteeCategory = categories.MASSPRODUCTION,
                BeingBuiltCategories = {categories.MASSPRODUCTION},
                Time = 60,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'CDR Assist Energy',
	
        PlatoonTemplate = 'CommanderAssist',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 756,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 90 }},
			{ UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.ENERGYPRODUCTION, categories.ENGINEER + categories.ENERGYPRODUCTION, 80 }},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 80,
                AssisteeType = 'Any',
				AssisteeCategory = categories.ENGINEER + categories.ENERGYPRODUCTION,
                BeingBuiltCategories = { categories.ENERGYPRODUCTION },
                Time = 75,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'CDR Assist Structure Experimental',
	
        PlatoonTemplate = 'CommanderAssist',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL, categories.ENGINEER, 125 }},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = {categories.STRUCTURE, categories.EXPERIMENTAL},
                Time = 75,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'CDR T1 AA - Response - Small Maps',
	
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerBuildAI',
		
        Priority = 700,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain)
		
			if (ScenarioInfo.size[1] >= 1028 or ScenarioInfo.size[2] >= 1028) then
				return 0, false
			end
			
			-- remove after 30 minutes
			if aiBrain.CycleTime > 1800 then
				return 0, false
			end
			
			return 700, false
		end,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioLessThan', { 3 }}, 
			
			{ MIBC, 'MapLessThan', { 1028 } },
			{ MIBC, 'GreaterThanGameTime', { 300 } },
			-- must not have any of the internal T2+ AA structures 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.ANTIAIR, 14, 35 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 9, categories.DEFENSE * categories.STRUCTURE * categories.ANTIAIR}},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Construction = {
			
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,	-- randomly select one of orientation points
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				BuildStructures = {'T1AADefense'},
            }
			
        }
		
    },

    Builder {BuilderName = 'CDR Assist Factory',
	
        PlatoonTemplate = 'CommanderAssist',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 753,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 80,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY,
				BeingBuiltCategories = {categories.MOBILE},
                Time = 60,
				
            },
			
        }
		
    },

    Builder {BuilderName = 'CDR Repair',
	
        PlatoonTemplate = 'CommanderRepair',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 753,
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
			
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = { },
		
    },	
	
}

--	TECH3 Commander Tasks vary if BO:ACU is installed

-- Commander Tech3 tasks - NO BO:ACU
BuilderGroup {BuilderGroupName = 'ACU Builders - Standard',
    BuildersType = 'EngineerBuilder',    
	
    Builder {BuilderName = 'CDR T3 Power - Template - Standard',
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        Priority = 780,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ EBC, 'LessThanEnergyTrend', { 2500 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 29, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
			{ UCBC, 'ACUHasUpgrade', { 'T3Engineering', true }},
			{ EBC, 'LessThanEconEfficiencyOverTime', { 2, 1.06 }},
        },
	
        BuilderType = { 'Commander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
	
    Builder {BuilderName = 'CDR Mass Fab - Standard',
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        Priority = 780,
		
		PriorityFunction = function(self, aiBrain)
		
			if ScenarioInfo.LOUD_IS_Installed then
				return 0, false
			end
			
			return self.Priority
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},			
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},			
			{ UCBC, 'ACUHasUpgrade', { 'T3Engineering', true }},			
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1 }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
				
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
	
    Builder {BuilderName = 'CDR Mass Fab - Standard - LOUD_IS',
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        Priority = 780,
		
		PriorityFunction = function(self, aiBrain)
		
			if ScenarioInfo.LOUD_IS_Installed then
				return self.Priority
			end
			
			return 0, false
		end,
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},			
			{ UCBC, 'ACUHasUpgrade', { 'T3Engineering', true }},
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1 }},
        },

        BuilderType = { 'Commander' },
		
        BuilderData = {
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
				
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}

-- Commander Tech3 tasks - BO:ACU active
BuilderGroup {BuilderGroupName = 'ACU Builders - BOACU',
    BuildersType = 'EngineerBuilder',    
	
    Builder {BuilderName = 'CDR T3 Power - Template - BOACU',
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
		
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') or unit:HasEnhancement('EXExperimentalEngineering')then
					return 780, false
				end
			end
			
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'LessThanEnergyTrend', { 2500 }},
			{ EBC, 'LessThanEconEfficiencyOverTime', { 2, 1.06 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 29, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
        },
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
	
    Builder {BuilderName = 'CDR Mass Fab - BOACU',
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
		
			if ScenarioInfo.LOUD_IS_Installed then
				return 0, false
			end		
		
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') or unit:HasEnhancement('EXExperimentalEngineering')then
					return 780, false
				end
			end
			
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1 }},
        },
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
	
    Builder {BuilderName = 'CDR Mass Fab - BOACU - LOUD_IS',
        PlatoonTemplate = 'CommanderBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		PlatoonAIPlan = 'EngineerBuildAI',
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
		
			if self.Priority == 10 and not ScenarioInfo.LOUD_IS_Installed then
				if unit:HasEnhancement('EXAdvancedEngineering') or unit:HasEnhancement('EXExperimentalEngineering')then
					return 780, false
				end
			end

			if not ScenarioInfo.LOUD_IS_Installed then
				return 0, false
			end

			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1 }},
        },
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}