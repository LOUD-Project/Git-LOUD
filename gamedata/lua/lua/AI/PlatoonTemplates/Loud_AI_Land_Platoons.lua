--   /lua/ai/LandPlatoonTemplates.lua
-- These templates determine the composition of platoons built by the Platoon Form Manager (platoons)

-- not that it's used much - but you can have factional differences -- have a look at the T1 Scouting Platoon where all factions have
-- 2 scouts except the Cybrans which only use 1 scout

PlatoonTemplate { Name = 'ReinforceLandPlatoonDirect',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 24, 48, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 0, 6, 'Artillery', 'none'},
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 0, 12, 'Guard', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 3, 'Guard', 'none' },
		--{ (categories.LAND * categories.MOBILE * categories.ANTISHIELD), 0, 3, 'Attack', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
	},
}

PlatoonTemplate { Name = 'ReinforceLandPlatoonIndirect',
    GlobalSquads = {
		{ (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 6, 'Attack', 'none'},
        { (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 0, 12, 'Guard', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 3, 'Guard', 'none' },
		--{ (categories.LAND * categories.MOBILE * categories.ANTISHIELD), 0, 3, 'Attack', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
	},
}


PlatoonTemplate { Name = 'ArtilleryAttack',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 0, 12, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 3, 'Guard', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none'},
    },
}

PlatoonTemplate { Name = 'T1MassAttack',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 5, 8, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 0, 1, 'Guard', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 1, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 1, 'Support', 'none' },
    },
}

PlatoonTemplate { Name = 'T2MassAttack',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 24, 48, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 2, 16, 'Artillery', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 5, 12, 'Guard', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 6, 'Support', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 4, 'Support', 'none' },
    },
}

PlatoonTemplate { Name = 'T3MassAttack',
    Plan = 'GuardPoint',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.ENGINEER - categories.EXPERIMENTAL, 50, 75, 'Attack', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 12, 20, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 10, 'Guard', 'none'},
		--{ (categories.LAND * categories.MOBILE * categories.ANTISHIELD), 0, 7, 'Attack', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 6, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
    },
}

PlatoonTemplate { Name = 'LandAttackLarge',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.ENGINEER - categories.EXPERIMENTAL, 50, 90, 'Attack', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 12, 20, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 10, 'Guard', 'none'},
		--{ (categories.LAND * categories.MOBILE * categories.ANTISHIELD), 0, 7, 'Attack', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 6, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
    },
}

PlatoonTemplate { Name = 'LandAttackLargeNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 50, 100, 'Attack', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 12, 20, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 10, 'Guard', 'none'},
		--{ (categories.LAND * categories.MOBILE * categories.ANTISHIELD), 0, 7, 'Attack', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 6, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401, 0, 4, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'LandAttackHugeNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 70, 100, 'Attack', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 6, 25, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.ANTIAIR), 6, 20, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 15, 'Guard', 'none'},
		--{ (categories.LAND * categories.MOBILE * categories.ANTISHIELD), 0, 7, 'Attack', 'none'},
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 6, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 4, 'Attack', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401, 0, 8, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'ReinforceAmphibiousPlatoon',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 12, 24, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'AmphibAttackSmall',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 12, 24, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'AmphibAttackMedium',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 24, 48, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'AmphibAttackLarge',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 48, 80, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 18, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 10, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'AmphibAttackHuge',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 72, 110, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 18, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 10, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'BaseGuardMedium',

    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.ENGINEER - categories.EXPERIMENTAL, 13, 18, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 2, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 1, 'Guard', 'none' },
		-- allow experimentals except artillery and construction
		{ (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.CONSTRUCTION - categories.ARTILLERY, 0, 2, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'BaseGuardAAPatrol',

    GlobalSquads = {
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 5, 12, 'Guard', 'GrowthFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 1, 'Guard', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 1, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T1LandScoutForm',

    FactionSquads = {
        UEF = {
            { 'uel0101', 2, 3, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0101', 2, 3, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0101', 1, 1, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0101', 1, 1, 'Guard', 'none' }
        },
    }
}


PlatoonTemplate { Name = 'T1MassGuard',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL, 2, 4, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 0, 1, 'Guard', 'AttackFormation' },		
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2MassGuard',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL, 5, 8, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 0, 1, 'Guard', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 1, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'T2MassGuardSpecial',
    Plan = 'GuardPoint',    
    FactionSquads = {
        UEF = {
			{ (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ (categories.LAND * categories.MOBILE * categories.SHIELD), 1, 1, 'Guard', 'AttackFormation' },
        },
        Aeon = {
			{ (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ (categories.LAND * categories.MOBILE * categories.SHIELD), 1, 1, 'Guard', 'AttackFormation' },
        },
        Cybran = {
			{ (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 1, 1, 'Guard', 'AttackFormation' },
        },
        Seraphim = {
			{ (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ (categories.LAND * categories.MOBILE * categories.SHIELD), 1, 1, 'Guard', 'AttackFormation' },

        },
    }
}

PlatoonTemplate { Name = 'T2PointGuard',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 13, 24, 'Attack', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 6, 8, 'Artillery', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 5, 12, 'Guard', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 3, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2PointGuardArtillery',
    Plan = 'GuardPoint',    
    GlobalSquads = {
		{ (categories.LAND * categories.MOBILE * categories.INDIRECTFIRE) - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.ANTIAIR), 5, 12, 'Guard', 'AttackFormation' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 4, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none' },
    },
}
--[[
PlatoonTemplate { Name = 'T4ExperimentalScathis',
    Plan = 'ArtilleryAI',   
    GlobalSquads = {
        { categories.url0401, 1, 1, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'T4ExperimentalLand',
    Plan = 'ExperimentalAIHub',   
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, 1, 1, 'Attack', 'none' },
    },
}
--]]
PlatoonTemplate { Name = 'T4ExperimentalLandGroup',

    Plan = 'AmphibForceAILOUD',
	
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, 6, 15, 'Artillery', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 0, 40, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
		--{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTISHIELD), 0, 3, 'Attack', 'none'},
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'ReinforceLandExperimental',

    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401, 1, 6, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'ReinforceAirExperimental',
    Plan = 'ReinforceAirAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.AIR * categories.EXPERIMENTAL), 1, 6, 'Attack', 'none' },
    },
}


PlatoonTemplate { Name = 'T4SatelliteExperimental',
    Plan = 'SatelliteAI',
    GlobalSquads = {
        { categories.SATELLITE, 1, 1, 'Attack', 'none' },
    }
}
--]]