--  /lua/ai/Loud_AI_Engineer_Task_Builders.lua
--- tasks for all engineers - reclaim, repair, assist

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'

local LUTL  = '/lua/loudutilities.lua'
local BHVR  = '/lua/ai/aibehaviors.lua'

local AIR           = categories.AIR
local ANTIMISSILE   = categories.ANTIMISSILE
local LAND          = categories.LAND
local NAVAL         = categories.NAVAL
local DEFENSE       = categories.DEFENSE
local ENGINEER      = categories.ENGINEER
local EXPERIMENTAL  = categories.EXPERIMENTAL
local FACTORY       = categories.FACTORY
local MOBILE        = categories.MOBILE
local SACU          = categories.SUBCOMMANDER
local STRUCTURE     = categories.STRUCTURE

local AIRPADS       = categories.AIRSTAGINGPLATFORM - MOBILE
local AIRFAC        = AIR * FACTORY
local ARTY          = STRUCTURE * categories.ARTILLERY
local LANDFAC       = LAND * FACTORY
local NAVALFAC      = NAVAL * FACTORY
local SHIELD        = STRUCTURE * categories.SHIELD

local TECH1         = categories.TECH1 
local TECH2         = categories.TECH2
local TECH3         = categories.TECH3

local DRAG          = categories.DRAGBUILD
local ENERGYPROD    = categories.ENERGYPRODUCTION
local ENERGYSTOR    = categories.ENERGYSTORAGE
local HYDRO         = categories.HYDROCARBON
local MASSPROD      = categories.MASSPRODUCTION
local WALL          = categories.WALL



