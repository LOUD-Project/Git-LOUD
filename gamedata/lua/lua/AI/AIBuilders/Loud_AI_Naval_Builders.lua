-- Loud_AI_Naval_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function(self,aiBrain,manager)

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .01 and aiBrain.NavalRatio < 6) then
	
		return 560, true	-- standard naval priority -- 

	end

	return 10, true
	
end


BuilderGroup { BuilderGroupName = 'Sea Builders',
    BuildersType = 'FactoryBuilder',
	
	-- you'll notice the high priority on T1 subs and frigates -- this will keep them producing frequently thru the game or 
	-- until the priority function shuts them down (T1 subs)
	Builder {BuilderName = 'T1 Sub',
	
        PlatoonTemplate = 'T1SeaSub',
		
        Priority = 600,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain)
		
			if aiBrain.CycleTime > 2700 then
				return 0, false
			end
			
			return 600,true
			
		end,
		
        BuilderType = {'SeaT1'},
		
        BuilderConditions = {
		
			{ UCBC, 'PoolLess', { 8, categories.SUBMARINE } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL }},			
			
        },
    },

    Builder {BuilderName = 'T1 Frigate',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 600,
		
        BuilderType = {'SeaT1','SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 8, categories.FRIGATE } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.FRIGATE, categories.NAVAL }},
			
        },
		
    },
	
    Builder {BuilderName = 'T1 Naval Anti-Air - AEON',
	
        PlatoonTemplate = 'T1SeaAntiAir',
		
		FactionIndex = 2,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderType = {'SeaT1','SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 16, categories.DEFENSIVEBOAT } },

			{ LUTL, 'HaveLessThanUnitsWithCategory', { 45, categories.DEFENSIVEBOAT } },
	
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.DEFENSIVEBOAT, categories.NAVAL }},			
			
        },
		
    },

    Builder {BuilderName = 'Destroyer',
	
        PlatoonTemplate = 'T2SeaDestroyer',
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 8, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DESTROYER, categories.NAVAL - categories.TECH1 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Cruiser',
	
        PlatoonTemplate = 'T2SeaCruiser',
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 8, categories.CRUISER } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CRUISER, categories.NAVAL - categories.TECH1 }},
			
        },
		
    },
	
    Builder {BuilderName = 'T2 Sub - UEF',	-- UEF Torpedo Boat
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 1,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 12, categories.xes0102 } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xes0102, categories.NAVAL - categories.TECH1 }},			
        },
		
    },
	
    Builder {BuilderName = 'T2 Sub - Aeon',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 2,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 12, categories.SUBMARINE } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
			
        },
		
    },

	-- since the Cybrans and Sera might have T3 subs their base requirement is lower here
	-- and would be superceded by the T3 submarine definition
	-- essentially once they have their minimum number of subs they would only build T3
    Builder {BuilderName = 'T2 Sub - Cybran',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 3,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 12, categories.SUBMARINE } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },
		
    },

    Builder {BuilderName = 'T2 Sub - Sera',	-- T1 Submarine - no T2 sub for sera
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 4,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 12, categories.SUBMARINE } },			
		
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },

    },

    Builder {BuilderName = 'Shield Boat - UEF',
	
        PlatoonTemplate = 'T2ShieldBoat',
		
		FactionIndex = 1,
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },			

			{ UCBC, 'PoolLess', { 8, categories.xes0205 }},
			
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Counter Intel Boat - Cybran',
	
        PlatoonTemplate = 'T2CounterIntelBoat',
		
		FactionIndex = 3,
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			
			{ UCBC, 'PoolLess', { 8, categories.xrs0205 }},			
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.xrs0205 }},
			
        },
		
    },

    Builder {BuilderName = 'Battleship',
	
        PlatoonTemplate = 'T3SeaBattleship',
		
        Priority = 560,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 4, categories.BATTLESHIP - categories.xas0306 }},			
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.BATTLESHIP - categories.xas0306, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },

    Builder {BuilderName = 'Battlecruiser - UEF',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 1,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Missile Cruiser - Aeon',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 2,
		
        Priority = 560,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.NAVAL * categories.TECH3 * categories.CRUISER }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Escort Cruiser - Cybran',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 3,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Heavy Cruiser - Sera',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 4,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Carrier - Aeon',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 2,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLess', { 2, categories.CARRIER * categories.NAVAL }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Carrier - Cybran',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 3,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 560,

		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLess', { 2, categories.CARRIER * categories.NAVAL }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Carrier - Sera',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 4,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLess', { 2, categories.CARRIER * categories.NAVAL }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },

    Builder {BuilderName = 'Nuke Sub - UEF',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 1,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Nuke Sub - Aeon',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 2,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Nuke Sub - Cybran',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 3,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
	Builder {BuilderName = 'T3 Assault Sub - Cybran',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 3,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 24, categories.SUBMARINE }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
			
        },
		
    },
	
	Builder {BuilderName = 'T3 SubKiller - Sera',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 4,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 24, categories.SUBMARINE }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
			
        },
		
    },
	
}

