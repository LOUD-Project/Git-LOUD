--  Loud_AI_Engineer_Factory_Builders.lua
--- tasks for building additional factories and gates

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local LOUDGETN              = table.getn
local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal
local GetListOfUnits        = moho.aibrain_methods.GetListOfUnits

local UnitsGreaterAtLocation                        = import(UCBC).UnitsGreaterAtLocation

local AboveUnitCap65 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap75 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function( self, aiBrain, manager )

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .011 and aiBrain.NavalRatio <= 10) then

		return 800, true

	end

	return 10, true
	
end

-- this function will turn a builder on if there are no factories
local HaveZeroAirFactories = function( self, aiBrain )

    if aiBrain.CycleTime > 60 then
	
        if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * categories.AIR, false, true )) < 1 then
	
            return 990, true
		
        end
        
    end

	return self.OldPriority or self.Priority, true

end

local HaveZeroLandFactories = function( self, aiBrain )

    if aiBrain.CycleTime > 60 then
	
        if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * categories.LAND, false, true )) < 1 then

            return 990, true
		
        end
        
    end

	return self.OldPriority or self.Priority, true

end

local HaveZeroNavalFactories = function( self, aiBrain )

    if aiBrain.CycleTime > 90 then
	
        if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * categories.NAVAL, false, true )) < 1 then
	
            return 990, true
		
        end
        
    end

	return self.OldPriority or self.Priority, true

end

-- In LOUD, construction of new factories is controlled by three things
-- the cap check, which comes from the BaseTemplateFile, controls the max number of factories by type
-- the balance between land and air factories -- we try to keep them in lock step with each other
-- the eco conditions -- sufficient storage -- and an economy that's been positive for a while
-- we have overrides for high production ratios (useful when enemy is trying to specialize and AI needs to compensate)
BuilderGroup {BuilderGroupName = 'Engineer Factory Construction', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory Rebuild',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroLandFactories,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 3000 }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.LAND }},            
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
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroAirFactories,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 3000 }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.AIR }},
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

    -- land factories are added only if there are more air factories and land strength isn't excessively high
    Builder {BuilderName = 'Land Factory Balance',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 4.5 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND' }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.LAND * categories.TECH1 }},
            
            { UCBC, 'FactoryRatioGreaterOrEqualAtLocation', { 'LocationType', categories.AIR, categories.LAND } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.012 }},
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

	-- when count & eco conditions are met - Air factories get built ahead of Land
    Builder {BuilderName = 'Air Factory Balance',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 801,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'AirProductionRatioLessThan', { 6 } },

            { LUTL, 'AirStrengthRatioLessThan', { 6 } },

			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR' }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.AIR * categories.TECH1 }},
            
            { UCBC, 'FactoryRatioGreaterOrEqualAtLocation', { 'LocationType', categories.LAND, categories.AIR } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.015 }},
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

    -- this builder permits the AI to ignore the count requirement for balance between Air and Land factories
    -- triggered by a high AirProductionRatio (usually indicates opponent isn't playing Air)
    Builder {BuilderName = 'Land Factory - High Air Production Ratio',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 801,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'AirProductionRatioGreaterThan', { 3 } },

			{ LUTL, 'LandProductionRatioLessThan', { 3 } },

            -- this allows it to exceed the cap check by 2
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND', 2 }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.LAND * categories.TECH1 }},
 
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.02 }},
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

    -- this builder comes into play if land strength is decent but air production is not high enough to make bombers/gunships
    -- and can also ignore the count requirement for balance and build beyond the factory cap limit for AIR
    Builder {BuilderName = 'Air Factory Balance - Land Ratio High',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 801,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'AirProductionRatioLessThan', { 6 } },

            { LUTL, 'LandProductionRatioGreaterThan', { 3 } },
            
            { LUTL, 'AirStrengthRatioLessThan', { 6 }},
            
			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR', 2 }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.AIR * categories.TECH1 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 3000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.02 }},
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

