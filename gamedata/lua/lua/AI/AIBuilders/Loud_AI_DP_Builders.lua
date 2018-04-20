-- /lua/ai/Loud_AI_DefensivePoint_Builders.lua
-- Constructs Base Defenses, Defensive Points & Extractor Defenses

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local BHVR = '/lua/ai/aibehaviors.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
	
		return self.Priority, false
		
	end

	return 10, false
end

BuilderGroup {BuilderGroupName = 'Engineer Builders Active DP',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Reclaim Mass DP',
	
        PlatoonTemplate = 'EngineerReclaimerGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 600, 
		
        InstanceCount = 2,
		
		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
			{ EBC, 'LessThanEconMassStorageRatio', { 90 }},			
			{ EBC, 'ReclaimablesInAreaMass', { 'LocationType', 75 }},
			
        },
		
        BuilderData = {
		
			ReclaimTime = 60,
			ReclaimType = 'Mass',
        },
		
    },	

    Builder {BuilderName = 'Repair DP',
	
        PlatoonTemplate = 'EngineerRepairGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

		BuilderType = { 'T1','T2','T3','SubCommander' },

        BuilderConditions = {
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
        },
		
        BuilderData = { },
		
    },
	
	Builder {BuilderName = 'Reclaim T2 Defenses DP',
	
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

    Builder {BuilderName = 'Assist Engineers DP',
	
        PlatoonTemplate = 'EngineerAssistGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAIPlan = 'EngineerAssistAI',
		
		InstanceCount = 2,
		
        Priority = 650,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 200, 2500 }},
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
			
        }
		
    },
	
    Builder {BuilderName = 'Mass Extractor DP',
	 
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 650,
		
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
                BuildStructures = {'T2Resource'}
				
            }
			
        }
		
    },
	
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
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			
        },
		
        BuilderData = {
		
			TransferCategory = categories.MOBILE * categories.ENGINEER * categories.TECH2,
			TransferType = 'Tech2',
			
        }
		
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
			
        }	
		
	},
	
	-- put this in here with low priority and eco check
	-- this way DP can get rid of SCU when he's done
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

BuilderGroup {BuilderGroupName = 'Active DP Mass Storage',
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

BuilderGroup {BuilderGroupName = 'DP Defenses STD',
	BuildersType = 'EngineerBuilder',

	-- this will rebuild the base radar of the DP
    Builder {BuilderName = 'DP STD Radar',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

        BuilderConditions = {
		
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 			
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
                BuildStructures = {	'T2Radar' }
				
            }
			
        }
		
    },
	
	-- this task builds the basic defenses of the DP
    Builder {BuilderName = 'T2 DP STD Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        Priority = 650,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
		
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 			
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * categories.DIRECTFIRE, 0, 24 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
				
                BuildStructures = {
					'T2GroundDefense',
					'T2GroundDefense',
					'T2AADefense',
					'T2AADefense',
					'T2GroundDefense',
					'T2GroundDefense',
					'T2GroundDefense',
					'T2GroundDefense',
					'T2AADefense',
					'T2AADefense',
					'T2GroundDefense',
					'T2GroundDefense',
                }
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T2 DP STD Auxiliary Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM - categories.MOBILE, 0, 28 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
                BuildStructures = {
					'T2RadarJammer',
					'T2AirStagingPlatform',
					'T2MissileDefense',
					'T2MissileDefense',
					'T2EnergyProduction',
					'T1MassCreation',
					'T1MassCreation',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
					'Wall',
                }
				
            }
			
        }
		
    },	

    Builder {BuilderName = 'T3 DP STD Shields',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 35, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.SHIELD, 0, 24 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
                BuildStructures = {
					'T3ShieldDefense',
					'T3ShieldDefense',
                    'T1MassCreation',
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 DP STD AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 35, 'Air' }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 0, 24 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
                BuildStructures = {
					'T3AADefense',
                    'T3AADefense',
					'T3AADefense',
                    'T3AADefense',
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 DP STD Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 35, 'Land' }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.DIRECTFIRE, 0, 24 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
                BuildStructures = {
                    'T3GroundDefense',
					'T3GroundDefense',
                    'T1MassCreation',
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T4 DP STD AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
		
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 35, 'Air' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.STRUCTURE * categories.SHIELD, 0, 24 }},
			
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.ANTIAIR * categories.EXPERIMENTAL, 0, 24 }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
				
                BuildStructures = {'T4AADefense'}
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T4 DP STD Antinuke Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.STRUCTURE * categories.SHIELD, 0, 24 }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
				
                BuildStructures = {'T3StrategicMissileDefense'}
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'DP Defenses SML',
	BuildersType = 'EngineerBuilder',

	-- this will rebuild the base radar of the DP
    Builder {BuilderName = 'DP SML Radar',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

        BuilderConditions = {
		
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {	'T2Radar' }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T2 DP SML Auxiliary Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM - categories.MOBILE, 0, 28 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {
					'T2RadarJammer',
					'T2AirStagingPlatform',
					'T2MissileDefense',
                }
				
            }
			
        }
		
    },	

    Builder {BuilderName = 'T2 DP SML Shields',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.SHIELD, 0, 24 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {	'T2ShieldDefense' }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 DP SML AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Air' }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 0, 24 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {
					'T3AADefense',
                    'T3AADefense',
					'T3AADefense',
                    'T3AADefense',
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T3 DP SML Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 30, 'Land' }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.DIRECTFIRE, 0, 24 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {
                    'T3GroundDefense',
					'T3GroundDefense',
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'T4 DP SML AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
		
			{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 35, 'Air' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.STRUCTURE * categories.SHIELD, 0, 24 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.ANTIAIR * categories.EXPERIMENTAL, 0, 24 }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {'T4AADefense'}
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'T4 DP SML Antinuke Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
		    { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3 }},			

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, categories.STRUCTURE * categories.SHIELD, 0, 24 }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                BuildStructures = {'T3StrategicMissileDefense'}
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Naval DP Defenses',
	BuildersType = 'EngineerBuilder',

	-- this will rebuild the base radar of the DP
    Builder {BuilderName = 'Naval DP Sonar',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

        BuilderConditions = {
		
			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYSONAR * categories.INTELLIGENCE }},
			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.MOBILESONAR * categories.INTELLIGENCE * categories.TECH3 }},
			
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {	'T2Sonar' }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'Naval DP Airstaging',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM - categories.MOBILE, 0, 28 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {
				
					'T2AirStagingPlatform',
					'T2MissileDefense',
				
				}
				
            }
			
        }
		
    },	

    Builder {BuilderName = 'Naval DP T2 AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.ANTIAIR * categories.TECH2, 0, 24 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {
				
					'T2AADefenseAmphibious',
					
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'Naval DP T2 Surface Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE, 0, 24 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {
				
                    'T2GroundDefenseAmphibious',
					
                }
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Naval DP T2 Naval Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.ANTINAVY * categories.TECH2, 0, 24 }},
			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {
				
                    'T2NavalDefense',
					
                }
				
            }
			
        }
		
    },

    Builder {BuilderName = 'Naval DP T3 AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 650,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.ANTIAIR * categories.TECH3, 0, 24 }},
			
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {
				
					'T3AADefense',
					
                }
				
            }
			
        }
		
    },
	
    Builder {BuilderName = 'Naval DP Antinuke',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 900,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 50000 }},
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.02 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.ANTIMISSILE * categories.SILO * categories.STRUCTURE * categories.TECH3, 0, 15 }},
			
        },
		
		BuilderType = { 'SubCommander' },
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
			
                NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T3StrategicMissileDefense'},
				
            }
			
        }
		
    },	
	
}