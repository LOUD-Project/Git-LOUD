-- File: /lua/ai/LOUD_AI_Air_Factory_Platoons.lua


-- Faction Based Factory Build Platoons

-- Scout Planes --

PlatoonTemplate { Name = 'T1AirScout',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 4, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0101', 1, 4, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0101', 1, 4, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0101', 1, 4, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3AirScout',
    FactionSquads = {
        UEF = {
            { 'uea0302', 1, 4, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0302', 1, 4, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0302', 1, 4, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0302', 1, 4, 'scout', 'none' }
        },
    }
}

-- Bombers --

PlatoonTemplate { Name = 'T1Bomber',
    FactionSquads = {
        UEF = {
            { 'uea0103', 1, 4, 'Attack', 'none' },
        },
        Aeon = {
            { 'uaa0103', 1, 4, 'Attack', 'none' },
        },
        Cybran = {
            { 'ura0103', 1, 4, 'Attack', 'none' },
        },
        Seraphim = {
            { 'xsa0103', 1, 4, 'Attack', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'T2Bomber',
    FactionSquads = {
        UEF = {
            { 'dea0202', 1, 2, 'Attack', 'none' }
        },
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

-- Fighters --

PlatoonTemplate { Name = 'T1Fighter',
    FactionSquads = {
        UEF = {
            { 'uea0102', 1, 5, 'Attack', 'none' },
            { 'uea0101', 1, 1, 'scout', 'none' }
        },
        Aeon = {
            { 'uaa0102', 1, 5, 'Attack', 'none' },
            { 'uaa0101', 1, 1, 'scout', 'none' }
        },
        Cybran = {
            { 'ura0102', 1, 5, 'Attack', 'none' },
            { 'ura0101', 1, 1, 'scout', 'none' }
        },
        Seraphim = {
            { 'xsa0102', 1, 5, 'Attack', 'none' },
            { 'xsa0101', 1, 1, 'scout', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T2Fighter',
    FactionSquads = {
        UEF = {
            { 'dea0202', 1, 3, 'Attack', 'none' },	-- Ftr/Bmbr
        },
        Aeon = {
            { 'xaa0202', 1, 3, 'Attack', 'none' },
        },
        Cybran = {
            { 'dra0202', 1, 3, 'Attack', 'none' },	-- Ftr/Bmbr
        },
        Seraphim = {
            { 'xsa0202', 1, 3, 'Attack', 'none' },	-- Ftr/Bmbr
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

-- Gunships --

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

--- Torpedo Bombers ---

PlatoonTemplate { Name = 'T2TorpedoBomber',
    FactionSquads = {
        UEF = {
            { 'uea0204', 1, 4, 'Attack', 'none' }
        },
        Aeon = {
            { 'uaa0204', 1, 4, 'Attack', 'none' }
        },
        Cybran = {
            { 'ura0204', 1, 4, 'Attack', 'none' }
        },
        Seraphim = {
            { 'xsa0204', 1, 4, 'Attack', 'none' }
        },
    }
}

PlatoonTemplate { Name = 'T3TorpedoBomber',
    FactionSquads = {
        UEF = {
            { 'uea0204', 1, 1, 'Attack', 'none' }	-- T2
        },
        Aeon = {
            { 'xaa0306', 1, 1, 'Attack', 'none' }
        },
        Cybran = {
            { 'ura0204', 1, 1, 'Attack', 'none' }   -- T2
        },
        Seraphim = {
            { 'xsa0204', 1, 1, 'Attack', 'none' }   -- T2
        },
    }
}

--- Air Transports ---

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
            { 'uaa0104', 1, 1, 'scout', 'none' }  -- T2
        },
        Cybran = {
            { 'ura0104', 1, 1, 'scout', 'none' }  -- T2
        },
        Seraphim = {
            { 'xsa0104', 1, 1, 'scout', 'none' }  -- T2
        },
    }
}
