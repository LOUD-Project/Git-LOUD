-- Loud_AI_Factory_Air_Builders.lua
-- factory production of all air units

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local TUTL = '/lua/ai/transportutilities.lua'

local LOUDGETN = table.getn
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits


-- imbedded into the Builder
local First45Minutes = function( self, aiBrain )
	
	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
    
    if self.Priority > 0 then 
        return self.Priority,true
    else
        return 0, false
    end
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function( self, aiBrain, manager )

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .01 and aiBrain.NavalRatio < 10) then
        --LOG("*AI DEBUG "..aiBrain.Nickname.." enemy naval is active at "..repr(aiBrain.NavalRatio))
		return 600, true

	end

	return 10, true
	
end

-- this function will turn a builder off if the enemy is not active in the air
local IsEnemyAirActive = function(self,aiBrain,manager)

	if aiBrain.AirRatio and (aiBrain.AirRatio > .01 and aiBrain.AirRatio < 10) then
	
		return 600, true

	end

	return 10, true
	
end

local HaveLessThanThreeT2AirFactory = function( self, aiBrain )
	
	-- remove by game time --
	if aiBrain.CycleTime >  2700 then
		
		return 0, false
		
	end
	
	if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * categories.AIR - categories.TECH1, false, true )) < 3 then
	
		return 600, true
		
	end

	
	return 0, false
	
end

local HaveLessThanThreeT3AirFactory = function( self, aiBrain )

	if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * categories.AIR * categories.TECH3, false, true )) < 3 then
	
		return 600, true
		
	end

	return 0, false
	
end

-- The simple idea here is that fighters are always produced if the air ratio is less than 10
-- Scout planes are always produced - controlled by map size ratio and number of factories producing
-- Bomber and Gunships are only produced if air ratio is greater than 2

-- T1 is produced while there is less than 4 T2/T3 Air Factories overall
-- T2 is produced as long as there are T2 factories
-- T2 is produced while there are less than 3 T3 Air Factories

-- ALL AIR BUILDERS SIT AT 600 PRIORITY except for highneed transports
-- usually controlled by air ratio and number of factories producing that unit

-- T1 - T2 Bombers were not controlled by the Air Ratio. 
-- Fighters will now always be produced if we're below a 1.0 Air Ratio.

