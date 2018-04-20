--  Loud_AI_Intel_Builders.lua
--- Builds all intelligence gathering units such
--- as air and land scouts, radar, sonar & optics 

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

BuilderGroup {BuilderGroupName = 'Land Scout Formations',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Land Scout Formation - Aeon',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 2,
        Priority = 700,
        InstanceCount = 3,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = true,
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - UEF',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 1,
        Priority = 700,
        InstanceCount = 3,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = true,
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - Cybran',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 3,
        Priority = 700,
        InstanceCount = 2,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = true,
			HoldFireOnPatrol = false, -- not needed since they don't have a weapon
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - Sera',
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 4,
        Priority = 700,
        InstanceCount = 2,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.SCOUT }},
		},
        BuilderData = {
			Patrol = false,	-- unlike other scouts, by being stationary they become cloaked
			HoldFireOnPatrol = true,	-- so we also hold fire when we are on our patrol station
        },
		
    },
	
}



-- These are the standard air scout patrols around a base

BuilderGroup {BuilderGroupName = 'Air Scout Formations',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Air Scout Peri - 200',
	
        PlatoonTemplate = 'Air Scout Formation',
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 805,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
			
		},
		
		BuilderData = {
		
			BasePerimeterOrientation = 'ALL',        
			Radius = 200,
			PatrolTime = 1200,
			
		},
		
    },
	
    Builder {BuilderName = 'Air Scout Peri - 290',
	
        PlatoonTemplate = 'Air Scout Formation',
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 804,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
			
		},
		
		BuilderData = {
		
			BasePerimeterOrientation = 'ALL',        
			Radius = 290,
			PatrolTime = 1200,
			
		},
		
    },
    
    Builder {BuilderName = 'Air Scout Peri - 380',
	
        PlatoonTemplate = 'Air Scout Formation',
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 803,
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
			
		},
		
		BuilderData = {
		
			BasePerimeterOrientation = 'ALL',
			Radius = 380,
			PatrolTime = 1000,
			
		},
		
    },
	
    Builder {BuilderName = 'Air Scout Peri - 460',
	
        PlatoonTemplate = 'Air Scout Formation',
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 802,
		
		InstanceCount = 5,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
			
		},
		
		BuilderData = {
		
			BasePerimeterOrientation = 'ALL',        
			Radius = 460,
			PatrolTime = 1000,
			
		},
		
    },
    
    -- Air Scout formations grow over time
	
	-- single plane formation for first 60 minutes
    Builder {BuilderName = 'Air Scout - Standard',
        PlatoonTemplate = 'Air Scout Formation',
		PlatoonAIPlan = 'ScoutingAI',
		Priority = 803,
		
		-- this function removes the builder after 45 minutes
		PriorityFunction = function(self, aiBrain)
		
			if self.Priority != 0 then
				if aiBrain.CycleTime > 2700 then
					return 0, false
				end
			end
			
			return self.Priority,true
		end,
		
        InstanceCount = 8,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
		},
		BuilderData = {
		},
    },
	
	-- double plane formation for first 90 minutes
    Builder {BuilderName = 'Air Scout - Pair',
        PlatoonTemplate = 'Air Scout Group',
		PlatoonAIPlan = 'ScoutingAI',
        Priority = 10,
		
		-- this function turns the builder on at 30 minutes and removes it at 75 minutes 
		PriorityFunction = function(self, aiBrain)
			
			if self.Priority != 0 then
				
				if aiBrain.CycleTime > 1500 then
					return 803, true
				end
			
				if aiBrain.CycleTime > 4500 then
					return 0, false
				end
			end
			
			return self.Priority,true
		end,

        InstanceCount = 6,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.AIR * categories.SCOUT }},
		},
		BuilderData = {
		},
    },
	
	-- wing of 6 spy planes starting at 60 minutes
    Builder {BuilderName = 'Air Scout - Wing',
        PlatoonTemplate = 'Air Scout Group Large',
		PlatoonAIPlan = 'ScoutingAI',
        Priority = 10,
		
		-- this function turns the builder on at the 45 minute mark
		PriorityFunction = function(self, aiBrain)
			
			if self.Priority != 720 then
			
				if aiBrain.CycleTime > 3600 then
					return 803, false
				end
			end
			
			return self.Priority,true
		end,
		
        InstanceCount = 6,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.AIR * categories.SCOUT * categories.TECH3 }},
		},
		BuilderData = {
		},
    },
	
	-- group of 12 spy planes after 60 minutes
    Builder {BuilderName = 'Air Scout - Group',
        PlatoonTemplate = 'Air Scout Group Huge',
		PlatoonAIPlan = 'ScoutingAI',
        Priority = 10,
		
		-- this function will turn the builder on at the 90 minute mark
		PriorityFunction = function(self, aiBrain)
		
			if self.Priority != 800 then
			
				if aiBrain.CycleTime > 4500 then
					return 802, false
				end
			end
			
			return self.Priority,true
		end,

        InstanceCount = 6,
        BuilderType = 'Any',
		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.AIR * categories.SCOUT * categories.TECH3 }},
		},
		BuilderData = {
		},
    },
}


BuilderGroup {BuilderGroupName = 'Radar Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Radar Engineer',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				MaxThreat = 30,
                BuildStructures = { 'T1Radar' },
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Radar Builders - Expansions',
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
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                NearBasePerimeterPoints = true,
				MaxThreat = 30,
                BuildStructures = { 'T1Radar' },
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Sonar Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sonar Engineer',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
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


BuilderGroup {BuilderGroupName = 'Optics Builders',
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
                BuildStructures = {
                    'T3Optics',
                },
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
                BuildStructures = {
                    'T3Optics',
                },
            }
        }
    },
}