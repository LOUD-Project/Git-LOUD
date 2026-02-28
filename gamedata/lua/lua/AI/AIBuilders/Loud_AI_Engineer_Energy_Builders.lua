-- Loud_AI_Engineer_Energy_Builders.lua

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local GetUnitsAroundPoint                           = moho.aibrain_methods.GetUnitsAroundPoint
local GreaterThanEnergyIncome                       = import(LUTL).GreaterThanEnergyIncome
local HaveGreaterThanUnitsWithCategory              = import(UCBC).HaveGreaterThanUnitsWithCategory
local HaveGreaterThanUnitsWithCategoryAndAlliance   = import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance
local UnitsGreaterAtLocation                        = import(UCBC).UnitsGreaterAtLocation
local UnitsGreaterAtLocationInRange                 = import(UCBC).UnitsGreaterAtLocationInRange
local UnitsLessAtLocation                           = import(UCBC).UnitsLessAtLocation
local UnitsLessAtLocationInRange                    = import(UCBC).UnitsLessAtLocationInRange

-- imbedded into the Builder
local First45Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 2700 then
		return 0, false
	end

	return self.Priority,true
end

local ENERGY    = categories.ENERGYPRODUCTION
local HYDRO     = categories.HYDROCARBON
local ENERGYT1  = ENERGY * categories.TECH1
local ENERGYT2  = ENERGY * categories.TECH2 - HYDRO
local ENERGYT3  = ENERGY * categories.TECH3



BuilderGroup {BuilderGroupName = 'Engineer Energy Builders', BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T1 Power Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        InstanceCount = 4,
		
        Priority = 761,
        
        PriorityFunction = function( self, aiBrain, unit, manager )
	
            if aiBrain.CycleTime > 3600 then
                return 0, false
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, ENERGYT3 ) then
                return 11, true
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 75, ENERGYT1, 0, 33 ) then
                return 12, true
            end
 
            -- if T2 power is present - priority is the same as Assist Energy task
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, ENERGYT2 ) then
                return 745, true
            end

	
            return (self.OldPriority or self.Priority), true
        end,
		
        BuilderConditions = {

			{ EBC, 'GreaterThanEconStorageCurrent', { 150, 0 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 90 }},            
            { EBC, 'LessThanEnergyTrendOverTime', { 10 }},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 35,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = {'T1EnergyProduction'},
            }
        }
    },
	
    Builder {BuilderName = 'T2 Power Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 900,
        
        PriorityFunction = function( self, aiBrain, unit, manager )
	
            if aiBrain.CycleTime > 3600 then
                return 0, false
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, ENERGYT3 ) then
                return 12, true
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 8, ENERGY - categories.TECH1 ) then
                return 11, true
            end
	
            return (self.OldPriority or self.Priority), true
        end,
        
        BuilderConditions = {
        
			{ EBC, 'LessThanEnergyTrend', { 90 }},
			{ EBC, 'LessThanEnergyTrendOverTime', { 80 }},
			--{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 6,
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 75,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = { 'T2EnergyProduction' },
            }
        }
    },

    Builder {BuilderName = 'T3 Power Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 851,
        
        PriorityFunction = function( self, aiBrain, unit, manager )
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 25, ENERGYT3 - HYDRO ) then
                return 12, true
            end
	
            return (self.OldPriority or self.Priority), true
        end,
    
        BuilderConditions = {

			{ EBC, 'LessThanEnergyTrend', { 300 }},        
			{ EBC, 'LessThanEnergyTrendOverTime', { 260 }},

			{ UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, ENERGYT3 }},
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 7,
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 60,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'PowerLayout',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
	
    Builder {BuilderName = 'Hydrocarbon',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 750,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
        
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 150, 2400 }},
            
			{ LUTL, 'HaveLessThanUnitsWithCategory', { 3, HYDRO }},
			
            { EBC, 'CanBuildOnHydroLessThanDistance',  { 'LocationType', 350, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
                BuildStructures = {'T1HydroCarbon'},
                
				LoopBuild = true,
                
                MaxRange = 350,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',                
            }
        }
    },	
	
    -- This platoon comes into play at the end of the T3 power template
    -- usually only when the base gets very large
    Builder {BuilderName = 'T3 Power - Perimeter',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 840,
        
        PriorityFunction = function( self, aiBrain, unit, manager )
            
            if not GreaterThanEnergyIncome( aiBrain, 33600 ) then
                return 10, true
            end
            
            if not UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 20, ENERGYT3 - HYDRO, 0, 59 ) then
                return 11, true
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, ENERGYT3, 60, 80 ) then
                return 12, true
            end

            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'LessThanEnergyTrend', { 300 }},
			{ EBC, 'LessThanEnergyTrendOverTime', { 260 }},
   			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},
            
			{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, ENERGYT3 }},
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
			
				Radius = 68,
                
                NearBasePerimeterPoints = true,
                
                ThreatMax = 55,
				
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Energy Builders - Expansions', BuildersType = 'EngineerBuilder',
   
    Builder {BuilderName = 'Hydrocarbon - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 700,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { EBC, 'CanBuildOnHydroLessThanDistance',  { 'LocationType', 350, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderType = { 'T2' },
		
        BuilderData = {
            Construction = {
                BuildStructures = { 'T1HydroCarbon' },
                
				LoopBuild = false,	#-- build only once then RTB
                
                MaxRange = 350,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',                
            }
        }
    },    
	
    Builder {BuilderName = 'T3 Power Template - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 750,

        BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},

			{ EBC, 'LessThanEnergyTrend', { 300 }},			
			{ EBC, 'LessThanEnergyTrendOverTime', { 260 }},
            
			-- don't build T3 power if one is already being built somewhere else
			{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, ENERGYT3 }},
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 16, ENERGYT3 - HYDRO }},
        },
        
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
			
				Radius = 1,
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Energy Builders - Naval', BuildersType = 'EngineerBuilder',

    -- in LOUD, T2 & T3 Pgens are capable of building on seafloor - this will do that
    Builder {BuilderName = 'T2 Power - Naval',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 900,
        
        PriorityFunction = First45Minutes,
		
        BuilderType = { 'T2' },
		
        BuilderConditions = {
        
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},
			
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, (ENERGY - categories.TECH1) - HYDRO }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 0 }},            
			{ EBC, 'LessThanEnergyTrend', { 60 }},
			{ EBC, 'LessThanEnergyTrendOverTime', { 60 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},
        },
        
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = { 'T2EnergyProduction' },
            }
        }
    },
    
	-- this one is different than usual in that there is no check to see if building any other T3 power elsewhere
    Builder {BuilderName = 'T3 Power - Naval',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},
			
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, ENERGYT3 - HYDRO }},
            
			{ EBC, 'LessThanEnergyTrend', { 300 }},            
			{ EBC, 'LessThanEnergyTrendOverTime', { 260 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},            
        },
        
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
			
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = { 'T3EnergyProduction' },
            }
        }
    },
	
    Builder {BuilderName = 'Hydrocarbon - Naval',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 750,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
        
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 150, 2400 }},
            
			{ LUTL, 'HaveLessThanUnitsWithCategory', { 3, HYDRO }},
			
            { EBC, 'CanBuildOnHydroLessThanDistance',  { 'LocationType', 350, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
                BuildStructures = {'T1HydroCarbon'},
                
				LoopBuild = true,
                
                MaxRange = 350,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',                
            }
        }
    },	
	
}

