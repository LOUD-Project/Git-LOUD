-- Loud_AI_Factory_Land_Builders.lua
-- factory production of all land units

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal

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
	
	return self.Priority,true
end

local First45Minutes = function(self,aiBrain)

	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
	
	return self.Priority, true
end

local Map10korLess = function(self,aiBrain)

    if ScenarioInfo.IMAPSize <= 64 then
        return 550, true
    end

    return self.Priority, true
end

-- This group covers those units that are universal to both land and water maps
BuilderGroup {BuilderGroupName = 'Factory Production - Land',
    BuildersType = 'FactoryBuilder',
	
    -- land scouts are reduced priority on smaller maps
    Builder {BuilderName = 'Land Scout', 
	
        PlatoonTemplate = 'T1LandScout',

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },

			-- this is here to insure enough scouts for large combat platoons but to avoid flooding
            { UCBC, 'PoolLess', { 4, categories.LAND * categories.SCOUT }},

			-- and that we aren't already building some
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SCOUT * categories.LAND, categories.LAND } },
        }, 
		
        BuilderType = {'LandT1','LandT2','LandT3'},
    },

    -- LAB are only built for the first 30 minutes
	Builder {BuilderName = 'T1 Bots',
	
		PlatoonTemplate = 'T1LandDFBot',

		Priority = 550,

		PriorityFunction = First30Minutes,

		BuilderConditions = {
            -- don't build LABs for typical combat - but numbers count when you're winning
            { LUTL, 'LandStrengthRatioGreaterThan', { 1.2 } },

            { LUTL, 'HaveLessThanUnitsWithCategory', { 75, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS }},
		},
		
		BuilderType = {'LandT1'},
    },	
	
    Builder {BuilderName = 'T1 Tanks',
	
        PlatoonTemplate = 'T1LandDFTank',

        Priority = 550,

		PriorityFunction = First45Minutes,

        BuilderConditions = {
            { LUTL, 'HaveLessThanUnitsWithCategory', { 72, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.FACTORY * categories.LAND - categories.TECH1 }},
        },
		
        BuilderType = {'LandT1','LandT2'},
    },

    Builder {BuilderName = 'T1 Mobile Artillery',
	
        PlatoonTemplate = 'T1LandArtillery',

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
            -- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.INDIRECTFIRE * categories.MOBILE }},
        },
		
        BuilderType = {'LandT1'},
    },
    
    -- T1 MAA is only built for the first 30 minutes --
    Builder {BuilderName = 'T1 Mobile AA - Large Map',
	
        PlatoonTemplate = 'T1LandAA',

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'AirStrengthRatioLessThan', { 4.5 } },

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
 
            { UCBC, 'PoolLess', { 4, categories.LAND * categories.MOBILE * categories.ANTIAIR }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND - categories.TECH1 }},
        },

        BuilderType = {'LandT1'},
    },
	
	-- on a small map - immediate AA defense a necessity
	-- a second opportunity for T1 Mobile AA
    Builder {BuilderName = 'T1 Mobile AA - Small Map',
	
        PlatoonTemplate = 'T1LandAA',

        Priority = 550,

		PriorityFunction = First30Minutes,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'AirStrengthRatioLessThan', { 4.5 } },            

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
 
			-- only on 5k-20k maps
			{ MIBC, 'MapLessThan', { 1028 } },

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			-- turn off as soon as we have a T2/T3 land factory
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND - categories.TECH1 }},
        },

        BuilderType = {'LandT1'},
    },

	
	-- Tech 2 - Shield/Stealth Vehicles	-- starts when there are 2+ T2/T3 factories
	-- stops when there is are 1+ T3 land factory and replaced by Tech 3 version
    Builder {BuilderName = 'T2 Mobile Shield - UEF',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 1,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 15 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Mobile Shield - Aeon',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 2,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 15 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },
	
    Builder {BuilderName = 'T2 Mobile Stealth - Cybran',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 3,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'PoolLess', { 7, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 15 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
        },

        BuilderType = {'LandT2'},
    },

	
	-- T3 Mobile Shield - T2 for UEF,AEON,SERA
	-- only made when there are NO T2 factory at this location
    Builder {BuilderName = 'T3 Mobile Shields - UEF',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 1,

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},

			{ LUTL, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 25 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
        },
		
        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'T3 Mobile Shields - AEON',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 2,

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},

			{ LUTL, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 25 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
        },

        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'T3 Mobile Stealth - CYBRAN',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 3,

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},

			{ LUTL, 'PoolLess', { 7, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
        },

        BuilderType = {'LandT3'},
    },
	
    Builder {BuilderName = 'T3 Mobile Shields - SERA',
	
        PlatoonTemplate = 'T3MobileShields',

		FactionIndex = 4,

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 25 }},

            -- must have some Directfire in the Pool at this location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
        },

        BuilderType = {'LandT3'},
    },

	-- T3 Sniper Bot
