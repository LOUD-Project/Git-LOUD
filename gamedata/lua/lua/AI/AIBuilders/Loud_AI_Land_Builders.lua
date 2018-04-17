--  Loud_AI_Land_Builders.lua
--- controls all land unit building by factories

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'


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

-- This group covers those units that are universal to both land and water maps
BuilderGroup {BuilderGroupName = 'Land Factory Builders',
    BuildersType = 'FactoryBuilder',
	
    Builder {BuilderName = 'Land Scout', 
	
        PlatoonTemplate = 'T1LandScout',
        Priority = 550,

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			-- this is here to insure enough scouts for large combat platoons but to avoid flooding
            { UCBC, 'PoolLess', { 6, categories.LAND * categories.SCOUT }},
			-- and that we aren't already building some
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SCOUT * categories.LAND, categories.LAND } },
			
        }, 
		
        BuilderType = {'LandT1','LandT2'},
		
    },
	
    Builder {BuilderName = 'Land Scout T3', 
	
        PlatoonTemplate = 'T3LandScout',
        Priority = 600,

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			-- this is here to insure enough scouts for large combat platoons but to avoid flooding
            { UCBC, 'PoolLess', { 6, categories.LAND * categories.SCOUT }},
			-- and that we aren't already building some
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SCOUT * categories.LAND, categories.LAND } },
			
        }, 
		
        BuilderType = {'LandT3'},
		
    },
	
	Builder {BuilderName = 'T1 Bots',
	
		PlatoonTemplate = 'T1LandDFBot',
		Priority = 550,

		PriorityFunction = First30Minutes,
		
		BuilderConditions = {

			{ UCBC, 'PoolLess', { 24, categories.DIRECTFIRE * categories.LAND }},
			
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND - categories.TECH1 }},			

		},
		
		BuilderType = {'LandT1'},
		
    },	

    Builder {BuilderName = 'T1 Mobile AA - Large Map',
	
        PlatoonTemplate = 'T1LandAA',
        Priority = 550,
		
		PriorityFunction = First30Minutes,

        BuilderConditions = {

			{ UCBC, 'PoolLess', { 8, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
			
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
		
			-- only on 5k-20k maps
			{ MIBC, 'MapLessThan', { 1028 } },
			
			-- turn off as soon as we have a T2/T3 land factory
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND - categories.TECH1 }},
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
			
        },
		
        BuilderType = {'LandT1'},
		
    },
	
	-- Tech 2 - Shield/Stealth Vehicles	-- starts when there are 2+ T2/T3 factories
	-- stops when there is are 1+ T3 land factory and replaced by Tech 3 version
    Builder {BuilderName = 'T2 Mobile Shield - UEF',
	
        PlatoonTemplate = 'T2MobileShields',
		FactionIndex = 1,
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 15, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'FactoriesGreaterThan', { 1, categories.LAND - categories.TECH1 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND * categories.TECH2 }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },
	
    Builder {BuilderName = 'T2 Mobile Shield - Aeon',
	
        PlatoonTemplate = 'T2MobileShields',
		FactionIndex = 2,
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 15, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'FactoriesGreaterThan', { 1, categories.LAND - categories.TECH1 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },
	
    Builder {BuilderName = 'T2 Mobile Stealth - Cybran',
	
        PlatoonTemplate = 'T2MobileShields',
		FactionIndex = 3,
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'FactoriesGreaterThan', { 1, categories.LAND - categories.TECH1 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 8, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
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
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},
			
			{ UCBC, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
			
        },
		
        BuilderType = {'LandT3'},
		
    },
	
    Builder {BuilderName = 'T3 Mobile Shields - AEON',
	
        PlatoonTemplate = 'T3MobileShields',
		FactionIndex = 2,
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},
			
			{ UCBC, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
			
        },
		
        BuilderType = {'LandT3'},
		
    },
	
    Builder {BuilderName = 'T3 Mobile Stealth - CYBRAN',
	
        PlatoonTemplate = 'T3MobileShields',
		FactionIndex = 3,
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},
			
			{ UCBC, 'PoolLess', { 8, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE }},
			
        },
		
        BuilderType = {'LandT3'},
		
    },
	
    Builder {BuilderName = 'T3 Mobile Shields - SERA',
	
        PlatoonTemplate = 'T3MobileShields',
		FactionIndex = 4,
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},
			
			{ UCBC, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
			
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


BuilderGroup {BuilderGroupName = 'Land Builders - Land Map',
    BuildersType = 'FactoryBuilder',
	
    Builder {BuilderName = 'T1 Tanks',
	
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 550,
		
		PriorityFunction = First45Minutes,

        BuilderConditions = {},
		
        BuilderType = {'LandT1','LandT2'},
		
    },

    Builder {BuilderName = 'T1 Mobile Artillery',
	
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 550,
		
		PriorityFunction = First45Minutes,

        BuilderConditions = {
		
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.INDIRECTFIRE * categories.MOBILE }},
			
        },
		
        BuilderType = {'LandT1'},
		
    },

	-- T2 Flak Vehicle 
    Builder {BuilderName = 'T2 Mobile Flak',
	
        PlatoonTemplate = 'T2LandAA',
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1, categories.LAND }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },	
	
    -- Tech 2 DirectFire Tank
    Builder {BuilderName = 'T2 Tank',
	
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH2, categories.LAND - categories.TECH1 }},
			
        },
		
        BuilderType = {'LandT2','LandT3'},
		
    },

    -- Tech 2 Attack Tank - 
    Builder {BuilderName = 'T2 Attack Tank',
	
        PlatoonTemplate = 'T2AttackTank',
        Priority = 550,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND - categories.TECH1 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH2, categories.LAND - categories.TECH1 }},
			
        },
		
        BuilderType = {'LandT2','LandT3'},
		
    },
	
	-- Tech 2 Artillery
    Builder {BuilderName = 'T2 Artillery',
	
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.INDIRECTFIRE * categories.MOBILE * categories.TECH2, categories.LAND * categories.TECH2 }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },

	-- T3 Assault Bots
    Builder {BuilderName = 'T3 Armored Assault',
	
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH3, (categories.LAND * categories.TECH3) + categories.GATE }},
			
        },
		
        BuilderType =  {'LandT3','Gate'},	-- this allows Gates to make them as well
		
    },

	-- T3 Mobile AA
    Builder {BuilderName = 'T3 Mobile AA',
	
        PlatoonTemplate = 'T3LandAA',
        Priority = 600, 
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.TECH3 }},
			
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 32, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},
			
        },
		
        BuilderType = {'LandT3','Gate'},
		
    },
	
    -- T3 Tank - non amphibious T3 Land Units
    Builder {BuilderName = 'Siege Assault Bot T3',
	
        PlatoonTemplate = 'T3LandBot',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ UCBC, 'FactoriesGreaterThan', { 1, categories.LAND * categories.TECH3 }},
			
        },
		
        BuilderType =  {'LandT3','Gate'},	-- this allows Gates to make them as well
		
    },
	
    -- T3 Mobile Artillery 
    Builder {BuilderName = 'Mobile Artillery T3',
	
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },
			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 30, categories.LAND * categories.MOBILE * categories.ARTILLERY * categories.TECH3 }},
 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ARTILLERY * categories.TECH3, categories.LAND * categories.TECH3 }},
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 14, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE * categories.TECH3 }},
			
        },
		
        BuilderType = {'LandT3'},
		
    },
	
	-- T3 MML - UEF Only
    Builder {BuilderName = 'Mobile Missile T3',
	
        PlatoonTemplate = 'T3MobileMissile',
		FactionIndex = 1,
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1.1 } },
			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 30, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.xel0306, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 14, categories.xel0306 }},
			
        },
		
        BuilderType = {'LandT3'},
		
    },
	
}


