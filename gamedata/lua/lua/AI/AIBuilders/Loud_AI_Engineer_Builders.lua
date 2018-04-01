--  /lua/ai/Loud_AI_Engineer_Builders.lua
--- constructs engineers at all types of bases
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'

BuilderGroup {BuilderGroupName = 'Engineer Factory Builders',
    BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Engineer T1 - Initial',
	
        PlatoonTemplate = 'T1BuildEngineerInitial',
		
        Priority = 900,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, categories.ENGINEER - categories.SUBCOMMANDER - categories.COMMAND }},
			
        },
		
        BuilderType =  {'AirT1','LandT1'},
		
    },
	
    Builder {BuilderName = 'Engineer T1 - Standard',
	
        PlatoonTemplate = 'T1BuildEngineer',
		
        Priority = 600, 
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech1' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			
        },
		
        BuilderType = {'LandT1','LandT2','LandT3'},
		
    },

    Builder {BuilderName = 'Engineer T2 - Initial',
	
        PlatoonTemplate = 'T2BuildEngineerInitial',
		
        Priority = 900,
		
        BuilderConditions = {
		
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, (categories.MOBILE * categories.ENGINEER) - categories.TECH1 - categories.COMMAND }},
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH2 }},
			
        },
		
        BuilderType =  {'LandT2','LandT3','AirT2','AirT3','Gate'},
    },
	
    Builder {BuilderName = 'Engineer T2 - Standard',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 600,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER - categories.TECH1 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.01, 1.02 }},
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech2' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'LandT2','LandT3'},
    },

    Builder {BuilderName = 'Engineer T3 - Initial',
        PlatoonTemplate = 'T3BuildEngineerInitial',
        Priority = 900,
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, (categories.MOBILE * categories.ENGINEER * categories.TECH3) - categories.COMMAND }},
            { UCBC,'EngineerLessAtLocation', { 'LocationType', 2, (categories.MOBILE * categories.ENGINEER * categories.TECH3) - categories.SUBCOMMANDER }},
        },
        BuilderType =  {'LandT3','AirT3','Gate'},
    },
	
    Builder {BuilderName = 'Engineer T3 - Standard',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 650,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.01, 1.02 }},
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
        },
        BuilderType = {'LandT3'},
    },
	
	-- this builder will add T3 engies above the cap when resources are very high
    Builder {BuilderName = 'Engineer T3 - Extra',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 650,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 8, 120, 1.05, 1.05 }},
            { UCBC, 'AboveEngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'LandT3','AirT3'},
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
}


BuilderGroup {BuilderGroupName = 'Engineer Factory Builders Expansion',
    BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Engineer T1 - Expansion',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 600, 
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech1' } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'LandT1','LandT2','LandT3'},
    },

    Builder {BuilderName = 'Engineer T2 - Expansion',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 601,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech2' } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'LandT2','LandT3'},
    },

    Builder {BuilderName = 'Engineer T3 - Expansion',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 650,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech3' } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
        },
        BuilderType = {'AirT3','LandT3'},
    },
	
    Builder {BuilderName = 'Engineer T3 - Extra - Expansion',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 650,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 8, 120, 1.05, 1.05 }},
            { UCBC, 'AboveEngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'LandT3','AirT3'},
    },
}


BuilderGroup {BuilderGroupName = 'Engineer Factory Builders Naval',
    BuildersType = 'FactoryBuilder',

    Builder {BuilderName = 'Engineer T1 - Naval',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 600, 
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech1' } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'SeaT1','SeaT2'},
    },

    Builder {BuilderName = 'Engineer T2 - Naval',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 601,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech2' } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'SeaT2','SeaT3'},
    },

    Builder {BuilderName = 'Engineer T3 - Naval',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 650,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			
            { UCBC, 'BelowEngineerCapCheck', { 'LocationType', 'Tech3' } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 10, 1.02, 1.02 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 }},
        },
        BuilderType = {'SeaT3'},
    },
	
    Builder {BuilderName = 'Engineer T3 - Extra - Naval',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 600,
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 8, 120, 1.05, 1.05 }},
            { UCBC, 'AboveEngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = {'SeaT3'},
    },

}