BuilderGroup {BuilderGroupName = 'Engineer Factory Construction - Expansions', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory Rebuild - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroLandFactories,
		
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
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 755,
        
        PriorityFunction = AboveUnitCap65,
        
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 4.5 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND' }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.LAND * categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.02 }},
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
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
        
        PriorityFunction = AboveUnitCap65,
		
        BuilderConditions = {
            
            { LUTL, 'AirProductionRatioLessThan', { 6 } },

			{ UCBC, 'FactoryCapCheck', { 'LocationType', 'AIR' }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 1, categories.AIR * categories.TECH1 }},
            
            { UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', categories.AIR, categories.LAND } },
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.02 }},
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

    -- this builder allows the AI to ignore the count requirement for balance between Air and Land factories
    -- triggered by the AirProductionRatio being higher than 3 to 1 (typical of GroundPound configurations)
    Builder {BuilderName = 'Land Factory - High Air Production Ratio - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
        
        PriorityFunction = AboveUnitCap65,
		
        BuilderConditions = {
            
            { LUTL, 'AirProductionRatioGreaterThan', { 3 } },

			{ LUTL, 'LandProductionRatioLessThan', { 6 } },

            -- this allows it to exceed the cap check by 2
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'LAND', 2 }},
            
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 2, categories.LAND * categories.TECH1 }},
	
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.02 }},
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

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

    Builder {BuilderName = 'Quantum Gate - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
			
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.TECH3 * categories.GATE }},
            
			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.TECH3 * categories.GATE }},
        },
		
        BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 50,

                BuildStructures = {'T3QuantumGate'},
            }
        }
    },

    Builder {BuilderName = 'Teleport Node - Expansion Base',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.TELEPORTER }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.TELEPORTER }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
				Radius = 40,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				ThreatMax = 50,

                BuildStructures = {'T4TeleportNode'},
            }
        }
    },

}

BuilderGroup {BuilderGroupName = 'Engineer Factory Construction - Naval', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Naval Factory Builder',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
        
        PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
            
            { LUTL, 'NavalProductionRatioLessThan', { 3 } },

			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'SEA' }},
            
            -- this was intended to minimize naval factory spam by
            -- only adding another factory if we had less than 3 T1 already here
            -- in practice - this sometimes just forced the creation of another
            -- naval yard if available
			{ UCBC, 'FactoryLessAtLocation',  { 'LocationType', 3, categories.NAVAL * categories.TECH1 }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.02 }},
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
                NearBasePerimeterPoints = true,
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
				ThreatMax = 30,
				
                BuildStructures = {'T1SeaFactory' },
            },
        },
    },

    Builder {BuilderName = 'Naval Factory Rebuild',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 10,
        
        PriorityFunction = HaveZeroNavalFactories,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },        
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Construction = {
                NearBasePerimeterPoints = true,
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
				ThreatMax = 50,
				
                BuildStructures = {'T1SeaFactory' },
            }
        }
    },
	
}


-- In the Standard base, the Gate is built to the rear of base -- see radius	
BuilderGroup {BuilderGroupName = 'Engineer Quantum Gate Construction', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = AboveUnitCap75,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
            
                return 11, true
               
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TECH3 * categories.GATE ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.015 }},
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

    Builder {BuilderName = 'Teleport Node',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.02 }},

			{ UCBC, 'ExpansionBaseCount', { 1, '>' } },

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.TELEPORTER }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
				Radius = 49,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 50,

                BuildStructures = {'T4TeleportNode'},
            }
        }
    },
	
}

-- In a small base, the Gate is tucked into the interior -- note the radius value
BuilderGroup {BuilderGroupName = 'Engineer Quantum Gate Construction - Small Base', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate - Small Base',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.015 }},

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

    Builder {BuilderName = 'Teleport Node - Small Base',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 900,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 15, 1.012, 1.02 }},

			{ UCBC, 'ExpansionBaseCount', { 1, '>' } },

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.TELEPORTER }},
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
				Radius = 36,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'FactoryLayout',
				
				ThreatMax = 50,

                BuildStructures = {'T4TeleportNode'},
            }
        }
    },

}