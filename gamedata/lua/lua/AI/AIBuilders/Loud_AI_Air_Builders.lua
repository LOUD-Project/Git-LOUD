--  File     :  /lua/ai/Loud_AI_Air_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'

-- imbedded into the Builder
local First45Minutes = function( self, aiBrain )
	
	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
	
	return self.Priority,true
end

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function( self, aiBrain, manager )

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .01 and aiBrain.NavalRatio < 6) then
	
		return 600, true

	end

	return 10, true
	
end

local HaveLessThanThreeT2AirFactory = function( self, aiBrain )
	
	-- remove by game time --
	if aiBrain.CycleTime >  2700 then
		
		return 0, false
		
	end
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR - categories.TECH1, false, true )) < 3 then
	
		return 600, true
		
	end

	
	return 0, false
	
end

local HaveLessThanThreeT3AirFactory = function( self, aiBrain )

	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR * categories.TECH3, false, true )) < 3 then
	
		return 600, true
		
	end

	return 0, false
	
end

-- The simple idea here is that fighters are always produced if the air ratio is less than 10
-- Bomber and Gunships are only produced if air ratio is greater than 2

-- T1 is produced while there is less than 4 T2/T3 Air Factories overall
-- T2 is produced as long as there are T2 factories
-- T2 is produced while there are less than 3 T3 Air Factories
BuilderGroup {BuilderGroupName = 'Air Factory Builders',
    BuildersType = 'FactoryBuilder',
	
	-- stop making when you have TECH3 air plants
    Builder {BuilderName = 'Air Scout',
	
        PlatoonTemplate = 'T1AirScout',
        Priority = 600,

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .65 } },
			
			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 6, [512] = 8, [1024] = 10, [2048] = 12, [4096] = 12}, categories.AIR * categories.SCOUT}},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.AIR * categories.SCOUT } },			
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT, categories.AIR - categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT1','AirT2'},
		
    },
	
    Builder {BuilderName = 'Spy Plane T3',
	
        PlatoonTemplate = 'T3AirScout',
        Priority = 601,

        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 12, [512] = 24, [1024] = 36, [2048] = 48, [4096] = 56}, categories.AIR * categories.SCOUT * categories.TECH3 }},
			
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.AIR * categories.SCOUT * categories.TECH3 }},			
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT, categories.AIR * categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT3'},
		
    },
	
	Builder {BuilderName = 'Bomber T1',
	
        PlatoonTemplate = 'T1Bomber',
        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
		
			-- stop making them if we have more than 3 T2/T3 air plants -- anywhere
            --{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR - categories.TECH1 }},
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
		
			-- stop making them if we have more than 3 T2/T3 air plants - anywhere
            --{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR - categories.TECH1 }},
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

			-- stop making them if we have more than 3 T3 air plants -- anywhere
			--{ LUTL, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
			-- stop making them if enemy has T3 AA of any kind
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ANTIAIR * categories.TECH3, 'Enemy' }},
			
        },
		
        BuilderType =  {'AirT2','AirT3'},
		
    },
	
    Builder {BuilderName = 'Fighters T2',
	
        PlatoonTemplate = 'T2Fighter',
        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,
		
        BuilderConditions = {
		
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR - categories.TECH1 }},
			
        },
		
        BuilderType =  {'AirT2','AirT3'},
		
    },
		
    Builder {BuilderName = 'Gunship T2',
	
        PlatoonTemplate = 'T2Gunship',
        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,

        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT2','AirT3'},
		
    },
	
    Builder {BuilderName = 'Bomber T3',
	
        PlatoonTemplate = 'T3Bomber',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR * categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT3'},
		
    },
    
    Builder {BuilderName = 'Fighters T3',
	
        PlatoonTemplate = 'T3Fighter',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioLessThan', { 10 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.AIR * categories.TECH3 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.HIGHALTAIR * categories.ANTIAIR, categories.AIR * categories.TECH3 }},			
			
        },
		
        BuilderType =  {'AirT3'},
		
    },

    Builder {BuilderName = 'Gunship T3',
	
        PlatoonTemplate = 'T3Gunship',
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .95 } },
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR * categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT3'},
		
    },

}

-- Torpedo Bombers have been problematic (ie. - generally overproduced)
-- Just being a water map isn't enough reason to build them - there needs to be a threat
-- AND importantly, it should only become an issue if the AI is actually playing on the water
-- When I see an AI with no Naval position building Torpedo Bombers I get disturbed especially
-- if his partners are in the water and he isn't
BuilderGroup {BuilderGroupName = 'Air Builders - Water Map',
    BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Torpedo Bomber T2',
	
        PlatoonTemplate = 'T2TorpedoBomber',
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {

			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			-- dont start production until you have at least 3+ T2/T3 factories at location
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, categories.FACTORY - categories.TECH1 }},
			
			-- a credible naval threat exists
			{ TBC, 'ThreatCloserThan', { 'LocationType', 1000, 50, 'Naval' }},

			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 9, categories.ANTINAVY * categories.AIR }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTINAVY * categories.AIR, categories.AIR * categories.TECH2 }},
			
        },
		
        BuilderType =  {'AirT2'},
		
    },

    Builder {BuilderName = 'Torpedo Bomber T3',
	
        PlatoonTemplate = 'T3TorpedoBomber',
		
        Priority = 600,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'UnitCapCheckLess', { .95 } },
			
			-- dont produce unless you have 3+ T3 Air factories overall
			{ LUTL, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR * categories.TECH3 }},
			
			{ TBC, 'ThreatCloserThan', { 'LocationType', 1000, 50, 'Naval' }},

			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 9, categories.ANTINAVY * categories.AIR }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTINAVY * categories.AIR, categories.AIR * categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT3'},
		
    },
}

