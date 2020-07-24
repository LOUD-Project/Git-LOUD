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

-- this function turns on the builder when he has T3 ability
local CDRbuildsT3 = function( self, aiBrain, unit )		

    if self.Priority == 10 then
        if unit:HasEnhancement('T3Engineering') or unit:HasEnhancement('EXAdvancedEngineering') or unit:HasEnhancement('EXExperimentalEngineering') then
            return 780, false
        end
    end

	return self.Priority, false
end


-- Some notes here about the syntax of the Construction section of the builder task

-- There are several options that control 'where' structures are built but most 
-- important to the AI is BaseTemplateFile
--
-- BaseTemplateFiles are used to describe different base layouts 
-- and are comprised of several sections for diffent portions of the base
-- such as factories, energy, shields, defenses, etc.
-- Each of these sections are known as as the BaseTemplate

-- each BaseTemplate section describes the relationship between certain structures
-- and where they can be placed relative to the point provided
-- 
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
BuilderGroup {BuilderGroupName = 'ACU Tasks - Start Game',
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
			-- Greater than 50 economy threat closer than 18km
			{ TBC, 'ThreatCloserThan', { 'LocationType', 900, 50, 'Economy' }},
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
BuilderGroup {BuilderGroupName = 'ACU Tasks',
    BuildersType = 'EngineerBuilder',

    -- his most important role for first 30 mins
    -- if low on power and has sufficient mass stored
    -- and no advanced power of any kind
    Builder {BuilderName = 'CDR - T1 Power',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerBuildAI',
		
        Priority = 780,
		
		PriorityFunction = First30Minutes,
		
        BuilderConditions = { 
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'LessEconEnergyStorageCurrent', { 5000 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 175, 0 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.TECH3 }},
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

    -- after 30 minutes - initiating more T3 Power and Mass Fabs becomes his 
    -- most important task if those are required
    Builder {BuilderName = 'CDR - T3 Power',
    
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		PlatoonAIPlan = 'EngineerBuildAI',

        Priority = 10,  -- becomes 780 when ACU is enhanced
        
        PriorityFunction = CDRbuildsT3,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ EBC, 'LessThanEnergyTrend', { 2400 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},

			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.TECH3 }},            
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 26, (categories.ENERGYPRODUCTION * categories.TECH3) - categories.HYDROCARBON }},
        },
	
        BuilderType = { 'Commander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
	
    Builder {BuilderName = 'CDR - Mass Fab',
    
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		PlatoonAIPlan = 'EngineerBuildAI',

        Priority = 10,  -- becomes 780 when enhanced
        
        PriorityFunction = CDRbuildsT3,

        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},			
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},			
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
            
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.04 }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
				
                BuildStructures = { 'T3MassCreation' },
            }
        }
    },

    -- after that assisting ECO is first priority
    -- Energy first if we are not full otherwise Mass
    -- provided we have some mass in storage
    Builder {BuilderName = 'CDR Assist Energy',
	
        PlatoonTemplate = 'CommanderAssist',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 756,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'LessThanEconEnergyStorageRatio', { 75 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},
            
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

    Builder {BuilderName = 'CDR Assist Mass Upgrade',
	
        PlatoonTemplate = 'CommanderAssist',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 755,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},           
            
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


    -- these next 4 tasks are all equal in eco conditions (except repair)
    -- so they'll appear randomly for the most part
    Builder {BuilderName = 'CDR Assist Factory Upgrade',
	
        PlatoonTemplate = 'CommanderAssist',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
            
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

    -- if no factory upgrades - help Structure or Experimental builds
    -- for upto 75 seconds
    Builder {BuilderName = 'CDR Assist Structure Experimental',
	
        PlatoonTemplate = 'CommanderAssist',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},             
            
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

    -- or assist factory builds for 60 seconds
    Builder {BuilderName = 'CDR Assist Factory',
	
        PlatoonTemplate = 'CommanderAssist',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
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

    -- or repair something -- no regard for Base Alert status
    Builder {BuilderName = 'CDR Repair',
	
        PlatoonTemplate = 'CommanderRepair',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 754,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
            
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = { },
    },	

    -- if mass is low and we can't do the previous jobs
    -- reclaim mass locally if there is any
    Builder {BuilderName = 'CDR Reclaim Mass',
	
        PlatoonTemplate = 'CommanderReclaim',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 750,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 15 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 60 }},
        },
		
        BuilderData = {
			ReclaimTime = 45,
			ReclaimType = 'Mass',
        },
    },

    -- just an in-case situation - rarely seen and only first 30 minutes
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
            { LUTL, 'AirStrengthRatioLessThan', { 1 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},			

			{ MIBC, 'GreaterThanGameTime', { 210 } },
            
			-- must not have any of the internal T2+ AA structures 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.ANTIAIR, 14, 35 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 9, categories.DEFENSE * categories.STRUCTURE * categories.ANTIAIR}},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Construction = {
				Radius = 51,    -- we use the same radius as that used by the T1 engineers so we don't overbuild
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,	-- randomly select one of orientation points
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				BuildStructures = {'T1AADefense'},
            }
        }
    },


}

