--   /lua/AI/AIBuilders/Loud_AI_Engineer_Expansion_Builders.lua
---  Summary: All tasks for building additional bases

local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local TBC   = '/lua/editor/ThreatBuildConditions.lua'
local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal

local AboveUnitCap65 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap80 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local OutNumbered_First15Minutes_Land = function( self,aiBrain )
	
	if aiBrain.OutnumberedRatio <= 1 or aiBrain.CycleTime > 900 then
    
        -- permanent removal of builder
		return 0, false
	end
	
	return self.Priority, true
end

local OutNumbered_First15Minutes_Naval = function( self,aiBrain )
	
	if aiBrain.OutnumberedRatio <= 1 or aiBrain.CycleTime > 900 then

        -- permanent removal of builder    
		return 0, false
	end
    
    -- ignore for first 10 seconds of game
    if aiBrain.CycleTime < 100 then
        return 10, true
    end
    
    -- 20km maps or less - reduce priority according to
    -- the amount of water on the map between 0 and 1 (where .5 = 50% is the ideal value)
    if ScenarioInfo.IMAPSize <= 64 then
    
        if ScenarioInfo.MapWaterRatio < .70 then
        
            -- as we approach 50% water, the reduction decreases - but the impact is increased by how outnumbered we are
            -- so even if the water ratio is excellent - the desire to respond decreases with the growth in how outnumbered
            local adjust = (100 - (( ScenarioInfo.MapWaterRatio * 2 ) * 100) * math.sqrt(aiBrain.OutnumberedRatio))
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." map water ratio is "..repr(ScenarioInfo.MapWaterRatio).." reducing priority to "..self.Priority-adjust )
            
            return self.Priority-adjust, true
            
        end
        
    end
	
	return self.Priority, true
end

local First15Minutes_Naval = function( self,aiBrain )
	
	if aiBrain.CycleTime > 900 then
    
        -- permanent removal of builder    
		return 0, false
	end
    
    if aiBrain.CycleTime < 100 then
        return 10, true
    end
    
    -- if no detected naval activity
    if aiBrain.NavalRatio < .02 then
        return 10, true
    end
	
	return self.OldPriority or self.Priority, true
end

local MapHasNavalAreas = function( self, aiBrain )

    if ScenarioInfo['Naval Area'][1] then
        return self.Priority, false
    end
    
	return 0, false

end

local MapHasNavalAreasButNotEstablished = function( self, aiBrain )

    if aiBrain.NumBasesNaval < 1 then
    
        -- this just checks if there are any Naval Area markers on the map
        if ScenarioInfo['Naval Area'][1] then
            return 999, false
        else
            return 10, true
        end
        
    end
    
	return 10, true
end