--[[	
    Builder {BuilderName = 'T3 Sniper Bot',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 0,	#--- turned this off for now - AI doesn't make good use of them - and they are wasted as part of regular assault teams
        BuilderConditions = {
 			{ MIBC, 'FactionIndex', { 2, 4 } },
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH3 * categories.BOT }},
        },
        BuilderType = {'Land'},
    },
--]]	
	-- T3 Shield Disruptor - AEON only
--[[	
    Builder {BuilderName = 'T3 Shield Disruptors',
        PlatoonTemplate = 'T3ShieldDisruptor',
        Priority = 0,
        BuilderConditions = {
 			{ MIBC, 'FactionIndex', { 2 } },
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTISHIELD * categories.LAND * categories.MOBILE * categories.TECH3 }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.ANTISHIELD * categories.LAND * categories.MOBILE * categories.TECH3 }},
        },
        BuilderType = {'Land'},
    },
--]]

}


BuilderGroup {BuilderGroupName = 'Factory Producion - Land - Land Only Map',
    BuildersType = 'FactoryBuilder',

	-- T2 Flak Vehicle 
    Builder {BuilderName = 'T2 Mobile Flak',
	
        PlatoonTemplate = 'T2LandAA',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
 
            { LUTL, 'AirStrengthRatioLessThan', { 3 } }, 

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},

            -- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

            -- if less than 24 T2/T3 MAA
			{ UCBC, 'PoolLess', { 24, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1, categories.LAND }},
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
  
            { LUTL, 'AirStrengthRatioLessThan', { 1 } },

            --- enemy focused upon ground attack in his air force
            { LUTL, 'AirToGroundBiasGreaterThan', { 1 } },

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},

            -- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

            -- if less than 12 T2/T3 MAA
			{ UCBC, 'PoolLess', { 12, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1, categories.LAND }},
        },
		
        BuilderType = {'LandT2'},
    },	
	
    -- Tech 2 DirectFire Tank
    Builder {BuilderName = 'T2 Tank',
	
        PlatoonTemplate = 'T2LandDFTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH2, categories.LAND - categories.TECH1, categories.LAND }},
        },
		
        BuilderType = {'LandT2','LandT3'},
    },

    -- Tech 2 Attack Tank - 
    Builder {BuilderName = 'T2 Attack Tank',
	
        PlatoonTemplate = 'T2AttackTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH2, categories.LAND - categories.TECH1, categories.LAND }},
        },
		
        BuilderType = {'LandT2','LandT3'},
    },
	
	-- Tech 2 Artillery
    Builder {BuilderName = 'T2 Artillery',
	
        PlatoonTemplate = 'T2LandArtillery',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },

			{ LUTL, 'FactoriesGreaterThan', { 1, categories.LAND - categories.TECH1 }},

			{ LUTL, 'PoolLess', { 24, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.INDIRECTFIRE * categories.MOBILE, categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },

	-- T3 Assault Bots
    Builder {BuilderName = 'T3 Armored Assault',
	
        PlatoonTemplate = 'T3ArmoredAssault',

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH3, (categories.LAND * categories.TECH3) + categories.GATE }},
        },
		
        BuilderType =  {'LandT3','Gate'},	-- this allows Gates to make them as well
    },

	-- T3 Mobile AA
    Builder {BuilderName = 'T3 Mobile AA',
	
        PlatoonTemplate = 'T3LandAA',

        Priority = 600, 
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
 
			{ LUTL, 'AirStrengthRatioLessThan', { 3 } }, 

			{ LUTL, 'PoolLess', { 32, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},

            -- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.LAND * categories.TECH3 }},

        },
		
        BuilderType = {'LandT3','Gate'},
    },

    Builder {BuilderName = 'T3 Mobile AA - High Need',
	
        PlatoonTemplate = 'T3LandAA',

        Priority = 610, 
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
 
			{ LUTL, 'AirStrengthRatioLessThan', { 1 } }, 

            --- enemy focused upon ground attack in his air force
            { LUTL, 'AirToGroundBiasGreaterThan', { 1 } },

			{ LUTL, 'PoolLess', { 16, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},

            -- must have some Directfire in the Pool at this Location
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.LAND * categories.TECH3 }},
        },
		
        BuilderType = {'LandT3','Gate'},
    },
	
    -- T3 Tank - non amphibious T3 Land Units
    Builder {BuilderName = 'Siege Assault Bot T3',
	
        PlatoonTemplate = 'T3LandBot',

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS), categories.LAND * categories.TECH3 }},				
        },
		
        BuilderType =  {'LandT3','Gate'},	-- this allows Gates to make them as well
    },
	
    -- T3 Mobile Artillery 
    Builder {BuilderName = 'Mobile Artillery T3',
	
        PlatoonTemplate = 'T3LandArtillery',

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},
            
			{ LUTL, 'PoolLess', { 30, categories.LAND * categories.MOBILE * categories.ARTILLERY * categories.TECH3 }},
            
 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ARTILLERY * categories.TECH3, categories.LAND * categories.TECH3 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 30, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE * categories.TECH3 }},
        },
		
        BuilderType = {'LandT3'},
    },
	
	-- T3 MML - UEF Only
    Builder {BuilderName = 'Mobile Missile T3',
	
        PlatoonTemplate = 'T3MobileMissile',

		FactionIndex = 1,

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInLandMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },

			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

			{ LUTL, 'PoolLess', { 30, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xel0306, categories.LAND * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 14, categories.xel0306 }},
        },

        BuilderType = {'LandT3'},
    },
	
}