BuilderGroup { BuilderGroupName = 'Sea Builders - Small',
    BuildersType = 'FactoryBuilder',
	
	-- you'll notice the high priority on T1 subs and frigates -- this will keep them producing frequently thru the game or 
	-- until the priority function shuts them down (T1 subs)
	Builder {BuilderName = 'T1 Sub - Small',
	
        PlatoonTemplate = 'T1SeaSub',
		
        Priority = 600,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain)
		
			if aiBrain.CycleTime > 2700 then
				return 0, false
			end
			
			return 600,true
			
		end,
		
        BuilderType = {'SeaT1'},
		
        BuilderConditions = {
		
			{ UCBC, 'PoolLess', { 6, categories.SUBMARINE } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL }},			
			
        },
    },

    Builder {BuilderName = 'T1 Frigate - Small',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 600,
		
        BuilderType = {'SeaT1','SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', {  6, categories.FRIGATE } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.FRIGATE, categories.NAVAL }},
			
        },
		
    },
	
    Builder {BuilderName = 'T1 Naval Anti-Air - AEON - Small',
	
        PlatoonTemplate = 'T1SeaAntiAir',
		
		FactionIndex = 2,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT1','SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 12, categories.DEFENSIVEBOAT } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.DEFENSIVEBOAT, categories.NAVAL }},			
			
        },
		
    },

    Builder {BuilderName = 'Destroyer - Small',
	
        PlatoonTemplate = 'T2SeaDestroyer',
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 6, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DESTROYER, categories.NAVAL - categories.TECH1 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Cruiser - Small',
	
        PlatoonTemplate = 'T2SeaCruiser',
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 6, categories.CRUISER } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CRUISER, categories.NAVAL - categories.TECH1 }},
			
        },
		
    },
	
    Builder {BuilderName = 'T2 Sub - UEF - Small',	-- UEF Torpedo Boat
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 1,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 12, categories.xes0102 } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xes0102, categories.NAVAL - categories.TECH1 }},			
        },
		
    },
	
    Builder {BuilderName = 'T2 Sub - Aeon - Small',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 2,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 10, categories.SUBMARINE } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
			
        },
		
    },

	-- since the Cybrans and Sera might have T3 subs their base requirement is lower here
	-- and would be superceded by the T3 submarine definition
	-- essentially once they have their minimum number of subs they would only build T3
    Builder {BuilderName = 'T2 Sub - Cybran - Small',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 3,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 8, categories.SUBMARINE } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },
		
    },

    Builder {BuilderName = 'T2 Sub - Sera - Small',	-- T1 Submarine - no T2 sub for sera
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 4,
		
        Priority = 560,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 8, categories.SUBMARINE } },			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },

    },

    Builder {BuilderName = 'Shield Boat - UEF - Small',
	
        PlatoonTemplate = 'T2ShieldBoat',
		
		FactionIndex = 1,
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },			

			{ UCBC, 'PoolLess', { 6, categories.xes0205 }},
			
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Counter Intel Boat - Cybran - Small',
	
        PlatoonTemplate = 'T2CounterIntelBoat',
		
		FactionIndex = 3,
		
        Priority = 560,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },
			
			{ UCBC, 'PoolLess', { 6, categories.xrs0205 }},			
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.xrs0205 }},
			
        },
		
    },

    Builder {BuilderName = 'Battleship - Small',
	
        PlatoonTemplate = 'T3SeaBattleship',
		
        Priority = 560,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 3, categories.BATTLESHIP - categories.xas0306 }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.BATTLESHIP - categories.xas0306, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },

    Builder {BuilderName = 'Battlecruiser - UEF - Small',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 1,
		
        Priority = 560,

		PriorityFunction = IsEnemyNavalActive,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 5, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Missile Cruiser - Aeon - Small',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 2,
		
        Priority = 560,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 5, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Escort Cruiser - Cybran - Small',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 3,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 5, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Heavy Cruiser - Sera - Small',
	
        PlatoonTemplate = 'T3Battlecruiser',
		
		FactionIndex = 4,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'PoolLess', { 5, categories.NAVAL * categories.TECH3 * categories.CRUISER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Carrier - Aeon - Small',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 2,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLess', { 1, categories.CARRIER * categories.NAVAL }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Carrier - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 3,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLess', { 1, categories.CARRIER * categories.NAVAL }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Carrier - Sera - Small',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 4,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLess', { 1, categories.CARRIER * categories.NAVAL }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },

    Builder {BuilderName = 'Nuke Sub - UEF - Small',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 1,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Nuke Sub - Aeon - Small',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 2,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
    Builder {BuilderName = 'Nuke Sub - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 3,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
			
        },
		
    },
	
	Builder {BuilderName = 'T3 Assault Sub - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 3,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 16, categories.SUBMARINE }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
			
        },
		
    },
	
	Builder {BuilderName = 'T3 SubKiller - Sera - Small',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 4,
		
        Priority = 560,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'PoolLess', { 16, categories.SUBMARINE }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
			
        },
		
    },
	
}