BuilderGroup {BuilderGroupName = 'Engineer Land Expansion Construction',

    BuildersType = 'EngineerBuilder',
    
    -- Builds land expansion bases at both Start and Expansion points
	-- but only when THIS location has at least 4 upgraded factories
	-- and ALL other (counted) expansion bases have at least 4 upgraded factories
    Builder {BuilderName = 'Land Expansion Base',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = AboveUnitCap65,
		
        BuilderConditions = {
			-- is there an expansion already underway (we use the Instant Version here for accuracy)
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
			-- this base must have 3+ T2/T3 factories
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE - categories.TECH1}},
            
			-- all other 'counted' land bases must have at least 3 T3 factories
			{ UCBC, 'ExistingBasesHaveGreaterThanFactory', { 3, 'Land', categories.FACTORY * categories.STRUCTURE * categories.TECH3 }},
            
			-- must have enough mass input to sustain existing factories and surplus
			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.05, 1.05 } },

			-- there must be a vacant start/expansion area with no allied structures within ExpansionRadius range (115)
            { UCBC, 'BaseAreaForExpansion', { 'LocationType', 2000, 115, -9999, 60, 0, 'AntiSurface' } },
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				-- a counted base is included when using ExistingBases functions - otherwise ignored
				-- this is what allows a base to count or not count against maximum allowed bases
                -- Counted Bases are typically production centres
				CountedBase = true,
                
				-- this tells the code to start an active base at this location
                ExpansionBase = true,
                
				-- this controls the radius at which this base will draw 'pool' units
				-- and it forms the basis for the Base Alert radius as well
                -- and controls the initial check for 'allied' positions
                ExpansionRadius = 115,
                
				-- this controls the radius for creation of auto-rally points 
				RallyPointRadius = 40,
                
				-- and of course -- the type of markers we're looking for
                NearMarkerType = 'Large Expansion Area',
                
				-- the limit of how far away to include markers when looking for a position
                LocationRadius = 2000,
                
				-- this controls which base layout file to use
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
				-- these parameters control point selection
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				-- what we'll build
                BuildStructures = {'T2AirStagingPlatform','T1LandFactory','T2Radar',
					'T1GroundDefense',
					'T1GroundDefense',
					'T1GroundDefense',
					'T1GroundDefense',
					'T2GroundDefense',
					'T2GroundDefense',
                }               
            },
        }
    }, 

    Builder {BuilderName = 'Land Expansion Base - SACU',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
        
        PriorityFunction = AboveUnitCap65,
		
        BuilderConditions = {
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.FACTORY * categories.STRUCTURE - categories.TECH1}},

			{ UCBC, 'ExistingBasesHaveGreaterThanFactory', { 3, 'Land', categories.FACTORY * categories.STRUCTURE * categories.TECH3 }},

			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.05, 1.05 } },

            { UCBC, 'BaseAreaForExpansion', { 'LocationType', 2000, 115, -9999, 75, 0, 'AntiSurface' } },
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
            Construction = {
				-- a counted base is included when using ExistingBases functions - otherwise ignored
				-- this is what allows a base to count or not count against maximum allowed bases
                -- Counted Bases are typically production centres
				CountedBase = true,
                
				-- this tells the code to start an active base at this location
                ExpansionBase = true,
                
				-- this controls the radius at which this base will draw 'pool' units
				-- and it forms the basis for the Base Alert radius as well
                -- and controls the initial check for 'allied' positions
                ExpansionRadius = 115,
                
				-- this controls the radius for creation of auto-rally points 
				RallyPointRadius = 40,
                
				-- and of course -- the type of markers we're looking for
                NearMarkerType = 'Large Expansion Area',
                
				-- the limit of how far away to include markers when looking for a position
                LocationRadius = 2000,
                
				-- this controls which base layout file to use
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
				-- these parameters control point selection
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				-- what we'll build
                BuildStructures = {'T2AirStagingPlatform','T1LandFactory','T1AirFactory','T2Radar',
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T3MissileDefense',
                    'T3MissileDefense',
                    'T2AADefense',
                    'T2AADefense',
                }               
            },
        }
    }, 

   
    -- Builds land expansion bases at both Start and Expansion points
    -- when there are nearby empty start locations
    -- first 15 minutes only
    Builder {BuilderName = 'Land Expansion Base - Outnumbered',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = OutNumbered_First15Minutes_Land,
		
        BuilderConditions = {

            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 2500 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},
            
			-- is there an expansion already underway (we use the Instant Version here for accuracy)
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
			-- there must be an start/expansion area
            { UCBC, 'BaseAreaForExpansion', { 'LocationType', 700, 115, -9999, 115, 60, 0, 'AntiSurface' } },
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
            Construction = {
				-- a counted base is included when using ExistingBases functions - otherwise ignored
				-- this is what allows a base to count or not count against maximum allowed bases
                -- Counted Bases are typically production centres
				CountedBase = true,
                
				-- this tells the code to start an active base at this location
                ExpansionBase = true,
                
				-- this controls the radius at which this base will draw 'pool' units
				-- and it forms the basis for the Base Alert radius as well
                -- and controls the initial check for 'allied' positions
                ExpansionRadius = 115,
                
				-- this controls the radius for creation of auto-rally points 
				RallyPointRadius = 40,
                
				-- and of course -- the type of markers we're looking for
                NearMarkerType = 'Large Expansion Area',
                
				-- the limit of how far away to include markers when looking for a position
                LocationRadius = 700,
                
				-- this controls which base layout file to use
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
				-- these parameters control point selection
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
                BuildStructures = {'T1LandFactory','T1GroundDefense','T1GroundDefense','T1GroundDefense','T1GroundDefense'}               
            },
        }
    }, 

}

