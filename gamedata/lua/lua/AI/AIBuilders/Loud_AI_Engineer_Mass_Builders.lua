-- Loud_AI_Engineer_Mass_Builders.lua

local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

local LUTL = '/lua/loudutilities.lua'


BuilderGroup {BuilderGroupName = 'Engineer Mass Builders',
    BuildersType = 'EngineerBuilder',


    Builder {BuilderName = 'Mass Extractor T1 - 250',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        
        InstanceCount = 1,
		
		BuilderType = { 'T1','T2','T3' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 225, -9999, 50, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- seek points closest to engineer
				LoopBuild = true,		-- repeat until none in range
                
                MaxRange = 250,

				ThreatMax = 50,
				ThreatRings = 0,
                
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },

    Builder {BuilderName = 'Mass Extractor T1 - 750 - Loop',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 845,
        
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 1000 }},            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 750, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = false,     -- seek points in range of base
				LoopBuild = true,       -- repeat until none
                
                MaxChoices = 4,         -- pick from list of up to 4 closest
                
                MinRange = 150,
                MaxRange = 750,
                
				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },

    Builder {BuilderName = 'Mass Extractor T1 - 1500 - Loop',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 760,
        
        InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 1000 }},            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 1500, -9999, 15, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				BuildClose = true,		-- seek points in range of engineer
				LoopBuild = true,
                
                MaxChoices = 6,         -- pick from list of up to 8 closest
                
                MinRange = 150,
                MaxRange = 1500,

				ThreatMax = 15,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },  
 	
    -- additional loop engineer is just here for mass heavy maps
    Builder {BuilderName = 'Mass Extractor T1 - 1500 - Loop - Extra',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 755,
        
        InstanceCount = 1,
		
        BuilderType = { 'T1','T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            -- at this point we'll use a low multiplier - this will keep the builder active until we
            -- reach that portion of the mass share -
            -- this is likely the only place where I might use this
			{ LUTL, 'NeedMassPointShare', { .5 } },
            
            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 1000 }},            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 1500, -9999, 10, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				BuildClose = false,		-- seek points in range of base
				LoopBuild = true,
                
                MaxChoices = 6,         -- pick from list of up to 6 closest
                
                MinRange = 150,
                MaxRange = 1500,

				ThreatMax = 15,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },  
    
    Builder {BuilderName = 'Mass Extractor T2 - 750 - Loop',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 840,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 1000 }},            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 750, -9999, 40, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = true,
				LoopBuild = true,
                
                MinRange = 150,
                MaxRange = 750,

				ThreatMax = 40,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T2Resource' }
            }
        }
    },

    -- build T2 MassFab
    Builder {BuilderName = 'Mass Fab T2 - Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

		BuilderType = { 'T2','T3' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.MASSFABRICATION, 10, 42 }},
            
            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 1000 }},                        
        },

        BuilderData = {

            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 50,

				Iterations = 1,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
                
                BuildStructures = {'T1MassCreation'},
            }
        }
    }, 

    -- SACU build MassFab
    Builder {BuilderName = 'Mass Fab T3 - Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

		BuilderType = { 'SubCommander' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 10, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
			--{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			--{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.04 }},
        },

        BuilderData = {

            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 50,

				Iterations = 1,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
                
                BuildStructures = {'T3MassCreation'},
            }
        }
    }, 

	

}

BuilderGroup {BuilderGroupName = 'Engineer Mass Builders - Defensive Point',
    BuildersType = 'EngineerBuilder',

	-- builds mass if some is available
    Builder {BuilderName = 'Mass Extractor - 200 - DP',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 745,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },			
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 200, -9999, 35, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = true,
				LoopBuild = true,		-- repeat build until no target or dead
                
                MaxRange = 200,

				ThreatMax = 35,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T2Resource' }
            }
        }
    },
	
}



BuilderGroup {BuilderGroupName = 'Engineer Mass Builders - Expansions',
    BuildersType = 'EngineerBuilder',
    
    Builder {BuilderName = 'Mass Extractor T1 - 150 - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        
        InstanceCount = 1,
		
		BuilderType = { 'T1','T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },			
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 150, -9999, 60, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = false,
				LoopBuild = true,		-- repeat build until no target or dead
                
                MaxRange = 150,

				ThreatMax = 60,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },
	
    Builder {BuilderName = 'Mass Extractor T2 - 750 - Loop - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 840,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },			
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 750, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = true,
				LoopBuild = true,		-- repeat build until no target or dead
                
                MinRange = 150,
                MaxRange = 750,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T2Resource' }
            }
        }
    },
	

}

