--   /lua/BuffFieldDefinitions.lua
--  Author(s):  Brute51
--  Summary  :  Buff field blueprint list

-- Here's a list of buff fields. Just copy-paste an existing one and change it to your liking.
-- You can merge a blueprint with an existing one by putting "Merge = true" in the blueprint.
-- It will then take the old blueprint and apply the changes.

local BuffFieldBlueprint = import('/lua/sim/BuffField.lua').BuffFieldBlueprint


-- this unique field is intended to be used only by the AI airpads - not implemented yet
-- but is designed to overcome the flaw where airpads claim to be full when they are
-- actually empty
BuffFieldBlueprint { Name = 'AirStagingBuffField',
    AffectsUnitCategories = categories.AIR + categories.MOBILE,
    AffectsAllies = false,
    AffectsVisibleEnemies = false,
    AffectsOwnUnits = true,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = true,
    MaintenanceConsumptionPerSecondEnergy = 0,
    Radius = 15,
    Buffs = {
        'CheatAIRSTAGING',
    },
}

BuffFieldBlueprint { Name = 'AeonMaelstromBuffField',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 500,
    Radius = 26,
    Buffs = {
        'AeonMaelstromField',
    },
}

BuffFieldBlueprint { Name = 'AeonMaelstromBuffField2',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 750,
    Radius = 36,
    Buffs = {
        'AeonMaelstromField2',
    },
}

BuffFieldBlueprint { Name = 'AeonMaelstromBuffField3',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 1000,
    Radius = 46,
    Buffs = {
        'AeonMaelstromField3',
    },
}

BuffFieldBlueprint { Name = 'CybranOpticalDisruptionBuffField',
    AffectsUnitCategories = categories.ALLUNITS - categories.COMMAND - categories.TECH1 - categories.WALL,
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = true,
    MaintenanceConsumptionPerSecondEnergy = 600,
    Radius = 80,
    Buffs = {
        'CybranOpticalDisruptionField',
    },
}

BuffFieldBlueprint { Name = 'SeraphimACURegenBuffField',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsAllies = false,
    AffectsVisibleEnemies = false,
    AffectsOwnUnits = true,
    AffectsSelf = true,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 0,
    Radius = 18,
    Buffs = {
        'SeraphimACURegenAura',
    },
}

BuffFieldBlueprint { Name = 'SeraphimAdvancedACURegenBuffField',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsAllies = false,
    AffectsVisibleEnemies = false,
    AffectsOwnUnits = true,
    AffectsSelf = true,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 0,
    Radius = 26,
    Buffs = {
        'SeraphimAdvancedACURegenAura',
    },
}

BuffFieldBlueprint { Name = 'SeraphimRegenBuffField',
    AffectsUnitCategories = categories.SERAPHIM,
    AffectsAllies = false,
    AffectsVisibleEnemies = false,
    AffectsOwnUnits = true,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 900,
    Radius = 26,
    Buffs = {
        'SeraphimRegenFieldMoo',
    },
}



