-- File: /lua/ai/Loud_Air_Platoon_Templates.lua

-- determines the composition of platoons built by the Platoon Manager
--------------------------
----- AIR FORMATIONS -----
--------------------------
local AIRBOMBER = categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY 
local AIRFIGHTER = categories.HIGHALTAIR * categories.ANTIAIR
local AIRGUNSHIP = categories.AIR * categories.GROUNDATTACK
local AIRSCOUT = categories.AIR * categories.SCOUT
local TORPBOMBER = categories.HIGHALTAIR * categories.ANTINAVY - categories.EXPERIMENTAL

PlatoonTemplate { Name = 'FighterAttack Small',
    GlobalSquads = {
        { AIRFIGHTER - categories.EXPERIMENTAL, 2, 12, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'FighterAttack',
    GlobalSquads = {
        { AIRFIGHTER - categories.EXPERIMENTAL, 18, 36, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'FighterAttack Large',
    GlobalSquads = {
        { AIRFIGHTER - categories.EXPERIMENTAL, 24, 48, 'Unassigned', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'FighterReinforce',
    Plan = 'ReinforceAirAI',	-- to either land or sea bases
    GlobalSquads = {
        { AIRFIGHTER, 3, 45, 'Attack', 'none' },
		{ AIRSCOUT, 0, 4, 'Support', 'none' }, 
    }
}


PlatoonTemplate { Name = 'BomberAttack Small',
    GlobalSquads = {
        { AIRBOMBER, 1, 12, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack',
    GlobalSquads = {
        { AIRBOMBER, 12, 24, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack Large',
    GlobalSquads = {
        { AIRBOMBER, 24, 40, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack Super',
    GlobalSquads = {
        { AIRBOMBER, 36, 60, 'Unassigned', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'Experimental Bomber',
    GlobalSquads = {
        { AIRBOMBER - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 3, 8, 'Unassigned', 'none' },
    },
}

PlatoonTemplate { Name = 'BomberReinforce',
    Plan = 'ReinforceAirAI',	-- either Land or Sea bases
    GlobalSquads = {
        { AIRBOMBER, 3, 24, 'Unassigned', 'none' },
		{ AIRSCOUT, 0, 4, 'Support', 'none' },
    }
}


PlatoonTemplate { Name = 'GunshipAttack Small',
    GlobalSquads = {
        { AIRGUNSHIP, 1, 15, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'GunshipAttack',
    GlobalSquads = {
        { AIRGUNSHIP, 16, 30, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 4, 'Attack', 'none' },
    }
}
PlatoonTemplate { Name = 'GunshipAttack Large',
    GlobalSquads = {
        { AIRGUNSHIP, 28, 45, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 6, 'Attack', 'none' },
    }
}
PlatoonTemplate { Name = 'GunshipAttack Super',
    GlobalSquads = {
        { AIRGUNSHIP, 42, 60, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 6, 'Attack', 'none' },
    }
}

PlatoonTemplate { Name = 'Experimental Gunship',
    GlobalSquads = {
        { (categories.AIR * categories.EXPERIMENTAL * categories.MOBILE * categories.GROUNDATTACK) - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 4, 8, 'Attack', 'none' },
		{ (categories.bea0402), 0, 8, 'guard', 'none' },
    },
}

PlatoonTemplate { Name = 'GunshipReinforce',
    Plan = 'ReinforceAirAI',	-- either Land or Sea bases
    GlobalSquads = {
        { AIRGUNSHIP, 3, 35, 'Attack', 'none' },
		{ AIRSCOUT, 0, 4, 'Support', 'none' },
    }
}

PlatoonTemplate { Name = 'Air Scout Formation',
    GlobalSquads = {
        { AIRSCOUT, 1, 1, 'scout', 'none' },
    }
}
PlatoonTemplate { Name = 'Air Scout Group',
    GlobalSquads = {
        { AIRSCOUT, 2, 2, 'scout', 'none' },
    }
}
PlatoonTemplate { Name = 'Air Scout Group Large',
    GlobalSquads = {
        { AIRSCOUT, 5, 5, 'scout', 'ScatterFormation' },
    }
}
PlatoonTemplate { Name = 'Air Scout Group Huge',
    GlobalSquads = {
        { AIRSCOUT, 9, 9, 'scout', 'ScatterFormation' },
    }
}


PlatoonTemplate { Name = 'TorpedoReinforce',
	GlobalSquads = {
		{ TORPBOMBER, 3, 48, 'Unassigned', 'AttackFormation' },
  		{ AIRSCOUT, 0, 4, 'Support', 'none' },
	}
}

PlatoonTemplate { Name = 'TorpedoAttack Small',
    GlobalSquads = {
        { TORPBOMBER, 1, 15, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack',
    GlobalSquads = {
        { TORPBOMBER, 16, 31, 'Unassigned', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack Large',
    GlobalSquads = {
        { TORPBOMBER, 32, 48, 'Unassigned', 'AttackFormation' },
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

PlatoonTemplate { Name = 'CzarTerrorAssault',

	FactionSquads = {
		Aeon = {
			{ categories.uaa0310, 4, 8, 'Attack', 'none' }
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
----- LAND FORMATIONS ----
--------------------------

local LAND          = categories.LAND * categories.MOBILE

local LANDAMPHIB        = LAND * categories.AMPHIBIOUS
local LANDANTIAIR       = LAND * categories.ANTIAIR
local LANDARTILLERY     = LAND * categories.INDIRECTFIRE
local LANDCOUNTERINTEL  = LAND * categories.COUNTERINTELLIGENCE
local LANDDIRECTFIRE    = LAND * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER
local LANDSCOUT         = LAND * categories.SCOUT
local LANDSHIELD        = LAND * categories.SHIELD
local LANDTMD           = LAND * categories.ANTIMISSILE - categories.SILO
local LANDSMD           = LAND * categories.ANTIMISSILE * categories.SILO

-- not that it's used much - but you can have factional differences -- have a look at the T1 Scouting Platoon where all factions have
-- 2 scouts except the Cybrans which only use 1 scout

PlatoonTemplate { Name = 'ReinforceLandPlatoonDirect',
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 5, 15, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'none'},
        { LANDANTIAIR, 0, 12, 'Guard', 'none'},
		{ LANDSHIELD, 0, 3, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Guard', 'none' },
        { LANDTMD, 0, 2, 'Guard', 'none' },
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'ReinforceLandPlatoonIndirect',
    GlobalSquads = {
		{ LANDDIRECTFIRE - categories.EXPERIMENTAL, 0, 6, 'Attack', 'none'},
        { LANDARTILLERY - categories.EXPERIMENTAL, 5, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none'},
		{ LANDSHIELD, 0, 3, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Support', 'none' },
        { LANDTMD, 0, 2, 'Guard', 'none' },
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'ReinforceLandPlatoonSupport',
    GlobalSquads = {
		{ LANDDIRECTFIRE - categories.EXPERIMENTAL, 0, 6, 'Attack', 'none'},
        { LANDARTILLERY - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none'},
		{ LANDSHIELD, 0, 3, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 3, 'Support', 'none' },
        { LANDTMD, 0, 3, 'Guard', 'none' },
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 3, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T1ArtilleryAttack',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDARTILLERY, 12, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 1, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 1, 'Support', 'none'},
        { LANDTMD, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T1MassAttack',

    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 5, 18, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 6, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 2, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
        { LANDTMD, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2MassAttack',

    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 24, 48, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 12, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 4, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 3, 'Guard', 'none' },
        { LANDTMD, 0, 2, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T3MassAttack',

    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 40, 66, 'Attack', 'none' },
		{ LANDARTILLERY, 12, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 5, 'Guard', 'none'},
        { LANDTMD, 0, 3, 'Guard', 'none' },        
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'T1LandAttack',

    GlobalSquads = {
        { LANDDIRECTFIRE - categories.AMPHIBIOUS - categories.EXPERIMENTAL, 5, 20, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 8, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 2, 'Guard', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
        { LANDTMD, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2LandAttack',

    GlobalSquads = {
        { LANDDIRECTFIRE - LANDAMPHIB, 24, 40, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY, 0, 15, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 4, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Guard', 'none' },
        { LANDTMD, 0, 2, 'Guard', 'none' },        
    },
}

PlatoonTemplate { Name = 'T2LandAttackNW',

    GlobalSquads = {
        { LANDDIRECTFIRE, 24, 40, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY, 0, 15, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 4, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Guard', 'none' },
        { LANDTMD, 0, 2, 'Guard', 'none' },        
    },
}

PlatoonTemplate { Name = 'T3LandAttack',

    GlobalSquads = {
        { LANDDIRECTFIRE - LANDAMPHIB, 40, 60, 'Attack', 'none' },
		{ LANDARTILLERY, 10, 20, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 4, 'Guard', 'none'},
        { LANDTMD, 0, 3, 'Guard', 'none' },        
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'T3LandAttackNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDDIRECTFIRE, 40, 60, 'Attack', 'none' },
		{ LANDARTILLERY, 10, 20, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 5, 'Guard', 'none'},
        { LANDTMD, 0, 4, 'Guard', 'none' },        
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'LandAttackHugeNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDDIRECTFIRE, 55, 72, 'Attack', 'none' },
		{ LANDARTILLERY, 12, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 5, 'Guard', 'none'},
        { LANDTMD, 0, 5, 'Guard', 'none' },        
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'ReinforceAmphibiousPlatoon',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 6, 24, 'Attack', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 8, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Support', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 3, 'Support', 'none'},
        { LANDAMPHIB * LANDTMD, 0, 2, 'Guard', 'none' },        
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T1AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 20, 32, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 8, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 8, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none'},        
        { LANDAMPHIB * LANDTMD, 0, 1, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T2AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 30, 45, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 12, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 8, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none'},        
        { LANDAMPHIB * LANDTMD, 0, 2, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T3AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 40, 65, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 18, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 18, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 10, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none'},        
        { LANDAMPHIB * LANDTMD, 0, 3, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'AmphibAttackHuge',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 48, 75, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 18, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 18, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 10, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 3, 'Guard', 'none'},        
        { LANDAMPHIB * LANDTMD, 0, 6, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'BaseGuardMedium',

    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL,  5, 18, 'Attack', 'AttackFormation' },
   		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 6, 'Artillery', 'none'},
		{ LANDSHIELD, 0, 4, 'Guard', 'none' },
        { LANDSMD, 0, 1, 'Support', 'none' },        
        { LANDTMD, 0, 2, 'Guard', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'BaseGuardAAPatrol',

    GlobalSquads = {
		{ LANDANTIAIR, 5, 8, 'Attack', 'GrowthFormation' },
		{ LANDSHIELD, 0, 3, 'Guard', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T1LandScoutForm',

    FactionSquads = {
        UEF = {
            { 'uel0101', 2, 2, 'Scout', 'none' }
        },
        Aeon = {
            { 'ual0101', 2, 3, 'Scout', 'none' },
            { LANDAMPHIB * categories.DIRECTFIRE - categories.EXPERIMENTAL - categories.SCOUT, 0, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'url0101', 1, 1, 'Scout', 'none' }
        },
        Seraphim = {
            { 'xsl0101', 1, 1, 'Scout', 'none' }
        },
    }
}


PlatoonTemplate { Name = 'T1MassGuard',

    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.EXPERIMENTAL, 2, 6, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ LANDANTIAIR, 0, 2, 'Support', 'AttackFormation' },		
		{ LANDSHIELD, 0, 1, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
        { LANDTMD, 0, 1, 'Guard', 'none' },        
        { LANDSCOUT, 0, 1, 'Scout', 'none' },        
    },
}

PlatoonTemplate { Name = 'T1AmphibMassGuard',

    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT - categories.EXPERIMENTAL, 3, 6, 'Attack', 'AttackFormation' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 1, 'Support', 'AttackFormation' },		
		{ LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
        { LANDAMPHIB * LANDTMD, 0, 1, 'Guard', 'none' },
        { LANDAMPHIB * categories.SCOUT, 0, 1, 'Scout', 'none' },        
    },
}

PlatoonTemplate { Name = 'T1PointGuardArtillery',

    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE) - categories.SCOUT - categories.EXPERIMENTAL, 0, 5, 'Attack', 'AttackFormation' },    
		{ LANDARTILLERY - categories.EXPERIMENTAL, 3, 8, 'Artillery', 'AttackFormation' },
		{ LANDANTIAIR, 0, 5, 'Guard', 'none' },
		{ LANDSHIELD, 0, 1, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
        { LANDAMPHIB * LANDTMD, 0, 1, 'Guard', 'none' },
        { LANDSCOUT, 0, 1, 'Scout', 'none' },        
    },
}

PlatoonTemplate { Name = 'T4ExperimentalGroupAmphibious',

    Plan = 'AmphibForceAILOUD',
	
    GlobalSquads = {
        { LANDAMPHIB * categories.EXPERIMENTAL - categories.url0401 - categories.INSIGNIFICANTUNIT, 7, 15, 'Artillery', 'none' },

        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 0, 40, 'Attack', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 18, 'Guard', 'none' },
        
		{ LANDAMPHIB * categories.SHIELD, 0, 3, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Support', 'none' },

        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 3, 'Support', 'none' },
        
        { LANDAMPHIB * LANDTMD, 0, 4, 'Guard', 'none' },        
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'T4ExperimentalGroup',

    Plan = 'LandForceAILOUD',
	
    GlobalSquads = {
        { LANDAMPHIB * categories.EXPERIMENTAL - categories.url0401 - categories.INSIGNIFICANTUNIT, 7, 15, 'Artillery', 'none' },

        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 0, 24, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 18, 'Artillery', 'none' },
        
		{ LANDANTIAIR, 0, 20, 'Guard', 'none' },
        
		{ LANDSHIELD, 0, 5, 'Guard', 'none' },
		{ LANDSHIELD, 0, 7, 'Support', 'none' },            
        
        { LANDCOUNTERINTEL, 0, 3, 'Guard', 'none' },
        { LANDCOUNTERINTEL, 0, 5, 'Support', 'none' },

        { LANDTMD, 0, 5, 'Guard', 'none' },        
        { LANDSMD, 0, 1, 'Support', 'none' },
        { LANDSCOUT, 0, 1, 'Scout', 'none' },

    },
}

PlatoonTemplate { Name = 'ReinforceLandExperimental',

    GlobalSquads = {
        { LANDAMPHIB * categories.EXPERIMENTAL - categories.url0401, 1, 8, 'Attack', 'none' },
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

local NAVAL         = categories.NAVAL * categories.MOBILE

local NAVALT4       = NAVAL * categories.EXPERIMENTAL

local FRIGATE       = categories.FRIGATE
local SUBMARINE     = categories.SUBMARINE
local CRUISER       = categories.CRUISER
local DESTROYER     = categories.DESTROYER
local DEFENSIVEBOAT = categories.DEFENSIVEBOAT
local LIGHTBOAT     = categories.LIGHTBOAT
local BATTLESHIP    = categories.BATTLESHIP

PlatoonTemplate { Name = 'T1WaterScoutForm',
    FactionSquads = {
        UEF = {
            { FRIGATE, 2, 7, 'Guard', 'none' },
			{ SUBMARINE + LIGHTBOAT, 0, 5, 'Guard', 'none' },
			{ CRUISER, 0, 1, 'Guard', 'none' },
			{ DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Aeon = {
            { FRIGATE, 3, 8, 'Guard', 'none' },
			{ SUBMARINE, 3, 5, 'Guard', 'none' },
			{ CRUISER, 0, 1, 'Guard', 'none' },
			{ DEFENSIVEBOAT, 0, 2, 'Guard', 'none' },
        },
        Cybran = {
            { FRIGATE, 3, 8, 'Guard', 'none' },
			{ SUBMARINE, 3, 5, 'Guard', 'none' },
			{ CRUISER, 0, 1, 'Guard', 'none' },
			{ DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Seraphim = {
            { FRIGATE, 3, 8, 'Guard', 'none' },
			{ SUBMARINE, 3, 5, 'Guard', 'none' },
			{ CRUISER, 0, 1, 'Guard', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'MassAttackNaval',

    GlobalSquads = {
        { SUBMARINE, 9, 15, 'Artillery', 'none' },			--Submarines		
    },
	
}


PlatoonTemplate { Name = 'SeaAttack Small',
	
	FactionSquads = {
	
		UEF = {
	
			{ DESTROYER, 1, 6, 'Attack', 'none' },									--Destroyers
			{ CRUISER, 2, 5, 'Artillery', 'none' },									--Cruisers
			{ FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			{ DEFENSIVEBOAT, 1, 2, 'Guard', 'none' },								--UEF Shield
            { SUBMARINE + LIGHTBOAT, 9, 15, 'Attack', 'none' },			--Submarines
        },
		
        Aeon = {
	
			{ DESTROYER, 2, 6, 'Attack', 'none' },									--Destroyers
			{ CRUISER, 2, 5, 'Artillery', 'none' },									--Cruisers
			{ FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			{ DEFENSIVEBOAT, 0, 6, 'Guard', 'none' },								--T1 Shard AA boat
            { SUBMARINE, 9, 15, 'Attack', 'none' },			--Submarines		
        },
		
        Cybran = {
	
			{ DESTROYER, 1, 6, 'Attack', 'none' },									--Destroyers
			{ CRUISER, 2, 5, 'Artillery', 'none' },									--Cruisers
			{ FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			{ DEFENSIVEBOAT, 1, 1, 'Guard', 'none' },								--Cyb CounterIntel
	        { SUBMARINE, 9, 15, 'Attack', 'none' },			--Submarines		
        },
		
        Seraphim = {
	
			{ DESTROYER, 1, 6, 'Artillery', 'none' },								--Destroyers
			{ CRUISER, 2, 5, 'Attack', 'none' },										--Cruisers
			{ FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
            { SUBMARINE, 9, 15, 'Attack', 'none' },			--Submarines			
        },	
	
	},

}

PlatoonTemplate { Name = 'SeaAttack Medium',

	FactionSquads = {
	
		UEF = {

            { NAVALT4, 0, 1, 'Artillery', 'none' },
			{ BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 3, 8, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ SUBMARINE + LIGHTBOAT, 9, 21, 'Attack', 'none' },							--Submarines and UEF Torp Boat
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			{ DEFENSIVEBOAT, 2, 4, 'Guard', 'none' },												--UEF Shield
			
		},
		
		Aeon = {
        
            { NAVALT4, 0, 1, 'Artillery', 'none' },
			{ BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 3, 8, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ SUBMARINE, 9, 20, 'Attack', 'none' },													--Submarines
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			{ DEFENSIVEBOAT, 0, 8, 'Guard', 'none' },												--T1 Shard AA Boat
			
		},
		
		Cybran = {
        
            { NAVALT4, 0, 1, 'Artillery', 'none' },
			{ BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 2, 8, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ SUBMARINE, 9, 20, 'Attack', 'none' },													--Submarines
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			{ DEFENSIVEBOAT, 2, 3, 'Guard', 'none' },												--CounterIntel
			
		},
	
		Seraphim = {
        
            { NAVALT4, 0, 1, 'Artillery', 'none' },
			{ BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 3, 8, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ SUBMARINE, 9, 20, 'Attack', 'none' },													--Submarines
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Medium - Base Patrol',

    GlobalSquads = {
	
        { DESTROYER, 0, 2, 'Attack', 'none' },									--Destroyers
        { CRUISER, 0, 2, 'Attack', 'none' },										--Cruisers
        { DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },								--UEF Shield, AEON Shard, Cyb CounterIntel
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Submarine - Base Patrol',

    GlobalSquads = {
	
        { SUBMARINE + LIGHTBOAT, 4, 12, 'Attack', 'none' },			--Submarines		
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Large',

    FactionSquads = {
	
		UEF = {
            { NAVALT4, 0, 2, 'Artillery', 'none' },
			{ BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 7, 18, 'Attack', 'none' },													--Frigates
			{ SUBMARINE + LIGHTBOAT, 15, 35, 'Attack', 'none' },                     							--Submarines & Coopers
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			{ DEFENSIVEBOAT, 6, 8, 'Guard', 'none' },												--UEF Shield
			
		},
	
		Aeon = {
            { NAVALT4, 0, 2, 'Artillery', 'none' },
			{ BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 7, 18, 'Attack', 'none' },													--Frigates
			{ SUBMARINE, 9, 25, 'Attack', 'none' },													--Submarines
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			{ DEFENSIVEBOAT, 0, 10, 'Guard', 'none' },												--T1 AA Shard
			
		},
	
		Cybran = {
            { NAVALT4, 0, 2, 'Artillery', 'none' },
			{ BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 7, 18, 'Attack', 'none' },													--Frigates
			{ SUBMARINE, 9, 25, 'Attack', 'none' },													--Submarines
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			{ DEFENSIVEBOAT, 3, 6, 'Guard', 'none' },												--Cyb CounterIntel
			
		},
	
		Seraphim = {
            { NAVALT4, 0, 2, 'Artillery', 'none' },
			{ BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ FRIGATE, 7, 18, 'Attack', 'none' },													--Frigates
			{ SUBMARINE, 9, 25, 'Attack', 'none' },													--Submarines
			{ NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			
		},		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Local',

    FactionSquads = {
	
		UEF = {
	
			{ FRIGATE, 4, 6, 'Artillery', 'none' },
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
            { DEFENSIVEBOAT, 0, 1, 'Guard', 'none' }
			
		},
		
		Aeon = {
	
			{ FRIGATE, 4, 6, 'Artillery', 'none' },												--Bombardment capable ships
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
            { DEFENSIVEBOAT, 0, 1, 'Guard', 'none' }
		
		},
		
		Cybran = {
	
			{ FRIGATE, 4, 6, 'Artillery', 'none' },												--Bombardment capable ships
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
            { DEFENSIVEBOAT, 0, 1, 'Guard', 'none' }
		
		},
		
		Seraphim = {
	
			{ FRIGATE, 4, 6, 'Artillery', 'none' },												--Bombardment capable ships
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
		
		},
		
    },
	
}


PlatoonTemplate { Name = 'SeaAttack Raiding',

    FactionSquads = {
	
		UEF = {
	
			{ FRIGATE, 4, 10, 'Artillery', 'none' },
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
            { DEFENSIVEBOAT, 0, 2, 'Guard', 'none' }
			
		},
		
		Aeon = {
	
			{ FRIGATE, 4, 10, 'Artillery', 'none' },												--Bombardment capable ships
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
            { DEFENSIVEBOAT, 0, 2, 'Guard', 'none' }
		
		},
		
		Cybran = {
	
			{ FRIGATE, 4, 10, 'Artillery', 'none' },												--Bombardment capable ships
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
            { DEFENSIVEBOAT, 0, 2, 'Guard', 'none' }
		
		},
		
		Seraphim = {
	
			{ FRIGATE, 4, 10, 'Artillery', 'none' },												--Bombardment capable ships
            { DESTROYER, 0, 4, 'Support', 'none' },
            { CRUISER, 0, 4, 'Guard', 'none' },
		
		},
		
    },
	
}


PlatoonTemplate { Name = 'SeaAttack Bombardment',

    FactionSquads = {
	
		UEF = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ CRUISER, 2, 8, 'Support', 'none' },													--Cruisers
			{ FRIGATE, 4, 6, 'Guard', 'none' },  													--Frigates
			{ DEFENSIVEBOAT, 2, 4, 'Guard', 'none' },												--Shield
			
		},
		
		Aeon = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ CRUISER, 2, 8, 'Support', 'none' },													--Cruisers
			{ FRIGATE, 4, 6, 'Guard', 'none' },  													--Frigates
			{ DEFENSIVEBOAT, 0, 4, 'Guard', 'none' },												--AA
		
		},
		
		Cybran = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ CRUISER, 2, 8, 'Support', 'none' },													--Cruisers
			{ FRIGATE, 4, 6, 'Guard', 'none' },  													--Frigates
			{ DEFENSIVEBOAT, 1, 3, 'Guard', 'none' },												--CounterIntel
		
		},
		
		Seraphim = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ CRUISER, 2, 8, 'Support', 'none' },													--Cruisers
			{ FRIGATE, 4, 6, 'Guard', 'none' },  													--Frigates
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Reinforcement',

    GlobalSquads = {
	
		{ NAVAL * categories.CARRIER, 0, 1, 'Support', 'none' },	    		--Carriers
        { BATTLESHIP, 0, 6, 'Attack', 'none' },													--Capital Ships	
        { DESTROYER, 0, 6, 'Attack', 'none' },													--Destroyers
        { CRUISER, 0, 5, 'Attack', 'none' },														--Cruisers
        { FRIGATE, 0, 6, 'Attack', 'none' },														--Frigates
        { SUBMARINE, 0, 16, 'Attack', 'none' },													--Submarines		
        { DEFENSIVEBOAT, 0, 12, 'Guard', 'none' },												--Shield CounterIntel AA
        { categories.LIGHTBOAT, 0, 12, 'Guard', 'none' },													--UEF Torp Boat
		
    },
	
}


PlatoonTemplate { Name = 'SeaNuke',
    GlobalSquads = {
        { NAVAL * categories.NUKE, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate { Name = 'T4ExperimentalSea',
    Plan = 'ExperimentalAIHub',
	GlobalSquads = {
        { NAVAL * categories.EXPERIMENTAL, 1, 1, 'Attack', 'none' },
    },
}