local AdjBuffFuncs = import('/lua/sim/adjacencybufffunctions.lua')

-- just a note -- I disabled a number of the buffs in here to 
-- eliminate those which have no use or no unit to use them

-- TIER 1 POWER GEN BUFF TABLE
T1PowerGeneratorAdjacencyBuffs = {
    'T1PowerEnergyBuildBonusSize4',
    'T1PowerEnergyBuildBonusSize8',
    'T1PowerEnergyBuildBonusSize12',
    'T1PowerEnergyBuildBonusSize16',
    'T1PowerEnergyBuildBonusSize20',
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
    'T1PowerRateOfFireBonusSize4',
}

BuffBlueprint { Name = 'T1PowerEnergyBuildBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
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
    EntityCategory = 'STRUCTURE SIZE8 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
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
    EntityCategory = 'STRUCTURE SIZE12 -NUKE -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
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
    EntityCategory = 'STRUCTURE SIZE16 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
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
    EntityCategory = 'STRUCTURE SIZE20 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1PowerEnergyMaintenanceBonusSize4',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 -ENERGYPRODUCTION',
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
    EntityCategory = 'STRUCTURE SIZE8 -ENERGYPRODUCTION',
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
    EntityCategory = 'STRUCTURE SIZE12 -NUKE -ENERGYPRODUCTION',
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
    EntityCategory = 'STRUCTURE SIZE16 -ENERGYPRODUCTION',
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
    EntityCategory = 'STRUCTURE SIZE20 -ENERGYPRODUCTION',
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

-- ENERGY WEAPON BONUS - TIER 1 POWER GENS
BuffBlueprint { Name = 'T1PowerEnergyWeaponBonusSize4',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
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
    EntityCategory = 'STRUCTURE SIZE8',
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
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
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
    EntityCategory = 'STRUCTURE SIZE16',
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
    EntityCategory = 'STRUCTURE SIZE20',
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
BuffBlueprint { Name = 'T1PowerRateOfFireBonusSize4',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
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
HydrocarbonAdjacencyBuffs = {
    'T2PowerEnergyBuildBonusSize4',
    'T2PowerEnergyBuildBonusSize8',
    'T2PowerEnergyBuildBonusSize12',
    'T2PowerEnergyBuildBonusSize16',
    'T2PowerEnergyBuildBonusSize20',
    'T2PowerEnergyWeaponBonusSize4',
    'T2PowerEnergyWeaponBonusSize8',
    'T2PowerEnergyWeaponBonusSize12',
    'T2PowerEnergyWeaponBonusSize16',
    'T2PowerEnergyWeaponBonusSize20',
    'T2PowerEnergyMaintenanceBonusSize4',
    'T2PowerEnergyMaintenanceBonusSize8',
    'T2PowerEnergyMaintenanceBonusSize12',
    'T2PowerEnergyMaintenanceBonusSize16',
    'T2PowerEnergyMaintenanceBonusSize20',
    'T2PowerRateOfFireBonusSize4',
}

T2PowerGeneratorAdjacencyBuffs = {
    'T2PowerEnergyBuildBonusSize4',
    'T2PowerEnergyBuildBonusSize8',
    'T2PowerEnergyBuildBonusSize12',
    'T2PowerEnergyBuildBonusSize16',
    'T2PowerEnergyBuildBonusSize20',
    'T2PowerEnergyWeaponBonusSize4',
    'T2PowerEnergyWeaponBonusSize8',
    'T2PowerEnergyWeaponBonusSize12',
    'T2PowerEnergyWeaponBonusSize16',
    'T2PowerEnergyWeaponBonusSize20',
    'T2PowerEnergyMaintenanceBonusSize4',
    'T2PowerEnergyMaintenanceBonusSize8',
    'T2PowerEnergyMaintenanceBonusSize12',
    'T2PowerEnergyMaintenanceBonusSize16',
    'T2PowerEnergyMaintenanceBonusSize20',
    'T2PowerRateOfFireBonusSize4',
}

-- ENERGY BUILD BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize8',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyBuildBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0125,
            Mult = 1.0,
        },
    },
}

