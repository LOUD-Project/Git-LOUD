--  /lua/ai/Loud_AI_Engineer_Task_Builders.lua
--- tasks for all engineers - reclaim, repair, assist

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'

local LUTL  = '/lua/loudutilities.lua'
local BHVR  = '/lua/ai/aibehaviors.lua'


-- These are the basic tasks that cover non-specifc things 
-- like reclaim, assist and repair
BuilderGroup {BuilderGroupName = 'Engineer Tasks',
    BuildersType = 'EngineerBuilder',
    
	-- a limited number of high priority shield repairing jobs
    Builder {BuilderName = 'Repair Shield',
	
        PlatoonTemplate = 'EngineerGeneral',
        
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 3,
		
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 3,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'LandStrengthRatioLessThan', { 1.1 } },
            
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 3,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },
            
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 2,
		
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
        
        PlatoonAIPlan = 'EngineerReclaimAI',
		
		Priority = 745,
		
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 140 }},
        },
		
        BuilderData = {
			ReclaimTime = 90,
			ReclaimType = 'Mass',
            ReclaimRange = 145,
        },
    },

	-- this builder takes advantage of the 'Any' AssisteeType so one builder can cover both new constructions and upgrades
    -- assist building power if storage is not almost full
    Builder {BuilderName = 'Assist Energy',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
        InstanceCount = 6,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'LessThanEnergyTrendOverTime', { 260 }},

			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 120, 1250 }},
            
			{ UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.ENERGYPRODUCTION + categories.ENERGYSTORAGE - categories.EXPERIMENTAL, categories.ENGINEER + categories.ENERGYSTORAGE + categories.ENERGYPRODUCTION, 120 }},
        },
		
        BuilderData = {
            Assist = {
                -- this allows the builder to continue assist until M drops below this
                AssistMass = 35,
                -- this allows the builder to continue assist until E drops below this
                AssistEnergy = 100,
            
				AssistRange = 120,
                AssisteeType = 'Any',
				AssisteeCategory = categories.ENGINEER + categories.ENERGYSTORAGE + categories.ENERGYPRODUCTION,
                BeingBuiltCategories = {categories.ENERGYPRODUCTION + categories.ENERGYSTORAGE - categories.EXPERIMENTAL},
                Time = 90,
            },
        },
    },
    
    -- assist upgrading mass if storage is low
    -- again we use the 'Any' Assistee type to help either new builds or upgrades
    Builder {BuilderName = 'Assist Mass',
	
        PlatoonTemplate = 'EngineerGeneral',
        
	    PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 740,
		
		InstanceCount = 3,
		
        BuilderConditions = {
            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.MASSPRODUCTION - categories.TECH1, categories.ENGINEER + categories.MASSPRODUCTION, 120 }},
            
			{ EBC, 'LessThanEconMassStorageRatio', { 60 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 4 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},            
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
            Assist = {
            
                -- this allows the builder to continue assist until E drops below this
                AssistEnergy = 500,
                -- this allows the builder to continue assist until M drops below this
                AssistMass = 75,
            
				AssistRange = 120,
                AssisteeType = 'Any',
				AssisteeCategory = categories.ENGINEER + categories.MASSPRODUCTION,
                BeingBuiltCategories = {categories.MASSPRODUCTION - categories.TECH1},
                Time = 90,
            },
        },
    },

    -- when energy is low
    Builder {BuilderName = 'Reclaim Energy',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 740,
		
        InstanceCount = 3,
		
        BuilderType = { 'T1','T2','T3' },

        BuilderConditions = {
			{ EBC, 'LessThanEconEnergyStorageCurrent', { 6000 }},

            { EBC, 'LessThanEnergyTrendOverTime', { 30 }},
            
			{ MIBC, 'ReclaimablesInAreaEnergy', { 'LocationType', 120 }},
        },
		
        BuilderData = {
			ReclaimTime = 75,
			ReclaimType = 'Energy',
            ReclaimRange = 120,
        },
    },


    -- repair damaged structures
    Builder {BuilderName = 'Repair',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 700,
		
        InstanceCount = 4,

		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
            
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},		

        },
		
        BuilderData = { },
    },
    
	-- when there is nothing else to do and storage somewhat low
    -- this is a shorter ranged version of the 'High' builder
    Builder {BuilderName = 'Reclaim Mass Low',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 660,
		
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2' },		

        BuilderConditions = {
        
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},
            
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 110 }},
        },
		
        BuilderData = {
			ReclaimTime = 75,
			ReclaimType = 'Mass',
            ReclaimRange = 120,
        },
    },    

    -- Assist ACU and SACU Enhancements
    Builder {BuilderName = 'Assist ACU SACU',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
		InstanceCount = 4,
		
		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.ENGINEER, categories.ENGINEER, 100 }},

        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Engineer',
				AssisteeCategory = categories.ENGINEER,
				BeingBuiltCategories = {categories.ENGINEER},
                Time = 90,
            },
        },
    },

    -- when there is nothing else to do assist AIR factories
    Builder {BuilderName = 'Assist Factory AIR',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 740,
		
		InstanceCount = 8,
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
        
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 4 }},
            
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
    
    -- when there is nothing else to do assist LAND factories
    Builder {BuilderName = 'Assist Factory LAND',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 740,
		
		InstanceCount = 8,
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'LandStrengthRatioLessThan', { 3 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 4 }},
            
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
    
    -- when there is nothing else to do assist SEA factories
    Builder {BuilderName = 'Assist Factory SEA',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 740,
		
		InstanceCount = 8,
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 3 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 4 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE + categories.FACTORY, categories.FACTORY * categories.NAVAL }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = categories.FACTORY * categories.NAVAL,
				BeingBuiltCategories = {categories.FACTORY + categories.MOBILE},
                Time = 90,
            },
        },
    },
        
    -- when there is nothing else to do assist factories
    Builder {BuilderName = 'Assist Factory',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 745,
		
		InstanceCount = 5,
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 4 }},
            
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 6,
		
        Priority = 720,
		
        BuilderType = { 'T1' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},		

            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.STRUCTURE + categories.EXPERIMENTAL, categories.ENGINEER + categories.FACTORY, 90 }},
        },
		
        BuilderData = {
            Assist = {
                AssistEnergy = 2500,
                AssistMass = 250,
                
				AssistRange = 90,
				AssisteeType = 'Any',
				AssisteeCategory = categories.ENGINEER + categories.FACTORY,
                BeingBuiltCategories = {categories.ALLUNITS},
                Time = 60,
            },
        },
    },

    -- when there is nothing else to do - general assist for T2/T3
    Builder {BuilderName = 'Eng Assist Structure/Exp',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 650,
		
        InstanceCount = 8,
		
		BuilderType = { 'T2','T3' },

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL - categories.ENERGYPRODUCTION, categories.ENGINEER, 125 }},
        },
		
        BuilderData = {
            Assist = {
                AssistEnergy = 2500,
                AssistMass = 250,
                
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimStructureAI',
		
        Priority = 730,
        
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2','T3','Commander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, (categories.TECH1 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD) + (categories.TECH1 * categories.WALL), 5, false }},
        },
		
        BuilderData = {
			Reclaim = { (categories.TECH1 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD) + (categories.TECH1 * categories.WALL)},
            ReclaimRange = 65,
        },
    },
	
    -- start reclaiming T2 PD defenses when T3 defenses are already built
	Builder {BuilderName = 'Reclaim T2 Defenses',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimStructureAI',
		
        Priority = 730,
        
        InstanceCount = 2,
		
        BuilderType = { 'T3','Commander' },
		
        BuilderConditions = {
			{ LUTL, 'UnitCapCheckGreater', { .25 } },
            
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.3 } },
            
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE - categories.ARTILLERY - categories.SORTSTRATEGIC, 5, false }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, 15, 42 }},
        },
		
        BuilderData = {
			Reclaim = {categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE - categories.ARTILLERY - categories.SORTSTRATEGIC},
            ReclaimRange = 75,
        },
    },
    
	Builder {BuilderName = 'Reclaim Power',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimStructureAI',
		
        Priority = 710,
		
        BuilderType = { 'Commander','T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.DRAGBUILD - categories.TECH3 - categories.EXPERIMENTAL - categories.HYDROCARBON, 5, false }},
        },
		
        BuilderData = {
			Reclaim = {categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH3 - categories.EXPERIMENTAL - categories.HYDROCARBON},
            ReclaimRange = 75,
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
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            
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
		
        Priority = 840,
		
        InstanceCount = 1,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
        
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
            
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
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimStructureAI',
		
        Priority = 730,
		
        BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
			{ LUTL, 'UnitCapCheckGreater', { .85 } },
            
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE, 5, false }},
        },
		
        BuilderData = {
			Reclaim = {categories.TECH2 * categories.STRUCTURE * categories.DEFENSE * categories.DRAGBUILD - categories.WALL - categories.SHIELD - categories.ANTIMISSILE},
            ReclaimRange = 50,
        },
    },

    -- if low on mass
    -- make reclaim very important
    Builder {BuilderName = 'Reclaim Mass Active DP',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 700, 
		
        InstanceCount = 2,
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderConditions = {
			--{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},			
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
        },
		
        BuilderData = {
			ReclaimTime = 75,
			ReclaimType = 'Mass',
            ReclaimRange = 90,
        },
    },	
	
    -- or build any locally available extractor
    Builder {BuilderName = 'Mass Extractor 200 Active DP',
	 
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 700,
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { EBC, 'CanBuildOnMassAtRange', { 'LocationType', 0, 200, -9999, 35, 0, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
            Construction = {
				BuildClose = true,	#-- engineer will build on closest mass points to itself
				LoopBuild = false,	#-- dont repeat this build - just build once then RTB
				ThreatMin = -9999,
				ThreatMax = 35,
				ThreatRings = 0,
				ThreatType = 'AntiSurface',
                BuildStructures = {'T2Resource'},
            },
        },
    },	

    -- otherwise
    -- fix things
    Builder {BuilderName = 'Repair Active DP',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
        
        PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 650,

		BuilderType = { 'T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 1000 }},

            { UCBC, 'DamagedStructuresInArea', { 'LocationType' }},
        },
		
        BuilderData = { },
    },

    -- assist other engineers at this DP
    Builder {BuilderName = 'Assist Active DP',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'} },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 2,
		
        Priority = 650,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', categories.STRUCTURE + categories.EXPERIMENTAL, categories.ENGINEER, 125 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

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
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.025 }},
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
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'},{ BHVR, 'EngineerTransferAI'}, },
		
        Priority = 600,
		
		BuilderType = { 'SubCommander' },		
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
            
			-- check that all the major components are in place
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.ANTIMISSILE * categories.SILO * categories.TECH3, 1, 24 }},
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ANTIAIR, 1, 24 }},			
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.DIRECTFIRE, 1, 24 }},
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.SHIELD - categories.ANTIARTILLERY, 1, 24 }},
        },
		
        BuilderData = {
			TransferCategory = categories.SUBCOMMANDER,
			TransferType = 'SCU',
        }
    },
	
}
