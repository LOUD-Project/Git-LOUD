-- File: /lua/ai/Loud_Air_Platoon_Templates.lua

-- determines the composition of platoons built by the Platoon Manager
PlatoonTemplate { Name = 'FighterSquadron',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL, 1, 60, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'FighterReinforce',
    Plan = 'ReinforceAirAI',	-- to either land or sea bases
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTIAIR), 3, 45, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.SCOUT),0,4,'Support','GrowthFormation' },
    }
}


PlatoonTemplate { Name = 'BomberAttackSmall',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY), 1, 6, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'BomberAttack',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY), 10, 16, 'Attack', 'AttackFormation' },
		{ (categories.HIGHALTAIR * categories.ANTIAIR), 0, 8, 'guard', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'BomberAttack Large',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY ), 16, 32, 'Attack', 'AttackFormation' },
		{ (categories.HIGHALTAIR * categories.ANTIAIR), 0, 16, 'guard', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'BomberAttack Super',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY ), 28, 64, 'Attack', 'AttackFormation' },
		{ (categories.HIGHALTAIR * categories.ANTIAIR), 0, 16, 'guard', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'Experimental Bomber',
    GlobalSquads = {
        { (categories.AIR * categories.EXPERIMENTAL * categories.MOBILE * categories.BOMBER) - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 3, 8, 'Attack', 'none' },
    },
}

PlatoonTemplate { Name = 'BomberReinforce',
    Plan = 'ReinforceAirLandAI',	-- specifically to land bases
    GlobalSquads = {
        { categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY, 1, 24, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.SCOUT), 0, 4, 'Support', 'GrowthFormation' },
    }
}


PlatoonTemplate { Name = 'GunshipAttackSmall',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 1, 16, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 4, 'guard', 'none' },
    }
}

PlatoonTemplate { Name = 'GunshipAttack',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 16, 64, 'Attack', 'AttackFormation' },
		{ (categories.HIGHALTAIR * categories.ANTIAIR), 0, 16, 'guard', 'AttackFormation' },
		{ (categories.AIR * categories.EXPERIMENTAL * categories.ANTIAIR), 0, 4, 'guard', 'none' },
    }
}

PlatoonTemplate { Name = 'GunshipSquadron',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 5, 35, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'GunshipReinforce',
    Plan = 'ReinforceAirAI',	-- either Land or Sea bases
    GlobalSquads = {
        { (categories.AIR * categories.GROUNDATTACK), 1, 35, 'Attack', 'AttackFormation' },
		{ (categories.AIR * categories.SCOUT), 0, 4, 'Support', 'GrowthFormation' },
    }
}

PlatoonTemplate { Name = 'Experimental Gunship',
    GlobalSquads = {
        { (categories.AIR * categories.EXPERIMENTAL * categories.MOBILE * categories.GROUNDATTACK) - categories.uaa0310 - categories.SATELLITE - categories.TRANSPORTFOCUS, 3, 8, 'Attack', 'none' },
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
        { categories.AIR * categories.SCOUT, 2, 3, 'scout', 'none' },
    }
}

PlatoonTemplate { Name = 'Air Scout Group Large',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT - categories.TECH1, 6, 10, 'scout', 'ScatterFormation' },
    }
}

PlatoonTemplate { Name = 'Air Scout Group Huge',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT - categories.TECH1, 12, 15, 'scout', 'ScatterFormation' },
    }
}


PlatoonTemplate { Name = 'TorpedoReinforce',
	Plan = 'ReinforceAirNavalAI',	-- specifically naval bases
	GlobalSquads = {
		{ (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 6, 18, 'Attack', 'AttackFormation' },
	}
}

PlatoonTemplate { Name = 'TorpedoSquadron',
    Plan = 'GuardPointAir',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 24, 48, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate { Name = 'TorpedoBomberAttack',
    GlobalSquads = {
        { (categories.HIGHALTAIR * categories.ANTINAVY) - categories.EXPERIMENTAL, 6, 48, 'Attack', 'AttackFormation' },
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
