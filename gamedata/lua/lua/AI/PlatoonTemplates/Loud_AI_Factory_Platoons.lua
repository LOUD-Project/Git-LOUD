-- File: /lua/ai/LOUD_AI_Factory_Platoons.lua

-- Faction Based Factory Build Platoons
-- Used when constructing units from factories

---------------
-- ENGINEERS --
---------------
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
            { 'uel0105', 1, 3, 'Support', 'none' }
        },
        Aeon = {
            { 'ual0105', 1, 3, 'Support', 'none' }
        },
        Cybran = {
            { 'url0105', 1, 3, 'Support', 'none' }
        },
        Seraphim = {
            { 'xsl0105', 1, 3, 'Support', 'none' }
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

-----------------
---- AIR UNITS --
-----------------
PlatoonTemplate { Name = 'T1AirScout',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 2, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0101', 1, 2, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0101', 1, 2, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0101', 1, 2, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2AirScout',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 2, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0101', 1, 2, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0101', 1, 2, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0101', 1, 2, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3AirScout',
    FactionSquads = {
        UEF = {
            { 'uea0302', 1, 2, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0302', 1, 2, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0302', 1, 2, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0302', 1, 2, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T1Bomber',
    FactionSquads = {
        UEF = {
            { 'uea0103', 1, 3, 'Attack', 'none' },
        },
        Aeon = {
            { 'uaa0103', 1, 3, 'Attack', 'none' },
        },
        Cybran = {
            { 'ura0103', 1, 3, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsa0103', 1, 3, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T2Bomber',
    FactionSquads = {
        UEF = {},
		Aeon = {},
        Cybran = {
            { 'dra0202', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsa0202', 1, 2, 'Attack', 'none' }
        },
    },
}

PlatoonTemplate { Name = 'T3Bomber',
    FactionSquads = {
        UEF = {
            { 'uea0304', 1, 1, 'Attack', 'none' },
        },
        Aeon = {
            { 'uaa0304', 1, 1, 'Attack', 'none' },
        },
        Cybran = {
            { 'ura0304', 1, 1, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsa0304', 1, 1, 'Attack', 'none' },
        },
    }
}


PlatoonTemplate { Name = 'T1Fighter',
    FactionSquads = {
        UEF = {
            { 'uea0102', 1, 2, 'Attack', 'none' },
        },
        Aeon = {
            { 'uaa0102', 1, 2, 'Attack', 'none' },
        },
        Cybran = {
            { 'ura0102', 1, 2, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsa0102', 1, 2, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T1FighterPlus',
    FactionSquads = {
        UEF = {
            { 'uea0102', 1, 2, 'Attack', 'none' },
            { 'uea0101', 1, 1, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0102', 1, 2, 'Attack', 'none' },
            { 'uaa0101', 1, 1, 'scout', 'none' } 
        },
        Cybran = {
            { 'ura0102', 1, 2, 'Attack', 'none' },
            { 'ura0101', 1, 1, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0102', 1, 2, 'Attack', 'none' },
            { 'xsa0101', 1, 1, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2FighterCrossover',
    FactionSquads = {
        UEF = {
            { 'dea0202', 1, 1, 'Attack', 'none' },	-- Ftr
            { 'uea0102', 1, 1, 'Attack', 'none' },
            { 'uea0101', 1, 1, 'scout', 'none' }            
        },
        Aeon = {
            { 'xaa0202', 1, 1, 'Attack', 'none' },  -- Ftr
            { 'uaa0102', 1, 1, 'Attack', 'none' },
            { 'uaa0101', 1, 1, 'scout', 'none' } 
        },
        Cybran = {
            { 'dra0202', 1, 1, 'Attack', 'none' },	-- Ftr/Bmbr
            { 'ura0102', 1, 1, 'Attack', 'none' },
            { 'ura0101', 1, 1, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0202', 1, 1, 'Attack', 'none' },	-- Ftr/Bmbr
            { 'xsa0102', 1, 1, 'Attack', 'none' },
            { 'xsa0101', 1, 1, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2Fighter',
    FactionSquads = {
        UEF = {
            { 'dea0202', 1, 2, 'Attack', 'none' },	-- Ftr
        },
        Aeon = {
            { 'xaa0202', 1, 2, 'Attack', 'none' },  -- Ftr
        },
        Cybran = {
            { 'dra0202', 1, 2, 'Attack', 'none' },	-- Ftr/Bmbr
        },
        Seraphim = {
            { 'xsa0202', 1, 2, 'Attack', 'none' },	-- Ftr/Bmbr
        },
    }
}


PlatoonTemplate { Name = 'T3Fighter',
    FactionSquads = {
        UEF = {
            { 'uea0303', 1, 2, 'Attack', 'none' }
        },
        Aeon = {
            { 'uaa0303', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'ura0303', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsa0303', 1, 2, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2Gunship',
    FactionSquads = {
        UEF = {
            { 'uea0203', 1, 2, 'Attack', 'none' },
        },
        Aeon = {
            { 'uaa0203', 1, 2, 'Attack', 'none' },
        },
        Cybran = {
            { 'ura0203', 1, 2, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsa0203', 1, 2, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T3Gunship',
    FactionSquads = {
        UEF = {
            { 'uea0305', 1, 1, 'Attack', 'none' }	-- Broadsword
        },
        Aeon = {
            { 'xaa0305', 1, 1, 'Attack', 'none' }	-- Restorer
        },
        Cybran = {
            { 'xra0305', 1, 1, 'Attack', 'none' }	-- Wailer
        },
        Seraphim = {
            { 'xsa0203', 1, 1, 'Attack', 'none' }	-- T2 Gunship
        },
    }
}

PlatoonTemplate { Name = 'T2TorpedoBomber',
    FactionSquads = {
        UEF = {
            { 'uea0204', 1, 3, 'Attack', 'none' }
        },
        Aeon = {
            { 'uaa0204', 1, 3, 'Attack', 'none' }
        },
        Cybran = {
            { 'ura0204', 1, 3, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsa0204', 1, 3, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3TorpedoBomber',
    FactionSquads = {
        UEF = {
            { 'uea0204', 1, 1, 'Attack', 'none' }
        },
        Aeon = {
            { 'xaa0306', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'ura0204', 1, 1, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsa0204', 1, 1, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T1AirTransport',
    FactionSquads = {
        UEF = {
            { 'uea0107', 1, 1, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0107', 1, 1, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0107', 1, 1, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0107', 1, 1, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2AirTransport',
    FactionSquads = {
        UEF = {
            { 'uea0104', 1, 1, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0104', 1, 1, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0104', 1, 1, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0104', 1, 1, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3AirTransport',
    FactionSquads = {
        UEF = {
            { 'xea0306', 1, 1, 'scout', 'none' }
        },
        Aeon = {
            { 'baa0309', 1, 1, 'scout', 'none' }
        },
        Cybran = {
            { 'bra0309', 1, 1, 'scout', 'none' }
        },
        Seraphim = {
            { 'bsa0309', 1, 1, 'scout', 'none' }
        },
    }
}

-----------------
-- LAND UNITS ---
-----------------
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
            { 'uel0106', 1, 5, 'Attack', 'none' },	-- LAB
        },
        Aeon = {
            { 'ual0106', 1, 5, 'Attack', 'none' },	-- LAB
        },
        Cybran = {
            { 'url0106', 1, 5, 'Attack', 'none' },	-- LAB
        },
        Seraphim = {
            { 'xsl0201', 1, 5, 'Attack', 'none' },	-- Medium Tank
        },        
    }
}

PlatoonTemplate { Name = 'T1LandDFTank',
    FactionSquads = {
        UEF = {
            { 'uel0201', 1, 4, 'Attack', 'none' },		-- Striker Medium Tank
			{ 'uel0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'uel0104', 1, 1, 'Attack', 'none' }       -- AA
         },
        Aeon = {
            { 'ual0201', 1, 4, 'Attack', 'none' },		-- Light Hover tank
			{ 'ual0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'ual0104', 1, 1, 'Attack', 'none' }       -- AA
        },
        Cybran = {
            { 'url0107', 1, 4, 'Attack', 'none' },		-- Mantis
			{ 'url0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'url0104', 1, 1, 'Attack', 'none' }       -- AA
        },
        Seraphim = {
            { 'xsl0201', 1, 4, 'Attack', 'none' },		-- Medium Tank
			{ 'xsl0103', 1, 1, 'Artillery', 'none' },	-- artillery
            { 'xsl0104', 1, 1, 'Attack', 'none' }       -- AA
        },
    }
}

PlatoonTemplate { Name = 'T1LandAmphibious',
    FactionSquads = {
        UEF = {},
        Aeon = {
            { 'ual0201', 1, 3, 'Attack', 'none' }	    -- Light Hover tank
        },
        Cybran = {},
        Seraphim = {
            { 'xsl0103', 1, 2, 'Attack', 'none' }	    -- Hover Artillery
        },
    }
}

PlatoonTemplate { Name = 'T1LandScout',
    FactionSquads = {
        UEF = {
            { 'uel0101', 1, 2, 'Guard', 'none' }
        },
        Aeon = {
            { 'ual0101', 1, 2, 'Guard', 'none' }
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
            { 'url0101', 1, 2, 'Guard', 'none' }
        },
        Seraphim = {
            { 'xsl0101', 1, 2, 'Guard', 'none' }
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
            { 'uel0202', 1, 2, 'Attack', 'none' },
        },
        Aeon = {
            { 'ual0202', 1, 2, 'Attack', 'none' },
        },
        Cybran = {
            { 'url0202', 1, 2, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsl0202', 1, 2, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T2AttackTank',
    FactionSquads = {
        UEF = {
            { 'del0204', 1, 2, 'Attack', 'none' },
        },
        Aeon = {
            { 'xal0203', 1, 2, 'Attack', 'none' },
         },
        Cybran = {
            { 'drl0204', 1, 2, 'Attack', 'none' },
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
            { 'uel0205', 1, 1, 'Guard', 'none' }    -- non-amphib
        },
        Aeon = {
            { 'ual0205', 1, 2, 'Attack', 'none' }	-- amphibious hover
        },
        Cybran = {
            { 'url0205', 1, 1, 'Guard', 'none' }    -- non-amphib
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

PlatoonTemplate { Name = 'T2LandAmphibBot',     -- yes - this is the same as above - but is provided so we can enable amphib bots seperate from tanks if needed
    FactionSquads = {
        UEF = {
            { 'uel0203', 1, 3, 'Attack', 'none' } -- Riptide
        },
        Aeon = {
            { 'xal0203', 1, 5, 'Attack', 'none' } -- Blaze
        },
        Cybran = {
            { 'url0203', 1, 2, 'Attack', 'none' } -- Wagner
        },
        Seraphim = {
            { 'xsl0203', 1, 3, 'Attack', 'none' } -- Yenzyne
        },
    }
}

PlatoonTemplate { Name = 'T2LandAmphibArtillery',   -- as above this is here to provide options for amphib artillery units if needed
    FactionSquads = {
        UEF = {},
        Aeon = {},
        Cybran = {},
        Seraphim = {},
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
            { 'xel0305', 1, 1, 'Attack', 'none' },  # Percival
        },
        Aeon = {
            { 'xal0203', 1, 2, 'Attack', 'none' },	# T2 Blaze - filler
        },
        Cybran = {
            { 'xrl0305', 1, 1, 'Attack', 'none' },  # Brick
        },
        Seraphim = {
            { 'xsl0303', 1, 1, 'Attack', 'none' },  # Othuum
        },
    }
}

PlatoonTemplate { Name = 'T3AmphibiousAA',      -- here for compatability
    FactionSquads = {
        UEF = {},
        Aeon = {},
        Cybran = {},
        Seraphim = {},
    }
}

PlatoonTemplate { Name = 'T3AmphibiousArtillery',       -- here to provide compatability
    FactionSquads = {
        UEF = {},
        Aeon = {},
        Cybran = {},
        Seraphim = {},
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

PlatoonTemplate { Name = 'T3MobileAntiNuke',
	FactionSquads = {
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

-------------------
--- NAVAL UNITS ---
-------------------

PlatoonTemplate { Name = 'T1SeaFrigate',
    FactionSquads = {
        UEF = {
            { 'ues0103', 1, 2, 'Attack', 'none' }
        },
        Aeon = {
            { 'uas0103', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0103', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0103', 1, 2, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T1SeaAntiAir',
    FactionSquads = {
        Aeon = {{ 'uas0102', 1, 2, 'Guard', 'none' }},
    }
}

PlatoonTemplate { Name = 'T1SeaSub',
    FactionSquads = {
        UEF = {
            { 'ues0203', 1, 2, 'Attack', 'none' }
        },
        Aeon = {
            { 'uas0203', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0203', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0203', 1, 2, 'Attack', 'none' }
        },
    }
}


PlatoonTemplate { Name = 'T2SeaCruiser',
    FactionSquads = {
        UEF = {
            { 'ues0202', 1, 2, 'Attack', 'none' }
        },
        Aeon = {
            { 'uas0202', 1, 2, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0202', 1, 2, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0202', 1, 2, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2SeaDestroyer',
    FactionSquads = {
        UEF = {
            { 'ues0201', 1, 1, 'Attack', 'none' }
        },
        Aeon = {
            { 'uas0201', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0201', 1, 1, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0201', 1, 1, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2SeaSub',
    FactionSquads = {
        UEF = {
            { 'xes0102', 1, 1, 'Attack', 'None' },	-- Cooper Torpedo boat
        },
        Aeon = {
            { 'xas0204', 1, 1, 'Attack', 'None' },
        },
        Cybran = {
            { 'xrs0204', 1, 1, 'Attack', 'None' },
        },
        Seraphim = {
            { 'xss0203', 1, 2, 'Attack', 'None' }	-- T1 sub
        },
    },
}

PlatoonTemplate { Name = 'T2ShieldBoat',
    FactionSquads = {
        UEF = {
            { 'xes0205', 1, 2, 'Guard', 'None' },
        },
    },
}

PlatoonTemplate { Name = 'T2CounterIntelBoat',
    FactionSquads = {
        Cybran = {
            { 'xrs0205', 1, 1, 'Guard', 'None' },
        },
    },
}


PlatoonTemplate { Name = 'T3SeaBattleship',
    FactionSquads = {
        UEF = {
            { 'ues0302', 1, 1, 'Attack', 'none' }
        },
        Aeon = {
            { 'uas0302', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0302', 1, 1, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0302', 1, 1, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3SeaCarrier',
    FactionSquads = {
        Aeon = {
            { 'uas0303', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0303', 1, 1, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0303', 1, 1, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3Battlecruiser',
    FactionSquads = {
        UEF = {
            { 'xes0307', 1, 1, 'Attack', 'none' },
        },
        Aeon = {
            { 'xas0306', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0302', 1, 1, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xss0302', 1, 1, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3SeaSub',
    FactionSquads = {

        Cybran = {
            { 'xrs0204', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xss0304', 1, 1, 'Attack', 'None' },
        }, 
    },
}

PlatoonTemplate { Name = 'T3SeaNukeSub',
    FactionSquads = {
        UEF = {
            { 'ues0304', 1, 1, 'Attack', 'none' }
        },
        Aeon = {
            { 'uas0304', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'urs0304', 1, 1, 'Attack', 'none' }
        },
    }
}