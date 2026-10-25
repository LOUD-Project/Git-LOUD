-- Loud_AI_Factory_Land_Builders.lua
-- factory production of all land units

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local Game = import('/lua/game.lua')


local GetArmyUnitCap                = GetArmyUnitCap
local GetArmyUnitCostTotal          = GetArmyUnitCostTotal

local AMPHIBIOUS        = categories.AMPHIBIOUS

local FACTORY           = categories.FACTORY
local LAND              = categories.LAND
local MOBILE            = categories.MOBILE
local ANTIMISSILE       = categories.ANTIMISSILE * MOBILE
local ARTILLERY         = categories.ARTILLERY * MOBILE
local SILO              = categories.SILO
local NUKE              = categories.NUKE * SILO

local TECH1             = categories.TECH1
local TECH2             = categories.TECH2
local TECH3             = categories.TECH3

local LANDSCOUT         = LAND * categories.SCOUT
local LANDT2            = LAND * TECH2
local LANDT3            = LAND * TECH3

local ANTIAIRLAND       = LAND * MOBILE * categories.ANTIAIR
local DIRECTFIRELAND    = LAND * MOBILE * categories.DIRECTFIRE
local INDIRECTFIRELAND  = LAND * MOBILE * categories.INDIRECTFIRE
local SHIELDLAND        = LAND * MOBILE * categories.SHIELD
local COUNTERLAND       = LAND * MOBILE * categories.COUNTERINTELLIGENCE

local AboveUnitCap70 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .70 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap85 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local First30Minutes = function( self,aiBrain )
	
	if aiBrain.CycleTime > 1800 then
		return 0, false
	end
    
    if aiBrain.CycleTime < 1 then
        return 10, true
    end
	
	return self.Priority,true
end

local First45Minutes = function(self,aiBrain)

	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
    
    if aiBrain.CycleTime < 1 then
        return 10, true
    end
	
	return self.Priority, true
end

local Map10korLess = function(self,aiBrain)

    if ScenarioInfo.IMAPSize <= 64 then
        return 550, true
    end

    return self.Priority, true
end

