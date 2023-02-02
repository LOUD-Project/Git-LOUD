--   /lua/BuffFieldDefinitions.lua
--  Author(s):  Brute51
--  Summary  :  Buff field blueprint list

-- Here's a list of buff fields. Just copy-paste an existing one and change it to your liking.
-- You can merge a blueprint with an existing one by putting "Merge = true" in the blueprint.
-- It will then take the old blueprint and apply the changes.

-- One feature sadly lacking here is definition of which 'toggle' will control the field. This should be
-- the SPECIAL toggle but it often is not.  Instead, the toggle is often coded manually leading to some
-- issues with the function of other toggles.

local BuffFieldBlueprint = import('/lua/sim/BuffField.lua').BuffFieldBlueprint


-- this unique field is intended to be used by airpads
-- designed to overcome the flaw where airpads claim to be full when they are
-- actually empty thus allowing aircraft to recharge and repair slowly without necessarily landing
BuffFieldBlueprint { Name = 'AirStagingBuffField',
    AffectsUnitCategories = categories.AIR * categories.MOBILE - categories.EXPERIMENTAL,
    AffectsAllies = true,
    AffectsVisibleEnemies = false,
    AffectsOwnUnits = true,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 0,
    Radius = 20,
    RadiusOffsetY = 5,

    Buffs = {'AIRSTAGING'},
}

BuffFieldBlueprint { Name = 'AeonMaelstromBuffField',
    AffectsUnitCategories = categories.ALLUNITS,
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 500,
    Radius = 24,

    VisualScale = 7.2,

    Buffs = {'AeonMaelstromField'},
}

BuffFieldBlueprint { Name = 'AeonMaelstromBuffField2',
    AffectsUnitCategories = categories.ALLUNITS,
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 750,
    Radius = 32,

    VisualScale = 9.7,

    Buffs = {'AeonMaelstromField2'},
}

BuffFieldBlueprint { Name = 'AeonMaelstromBuffField3',
    AffectsUnitCategories = categories.ALLUNITS,
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 1200,
    Radius = 40,

    VisualScale = 12.3,

    Buffs = {'AeonMaelstromField3'},
}

BuffFieldBlueprint { Name = 'CybranOpticalDisruptionBuffField',
    AffectsUnitCategories = categories.ALLUNITS - categories.COMMAND - categories.SUBCOMMANDER - categories.TECH1 - categories.WALL,
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 660,

    Radius = 80,

    Buffs = {'CybranOpticalDisruptionField'},
}

BuffFieldBlueprint { Name = 'CybranACUOpticalDisruptionBuffField',
    AffectsUnitCategories = categories.ALLUNITS - categories.COMMAND - categories.SUBCOMMANDER - categories.TECH1 - categories.WALL,
    AffectsAllies = false,
    AffectsVisibleEnemies = true,
    AffectsOwnUnits = false,
    AffectsSelf = false,
    DisableInTransport = true,
    InitiallyEnabled = false,
    MaintenanceConsumptionPerSecondEnergy = 0,  -- defined in the enhancement 

    Radius = 80,

    Buffs = {'CybranOpticalDisruptionField'},
}

BuffFieldBlueprint { Name = 'SeraphimACURegenBuffField',

    AffectsUnitCategories = categories.SERAPHIM,
    AffectsOwnUnits = true,
    --AttachBone = 'Torso',
    DisableInTransport = true,
    FieldVisualEmitter = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
    Radius = 18,
    VisualScale = 0.8,

    Buffs = {'SeraphimACURegenAura'},
}

BuffFieldBlueprint { Name = 'SeraphimAdvancedACURegenBuffField',

    AffectsUnitCategories = categories.SERAPHIM,
    AffectsOwnUnits = true,
    --AttachBone = 'Torso',
    DisableInTransport = true,
    FieldVisualEmitter = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
    Radius = 24,
    VisualScale = 1.2,

    Buffs = {'SeraphimAdvancedACURegenAura'},
}

BuffFieldBlueprint { Name = 'SeraphimRegenBuffField',

    AffectsUnitCategories = categories.SERAPHIM,
    AffectsOwnUnits = true,
    DisableInTransport = true,
    FieldVisualEmitter = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
    MaintenanceConsumptionPerSecondEnergy = 900,
    Radius = 26,

    Buffs = {'SeraphimRegenFieldMoo'},
}



