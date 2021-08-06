local AdjBuffFuncs = import('/lua/sim/adjacencybufffunctions.lua')

-- WEAPON BOOSTERS - from BrewLAN
-- simplified in LOUD to single bonuses regardless of size
-- and non-stacking (for now)

T3WeaponBoosterAccuracyAdjacencyBuffs = {
    'WeaponBoosterAccuracyBonus',
    'WeaponBoosterRateOfFireTradeOff',
}

T3WeaponBoosterDamageAdjacencyBuffs = {
    'WeaponBoosterDamageBonus',
    'WeaponBoosterEnergyWeaponTradeOff',
}

BuffBlueprint {
    Name = 'WeaponBoosterAccuracyBonus',
    DisplayName = 'WeaponBoosterAccuracyBonus',
    BuffType = 'ACCURACYBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        FiringRandomness = {
            Add = -0.25,    -- decrease firing randomness by 25%
            Mult = 1.0,
        },
    },
}


BuffBlueprint {
    Name = 'WeaponBoosterRateOfFireTradeOff',
    DisplayName = 'WeaponBoosterRateOfFireTradeOff',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = 0.025,    -- reduce rate of fire by 2.5%
            Mult = 1.0,
        },
        EnergyWeapon = {
            Add = 0.025,    -- increase energy consumption by 2.5%
            Mult = 1,
        },
    },
}


BuffBlueprint {
    Name = 'WeaponBoosterDamageBonus',
    DisplayName = 'WeaponBoosterDamageBonus',
    BuffType = 'DAMAGEBONUS',
    Stacks = 'NEVER',
    Duration = -1,
    EntityCategory = 'STRUCTURE',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.1,     -- add 10% damage
        },
    },
}

BuffBlueprint {
    Name = 'WeaponBoosterEnergyWeaponTradeOff',
    DisplayName = 'WeaponBoosterEnergyWeaponTradeOff',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'NEVER',
    Duration = -1,
    EntityCategory = 'STRUCTURE',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = 0.175,    -- increase energy consumption by 17.5%
            Mult = 1,
        },
    },
}

-- TIER 1 POWER GEN BUFF TABLE
-- the effectiveness of T1 Pgens drops off beyone Size20

T1PowerGeneratorAdjacencyBuffs = {
    'T1PowerEnergyBuildBonusSize4',
    'T1PowerEnergyBuildBonusSize8',
    'T1PowerEnergyBuildBonusSize12',
    'T1PowerEnergyBuildBonusSize16',
    'T1PowerEnergyBuildBonusSize20',

    'T1PowerEnergyBuildBonusSize24',
    'T1PowerEnergyBuildBonusSize30',
    'T1PowerEnergyBuildBonusSize32',
    'T1PowerEnergyBuildBonusSize36',
    'T1PowerEnergyBuildBonusSize40',
    'T1PowerEnergyBuildBonusSize44',
    'T1PowerEnergyBuildBonusSize48',

    'T1PowerEnergyWeaponBonusSize4',
    'T1PowerEnergyWeaponBonusSize8',
    'T1PowerEnergyWeaponBonusSize12',
    'T1PowerEnergyWeaponBonusSize16',
    'T1PowerEnergyWeaponBonusSize20',

    'T1PowerEnergyMaintenanceBonusSize4',
    'T1PowerEnergyMaintenanceBonusSize8',
    'T1PowerEnergyMaintenanceBonusSize12',
    'T1PowerEnergyMaintenanceBonusSize16',
    'T1PowerEnergyMaintenanceBonusSize20',

    'T1PowerEnergyMaintenanceBonusSize24',
    'T1PowerEnergyMaintenanceBonusSize30',
    'T1PowerEnergyMaintenanceBonusSize32',
    'T1PowerEnergyMaintenanceBonusSize36',
    'T1PowerEnergyMaintenanceBonusSize40',
    'T1PowerEnergyMaintenanceBonusSize44',
    'T1PowerEnergyMaintenanceBonusSize48',

    'T1PowerRateOfFireBonusSize4',
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE4 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0625,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize8',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE8 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.03125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE12 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.020833,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE16 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.015625,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize24',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE24 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.009,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize30',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE30 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.007,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize32',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE32 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0065,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize36',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE36 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.005,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize40',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE40 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.004,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize44',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE44 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.003,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize48',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0025,
            Mult = 1.0,
        },
    },
}


BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize4',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE4 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.0625,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize8',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE8 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.03125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize12',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE12 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.020833,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize16',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE16 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.015625,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize20',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.0125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize24',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE24 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.009,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize30',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE30 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.0065,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize32',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE32 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.006,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize36',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE36 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.005,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize40',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE40 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.004,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize44',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE44 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.003,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize48',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.0025,
            Mult = 1.0,
        },
    },
}

-- ENERGY WEAPON BONUS - TIER 1 POWER GENS
BuffBlueprint { Name = 'T1PowerEnergyWeaponBonusSize4',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE4,	-- * categories.DEFENSE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyWeaponBonusSize8',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE8, -- * categories.DEFENSE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.0125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyWeaponBonusSize12',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE12 - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.008333,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyWeaponBonusSize16',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE16 - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.00625,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyWeaponBonusSize20',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.005,
            Mult = 1.0,
        },
    },
}

-- RATE OF FIRE WEAPON BONUS - TIER 1 POWER GENS
-- interestingly - this is the only one activated
-- T2 and T3 do not provide this RoF bonus to projectile weapons - only energy weapons
BuffBlueprint { Name = 'T1PowerRateOfFireBonusSize4',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE4 - categories.NUKE, -- * categories.DEFENSE,
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}




-- HYDROCARBON POWER GEN BUFF TABLE
-- T2 Power bonuses drop off beyond Size30
HydrocarbonAdjacencyBuffs = {
    'T2PowerEnergyBuildBonusSize4to12',
    'T2PowerEnergyBuildBonusSize16',
    'T2PowerEnergyBuildBonusSize20',

    'T2PowerEnergyBuildBonusSize24',
    'T2PowerEnergyBuildBonusSize30',
    'T2PowerEnergyBuildBonusSize32',
    'T2PowerEnergyBuildBonusSize36',
    'T2PowerEnergyBuildBonusSize40',
    'T2PowerEnergyBuildBonusSize44',
    'T2PowerEnergyBuildBonusSize48',

    'T2PowerEnergyWeaponBonusSize4to12',
    'T2PowerEnergyWeaponBonusSize16',
    'T2PowerEnergyWeaponBonusSize20',

    'T2PowerEnergyMaintenanceBonusSize4to12',
    'T2PowerEnergyMaintenanceBonusSize16',
    'T2PowerEnergyMaintenanceBonusSize20',

    'T2PowerEnergyMaintenanceBonusSize24',
    'T2PowerEnergyMaintenanceBonusSize30',
    'T2PowerEnergyMaintenanceBonusSize32',
    'T2PowerEnergyMaintenanceBonusSize36',
    'T2PowerEnergyMaintenanceBonusSize40',
    'T2PowerEnergyMaintenanceBonusSize44',
    'T2PowerEnergyMaintenanceBonusSize48',

    'T2PowerRateOfFireBonusSize4',
}

T2PowerGeneratorAdjacencyBuffs = {
    'T2PowerEnergyBuildBonusSize4to12',
    'T2PowerEnergyBuildBonusSize16',
    'T2PowerEnergyBuildBonusSize20',

    'T2PowerEnergyBuildBonusSize24',
    'T2PowerEnergyBuildBonusSize30',
    'T2PowerEnergyBuildBonusSize32',
    'T2PowerEnergyBuildBonusSize36',
    'T2PowerEnergyBuildBonusSize40',
    'T2PowerEnergyBuildBonusSize44',
    'T2PowerEnergyBuildBonusSize48',

    'T2PowerEnergyWeaponBonusSize4to12',
    'T2PowerEnergyWeaponBonusSize16',
    'T2PowerEnergyWeaponBonusSize20',

    'T2PowerEnergyMaintenanceBonusSize4to12',
    'T2PowerEnergyMaintenanceBonusSize16',
    'T2PowerEnergyMaintenanceBonusSize20',

    'T2PowerEnergyMaintenanceBonusSize24',
    'T2PowerEnergyMaintenanceBonusSize30',
    'T2PowerEnergyMaintenanceBonusSize32',
    'T2PowerEnergyMaintenanceBonusSize36',
    'T2PowerEnergyMaintenanceBonusSize40',
    'T2PowerEnergyMaintenanceBonusSize44',
    'T2PowerEnergyMaintenanceBonusSize48',

    'T2PowerRateOfFireBonusSize4',
}