--- THIS GROUP IS UNIVERSAL TO ALL MAPS
BuilderGroup {BuilderGroupName = 'Factory Production Land', BuildersType = 'FactoryBuilder',
	
    Builder {BuilderName = 'Land Scout', 
	
        PlatoonTemplate = 'T1LandScout',

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
            
            { MIBC, 'GreaterThanGameTime', { 180 }},

			--- this is here to insure enough scouts for large combat platoons but to avoid flooding
            { UCBC, 'PoolLess', { 4, LANDSCOUT }},

			--- and that we aren't already building some
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, LANDSCOUT, LAND } },

            --- scouts cannot be more than 6% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 6, LANDSCOUT, DIRECTFIRELAND, 5 }},
        }, 
		
        BuilderType = {'LandT1','LandT2','LandT3'},
    },

	Builder {BuilderName = 'T1 Bots',
	
		PlatoonTemplate = 'T1LandDFBot',

		Priority = 550,

		PriorityFunction = First30Minutes,

		BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

            { LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },

            { LUTL, 'HaveLessThanUnitsWithCategory', { 55, DIRECTFIRELAND - AMPHIBIOUS }},
		},
		
		BuilderType = {'LandT1'},
    },	
	
    Builder {BuilderName = 'T1 Tanks',
	
        PlatoonTemplate = 'T1LandDFTank',

        Priority = 550,

		PriorityFunction = First45Minutes,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 85, DIRECTFIRELAND - AMPHIBIOUS }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, FACTORY * LAND - TECH1 }},
        },
		
        BuilderType = {'LandT1','LandT2'},
    },

    Builder {BuilderName = 'T1 Mobile Artillery',
	
        PlatoonTemplate = 'T1LandArtillery',

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, LANDT3 }},

            --- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			--- turn off as soon as we have a T2/T3 land factory
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, FACTORY * LAND - TECH1 }},

            --- mobile arty cannot be more than 15% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 15, INDIRECTFIRELAND, DIRECTFIRELAND, 12 }},            
        },
		
        BuilderType = {'LandT1'},
    },
    
    Builder {BuilderName = 'T1 Mobile AA - Large Map',
	
        PlatoonTemplate = 'T1LandAA',

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'AirStrengthRatioLessThan', { 4.5 } },

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
 
            { UCBC, 'PoolLess', { 4, ANTIAIRLAND }},

            --- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, FACTORY * LAND - TECH1 }},

            --- mobile AA cannot be more than 10% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, ANTIAIRLAND, DIRECTFIRELAND, 8 }},
        },

        BuilderType = {'LandT1'},
    },
	
    Builder {BuilderName = 'T1 Mobile AA - Small Map',
	
        PlatoonTemplate = 'T1LandAA',

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'AirStrengthRatioLessThan', { 4.5 } },            

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
 
			--- only on 5k-20k maps
			{ MIBC, 'MapLessThan', { 1028 } },
 
            { UCBC, 'PoolLess', { 8, ANTIAIRLAND }},

            --- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			--- turn off as soon as we have a T2/T3 land factory
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, FACTORY * LAND - TECH1 }},

            --- mobile AA cannot be more than 10% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, ANTIAIRLAND, DIRECTFIRELAND, 8 }},
        },

        BuilderType = {'LandT1'},
    },

	
	-- Tech 2 
    -- Shield/Stealth Vehicles	-- starts when there are 2+ T2/T3 factories
    Builder {BuilderName = 'T2 Mobile Shield - UEF',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 1,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, SHIELDLAND, LAND }},

            --- T2 mobile shields cannot be more than 8% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 8, SHIELDLAND, DIRECTFIRELAND - AMPHIBIOUS, 4 }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Mobile Shield - Aeon',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 2,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {

            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, SHIELDLAND, LAND }},

            --- T2 mobile shields cannot be more than 8% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 8, SHIELDLAND, DIRECTFIRELAND, 4 }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Mobile Stealth - Cybran',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 3,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

            --- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, COUNTERLAND }},

            --- Mobile Stealth cannot be more than 6% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 6, COUNTERLAND, DIRECTFIRELAND - AMPHIBIOUS, 2 }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Mobile Shield - Sera',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 4,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

            --- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, SHIELDLAND, LAND }},

            --- T2 mobile shields cannot be more than 8% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 8, SHIELDLAND, DIRECTFIRELAND, 4 }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Mobile TMD',
	
        PlatoonTemplate = 'T2LandMobileTMD',

        Priority = 550,

        BuilderConditions = {

            --- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, LANDT2 * ANTIMISSILE }},

            --- Mobile TMD cannot be more than 5% of non-amphibious DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 5, LANDT2 * ANTIMISSILE, DIRECTFIRELAND - AMPHIBIOUS, 2 }},
        },
		
        BuilderType = {'LandT2'},
    },
    
	
	-- T3 Mobile Shield - T2 for UEF,AEON,SERA
	-- only made when there are NO T2 factory at this location
    Builder {BuilderName = 'T3 Mobile Shields - UEF',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 1,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, LANDT3 }},

            { EBC, 'GreaterThanEnergyTrendOverTime', { 30 }},

            --- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, SHIELDLAND, LAND }},

            --- T3 mobile shields cannot be more than 8% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 8, SHIELDLAND, DIRECTFIRELAND, 4 }},
        },
		
        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'T3 Mobile Shields - AEON',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 2,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, LANDT3 }},

            { EBC, 'GreaterThanEnergyTrendOverTime', { 30 }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, SHIELDLAND, LAND }},

            --- T3 mobile shields cannot be more than 8% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 8, SHIELDLAND, DIRECTFIRELAND, 4 }},
        },

        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'T3 Mobile Stealth - CYBRAN',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 3,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, LANDT3 }},

            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, COUNTERLAND }},

            --- Mobile Stealth cannot be more than 6% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 6, COUNTERLAND, DIRECTFIRELAND, 4 }},
        },

        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'T3 Mobile Shields - SERA',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 4,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { EBC, 'GreaterThanEnergyTrendOverTime', { 30 }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, SHIELDLAND, LAND }},

            --- T3 mobile shields cannot be more than 8% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 8, SHIELDLAND, DIRECTFIRELAND, 4 }},
        },

        BuilderType = {'LandT3'},
    },
	
    -- T3 Mobile TMD
    Builder {BuilderName = 'T3 Mobile TMD - AEON',
	
        PlatoonTemplate = 'T3LandMobileTMD',
        
        FactionIndex = 2,

        Priority = 550,

        BuilderConditions = {

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, LAND * ANTIMISSILE }},

            --- Mobile TMD cannot be more than 5% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 5, LAND * ANTIMISSILE, DIRECTFIRELAND - AMPHIBIOUS, 2 }},
        },
		
        BuilderType = {'LandT3'},
    },
    
    -- T3 Mobile Anti-Nuke 
    Builder {BuilderName = 'T3 Mobile AntiNuke',
	
        PlatoonTemplate = 'T3MobileAntiNuke',

        Priority = 550,

        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if Game.WeaponRestricted('StrategicMissile') then
                return 0, false
            end
            
            if import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance( aiBrain, 0, NUKE,'Enemy') then
                return (self.OldPriority or self.Priority), true
            end

            return 10, true

        end,
		
        BuilderConditions = {

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},
            
 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, LANDT3 * ANTIMISSILE * SILO, LANDT3 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, LANDT3 * ANTIMISSILE * SILO }},
        },
		
        BuilderType = {'LandT3'},
    },
    
}

