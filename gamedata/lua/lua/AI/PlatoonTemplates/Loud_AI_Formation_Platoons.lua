-- File: /lua/ai/Loud_Air_Platoon_Templates.lua

-- determines the composition of platoons built by the Platoon Manager
--------------------------
----- AIR FORMATIONS -----
--------------------------

PlatoonTemplate { Name = 'FighterAttack Small',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL, 1, 12, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'FighterAttack',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL, 18, 32, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'FighterAttack Large',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL, 24, 48, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'FighterEscort',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL, 18, 32, 'Attack', 'None' },
    }
}
PlatoonTemplate { Name = 'FighterReinforce',
    Plan = 'ReinforceAirAI',	-- to either land or sea bases
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR), 3, 45, 'Attack', 'none' },
		{ (categories.AIR * categories.SCOUT),0,4,'Support','none' },
    }
}


PlatoonTemplate { Name = 'BomberAttack Small',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY), 1, 12, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY), 12, 24, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack Large',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY ), 24, 36, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack Super',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY ), 36, 48, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'Experimental Bomber',
    GlobalSquads = {
        { (categories.AIR * categories.EXPERIMENTAL * categories.MOBILE * categories.BOMBER) - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 3, 8, 'Attack', 'none' },
    },
}
PlatoonTemplate { Name = 'BomberReinforce',
    Plan = 'ReinforceAirAI',	-- either Land or Sea bases
    GlobalSquads = {
        { categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY, 3, 24, 'Attack', 'none' },
		{ (categories.AIR * categories.SCOUT), 0, 4, 'Support', 'none' },
    }
}


PlatoonTemplate { Name = 'GunshipAttack Small',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 1, 15, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'GunshipAttack',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 16, 30, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 4, 'Attack', 'none' },
    }
}

PlatoonTemplate { Name = 'GunshipAttack Large',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 28, 45, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 6, 'Attack', 'none' },
    }
}

PlatoonTemplate { Name = 'GunshipSquadron',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 5, 35, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'GunshipEscort',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 5, 35, 'Attack', 'None' },
    }
}

PlatoonTemplate { Name = 'GunshipReinforce',
    Plan = 'ReinforceAirAI',	-- either Land or Sea bases
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 3, 35, 'Attack', 'none' },
		{ (categories.AIR * categories.SCOUT), 0, 4, 'Support', 'none' },
    }
}

PlatoonTemplate { Name = 'Experimental Gunship',
    GlobalSquads = {
        { (categories.AIR * categories.EXPERIMENTAL * categories.MOBILE * categories.GROUNDATTACK) - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 4, 8, 'Attack', 'none' },
		{ (categories.bea0402), 0, 8, 'guard', 'none' },
    },
}


PlatoonTemplate { Name = 'Air Scout Formation',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT, 1, 1, 'scout', 'none' },
    }
}

PlatoonTemplate { Name = 'Air Scout Group',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT, 2, 2, 'scout', 'none' },
    }
}

PlatoonTemplate { Name = 'Air Scout Group Large',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT - categories.TECH1, 5, 5, 'scout', 'ScatterFormation' },
    }
}

PlatoonTemplate { Name = 'Air Scout Group Huge',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT - categories.TECH1, 9, 9, 'scout', 'ScatterFormation' },
    }
}


PlatoonTemplate { Name = 'TorpedoReinforce',
	Plan = 'ReinforceAirNavalAI',	-- specifically naval bases
	GlobalSquads = {
		{ (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 3, 48, 'Attack', 'AttackFormation' },
  		{ (categories.AIR * categories.SCOUT), 0, 4, 'Support', 'none' },
	}
}

PlatoonTemplate { Name = 'TorpedoBomberAttack',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 6, 48, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack Small',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 1, 12, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 13, 29, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack Large',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 30, 42, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'TorpedoEscort',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 13, 29, 'Attack', 'None' },
    }
}
PlatoonTemplate { Name = 'TorpedoEscort Large',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 30, 42, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'T4ExperimentalAirCzar',

	FactionSquads = {
	
		Aeon = {
			{ categories.uaa0310, 3, 5, 'Attack', 'none' },
		},
    }
}

PlatoonTemplate { Name = 'CzarTerrorAttack',

	FactionSquads = {
	
		Aeon = {
			{ categories.uaa0310, 1, 1, 'Attack', 'none' }
		},
    }
}

