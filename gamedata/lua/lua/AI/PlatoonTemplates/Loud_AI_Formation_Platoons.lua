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
        { AIRFIGHTER - categories.EXPERIMENTAL, 18, 32, 'Unassigned', 'AttackFormation' },
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
        { AIRFIGHTER, 3, 45, 'Unassigned', 'none' },
		{ AIRSCOUT, 0, 4, 'Support', 'none' }, 
    }
}


PlatoonTemplate { Name = 'BomberAttack Small',
    GlobalSquads = {
        { AIRBOMBER, 1, 12, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack',
    GlobalSquads = {
        { AIRBOMBER, 12, 24, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack Large',
    GlobalSquads = {
        { AIRBOMBER, 24, 40, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'BomberAttack Super',
    GlobalSquads = {
        { AIRBOMBER, 36, 60, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'Experimental Bomber',
    GlobalSquads = {
        { AIRBOMBER - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 3, 8, 'Attack', 'none' },
    },
}
PlatoonTemplate { Name = 'BomberReinforce',
    Plan = 'ReinforceAirAI',	-- either Land or Sea bases
    GlobalSquads = {
        { AIRBOMBER, 3, 24, 'Attack', 'none' },
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
		{ TORPBOMBER, 3, 48, 'Attack', 'AttackFormation' },
  		{ AIRSCOUT, 0, 4, 'Support', 'none' },
	}
}

PlatoonTemplate { Name = 'TorpedoAttack Small',
    GlobalSquads = {
        { TORPBOMBER, 1, 15, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack',
    GlobalSquads = {
        { TORPBOMBER, 16, 31, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate { Name = 'TorpedoAttack Large',
    GlobalSquads = {
        { TORPBOMBER, 32, 48, 'Attack', 'AttackFormation' },
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
----- LAND FORMATIONS ----
--------------------------

local LAND = categories.LAND * categories.MOBILE

local LANDAMPHIB = LAND * categories.AMPHIBIOUS
local LANDANTIAIR = LAND * categories.ANTIAIR
local LANDARTILLERY = LAND * categories.INDIRECTFIRE
local LANDCOUNTERINTEL = LAND * categories.COUNTERINTELLIGENCE
local LANDDIRECTFIRE = LAND * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER
local LANDSCOUT = categories.LAND * categories.SCOUT
local LANDSHIELD = LAND * categories.SHIELD

-- not that it's used much - but you can have factional differences -- have a look at the T1 Scouting Platoon where all factions have
-- 2 scouts except the Cybrans which only use 1 scout

PlatoonTemplate { Name = 'ReinforceLandPlatoonDirect',
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 5, 15, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'none'},
        { LANDANTIAIR, 0, 12, 'Guard', 'none'},
		{ LANDSHIELD, 0, 3, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Guard', 'none' },
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
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'ReinforceLandPlatoonSupport',
    GlobalSquads = {
		{ LANDDIRECTFIRE - categories.EXPERIMENTAL, 0, 6, 'Attack', 'none'},
        { LANDARTILLERY - categories.EXPERIMENTAL, 0, 4, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none'},
		{ LANDSHIELD, 0, 3, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Support', 'none' },
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T1ArtilleryAttack',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDARTILLERY, 12, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 1, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 1, 'Support', 'none'},
    },
}

PlatoonTemplate { Name = 'T1MassAttack',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 5, 18, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 6, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 2, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2MassAttack',
    Plan = 'GuardPoint',    
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 24, 36, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 12, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 4, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 3, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T3MassAttack',
    Plan = 'GuardPoint',
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL, 45, 80, 'Attack', 'none' },
		{ LANDARTILLERY, 15, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 5, 'Guard', 'none'},
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'T1LandAttack',
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.AMPHIBIOUS - categories.EXPERIMENTAL, 5, 18, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 6, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 2, 'Guard', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T2LandAttack',
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.AMPHIBIOUS - categories.EXPERIMENTAL, 24, 36, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 12, 'Artillery', 'AttackFormation' },
        { LANDANTIAIR, 0, 12, 'Guard', 'none' },
		{ LANDSHIELD, 0, 4, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 2, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'T3LandAttack',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDDIRECTFIRE - categories.AMPHIBIOUS, 40, 72, 'Attack', 'none' },
		{ LANDARTILLERY, 15, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 4, 'Guard', 'none'},
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'T3LandAttackNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDDIRECTFIRE, 40, 72, 'Attack', 'none' },
		{ LANDARTILLERY, 12, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 5, 'Guard', 'none'},
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'LandAttackHugeNW',
    Plan = 'LandForceAILOUD',
    GlobalSquads = {
        { LANDDIRECTFIRE, 60, 72, 'Attack', 'none' },
		{ LANDARTILLERY, 12, 24, 'Artillery', 'none' },
        { LANDANTIAIR, 0, 20, 'Guard', 'none' },
		{ LANDSHIELD, 0, 10, 'Support', 'none'},
		{ LANDCOUNTERINTEL, 0, 5, 'Guard', 'none'},
        { LANDSCOUT, 0, 2, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'ReinforceAmphibiousPlatoon',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 6, 24, 'Attack', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 8, 'Guard', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Support', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 3, 'Support', 'none'},
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T1AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 16, 30, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 8, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 8, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none'},        
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T2AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 24, 40, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 12, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 8, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 5, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none'},        
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
	},
}

PlatoonTemplate { Name = 'T3AmphibAttack',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 36, 48, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 18, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 18, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 10, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 2, 'Guard', 'none'},        
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
    },
}

PlatoonTemplate { Name = 'AmphibAttackHuge',
    Plan = 'AmphibForceAILOUD',
    GlobalSquads = {
        { LANDAMPHIB * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.SCOUT, 48, 70, 'Attack', 'none' },
        { LANDAMPHIB * categories.ARTILLERY, 0, 18, 'Artillery', 'none' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 18, 'Support', 'none' },
		{ LANDAMPHIB * categories.SHIELD, 0, 10, 'Guard', 'none' },
        { LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 3, 'Guard', 'none'},        
		{ LANDAMPHIB * categories.SCOUT, 0,  1, 'Scout', 'none' },
    },
}


PlatoonTemplate { Name = 'BaseGuardMedium',

    GlobalSquads = {
        { LANDDIRECTFIRE - categories.EXPERIMENTAL,  5, 18, 'Attack', 'AttackFormation' },
   		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 6, 'Artillery', 'none'},
		{ LANDSHIELD, 0, 4, 'Guard', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate { Name = 'BaseGuardAAPatrol',

    GlobalSquads = {
		{ LANDANTIAIR, 6, 12, 'Attack', 'GrowthFormation' },
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
            { LANDAMPHIB - categories.EXPERIMENTAL - categories.SCOUT, 0, 2, 'Attack', 'none' }
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
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL, 2, 5, 'Attack', 'AttackFormation' },
		{ LANDARTILLERY - categories.EXPERIMENTAL, 0, 2, 'Artillery', 'AttackFormation' },
		{ LANDANTIAIR, 0, 2, 'Support', 'AttackFormation' },		
		{ LANDSHIELD, 0, 1, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
        { LANDSCOUT, 0, 1, 'Scout', 'none' },        
    },
}

PlatoonTemplate { Name = 'T1AmphibMassGuard',

    GlobalSquads = {
        { LANDAMPHIB - categories.SCOUT - categories.EXPERIMENTAL, 3, 6, 'Attack', 'AttackFormation' },
		{ LANDAMPHIB * categories.ANTIAIR, 0, 1, 'Support', 'AttackFormation' },		
		{ LANDAMPHIB * categories.COUNTERINTELLIGENCE, 0, 1, 'Guard', 'none' },
        { LANDAMPHIB * categories.SCOUT, 0, 1, 'Scout', 'none' },        
    },
}

PlatoonTemplate { Name = 'T1PointGuardArtillery',

    GlobalSquads = {
        { (categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.AMPHIBIOUS) - categories.SCOUT - categories.EXPERIMENTAL, 0, 5, 'Attack', 'AttackFormation' },    
		{ LANDARTILLERY - categories.EXPERIMENTAL, 3, 8, 'Artillery', 'AttackFormation' },
		{ LANDANTIAIR, 0, 5, 'Guard', 'none' },
		{ LANDSHIELD, 0, 1, 'Support', 'none' },
		{ LANDCOUNTERINTEL, 0, 1, 'Guard', 'none' },
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
PlatoonTemplate { Name = 'T1WaterScoutForm',
    FactionSquads = {
        UEF = {
            { categories.FRIGATE, 2, 7, 'Guard', 'none' },
			{ categories.SUBMARINE + categories.LIGHTBOAT, 0, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Aeon = {
            { categories.FRIGATE, 3, 8, 'Guard', 'none' },
			{ categories.SUBMARINE, 3, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.DEFENSIVEBOAT, 0, 2, 'Guard', 'none' },
        },
        Cybran = {
            { categories.FRIGATE, 3, 8, 'Guard', 'none' },
			{ categories.SUBMARINE, 3, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Seraphim = {
            { categories.FRIGATE, 3, 8, 'Guard', 'none' },
			{ categories.SUBMARINE, 3, 5, 'Guard', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'MassAttackNaval',

    GlobalSquads = {
        { categories.SUBMARINE, 7, 15, 'Artillery', 'none' },			--Submarines		
    },
	
}


PlatoonTemplate { Name = 'SeaAttack Small',
	
	FactionSquads = {
	
		UEF = {
	
			{ categories.DESTROYER, 1, 6, 'Attack', 'none' },									--Destroyers
			{ categories.CRUISER, 2, 5, 'Artillery', 'none' },									--Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			{ categories.DEFENSIVEBOAT, 1, 1, 'Guard', 'none' },								--UEF Shield

        },
		
        Aeon = {
	
			{ categories.DESTROYER, 2, 6, 'Attack', 'none' },									--Destroyers
			{ categories.CRUISER, 2, 5, 'Artillery', 'none' },									--Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			{ categories.DEFENSIVEBOAT, 0, 6, 'Guard', 'none' },								--T1 Shard AA boat
		
        },
		
        Cybran = {
	
			{ categories.DESTROYER, 1, 6, 'Attack', 'none' },									--Destroyers
			{ categories.CRUISER, 2, 5, 'Artillery', 'none' },									--Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			{ categories.DEFENSIVEBOAT, 1, 1, 'Guard', 'none' },								--Cyb CounterIntel
			
        },
		
        Seraphim = {
	
			{ categories.DESTROYER, 1, 6, 'Artillery', 'none' },								--Destroyers
			{ categories.CRUISER, 2, 5, 'Attack', 'none' },										--Cruisers
			{ categories.FRIGATE, 5, 12, 'Attack', 'none' },									--Frigates
			
        },	
	
	},

}

PlatoonTemplate { Name = 'SeaAttack Medium',

	FactionSquads = {
	
		UEF = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 3, 8, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE + categories.LIGHTBOAT, 7, 21, 'Attack', 'none' },							--Submarines and UEF Torp Boat
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			{ categories.DEFENSIVEBOAT, 2, 4, 'Guard', 'none' },												--UEF Shield
			
		},
		
		Aeon = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 3, 8, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE, 7, 16, 'Attack', 'none' },													--Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			{ categories.DEFENSIVEBOAT, 0, 8, 'Guard', 'none' },												--T1 Shard AA Boat
			
		},
		
		Cybran = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 2, 8, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE, 7, 16, 'Attack', 'none' },													--Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			{ categories.DEFENSIVEBOAT, 2, 3, 'Guard', 'none' },												--CounterIntel
			
		},
	
		Seraphim = {

			{ categories.BATTLESHIP, 1, 4, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 3, 8, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 10, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 15, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE, 7, 16, 'Attack', 'none' },													--Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers		
			
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Medium - Base Patrol',

    GlobalSquads = {
	
        { categories.DESTROYER, 0, 2, 'Attack', 'none' },									--Destroyers
        { categories.CRUISER, 0, 2, 'Attack', 'none' },										--Cruisers
        { categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },								--UEF Shield, AEON Shard, Cyb CounterIntel
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Submarine - Base Patrol',

    GlobalSquads = {
	
        { categories.SUBMARINE + categories.LIGHTBOAT, 4, 12, 'Attack', 'none' },			--Submarines		
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Large',

    FactionSquads = {
	
		UEF = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE + categories.LIGHTBOAT, 7, 35, 'Attack', 'none' },							--Submarines & Coopers
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			{ categories.DEFENSIVEBOAT, 6, 8, 'Guard', 'none' },												--UEF Shield
			
		},
	
		Aeon = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE, 7, 25, 'Attack', 'none' },													--Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			{ categories.DEFENSIVEBOAT, 0, 10, 'Guard', 'none' },												--T1 AA Shard
			
		},
	
		Cybran = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE, 7, 25, 'Attack', 'none' },													--Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			{ categories.DEFENSIVEBOAT, 3, 6, 'Guard', 'none' },												--Cyb CounterIntel
			
		},
	
		Seraphim = {

			{ categories.BATTLESHIP, 3, 8, 'Attack', 'none' },													--Capital Ships
			{ categories.DESTROYER, 5, 12, 'Attack', 'none' },													--Destroyers
			{ categories.CRUISER, 4, 15, 'Attack', 'none' },													--Cruisers
			{ categories.FRIGATE, 5, 18, 'Attack', 'none' },													--Frigates
			{ categories.SUBMARINE, 7, 25, 'Attack', 'none' },													--Submarines
			{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Guard', 'none' },				--Carriers
			
		},		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Bombardment',

    FactionSquads = {
	
		UEF = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													--Cruisers
			{ categories.DEFENSIVEBOAT, 3, 4, 'Guard', 'none' },												--Shield
			
		},
		
		Aeon = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													--Cruisers
			{ categories.DEFENSIVEBOAT, 0, 8, 'Guard', 'none' },												--AA
		
		},
		
		Cybran = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													--Cruisers
			{ categories.DEFENSIVEBOAT, 2, 3, 'Guard', 'none' },												--CounterIntel
		
		},
		
		Seraphim = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												--Bombardment capable ships
			{ categories.CRUISER, 4, 8, 'Support', 'none' },													--Cruisers
		
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Raiding',

    FactionSquads = {
	
		UEF = {
	
			{ categories.FRIGATE, 4, 10, 'Artillery', 'none' },
            { categories.DESTROYER, 0, 2, 'Support', 'none' },
            { categories.CRUISER, 0, 2, 'Guard', 'none' },
            { categories.DEFENSIVEBOAT, 0, 2, 'Guard', 'none' }
			
		},
		
		Aeon = {
	
			{ categories.FRIGATE, 4, 10, 'Artillery', 'none' },												--Bombardment capable ships
            { categories.DESTROYER, 0, 2, 'Support', 'none' },
            { categories.CRUISER, 0, 2, 'Guard', 'none' },
            { categories.DEFENSIVEBOAT, 0, 2, 'Guard', 'none' }
		
		},
		
		Cybran = {
	
			{ categories.FRIGATE, 4, 10, 'Artillery', 'none' },												--Bombardment capable ships
            { categories.DESTROYER, 0, 2, 'Support', 'none' },
            { categories.CRUISER, 0, 2, 'Guard', 'none' },
            { categories.DEFENSIVEBOAT, 0, 2, 'Guard', 'none' }
		
		},
		
		Seraphim = {
	
			{ categories.FRIGATE, 4, 10, 'Artillery', 'none' },												--Bombardment capable ships
            { categories.DESTROYER, 0, 2, 'Support', 'none' },
            { categories.CRUISER, 0, 2, 'Guard', 'none' },
		
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Reinforcement',

    GlobalSquads = {
	
		{ categories.MOBILE * categories.NAVAL * categories.CARRIER, 0, 1, 'Support', 'none' },	    		--Carriers
        { categories.BATTLESHIP, 0, 4, 'Attack', 'none' },													--Capital Ships	
        { categories.DESTROYER, 0, 6, 'Attack', 'none' },													--Destroyers
        { categories.CRUISER, 0, 5, 'Attack', 'none' },														--Cruisers
        { categories.FRIGATE, 2, 6, 'Attack', 'none' },														--Frigates
        { categories.SUBMARINE, 0, 16, 'Attack', 'none' },													--Submarines		
        { categories.DEFENSIVEBOAT, 0, 12, 'Guard', 'none' },												--Shield CounterIntel AA
        { categories.LIGHTBOAT, 0, 12, 'Guard', 'none' },													--UEF Torp Boat
		
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