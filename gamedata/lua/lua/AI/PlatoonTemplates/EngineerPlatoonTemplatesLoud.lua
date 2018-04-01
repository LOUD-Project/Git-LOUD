--   /lua/ai/EngineerPlatoonTemplatesLoud.lua
--  Global engineer platoon templates

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



-- Factory built Engineers below
PlatoonTemplate { Name = 'T1BuildEngineer',

    FactionSquads = {
        UEF = {
            { 'uel0105', 1, 1, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0105', 1, 1, 'Support', 'none' }
        },
        Cybran = {
            { 'url0105', 1, 1, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0105', 1, 1, 'Support', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T1BuildEngineerInitial',

    FactionSquads = {
        UEF = {
            { 'uel0105', 1, 5, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0105', 1, 5, 'Support', 'none' }
        },
        Cybran = {
            { 'url0105', 1, 5, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0105', 1, 5, 'Support', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2BuildEngineer',

    FactionSquads = {
        UEF = {
            { 'uel0208', 1, 1, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0208', 1, 1, 'Support', 'none' }
        },
        Cybran = {
            { 'url0208', 1, 1, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0208', 1, 1, 'Support', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2BuildEngineerInitial',
    FactionSquads = {
        UEF = {
            { 'uel0208', 1, 2, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0208', 1, 2, 'Support', 'none' }
        },
        Cybran = {
            { 'url0208', 1, 2, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0208', 1, 2, 'Support', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3BuildEngineer',
    FactionSquads = {
        UEF = {
            { 'uel0309', 1, 1, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0309', 1, 1, 'Support', 'none' }
        },
        Cybran = {
            { 'url0309', 1, 1, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0309', 1, 1, 'Support', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3BuildEngineerInitial',
    FactionSquads = {
        UEF = {
            { 'uel0309', 1, 2, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0309', 1, 2, 'Support', 'none' }
        },
        Cybran = {
            { 'url0309', 1, 2, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0309', 1, 2, 'Support', 'none' }
        },
    }
}