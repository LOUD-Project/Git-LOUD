-- Loud_AI_Engineer_Mass_Builders.lua

local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

local LUTL = '/lua/loudutilities.lua'


BuilderGroup {BuilderGroupName = 'Engineer Mass Builders',
    BuildersType = 'EngineerBuilder',

	-- build mass at higher priority when close - looping
    Builder {BuilderName = 'Mass Extractor T1 - 150 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        
        InstanceCount = 1,
		
		BuilderType = { 'T1' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 150, -9999, 60, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- engineer will build on points closest to itself
				LoopBuild = true,		-- repeat this build until it fails
                
                MaxRange = 150,

				ThreatMax = 60,
				ThreatRings = 0,
                
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },
 	
    Builder {BuilderName = 'Mass Extractor T1 - 1500 - Loop',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 760,
        
        InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 1500, -9999, 10, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				BuildClose = true,		-- engineer will build points closest to itself
				LoopBuild = true,		-- repeating build until it fails to find a target or dead
                
                MinRange = 150,
                MaxRange = 1500,

				ThreatMax = 10,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },  
 	
    -- this additional looping mex engineer is really just here to give LOUD more 'umph' on
    -- mass heavy maps or situations where he's got a lot of mass points to cover beyond a 
    -- typical scenario
    Builder {BuilderName = 'Mass Extractor T1 - 1500 - Loop - Extra',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 755,
        
        InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            -- at this point we'll use a low multiplier - this will keep the builder active until we
            -- reach that portion of the mass share -
            -- this is likely the only place where I might use this
			{ LUTL, 'NeedMassPointShare', { .5 } },
            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 300, 1500, -9999, 10, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				BuildClose = false,		-- engineer will build points closest to base
				LoopBuild = true,		-- repeating build until it fails to find a target or dead
                
                MinRange = 300,
                MaxRange = 1500,

				ThreatMax = 10,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },  

    Builder {BuilderName = 'Mass Extractor 1500',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 745,
        
        InstanceCount = 2,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 150, 1000, -9999, 10, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = false,		-- build on points closest to base
				LoopBuild = false,
                
                MinRange = 150,
                MaxRange = 1000,
                
				ThreatMax = 10,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },
	
	-- build mass at higher priority when close - once only
    Builder {BuilderName = 'Mass Extractor T2 - 150 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 150, -9999, 60, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- engineer will build on points closest to itself
				LoopBuild = false,		-- build and RTB
                
                MaxRange = 150,

				ThreatMax = 60,
				ThreatRings = 0,
                
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T2Resource' }
            }
        }
    },	

    -- SACU build T3 MEX at high priority when close - once only
    Builder {BuilderName = 'Mass Extractor T3 - 150 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        
        InstanceCount = 1,
		
		BuilderType = { 'SubCommander' },

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 150, -9999, 60, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- engineer will build on points closest to itself
				LoopBuild = false,		-- build and RTB
                
                MaxRange = 150,
                
				ThreatMax = 60,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T3Resource' }
            }
        }
    },

    -- SACU build MassFab
    Builder {BuilderName = 'Mass Fab - Template',
    
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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
			
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.04 }},
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

	
	-- build mass with advanced engineers at higher priority when needed
    Builder {BuilderName = 'Mass Extractor - 750 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 810,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 750, -9999, 45, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = true,		-- build on mass points closest to itself
				LoopBuild = false,		-- dont repeat - just build once then RTB
                
                MaxRange = 750,

				ThreatMax = 45,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T2Resource' }
            }
        }
    },

}

BuilderGroup {BuilderGroupName = 'Engineer Mass Builders - Defensive Point',
    BuildersType = 'EngineerBuilder',

	-- builds mass if some is available
    Builder {BuilderName = 'Mass Extractor - 200 - DP',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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

	-- builds mass if some is available
    Builder {BuilderName = 'Mass Extractor - 750 - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
        
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },			
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 750, -9999, 45, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				BuildClose = true,
				LoopBuild = true,		-- repeat build until no target or dead
                
                MaxRange = 750,

				ThreatMax = 45,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T2Resource' }
            }
        }
    },
	
	-- general mass builder for Expansion base
    Builder {BuilderName = 'Mass Extractor 1500 - Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 750,
        
        InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'NeedMassPointShare', { 1 } },	
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 1500, -9999, 10, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
				LoopBuild = false,	#-- repeat build until no target or dead
                
                MaxRange = 1500,

				ThreatMax = 10,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                
                BuildStructures = { 'T1Resource' }
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Mass Builders - Naval',
    BuildersType = 'EngineerBuilder',

	-- builds mass if we are low on share and some is available
    Builder {BuilderName = 'Mass Extractor - 750 - Naval',
    
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        Priority = 800,
        
        InstanceCount = 1,
		
		BuilderType = { 'T1','T2' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ LUTL, 'NeedMassPointShare', { 1 } },
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 750, -9999, 45, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				LoopBuild = false,	#-- build only once then RTB
                
                MaxRange = 750,

				ThreatMax = 45,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                
                BuildStructures = {'T1Resource'}
            }
        }
    },
    
    Builder {BuilderName = 'Mass Fab - Naval Expansion',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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
    
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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
	
    Builder {BuilderName = 'Mass Fab Expansion - Template - LOUD_IS',
    
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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
	
        PlatoonTemplate = 'MassAdjacencyEngineer',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
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
				
				MinStorageUnits = 4,
				
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
	
        PlatoonTemplate = 'MassAdjacencyEngineer',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
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
				
				MinStorageUnits = 4,
				
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
	
        PlatoonTemplate = 'MassAdjacencyEngineer',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
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
                
				MinStorageUnits = 4,
                
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
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
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