-- These are the basic tasks that cover non-specifc things 
-- like reclaim, assist and repair
BuilderGroup {BuilderGroupName = 'Engineer Tasks', BuildersType = 'EngineerBuilder',
    
	-- a limited number of high priority shield repairing jobs
    Builder {BuilderName = 'Repair Shield',
	
        PlatoonTemplate = 'EngineerGeneral',
        
        PlatoonAIPlan = 'EngineerAssistShield',
		
        Priority = 750,
        
		InstanceCount = 3,
		
		BuilderType = { 'Commander','T2','T3','SubCommander' },

        BuilderConditions = {
			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, SHIELD - TECH2 }},
            { UCBC, 'ShieldDamaged', { 'LocationType' }},
        },
		
        BuilderData = {
            Assist = {
                BeingBuiltCategories = { SHIELD - TECH2 },
                Time = 25,
            },
        },
    },


    -- These next 4 builders spread SACU assisting out amongst several job types
    -- While these all could have been housed as a single builder - I did this
    -- to insure that the SACU get spread around to multiple jobs
    
    Builder {BuilderName = 'SCU Assist Engineer',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
        InstanceCount = 3,
		
        BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},

            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', STRUCTURE + EXPERIMENTAL - ENERGYPROD, ENGINEER, 125 }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
                AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER,
                BeingBuiltCategories = { (STRUCTURE + EXPERIMENTAL - ENERGYPROD) },
                Time = 120,
            },
        }
    },

    Builder {BuilderName = 'SCU Assist Factory',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 750,
		
		InstanceCount = 3,
		
		BuilderType = { 'SubCommander' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, MOBILE + FACTORY}},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = FACTORY,
				BeingBuiltCategories = {FACTORY + MOBILE},
                Time = 75,
            },
        },
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
            { LUTL, 'LandStrengthRatioLessThan', { 5.1 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 5000 }},
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', LAND * EXPERIMENTAL - ENERGYPROD, ENGINEER, 125 }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER,
                BeingBuiltCategories = { (LAND * EXPERIMENTAL - ENERGYPROD) },
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
            
            { LUTL, 'AirStrengthRatioLessThan', { 2 } },
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', AIR * EXPERIMENTAL - ENERGYPROD, ENGINEER, 125 }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER,
                BeingBuiltCategories = { (AIR * EXPERIMENTAL - ENERGYPROD) },
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

            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', ARTY, ENGINEER, 125 }},

        },
		
        BuilderData = {
            Assist = {
				AssistRange = 125,
                AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER,
                BeingBuiltCategories = { ARTY },
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
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
        },
		
        BuilderData = {
			ReclaimTime = 90,
			ReclaimType = 'Mass',
            ReclaimRange = 75,
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

			{ EBC, 'LessThanEconEnergyStorageRatio', { 75 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 500 }},
            
			{ UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, ENERGYPROD + ENERGYSTOR - EXPERIMENTAL, ENGINEER + ENERGYSTOR + ENERGYPROD, 105 }},
        },
		
        BuilderData = {
            Assist = {
                -- this allows the builder to continue assist until M drops below this
                AssistMass = 150,
                -- this allows the builder to continue assist until E drops below this
                AssistEnergy = 100,
            
				AssistRange = 105,
                AssisteeType = 'Any',
				AssisteeCategory = ENGINEER + ENERGYSTOR + ENERGYPROD,
                BeingBuiltCategories = {ENERGYPROD + ENERGYSTOR - EXPERIMENTAL},
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
		
		InstanceCount = 4,
		
        BuilderConditions = {
            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, MASSPROD - TECH1, ENGINEER + MASSPROD, 120 }},
            
			{ EBC, 'LessThanEconMassStorageRatio', { 60 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 150, 2500 }},            
        },
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
            Assist = {
            
                -- this allows the builder to continue assist until E drops below this
                AssistEnergy = 500,
                -- this allows the builder to continue assist until M drops below this
                AssistMass = 35,
            
				AssistRange = 120,
                AssisteeType = 'Any',
				AssisteeCategory = ENGINEER + MASSPROD,
                BeingBuiltCategories = {MASSPROD - TECH1},
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
            
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
        },
		
        BuilderData = {
			ReclaimTime = 75,
			ReclaimType = 'Mass',
            ReclaimRange = 75,
        },
    },    

    -- Assist ACU and SACU Enhancements
    Builder {BuilderName = 'Assist ACU SACU',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 740,
		
		InstanceCount = 4,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', ENGINEER, ENGINEER, 100 }},

        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER,
				BeingBuiltCategories = {ENGINEER},
                Time = 90,
            },
        },
    },

    -- repair structures
    Builder {BuilderName = 'Repair',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 740,
		
        InstanceCount = 3,

		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},		
            
            { UCBC, 'DamagedStructuresInArea', { 'LocationType' }},
        },
		
        BuilderData = { },
    },

    -- unfinished structures
    Builder {BuilderName = 'Unfinished',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerRepairAI',
		
        Priority = 740,
		
        InstanceCount = 2,

		BuilderType = { 'T1','T2','T3','SubCommander' },
		
        BuilderConditions = {
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},		
            
            { UCBC, 'UnfinishedUnits', { 'LocationType', STRUCTURE }},
        },
		
        BuilderData = { },
    },

    -- when there is nothing else to do assist AIR factories
    Builder {BuilderName = 'Assist Factory AIR',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 740,
		
		InstanceCount = 5,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
        
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, MOBILE + FACTORY, AIRFAC }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = AIRFAC,
				BeingBuiltCategories = {FACTORY + MOBILE},
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
		
		InstanceCount = 5,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'LandStrengthRatioLessThan', { 5.1 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, MOBILE + FACTORY, LANDFAC }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = LANDFAC,
				BeingBuiltCategories = {FACTORY + MOBILE},
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
		
		InstanceCount = 5,
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 5.1 } },
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},
            
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, MOBILE + FACTORY, NAVALFAC }},
        },
		
        BuilderData = {
            Assist = {
				AssistRange = 120,
				AssisteeType = 'Factory',
				AssisteeCategory = NAVALFAC,
				BeingBuiltCategories = {FACTORY + MOBILE},
                Time = 90,
            },
        },
    },
    
    -- when there is nothing else to do - specific assist for T2/T3/SACU
    Builder {BuilderName = 'Gen Assist Eng/Fac',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
        Priority = 725,
		
        InstanceCount = 5,
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},

            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', STRUCTURE + EXPERIMENTAL - ENERGYPROD, ENGINEER + FACTORY, 120 }},
        },
		
        BuilderData = {
            Assist = {
                AssistEnergy = 2400,
                AssistMass = 240,
                
				AssistRange = 120,
				AssisteeType = 'Any',
				AssisteeCategory = ENGINEER + FACTORY,
                BeingBuiltCategories = { (STRUCTURE + EXPERIMENTAL - ENERGYPROD) },
                Time = 75,
            },
        },
    },

    -- when there is nothing else to do - general assist
    Builder {BuilderName = 'Gen Assist',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 5,
		
        Priority = 720,
		
        BuilderType = { 'T1','T2','T3' },
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},		

            { UCBC, 'BuildingGreaterAtLocationAtRange', { 'LocationType', 0, categories.ALLUNITS - EXPERIMENTAL - ENERGYPROD - MASSPROD, ENGINEER + FACTORY, 90 }},
        },
		
        BuilderData = {
            Assist = {
                AssistEnergy = 2000,
                AssistMass = 200,
                
				AssistRange = 90,
				AssisteeType = 'Any',
				AssisteeCategory = ENGINEER + FACTORY,
                BeingBuiltCategories = {categories.ALLUNITS - EXPERIMENTAL - ENERGYPROD - MASSPROD},
                Time = 60,
            },
        },
    },

}