-- ENERGY BUILD BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize4to12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = (categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12)) - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.10,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE16 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.06,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize24',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE24 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize30',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE30 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize32',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE32 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.035,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize36',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE36 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.03,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize40',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE40 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize44',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE44 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.02,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize48',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.015,
            Mult = 1.0,
        },
    },
}


-- ENERGY MAINTENANCE BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize4to12',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = (categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12)) - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize16',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE16 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize20',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.06,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize24',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE24 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize30',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE30 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize32',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE32 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.035,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize36',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE36 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.03,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize40',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE40 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize44',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE44 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.02,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize48',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.015,
            Mult = 1.0,
        },
    },
}


-- ENERGY WEAPON BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize4to12',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = (categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12)) - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize16',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE16 - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.0375,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize20',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.03,
            Mult = 1.0,
        },
    },
}

-- RATE OF FIRE WEAPON BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerRateOfFireBonusSize4',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE4 - categories.NUKE,
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

-- TIER 3 POWER GEN BUFF TABLE
T3PowerGeneratorAdjacencyBuffs = {
    'T3PowerEnergyBuildBonusSize4to16',
    'T3PowerEnergyBuildBonusSize20',

    'T3PowerEnergyBuildBonusSize24',
    'T3PowerEnergyBuildBonusSize30',
    'T3PowerEnergyBuildBonusSize32',
    'T3PowerEnergyBuildBonusSize36',
    'T3PowerEnergyBuildBonusSize40',
    'T3PowerEnergyBuildBonusSize44',
    'T3PowerEnergyBuildBonusSize48',

    'T3PowerEnergyMaintenanceBonusSize4to16',
    'T3PowerEnergyMaintenanceBonusSize20',

    'T3PowerEnergyMaintenanceBonusSize24',
    'T3PowerEnergyMaintenanceBonusSize30',
    'T3PowerEnergyMaintenanceBonusSize32',
    'T3PowerEnergyMaintenanceBonusSize36',
    'T3PowerEnergyMaintenanceBonusSize40',
    'T3PowerEnergyMaintenanceBonusSize44',
    'T3PowerEnergyMaintenanceBonusSize48',

    'T3PowerEnergyWeaponBonusSize4to16',

    'T3PowerRateOfFireBonusSize4',
}

-- ENERGY BUILD BONUS - TIER 3 POWER GENS
BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize4to16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = (categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12 + categories.SIZE16)) - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.15,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.12,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize24',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE24 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.10,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize30',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE30 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize32',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE32 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.07,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize36',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE36 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.06,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize40',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE40 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize44',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE44 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.035,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize48',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.03,
            Mult = 1.0,
        },
    },
}


-- ENERGY MAINTENANCE BONUS - TIER 3 POWER GENS
BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize4to16',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = (categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12 + categories.SIZE16)) - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.15,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize20',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE20 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.12,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize24',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE24 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.10,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize30',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE30 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize32',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE32 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.07,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize36',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE36 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.06,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize40',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE40 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize44',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE44 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.035,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize48',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48 - categories.NUKE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.03,
            Mult = 1.0,
        },
    },
}


-- ENERGY WEAPON BONUS - TIER 3 POWER GENS
BuffBlueprint { Name = 'T3PowerEnergyWeaponBonusSize4to16',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12 + categories.SIZE16),
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.08,
            Mult = 1.0,
        },
    },
}


