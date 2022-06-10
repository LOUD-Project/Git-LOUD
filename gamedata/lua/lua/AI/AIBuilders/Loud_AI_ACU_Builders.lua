--- File     :  /lua/ai/Loud_AI_ACU_Builders.lua
--- tasks for ACU (Bob) including initial starting build and adding additional factories

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local BHVR = '/lua/ai/aibehaviors.lua'
local LUTL = '/lua/loudutilities.lua'

local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetPosition = moho.entity_methods.GetPosition


-- this is here as a test to see if it has any impact I can detect
-- I don't think it does being that all of this is really just data
-- that is loaded
local ENERGYPRODUCTION = categories.ENERGYPRODUCTION
local HYDROCARBON = categories.HYDROCARBON
local MASSFABRICATION = categories.MASSFABRICATION
local MASSPRODUCTION = categories.MASSPRODUCTION
local ENGINEER = categories.ENGINEER
local EXPERIMENTAL = categories.EXPERIMENTAL
local FACTORY = categories.FACTORY
local STRUCTURE = categories.STRUCTURE
local ANTIAIR = categories.ANTIAIR
local TECH1 = categories.TECH1
local TECH2 = categories.TECH2
local TECH3 = categories.TECH3


-- imbedded into the Builder
local First5Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 300 then
		return 0, false
	end
	
	return self.Priority, true
end

local First45Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
	
	return self.Priority, true
end

-- this function turns on the builder when he has T3 ability
-- this is kind of costly - best if any of those enhancements just flagged the brain
-- since this is intended to be used just on an ACU - but I think best would be
-- if the unit itself was flagged - ie. unit.BuildsT3
local CDRbuildsT3 = function( self, aiBrain, unit )		

    if self.Priority == 10 then
        if unit:HasEnhancement('T3Engineering') or unit:HasEnhancement('EXAdvancedEngineering') or unit:HasEnhancement('EXExperimentalEngineering') then
            return 780, false
        end
    end

	return self.Priority, false
end

-- This is mostly for the players that rush him but this should also effect how prepared his bases are.
local IsEnemyCrushingLand = function( builder, aiBrain, unit )

    if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 300 then

		return builder.Priority + 100, true	

    end

    if GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' ) > 30 then

        return builder.Priority + 100, true
        
    end
    
    return builder.Priority, false
end

