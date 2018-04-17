--  /lua/ai/Loud_AI_Economic_Builders.lua
--- builds economic structure and general economic 
--- tasks for all engineers - reclaim, repair, assist

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'

BuilderGroup {BuilderGroupName = 'Engineer Builders',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Reclaim Mass High',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		Priority = 745,
		
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2','T3' },
		
        BuilderConditions = {
		
			{ EBC, 'LessThanEconMassStorageRatio', { 20 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', }},
			
        },
		
        BuilderData = {
		
			ReclaimTime = 60,
			ReclaimType = 'Mass',
			
        },
		
    },
	
    Builder {BuilderName = 'Reclaim Mass Low',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        InstanceCount = 3,
		
        BuilderType = { 'T1','T2' },		

        BuilderConditions = {
		
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', }},
			
        },
		
        BuilderData = {
		
			ReclaimTime = 75,
			ReclaimType = 'Mass',
			
        },
		
    },    

    Builder {BuilderName = 'Reclaim Energy',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        InstanceCount = 3,
		
        BuilderType = { 'T1','T2','T3' },

        BuilderConditions = {
		
			{ MIBC, 'ReclaimablesInAreaEnergy', { 'LocationType', }},
			{ EBC, 'LessEconEnergyStorageCurrent', { 6000 }},
			
        },
		
        BuilderData = {
		
			ReclaimTime = 75,
			ReclaimType = 'Energy',
			
        },
		
    },
	
    Builder {BuilderName = 'Repair',
	
        PlatoonTemplate = 'EngineerRepairGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        InstanceCount = 4,

		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
		
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
			
        },
		
        BuilderData = { },
		
    },
	
    Builder {BuilderName = 'Assist Factory',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 650,
		
		InstanceCount = 10,
		
		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE + categories.FACTORY }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY,
				BeingBuiltCategories = {categories.FACTORY + categories.MOBILE},
                Time = 90,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'T1 Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 8,
		
        Priority = 650,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},		
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL - categories.ENERGYPRODUCTION, categories.ENGINEER, 125 }},
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
				AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = {categories.STRUCTURE, categories.EXPERIMENTAL},
                Time = 90,
				
            },
			
        }
		
    },

	-- this builder takes advantage of the 'Any' AssisteeType so one builder can cover both new constructions and upgrades
    Builder {BuilderName = 'Assist Energy',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
        InstanceCount = 8,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
		
			{ EBC, 'LessThanEconEnergyStorageRatio', { 90 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
			{ UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.ENERGYPRODUCTION + categories.ENERGYSTORAGE - categories.EXPERIMENTAL, categories.ENGINEER + categories.ENERGYSTORAGE + categories.ENERGYPRODUCTION, 120 }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 120,
                AssisteeType = 'Any',
				AssisteeCategory = categories.ENGINEER + categories.ENERGYSTORAGE + categories.ENERGYPRODUCTION,
                BeingBuiltCategories = {categories.ENERGYPRODUCTION + categories.ENERGYSTORAGE - categories.EXPERIMENTAL},
                Time = 120,
				
            },
			
        }
		
    },	
    
    Builder {BuilderName = 'Assist Mass Upgrade',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
	    PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
		InstanceCount = 4,
		
        BuilderConditions = {
		
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.MASSPRODUCTION - categories.TECH1, categories.ENGINEER + categories.MASSPRODUCTION, 120 }},
			
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
		
            Assist = {
			
				AssistRange = 120,
                AssisteeType = 'Any',
				AssisteeCategory = categories.ENGINEER + categories.MASSPRODUCTION,
                BeingBuiltCategories = {categories.MASSPRODUCTION - categories.TECH1},
                Time = 90,
				
            },
			
        }
		
    },

    Builder {BuilderName = 'Eng Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 650,
		
        InstanceCount = 8,
		
		BuilderType = { 'T2','T3' },

        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL - categories.ENERGYPRODUCTION, categories.ENGINEER, 125 }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
				AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = { (categories.STRUCTURE + categories.EXPERIMENTAL - categories.ENERGYPRODUCTION) },
                Time = 120,
            },
			
        }
		
    },
	
    Builder {BuilderName = 'SCU Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 3,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL - categories.ENERGYPRODUCTION, categories.ENGINEER, 125 }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = { (categories.STRUCTURE + categories.EXPERIMENTAL - categories.ENERGYPRODUCTION) },
                Time = 150,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'SCU Assist Land Experimental',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.LAND * categories.EXPERIMENTAL - categories.ENERGYPRODUCTION, categories.ENGINEER, 125 }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = { (categories.LAND * categories.EXPERIMENTAL - categories.ENERGYPRODUCTION) },
                Time = 150,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'SCU Assist Air Experimental',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.AIR * categories.EXPERIMENTAL - categories.ENERGYPRODUCTION, categories.ENGINEER, 125 }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = { (categories.AIR * categories.EXPERIMENTAL - categories.ENERGYPRODUCTION) },
                Time = 150,
				
            },
			
        }
		
    },
	
    Builder {BuilderName = 'SCU Assist Artillery',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE * categories.ARTILLERY, categories.ENGINEER, 125 }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
                BeingBuiltCategories = { (categories.STRUCTURE * categories.ARTILLERY) },
                Time = 150,
				
            },
			
        }
		
    },

}