BuilderGroup {BuilderGroupName = 'Land Builders - Water Map',
    BuildersType = 'FactoryBuilder',
	
    Builder {BuilderName = 'T1 Tanks - Water',
	
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 550,
		
		PriorityFunction = First45Minutes,

        BuilderConditions = {
		
			{ UCBC, 'PoolLess', { 24, categories.DIRECTFIRE * categories.LAND }},
			
		},
		
        BuilderType = {'LandT1'},
		
    },

	-- Tech 1 Arty - only 30 minutes on water maps
    Builder {BuilderName = 'T1 Mobile Artillery - Water',
	
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 550,
		
		PriorityFunction = First30Minutes,

        BuilderConditions = {
		
			{ UCBC, 'PoolLess', { 8, categories.INDIRECTFIRE * categories.MOBILE }},
			
        },
		
        BuilderType = {'LandT1'},
		
    },

    -- Tech 2 Amphibious Tank
    Builder {BuilderName = 'T2 Amphibious Tank',
	
        PlatoonTemplate = 'T2LandAmphibTank',
        Priority = 551,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
            { UCBC, 'PoolLess', { 48, categories.DIRECTFIRE * categories.AMPHIBIOUS * categories.LAND }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 4, categories.DIRECTFIRE * categories.AMPHIBIOUS * categories.TECH2, categories.LAND }},
			
        },
		
        BuilderType = {'LandT2','LandT3'},
		
    },
	
	-- T2 Amphibious AA 
    Builder {BuilderName = 'T2 Amphibious AA',
	
        PlatoonTemplate = 'T2LandAmphibAA',
        Priority = 551,
		
        BuilderConditions = {

            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 16, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.LAND }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },
	
	-- T2 Amphibious Shield - Aeon Only
    Builder {BuilderName = 'T2 Mobile Amphibious Shield - Aeon',
	
        PlatoonTemplate = 'T2MobileShields',
		FactionIndex = 2,
        Priority = 551,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 15, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'FactoriesGreaterThan', { 1, categories.LAND - categories.TECH1 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'PoolLess', { 10, categories.LAND * categories.MOBILE * categories.SHIELD }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SHIELD, categories.LAND }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },
	
    -- Tech 2 DirectFire Tank -- limited output on water maps
    Builder {BuilderName = 'T2 Tank - Water',
	
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ UCBC, 'PoolLess', { 28, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.TECH1 }},

			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND - categories.TECH1 }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS), categories.LAND }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },

    -- Tech 2 Attack Tank -- limited output on water maps
    Builder {BuilderName = 'T2 Attack Tank - Water',
	
        PlatoonTemplate = 'T2AttackTank',
        Priority = 550,

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ UCBC, 'PoolLess', { 28, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.TECH1 }},

			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND - categories.TECH1 }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS), categories.LAND }},
			
        },
		
        BuilderType = {'LandT2'},
		
    },
	
	-- Tech 2 Artillery	-- limited output on water maps
    Builder {BuilderName = 'T2 Artillery - Water',
	
        PlatoonTemplate = 'T2LandArtilleryWaterMap',
        Priority = 550,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
			{ UCBC, 'PoolLess', { 20, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.AMPHIBIOUS }},

			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND - categories.TECH1 }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.INDIRECTFIRE * categories.MOBILE, categories.LAND }},
			
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
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 4, categories.LAND * categories.AMPHIBIOUS * categories.DIRECTFIRE }},
			
        },
		
        BuilderType = {'LandT3','Gate'},
		
    },	
	
	-- T3 Amphibious AA
    Builder {BuilderName = 'T3 Amphibious AA',
	
        PlatoonTemplate = 'T3AmphibiousAA',
        Priority = 600, 
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 30, categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.TECH1 }},
			
			{ UCBC, 'FactoriesGreaterThan', { 2, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.LAND * categories.TECH3 }},
		
        },
		
        BuilderType = {'LandT3'},
		
    },
	
	-- T3 NON-AMPHIB Production --
	-- begins only when there are 4 T3 factories --
	
    -- T3 non amphibious Land Units
    Builder {BuilderName = 'Siege Assault Bot T3 - Water',
	
        PlatoonTemplate = 'T3LandBot',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			
			{ UCBC, 'PoolLess', { 48, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.TECH1 }},
			
			{ UCBC, 'FactoriesGreaterThan', { 3, categories.LAND * categories.TECH3 }},
 			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS), categories.LAND * categories.TECH3 }},			
			
        },
		
        BuilderType =  {'LandT3'},
		
    },

	-- T3 Mobile Artillery
    Builder {BuilderName = 'T3 Mobile Artillery - Water',
	
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },			
			
			{ UCBC, 'PoolLess', { 28, categories.LAND * categories.MOBILE * categories.ARTILLERY - categories.TECH1 }},			

			{ UCBC, 'FactoriesGreaterThan', { 3, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.LAND * categories.MOBILE * categories.ARTILLERY), categories.LAND * categories.TECH3 }},

        },
		
        BuilderType = {'LandT3'},
		
    },
	
	-- T3 Mobile Missile -- UEF only --
    Builder {BuilderName = 'T3 Mobile Missile - Water',
	
        PlatoonTemplate = 'T3MobileMissile',
		FactionIndex = 1,
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'LandStrengthRatioLessThan', { 6 } },
			
			{ UCBC, 'PoolLess', { 24, categories.xel0306 }},

			{ UCBC, 'FactoriesGreaterThan', { 3, categories.LAND * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xel0306, categories.LAND * categories.TECH3 }},
			
        },
		
        BuilderType = {'LandT3'},
		
    },
	
}