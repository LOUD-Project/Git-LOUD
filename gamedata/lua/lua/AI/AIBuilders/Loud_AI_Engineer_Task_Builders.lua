--  /lua/ai/Loud_AI_Engineer_Task_Builders.lua
--- tasks for all engineers - reclaim, repair, assist

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'


-- These are the basic tasks that cover non-specifc things 
-- like reclaim, assist and repair
BuilderGroup {BuilderGroupName = 'Engineer Tasks',
    BuildersType = 'EngineerBuilder',
    
	-- a limited number of high priority shield repairing jobs
    Builder {BuilderName = 'Repair Shield',
	
        PlatoonTemplate = 'EngineerRepairGeneral',
        
        PlatoonAIPlan = 'EngineerAssistShield',
		
        Priority = 750,
        
		InstanceCount = 3,
		
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


    -- These next 4 builders spread SACU assisting out amongst several job types
    -- While these all could have been housed as a single builder - I did this
    -- to insure that the SACU get spread around to multiple jobs
    
	-- SACU assisting any STRUCTURE but energy 
    Builder {BuilderName = 'SCU Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
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

	-- SACU assisting any LAND EXP
    Builder {BuilderName = 'SCU Assist Land Experimental',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
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
    
    -- SACU assisting any AIR EXP
    Builder {BuilderName = 'SCU Assist Air Experimental',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
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
        },
    },
	
    -- SACU assisting any ARTILLERY STRUCTURE (T2 thru T4)
    Builder {BuilderName = 'SCU Assist Artillery',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 1,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},

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
        },
    },


    -- Regular Engineers reclaim mass if storage is quite low
    Builder {BuilderName = 'Reclaim Mass High',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		Priority = 745,
		
        InstanceCount = 3,
		
        BuilderType = { 'T1','T2','T3' },
		
        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 25 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', }},
        },
		
        BuilderData = {
			ReclaimTime = 60,
			ReclaimType = 'Mass',
        },
    },

	-- this builder takes advantage of the 'Any' AssisteeType so one builder can cover both new constructions and upgrades
    -- assist building power if storage is not almost full
    Builder {BuilderName = 'Assist Energy',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
        InstanceCount = 9,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'LessThanEconEnergyStorageRatio', { 75 }},
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
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
        },
    },
    
    -- assist upgrading mass if storage is low
    Builder {BuilderName = 'Assist Mass Upgrade',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
	    PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
		InstanceCount = 4,
		
        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
            
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
        },
    },


    -- repair damaged structures
    Builder {BuilderName = 'Repair',
	
        PlatoonTemplate = 'EngineerRepairGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
		
        InstanceCount = 4,

		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},		
            
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
        },
		
        BuilderData = { },
    },
    
	-- when there is nothing else to do and storage somewhat low
    Builder {BuilderName = 'Reclaim Mass Low',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        InstanceCount = 3,
		
        BuilderType = { 'T1','T2' },		

        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', }},
        },
		
        BuilderData = {
			ReclaimTime = 75,
			ReclaimType = 'Mass',
        },
    },    

    -- when there is nothing else to do and energy somewhat low
    Builder {BuilderName = 'Reclaim Energy',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        InstanceCount = 3,
		
        BuilderType = { 'T1','T2','T3' },

        BuilderConditions = {
			{ MIBC, 'ReclaimablesInAreaEnergy', { 'LocationType', }},
            
			{ EBC, 'LessEconEnergyStorageCurrent', { 5000 }},
        },
		
        BuilderData = {
			ReclaimTime = 75,
			ReclaimType = 'Energy',
        },
    },

    -- when there is nothing else to do assist AIR factories
    Builder {BuilderName = 'Assist Factory AIR',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 701,
		
		InstanceCount = 8,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 1 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE + categories.FACTORY, categories.FACTORY * categories.AIR }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY * categories.AIR,
				BeingBuiltCategories = {categories.FACTORY + categories.MOBILE},
                Time = 90,
            },
        },
    },
    
    -- when there is nothing else to do assist AIR factories
    Builder {BuilderName = 'Assist Factory LAND',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 701,
		
		InstanceCount = 8,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'LandStrengthRatioLessThan', { 1 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE + categories.FACTORY, categories.FACTORY * categories.LAND }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY * categories.LAND,
				BeingBuiltCategories = {categories.FACTORY + categories.MOBILE},
                Time = 90,
            },
        },
    },
    
    -- when there is nothing else to do assist factories
    Builder {BuilderName = 'Assist Factory',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 700,
		
		InstanceCount = 5,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE + categories.FACTORY}},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY,
				BeingBuiltCategories = {categories.FACTORY + categories.MOBILE},
                Time = 90,
            },
        },
    },

    -- when there is nothing else to do - general assist for T1
    Builder {BuilderName = 'T1 Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 6,
		
        Priority = 650,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},		

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
        },
    },

    -- when there is nothing else to do - general assist for T2/T3
    Builder {BuilderName = 'Eng Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 650,
		
        InstanceCount = 8,
		
		BuilderType = { 'T2','T3' },

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},

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
        },
    },

}

