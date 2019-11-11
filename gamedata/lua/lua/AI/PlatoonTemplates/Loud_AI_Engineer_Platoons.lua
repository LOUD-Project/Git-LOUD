--   /lua/ai/platoontemplates/Loud_AI_Engineer_Platoons.lua

--  Global engineer platoon templates
--  used when forming engineer tasks

-- COMMANDER
PlatoonTemplate {Name = 'CommanderAssist',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Support', 'none' },
    },        
}

PlatoonTemplate {Name = 'CommanderBuilder',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Support', 'none' },
    },        
}

PlatoonTemplate {Name = 'CommanderEnhance',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Support', 'none' },
    },
}

PlatoonTemplate {Name = 'CommanderReclaim',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Support', 'none' },
    },	
}

PlatoonTemplate {Name = 'CommanderRepair',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Support', 'none' },
    },        
}


-- GENERAL ENGINEER 
PlatoonTemplate {Name = 'EngineerBuilderGeneral',
    Plan = 'EngineerBuildAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER), 1, 1, 'Support', 'none' },
    },        
}

PlatoonTemplate {Name = 'EngineerAssistGeneral',
	GlobalSquads = {
		{ (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
	},
}

PlatoonTemplate {Name = 'EngineerReclaimerGeneral',
    Plan = 'EngineerReclaimAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}

PlatoonTemplate {Name = 'EngineerUnitReclaimerGeneral',
	Plan = 'EngineerReclaimUnitAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}	

PlatoonTemplate {Name = 'EngineerStructureReclaimerGeneral',
	Plan = 'EngineerReclaimStructureAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}	
	
PlatoonTemplate {Name = 'EngineerRepairGeneral',
    Plan = 'EngineerRepairAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },        
}

PlatoonTemplate {Name = 'MassAdjacencyEngineer',
    Plan = 'EngineerBuildMassAdjacencyAI',
    GlobalSquads = {
		{ (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}

PlatoonTemplate {Name = 'MassAdjacencyDefenseEngineer',
    Plan = 'EngineerBuildMassDefenseAdjacencyAI',
    GlobalSquads = {
		{ (categories.MOBILE * categories.ENGINEER) + categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}


-- Engineer Transfers -- they all run DummyAI since a behavior will do whats needed here

PlatoonTemplate {Name = 'T2EngineerTransfer',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER * categories.TECH2), 1, 1, 'Support', 'none' },
    },
}

PlatoonTemplate {Name = 'T3EngineerTransfer',
    GlobalSquads = {
        { (categories.MOBILE * categories.ENGINEER * categories.TECH3) - categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}

PlatoonTemplate {Name = 'SubCommanderTransfer',
    GlobalSquads = {
        { categories.SUBCOMMANDER, 1, 1, 'Support', 'none' },
    },
}