BuilderGroup {BuilderGroupName = 'Factory Production - Air',
    BuildersType = 'FactoryBuilder',
	
    Builder {BuilderName = 'Air Scout T1 - Initial',
	
        PlatoonTemplate = 'T1AirScout',
        
        PlatoonAddFunctions = { { LUTL, 'UseBuilderOnce' }, },

        Priority = 610,
        
        PriorityFunction = First45Minutes, 

        BuilderConditions = {
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.SCOUT } },
        },

        BuilderType =  {'AirT1'},
    },
	
    Builder {BuilderName = 'Air Scout T1',
	
        PlatoonTemplate = 'T1AirScout',
        
        Priority = 600,
        
        PriorityFunction = First45Minutes, 

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .65 } },

            -- don't build T1 air scouts if we can build better ones
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, categories.AIR - categories.TECH1 }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 8, [512] = 12, [1024] = 18, [2048] = 20, [4096] = 20}, categories.AIR * categories.SCOUT}},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.AIR * categories.SCOUT } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT, categories.AIR }},
        },

        BuilderType =  {'AirT1'},
    },
	
    Builder {BuilderName = 'Air Scout T2',
	
        PlatoonTemplate = 'T2AirScout',

        Priority = 600,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 24, [512] = 36, [1024] = 60, [2048] = 78, [4096] = 78}, categories.AIR * categories.SCOUT}},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.AIR * categories.SCOUT } },			

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.AIR * categories.SCOUT, categories.AIR }},
        },

        BuilderType =  {'AirT2'},
    },

    Builder {BuilderName = 'Air Scout T3',
	
        PlatoonTemplate = 'T3AirScout',
        
        Priority = 600,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 24, [512] = 36, [1024] = 60, [2048] = 78, [4096] = 78}, categories.AIR * categories.SCOUT}},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 12, categories.AIR * categories.SCOUT } },			

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.AIR * categories.SCOUT, categories.AIR * categories.TECH3 }},
        },

        BuilderType =  {'AirT3'},
    },

	
	Builder {BuilderName = 'Bomber T1',
	
        PlatoonTemplate = 'T1Bomber',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
            
			-- stop making them if enemy has T2 AA of any kind
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ANTIAIR - categories.TECH1, 'Enemy' }},
        },
		
        BuilderType =  {'AirT1','AirT2'},
    },
	
    Builder {BuilderName = 'Fighters T1',
	
        PlatoonTemplate = 'T1Fighter',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 4.5 } },
            
			-- stop making them if enemy has T2 AA of any kind
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ANTIAIR - categories.TECH1, 'Enemy' }},
        },
		
        BuilderType =  {'AirT1','AirT2'},
    },
	
    Builder {BuilderName = 'Bomber T2',
	
        PlatoonTemplate = 'T2Bomber',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },
	
    Builder {BuilderName = 'Fighters T2',
	
        PlatoonTemplate = 'T2Fighter',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 4.5 } },
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },

    Builder {BuilderName = 'Gunship T2',
	
        PlatoonTemplate = 'T2Gunship',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

            { LUTL, 'UnitCapCheckLess', { .85 } },
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },
	
    Builder {BuilderName = 'Bomber T3',
	
        PlatoonTemplate = 'T3Bomber',

        Priority = 600,
        
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
        },
		
        BuilderType =  {'AirT3'},
    },
    
    Builder {BuilderName = 'Fighters T3',
	
        PlatoonTemplate = 'T3Fighter',

        Priority = 600,
		
		PriorityFunction = IsEnemyAirActive,

        BuilderConditions = {
            { LUTL, 'HaveLessThanUnitsWithCategory', { 120, categories.HIGHALTAIR * categories.ANTIAIR }},

			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR * categories.TECH3 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.HIGHALTAIR * categories.ANTIAIR, categories.AIR * categories.TECH3 }},			
        },

        BuilderType =  {'AirT3'},
    },

    Builder {BuilderName = 'Gunship T3',
	
        PlatoonTemplate = 'T3Gunship',

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
        },

        BuilderType =  {'AirT3'},
    },
}

-- Torpedo Bombers have been problematic
-- Just being a water map isn't enough reason to build them - there needs to be a threat
-- AND importantly, it should only become an issue if the AI is actually playing on the water
-- When I see an AI with no Naval position building Torpedo Bombers I get disturbed especially
-- if his partners are in the water and he isn't - there are legitimate reasons to do this, but we
-- need to control them carefully
BuilderGroup {BuilderGroupName = 'Factory Production - Torpedo Bombers',
    BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Torpedo Bomber T2',
	
        PlatoonTemplate = 'T2TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
            
			-- dont start production until you have at least 2+ T2/T3 factories at location
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR - categories.TECH1 }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, categories.ANTINAVY * categories.AIR }},
        },

        BuilderType =  {'AirT2','SeaT2'},
    },

    Builder {BuilderName = 'Torpedo Bomber T3',
	
        PlatoonTemplate = 'T3TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

			-- dont produce unless you have 3+ T3 Air factories overall
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR * categories.TECH3 }},

			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, categories.ANTINAVY * categories.AIR }},
        },

        BuilderType =  {'AirT3','SeaT3'},
    },

    -- Increased opportunity for Torpedo Bombers when Naval is active but low
    Builder {BuilderName = 'Torpedo Bomber T2 - Response',
	
        PlatoonTemplate = 'T2TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 3 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1.2 } }, 

            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			-- dont start production until you have at least 2+ T2/T3 factories at location
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, categories.ANTINAVY * categories.AIR }},            
        },

        BuilderType =  {'AirT2','SeaT2'},
    },

    Builder {BuilderName = 'Torpedo Bomber T3 - Response',
	
        PlatoonTemplate = 'T3TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 3 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1.2 } },

            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			-- dont produce unless you have 3+ T3 Air factories overall
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR * categories.TECH3 }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, categories.ANTINAVY * categories.AIR }},            
        },
		
        BuilderType =  {'AirT3','SeaT3'},
    },    
}

