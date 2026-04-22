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
local GetEconomyIncome		= moho.aibrain_methods.GetEconomyIncome

local UnitsGreaterAtLocation   = import(UCBC).UnitsGreaterAtLocation
local GreaterThanEnergyIncome  = import(LUTL).GreaterThanEnergyIncome
local MapLessThan              = import(MIBC).MapLessThan

local FACTORY   = categories.FACTORY
local GATE      = categories.GATE
local AIR       = categories.AIR
local LAND      = categories.LAND
local NAVAL     = categories.NAVAL

local AboveUnitCap65 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap85 = function( self,aiBrain )

	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function( self, aiBrain, manager )

	if (aiBrain.NavalRatio and (aiBrain.NavalRatio > .011 and aiBrain.NavalRatio <= 10)) and
    GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) < .75 then

		return 800, true

	end

	return 10, true
	
end


-- In LOUD, construction of new factories is controlled by three things
-- the cap check, which comes from the BaseTemplateFile, controls the max number of factories by type
-- the balance between land and air factories -- we try to keep them in lock step with each other
-- the eco conditions -- sufficient storage -- and an economy that's been positive for a while
-- we have overrides for high production ratios (useful when enemy is trying to specialize and AI needs to compensate)
BuilderGroup {BuilderGroupName = 'Engineer Factory Construction', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Land Factory',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
			{ EBC, 'NeedFactory', { 'LAND' }},
			
			{ EBC, 'GreaterThanEconStorageCurrent', { 100, 1000 }},
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

    Builder {BuilderName = 'Air Factory',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 801,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
			{ EBC, 'NeedFactory', { 'AIR' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 100, 1500 }},
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

    Builder {BuilderName = 'Land Factory - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 755,
        
        PriorityFunction = AboveUnitCap85,
        
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },

			{ EBC, 'NeedFactory', { 'LAND' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 100, 1000 }},
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

    Builder {BuilderName = 'Air Factory - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },

			{ EBC, 'NeedFactory', { 'AIR' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 100, 1500 }},
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

    Builder {BuilderName = 'Quantum Gate - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
            
            if GetEconomyIncome( aiBrain, 'ENERGY' ) * 10 < 22000 or UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TECH3 * categories.GATE ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,
			
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 2500, 25000 }},

			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.TECH3 * GATE }},
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

        PriorityFunction = function( builder, aiBrain, unit, manager )
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TELEPORTER ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},            

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.TELEPORTER }},
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
			{ EBC, 'NeedFactory', { 'NAVAL' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 2000 }},
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
	
}


-- In the Standard base, the Gate is built to the rear of base -- see radius	
BuilderGroup {BuilderGroupName = 'Engineer Quantum Gate Construction', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Quantum Gate',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 852,

        PriorityFunction = function( builder, aiBrain, unit, manager )
            
            if GetEconomyIncome( aiBrain, 'ENERGY' ) * 10 < 18000 or UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TECH3 * categories.GATE ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 2500, 25000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 5, 1.002, 1.002 }},
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

        PriorityFunction = function( builder, aiBrain, unit, manager )

            if aiBrain.NumBasesLand <= 1 then
            
                return 11, true
                
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TELEPORTER ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
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
		
        Priority = 852,

        PriorityFunction = function( builder, aiBrain, unit, manager )
            
            if GetEconomyIncome( aiBrain, 'ENERGY' ) * 10 < 18000 or UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TECH3 * categories.GATE ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 2500, 25000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 5, 1.002, 1.002 }},
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

        PriorityFunction = function( builder, aiBrain, unit, manager )

            if aiBrain.NumBasesLand <= 1 then
            
                return 11, true
                
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.TELEPORTER ) then
            
                return 12, true
                
            end

            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
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