-- this only comes into play when IS is turned on - rings local MEX with power
BuilderGroup {BuilderGroupName = 'Engineer Mass Energy Construction', BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Energy Adjacency',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        PlatoonAIPlan = 'EngineerBuildMassAdjacencyAI',
		
        Priority = 762,
		
		PriorityFunction = First45Minutes,

		InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 400 }}, -- higher cost to prevent hurting early economy
            
            { EBC, 'LessThanEnergyTrendOverTime', { 10 }},
            
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, ENERGY - categories.TECH1 }},            

			{ UCBC, 'MassExtractorInRangeHasLessThanEnergy', {'LocationType', 20, 180, 4 }},
        },
		
        BuilderData = {
            Construction = {
				LoopBuild = true,
                LoopMass = 125,
                LoopEnergy = 1250,
				
				MinRadius = 20,
				Radius = 180,
				
				MinStructureUnits = 4,
                
                AdjacencyStructure = ENERGYT1,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'EnergyAdjacency',
				
                BuildStructures = {'T1EnergyProduction','T1EnergyProduction','T1EnergyProduction','T1EnergyProduction'}
            }
        }
    },
	
}

-- used when IS is turned off
BuilderGroup {BuilderGroupName = 'Engineer Energy Storage Construction', BuildersType = 'EngineerBuilder',
	
	Builder {BuilderName = 'Energy Storage - HydroCarbon',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 700,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 0, HYDRO }},

            { UCBC, 'AdjacencyCheck', { 'LocationType', 'HYDRO', 450, 'ueb1105' }},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
            Construction = {
			
				AdjacencyCategory = HYDRO,
                AdjacencyDistance = 450,
                
                BuildStructures = {'EnergyStorage','EnergyStorage'},
            }
        }
    },
}

