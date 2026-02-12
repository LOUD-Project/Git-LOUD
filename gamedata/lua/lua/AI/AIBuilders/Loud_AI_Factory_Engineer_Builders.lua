--  /lua/ai/Loud_AI_Engineer_Builders.lua
--- constructs engineers at all types of bases

local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal

-- imbedded into the Builder
local AboveUnitCap50 = function( self,aiBrain )

    if aiBrain.CycleTime < 130 then    -- delay standard engineers to prevent eco crash
        return 10, true        
    end

	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .5 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap60 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .6 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap70 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .7 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

BuilderGroup {BuilderGroupName = 'Factory Production - Engineers', BuildersType = 'FactoryBuilder',
    
    -- These first four builders at 900 priority insure that
    -- a bare minimum of engineers are created for all tiers
    
    -- T1 is only made if there are less than 3 engineers (all tiers) at the base
    -- T2 is only made if there are no idle engineers at the base
    -- T3 is only made if there are no idel T3 engineers at the base
    -- SACU are made continously until cap is reached
    Builder {BuilderName = 'Engineer T1 - Initial',
	
        PlatoonTemplate = 'T1BuildEngineerInitial',
        
        PlatoonAddFunctions = { { LUTL, 'UseBuilderOnce' }, },
		
        Priority = 900,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech1' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, categories.ENGINEER - categories.TECH3 - categories.SUBCOMMANDER - categories.COMMAND }},
        },
		
        BuilderType =  {'AirT1','LandT1','SeaT1','AirT2','LandT2','SeaT2'},
    },

    Builder {BuilderName = 'Engineer T2 - Initial',
	
        PlatoonTemplate = 'T2BuildEngineerInitial',
        
        PlatoonAddFunctions = { { LUTL, 'UseBuilderOnce' }, },
		
        Priority = 900,
 		
        BuilderConditions = {

            { LUTL, 'UnitCapCheckLess', { .6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, (categories.MOBILE * categories.ENGINEER) - categories.TECH1 - categories.COMMAND }},
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH2 }},
        },
		
        BuilderType =  {'AirT2','LandT2','SeaT2','AirT3','LandT3','SeaT3','Gate'},
    },

    Builder {BuilderName = 'Engineer T3 - Initial',
    
        PlatoonTemplate = 'T3BuildEngineerInitial',
        
        PlatoonAddFunctions = { { LUTL, 'UseBuilderOnce' }, },
        
        Priority = 900,
        
        BuilderConditions = {

            { LUTL, 'UnitCapCheckLess', { .7 } },
            
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, (categories.MOBILE * categories.ENGINEER * categories.TECH3) - categories.COMMAND }},
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 2, (categories.MOBILE * categories.ENGINEER * categories.TECH3) - categories.SUBCOMMANDER }},
        },
        
        BuilderType =  {'AirT3','LandT3','SeaT3','Gate'},
    },

    Builder {BuilderName = 'Sub Commander',
    
        PlatoonTemplate = 'T3LandSubCommander',
        
        Priority = 900,
        
        BuilderConditions = {
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.SUBCOMMANDER }},
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'SCU' } },
        },
        
        BuilderType = {'Gate'},
    },

    
    -- the remainder of these builders produce additional engineers at the same priority as units
    -- until cap is reached
    
    -- T1 wont be produced if any engineer is idle at the base and only if we have room in the other tiers as well
    -- T2 is only produced if there are no idle T2 or T3 engineers
    -- T3 is only concerned about idle T3 engineers (including SACU)
    Builder {BuilderName = 'Engineer T1 - Standard',
	
        PlatoonTemplate = 'T1BuildEngineer',
		
        Priority = 600, 
        
        PriorityFunction = AboveUnitCap50,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
            
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech1' } },
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech2' } },
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech3' } },            
            
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
		
        BuilderType = {'AirT1','LandT1','SeaT1','AirT2','LandT2','SeaT2'},
    },

    Builder {BuilderName = 'Engineer T2 - Standard',
    
        PlatoonTemplate = 'T2BuildEngineer',
        
        Priority = 600,
        
        PriorityFunction = AboveUnitCap60,
        
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},        
            { LUTL, 'UnitCapCheckLess', { .6 } },

			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH2 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.6, 6, 1, 1 }},
            
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech2' } },
            
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        
        BuilderType = {'AirT2','LandT2','SeaT2','AirT3','LandT3','SeaT3','Gate'},
    },

    Builder {BuilderName = 'Engineer T3 - Standard',
    
        PlatoonTemplate = 'T3BuildEngineer',
        
        Priority = 650,
        
        PriorityFunction = AboveUnitCap70,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},        
            
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.6, 6, 1, 1 }},
            
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech3' } },
            
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
        },
        
        BuilderType = {'AirT3','LandT3','SeaT3','Gate'},
    },

	
	-- this builder will add T3 engies above the cap when resources are very high
    -- and only if there are no idle T3 engineers (including SACU)
    Builder {BuilderName = 'Engineer T3 - Extra',
    
        PlatoonTemplate = 'T3BuildEngineer',
        
        Priority = 650,
        
        PriorityFunction = AboveUnitCap70,

        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},        
            
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 60, 1.02, 1.04 }},
            
            { UCBC, 'AboveEngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        
        BuilderType = {'AirT3','LandT3','SeaT3','Gate'},
    },

	
	-- this builder will add SACU above the cap when resources are very high
    -- and only if there are no idle SACU
    Builder {BuilderName = 'Sub Commander - Extra',
    
        PlatoonTemplate = 'T3LandSubCommander',
        
        Priority = 650,
        
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},        
            
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.SUBCOMMANDER }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 60, 1.02, 1.04 }},
            
            { UCBC, 'AboveEngineerCapCheck', { 'LocationType', 'SCU' } },
        },
        
        BuilderType = {'Gate'},
    },

}