BuilderGroup {BuilderGroupName = 'Engineer Tasks - Aux',
    BuildersType = 'EngineerBuilder',
	
	Builder {BuilderName = 'Reclaim T1 Defenses',
	
        PlatoonTemplate = 'EngineerStructureReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 730,
		
        BuilderType = { 'T1','T2','T3','Commander' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH1 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL }},
			
        },
		
        BuilderData = {
		
			Reclaim = {categories.TECH1 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL},
        },
		
    },
	
	Builder {BuilderName = 'Reclaim T2 Defenses',
	
        PlatoonTemplate = 'EngineerStructureReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 730,
		
        BuilderType = { 'T2','T3','Commander' },
		
        BuilderConditions = {
		
			{ LUTL, 'UnitCapCheckGreater', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE }},
			
        },
		
        BuilderData = {
		
			Reclaim = {categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE},
			
        },
		
    },
    
	Builder {BuilderName = 'Reclaim Power',
	
        PlatoonTemplate = 'EngineerStructureReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,
		
        BuilderType = { 'Commander','T2','T3','SubCommander' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.DRAGBUILD - categories.TECH3 - categories.EXPERIMENTAL - categories.HYDROCARBON}},
			
        },
		
        BuilderData = {
		
			Reclaim = {categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH3 - categories.EXPERIMENTAL - categories.HYDROCARBON},
			
        },
		
    },
	
    Builder {BuilderName = 'Repair Shield',
	
        PlatoonTemplate = 'EngineerRepairGeneral',
        PlatoonAIPlan = 'EngineerAssistShield',
		
        Priority = 750,
		InstanceCount = 4,
		
		BuilderType = { 'Commander','T2','T3','SubCommander' },

        BuilderConditions = {
		
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, (categories.STRUCTURE * categories.SHIELD - categories.TECH2) }},
            { UCBC, 'ShieldDamaged', { 'LocationType' }},
			
        },
		
        BuilderData = {
		
            Assist = {
			
                BeingBuiltCategories = {categories.SHIELD * categories.STRUCTURE - categories.TECH2},
                Time = 25,
            },
			
        },

    },
	
}


BuilderGroup {BuilderGroupName = 'Engineer Transfers',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T2 Engineer Transfers',
	
        PlatoonTemplate = 'T2EngineerTransfer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'EngineerTransferAI'}, },
		
        Priority = 650,
		
        InstanceCount = 1,
		
		BuilderType = { 'T2' },

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},			
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			{ UCBC, 'BaseCount', { 1, '>' } }
			
        },
		
        BuilderData = {
		
			TransferCategory = categories.MOBILE * categories.ENGINEER * categories.TECH2,
			TransferType = 'Tech2',
			
        }
    },

    Builder {BuilderName = 'T3 Engineer Transfers',
	
        PlatoonTemplate = 'T3EngineerTransfer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'EngineerTransferAI'}, },
		
        Priority = 650,
		
        InstanceCount = 1,
		
		BuilderType = { 'T3' },

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			{ UCBC, 'BaseCount', { 1, '>' } }
			
        },
		
        BuilderData = {
		
			TransferCategory = categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER,
			TransferType = 'Tech3',
			
        }
    },

    Builder {BuilderName = 'SCU Transfers',
	
        PlatoonTemplate = 'SubCommanderTransfer',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'EngineerTransferAI'}, },
		
        Priority = 750,
		
        InstanceCount = 1,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'BaseCount', { 1, '>' } }
			
        },
		
        BuilderData = {
		
			TransferCategory = categories.SUBCOMMANDER,
			TransferType = 'SCU',
			
        }
		
    },
	
}



