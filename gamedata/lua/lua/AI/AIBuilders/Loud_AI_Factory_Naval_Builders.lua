-- Loud_AI_Factory_Naval_Builders.lua
-- factory production of all naval units

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
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

local AboveUnitCap95 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function(self,aiBrain,manager)

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .011 and aiBrain.NavalRatio <= 10) then
	
		return self.OldPriority or self.Priority, true	-- standard naval priority -- 

	end

	return 10, true
	
end


BuilderGroup { BuilderGroupName = 'Factory Production - Naval',
    BuildersType = 'FactoryBuilder',
	
	-- you'll notice the high priority on T1 subs and frigates -- this will keep them producing frequently thru the game or 
	-- until the priority function shuts them down (T1 subs)
	Builder {BuilderName = 'T1 Sub',
	
        PlatoonTemplate = 'T1SeaSub',
		
        Priority = 610,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain)
		
			if aiBrain.CycleTime > 2100 then
				return 0, false
			end
			
			return self.Priority,true
			
		end,
		
        BuilderType = {'SeaT1'},
		
        BuilderConditions = {
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.SUBMARINE } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL }},			
        },
    },

    Builder {BuilderName = 'T1 Frigate',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT1','SeaT2'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },
            
            { LUTL, 'PoolLess', { 32, categories.FRIGATE }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.FRIGATE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.FRIGATE, categories.NAVAL }},
        },
    },

    -- this will provide some frigate production even if the enemy is not in the water
    Builder {BuilderName = 'T1 Frigate - High Strength',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT1','SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioGreaterThan', { 6 } },
            
            { LUTL, 'PoolLess', { 6, categories.FRIGATE }},
        },
    },

    Builder {BuilderName = 'T1 Frigate at T3 factory',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },
            
            { LUTL, 'PoolLess', { 32, categories.FRIGATE }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.FRIGATE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.FRIGATE, categories.NAVAL }},
        },
    },
	
    Builder {BuilderName = 'T1 Naval Anti-Air - AEON',
	
        PlatoonTemplate = 'T1SeaAntiAir',
		
		FactionIndex = 2,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap70,
		
        BuilderType = {'SeaT1'},

        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'PoolLess', { 24, categories.DEFENSIVEBOAT } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.DEFENSIVEBOAT } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.DEFENSIVEBOAT, categories.NAVAL }},
        },
    },

    Builder {BuilderName = 'Destroyer',
	
        PlatoonTemplate = 'T2SeaDestroyer',
		
        Priority = 600,
		
		PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'PoolLess', { 20, categories.DESTROYER }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.DESTROYER, categories.NAVAL - categories.TECH1 }},
        },
    },

    Builder {BuilderName = 'Destroyer - High Strength',
	
        PlatoonTemplate = 'T2SeaDestroyer',
		
        Priority = 600,
		
		PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioGreaterThan', { 6 } },
            
            { UCBC, 'PoolGreater', { 5, categories.FRIGATE }},
            
            { UCBC, 'PoolGreater', { 7, categories.SUBMARINE }},

            { LUTL, 'PoolLess', { 6, categories.DESTROYER }},
        },
    },
	
    Builder {BuilderName = 'Cruiser',
	
        PlatoonTemplate = 'T2SeaCruiser',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },        

            { LUTL, 'PoolLess', { 20, categories.CRUISER }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.CRUISER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.CRUISER, categories.NAVAL - categories.TECH1 }},
        },
    },
	
    Builder {BuilderName = 'Cruiser - High Strength',
	
        PlatoonTemplate = 'T2SeaCruiser',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioGreaterThan', { 6 } },        
            
            { UCBC, 'PoolGreater', { 5, categories.FRIGATE }},
            
            { UCBC, 'PoolGreater', { 7, categories.SUBMARINE }},

            { LUTL, 'PoolLess', { 6, categories.CRUISER }},
        },
    },
		
    Builder {BuilderName = 'T2 Sub - UEF',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 1,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'PoolLess', { 24, (categories.SUBMARINE + categories.xes0102) }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 16, (categories.SUBMARINE + categories.xes0102) }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, (categories.SUBMARINE + categories.xes0102), categories.NAVAL - categories.TECH1 }},
        },
    },
	
    Builder {BuilderName = 'T2 Sub - Aeon',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 2,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'PoolLess', { 24, categories.SUBMARINE }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 16, categories.SUBMARINE }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
        },
    },

	-- since the Cybrans and Sera might have T3 subs their base requirement is lower here
	-- and would be superceded by the T3 submarine definition
	-- essentially once they have their minimum number of subs they would only build T3
    Builder {BuilderName = 'T2 Sub - Cybran',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 3,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'PoolLess', { 24, categories.SUBMARINE }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.SUBMARINE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
        },
    },

    Builder {BuilderName = 'T2 Sub - Sera',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 4,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'PoolLess', { 24, categories.SUBMARINE }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.SUBMARINE } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
        },
    },

    Builder {BuilderName = 'T2 Sub - High Strength',
	
        PlatoonTemplate = 'T2SeaSub',

        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioGreaterThan', { 6 } },

            { LUTL, 'PoolLess', { 8, categories.SUBMARINE }},
        },
    },

    Builder {BuilderName = 'Shield Boat - UEF',
	
        PlatoonTemplate = 'T2ShieldBoat',
		
		FactionIndex = 1,
		
        Priority = 600,

        PriorityFunction = AboveUnitCap85,

        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'PoolLess', { 12, categories.xes0205 }},
            
            { UCBC, 'PoolGreater', { 2, categories.CRUISER + categories.DESTROYER }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.xes0205 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
    },
	
    Builder {BuilderName = 'Counter Intel Boat - Cybran',

        PlatoonTemplate = 'T2CounterIntelBoat',
		
		FactionIndex = 3,
		
        Priority = 600,

        PriorityFunction = AboveUnitCap85,

        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'PoolLess', { 9, categories.xrs0205 }},
            
            { UCBC, 'PoolGreater', { 2, categories.CRUISER + categories.DESTROYER }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.xrs0205 }},
        },
    },

    Builder {BuilderName = 'Battleship',
	
        PlatoonTemplate = 'T3SeaBattleship',
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {

			{ UCBC, 'PoolLess', { 4, categories.BATTLESHIP }},
            
            { UCBC, 'PoolGreater', { 6, categories.CRUISER + categories.DESTROYER }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.BATTLESHIP, categories.NAVAL * categories.TECH3 }},
        },
    },

    -- T3 Battlecruiser class --
    Builder {BuilderName = 'Battlecruiser - UEF',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 1,
		
        Priority = 610,
		
		PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Missile Cruiser - Aeon',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 2,
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.NAVAL * categories.TECH3 * categories.CRUISER }},			
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.CRUISER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Escort Cruiser - Cybran',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 3,
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Heavy Cruiser - Sera',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 4,
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},
            
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    -- T3 Submarines
	Builder {BuilderName = 'T3 Assault Sub - Cybran',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 3,
		
        Priority = 600,
		
		PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
			
			{ UCBC, 'PoolLess', { 24, categories.SUBMARINE }},
            
            { UCBC, 'PoolGreater', { 6, categories.CRUISER + categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },
    },
	
	Builder {BuilderName = 'T3 SubKiller - Sera',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 4,
		
        Priority = 600,
		
		PriorityFunction = AboveUnitCap85,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
			
			{ UCBC, 'PoolLess', { 24, categories.SUBMARINE }},
            
            { UCBC, 'PoolGreater', { 6, categories.CRUISER + categories.DESTROYER }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },
    },

	-- all the Carriers and Nuke Subs currently suppressed
--[[
    Builder {BuilderName = 'Carrier - Aeon',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 2,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 0,
		
		PriorityFunction = IsEnemyNavalActive,		

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.CARRIER * categories.NAVAL }},
			
			--{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.CARRIER * categories.NAVAL }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Carrier - Cybran',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 3,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 0,

		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.CARRIER * categories.NAVAL }},
			
			--{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.CARRIER * categories.NAVAL }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Carrier - Sera',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 4,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 0,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.CARRIER * categories.NAVAL }},
			
			--{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.CARRIER * categories.NAVAL }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
        },
    },

    Builder {BuilderName = 'Nuke Sub - UEF',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 1,
		
        Priority = 0,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Nuke Sub - Aeon',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 2,
		
        Priority = 0,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Nuke Sub - Cybran',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 3,
		
        Priority = 0,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
        },
    },
