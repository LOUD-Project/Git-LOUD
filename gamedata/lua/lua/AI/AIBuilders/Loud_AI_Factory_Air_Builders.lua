-- Loud_AI_Factory_Air_Builders.lua
-- factory production of all air units

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'
local TBC   = '/lua/editor/ThreatBuildConditions.lua'
local TUTL  = '/lua/ai/transportutilities.lua'

local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal
local GetListOfUnits        = moho.aibrain_methods.GetListOfUnits
local LOUDGETN              = table.getn

local AIR               = categories.AIR
local AIRSCOUT          = AIR * categories.SCOUT
local AIRT2UP           = AIR - categories.TECH1
local AIRT3             = AIR * categories.TECH3
local AIRTORP           = AIR * categories.ANTINAVY
local HIGHALTAIRAA      = categories.HIGHALTAIR * categories.ANTIAIR
local TRANSPORTS        = categories.TRANSPORTFOCUS
local TRANSPORTST2UP    = TRANSPORTS - categories.TECH1 - categories.GROUNDATTACK


local AboveUnitCap75 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap90 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local First45Minutes = function( self, aiBrain )

    if aiBrain.CycleTime < 220 then   -- delay scouts to prevent energy crash 
        return 10, true        
    end
	
	if aiBrain.CycleTime > 2700 then
		return 0, false
	end
    
    if self.Priority > 0 then 
        return self.Priority, true
    else
        return 0, false
    end
end

local IsEnemyNavalActive = function( self, aiBrain, manager )

    if not aiBrain.IsWaterMap then
    
        return 0, false
    
    end

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .011 and aiBrain.NavalRatio < 10) then

		return 600, true

	end

	return 10, true
	
end

local IsEnemyAirActive = function(self,aiBrain,manager)

	if aiBrain.AirRatio and (aiBrain.AirRatio > .011 and aiBrain.AirRatio < 10) then
	
		return self.OldPriority or self.Priority, true

	end

	return 10, true
	
end

local HaveLessThanThreeT2AirFactory = function( self, aiBrain )
	
    if aiBrain.CycleTime < 240 then -- delay air units longer than air scouts
    
        return 10, true
        
    end
    
	-- remove by game time --
	if aiBrain.CycleTime >  2700 then
		
		return 0, false
		
	end
	
	if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * AIRT2UP, false, true )) < 3 then
	
		return self.OldPriority or self.Priority, true
		
	end

	
	return 0, false
	
end

local HaveLessThanThreeT3AirFactory = function( self, aiBrain )

	if LOUDGETN( GetListOfUnits( aiBrain, categories.FACTORY * AIRT3, false, true )) < 3 then
	
		return self.OldPriority or self.Priority, true
		
	end

	return 0, false
	
end

-- The simple idea here is that fighters are always produced if the air ratio is less than 3
-- Scout planes are always produced - controlled by map size ratio and number of factories producing
-- Bomber and Gunships are only produced if air ratio is greater than 2

-- T1 is produced while there are less than 3 T2/T3 Air Factories overall
-- T2 is produced while there are less than 3 T3 Air Factories

-- ALL AIR BUILDERS SIT AT 600 PRIORITY except for highneed transports and torp bombers
-- usually controlled by air ratio and number of factories producing that unit

BuilderGroup {BuilderGroupName = 'Factory Production Air - Scouts', BuildersRestriction = 'AIRSCOUTS', BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Air Scout T1',
	
        PlatoonTemplate = 'T1AirScout',
        
        Priority = 600,
        
        PriorityFunction = First45Minutes, 

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .65 } },

            -- don't build T1 air scouts if we can build better ones
            { UCBC, 'FactoriesLessThan', { 1, AIRT2UP }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 8, [512] = 10, [1024] = 14, [2048] = 20, [4096] = 26}, AIRSCOUT }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 9, AIRSCOUT } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, AIRSCOUT, AIR }},
        },

        BuilderType =  {'AirT1'},
    },
	
    Builder {BuilderName = 'Air Scout T2',
	
        PlatoonTemplate = 'T2AirScout',

        Priority = 600,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

            -- don't build T2 air scouts if we can build better ones
            { UCBC, 'FactoriesLessThan', { 1, AIRT3 }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 24, [512] = 36, [1024] = 48, [2048] = 60, [4096] = 78}, AIRSCOUT }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 9, AIRSCOUT } },			

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, AIRSCOUT, AIRT2UP }},
        },

        BuilderType =  {'AirT2'},
    },

    Builder {BuilderName = 'Air Scout T3',
	
        PlatoonTemplate = 'T3AirScout',
        
        Priority = 600,

        PriorityFunction = AboveUnitCap90,
        
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 24, [512] = 36, [1024] = 48, [2048] = 60, [4096] = 96}, AIRSCOUT }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 9, AIRSCOUT } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, AIRSCOUT, AIRT3 }},
        },

        BuilderType =  {'AirT3'},
    },
}