BuilderGroup {BuilderGroupName = 'Engineer Tasks - Reclaim Old Structures', BuildersType = 'EngineerBuilder',
	
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
            
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, (TECH1 * STRUCTURE * DEFENSE * DRAG) + (TECH1 * WALL), 5, false }},
        },
		
        BuilderData = {
			Reclaim = { (TECH1 * STRUCTURE * DEFENSE * DRAG) + (TECH1 * WALL)},
            ReclaimRange = 65,
        },
    },
	
	Builder {BuilderName = 'Reclaim T1 Airpad',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimStructureAI',
		
        Priority = 735,
        
        InstanceCount = 1,
		
        BuilderType = { 'T1','T2','T3' },
		
        BuilderConditions = {
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, (TECH2 * AIRPADS), 5, false }},
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, (TECH1 * AIRPADS), 5, false }},
        },
		
        BuilderData = {
			Reclaim = { (TECH1 * AIRPADS)},
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

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.5 } },
            
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, TECH2 * STRUCTURE * DEFENSE * DRAG - WALL - SHIELD - ARTY - categories.SORTSTRATEGIC, 5, false }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 8, STRUCTURE * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * TECH3, 15, 42 }},
        },
		
        BuilderData = {
			Reclaim = {TECH2 * STRUCTURE * DEFENSE * DRAG - WALL - SHIELD - ARTY - categories.SORTSTRATEGIC},
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
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, STRUCTURE * ENERGYPROD * DRAG - TECH3 - EXPERIMENTAL - HYDRO, 5, false }},
        },
		
        BuilderData = {
			Reclaim = {STRUCTURE * ENERGYPROD - TECH3 - EXPERIMENTAL - HYDRO},
            ReclaimRange = 75,
        },
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Transfers', BuildersType = 'EngineerBuilder',

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
			TransferCategory = MOBILE * ENGINEER * TECH2,
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
			TransferCategory = MOBILE * ENGINEER * TECH3 - SACU,
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
			TransferCategory = SACU,
			TransferType = 'SCU',
        },
    },
}

-- These are the basic tasks for an engineer at a Defensive Point
-- but includes all general tasks as well as transfers & local MEX building
BuilderGroup {BuilderGroupName = 'Engineer Tasks - Active DP', BuildersType = 'EngineerBuilder',

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

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, TECH2 * STRUCTURE * DEFENSE * DRAG - WALL - SHIELD - ANTIMISSILE, 5, false }},
        },
		
        BuilderData = {
			Reclaim = {TECH2 * STRUCTURE * DEFENSE * DRAG - WALL - SHIELD - ANTIMISSILE},
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
		
		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'LessThanEconMassStorageRatio', { 50 }},			
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
        },
		
        BuilderData = {
			ReclaimTime = 45,
			ReclaimType = 'Mass',
            ReclaimRange = 75,
        },
    },	
    -- when energy is low
    Builder {BuilderName = 'Reclaim Energy Active DP',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerReclaimAI',
		
        Priority = 700,
		
        InstanceCount = 2,
		
        BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
			{ EBC, 'LessThanEconEnergyStorageRatio', { 75 }},
			{ MIBC, 'ReclaimablesInAreaEnergy', { 'LocationType', 75 }},
        },
		
        BuilderData = {
			ReclaimTime = 45,
			ReclaimType = 'Energy',
            ReclaimRange = 75,
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

		BuilderType = { 'T1','T2','T3','SubCommander' },

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
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 5000 }},
            
            { UCBC, 'LocationEngineerNeedsBuildingAssistanceInRange', { 'LocationType', STRUCTURE + EXPERIMENTAL, ENGINEER, 125 }},
        },
		
		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderData = {
            Assist = {
				AssistRange = 125,
				AssisteeType = 'Engineer',
				AssisteeCategory = ENGINEER - TECH1,
                BeingBuiltCategories = {EXPERIMENTAL, STRUCTURE},
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
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},			
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.01 }},
        },
		
        BuilderData = {
			TransferCategory = MOBILE * ENGINEER * TECH2,
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
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
			-- we do an eco check just to make sure we're not transferring just because we're in a eco lock
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.01 }},
        },
		
        BuilderData = {
			TransferCategory = MOBILE * ENGINEER * TECH3 - SACU,
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
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, ANTIMISSILE * categories.SILO * TECH3, 1, 24 }},
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, STRUCTURE * EXPERIMENTAL * categories.ANTIAIR, 1, 24 }},			
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, STRUCTURE * DEFENSE * TECH3 * categories.DIRECTFIRE, 1, 24 }},
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 1, SHIELD - categories.ANTIARTILLERY, 1, 24 }},
        },
		
        BuilderData = {
			TransferCategory = SACU,
			TransferType = 'SCU',
        }
    },
	
}