--]]

}

BuilderGroup { BuilderGroupName = 'Factory Production - Naval - Small',
    BuildersType = 'FactoryBuilder',
	
	-- you'll notice the high priority on T1 subs and frigates -- this will keep them producing frequently thru the game or 
	-- until the priority function shuts them down (T1 subs)
	Builder {BuilderName = 'T1 Sub - Small',
	
        PlatoonTemplate = 'T1SeaSub',
		
        Priority = 610,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain)
		
			if aiBrain.CycleTime > 2700 then
				return 0, false
			end
			
			return self.Priority,true
			
		end,
		
        BuilderType = {'SeaT1'},
		
        BuilderConditions = {
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.SUBMARINE } },
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL }},			
        },
    },

    Builder {BuilderName = 'T1 Frigate - Small',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT1','SeaT2' },
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'HaveLessThanUnitsWithCategory', { 36, categories.FRIGATE * categories.NAVAL }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.FRIGATE } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.FRIGATE, categories.NAVAL }},
        },
    },

    Builder {BuilderName = 'T1 Frigate - Small - at T3 factory',
	
        PlatoonTemplate = 'T1SeaFrigate',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'HaveLessThanUnitsWithCategory', { 36, categories.FRIGATE * categories.NAVAL }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.FRIGATE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.FRIGATE, categories.NAVAL }},
        },
    },
		
    Builder {BuilderName = 'T1 Naval Anti-Air - AEON - Small',
	
        PlatoonTemplate = 'T1SeaAntiAir',
		
		FactionIndex = 2,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT1'},

        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'HaveLessThanUnitsWithCategory', { 24, categories.DEFENSIVEBOAT * categories.NAVAL } },
            
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.DEFENSIVEBOAT } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.DEFENSIVEBOAT, categories.NAVAL }},			
        },
    },

    Builder {BuilderName = 'Destroyer - Small',
	
        PlatoonTemplate = 'T2SeaDestroyer',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'HaveLessThanUnitsWithCategory', { 24, categories.DESTROYER * categories.NAVAL }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.DESTROYER }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.DESTROYER, categories.NAVAL - categories.TECH1 }},
        },
    },
	
    Builder {BuilderName = 'Cruiser - Small',
	
        PlatoonTemplate = 'T2SeaCruiser',
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
            { LUTL, 'HaveLessThanUnitsWithCategory', { 24, categories.CRUISER * categories.NAVAL }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.CRUISER } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.CRUISER, categories.NAVAL - categories.TECH1 }},
        },
    },
	
    Builder {BuilderName = 'T2 Sub - UEF - Small',	-- UEF Torpedo Boat
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 1,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 14, (categories.SUBMARINE + categories.xes0102) } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, (categories.SUBMARINE + categories.xes0102), categories.NAVAL - categories.TECH1 }},			
        },
    },
	
    Builder {BuilderName = 'T2 Sub - Aeon - Small',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 2,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 14, categories.SUBMARINE } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
        },
    },

	-- since the Cybrans and Sera might have T3 subs their base requirement is lower here
	-- and would be superceded by the T3 submarine definition
	-- essentially once they have their minimum number of subs they would only build T3
    Builder {BuilderName = 'T2 Sub - Cybran - Small',
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 3,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.SUBMARINE } },
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },
    },

    Builder {BuilderName = 'T2 Sub - Sera - Small',	-- T1 Submarine - no T2 sub for sera
	
        PlatoonTemplate = 'T2SeaSub',
		
		FactionIndex = 4,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap95,

        BuilderType = {'SeaT2','SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.SUBMARINE } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},			
        },
    },

    Builder {BuilderName = 'Shield Boat - UEF - Small',
	
        PlatoonTemplate = 'T2ShieldBoat',
		
		FactionIndex = 1,
		
        Priority = 600,
        
        PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT2','SeaT3'},

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },			

            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.xes0205 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
            
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xes0205, categories.NAVAL - categories.TECH1 }},
        },
    },
	
    Builder {BuilderName = 'Counter Intel Boat - Cybran - Small',
	
        PlatoonTemplate = 'T2CounterIntelBoat',
		
		FactionIndex = 3,
		
        Priority = 600,
		
        BuilderType = {'SeaT2','SeaT3'},
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
			{ LUTL, 'NavalStrengthRatioGreaterThan', { .1 } },

            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.xrs0205 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.xrs0205, categories.NAVAL - categories.TECH1 }},
        },
    },

    Builder {BuilderName = 'Battleship - Small',
	
        PlatoonTemplate = 'T3SeaBattleship',
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.BATTLESHIP }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.CRUISER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.BATTLESHIP, categories.NAVAL * categories.TECH3 }},
        },
    },

    Builder {BuilderName = 'Battlecruiser - UEF - Small',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 1,
		
        Priority = 610,

		PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

            { LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.NAVAL * categories.TECH3 * categories.CRUISER }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Missile Cruiser - Aeon - Small',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 2,
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.NAVAL * categories.TECH3 * categories.CRUISER }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.CRUISER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Escort Cruiser - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 3,
		
        Priority = 610,
        
        PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },        

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Heavy Cruiser - Sera - Small',
	
        PlatoonTemplate = 'T3SeaCruiser',
		
		FactionIndex = 4,
		
        Priority = 610,
		
		PriorityFunction = AboveUnitCap95,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.NAVAL * categories.TECH3 * categories.CRUISER }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.DESTROYER }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NAVAL * categories.TECH3 * categories.CRUISER, categories.NAVAL * categories.TECH3 }},
        },
    },
	
	
	Builder {BuilderName = 'T3 Assault Sub - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 3,
		
        Priority = 600,
		
		PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 16, categories.SUBMARINE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
        },
    },
	
	Builder {BuilderName = 'T3 SubKiller - Sera - Small',
	
        PlatoonTemplate = 'T3SeaSub',
		
		FactionIndex = 4,
		
        Priority = 600,
		
		PriorityFunction = AboveUnitCap85,
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 6 } },
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 16, categories.SUBMARINE }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.SUBMARINE, categories.NAVAL - categories.TECH1 }},
        },
    },
	
	-- all Carriers and Nuke subs suppressed atm
--[[
    Builder {BuilderName = 'Carrier - Aeon - Small',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 2,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,		

        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.CARRIER * categories.NAVAL }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Carrier - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 3,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.CARRIER * categories.NAVAL }},
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Carrier - Sera - Small',
	
        PlatoonTemplate = 'T3SeaCarrier',
		
		FactionIndex = 4,
		
		--PlatoonAddBehaviors = { 'CarrierThread' },
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.BATTLESHIP }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.CARRIER * categories.NAVAL }},			

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.CARRIER * categories.NAVAL, categories.NAVAL * categories.TECH3 }},
        },
    },

    Builder {BuilderName = 'Nuke Sub - UEF - Small',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 1,
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Nuke Sub - Aeon - Small',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 2,
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
        },
    },
	
    Builder {BuilderName = 'Nuke Sub - Cybran - Small',
	
        PlatoonTemplate = 'T3SeaNukeSub',
		
		FactionIndex = 3,
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderType = {'SeaT3'},
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
			
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.NUKE }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.NUKE, categories.NAVAL * categories.TECH3 }},
        },
    },
--]]
	
}