BuilderGroup {BuilderGroupName = 'Extractor Builders',
    BuildersType = 'EngineerBuilder',

	-- build mass at higher priority when close
    Builder {BuilderName = 'Mass Extractor - 200 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        InstanceCount = 1,
		
		BuilderType = { 'T1' },

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 200, -9999, 60, 0, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- engineer will build on points closest to itself
				LoopBuild = true,		-- repeat this build until it fails
				ThreatMin = -9999,
				ThreatMax = 75,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T1Resource' }
				
            }
			
        }
		
    },
	
	-- build mass at higher priority when close
    Builder {BuilderName = 'Mass Extractor T2 - 200 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        InstanceCount = 1,
		
		BuilderType = { 'T2','T3' },

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 200, -9999, 60, 0, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- engineer will build on points closest to itself
				LoopBuild = false,		-- build and RTB
				ThreatMin = -9999,
				ThreatMax = 75,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T2Resource' }
            }
			
        }
		
    },	

    Builder {BuilderName = 'Mass Extractor T3 - 200 - BuildClose',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 850,
        InstanceCount = 1,
		
		BuilderType = { 'SubCommander' },

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 200, -9999, 60, 0, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- engineer will build on points closest to itself
				LoopBuild = false,		-- build and RTB
				ThreatMin = -9999,
				ThreatMax = 60,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T3Resource' }
				
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
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 30, 1, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,		-- build on mass points closest to itself
				LoopBuild = false,		-- dont repeat - just build once then RTB
				ThreatMin = -9999,
				ThreatMax = 25,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T2Resource' }
				
            }
			
        }
		
    },
 	
    Builder {BuilderName = 'Mass Extractor 1500 - Loop',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 760,
        InstanceCount = 1,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -9999, 10, 1, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
            Construction = {
				BuildClose = true,		-- engineer will build points closest to itself
				LoopBuild = true,		-- repeating build until it fails to find a target or dead
				ThreatMin = -9999,
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
		
        Priority = 700,
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -9999, 10, 1, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = false,		-- build on points closest to base
				LoopBuild = false,
				ThreatMin = -9999,
				ThreatMax = 10,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T1Resource' }
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Extractor Builders - Expansions',
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
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 30, 1, 'AntiSurface', 1 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				BuildClose = true,
				LoopBuild = true,		-- repeat build until no target or dead
				ThreatMin = -9999,
				ThreatMax = 25,
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
			{ LUTL, 'NeedMassPointShare', {} },	
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -9999, 10, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				LoopBuild = false,	#-- repeat build until no target or dead
				ThreatMin = -9999,
				ThreatMax = 10,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                BuildStructures = { 'T1Resource' }
				
            }
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Extractor Builders Naval Expansions',
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
			{ LUTL, 'NeedMassPointShare', {} },
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 30, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
		
            Construction = {
			
				LoopBuild = false,	#-- build only once then RTB
				ThreatMin = -9999,
				ThreatMax = 25,
				ThreatRings = 1,
				ThreatType = 'AntiSurface',
                BuildStructures = {'T1Resource'}
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Mass Fab Builders',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Fab - Template',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
	
		BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 10, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.02 }},
			
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

BuilderGroup {BuilderGroupName = 'Mass Fab Builders - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Mass Fab - Template - LOUD_IS',
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 800,
		
		BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },

			-- check base massfabs 
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 10, categories.MASSFABRICATION * categories.TECH3, 10, 42 }},
			-- there has to be advanced power at this location
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.02 }},
			
        },
		
        BuilderData = {
		
            Construction = {
			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				Iterations = 1,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassFabLayout',
                BuildStructures = {'T3MassCreation' },
				
            }
			
        }
		
    }, 
	
}

BuilderGroup {BuilderGroupName = 'Mass Fab Builders - Expansions',
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
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.02 }},
			
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

BuilderGroup {BuilderGroupName = 'Mass Fab Builders - Expansions - LOUD_IS',
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
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.ENERGYPRODUCTION - categories.TECH1 }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.02 }},
			
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

BuilderGroup {BuilderGroupName = 'Mass Fab Builders Naval Expansions',
    BuildersType = 'EngineerBuilder',	

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
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.3, 1.02 }},
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


BuilderGroup {BuilderGroupName = 'Mass Storage',
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

BuilderGroup {BuilderGroupName = 'Engineering Support Builder',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Engineering Support - Base Template',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
		
        BuilderConditions = {
		
 			{ MIBC, 'FactionIndex', { 1, 3 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.ENGINEERSTATION}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 4, categories.ENERGYPRODUCTION * categories.TECH3}},
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
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ENGINEERSTATION}},
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 4, categories.ENERGYPRODUCTION * categories.TECH3}},
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