--- if you are looking for upgrades for SCU then you need to look for the selfenhance functions
--- in the AIBehaviors file - they use a different method entirely

-- notice the use of the ClearTaskOnComplete flag
-- since an ACU will only use the upgrade task once
-- I wanted a way to remove the builder from the builder list when completed
-- this flag accomplishes this, setting the priority to zero permanently
-- the builder manager will then remove it from the task list


-- VANILLA COMMANDER UPGRADES --
BuilderGroup {BuilderGroupName = 'ACU Upgrades LOUD',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'UEF CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ MIBC, 'GreaterThanGameTime', { 210 } },            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},			
			{ UCBC, 'ACUNeedsUpgrade', { 'AdvancedEngineering' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'Shield', 'AdvancedEngineering' },
        },
		
    },

    Builder {BuilderName = 'Aeon CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },		

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
			{ UCBC, 'ACUNeedsUpgrade', { 'EnhancedSensors' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'AdvancedEngineering', 'EnhancedSensors' },
        },
		
    },

    Builder {BuilderName = 'Cybran CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },		

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
			{ UCBC, 'ACUNeedsUpgrade', { 'MicrowaveLaserGenerator' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'AdvancedEngineering', 'MicrowaveLaserGenerator' },
        },
		
    },

    Builder {BuilderName = 'Seraphim CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },		

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
			{ UCBC, 'ACUNeedsUpgrade', { 'RegenAura' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'AdvancedEngineering', 'RegenAura' },
        },
		
    },
	
    Builder {BuilderName = 'ACU T3Engineering Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
			{ UCBC, 'ACUNeedsUpgrade', { 'T3Engineering' }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('AdvancedEngineering') then
					return 850, false
				end
			end
			return self.Priority,true
		end,		
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'T3Engineering' },
        },
		
    },
}


--	Adapted for using the BlackOps Advanced ACU mod

-- 	Only the first upgrade starts turned on, as it finishes, it is removed
--	and the next stage is turned on thru the Priority Function
-- 	This can be more efficient than using multiple builder conditions
--		Each faction will have their commander stage thru their upgrades
--		Note: Due to the way that slots are checked, you can never stack more
--		than 2 upgrades to the same slot in the same enhancement list - so for
--		that reason you'll see I had to split some of slot upgrades into 2 platoons

BuilderGroup {BuilderGroupName = 'BOACU Upgrades LOUD',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'CDR Common Upgrade BOPACU - LCH',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ MIBC, 'GreaterThanGameTime', { 210 } },            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
        },
		
        Priority = 850,
	
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXImprovedEngineering','EXAdvancedEngineering' },
        },
    },
	
	-- =============
	-- UEF Commander
	-- =============
	
    Builder {BuilderName = 'CDR UEF Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },
		
		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXAntiMatterCannon','EXImprovedContainmentBottle' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR UEF Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedContainmentBottle') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXShieldBattery','EXActiveShielding' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR UEF Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
	
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXActiveShielding') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXPowerBooster','EXImprovedShieldBattery' },
        },
		
    },	

	-- ==============
	-- Aeon Commander
	-- ==============
	
    Builder {BuilderName = 'CDR Aeon Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXBeamPhason','EXImprovedCoolingSystem' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Aeon Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedCoolingSystem') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXShieldBattery','EXActiveShielding' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Aeon Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXActiveShielding') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXPowerBooster','EXImprovedShieldBattery' },
        },
		
    },

	-- ================
	-- Cybran Commander
	-- ================
	
    Builder {BuilderName = 'CDR Cybran Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXMasor','EXImprovedCoolingSystem' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Cybran Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedCoolingSystem') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXArmorPlating','EXStructuralIntegrity' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Cybran Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXStructuralIntegrity') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXAdvancedEmitterArray','EXCompositeMaterials' },
        },
		
    },

	-- ==============
	-- Sera Commander
	-- ==============
	
    Builder {BuilderName = 'CDR Sera Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXCannonBigBall','EXImprovedContainmentBottle' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Sera Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedContainmentBottle') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXL1Lambda','EXL2Lambda' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Sera Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
        
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXL2Lambda') then
					return 850, false
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXPowerBooster' },
        },
		
    },	
}

