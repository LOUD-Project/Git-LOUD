---  /lua/ai/StructurePlatoonTemplates.lua

-- There used to be a whole lot more platoons for all manner of upgradeable structures since, in the past
-- unit upgrades were performed by the PFM.  Since such units now self-upgrade, the only remaining 
-- structure platoons are used to group certain structures to force a behaviour on them


PlatoonTemplate { Name = 'StrategicArtilleryStructure',
    Plan = 'ArtilleryAI',
    GlobalSquads = {
        { categories.ARTILLERY * categories.STRUCTURE - categories.TACTICAL - categories.TECH2 - categories.TECH1, 1, 1, 'artillery', 'None' }
    }
}

PlatoonTemplate { Name = 'T3Nuke',
    Plan = 'NukeAIHub',
    GlobalSquads = {
        { categories.NUKE * categories.STRUCTURE * ( categories.TECH3 + categories.EXPERIMENTAL ), 1, 6, 'attack', 'none' },
    }
}

PlatoonTemplate { Name = 'T4SatelliteExperimental',
    Plan = 'AirForceAILOUD',
    GlobalSquads = {
        { categories.SATELLITE, 1, 1, 'attack', 'none' },
    }
}