--- THIS GROUP IS ONLY USED ON MAPS WITH NO WATER
BuilderGroup {BuilderGroupName = 'Factory Production Land - Land Only Map', BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'T2 Mobile Flak',
	
        PlatoonTemplate = 'T2LandAA',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },

            { LUTL, 'AirStrengthRatioLessThan', { 6 } },

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, LANDT3 }},

            --- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

            --- if less than 24 T2/T3 MAA
			{ UCBC, 'PoolLess', { 24, ANTIAIRLAND - TECH1 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, ANTIAIRLAND - TECH1, LAND }},

            --- mobile AA cannot be more than 12% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 12, ANTIAIRLAND - TECH1, DIRECTFIRELAND, 12 }},
        },
		
        BuilderType = {'LandT2'},
    },	

    Builder {BuilderName = 'T2 Mobile Flak - High Need',
	
        PlatoonTemplate = 'T2LandAA',

        Priority = 560,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
  
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },

            --- enemy focused upon ground attack in his air force
            { LUTL, 'AirToGroundBiasGreaterThan', { 1 } },

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, LANDT3 }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

            --- if less than 12 T2/T3 MAA
			{ UCBC, 'PoolLess', { 12, ANTIAIRLAND - TECH1 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, ANTIAIRLAND - TECH1, LAND }},

            --- mobile AA cannot be more than 12% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 12, ANTIAIRLAND - TECH1, DIRECTFIRELAND, 12 }},
        },
		
        BuilderType = {'LandT2'},
    },	

    Builder {BuilderName = 'T2 Tank',
	
        PlatoonTemplate = 'T2LandDFTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioLessThan', { 5.1 } },

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, LANDT3 }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, DIRECTFIRELAND * LANDT2, LAND - TECH1, LAND }},
        },
		
        BuilderType = {'LandT2','LandT3'},
    },

    Builder {BuilderName = 'T2 Attack Tank',
	
        PlatoonTemplate = 'T2AttackTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioLessThan', { 5.1 } },

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, LANDT3 }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, DIRECTFIRELAND * LANDT2, LAND - TECH1, LAND }},
        },
		
        BuilderType = {'LandT2','LandT3'},
    },
	
    Builder {BuilderName = 'T2 Artillery',
	
        PlatoonTemplate = 'T2LandArtillery',

        Priority = 550,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 1, categories.LAND - TECH1 }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, INDIRECTFIRELAND, LAND }},

            --- mobile arty cannot be more than 15% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 18, INDIRECTFIRELAND, DIRECTFIRELAND, 18 }},                        
        },

        BuilderType = {'LandT2'},
    },

    Builder {BuilderName = 'T3 Armored Assault',
	
        PlatoonTemplate = 'T3ArmoredAssault',

        Priority = 550,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'LandStrengthRatioLessThan', { 6.5 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, DIRECTFIRELAND * LANDT3, LANDT3 + categories.GATE }},
        },
		
        BuilderType =  {'LandT3','Gate'},	-- this allows Gates to make them as well
    },

    Builder {BuilderName = 'Siege Assault Bot T3',
	
        PlatoonTemplate = 'T3LandBot',

        Priority = 550,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'LandStrengthRatioLessThan', { 6.5 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, DIRECTFIRELAND - AMPHIBIOUS, LANDT3 }},				
        },
		
        BuilderType =  {'LandT3','Gate'},	-- this allows Gates to make them as well
    },
	
    Builder {BuilderName = 'Mobile Artillery T3',
	
        PlatoonTemplate = 'T3LandArtillery',

        Priority = 550,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, LANDT3 * ARTILLERY, LANDT3 }},

            --- mobile arty cannot be more than 18% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 18, INDIRECTFIRELAND, DIRECTFIRELAND, 18 }},
        },
		
        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'Mobile Missile T3',
	
        PlatoonTemplate = 'T3MobileMissile',

		FactionIndex = 1,

        Priority = 550,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.xel0306, LANDT3 }},

            --- mobile arty cannot be more than 18% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 18, categories.xel0306, DIRECTFIRELAND, 18 }},            
        },

        BuilderType = {'LandT3'},
    },

    Builder {BuilderName = 'T3 Mobile AA',
	
        PlatoonTemplate = 'T3LandAA',

        Priority = 550, 
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end
            
            if aiBrain.LandRatio < 0.7 then
                return 10, true
            end
            
            if aiBrain.AirRatio > 6 then
                return 10, true
            end
            
            if aiBrain.AirRatio < 3 or aiBrain.AirBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, DIRECTFIRELAND }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, ANTIAIRLAND, LANDT3 }},

            --- mobile AA cannot be more than 12% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 12, ANTIAIRLAND - TECH1, DIRECTFIRELAND, 15 }},
        },
		
        BuilderType = {'LandT3','Gate'},
    },

}