BuilderGroup {BuilderGroupName = 'Engineer Defensive Point Construction STD',

    BuildersType = 'EngineerBuilder',

	-- This builder will start an active DP with a T2/T3 engineer
	Builder {BuilderName = 'DP - Expansion',
	
		PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		Priority = 750,
        
        PriorityFunction = AboveUnitCap80,
		
        BuilderConditions = {

			{ LUTL, 'GreaterThanEnergyIncome', { 480 }},

			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.01 }},
            
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},
			
            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1600, -999999, 60, 0, 'AntiSurface' }},
        },
		
		BuilderType = { 'T2','T3' },
		
		BuilderData = {
			Construction = {
				CountedBase = false,
				
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 23,
                
				NearMarkerType = 'Defensive Point',
				
				LocationRadius = 1600,
				
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2GroundDefense','T2AADefense'}
			}
		}
	},
        
    -- this one starts with an SACU - difference between the previous builder - this one needs more factories as a condition
	Builder {BuilderName = 'DP - Expansion SACU',
	
		PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		Priority = 750,
        
        PriorityFunction = AboveUnitCap80,
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },

			{ UCBC, 'IsBaseExpansionUnderway', {false} },
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.02 }},
            
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},
			
            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1600, -999999, 60, 0, 'AntiSurface' }},
        },
		
		BuilderType = { 'SubCommander' },
		
		BuilderData = {
			Construction = {
				CountedBase = false,
				
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 23,
                
				NearMarkerType = 'Defensive Point',
				
				LocationRadius = 1600,
				
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2GroundDefense','T2AADefense',
                    'T3MissileDefense',
                    'T2GroundDefense',
                    'T2AADefense',
                    'T2RadarJammer',
                    'T2EnergyProduction',
					'T2Radar',
				}
			}
		}
	},

	-- This builder will start an active DP with a T1
	Builder {BuilderName = 'DP - Expansion - Outnumbered',
	
		PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		Priority = 750,
        
        PriorityFunction = OutNumbered_First15Minutes_Land,

        BuilderConditions = {

            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 2500 }},
    
			{ UCBC, 'IsBaseExpansionUnderway', {false} },

            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1600, -999999, 60, 0, 'AntiSurface' }},
        },
		
		BuilderType = { 'T1' },
		
		BuilderData = {
			Construction = {
				CountedBase = false,
				
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 23,
                
				NearMarkerType = 'Defensive Point',
				
				LocationRadius = 1600,
                
                LoopBuild = true,
                LoopMass = 100,
                LoopEnergy = 2500,
				
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T1GroundDefense','T1AADefense'}
			}
		}
	},
    
	-- Like above, we want to create an Active DP, but on Start and Expansion areas
	-- this allows the AI to setup forward positions long before he has the resources to start a full base
	-- Later on he can convert these 'Active DP' into real bases at his discretion
    Builder {BuilderName = 'DP - Expansion - Start & Expansion Areas',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 745,

        PriorityFunction = AboveUnitCap80,
        
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 480 }},
			
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.01 }},
            
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},
		
			{ UCBC, 'BaseAreaForDP', { 'LocationType', 2000, -999999, 60, 0, 'AntiSurface' } },
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

                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = { 'T2GroundDefense', 'T2AADefense',
                    'T2AirStagingPlatform',
                    'T2Radar',
                    'T2GroundDefense',
                    'T2AADefense',
					'T2GroundDefense',
					'T2AADefense',
                    'T2GroundDefense',
                    'T2AADefense',
                }
            }
        }
    },

    -- this is the SACU version with higher factory requirements
    Builder {BuilderName = 'DP - Expansion - Start & Expansion Areas - SACU',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = AboveUnitCap80,

        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },
			
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.02 }},
            
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.FACTORY - categories.TECH1 }},
		
			{ UCBC, 'BaseAreaForDP', { 'LocationType', 2000, -999999, 60, 0, 'AntiSurface' } },
        },
		
        BuilderType = { 'SubCommander' },
		
        BuilderData = {
            Construction = {
				CountedBase = false,
				
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 44,

                LocationRadius = 2000,
                NearMarkerType = 'Expansion Area',

                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2GroundDefense','T2AirStagingPlatform','T2AADefense','T2Radar',
                    'T3GroundDefense',
                    'T3AADefense',
					'T2GroundDefense',
					'T2AADefense',
                    'T3GroundDefense',
                    'T3AADefense',
                }
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Naval Expansion Construction',

    BuildersType = 'EngineerBuilder',

	-- start the primary naval base only when you have 4 or more factories at this base
	-- only the MAIN base will do this -- Additional naval bases are only initiated by
	-- other expansion bases 
	-- NOTE the threat restrictions on this builder - it's designed so that an AI will
	-- not go into the water if an enemy is close or if there are no safe areas
	-- I made use of the 'rings' variable here -- on a 20km map 2 rings is about 2.5km

    Builder {BuilderName = 'Naval Base Initial - Large Map',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 999,
		
		PriorityFunction = MapHasNavalAreasButNotEstablished,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
			{ UCBC, 'NavalBaseCount', { 1, '<' } },
            
			{ MIBC, 'MapGreaterThan', { 1024 } },            

			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.015, 1.015 } },
      
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, categories.FACTORY * categories.STRUCTURE}},
			
			-- can't be a major enemy base within 15km of here
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 750, 'Economy', 200 }},
			
			-- find a safe, unused, naval marker within 14.5km of this base
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 725, -250, 50, 2, 'AntiSurface' } },
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				CountedBase = true,
                
                ExpansionBase = true,
                ExpansionRadius = 125,
                
				RallyPointRadius = 46,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 725,
				
                ThreatMax = 50,
                ThreatRings = 2,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {'T1SeaFactory','T2AirStagingPlatform','T1SeaFactory','T1Sonar'}
            }
        }
    },
    
    Builder {BuilderName = 'Naval Base Initial - Small Map',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 999,
		
		PriorityFunction = MapHasNavalAreasButNotEstablished,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },

			{ UCBC, 'IsBaseExpansionUnderway', {false} },

			{ UCBC, 'NavalBaseCount', { 1, '<' } },

			{ MIBC, 'MapLessThan', { 1028 } },            

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.85, 20, 1.012, 1.02 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.STRUCTURE}},

			-- can't be a major enemy base within 7km of here
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 350, 'Economy', 200 }},

			-- find a safe, unused, naval marker within 12km of this base
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 600, -250, 50, 1, 'AntiSurface' } },
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
				CountedBase = true,
                
                ExpansionBase = true,
                ExpansionRadius = 125,
                
				RallyPointRadius = 46,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 600,
				
                ThreatMax = 50,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {'T1SeaFactory'}
            }
        }
    },    
   
    -- in Outnumbered conditions - hurry the naval base a bit
    Builder {BuilderName = 'Naval Base Initial - OutNumbered',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
		PriorityFunction = OutNumbered_First15Minutes_Naval, 
		
        BuilderConditions = {

            { EBC, 'GreaterThanEconEnergyStorageCurrent', { 2500 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 16 }},
            
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
			{ UCBC, 'NavalBaseCount', { 1, '<' } },
			
			-- can't be a major enemy base within 15km of here
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 750, 'Economy', 200 }},

			-- find a safe, unused, naval marker within 8km of this base
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 500, -250, 50, 1, 'AntiSurface' } },
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
				CountedBase = true,
                
                ExpansionBase = true,
                ExpansionRadius = 125,
                
				RallyPointRadius = 46,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 500,
				
                ThreatMax = 50,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {'T1SeaFactory'}
            }
        }
    },        
   
    Builder {BuilderName = 'Naval Base Initial - Rush Detected',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 999,

		PriorityFunction = First15Minutes_Naval,

        BuilderConditions = {
            
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
			{ UCBC, 'NavalBaseCount', { 1, '<' } },
			
			-- can't be a major enemy base within 15km of here
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 750, 'Economy', 200 }},

			-- find a safe, unused, naval marker within 8km of this base
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 600, -250, 50, 1, 'AntiSurface' } },
        },
		
        BuilderType = { 'T1','T2' },
		
        BuilderData = {
            Construction = {
				CountedBase = true,
                
                ExpansionBase = true,
                ExpansionRadius = 125,
                
				RallyPointRadius = 46,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 600,
				
                ThreatMax = 50,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {'T1SeaFactory'}
            }
        }
    },      
}

