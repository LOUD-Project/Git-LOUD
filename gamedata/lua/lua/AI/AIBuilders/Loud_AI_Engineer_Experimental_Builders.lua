--  Loud_AI_Engineer_Experimental_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'

local LessThan20MinutesRemain = function(self, aiBrain)

	if aiBrain.VictoryTime then

		if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 20 ) ) then	-- less than 20 minutes left

			return 0, false

		end

	end

	return self.Priority, true
end

local LessThan30MinutesRemain = function(self, aiBrain)

	if aiBrain.VictoryTime then

		if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 30 ) ) then	-- less than 30 minutes left

			return 0, false

		end

	end

	return self.Priority, true
end

-- the key distinction here is that we don't want to be building Experimentals unless we have the army to back it up
-- this means we don't go experimental unless we have a decent army, air force or navy - so we use the ratios for that

-- alternatively, if we have the level of resources required - but not the force to back it up - we'll opt for nuke
-- or artillery over experimental - since they have no ratio requirement

-- Land Experimental are built using 4 definitions - the intention here is to have some economic control over which
-- ones get built - according to resource availability - lighter ones having lower eco needs

BuilderGroup {BuilderGroupName = 'Engineer T4 Land Construction',
    BuildersType = 'EngineerBuilder',

-- This should be used for a light experimental - lowest eco requirements
    Builder {BuilderName = 'Land Experimental 1',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 3,
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				Iterations = 1,

                BuildStructures = {'T4LandExperimental1' },
            }
        }
    },
	
-- This one builds medium experimentals but has slightly higher eco needs
    Builder {BuilderName = 'Land Experimental 2',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 3,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental2'},
            }
        }
    },

-- This one builds heavy experimentals but has the highest eco needs
	Builder {BuilderName = 'Land Experimental 3',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental3' },
            }
        }
    },
	
-- This one builds the heaviest experiementals of all
	Builder {BuilderName = 'Land Experimental 4',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan30MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental4'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Land Construction - Expansions',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Exp 1 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 3,
            Construction = {
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental1'},

            }
        }
    },
	
    Builder {BuilderName = 'Land Exp 2 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental2'},
            }
        }
    },
	
	Builder {BuilderName = 'Land Exp 3 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.04 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 3,
            Construction = {
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental3'},
            }
        }
    },
	
	Builder {BuilderName = 'Land Exp 4 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan30MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.04 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 3,
            Construction = {
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4LandExperimental4'},
            }
        }
    },
}

-- This BuilderGroup is used when a land solution from this base can be found
-- to the current enemy - otherwise the Air version is used. 
BuilderGroup {BuilderGroupName = 'Engineer T4 Air Construction - Land Only Map',
    BuildersType = 'EngineerBuilder',
	
-- Like the land experimentals - we Tier the AirExps in 2 groups 
-- We also have different priorities on land maps versus water maps - Air Exps more necessary on Water maps and trigger earlier
    Builder {BuilderName = 'Air Experimental - Land Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 2,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = { 'T4AirExperimental1' },
            }
        }
    },

    Builder {BuilderName = 'Air Experimental - Air Transport',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },
			
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = { 'T4AirExperimentalTransport' },
            }
        }
    },
    
    Builder {BuilderName = 'Air Experimental 2 - Land Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 0.9 } },
			
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = { 'T4AirExperimental2' },
            }
        }
    },
}	

BuilderGroup {BuilderGroupName = 'Engineer T4 Air Construction - Water Map',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Experimental 1 - Water Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 751,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 2,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'AirStrengthRatioGreaterThan', { 0.8 } },
            
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				Radius = 50,
				
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4AirExperimental1' },
            }
        }
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Water Map',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 751,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 2,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 0.9 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },

        BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
				Radius = 50,
				
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4AirExperimental2' },
            }
        }
    },
}

	
BuilderGroup {BuilderGroupName = 'Engineer T4 Air Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Experimental - Land Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            Construction = {
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4AirExperimental1' },
            }
        }
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Land Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,

		InstanceCount = 1,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.SHIELD }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,

                BuildStructures = {'T4AirExperimental2'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Air Construction - Water Map - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Experimental - Water Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },

        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = { 'T4AirExperimental1' },
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Air Experimental 2 - Water Map - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		PriorityFunction = LessThan20MinutesRemain,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				Radius = 45,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				Iterations = 1,
                BuildStructures = { 'T4AirExperimental2' },
				
            }
			
        }
		
    },
	
}


	
BuilderGroup {BuilderGroupName = 'Satellite Builders',
    BuildersType = 'EngineerBuilder',
	
    -- Builder {BuilderName = 'Satellite Experimental',
        -- PlatoonTemplate = 'EngineerBuilderGeneral',
		-- PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        -- Priority = 0, 
        -- BuilderConditions = {

            -- { LUTL, 'UnitCapCheckLess', { .95 } },
			-- { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 8, 160 }},
            -- { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.15 }},
			-- { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.EXPERIMENTAL * categories.ORBITALSYSTEM}},
			-- { UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ORBITALSYSTEM}},

        -- },
        -- BuilderType = 'Any',
        -- BuilderData = {
            -- Construction = {
				-- Radius = 45,
                -- NearBasePerimeterPoints = true,
				-- BasePerimeterOrientation = 'FRONT',
				-- Iterations = 1,
                -- BuildStructures = {
                    -- 'T4SatelliteExperimental',
                -- },
            -- }
        -- }
    -- },
}


