--   /lua/ai/Loud_AI_Artillery_Builders.lua

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'

local CategoryRestricted = import('/lua/game.lua').CategoryRestricted

local LessThan30MinutesRemain = function(self, aiBrain)

	if aiBrain.VictoryTime then

		if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 30 ) ) then	-- less than 30 minutes left

			return 0, false

		end

	end

	return self.Priority, true

end


BuilderGroup {BuilderGroupName = 'Engineer Artillery Construction T3', BuildersRestriction = 'STRATEGICARTILLERY', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Artillery T3',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)

            if LessThan30MinutesRemain(self, aiBrain) then
                return 0, false
            end

            return self.Priority, true            
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},			

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 75, 1.0125, 1.025 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, (categories.STRATEGIC * categories.ARTILLERY * categories.STRUCTURE) - categories.TECH2 }},

            { UCBC, 'CheckUnitRange', { 'LocationType', 'T3Artillery', categories.STRUCTURE - categories.TECH1} },
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
				Radius = 52,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
                BuildStructures = {'T3Artillery'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Artillery Construction T4', BuildersRestriction = 'EXPERIMENTALARTILLERY', BuildersType = 'EngineerBuilder',
	
	-- this platoon covers Mavor, Scathis, Ylonna Oss & Salvation
    Builder {BuilderName = 'Artillery Experimental',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)

            if LessThan30MinutesRemain(self, aiBrain) then
                return 0, false
            end

            return self.Priority, true            
        end,

		InstanceCount = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            --- only on maps > 20k
			{ MIBC, 'MapGreaterThan', { 1024 } },            

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},
            
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD - categories.ANTIARTILLERY }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},			

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 75, 1.015, 1.025 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.ueb2401 + categories.xab2307 + categories.url0401 + categories.xsb2401 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 6,
			
            Construction = {
				Radius = 50,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
                BuildStructures = {'T4Artillery'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Artillery Construction T3 Expansions', BuildersRestriction = 'STRATEGICARTILLERY', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Artillery T3 Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)

            if LessThan30MinutesRemain(self, aiBrain) then
                return 0, false
            end

            return self.Priority, true            
        end,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
            
			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD - categories.ANTIARTILLERY }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},			
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 75, 1.0125, 1.025 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, (categories.STRATEGIC * categories.ARTILLERY * categories.STRUCTURE) - categories.TECH2 }},

            { UCBC, 'CheckUnitRange', { 'LocationType', 'T3Artillery', categories.STRUCTURE - categories.TECH1} },
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
            
            Construction = {
				Radius = 48,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
                BuildStructures = {'T3Artillery'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Artillery Construction T4 Expansions', BuildersRestriction = 'EXPERIMENTALARTILLERY', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Artillery Experimental Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)

            if LessThan30MinutesRemain(self, aiBrain) then
                return 0, false
            end

            return self.Priority, true            
        end,

		InstanceCount = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            --- only on maps > 20k
			{ MIBC, 'MapGreaterThan', { 1024 } },            

			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

			{ LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.SHIELD - categories.ANTIARTILLERY }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},			

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2.5, 100, 1.02, 1.03 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.ueb2401 + categories.xab2307 + categories.url0401 + categories.xsb2401 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 6,
			
            Construction = {
				Radius = 46,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,

                BuildStructures = {'T4Artillery'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Nuke Construction', BuildersRestriction = 'NUKE', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Nuke Silo',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)

            if LessThan30MinutesRemain(self, aiBrain) then
                return 0, false
            end

            return self.Priority, true            
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		

            { LUTL, 'UnitCapCheckLess', { .95 } },		

			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 75, 1.0125, 1.025 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.NUKE * categories.STRUCTURE }},			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T3StrategicMissile'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Nuke Construction Expansions', BuildersRestriction = 'NUKE', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Nuke Silo Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain)

            if LessThan30MinutesRemain(self, aiBrain) then
                return 0, false
            end

            return self.Priority, true            
        end,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .95 } },		

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},			
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2.5, 100, 1.02, 1.03 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.NUKE * categories.STRUCTURE }},			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
			
				Radius = 1,

				NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3StrategicMissile'},
            }
        }
    },
}