BuffBlueprint { Name = 'T3PowerRateOfFireBonusSize4',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

-- TIER 1 MASS EXTRACTOR BUFF TABLE
T1MassExtractorAdjacencyBuffs = {
    'T1MEXMassBuildBonus',
}

-- MASS BUILD BONUS - TIER 1 MASS EXTRACTOR
BuffBlueprint { Name = 'T1MEXMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

-- TIER 2 MASS EXTRACTOR BUFF TABLE
T2MassExtractorAdjacencyBuffs = {
    'T2MEXMassBuildBonus',
}

-- MASS BUILD BONUS - TIER 2 MASS EXTRACTOR
BuffBlueprint { Name = 'T2MEXMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.15,
            Mult = 1.0,
        },
    },
}

-- TIER 3 MASS EXTRACTOR BUFF TABLE
T3MassExtractorAdjacencyBuffs = {
    'T3MEXMassBuildBonus',
}

-- MASS BUILD BONUS - TIER 3 MASS EXTRACTOR
BuffBlueprint { Name = 'T3MEXMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.2,
            Mult = 1.0,
        },
    },
}

-- TIER 1 MASS FABRICATOR BUFF TABLE
T1MassFabricatorAdjacencyBuffs = {
    'T1FabricatorMassBuildBonusStandard',
	'T1FabricatorMassBuildBonusOversize1',
	'T1FabricatorMassBuildBonusOversize2',
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusStandard',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12 + categories.SIZE16 + categories.SIZE20),
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusOversize1',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE24 + categories.SIZE30 + categories.SIZE32 + categories.SIZE36 + categories.SIZE40),
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.012,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusOversize2',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE44 + categories.SIZE48),
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.009,
            Mult = 1.0,
        },
    },
}

-- TIER 3 MASS FABRICATOR BUFF TABLE
T3MassFabricatorAdjacencyBuffs = {
    'T3FabricatorMassBuildBonusSize4to20',
	'T3FabricatorMassBuildBonusSize24to32',
	'T3FabricatorMassBuildBonusSize36to44',
	'T3FabricatorMassBuildBonusSize48',
}

-- MASS BUILD BONUS - TIER 3 MASS FABRICATOR
BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize4to20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE4 + categories.SIZE8 + categories.SIZE12 + categories.SIZE16 + categories.SIZE20),
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}
	
BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize24to32',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE24 + categories.SIZE30 + categories.SIZE32),
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.06,
            Mult = 1.0,
        },
    },
}	
	
BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize36to44',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * (categories.SIZE36 + categories.SIZE40 + categories.SIZE44),
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}
	
BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize48',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SIZE48,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.03,
            Mult = 1.0,
        },
    },		
}

-- TIER 1 ENERGY STORAGE
T1EnergyStorageAdjacencyBuffs = {
    'T1EnergyStorageEnergyProductionBonusSize4',
    'T1EnergyStorageEnergyProductionBonusSize12',
    'T1EnergyStorageEnergyProductionBonusSize16',
    'T1EnergyStorageEnergyProductionBonusSize20',

	'T1EnergyStorageShieldRegenBonusSize4',
	'T1EnergyStorageShieldRegenBonusSize12',
	'T1EnergyStorageShieldRegenBonusSize16',

	'T1EnergyStorageShieldSizeBonusSize4',
	'T1EnergyStorageShieldSizeBonusSize12',

	'T1EnergyStorageShieldHealthBonusSize4',
	'T1EnergyStorageShieldHealthBonusSize12',
	'T1EnergyStorageShieldHealthBonusSize16',
}