PlatoonTemplate { Name = 'T4ExperimentalAirGroup',
    Plan = 'ExperimentalAIHub', 
    GlobalSquads = {
        { (categories.AIR * categories.EXPERIMENTAL * categories.MOBILE) - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 2, 4, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'ReinforceAirExperimental',
    Plan = 'ReinforceAirAI',
    GlobalSquads = {
        { (categories.MOBILE * categories.AIR * categories.EXPERIMENTAL), 1, 6, 'Attack', 'none' },
    },
}


--------------------------
----- LAND FORMATION -----
--------------------------
-- not that it's used much - but you can have factional differences -- have a look at the T1 Scouting Platoon where all factions have
-- 2 scouts except the Cybrans which only use 1 scout

PlatoonTemplate { Name = 'ReinforceLandPlatoonDirect',
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 5, 15, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'none'},
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 12, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 3, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
	},
}

PlatoonTemplate { Name = 'ReinforceLandPlatoonIndirect',
    GlobalSquads = {
		{ categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 6, 'Attack', 'none'},
        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 5, 24, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 12, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 3, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
	},
}

PlatoonTemplate { Name = 'ReinforceLandPlatoonSupport',
    GlobalSquads = {
		{ categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 6, 'Attack', 'none'},
        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 4, 12, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 3, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
	},
}

PlatoonTemplate { Name = 'T1ArtilleryAttack',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 5, 15, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 4, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 1, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none'},
    },
}

PlatoonTemplate { Name = 'T1MassAttack',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 5, 15, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 4, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 1, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2MassAttack',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 24, 36, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 12, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 10, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 4, 'Support', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 3, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T3MassAttack',
    Plan = 'GuardPoint',
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 45, 80, 'Attack', 'none' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 18, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 10, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 5, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
    },
}

PlatoonTemplate { Name = 'T1LandAttack',
    Plan = 'LandForceAILOUD',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 6, 18, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 4, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 1, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2LandAttack',
    Plan = 'LandForceAILOUD',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 24, 36, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 12, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 10, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 4, 'Support', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T3LandAttack',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 40, 72, 'Attack', 'none' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 18, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 10, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 4, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
    },
}

PlatoonTemplate { Name = 'T3LandAttackNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 40, 72, 'Attack', 'none' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 18, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 10, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 5, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401, 0, 6, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'LandAttackHugeNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 70, 100, 'Attack', 'none' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 18, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 10, 'Guard', 'none'},
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 5, 'Guard', 'none'},
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 2, 'Support', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401, 0, 10, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'ReinforceAmphibiousPlatoon',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 6, 24, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 3, 'Guard', 'none'},
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T1AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 12, 24, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 1, 'Guard', 'none'},        
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T2AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 24, 40, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 8, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Guard', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none'},        
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T3AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 40, 60, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 18, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 10, 'Guard', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 2, 'Guard', 'none'},        
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'AmphibAttackHuge',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 60, 90, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 18, 'Guard', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 10, 'Guard', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 3, 'Guard', 'none'},        
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'BaseGuardMedium',

    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 13, 24, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 3, 'Attack', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'BaseGuardAAPatrol',

    GlobalSquads = {
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 4, 18, 'Guard', 'GrowthFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 3, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T1LandScoutForm',

    FactionSquads = {
        UEF = {
            { 'uel0101', 2, 4, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0101', 2, 2, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0101', 1, 1, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0101', 1, 2, 'Guard', 'none' }
        },
    }
}


PlatoonTemplate { Name = 'T1MassGuard',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL, 3, 5, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 1, 'Attack', 'AttackFormation' },		
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'T2MassGuard',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL, 5, 8, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 1, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 1, 'Guard', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },        
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'T2MassGuardSpecial',
    Plan = 'GuardPoint',    
    FactionSquads = {
        UEF = {
			{ categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ categories.LAND * categories.MOBILE * categories.SHIELD, 1, 1, 'Guard', 'AttackFormation' },
        },
        Aeon = {
			{ categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ categories.LAND * categories.MOBILE * categories.SHIELD, 1, 1, 'Guard', 'AttackFormation' },
        },
        Cybran = {
			{ categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 1, 1, 'Guard', 'none' },
        },
        Seraphim = {
			{ categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 1, 'Attack', 'AttackFormation' },
			{ categories.LAND * categories.MOBILE * categories.SHIELD, 1, 1, 'Guard', 'AttackFormation' },

        },
    }
}

PlatoonTemplate { Name = 'T2PointGuard',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 13, 24, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 5, 8, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 12, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 3, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T1PointGuardArtillery',
    Plan = 'GuardPoint',    
    GlobalSquads = {
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 5, 8, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 5, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 1, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
    },
}


