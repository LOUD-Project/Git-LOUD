--  Loud_AI_Naval_Factory_Platoons.lua

-- Templates for actual unit creation
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