-- ENERGY MAINTENANCE BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize4',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize8',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize12',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize16',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyMaintenanceBonusSize20',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

-- ENERGY WEAPON BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize4',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize8',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize12',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize16',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2PowerEnergyWeaponBonusSize20',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

-- RATE OF FIRE WEAPON BONUS - TIER 2 POWER GENS
BuffBlueprint { Name = 'T2PowerRateOfFireBonusSize4',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

-- TIER 3 POWER GEN BUFF TABLE
T3PowerGeneratorAdjacencyBuffs = {
    'T3PowerEnergyBuildBonusSize4',
    'T3PowerEnergyBuildBonusSize8',
    'T3PowerEnergyBuildBonusSize12',
    'T3PowerEnergyBuildBonusSize16',
    'T3PowerEnergyBuildBonusSize20',
    'T3PowerEnergyWeaponBonusSize4',
    'T3PowerEnergyWeaponBonusSize8',
    'T3PowerEnergyWeaponBonusSize12',
    'T3PowerEnergyWeaponBonusSize16',
    'T3PowerEnergyWeaponBonusSize20',
    'T3PowerEnergyMaintenanceBonusSize4',
    'T3PowerEnergyMaintenanceBonusSize8',
    'T3PowerEnergyMaintenanceBonusSize12',
    'T3PowerEnergyMaintenanceBonusSize16',
    'T3PowerEnergyMaintenanceBonusSize20',
    'T3PowerRateOfFireBonusSize4',
}

-- ENERGY BUILD BONUS - TIER 3 POWER GENS
BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize8',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3PowerEnergyBuildBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20 -ENERGYPRODUCTION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875,
            Mult = 1.0,
        },
    },
}

-- ENERGY MAINTENANCE BONUS - TIER 3 POWER GENS
BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize4',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 -ENERGYPRODUCTION',
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

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize8',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8 -ENERGYPRODUCTION',
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

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize12',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE -ENERGYPRODUCTION',
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

BuffBlueprint { Name = 'T3PowerEnergyMaintenanceBonusSize16',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16 -ENERGYPRODUCTION',
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
    EntityCategory = 'STRUCTURE SIZE20 -ENERGYPRODUCTION',
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

-- ENERGY WEAPON BONUS - TIER 3 POWER GENS
BuffBlueprint { Name = 'T3PowerEnergyWeaponBonusSize4',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
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

BuffBlueprint { Name = 'T3PowerEnergyWeaponBonusSize8',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
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

BuffBlueprint { Name = 'T3PowerEnergyWeaponBonusSize12',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
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

BuffBlueprint { Name = 'T3PowerEnergyWeaponBonusSize16',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
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

BuffBlueprint { Name = 'T3PowerEnergyWeaponBonusSize20',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
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
    EntityCategory = 'STRUCTURE SIZE4',
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

-- TIER 1 MASS EXTRACTOR BUFF TABLE
T1MassExtractorAdjacencyBuffs = {
    'T1MEXMassBuildBonusSize4',
    'T1MEXMassBuildBonusSize8',
    'T1MEXMassBuildBonusSize12',
    'T1MEXMassBuildBonusSize16',
    'T1MEXMassBuildBonusSize20',
}

-- MASS BUILD BONUS - TIER 1 MASS EXTRACTOR
BuffBlueprint { Name = 'T1MEXMassBuildBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MEXMassBuildBonusSize8',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MEXMassBuildBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.033333,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MEXMassBuildBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MEXMassBuildBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.02,
            Mult = 1.0,
        },
    },
}

-- TIER 2 MASS EXTRACTOR BUFF TABLE
T2MassExtractorAdjacencyBuffs = {
    'T2MEXMassBuildBonusSize4',
    'T2MEXMassBuildBonusSize8',
    'T2MEXMassBuildBonusSize12',
    'T2MEXMassBuildBonusSize16',
    'T2MEXMassBuildBonusSize20',
}

-- MASS BUILD BONUS - TIER 2 MASS EXTRACTOR
BuffBlueprint { Name = 'T2MEXMassBuildBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.15,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MEXMassBuildBonusSize8',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MEXMassBuildBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MEXMassBuildBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.0375,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MEXMassBuildBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.03,
            Mult = 1.0,
        },
    },
}

-- TIER 3 MASS EXTRACTOR BUFF TABLE
T3MassExtractorAdjacencyBuffs = {
    'T3MEXMassBuildBonusSize4',
    'T3MEXMassBuildBonusSize8',
    'T3MEXMassBuildBonusSize12',
    'T3MEXMassBuildBonusSize16',
    'T3MEXMassBuildBonusSize20',
}

-- MASS BUILD BONUS - TIER 3 MASS EXTRACTOR
BuffBlueprint { Name = 'T3MEXMassBuildBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.2,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MEXMassBuildBonusSize8',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MEXMassBuildBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.066667,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MEXMassBuildBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MEXMassBuildBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.04,
            Mult = 1.0,
        },
    },
}