BuilderGroup {BuilderGroupName = 'Engineer Naval Expansion Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
	-- start additional naval bases if naval strength too low
	-- must already have a naval base -- must have 4+ Naval factories
	-- only Naval Bases will do this
    Builder {BuilderName = 'Naval Base Secondary',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,
		
		PriorityFunction = MapHasNavalAreas,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
			{ LUTL, 'NavalStrengthRatioLessThan', { 1 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .25 } },
			
			{ UCBC, 'NavalBaseCount', { 0, '>' } },
			{ UCBC, 'IsBaseExpansionUnderway', {false} },
			
			{ EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType', 1.025, 1.02 } },
			
            -- must be 5 T3 yards before we expand
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 4, categories.FACTORY * categories.STRUCTURE * categories.TECH3 }},
            
            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 1100, -250, 50, 2, 'AntiSurface' } },
			
			-- all other 'counted' Sea bases must have at least 5 T3 factories
			{ UCBC, 'ExistingBasesHaveGreaterThanFactory', { 4, 'Sea', categories.FACTORY * categories.STRUCTURE * categories.TECH3 }},
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				CountedBase = true,
                ExpansionBase = true,
                ExpansionRadius = 125,
				RallyPointRadius = 46,
				
                NearMarkerType = 'Naval Area',
                LocationRadius = 1100,

                ThreatMax = 50,
                ThreatRings = 2,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',

                BuildStructures = {'T1SeaFactory','T2AirStagingPlatform'}
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Defensive Point Construction - Naval',
	BuildersType = 'EngineerBuilder',

	-- build a naval position that is closer to the goal than the current primary position
    Builder {BuilderName = 'Naval DP Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
		
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		-- unique for an engineer platoon
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 750,

        PriorityFunction = AboveUnitCap80,
        
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
            
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},
            
			{ UCBC, 'NavalDefensivePointNeedsStructure', { 'LocationType', 1200, 'OVERLAY SONAR INTELLIGENCE', 60, 0, -999999, 75, 1, 'AntiSurface' }},
        },
		
        BuilderType = { 'T2','T3', },
		
        BuilderData = {
            Construction = {
				CountedBase = false,
				ExpansionBase = true,
                ExpansionRadius = 115,
				RallyPointRadius = 25,

                NearMarkerType = 'Naval Defensive Point',
				
                LocationRadius = 1200,
				
                MarkerUnitCategory = 'OVERLAYSONAR SONAR INTELLIGENCE',
                MarkerRadius = 120,
                MarkerUnitCount = 0,

                ThreatMax = 75,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T1Sonar'}
            }
        }
    },