BuilderGroup {BuilderGroupName = 'Factory Production Air - Fighters', BuildersRestriction = 'AIRFIGHTERS', BuildersType = 'FactoryBuilder',

    --- fighters with a air scout supplement - prior to T2
    Builder {BuilderName = 'Fighters T1 Plus',
	
        PlatoonTemplate = 'T1FighterPlus',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 2 } },

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 24, [512] = 36, [1024] = 48, [2048] = 60, [4096] = 72}, HIGHALTAIRAA }},
            
			--- stop if enemy has T2 AA of any kind
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ANTIAIR - categories.TECH1, 'Enemy' }},
        },
		
        BuilderType =  {'AirT1'},
    },
	
    --- fighters with no scout supplement made if T2 ANTIAIR is present
    --- most useful early when new air factories come online and T2 is present
    Builder {BuilderName = 'Fighters T1',
	
        PlatoonTemplate = 'T1Fighter',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 1.5 } },

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 24, [512] = 36, [1024] = 48, [2048] = 60, [4096] = 72}, HIGHALTAIRAA }},
        },
		
        BuilderType =  {'AirT1'},
    },
	
    Builder {BuilderName = 'Fighters T2 Crossover',
	
        PlatoonTemplate = 'T2FighterCrossover',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 2 } },

            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, AIRT2UP }},
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },

    Builder {BuilderName = 'Fighters T2',
	
        PlatoonTemplate = 'T2Fighter',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR - categories.TECH1 }},
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },

    Builder {BuilderName = 'Fighters T3',
	
        PlatoonTemplate = 'T3Fighter',

        Priority = 600,
		
		PriorityFunction = IsEnemyAirActive,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },

			{ LUTL, 'HaveGreaterThanT3AirFactories', { 1 }},
        },

        BuilderType =  {'AirT3'},
    },
}

BuilderGroup {BuilderGroupName = 'Factory Production Air - Bombers', BuildersRestriction = 'AIRBOMBERS', BuildersType = 'FactoryBuilder',	

	Builder {BuilderName = 'Bomber T1',
	
        PlatoonTemplate = 'T1Bomber',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
            
			-- stop making them if enemy has T2 AA of any kind
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ANTIAIR - categories.TECH1, 'Enemy' }},
        },
		
        BuilderType =  {'AirT1'},
    },

    Builder {BuilderName = 'Bomber T2',
	
        PlatoonTemplate = 'T2Bomber',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },
	
    Builder {BuilderName = 'Bomber T3',
	
        PlatoonTemplate = 'T3Bomber',

        Priority = 600,
        
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

			{ LUTL, 'HaveGreaterThanT3AirFactories', { 3 }},
        },
		
        BuilderType =  {'AirT3'},
    },
}

BuilderGroup {BuilderGroupName = 'Factory Production Air - Gunships', BuildersRestriction = 'AIRGUNSHIPS', BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Gunship T2',
	
        PlatoonTemplate = 'T2Gunship',

        Priority = 600,
		
		PriorityFunction = HaveLessThanThreeT3AirFactory,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1.8 } },

            { LUTL, 'UnitCapCheckLess', { .85 } },
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },
	
    Builder {BuilderName = 'Gunship T3',
	
        PlatoonTemplate = 'T3Gunship',

        Priority = 600,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1.8 } },

			{ LUTL, 'HaveGreaterThanT3AirFactories', { 3 }},
        },

        BuilderType =  {'AirT3'},
    },
}