-- TIER 1 MASS FABRICATOR BUFF TABLE
T1MassFabricatorAdjacencyBuffs = {
    'T1FabricatorMassBuildBonusSize4',
    'T1FabricatorMassBuildBonusSize8',
    'T1FabricatorMassBuildBonusSize12',
    'T1FabricatorMassBuildBonusSize16',
    'T1FabricatorMassBuildBonusSize20',
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusSize8',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.0125,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.008333,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.00625,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1FabricatorMassBuildBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.005,
            Mult = 1.0,
        },
    },
}

-- TIER 3 MASS FABRICATOR BUFF TABLE
T3MassFabricatorAdjacencyBuffs = {
    'T3FabricatorMassBuildBonusSize4',
    'T3FabricatorMassBuildBonusSize8',
    'T3FabricatorMassBuildBonusSize12',
    'T3FabricatorMassBuildBonusSize16',
    'T3FabricatorMassBuildBonusSize20',
}

-- MASS BUILD BONUS - TIER 3 MASS FABRICATOR
BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize8',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12 -NUKE',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3FabricatorMassBuildBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE4',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE12',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE16',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE20',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
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

-- Combo building gets T3 Shield Effects but only T2 Resource Adjacency
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
}

BuffBlueprint { Name = 'T2EnergyStorageEnergyProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE4',
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
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE12',
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
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE16',
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
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE20',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE4',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE12',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE16',
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
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE20',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
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
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
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
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE4',
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
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE12',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.033,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T1MassStorageMassProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.02,
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
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE4',
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

BuffBlueprint { Name = 'T2MassStorageMassProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE12',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.0583,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T2MassStorageMassProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.035,
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
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.215,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MassStorageMassProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE12',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.07167,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'T3MassStorageMassProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Add = 0.043,
            Mult = 1.0,
        },
    },
}

