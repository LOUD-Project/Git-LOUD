--   /lua/ai/LOUD_AI_Land_Factory_Platoons.lua

-- These templates translates the Factory templates into specific unit IDs by the Factory Manager (units)

PlatoonTemplate { Name = 'T1LandAA',
    FactionSquads = {
        UEF = {
            { 'uel0104', 1, 2, 'Attack', 'none' }
        },
        Aeon = {
            { 'ual0104', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'url0104', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsl0104', 1, 2, 'Attack', 'none' }
        },
    },
}

PlatoonTemplate { Name = 'T1LandArtillery',
    FactionSquads = {
        UEF = {
            { 'uel0103', 1, 2, 'Artillery', 'none' }
        },
        Aeon = {
            { 'ual0103', 1, 2, 'Artillery', 'none' }
        },
        Cybran = {
            { 'url0103', 1, 2, 'Artillery', 'none' }
        },
        Seraphim = {
            { 'xsl0103', 1, 2, 'Artillery', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T1LandDFBot',
    FactionSquads = {
        UEF = {
            { 'uel0106', 1, 7, 'Attack', 'none' },	#-- LAB
        },
        Aeon = {
            { 'ual0106', 1, 8, 'Attack', 'none' },	#-- LAB
        },
        Cybran = {
            { 'url0106', 1, 7, 'Attack', 'none' },	#-- LAB
        },
        Seraphim = {
            { 'xsl0201', 1, 6, 'Attack', 'none' },	#-- Medium Tank
        },        
    }
}

PlatoonTemplate { Name = 'T1LandDFTank',
    FactionSquads = {
        UEF = {
            { 'uel0201', 1, 5, 'Attack', 'none' },		-- Striker Medium Tank
			{ 'uel0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'uel0104', 1, 1, 'Guard', 'none' },		-- AA
         },
        Aeon = {
            { 'ual0201', 1, 7, 'Attack', 'none' },		-- Light Hover tank
			{ 'ual0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'ual0104', 1, 1, 'Guard', 'none' },		-- AA
        },
        Cybran = {
            { 'url0107', 1, 5, 'Attack', 'none' },		-- Mantis
			{ 'url0103', 1, 1, 'Artillery', 'none' },	-- arty
            { 'url0104', 1, 1, 'Guard', 'none' },		-- AA
        },
        Seraphim = {
            { 'xsl0201', 1, 4, 'Attack', 'none' },		-- Medium Tank
			{ 'xsl0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'xsl0104', 1, 1, 'Guard', 'none' },		-- AA
        },
    }
}

PlatoonTemplate { Name = 'T1LandAmphibious',
    FactionSquads = {
        UEF = {},
        Aeon = {
            { 'ual0201', 1, 3, 'Attack', 'none' }	#-- Light Hover tank
        },
        Cybran = {},
        Seraphim = {
            { 'xsl0103', 1, 2, 'Attack', 'none' }	#-- Hover Artillery
        },
    }
}

PlatoonTemplate { Name = 'T1LandScout',
    FactionSquads = {
        UEF = {
            { 'uel0101', 1, 3, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0101', 1, 3, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0101', 1, 1, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0101', 1, 1, 'Guard', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3LandScout',
    FactionSquads = {
        UEF = {
            { 'uel0101', 1, 3, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0101', 1, 3, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0101', 1, 1, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0101', 1, 1, 'Guard', 'none' }
        },
    }
}


PlatoonTemplate { Name = 'T2LandAA',
    FactionSquads = {
        UEF = {
            { 'uel0205', 1, 2, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0205', 1, 2, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0205', 1, 2, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0205', 1, 2, 'Guard', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2LandDFTank',
    FactionSquads = {
        UEF = {
            { 'uel0202', 1, 5, 'Attack', 'none' },
			{ 'uel0205', 1, 1, 'Guard', 'none' },
        },
        Aeon = {
            { 'ual0202', 1, 3, 'Attack', 'none' },
			{ 'ual0205', 1, 1, 'Guard', 'none' },
        },
        Cybran = {
            { 'url0202', 1, 5, 'Attack', 'none' },
			{ 'url0205', 1, 1, 'Guard', 'none' },
        },
        Seraphim = {
            { 'xsl0202', 1, 3, 'Attack', 'none' },
			{ 'xsl0205', 1, 1, 'Guard', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T2AttackTank',
    FactionSquads = {
        UEF = {
			{ 'uel0202', 1, 1, 'Attack', 'none' },
            { 'del0204', 1, 2, 'Attack', 'none' },
        },
        Aeon = {
            { 'xal0203', 1, 3, 'Attack', 'none' },
         },
        Cybran = {
            { 'drl0204', 1, 3, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsl0202', 1, 2, 'Attack', 'none' },
        },
    },
}

PlatoonTemplate { Name = 'T2LandArtillery',
    FactionSquads = {
        UEF = {
            { 'uel0111', 1, 2, 'Artillery', 'none' },
        },
        Aeon = {
            { 'ual0111', 1, 2, 'Artillery', 'none' },
        },
        Cybran = {
            { 'url0111', 1, 2, 'Artillery', 'none' },
        },
        Seraphim = {
            { 'xsl0111', 1, 2, 'Artillery', 'none' },
        },
    }
}
PlatoonTemplate { Name = 'T2LandArtilleryWaterMap',
    FactionSquads = {
        UEF = {
            { 'uel0111', 1, 1, 'Artillery', 'none' },
        },
        Aeon = {
            { 'ual0111', 1, 1, 'Artillery', 'none' },
        },
        Cybran = {
            { 'url0111', 1, 1, 'Artillery', 'none' },
        },
        Seraphim = {
            { 'xsl0111', 1, 1, 'Artillery', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T2MobileShields',
    FactionSquads = {
        UEF = {
            { 'uel0307', 1, 1, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0307', 1, 1, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0306', 1, 1, 'Guard', 'none' }
        },
    }
}


PlatoonTemplate { Name = 'T2LandAmphibAA',
    FactionSquads = {
        UEF = {
            { 'uel0205', 1, 1, 'Attack', 'none' }	-- T2 AA vehicle
        },	
        Aeon = {
            { 'ual0205', 1, 2, 'Attack', 'none' }	-- amphibious hover
        },
        Cybran = {
            { 'url0205', 1, 1, 'Attack', 'none' }	-- T2 AA vehicle
        },		
        Seraphim = {
            { 'xsl0205', 1, 2, 'Attack', 'none' }	-- amphibious hover
        },
    }
}

PlatoonTemplate { Name = 'T2LandAmphibTank',
    FactionSquads = {
        UEF = {
            { 'uel0203', 1, 3, 'Attack', 'none' }	-- Riptide
        },
        Aeon = {
            { 'xal0203', 1, 5, 'Attack', 'none' }	-- Blaze
        },
        Cybran = {
            { 'url0203', 1, 2, 'Attack', 'none' }	-- Wagner
        },
        Seraphim = {
            { 'xsl0203', 1, 3, 'Attack', 'none' }	-- Yenzyne
        },
    }
}

PlatoonTemplate { Name = 'T2LandAmphibBot',
    FactionSquads = {
        UEF = {
            { 'uel0203', 1, 3, 'Attack', 'none' }
        },
        Aeon = {
            { 'xal0203', 1, 5, 'Attack', 'none' }
        },
        Cybran = {
            { 'url0203', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsl0203', 1, 3, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2LandAmphibArtillery',
    FactionSquads = {
        UEF = {
            { 'uel0111', 1, 1, 'Attack', 'none' },
        },
        Aeon = {
            { 'ual0111', 1, 1, 'Attack', 'none' },
        },
        Cybran = {
            { 'url0111', 1, 1, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsl0111', 1, 1, 'Attack', 'none' },
        },
    }
}


PlatoonTemplate { Name = 'T3LandAA',
    FactionSquads = {
        UEF = {
            { 'uel0205', 1, 2, 'Attack', 'none' }	# All factions use T2 AA by default
        },
        Aeon = {
            { 'ual0205', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'url0205', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsl0205', 1, 2, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3LandBot',
    FactionSquads = {
        UEF = {
            { 'uel0303', 1, 3, 'Attack', 'none' },  # Titan
        },
        Aeon = {
            { 'ual0303', 1, 2, 'Attack', 'none' },  # Harbinger
        },
        Cybran = {
            { 'url0303', 1, 3, 'Attack', 'none' },  # Loyalist
        },
        Seraphim = {
            { 'xsl0303', 1, 1, 'Attack', 'none' },  # Othuum
        },
    }
}

PlatoonTemplate { Name = 'T3SniperBots',
    FactionSquads = {
        Aeon = {
            { 'xal0305', 1, 1, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsl0305', 1, 1, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T3ArmoredAssault',
    FactionSquads = {
        UEF = {
            { 'xel0305', 1, 1, 'Attack', 'none' },  # Percival
        },
        Aeon = {
            { 'xal0203', 1, 1, 'Attack', 'none' },	# T2 Blaze - no stock T3 unit
        },
        Cybran = {
            { 'xrl0305', 1, 1, 'Attack', 'none' },  # Brick
        },
        Seraphim = {
            { 'xsl0303', 1, 1, 'Attack', 'none' },  # Othuum
        },
    }
}

PlatoonTemplate { Name = 'T3Amphibious',
    FactionSquads = {
        UEF = {
            { 'xel0305', 1, 2, 'Attack', 'none' },  # Percival
        },
        Aeon = {
            { 'xal0203', 1, 2, 'Attack', 'none' },	# T2 Blaze - filler
        },
        Cybran = {
            { 'xrl0305', 1, 1, 'Attack', 'none' },  # Brick
        },
        Seraphim = {
            { 'xsl0303', 1, 2, 'Attack', 'none' },  # Othuum
        },
    }
}

PlatoonTemplate { Name = 'T3AmphibiousAA',
    FactionSquads = {
        UEF = {
            { 'uel0205', 1, 2, 'Attack', 'none' }	# All factions use T2 AA by default since base game has no T3 AA (land or amphibious)
        },
        Aeon = {
            { 'ual0205', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'url0205', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsl0205', 1, 2, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3LandArtillery',
    FactionSquads = {
        UEF = {
            { 'uel0304', 1, 2, 'Attack', 'none' },
        },
        Aeon = {
            { 'ual0304', 1, 2, 'Attack', 'none' },
        },
        Cybran = {
            { 'url0304', 1, 2, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsl0304', 1, 2, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T3MobileMissile',
    FactionSquads = {
        UEF = {
            { 'xel0306', 1, 2, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T3MobileShields',
    FactionSquads = {
        UEF = {
            { 'uel0308', 1, 1, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0308', 1, 1, 'Guard', 'none' }
        },
		Cybran = {
			{ 'url0307', 1, 1, 'Guard', 'none' }	-- T3 CounterIntel
		},
        Seraphim = {
            { 'xsl0307', 1, 1, 'Guard', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3ShieldDisruptor',
	FactionSquads = {
		Aeon = {
			{ 'dal0310', 1, 1, 'Attack', 'none' },
		},
	}
}


PlatoonTemplate { Name = 'T3LandSubCommander',
    FactionSquads = {
        UEF = {
            { 'uel0301', 1, 2, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0301', 1, 2, 'Guard', 'none' }
        },
        Cybran = {
            { 'url0301', 1, 2, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0301', 1, 2, 'Guard', 'none' }
        },
    }
}