BuilderGroup {BuilderGroupName = 'Transport Factory Builders',
    BuildersType = 'FactoryBuilder',
	
	-- I recently expanded the transports that engineers can use to include T2
	-- This makes the use of T1 transports redundant once we can build T2
	-- so T1 transports are only made when there are less than 2 T2/T3 air factories
    Builder {BuilderName = 'Air Transport T1 - Initial',
	
        PlatoonTemplate = 'T1AirTransport',
		
        Priority = 610, 
		
		PriorityFunction = First45Minutes,

        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
			-- stop making them if we have more than 3 T2/T3 air plants - anywhere
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR - categories.TECH1 }},
			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 1, [512] = 1, [1024] = 1, [2048] = 2, [4096] = 2}, categories.TRANSPORTFOCUS * categories.TECH1}},

        },
		
        BuilderType =  {'AirT1'},
		
    },
	
    Builder {BuilderName = 'Air Transport T1 - Standard',
	
        PlatoonTemplate = 'T1AirTransport',
		
        PlatoonAddFunctions = { {LUTL, 'ResetBrainNeedsTransport'}, },		
	
        Priority = 600, 
		
		PriorityFunction = First45Minutes,
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },
			
			-- stop making them if we have more than 2 T2/T3 air plants - anywhere
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.FACTORY * categories.AIR - categories.TECH1 }},
			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 2, [512] = 2, [1024] = 3, [2048] = 4, [4096] = 6}, categories.TRANSPORTFOCUS * categories.TECH1}},
			
        },
		
        BuilderType =  {'AirT1'},
		
    },
    
	-- we'll always try to maintain the base number of T2 transports (since engineers won't use T3 transports)
    Builder {BuilderName = 'Air Transport T2',
	
        PlatoonTemplate = 'T2AirTransport',
		
        PlatoonAddFunctions = { {LUTL, 'ResetBrainNeedsTransport'}, },
		
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },			

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 1, [512] = 3, [1024] = 6, [2048] = 10, [4096] = 12}, categories.TRANSPORTFOCUS * categories.TECH2}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.TRANSPORTFOCUS * categories.TECH2 - categories.GROUNDATTACK, categories.AIR - categories.TECH1 }},
        },
		
        BuilderType =  {'AirT2','AirT3'},
		
    },
	
	-- stop construction of T2 Gunships (for transport) once we have the ability to build T3
    Builder {BuilderName = 'UEF Gunship Transports',
	
        PlatoonTemplate = 'T2Gunship',
		
		FactionIndex = 1,
		
        Priority = 600,
		
        BuilderConditions = {
		
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.uea0203 }},
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.uea0203, categories.AIR - categories.TECH1 }},
        },
		
        BuilderType =  {'AirT2'},
		
    },
	
	-- stop construction of T2 Transports (for high need) once we have the ability to build T3 in some numbers
    Builder {BuilderName = 'Air Transport T2 - HighNeed',
	
        PlatoonTemplate = 'T2AirTransport',
		
        PlatoonAddFunctions = { {LUTL, 'ResetBrainNeedsTransport'}, },
		
        Priority = 610,
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .75 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.TRANSPORTFOCUS * categories.TECH2 - categories.GROUNDATTACK, categories.AIR - categories.TECH1 }},
			
        },
		
        BuilderType =  {'AirT2'},
		
    },

	-- you'll notice no rule here regarding 'armyneedstransports' - this is to insure that we are always trying to keep --
	-- the base number of T3 transports available no matter the conditions -- DEPRECATED --
	-- also notice that the check is based on Transports that are NOT Tech1 - this accounts for the situation when
	-- some factions don't have real T3 transports (like when BO Unleashed is not installed)
    Builder {BuilderName = 'Air Transport T3',
	
        PlatoonTemplate = 'T3AirTransport',
		
        PlatoonAddFunctions = { {LUTL, 'ResetBrainNeedsTransport'}, },
		
        Priority = 600,
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },
			
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK, categories.AIR * categories.TECH3 }},
			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 3, [512] = 4, [1024] = 8, [2048] = 14, [4096] = 18}, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK}},
			
        },
		
        BuilderType =  {'AirT3'},
		
    },
	
    Builder {BuilderName = 'Air Transport T3 - HighNeed',
	
        PlatoonTemplate = 'T3AirTransport',
		
        PlatoonAddFunctions = { {LUTL, 'ResetBrainNeedsTransport'}, },
		
        Priority = 610,
		
        BuilderConditions = {
		
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'UnitCapCheckLess', { .85 } },
			
            { UCBC, 'ArmyNeedsTransports', { true } },
			
			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.TRANSPORTFOCUS - categories.TECH1 - categories.GROUNDATTACK, categories.AIR * categories.TECH3 }},
			
        },
		
        BuilderType =  {'AirT3'},
		
    },

}