BuilderGroup {BuilderGroupName = 'Engineer Tasks - Reclaim Old Structures',
    BuildersType = 'EngineerBuilder',
	
	Builder {BuilderName = 'Reclaim T1 Defenses',
	
        PlatoonTemplate = 'EngineerStructureReclaimerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 730,
        
        InstanceCount = 2,
		
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
        
        InstanceCount = 2,
		
        BuilderType = { 'T2','T3','Commander' },
		
        BuilderConditions = {
			{ LUTL, 'UnitCapCheckGreater', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE - categories.ARTILLERY - categories.SORTSTRATEGIC}},
        },
		
        BuilderData = {
			Reclaim = {categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE - categories.ARTILLERY - categories.SORTSTRATEGIC},
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
        },
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
        },
    },
}


-- These are the basic tasks for an engineer at a Defensive Point
-- but includes all general tasks as well as transfers & local MEX building
BuilderGroup {BuilderGroupName = 'Engineer Tasks - Active DP',
    BuildersType = 'EngineerBuilder',

    -- if no alert
    -- if high unit count is triggered - start reclaiming T2 defense structures
	Builder {BuilderName = 'Reclaim T2 Defenses Active DP',
	
        PlatoonTemplate = 'EngineerStructureReclaimerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 730,
		
        BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'UnitCapCheckGreater', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE }},
        },
		
        BuilderData = {
			Reclaim = {categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE},
        },
    },

    -- if low on mass
    -- make reclaim very important
    Builder {BuilderName = 'Reclaim Mass Active DP',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700, 
		
        InstanceCount = 2,
		
		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},			
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
        },
		
        BuilderData = {
			ReclaimTime = 90,
			ReclaimType = 'Mass',
        },
    },	
	
    -- or build any locally available extractor
    Builder {BuilderName = 'Mass Extractor 200 Active DP',
	 
        PlatoonTemplate = 'EngineerBuilderGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 700,
		
		BuilderType = { 'T2','T3' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 200, -9999, 60, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				BuildClose = true,	#-- engineer will build on closest mass points to itself
				LoopBuild = false,	#-- dont repeat this build - just build once then RTB
				ThreatMin = -9999,
				ThreatMax = 60,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                BuildStructures = {'T2Resource'},
            },
        },
    },	

    -- otherwise
    -- fix things
    Builder {BuilderName = 'Repair Active DP',
	
        PlatoonTemplate = 'EngineerRepairGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
        Priority = 650,

		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 75, 0 }},

            { UCBC, 'DamagedStructuresInArea', { 'LocationType' }},
        },
		
        BuilderData = { },
    },

    -- assist other engineers at this DP
    Builder {BuilderName = 'Assist Active DP',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 2,
		
        Priority = 650,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL, categories.ENGINEER, 125 }},
        },
		
		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
            Assist = {
				AssistRange = 125,
				AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER - categories.TECH1,
                BeingBuiltCategories = {categories.EXPERIMENTAL, categories.STRUCTURE},
                Time = 90,
            },
        },
    },

    -- else
    -- transfer to another base if needed elsewhere and
    -- economy conditions have been quite good for a while
    Builder {BuilderName = 'T2 Engineer Transfers DP',
	
        PlatoonTemplate = 'T2EngineerTransfer',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'EngineerTransferAI'}, },
		
        Priority = 600,
		
        InstanceCount = 1,
		
		BuilderType = { 'T2' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},			
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        BuilderData = {
			TransferCategory = categories.MOBILE * categories.ENGINEER * categories.TECH2,
			TransferType = 'Tech2',
        },
    },	
	
    Builder {BuilderName = 'T3 Engineer Transfers DP',
	
        PlatoonTemplate = 'T3EngineerTransfer',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'EngineerTransferAI'}, },
		
        Priority = 600,
		
        InstanceCount = 1,
		
		BuilderType = { 'T3' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 18900 }},
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
        },
		
        BuilderData = {
			TransferCategory = categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER,
			TransferType = 'Tech3',
        },	
	},

    -- but SACU only transfers if major tasks have been completed at this base
    Builder {BuilderName = 'SCU Transfers DP',
	
        PlatoonTemplate = 'SubCommanderTransfer',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 600,
		
		BuilderType = { 'SubCommander' },		
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
            
			-- check that all the major components are in place
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.ANTIMISSILE * categories.SILO * categories.TECH3, 1, 24 }},
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ANTIAIR, 1, 24 }},			
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.DIRECTFIRE, 1, 24 }},
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.SHIELD, 1, 24 }},
        },
		
        BuilderData = {
			TransferCategory = categories.SUBCOMMANDER,
			TransferType = 'SCU',
        }
    },
	
}



--[[
BuilderGroup {BuilderGroupName = 'Mass Fab Builders Naval Expansions',
    BuildersType = 'EngineerBuilder',	


	
}
--]]
