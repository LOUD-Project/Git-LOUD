--   /lua/AI/AIBuilders/Loud_Expansion_Builders.lua
---  Summary: All tasks for building additional bases

local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

local MapHasNavalAreas = function( self, aiBrain )

	if table.getn(ScenarioInfo.Env.Scenario.MasterChain['Naval Area']) > 0 then
		return self.Priority, true
	end

	return 0, false

end


BuilderGroup {BuilderGroupName = 'Land Expansion Builders',

    BuildersType = 'EngineerBuilder',
    
    -- Builds land expansion bases at both Start and Expansion points
	-- but only when THIS location has at least 7 upgraded factories
	-- and ALL other (counted) expansion bases have at least 4 upgraded factories
    Builder {BuilderName = 'Land Expansion Base',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			-- is there an expansion already underway (we use the Instant Version here for accuracy)
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
			-- this base must have 7+ T2/T3 factories
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, categories.FACTORY * categories.STRUCTURE - categories.TECH1}},
			-- must have enough mass input to sustain existing factories and surplus
			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.03, 1.03 } },
			-- all other 'counted' bases must have at least 4 T2/T3 factories
			{ UCBC, 'ExistingBasesHaveGreaterThanFactory', { 3, categories.FACTORY * categories.STRUCTURE - categories.TECH1 }},
			-- there must be an start/expansion area with no engineers
            { UCBC, 'BaseAreaForExpansion', { 'LocationType', 8000, -9999, 40, 0, 'AntiSurface' } },
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				-- a counted base is included when using ExistingBases functions - otherwise ignored
				-- this is what allows active DPs to not count against maximum allowed bases
				CountedBase = true,
				-- this tells the code to start an active base at this location
                ExpansionBase = true,
				-- this controls the radius at which this base will draw 'pool' units
				-- and it forms the basis for the Base Alert radius as well
                ExpansionRadius = 110,
				-- this controls the radius for creation of auto-rally points 
				RallyPointRadius = 44,
				-- and of course -- the type of markers we're looking for
                NearMarkerType = 'Large Expansion Area',
				-- the limit of how far away to include markers when looking for a position
                LocationRadius = 8000,
				-- this controls which base layout file to use
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				-- these parameters control point selection
                ThreatMin = -9999,
                ThreatMax = 40,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				-- what we'll build
                BuildStructures = {  
					'T1LandFactory',
					'T2AirStagingPlatform',
					'T2Radar',
					'T2GroundDefense',
                }               
            },
        }
    }, 

}

BuilderGroup {BuilderGroupName = 'DP Builders Standard',

    BuildersType = 'EngineerBuilder',

	-- This builder will start an active DP 
	Builder {BuilderName = 'Defensive Point Expansion',
	
		PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		Priority = 710,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 2100 }},
			

			{ UCBC, 'IsBaseExpansionUnderway', {false} },
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
			
            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 2000, -999999, 30, 0, 'AntiSurface' }},
			
        },
		
		BuilderType = { 'T2','T3' },
		
		BuilderData = {
		
			Construction = {
			
				CountedBase = false,
				
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 23,
				NearMarkerType = 'Defensive Point',
				
				LocationRadius = 2000,
				
                ThreatMin = -999999,
                ThreatMax = 35,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointStandard',
				
                BuildStructures = {
					'T2Radar',
					'T2AirStagingPlatform',
				}
			}
		}
	},

	-- Like above, we want to create an Active DP, but on Start and Expansion areas
	-- this allows the AI to setup forward positions long before he has the resources to start a full base
	-- Later on he can convert these 'Active DP' into real bases at his discretion
    Builder {BuilderName = 'DP - Start & Expansion Areas',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},
			
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
		
			{ UCBC, 'BaseAreaForDP', { 'LocationType', 2000, -999999, 35, 0, 'AntiSurface' } },
			
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
		
            Construction = {
			
				CountedBase = false,
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 44,

                LocationRadius = 2000,
                NearMarkerType = 'Expansion Area',

                ThreatMin = -999999,
                ThreatMax = 35,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {
					'T2Radar',
					'T2AirStagingPlatform',
                }
				
            }
			
        }
		
    },    
}

BuilderGroup {BuilderGroupName = 'DP Builders Small',

    BuildersType = 'EngineerBuilder',

	-- This builder will start an active DP 
	Builder {BuilderName = 'Defensive Point Expansion Small',
	
		PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		Priority = 710,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 4200 }},

			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},

            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 2000, -999999, 30, 0, 'AntiSurface' }},
			
        },
		
		BuilderType = { 'T2','T3' },
		
		BuilderData = {
		
			Construction = {
			
				CountedBase = false,
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 23,
				
				NearMarkerType = 'Defensive Point',
				
				LocationRadius = 2000,
				
                ThreatMin = -999999,
                ThreatMax = 30,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {
					'T2Radar',
					'T2AirStagingPlatform',
				}
			}
		}
	},
}