PlatoonTemplate { Name = 'T2PointGuardArtillery',
    Plan = 'GuardPoint',    
    GlobalSquads = {
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 12, 24, 'Artillery', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 12, 'Guard', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.SHIELD, 0, 4, 'Guard', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },
		{ categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T4ExperimentalGroupAmphibious',

    Plan = 'AmphibForceAILOUD',
	
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, 11, 15, 'Artillery', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 0, 40, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.ANTIAIR), 0, 18, 'Support', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 4, 'Artillery', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 5, 'Attack', 'none' },
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SHIELD), 0, 1, 'Support', 'none' },        
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 2, 'Artillery', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 2, 'Attack', 'none' },
        { (categories.LAND * categories.AMPHIBIOUS * categories.COUNTERINTELLIGENCE), 0, 1, 'Support', 'none' },        
		{ (categories.LAND * categories.AMPHIBIOUS * categories.SCOUT), 0,  1, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'T4ExperimentalGroup',

    Plan = 'LandForceAILOUD',
	
    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, 11, 15, 'Artillery', 'none' },
        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 24, 'Attack', 'AttackFormation' },
		{ categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL, 0, 18, 'Artillery', 'none' },
		{ categories.LAND * categories.MOBILE * categories.ANTIAIR, 0, 18, 'Support', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 5, 'Artillery', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 5, 'Attack', 'none' },
		{ (categories.LAND * categories.MOBILE * categories.SHIELD), 0, 2, 'Support', 'none' },            
        { (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 3, 'Artillery', 'none' },
        { (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 3, 'Attack', 'none' },
        { (categories.LAND * categories.MOBILE * categories.COUNTERINTELLIGENCE), 0, 2, 'Support', 'none' },
        { (categories.LAND * categories.MOBILE * categories.SCOUT), 0, 1, 'Scout', 'none' },

    },
}

PlatoonTemplate { Name = 'ReinforceLandExperimental',

    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401, 1, 6, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'T4SatelliteExperimental',
    Plan = 'SatelliteAI',
    GlobalSquads = {
        { categories.SATELLITE, 1, 1, 'Attack', 'none' },
    }
}