local IsEnemyCrushingAir = function( builder, aiBrain, unit )

    if aiBrain.AirRatio <= 1.0 and aiBrain.CycleTime > 300 then
	
		return builder.Priority + 100, true	

    end
    
    return builder.Priority, false
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
		
		PriorityFunction = First45Minutes,
		
        BuilderConditions = { 
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ EBC, 'LessThanEconEnergyStorageCurrent', { 5750 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 25, 0 }},

			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, ENERGYPRODUCTION - TECH1 }},            
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, ENERGYPRODUCTION * STRUCTURE * TECH3 }},
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
    
	-- build mass at higher priority when close
    Builder {BuilderName = 'CDR - Mass Extractor',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerBuildAI',
		
        Priority = 775,
		
		PriorityFunction = First5Minutes,
		
		BuilderType = { 'Commander' },

        BuilderConditions = {
        
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 60, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = false,		-- build on points close to baase
				LoopBuild = false,		-- don't repeat this build
                
                MaxRange = 60,

				ThreatMax = 25,
				ThreatRings = 0,
                
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
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

			{ EBC, 'LessThanEnergyTrendOverTime', { 260 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 70 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},
            
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, ENERGYPRODUCTION * TECH3 }},

			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, ENERGYPRODUCTION * TECH3 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 26, (ENERGYPRODUCTION * TECH3) - HYDROCARBON }},
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
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, MASSFABRICATION * TECH3, 10, 42 }},
            
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, ENERGYPRODUCTION - TECH1 }},
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
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 756,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'LessThanEconEnergyStorageRatio', { 50 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 1000 }},
            
			{ UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, ENERGYPRODUCTION, ENGINEER + ENERGYPRODUCTION, 75 }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Assist = {
                AssistEnergy = 100,
                AssistMass = 50,
				AssistRange = 80,
                AssisteeType = 'Any',
				AssisteeCategory = ENGINEER + ENERGYPRODUCTION,
                BeingBuiltCategories = { ENERGYPRODUCTION },
                Time = 75,
            },
        }
    },

    Builder {BuilderName = 'CDR Assist Mass Upgrade',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 756,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},            
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 1250 }},           
            
            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, MASSPRODUCTION, MASSPRODUCTION, 60 }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Assist = {
				AssistRange = 80,
				AssisteeType = 'Structure',
				AssisteeCategory = MASSPRODUCTION,
                BeingBuiltCategories = {MASSPRODUCTION},
                Time = 60,
            },
        }
    },


    -- these next 4 tasks are all equal in eco conditions (except repair)
    -- so they'll appear randomly for the most part
    Builder {BuilderName = 'CDR Assist Factory Upgrade',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 755,
        
        PriorityFunction = IsEnemyCrushingLand,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1, 1.01 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, FACTORY }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Assist = {
				AssistRange = 75,
				AssisteeType = 'Factory',
				AssisteeCategory = FACTORY,
				BeingBuiltCategories = {FACTORY},
                Time = 75,
            },
        }
    },

    -- if no factory upgrades - help Structure or Experimental builds
    -- for upto 75 seconds
    Builder {BuilderName = 'CDR Assist Structure Experimental',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},             
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', STRUCTURE + EXPERIMENTAL, ENGINEER, 125 }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Assist = {
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER,
                BeingBuiltCategories = {STRUCTURE, EXPERIMENTAL},
                Time = 75,
            },
        }
    },

    -- or assist factory builds for 60 seconds
    Builder {BuilderName = 'CDR Assist Factory',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 754,
        
        PriorityFunction = IsEnemyCrushingLand,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }}, 
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Assist = {
				AssistRange = 80,
				AssisteeType = 'Factory',
				AssisteeCategory = FACTORY,
				BeingBuiltCategories = {categories.MOBILE},
                Time = 60,
            },
        }
    },

    -- or repair something -- no regard for Base Alert status
    Builder {BuilderName = 'CDR Repair',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 754,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
            
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = { },
    },	

    -- if mass is low and we can't do the previous jobs
    -- reclaim mass locally if there is any
    Builder {BuilderName = 'CDR Reclaim Mass',
	
        PlatoonTemplate = 'CommanderBuilder',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 750,
		
        BuilderType = { 'Commander' },
		
        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 15 }},
            
			{ MIBC, 'GreaterThanGameTime', { 210 } },            
            
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 45 }},
        },
		
        BuilderData = {
			ReclaimTime = 45,
			ReclaimType = 'Mass',
            ReclaimRange = 50,
        },
    },

    -- just an in-case situation - rarely seen and only first 15 minutes
    Builder {BuilderName = 'CDR T1 AA - Response - Small Maps',
	
        PlatoonTemplate = 'CommanderBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerBuildAI',
		
        Priority = 700,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain)

            -- too early (7 mins) -- we don't want Bob wandering around too much this early
            if aiBrain.CycleTime < 420 then
                return 10, true
            end

            -- map is too large
			if (ScenarioInfo.size[1] >= 1028 or ScenarioInfo.size[2] >= 1028) then
				return 0, false
			end
			
			-- remove after 15 minutes
			if aiBrain.CycleTime > 900 then
				return 0, false
			end
            
            if aiBrain.AirRatio < 1.5 then
                return self.Priority + 100, true
            end
			
			return self.Priority, true
		end,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 3 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},			

			-- must not have any of the internal T2+ AA structures 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, STRUCTURE * ANTIAIR, 14, 35 }},
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 9, STRUCTURE * ANTIAIR}},
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

    Builder {BuilderName = 'CDR T1 Base Defense - PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 754,
		
		PriorityFunction = function(self, aiBrain)
		
			if self.Priority != 0 then

				-- remove after 30 minutes
				if aiBrain.CycleTime > 1800 then
					return 0, false
				end
				
			end
            
            if aiBrain.LandRatio <= 1.5 then
                return self.Priority + 100, true
            end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
            
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},
            
            { LUTL, 'LandStrengthRatioLessThan', { 4 }},
            
			{ EBC, 'GreaterThanEnergyIncome', { 300 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 175, 1750 }},
			
			-- dont build if we have built any advanced power -- obsolete
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.STRUCTURE - categories.TECH1 }},
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE, 30, 50}},
        },
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
            Construction = {
				Radius = 36,
                NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,	-- pick a random point from the 9 FRONT rotations

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {
					'T1GroundDefense',
					'T1Artillery',
				},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 60, 1.025, 1.04 }},
            
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
			{ MIBC, 'GreaterThanGameTime', { 210 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 60, 1.025, 1.04 }},
            
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
			{ MIBC, 'GreaterThanGameTime', { 210 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 60, 1.025, 1.04 }},
            
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
			{ MIBC, 'GreaterThanGameTime', { 210 } },
            
   			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 60, 1.025, 1.04 }},
            
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
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 60, 1.025, 1.04 }},
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

			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 60, 1.025, 1.04 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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

			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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

			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 3000 }},
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
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