##################################################################
## Experimental STORAGE
##################################################################
ExperimentalStorageAdjacencyBuff = {
    'ExperimentalMassStorageProductionBonusSize4',
    'ExperimentalMassStorageProductionBonusSize12',
    'ExperimentalMassStorageProductionBonusSize20',
	
    'ExperimentalEnergyStorageProductionBonusSize4',
    'ExperimentalEnergyStorageProductionBonusSize12',
    'ExperimentalEnergyStorageProductionBonusSize16',
    'ExperimentalEnergyStorageProductionBonusSize20',
	
    'ExperimentalPowerEnergyBuildBonusSize4',
    'ExperimentalPowerEnergyBuildBonusSize8',
    'ExperimentalPowerEnergyBuildBonusSize12',
    'ExperimentalPowerEnergyBuildBonusSize16',
    'ExperimentalPowerEnergyBuildBonusSize20',
	
    'ExperimentalPowerEnergyWeaponBonusSize4',
    'ExperimentalPowerEnergyWeaponBonusSize8',
    'ExperimentalPowerEnergyWeaponBonusSize12',
    'ExperimentalPowerEnergyWeaponBonusSize16',
    'ExperimentalPowerEnergyWeaponBonusSize20',
	
    'ExperimentalPowerEnergyMaintenanceBonusSize4',
    'ExperimentalPowerEnergyMaintenanceBonusSize8',
    'ExperimentalPowerEnergyMaintenanceBonusSize12',
    'ExperimentalPowerEnergyMaintenanceBonusSize16',
    'ExperimentalPowerEnergyMaintenanceBonusSize20',
	
    'ExperimentalPowerRateOfFireBonusSize4',
    'ExperimentalPowerRateOfFireBonusSize8',
    'ExperimentalPowerRateOfFireBonusSize12',
    'ExperimentalPowerRateOfFireBonusSize16',
    'ExperimentalPowerRateOfFireBonusSize20',
	
    'ExperimentalFabricatorMassBuildBonusSize4',
    'ExperimentalFabricatorMassBuildBonusSize8',
    'ExperimentalFabricatorMassBuildBonusSize12',
    'ExperimentalFabricatorMassBuildBonusSize16',
    'ExperimentalFabricatorMassBuildBonusSize20',
	
	'ExperimentalEnergyStorageShieldRegenBonusSize4',
	'ExperimentalEnergyStorageShieldRegenBonusSize12',
	'ExperimentalEnergyStorageShieldRegenBonusSize16',
}

BuffBlueprint { Name = 'ExperimentalMassStorageProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalMassStorageProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE12',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalMassStorageProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSPRODUCTION SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassProductionBuffRemove,
    Affects = {
        MassProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalEnergyStorageProductionBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageProductionBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageProductionBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageProductionBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE ENERGYPRODUCTION SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalPowerEnergyBuildBonusSize4',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyBuildBonusSize8',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyBuildBonusSize12',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyBuildBonusSize16',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint {Name = 'ExperimentalPowerEnergyBuildBonusSize20',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalPowerEnergyMaintenanceBonusSize4',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyMaintenanceBonusSize8',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyMaintenanceBonusSize12',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyMaintenanceBonusSize16',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyMaintenanceBonusSize20',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalPowerEnergyWeaponBonusSize4',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyWeaponBonusSize8',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyWeaponBonusSize12',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyWeaponBonusSize16',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerEnergyWeaponBonusSize20',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalPowerRateOfFireBonusSize4',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = 0.0,
            Mult = 0.9,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerRateOfFireBonusSize8',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = 0.0,
            Mult = 0.9,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerRateOfFireBonusSize12',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = 0.0,
            Mult = 0.9,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerRateOfFireBonusSize16',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = 0.0,
            Mult = 0.9,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalPowerRateOfFireBonusSize20',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = 0.0,
            Mult = 0.9,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalFabricatorMassBuildBonusSize4',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSFABRICATION SIZE4',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalFabricatorMassBuildBonusSize8',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSFABRICATION SIZE8',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalFabricatorMassBuildBonusSize12',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSFABRICATION SIZE12',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalFabricatorMassBuildBonusSize16',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSFABRICATION SIZE16',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalFabricatorMassBuildBonusSize20',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE MASSFABRICATION SIZE20',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Mult = 0.9,
            Add = 0.0,
        },
    },
}


BuffBlueprint { Name = 'ExperimentalEnergyStorageShieldRegenBonusSize4',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SHIELD SIZE4',
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageShieldRegenBonusSize12',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SHIELD SIZE12',
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}

BuffBlueprint { Name = 'ExperimentalEnergyStorageShieldRegenBonusSize16',
    BuffType = 'SHIELDREGENBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SHIELD SIZE16',
    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldRegenBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldRegenBuffRemove,
    Affects = {
        ShieldRegeneration = {
            Mult = 1.2,
            Add = 0.0,
        },
    },
}