BuilderGroup {BuilderGroupName = 'Engineer T4 Naval Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sea Experimental 1',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'PoolLess', { 3, categories.BATTLESHIP }},			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 47,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental1' },
				
            }
        }
    },
	
    Builder {BuilderName = 'Sea Experimental 2',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },			

			{ LUTL, 'PoolLess', { 3, categories.BATTLESHIP }},			

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 47,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental2' },
				
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Naval Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sea Experimental 1 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 1,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },			

			{ LUTL, 'PoolLess', { 3, categories.BATTLESHIP }},			

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 36,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental1' },
				
            }
        }
    },
	
    Builder {BuilderName = 'Sea Experimental 2 Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan20MinutesRemain,
		
		InstanceCount = 2,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'PoolLess', { 3, categories.BATTLESHIP }},			

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 50, 1.02, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 36,
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = true,
				Iterations = 1,
				
                BuildStructures = { 'T4SeaExperimental2' },
				
            }
        }
    },
	
}


BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
		   
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
				Radius = 52,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 3,
				
				Iterations = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
                    'T4EconExperimental',
					
					'T3ShieldDefense',
					'T3ShieldDefense',
					
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					
					'T4GroundDefense',
					'T4GroundDefense',

					'T3ShieldDefense',
					'T3ShieldDefense',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Construction - Small Base',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
		   
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
				Radius = 44,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,
				
				Iterations = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
                    'T4EconExperimental',
					
					'T3ShieldDefense',
					'T3ShieldDefense',
					
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					
					'T4GroundDefense',
					'T4GroundDefense',

					'T3ShieldDefense',
					'T3ShieldDefense',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Defense Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 52,
				
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 3,
				
				Iterations = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					
					'T2ShieldDefense',
					'T2ShieldDefense',
					
					'T4AADefense',
					'T3AADefense',
					
					'T2ShieldDefense',
					'T2ShieldDefense',
					
					'T4EconExperimental',	-- this is here so that engies will assist the experimental build if it's not done already
					
					'T4GroundDefense',
					'T4GroundDefense',
					
					'T4AADefense',
					'T3AADefense',

					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',

--					'T3TeleportJammer',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Defense Construction - LOUD IS',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Economic Experimental Defenses - IS',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,

		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 52,
				
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 3,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					
					'T4EconExperimental',	-- this is here so that engies will assist the experimental build if it's not done already or the engy is destroyed while building paragon
                },
            }
        }
    },
}


BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Defense Construction - Small Base',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental Defenses - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
		
		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 44,
				
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,
				
				Iterations = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					
					'T2ShieldDefense',
					'T2ShieldDefense',
					
					'T4AADefense',
					'T3AADefense',
					
					'T2ShieldDefense',
					'T2ShieldDefense',
					
					'T4EconExperimental',	-- this is here so that engies will assist the experimental build if it's not done already
					
					'T4GroundDefense',
					'T4GroundDefense',
					
					'T4AADefense',
					'T3AADefense',

					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',

--					'T3TeleportJammer',
                },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Defense Construction - LOUD IS - Small Base',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Economic Experimental Defenses - IS - Small Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,

		PriorityFunction = LessThan30MinutesRemain,		
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, (categories.STRUCTURE * categories.SHIELD) }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
			
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 44,
				
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ResourceFacility',
				
                BuildStructures = {
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T4AADefense',
					'T4AADefense',
					'T3AADefense',
					'T3AADefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					
					'T4EconExperimental',	-- this is here so that engies will assist the experimental build if it's not done already or the engy is destroyed while building paragon
                },
            }
        }
    },
}



BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental - Expansions',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,
		
		PriorityFunction = LessThan30MinutesRemain,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
		   
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 10, (categories.STRUCTURE * categories.SHIELD) }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
                NearBasePerimeterPoints = true,			
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',

                BuildStructures = { 'T4EconExperimental' },
				
            }
        }
    },

}

BuilderGroup {BuilderGroupName = 'Engineer T4 Economy Construction - Naval',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Economic Experimental Naval',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

		PriorityFunction = LessThan30MinutesRemain,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
			
        },

        BuilderType = { 'SubCommander' },		

        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
                NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = { 'T4EconExperimental' },
				
            }
        }
    },

}