BuffBlueprint { Name = 'T1EnergyStorageEnergyProductionBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.10,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageEnergyProductionBonusSize12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.033,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageEnergyProductionBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageEnergyProductionBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE20,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.02,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldRegenBonusSize4',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.08,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldRegenBonusSize12',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.0266,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldRegenBonusSize16',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.02,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldSizeBonusSize4',
    BuffType = 'SHIELDSIZEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldSizeBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldSizeBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldSizeBuffRemove,
    Affects = {
        ShieldSize = {
            Add = 0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldSizeBonusSize12',
    BuffType = 'SHIELDSIZEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldSizeBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldSizeBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldSizeBuffRemove,
    Affects = {
        ShieldSize = {
            Add = 0.0133,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldHealthBonusSize4',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldHealthBonusSize12',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.008,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1EnergyStorageShieldHealthBonusSize16',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.0065,
            Mult = 1.0,
        },
    },
}


-- TIER 2 ENERGY STORAGE & T3 MASSENERGY (COMBO) STORAGE
T2EnergyStorageAdjacencyBuffs = {
    'T2EnergyStorageEnergyProductionBonusSize4',
    'T2EnergyStorageEnergyProductionBonusSize12',
    'T2EnergyStorageEnergyProductionBonusSize16',
    'T2EnergyStorageEnergyProductionBonusSize20',
	'T2EnergyStorageShieldRegenBonusSize4',
	'T2EnergyStorageShieldRegenBonusSize12',
	'T2EnergyStorageShieldRegenBonusSize16',
	'T2EnergyStorageShieldSizeBonusSize4',
	'T2EnergyStorageShieldSizeBonusSize12',
	'T2EnergyStorageShieldHealthBonusSize4',
	'T2EnergyStorageShieldHealthBonusSize12',
	'T2EnergyStorageShieldHealthBonusSize16',
}

-- Combo building gets T3 Shield Effects but only T2 Resource Adjacency and T2 Energy Weapon Bonus
T3MassEnergyStorageAdjacencyBuffs = {
    'T2EnergyStorageEnergyProductionBonusSize4',
    'T2EnergyStorageEnergyProductionBonusSize12',
    'T2EnergyStorageEnergyProductionBonusSize16',
    'T2EnergyStorageEnergyProductionBonusSize20',
    'T2MassStorageMassProductionBonusSize4',
    'T2MassStorageMassProductionBonusSize12',
    'T2MassStorageMassProductionBonusSize20',
	'T3EnergyStorageShieldRegenBonusSize4',
	'T3EnergyStorageShieldRegenBonusSize12',
	'T3EnergyStorageShieldRegenBonusSize16',
	'T3EnergyStorageShieldSizeBonusSize4',
	'T3EnergyStorageShieldSizeBonusSize12',
	'T3EnergyStorageShieldHealthBonusSize4',
	'T3EnergyStorageShieldHealthBonusSize12',
	'T3EnergyStorageShieldHealthBonusSize16',
    'T2PowerEnergyWeaponBonusSize4to12',
}

T3MassEnergyStorageAdjacencyBuffsIS = {
    'T2PowerEnergyWeaponBonusSize4to12',
}

BuffBlueprint { Name = 'T2EnergyStorageEnergyProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.175,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageEnergyProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.0583,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageEnergyProductionBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.04375,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageEnergyProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE20,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.035,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldRegenBonusSize4',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.11,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldRegenBonusSize12',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.0366,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldRegenBonusSize16',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.0275,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldSizeBonusSize4',
    BuffType = 'SHIELDSIZEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldSizeBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldSizeBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldSizeBuffRemove,
    Affects = {
        ShieldSize = {
            Add = 0.0675,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldSizeBonusSize12',
    BuffType = 'SHIELDSIZEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldSizeBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldSizeBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldSizeBuffRemove,
    Affects = {
        ShieldSize = {
            Add = 0.0225,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldHealthBonusSize4',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.0608,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldHealthBonusSize12',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.0203,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2EnergyStorageShieldHealthBonusSize16',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.0152,
            Mult = 1.0,
        },
    },
}


-- TIER 3 ENERGY STORAGE
T3EnergyStorageAdjacencyBuffs = {
    'T3EnergyStorageEnergyProductionBonusSize4',
    'T3EnergyStorageEnergyProductionBonusSize12',
    'T3EnergyStorageEnergyProductionBonusSize16',
    'T3EnergyStorageEnergyProductionBonusSize20',
	'T3EnergyStorageShieldRegenBonusSize4',
	'T3EnergyStorageShieldRegenBonusSize12',
	'T3EnergyStorageShieldRegenBonusSize16',
	'T3EnergyStorageShieldSizeBonusSize4',
	'T3EnergyStorageShieldSizeBonusSize12',
	'T3EnergyStorageShieldHealthBonusSize4',
	'T3EnergyStorageShieldHealthBonusSize12',
	'T3EnergyStorageShieldHealthBonusSize16',
}

BuffBlueprint { Name = 'T3EnergyStorageEnergyProductionBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.215,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageEnergyProductionBonusSize12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.07167,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageEnergyProductionBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.05375,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageEnergyProductionBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.SIZE20,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Add = 0.043,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldRegenBonusSize4',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.12,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldRegenBonusSize12',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.04,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldRegenBonusSize16',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Add = 0.03,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldSizeBonusSize4',
    BuffType = 'SHIELDSIZEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldSizeBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldSizeBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldSizeBuffRemove,
    Affects = {
        ShieldSize = {
            Add = 0.08,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldSizeBonusSize12',
    BuffType = 'SHIELDSIZEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldSizeBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldSizeBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldSizeBuffRemove,
    Affects = {
        ShieldSize = {
            Add = 0.02666,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldHealthBonusSize4',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.064,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldHealthBonusSize12',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.0214,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3EnergyStorageShieldHealthBonusSize16',
    BuffType = 'SHIELDHEALTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD * categories.SIZE16,
    BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldHealthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldHealthBuffRemove,
    Affects = {
        ShieldHealth = {
            Add = 0.016,
            Mult = 1.0,
        },
    },
}


-- MASS STORAGE Mass Production Buffs used to be linear
-- so the bonus was consistent no matter what the size of the origin
-- as long as you lined the entire side
-- This is no longer true - it's still good but it's diminished with
-- larger mass producing structures (T3 Mass Fabs, Paragons)
-- Only the T4 storage is unaffected by this and gets the maximum buff in all cases


-- MASS STORAGE
T1MassStorageAdjacencyBuffs = {
    'T1MassStorageMassProductionBonusSize4',
    'T1MassStorageMassProductionBonusSize12',
    'T1MassStorageMassProductionBonusSize20',
}

BuffBlueprint { Name = 'T1MassStorageMassProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.1,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MassStorageMassProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.03,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MassStorageMassProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE20,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.015,
            Mult = 1.0,
        },
    },
}

T2MassStorageAdjacencyBuffs = {
    'T2MassStorageMassProductionBonusSize4',
    'T2MassStorageMassProductionBonusSize12',
    'T2MassStorageMassProductionBonusSize20',
}

BuffBlueprint { Name = 'T2MassStorageMassProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.15,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MassStorageMassProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.045,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MassStorageMassProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE20,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.0225,
            Mult = 1.0,
        },
    },
}

T3MassStorageAdjacencyBuffs = {
    'T3MassStorageMassProductionBonusSize4',
    'T3MassStorageMassProductionBonusSize12',
    'T3MassStorageMassProductionBonusSize20',
}

BuffBlueprint { Name = 'T3MassStorageMassProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE4,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.175,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MassStorageMassProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE12,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.0525,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MassStorageMassProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION * categories.SIZE20,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.0265,
            Mult = 1.0,
        },
    },
}

--
-- Experimental STORAGE
--
ExperimentalStorageAdjacencyBuff = {
    'ExperimentalMassStorageProductionBonus',
    'ExperimentalEnergyStorageProductionBonus',
    'ExperimentalPowerEnergyBuildBonus',
    'ExperimentalPowerEnergyMaintenanceBonus',
    'ExperimentalPowerEnergyWeaponBonus',
    'ExperimentalPowerRateOfFireBonus',
    'ExperimentalFabricatorMassBuildBonus',
	'ExperimentalEnergyStorageShieldRegenBonus',
}

BuffBlueprint { Name = 'ExperimentalMassStorageProductionBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Mult = 1.0,
            Add = 0.2,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageProductionBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Mult = 1.0,
            Add = 0.24,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        EnergyActive = {
            Mult = 0.18,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyMaintenanceBonus',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE - categories.ENERGYPRODUCTION,
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Mult = 0.18,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyWeaponBonus',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.DEFENSE,
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Mult = 1.0,
            Add = -0.08,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.DEFENSE,
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.08,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalFabricatorMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.MASSFABRICATION,
    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.BuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.BuildBuffRemove,
    Affects = {
        MassActive = {
            Mult = 1.0,
            Add = -0.12,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageShieldRegenBonus',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    ParsedEntityCategory = categories.STRUCTURE * categories.SHIELD,
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Mult = 1.0,
            Add = 0.06,
        },
    },
}