BuilderGroup {BuilderGroupName = 'Factory Producion - Land - Water Map',
    BuildersType = 'FactoryBuilder',


    -- Tech 1 Amphibious Tank
    Builder {BuilderName = 'T1 Amphibious Tank',
	
        PlatoonTemplate = 'T1LandAmphibious',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap70,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

            { LUTL, 'PoolLess', { 60, categories.AMPHIBIOUS }},

            -- ok - we use a very general amphibious check here since units in this class are NOT necessarily DIRECTFIRE
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.AMPHIBIOUS, categories.LAND }},
        },

        BuilderType = {'LandT1','LandT2'},
    },
	

    -- Tech 2 Amphibious Tank
    Builder {BuilderName = 'T2 Amphibious Tank',
	
        PlatoonTemplate = 'T2LandAmphibTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

            { LUTL, 'PoolLess', { 60, categories.DIRECTFIRE * categories.AMPHIBIOUS * categories.LAND }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 4, categories.DIRECTFIRE * categories.AMPHIBIOUS * categories.TECH2, categories.LAND }},
        },

        BuilderType = {'LandT2','LandT3'},
    },
	
	-- T2 Amphibious AA -- builds non-amphib for Cybran & UEF to fill out land formations
    Builder {BuilderName = 'T2 Amphibious AA',
	
        PlatoonTemplate = 'T2LandAmphibAA',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },

			{ LUTL, 'PoolLess', { 20, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },
	
	-- T2 Amphibious Shield - Aeon Only
    Builder {BuilderName = 'T2 Mobile Amphibious Shield - Aeon',
	
        PlatoonTemplate = 'T2MobileShields',

		FactionIndex = 2,

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'PoolLess', { 15, categories.LAND * categories.MOBILE * categories.SHIELD }},

			{ LUTL, 'FactoriesGreaterThan', { 1, categories.LAND - categories.TECH1 }},
            
            { EBC, 'GreaterThanEnergyTrendOverTime', { 20 }},

			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },
	
    -- Tech 2 DirectFire Tank -- limited output on water maps for some land operations
    Builder {BuilderName = 'T2 Tank - Water',
	
        PlatoonTemplate = 'T2LandDFTank',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND - categories.TECH1 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 75, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS), categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },
	
	-- Tech 2 Artillery	-- limited output on water maps for land operations
    Builder {BuilderName = 'T2 Artillery - Water',
	
        PlatoonTemplate = 'T2LandArtilleryWaterMap',

        Priority = 550,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND - categories.TECH1 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 32, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.AMPHIBIOUS }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.AMPHIBIOUS), categories.LAND }},
        },

        BuilderType = {'LandT2'},
    },
	
	-- ===================  --
	-- T3 Amphibious Units	--
	-- ===================  --
	-- T3 Amphibious units only start building when there are 3 or more T3 factories
	-- In this way T2 production continues at great volume until then
	
    Builder {BuilderName = 'T3 Amphibious Assault',
	
        PlatoonTemplate = 'T3Amphibious',

        Priority = 600,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 4, (categories.LAND * categories.AMPHIBIOUS) * categories.DIRECTFIRE }},
        },

        BuilderType = {'LandT3','Gate'},
    },	
	
	-- T3 Amphibious AA --
    Builder {BuilderName = 'T3 Amphibious AA',
	
        PlatoonTemplate = 'T3AmphibiousAA',

        Priority = 600, 
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.AMPHIBIOUS * categories.ANTIAIR, categories.LAND * categories.TECH3 }},
        },

        BuilderType = {'LandT3'},
    },
	
	-- T3 Amphibious Artillery --
    Builder {BuilderName = 'T3 Amphibious Artillery',
	
        PlatoonTemplate = 'T3AmphibiousArtillery',

        Priority = 600, 
		
        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.AMPHIBIOUS * categories.INDIRECTFIRE, categories.LAND * categories.TECH3 }},
        },

        BuilderType = {'LandT3'},
    },

	-- T3 NON-AMPHIB Production --
	-- begins only when there are 4 T3 factories --
	
    -- T3 non amphibious Land Units
    Builder {BuilderName = 'Siege Assault Bot T3 - Water',
	
        PlatoonTemplate = 'T3LandBot',

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },

			{ LUTL, 'FactoriesGreaterThan', { 3, categories.LAND * categories.TECH3 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 75, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS }},

            -- this insures that we're actually building amphib units first without using priority as a gate
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 1, (categories.LAND * categories.AMPHIBIOUS) * categories.DIRECTFIRE }},

 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS), categories.LAND * categories.TECH3 }},			
        },

        BuilderType =  {'LandT3'},
    },

	-- T3 Mobile Artillery
    Builder {BuilderName = 'T3 Mobile Artillery - Water',
	
        PlatoonTemplate = 'T3LandArtillery',

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },			

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 32, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.AMPHIBIOUS }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.ARTILLERY), categories.LAND * categories.TECH3 }},
        },

        BuilderType = {'LandT3'},
    },
	
	-- T3 Mobile Missile -- UEF only --
    Builder {BuilderName = 'T3 Mobile Missile - Water',
	
        PlatoonTemplate = 'T3MobileMissile',

		FactionIndex = 1,

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},		

			{ LUTL, 'LandStrengthRatioLessThan', { 5.5 } },

			{ LUTL, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},

            { LUTL, 'HaveLessThanUnitsWithCategory', { 32, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.AMPHIBIOUS }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xel0306, categories.LAND * categories.TECH3 }},
        },

        BuilderType = {'LandT3'},
    },
	
}