BuilderGroup {BuilderGroupName = 'Factory Production - Transports',
    BuildersType = 'FactoryBuilder',
	
	-- I recently expanded the transports that engineers can use to include T2
	-- This makes the use of T1 transports redundant once we can build T2
	-- so T1 transports are only made when there are less than 2 T2/T3 air factories
--[[
    Builder {BuilderName = 'Air Transport T1 - Initial',
	
        PlatoonTemplate = 'T1AirTransport',

        PlatoonAddFunctions = { { LUTL, 'UseBuilderOnce' }, {TUTL, 'ResetBrainNeedsTransport'}, },

        Priority = 610, 

		PriorityFunction = First45Minutes,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

            { UCBC, 'ArmyNeedsTransports', { true } },
        },

        BuilderType =  {'AirT1'},
    },
--]]
    Builder {BuilderName = 'Air Transport T1 - Standard',
	
        PlatoonTemplate = 'T1AirTransport',
		
        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },		
	
        Priority = 600, 
		
		PriorityFunction = First45Minutes,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

            { UCBC, 'ArmyNeedsTransports', { true } },

			-- stop making them if enemy has T2 AA of any kind
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ANTIAIR - categories.TECH1, 'Enemy' }},
			
			-- stop making them if we have more than 2 T2/T3 air plants - anywhere
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR - categories.TECH1 }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 2, [512] = 2, [1024] = 4, [2048] = 5, [4096] = 5}, categories.TRANSPORTFOCUS * categories.TECH1}},
        },

        BuilderType =  {'AirT1'},
    },

	-- always maintain the base number of T2 transports (since engineers won't use T3 transports)
    Builder {BuilderName = 'Air Transport T2',
	
        PlatoonTemplate = 'T2AirTransport',

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

			{ UCBC, 'HaveLessThanUnitsForMapSize', { { [256] = 1, [512] = 2, [1024] = 3, [2048] = 6, [4096] = 8 }, categories.TRANSPORTFOCUS * categories.TECH2}},

			-- note -- this condition - unlike the T3 condition - counts ONLY traditional T2 transports --
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK, categories.AIR - categories.TECH1 }},
        },

        BuilderType =  {'AirT2','AirT3'},
    },
	
    Builder {BuilderName = 'Air Transport T2 - HighNeed',
	
        PlatoonTemplate = 'T2AirTransport',
		
        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },
		
        Priority = 610,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .75 } },
            
            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK, categories.AIR - categories.TECH1 }},
        },
		
        BuilderType =  {'AirT2'},
    },
	
	-- stop construction of T2 Gunships (for transport) once we have the ability to build T3
    Builder {BuilderName = 'UEF Gunship Transports',
	
        PlatoonTemplate = 'T2Gunship',
		
		FactionIndex = 1,
		
        Priority = 600,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		

            { LUTL, 'UnitCapCheckLess', { .75 } },

            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.uea0203 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.uea0203, categories.AIR - categories.TECH1 }},
        },
		
        BuilderType =  {'AirT2'},
    },

    Builder {BuilderName = 'Air Transport T3',
	
        PlatoonTemplate = 'T3AirTransport',
		
        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

            { UCBC, 'ArmyNeedsTransports', { true } },

			-- is someone else is building a transport --
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK, categories.AIR * categories.TECH3 }},

			-- note -- this condition counts ALL T2, T3 and T4 transports --
			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 3, [512] = 6, [1024] = 10, [2048] = 15, [4096] = 20}, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK}},
        },

        BuilderType =  {'AirT3'},
    },
	
    Builder {BuilderName = 'Air Transport T3 - HighNeed',
	
        PlatoonTemplate = 'T3AirTransport',

        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },

        Priority = 610,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

            { UCBC, 'ArmyNeedsTransports', { true } },

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK, categories.AIR * categories.TECH3 }},
        },

        BuilderType =  {'AirT3'},
    },
}