BuilderGroup {BuilderGroupName = 'Naval Base Builders',

    BuildersType = 'EngineerBuilder',

	-- start the primary naval base only when you have 4 or more factories at this base
	-- only the MAIN base will do this -- Additional naval bases are only initiated by
	-- other expansion bases 
	-- NOTE the threat restrictions on this builder - it's designed so that an AI will
	-- not go into the water if an enemy is close or if there are no safe areas
	-- I made use of the 'rings' variable here -- on a 20km map 2 rings is about 2.5km
	-- I also shortened the search range to about 17km from 20km
    Builder {BuilderName = 'Naval Base Initial',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 999,
		
		PriorityFunction = MapHasNavalAreas,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
			{ UCBC, 'NavalBaseCount', { 1, '<' } },
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
			
			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.01, 1.03 } },
			
			-- must have 3+ factories at MAIN
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE}},
			
			-- can't be a major enemy base with 10km of here
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 500, 'Economy', 300 }},
			
			-- find a safe, unused, naval marker within 850 units of this base
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 850, -250, 25, 2, 'AntiSurface' } },
			
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
		
            Construction = {
			
				CountedBase = true,
                ExpansionBase = true,
                ExpansionRadius = 110,
				RallyPointRadius = 48,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 850,
				
                ThreatMin = -250,
                ThreatMax = 25,
                ThreatRings = 2,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {
					'T1SeaFactory',
					'T2AirStagingPlatform',
					'T1SeaFactory',
					'T2Sonar',

                }
				
            }
			
        }
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Naval Base Builders - Expansion',
    BuildersType = 'EngineerBuilder',
	
	-- start additional naval bases if naval strength too low
	-- must already have a naval base -- must have 4+ Naval factories
	-- only Naval Bases will do this
    Builder {BuilderName = 'Naval Base Secondary from EXPANSION',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,
		
		PriorityFunction = MapHasNavalAreas,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
			{ LUTL, 'NavalStrengthRatioLessThan', { 5 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			
			{ UCBC, 'NavalBaseCount', { 0, '>' } },
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
			
			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.03, 1.03 } },
			
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE * categories.TECH3 }},
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 1250, -250, 25, 2, 'AntiSurface' } },
			
			-- all other 'counted' bases must have at least 4 T2/T3 factories
			{ UCBC, 'ExistingBasesHaveGreaterThanFactory', { 3, categories.FACTORY * categories.STRUCTURE - categories.TECH1 }},
			
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
		
            Construction = {
			
				CountedBase = true,
                ExpansionBase = true,
                ExpansionRadius = 110,
				RallyPointRadius = 48,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 1250,

                ThreatMin = -250,
                ThreatMax = 25,
                ThreatRings = 2,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {
					'T1SeaFactory',
					'T2AirStagingPlatform',
                }
				
            }
			
        }
		
    },
	
}

-- builds sonar outposts at the moment 
BuilderGroup {BuilderGroupName = 'Naval Defensive Points',
	BuildersType = 'EngineerBuilder',

	-- build a naval position that is closer to the goal than the current primary position
    Builder {BuilderName = 'Naval DP',
	
        PlatoonTemplate = 'EngineerBuilderGeneral',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		-- unique for an engineer platoon
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 745,
		
        InstanceCount = 1,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},
			
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},
			
			{ UCBC, 'NavalDefensivePointNeedsStructure', { 'LocationType', 1500, 'OVERLAY SONAR INTELLIGENCE', 120, 0, -999999, 30, 1, 'AntiSurface' }},
			
        },
		
        BuilderType = { 'T2','T3', },
		
        BuilderData = {
		
            Construction = {
			
				CountedBase = false,
				ExpansionBase = true,
                ExpansionRadius = 110,
				RallyPointRadius = 25,

                NearMarkerType = 'Naval Defensive Point',
				
                LocationRadius = 1500,
				
                MarkerUnitCategory = 'OVERLAYSONAR SONAR INTELLIGENCE',
                MarkerRadius = 120,
                MarkerUnitCount = 0,
				
                ThreatMin = -999999,
                ThreatMax = 30,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {
				
					'T2Sonar',
					'T2AirStagingPlatform',

					'T2MissileDefense',

					'T2AADefenseAmphibious',
					'T2AADefenseAmphibious',

					'T2NavalDefense',
					'T2NavalDefense',

					'T2GroundDefenseAmphibious',
					'T2GroundDefenseAmphibious',
					
                }
				
            }
			
        }
		
    },
	
}