--[[    
	-- Like above, we want to create an Active DP, but on unused Naval Areas
	-- Later on he can convert these 'Active DP' into real bases at his discretion
    Builder {BuilderName = 'Naval DP Expansion - Naval Areas',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		-- unique for an engineer platoon
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 750,

        PriorityFunction = AboveUnitCap80,
        
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.025 }},
            
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},

            { UCBC, 'NavalAreaForExpansion', { 'LocationType', 1200, -250, 50, 2, 'AntiSurface' } },
        },
		
        BuilderType = { 'T2','T3' },
		
        BuilderData = {
            Construction = {
				CountedBase = false,
				ExpansionBase = true,
                ExpansionRadius = 115,
				RallyPointRadius = 25,

                NearMarkerType = 'Naval Area',
				
                LocationRadius = 1200,

                ThreatMax = 75,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T1Sonar'}
            }
        }
    },
--]]	
}

--[[
BuilderGroup {BuilderGroupName = 'Engineer Defensive Point Construction - Small',

    BuildersType = 'EngineerBuilder',

	-- This builder will start an active DP 
	Builder {BuilderName = 'DP - Expansion Small',
	
		PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		Priority = 745,
		
        BuilderConditions = {
        
            { LUTL, 'UnitCapCheckLess', { .95 } },
            
			{ LUTL, 'GreaterThanEnergyIncome', { 480 }},

			{ UCBC, 'IsBaseExpansionUnderway', {false} },
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.02 }},
            
            -- allow expansions if there are ANY upgraded factories --
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},

            -- find a suitable DP within 2000
            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1250, -999999, 60, 0, 'AntiSurface' }},
        },
		
		BuilderType = { 'T2','T3' },
		
		BuilderData = {
			Construction = {
				CountedBase = false,
				
				ExpansionBase = true,
				ExpansionRadius = 100,
				RallyPointRadius = 23,
				
				NearMarkerType = 'Defensive Point',
				
				LocationRadius = 1250,
				
                ThreatMax = 60,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2GroundDefense','T2AADefense',
                    'T2Wall',
                    'Wall',
                    'Wall',
                    'T2Wall',
                    'Wall',
                    'Wall',
                    'T2Wall',
                    'T2MissileDefense',
                    'T2Wall',
                    'Wall',
                    'Wall',
                    'T2Wall',
                    'Wall',
                    'Wall',
                    'T2Wall',
                    'T2GroundDefense',
                    'T2AADefense',
                    'T2RadarJammer',
                    'T2EnergyProduction',
					'T2Radar',
                    'T2Wall',
                    'Wall',
                    'T2Wall',
                    'T2Wall',
                    'Wall',
                    'T2Wall',
				}
			}
		}
	},
}
--]]