----------------------------
----- NAVAL FORMATIONS -----
----------------------------
PlatoonTemplate { Name = 'T1WaterScoutForm',
    FactionSquads = {
        UEF = {
            { categories.FRIGATE, 2, 5, 'Guard', 'none' },
			{ categories.SUBMARINE + categories.LIGHTBOAT, 0, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Aeon = {
            { categories.FRIGATE, 3, 6, 'Guard', 'none' },
			{ categories.SUBMARINE, 3, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.LIGHTBOAT, 0, 2, 'Guard', 'none' },
        },
        Cybran = {
            { categories.FRIGATE, 3, 6, 'Guard', 'none' },
			{ categories.SUBMARINE, 3, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Seraphim = {
            { categories.FRIGATE, 3, 6, 'Guard', 'none' },
			{ categories.SUBMARINE, 3, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'MassAttackNaval',

    GlobalSquads = {
        { categories.SUBMARINE, 7, 15, 'Artillery', 'none' },			# Submarines		
    },
	
}


PlatoonTemplate { Name = 'SeaAttack Small',
	
	FactionSquads = {
	
		UEF = {
	
			{ categories.DESTROYER, 1, 6, 'Attack', 'none' },									# Destroyers
			{ categories.CRUISER, 2, 5, 'Artillery', 'none' },									# Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									# Frigates
			{ categories.SUBMARINE + categories.LIGHTBOAT, 7, 16, 'Attack', 'none' },			# Submarines & Coopers
			{ categories.DEFENSIVEBOAT, 1, 1, 'Guard', 'none' },								# UEF Shield

        },
		
        Aeon = {
	
			{ categories.DESTROYER, 2, 6, 'Attack', 'none' },									# Destroyers
			{ categories.CRUISER, 2, 5, 'Attack', 'none' },										# Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									# Frigates
			{ categories.SUBMARINE, 7, 12, 'Artillery', 'none' },								# Submarines
			{ categories.DEFENSIVEBOAT, 6, 6, 'Guard', 'none' },								# T1 Shard AA boat
		
        },
		
        Cybran = {
	
			{ categories.DESTROYER, 1, 6, 'Attack', 'none' },									# Destroyers
			{ categories.CRUISER, 2, 5, 'Artillery', 'none' },									# Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									# Frigates
			{ categories.SUBMARINE, 7, 12, 'Artillery', 'none' },								# Submarines
			{ categories.DEFENSIVEBOAT, 1, 1, 'Guard', 'none' },								# Cyb CounterIntel
			
        },
		
        Seraphim = {
	
			{ categories.DESTROYER, 1, 6, 'Artillery', 'none' },								# Destroyers
			{ categories.CRUISER, 2, 5, 'Attack', 'none' },										# Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									# Frigates
			{ categories.SUBMARINE, 7, 12, 'Artillery', 'none' },								# Submarines
			
        },	
	
	},

}

PlatoonTemplate { Name = 'SeaAttack Medium',

	FactionSquads = {
	
		UEF = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 3, 8, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE + categories.LIGHTBOAT, 7, 21, 'Attack', 'none' },							# Submarines and UEF Torp Boat
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers		
			{ categories.DEFENSIVEBOAT, 0, 4, 'Guard', 'none' },												# UEF Shield
			
		},
		
		Aeon = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 2, 8, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE, 7, 16, 'Attack', 'none' },													# Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers		
			{ categories.DEFENSIVEBOAT, 6, 8, 'Guard', 'none' },												# T1 Shard AA Boat
			
		},
		
		Cybran = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 2, 8, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE, 7, 16, 'Attack', 'none' },													# Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers		
			{ categories.DEFENSIVEBOAT, 2, 3, 'Guard', 'none' },												# CounterIntel
			
		},
	
		Seraphim = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 3, 8, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE, 7, 16, 'Attack', 'none' },													# Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers		
			
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Medium - Base Patrol',

    GlobalSquads = {
	
        { categories.DESTROYER, 0, 2, 'Attack', 'none' },									# Destroyers
        { categories.CRUISER, 0, 2, 'Attack', 'none' },										# Cruisers
        { categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },								# UEF Shield and Cyb CounterIntel
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Submarine - Base Patrol',

    GlobalSquads = {
	
        { categories.SUBMARINE + categories.LIGHTBOAT, 7, 16, 'Attack', 'none' },			# Submarines		
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Large',

    FactionSquads = {
	
		UEF = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE + categories.LIGHTBOAT, 7, 35, 'Attack', 'none' },							# Submarines & Coopers
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers
			{ categories.DEFENSIVEBOAT, 6, 8, 'Guard', 'none' },												# UEF Shield
			
		},
	
		Aeon = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE, 7, 25, 'Attack', 'none' },													# Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers
			{ categories.DEFENSIVEBOAT, 6, 10, 'Guard', 'none' },												# T1 AA Shard
			
		},
	
		Cybran = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE, 7, 25, 'Attack', 'none' },													# Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers
			{ categories.DEFENSIVEBOAT, 3, 6, 'Guard', 'none' },												# Cyb CounterIntel
			
		},
	
		Seraphim = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													# Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													# Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													# Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													# Frigates
			{ categories.SUBMARINE, 7, 25, 'Attack', 'none' },													# Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				# Carriers
			
		},		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Bombardment',

    FactionSquads = {
	
		UEF = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													# Cruisers
			{ categories.DEFENSIVEBOAT, 3, 4, 'Guard', 'none' },												# Shield
			
		},
		
		Aeon = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													# Cruisers
			{ categories.DEFENSIVEBOAT, 4, 8, 'Guard', 'none' },												# AA
		
		},
		
		Cybran = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													# Cruisers
			{ categories.DEFENSIVEBOAT, 2, 3, 'Guard', 'none' },												# CounterIntel
		
		},
		
		Seraphim = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													# Cruisers
		
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Reinforcement',

    GlobalSquads = {
	
		{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Support', 'none' },	    		# Carriers
        { categories.BATTLESHIP, 0, 4, 'Attack', 'none' },													# Capital Ships	
        { categories.DESTROYER, 1, 6, 'Attack', 'none' },													# Destroyers
        { categories.CRUISER, 1, 5, 'Attack', 'none' },														# Cruisers
        { categories.FRIGATE, 5, 8, 'Attack', 'none' },														# Frigates
        { categories.SUBMARINE, 0, 16, 'Attack', 'none' },													# Submarines		
        { categories.DEFENSIVEBOAT, 0, 12, 'Guard', 'none' },												# Shield CounterIntel AA
        { categories.LIGHTBOAT, 0, 12, 'Guard', 'none' },													# UEF Torp Boat
		
    },
	
}


PlatoonTemplate { Name = 'SeaNuke',
    GlobalSquads = {
        { categories.NAVAL * categories.NUKE, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate { Name = 'T4ExperimentalSea',
    Plan = 'ExperimentalAIHub',
	GlobalSquads = {
        { categories.NAVAL * categories.EXPERIMENTAL * categories.MOBILE, 1, 1, 'Attack', 'none' },
    },
}