BuilderGroup {BuilderGroupName = 'Factory Production Air - Torpedo Bombers', BuildersRestriction = 'AIRTORPEDOBOMBERS', BuildersType = 'FactoryBuilder',
    --- Torpedo Bombers are problematic as just being a water map isn't enough reason to build them - there needs to be a threat
    --- AND importantly, it should only become an issue if the AI is actually playing on the water
    --- When I see an AI with no Naval position building Torpedo Bombers I get disturbed especially if his partners are in the water and he isn't
    --- there are legitimate reasons to do this, but we need to control them carefully
    Builder {BuilderName = 'Torpedo Bomber T1',
	
        PlatoonTemplate = 'T1TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 3 } },        

            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

            -- dont build unless you have 2+ air factories
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 3, AIRTORP }},
        },

        BuilderType =  {'AirT1'},
    },

    Builder {BuilderName = 'Torpedo Bomber T2',
	
        PlatoonTemplate = 'T2TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 3 } },        

            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
            
			-- dont start production until you have at least 2+ T2/T3 factories at location
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, AIRTORP }},
        },

        BuilderType =  {'AirT2','SeaT2'},
    },

    Builder {BuilderName = 'Torpedo Bomber T3',
	
        PlatoonTemplate = 'T3TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 3 } },
            
            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },

			-- dont produce unless you have 3+ T3 Air factories overall
			{ LUTL, 'HaveGreaterThanT3AirFactories', { 2 }},

			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, AIRTORP }},
        },

        BuilderType =  {'AirT3','SeaT3'},
    },

    -- Increased opportunity for Torpedo Bombers when Naval is active but low
    Builder {BuilderName = 'Torpedo Bomber T2 - Response',
	
        PlatoonTemplate = 'T2TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 1.5 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1.8 } }, 

            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			-- dont start production until you have at least 2+ T2/T3 factories at location
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY - categories.TECH1 }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, AIRTORP }},            
        },

        BuilderType =  {'AirT2','SeaT2'},
    },

    Builder {BuilderName = 'Torpedo Bomber T3 - Response',
	
        PlatoonTemplate = 'T3TorpedoBomber',
		
        Priority = 10,
		
		PriorityFunction = IsEnemyNavalActive,
		
        BuilderConditions = {
            { LUTL, 'NavalStrengthRatioLessThan', { 1.5 } },

			{ LUTL, 'AirStrengthRatioGreaterThan', { 1.8 } },

            { LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},

			-- dont produce unless you have 3+ T3 Air factories overall
			{ LUTL, 'HaveGreaterThanT3AirFactories', { 2 }},

            -- one of the few places where I use a % ratio to control the number of units
			{ UCBC, 'HaveLessThanUnitsAsPercentageOfUnitCap', { 4.5, AIRTORP }},            
        },
		
        BuilderType =  {'AirT3','SeaT3'},
    },    
}

BuilderGroup {BuilderGroupName = 'Factory Production Air - Transports', BuildersRestriction = 'AIRTRANSPORTS', BuildersType = 'FactoryBuilder',

    --- Transports are built on an 'as Needed' basis - that need is created when a platoon looks for transport and cannot find enough

    Builder {BuilderName = 'Air Transport T1',
	
        PlatoonTemplate = 'T1AirTransport',
		
        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },		
	
        Priority = 610, 
		
		PriorityFunction = HaveLessThanThreeT2AirFactory,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { LUTL, 'UnitCapCheckLess', { .6 } },

            { UCBC, 'ArmyNeedsTransports', { true } },
			
			-- stop making them if we have more than 1 T2/T3 air plants - anywhere
            { UCBC, 'FactoriesLessThan', { 1, AIRT2UP }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 1, [512] = 2, [1024] = 3, [2048] = 5, [4096] = 6}, TRANSPORTS * categories.TECH1}},
        },

        BuilderType =  {'AirT1','AirT2'},
    },

    Builder {BuilderName = 'Air Transport T2',
	
        PlatoonTemplate = 'T2AirTransport',
		
        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },
		
        Priority = 610,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
                return 10, true
            end
            
            if (not aiBrain.NeedTransports) or aiBrain.LandRatio <= 0.7 then
                return 10, true
            end
            
            if aiBrain.AirRatio < 0.6 then 
                return self.Priority - 10, true
            end
            
            return self.Priority, false
        end,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, TRANSPORTST2UP, AIRT2UP }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 6, [512] = 8, [1024] = 12, [2048] = 18, [4096] = 24}, TRANSPORTS * categories.TECH2}},
        },
		
        BuilderType =  {'AirT2','AirT3'},
    },
	
	--- stop construction of T2 Gunships (for transport) once we have the ability to build T3
    Builder {BuilderName = 'UEF Gunship Transports',
	
        PlatoonTemplate = 'T2Gunship',
		
		FactionIndex = 1,
		
        Priority = 600,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .60 then
                return 10, true
            end
            
            if (not aiBrain.NeedTransports) or aiBrain.LandRatio <= 0.7 then
                return 10, true
            end
            
            if aiBrain.AirRatio < 0.6 then
                return self.Priority - 10, true
            end

            return self.Priority, false
        end,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		

			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.uea0203 }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.uea0203, AIRT2UP }},
        },
		
        BuilderType =  {'AirT2'},
    },

    Builder {BuilderName = 'Air Transport T3',
	
        PlatoonTemplate = 'T3AirTransport',

        PlatoonAddFunctions = { {TUTL, 'ResetBrainNeedsTransport'}, },

        Priority = 610,
        
        PriorityFunction = function(self, aiBrain)
	
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
                return 10, true
            end
            
            if (not aiBrain.NeedTransports) or aiBrain.LandRatio <= 0.7 then
                return 10, true
            end
            
            if aiBrain.AirRatio < 0.6 then
                return self.Priority - 10, true
            end

            return self.Priority, false            
        end,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, TRANSPORTST2UP, AIRT3 }},

			{ UCBC, 'HaveLessThanUnitsForMapSize', { {[256] = 6, [512] = 8, [1024] = 12, [2048] = 18, [4096] = 24}, TRANSPORTS * categories.TECH3}},
        },

        BuilderType =  {'AirT3'},
    },
}