BuilderGroup {BuilderGroupName = 'Engineer Mass Builders - Naval',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Mass Extractor T2 - 750 - Loop - Naval',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        Priority = 800,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 750, -9999, 30, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
        
            Construction = {
            
                BuildClose = false,
				LoopBuild = true,
                
                MaxRange = 750,

				ThreatMax = 30,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = {'T1Resource'}
            }
        }
    },
    
    Builder {BuilderName = 'Mass Fab - Naval Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 40 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
            
            { EBC, 'LessThanEconEfficiencyOverTime', { 1.05, 2 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.04 }},
            
            { UCBC, 'BuildingLessAtLocation', { 'LocationType', 1, categories.MASSFABRICATION }},
        },
		
        BuilderData = {
		
            Construction = {
				NearBasePerimeterPoints = true,

				ThreatMax = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = { 'T3MassCreation' },
            }
        }
    },	

}

BuilderGroup {BuilderGroupName = 'Engineer Mass Fab Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Fab Expansion - Template',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,
		
		BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.04 }},
        },
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				Iterations = 1,
				
                BuildStructures = {
                    'T3MassCreation',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
					'MassStorage',
                },
            }
        }
    }, 
	
}

BuilderGroup {BuilderGroupName = 'Engineer Mass Fab Construction - Expansions - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Fab - Expansion - IS',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.04 }},
        },
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,

				ThreatMax = 50,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',

                BuildStructures = { 'T3MassCreation' },
            }
        }
    }, 
	
}

BuilderGroup {BuilderGroupName = 'Engineer Mass Storage Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Storage 600',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        PlatoonAIPlan = 'EngineerBuildMassAdjacencyAI',
		
        Priority = 750,
		
		InstanceCount = 2,
		
        BuilderType = { 'T1','T2' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ UCBC, 'MassExtractorInRangeHasLessThanStorage', {'LocationType', 20, 600, 4 }},
        },
		
        BuilderData = {
            Construction = {
				LoopBuild = true,
				
				MinRadius = 20,
				Radius = 600,
				
				MinStructureUnits = 4,
                
                AdjacencyStructure = categories.MASSSTORAGE,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacency',
				
                BuildStructures = {
                    'MassStorage',
                    'MassStorage',
					'MassStorage',
					'MassStorage',
                }
            }
        }
    },
	
    Builder {BuilderName = 'Mass Storage 1024',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        PlatoonAIPlan = 'EngineerBuildMassAdjacencyAI',
		
        Priority = 740,
		
		InstanceCount = 2,
		
        BuilderType = { 'T1','T2' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.02 }},
			{ UCBC, 'MassExtractorInRangeHasLessThanStorage', {'LocationType', 500, 1024, 4 }},
        },
		
        BuilderData = {
            Construction = {
				LoopBuild = false,
				
				MinRadius = 500,
				Radius = 2048,
                
                AdjacencyStructure = categories.MASSSTORAGE,

				MinStructureUnits = 4,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacency',
				
                BuildStructures = {
                    'MassStorage',
                    'MassStorage',
					'MassStorage',
					'MassStorage',
                }
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Mass Storage Construction - Active DP',
	BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Mass Storage DP',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        PlatoonAIPlan = 'EngineerBuildMassAdjacencyAI',
		
        Priority = 600,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ UCBC, 'MassExtractorInRangeHasLessThanStorage', {'LocationType', 20, 200, 4 }},
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
				MinRadius = 20,
				Radius = 200,
                
				MinStructureUnits = 4,
                
                AdjacencyStructure = categories.MASSSTORAGE,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacency',

                BuildStructures = {
                    'MassStorage',
                    'MassStorage',
					'MassStorage',
					'MassStorage',
                }
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Eng Station Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Engineering Support - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
		
        BuilderConditions = {
 			{ MIBC, 'FactionIndex', { 1, 3 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, categories.ENGINEERSTATION}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
        },
		
		BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 30,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = { 'T2EngineerSupport' },
            }
        }
    },

	Builder {BuilderName = 'T3 Engineering Support - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
		
        BuilderConditions = {
 			{ MIBC, 'FactionIndex', { 2, 4 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, categories.ENGINEERSTATION}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
        },
		
		BuilderType = { 'T3' },
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 30,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = { 'T3EngineerSupport' },
            }
        }
    },
	
}
