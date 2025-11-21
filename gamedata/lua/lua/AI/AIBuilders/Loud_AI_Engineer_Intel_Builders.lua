--  Loud_AI_Engineer_Intel_Builders.lua
--- Builds all intelligence gathering units such
--- as air and land scouts, radar, sonar & optics 

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'

local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal

local AboveUnitCap80 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

BuilderGroup {BuilderGroupName = 'Engineer Radar Construction - Expansions', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Radar Engineer T1 - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
        
        PriorityFunction = AboveUnitCap80,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
        },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',

				MaxThreat = 30,
                
                BuildStructures = { 'T1Radar' },
            }
        }
    },	

    Builder {BuilderName = 'Radar Engineer T2 - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
        
        PriorityFunction = AboveUnitCap80,
		
        BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
        },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',

				MaxThreat = 30,
                
                BuildStructures = { 'T2Radar' },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Sonar Builders', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Sonar Engineer',
	
        PlatoonTemplate = 'EngineerBuilder',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = AboveUnitCap80,

        BuilderType = { 'T2' },
		
        BuilderConditions = {
			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYSONAR * categories.INTELLIGENCE }},

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

BuilderGroup {BuilderGroupName = 'Engineer Optics Construction', BuildersType = 'EngineerBuilder',
    
    Builder {BuilderName = 'Optics Aeon',

        PlatoonTemplate = 'EngineerBuilder',

		FactionIndex = 2,

		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

        Priority = 760,
        
        PriorityFunction = AboveUnitCap80,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.OPTICS }},
        },
		
        BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',

                BuildStructures = { 'T3Optics' },
            }
        }
    },	

    Builder {BuilderName = 'Optics Cybran',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		FactionIndex = 3,
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 760,

        PriorityFunction = AboveUnitCap80,
        
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 33600 }},

            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION * categories.TECH3 }},
			
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.OPTICS }},
        },
		
        BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',

                BuildStructures = { 'T3Optics' },
            }
        }
    },

}