BuilderGroup {BuilderGroupName = 'Factory Production Land - Water Map', BuildersType = 'FactoryBuilder',


    Builder {BuilderName = 'T1 Amphibious Tank',
	
        PlatoonTemplate = 'T1LandAmphibious',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap70,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

            { LUTL, 'PoolLess', { 60, categories.AMPHIBIOUS }},

            --- ok - we use a general amphibious check since units in this class are NOT necessarily DIRECTFIRE
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, AMPHIBIOUS, LAND }},
        },

        BuilderType = {'LandT1','LandT2'},
    },

    Builder {BuilderName = 'T1 Amphibious Mobile Artillery - SERA',
	
        PlatoonTemplate = 'T1LandArtillery',

		FactionIndex = 4,

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},
            
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

            --- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, DIRECTFIRELAND * AMPHIBIOUS }},

            --- mobile arty cannot be more than 18% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 18, INDIRECTFIRELAND, DIRECTFIRELAND, 12 }},            
        },
		
        BuilderType = {'LandT1','LandT2'},  --- SERA don't have an amphib mobile T2 artillery so we all T2 factories here
    },

    Builder {BuilderName = 'T2 Amphibious Tank',
	
        PlatoonTemplate = 'T2LandAmphibTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, LANDT3 }},

            { LUTL, 'PoolLess', { 60, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.AMPHIBIOUS * categories.TECH2 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 4, DIRECTFIRELAND * AMPHIBIOUS * LANDT2, LAND }},
        },

        BuilderType = {'LandT2','LandT3'},
    },
	
    Builder {BuilderName = 'T2 Amphibious AA',  --- note: this build non-amphib AA for UEF & Cybran
	
        PlatoonTemplate = 'T2LandAmphibAA',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },

			{ LUTL, 'PoolLess', { 20, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, ANTIAIRLAND, LAND }},

            --- mobile AA cannot be more than 12% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 12, ANTIAIRLAND - TECH1, DIRECTFIRELAND, 12 }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Tank - Water',
	
        PlatoonTemplate = 'T2LandDFTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND - TECH1 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 64, DIRECTFIRELAND - AMPHIBIOUS }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, DIRECTFIRELAND - AMPHIBIOUS, LAND }},

            --- Non-amphib T2 Tanks cannot be more than 10% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, DIRECTFIRELAND - AMPHIBIOUS, DIRECTFIRELAND - AMPHIBIOUS, 12 }},

        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Artillery - Water',
	
        PlatoonTemplate = 'T2LandArtilleryWaterMap',

        Priority = 550,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND - TECH1 }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, INDIRECTFIRELAND - AMPHIBIOUS, LAND }},

            --- non-amphib mobile arty cannot be more than 10% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, INDIRECTFIRELAND - AMPHIBIOUS, DIRECTFIRELAND - AMPHIBIOUS, 8 }},
        },

        BuilderType = {'LandT2','LandT3'},
    },
	
    Builder {BuilderName = 'T3 Amphibious Assault',
	
        PlatoonTemplate = 'T3Amphibious',

        Priority = 550,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 4, DIRECTFIRELAND * LANDT3 * AMPHIBIOUS }},
        },

        BuilderType = {'LandT3','Gate'},
    },	
	
    Builder {BuilderName = 'T3 Amphibious AA',
	
        PlatoonTemplate = 'T3AmphibiousAA',

        Priority = 550, 
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, ANTIAIRLAND * AMPHIBIOUS, LANDT3 }},

            --- amphibious MAA cannot be more than 12% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 12, ANTIAIRLAND * AMPHIBIOUS, DIRECTFIRELAND, 12 }},
        },

        BuilderType = {'LandT3'},
    },
	
	-- T3 Amphibious Artillery --
    Builder {BuilderName = 'T3 Amphibious Artillery',
	
        PlatoonTemplate = 'T3AmphibiousArtillery',

        Priority = 550, 
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,
			
        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, INDIRECTFIRELAND * LANDT3 * AMPHIBIOUS, LANDT3 }},

            --- amphibious mobile arty cannot be more than 18% of DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 18, INDIRECTFIRELAND * LANDT3 * AMPHIBIOUS, DIRECTFIRELAND, 18 }},            
        },

        BuilderType = {'LandT3'},
    },

	-- T3 NON-AMPHIB Production --
    Builder {BuilderName = 'Siege Assault Bot T3 - Water',
	
        PlatoonTemplate = 'T3LandBot',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'LandStrengthRatioLessThan', { 5.1 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 64, DIRECTFIRELAND - AMPHIBIOUS }},

            --- insures that we're building amphib units first without using priority as a gate
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 1, DIRECTFIRELAND * AMPHIBIOUS }},

 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, DIRECTFIRELAND * LANDT3 - AMPHIBIOUS, LANDT3 }},			

            --- Non-amphib T3 cannot be more than 10% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, DIRECTFIRELAND - AMPHIBIOUS, DIRECTFIRELAND - AMPHIBIOUS, 12 }},

        },

        BuilderType =  {'LandT3'},
    },

    Builder {BuilderName = 'T3 Mobile Artillery - Water',
	
        PlatoonTemplate = 'T3LandArtillery',

        Priority = 550,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, LANDT3 * ARTILLERY, LANDT3 }},

            --- non-amphib mobile arty cannot be more than 10% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, INDIRECTFIRELAND - AMPHIBIOUS, DIRECTFIRELAND - AMPHIBIOUS, 8 }},
        },

        BuilderType = {'LandT3'},
    },
	
	-- T3 Mobile Missile -- UEF only --
    Builder {BuilderName = 'T3 Mobile Missile - Water',
	
        PlatoonTemplate = 'T3MobileMissile',

		FactionIndex = 1,

        Priority = 550,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end
            
            if aiBrain.LandBias > 1 then
                return self.Priority + 10, true
            end
            
            return self.Priority, false
        end,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'FactoriesGreaterThan', { 2, LANDT3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xel0306, LANDT3 }},

            --- mobile missile arty cannot be more than 10% of non-amphib DIRECTFIRELAND units
            { UCBC, 'HaveLessThanUnitsAsPercentageofCategoryUnitCount', { 10, categories.xel0306, DIRECTFIRELAND - AMPHIBIOUS, 8 }},            
        },

        BuilderType = {'LandT3'},
    },
	
}