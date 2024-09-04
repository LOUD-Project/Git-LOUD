--   /lua/sim/buffdefinition.lua

local AdjBuffFuncs = import('/lua/sim/adjacencybufffunctions.lua')

-- These first two buffs are from the standard Sera ACU
BuffBlueprint { Name = 'SeraphimACURegenAura',
    DisplayName = 'SeraphimACURegenAura',
    BuffType = 'REGENAURA',
    Stacks = 'IGNORE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.3,
            Ceil = 75,
			Floor = 1,
		},
	},
	Effects = {
		'/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
	},
	EffectsScale = 0.4,
}

BuffBlueprint { Name = 'SeraphimAdvancedACURegenAura',
    DisplayName = 'SeraphimAdvancedACURegenAura',
    BuffType = 'REGENAURA',
    Stacks = 'IGNORE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.6,
            Ceil = 125,
            Floor = 3,
		},
		ShieldRegeneration = {
		    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
			Add = 0,
			Mult = 1.15,
		},
		VisionRadius = {
			Add = 0,
			Mult = 1.125,
		},
	},
	Effects = {
		'/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
	},
	EffectsScale = 0.5,
}

-- This buff is for the BO Restoration Field building
BuffBlueprint { Name = 'SeraphimRegenFieldMoo',
    DisplayName = 'SeraphimRegenFieldMoo',
    BuffType = 'REGENAURA',
    Stacks = 'IGNORE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.75,
            Ceil = 125,
            Floor = 3,
        },
		ShieldRegeneration = {
		    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
			Add = 0,
			Mult = 1.175,
		},
		VisionRadius = {
			Add = 0,
			Mult = 1.125,
		},
    },
	Effects = {
		'/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
	},
	EffectsScale = 0.6,
}

-- These are LOUD specific buffs

-- This is a 4% mobility penalty
BuffBlueprint { Name = 'MobilityPenalty',
	BuffType = 'MOBILITY',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
		SpeedMult = {
			Add = 0,
			Mult = 0.96,
		},
		AccelMult = {
			Add = 0,
			Mult = 0.96,
		},
        TurnMult = {
            Add = 0,
            Mult = 0.96,
        },
	},
}

-- this is a 33% agility buff (turn and accelerate only)
BuffBlueprint { Name = 'AgilityBuff',
	BuffType = 'AGILITY',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
		AccelMult = {
			Add = 0,
			Mult = 1.33,
		},
        TurnMult = {
            Add = 0,
            Mult = 1.33,
        },
	},
}

-- this is a 10 point regen buff --
BuffBlueprint { Name = 'RegenPackage10',
    BuffType = 'REGEN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 10,
            Mult = 1.0,
        },
    },
}

-- this is a 15% MaxHP buff (not HP)
BuffBlueprint { Name = 'ArmorPackage1',
    BuffType = 'ARMOR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.15,
            DoNoFill = true,
        },
        Regen = {
            Add = 1,
            Mult = 1.0,
        },
    },
}

-- this is a 7k MaxHP buff (not HP)
BuffBlueprint { Name = 'ArmorPackage7',
    BuffType = 'ARMOR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 7000,
            Mult = 1.0,
            DoNoFill = true,
        },
    },
}

-- this is a 28 range addition to vision & water vision
BuffBlueprint { Name = 'PerimeterOpticsPackage',
    BuffType = 'INTEL',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        VisionRadius = {
            Add = 28,
            Mult = 1.0,
        },
        WaterVisionRadius = {
            Add = 28,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'AIRSTAGING',
	BuffType = 'AIRSTAGING',
	Stacks = 'IGNORE',
	Duration = -1,
	Affects = {
		Health = {
			Add = 0,
			Mult = 1.06,
		},
		FuelRatio = {
			Add = 0.085,
			Mult = 1.0,
		}
	},
}

BuffBlueprint { Name = 'CybranOpticalDisruptionField',
    DisplayName = 'CybranOpticalDisruptionField',
    BuffType = 'COUNTERINTEL',
    Stacks = 'IGNORE',
    Duration = -1,
    Affects = {
		VisionRadius = {
			Add = 0,
			Mult = 0.8,
		},
		RadarRadius = {
		    BuffCheckFunction = AdjBuffFuncs.RadarRadiusBuffCheck,
			Add = 0,
			Mult = 0.7,
		},
        SonarRadius = {
            BuffCheckFunction = AdjBuffFuncs.SonarRadiusBuffCheck,
            Add = 0,
            Mult = 0.7,
        },
		OmniRadius = {
		    BuffCheckFunction = AdjBuffFuncs.OmniRadiusBuffCheck,
			Add = 0,
			Mult = 0.6,
		},
    },
	Effects = {
		'/effects/emitters/jammer_ambient_01_emit.bp',
		'/effects/emitters/jammer_ambient_02_emit.bp',
	},
	EffectsScale = 0.45,
}

BuffBlueprint { Name = 'DarknessEffect',
    DisplayName = 'DarknessEffect',
    BuffType = 'COUNTERINTEL',
    Stacks = 'ALWAYS',
    Duration = 20.1,
    Affects = {
		VisionRadius = {
			Add = 0,
			Mult = 0.9,
		},
		RadarRadius = {
		    BuffCheckFunction = AdjBuffFuncs.RadarRadiusBuffCheck,
			Add = 0,
			Mult = 0.85,
		},
        OmniRadius = {
		    BuffCheckFunction = AdjBuffFuncs.OmniRadiusBuffCheck,
            Add = 0,
            Mult = 0.75,
        },
    },
	Effects = {
		'/effects/emitters/jammer_ambient_01_emit.bp',
		'/effects/emitters/jammer_ambient_02_emit.bp',
	},
	EffectsScale = 0.35,
}

BuffBlueprint { Name = 'RegenPackage1',
    BuffType = 'REGENUPGRADE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 0,
            Mult = 4.0,
			Ceil = 45,
			Floor = 4,
        }
    },
}

BuffBlueprint { Name = 'RegenPackage2',
    BuffType = 'REGENUPGRADE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 0,
            Mult = 6.0,
			Ceil = 75,
			Floor = 25,
        }
    },
}


-- Production Buffs - Build Power
-- please note -- these effects are replacing not stacking
BuffBlueprint { Name = 'FACTORY_30_BuildRate',
    BuffType = 'FACTORYBUILDRATE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
			Add =  0,
            Mult = 1.3,
        },
    },
}

BuffBlueprint { Name = 'FACTORY_60_BuildRate',
    BuffType = 'FACTORYBUILDRATE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 1.6,
        },
    },
}

-- Production Buffs - Materiel Efficiency
-- please note -- I'm stacking these effects -- not replacing
BuffBlueprint { Name = 'FACTORY_10_Materiel',
    BuffType = 'FACTORYRESOURCEUSAGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		EnergyActive = {
			Add = -0.10,
			Mult = 1.0,
		},
		MassActive = {
			Add = -0.10,
			Mult = 1.0,
		},
    },
}

BuffBlueprint { Name = 'FACTORY_20_Materiel',
    BuffType = 'FACTORYRESOURCEUSAGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		EnergyMaintenance = {
			Add = -0.15,
			Mult = 1.0,
		},
		EnergyActive = {
			Add = -0.10,
			Mult = 1.0,
		},
		MassActive = {
			Add = -0.10,
			Mult = 1.0,
		},
    },
}

BuffBlueprint { Name = 'FACTORY_25_Materiel',
    BuffType = 'FACTORYRESOURCEUSAGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		EnergyMaintenance = {
			Add = -0.10,
			Mult = 1.0,
		},
		EnergyActive = {
			Add = -0.05,
			Mult = 1.0,
		},
		MassActive = {
			Add = -0.05,
			Mult = 1.0,
		},
    },
}


-- Intelligence Buffs
BuffBlueprint { Name = 'INSTALL_T2_Radar',
    BuffType = 'STRUCTUREINTELLIGENCE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		RadarRadius = {
			Add = 176,
			Mult = 1.0,
		},
    },
}

BuffBlueprint { Name = 'INSTALL_T3_Radar',
    BuffType = 'STRUCTUREINTELLIGENCE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		RadarRadius = {
			Add = 308,
			Mult = 1.0,
		},
		OmniRadius = {
			Add = 120,
			Mult = 1.0,
		},
    },
}

BuffBlueprint { Name = 'INSTALL_T2_Sonar',
    BuffType = 'STRUCTUREINTELLIGENCE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		SonarRadius = {
			Add = 176,
			Mult = 1.0,
		},
    },
}

BuffBlueprint { Name = 'INSTALL_T3_Sonar',
    BuffType = 'STRUCTUREINTELLIGENCE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		SonarRadius = {
			Add = 228,
			Mult = 1.0,
		},
		RadarRadius = {
			Add = 90,
			Mult = 1.0,
		},        
		OmniRadius = {
			Add = 32,
			Mult = 1.0,
		},
    },
}


-- This buff is for Aeon Maelstrom Field from BAL0402 and the Aeon BO ACU
BuffBlueprint { Name = 'AeonMaelstromField',
    DisplayName = 'AeonMaelstromField',
    BuffType = 'DAMAGEAURA',
    Stacks = 'IGNORE',
    Duration = 3.6,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -40,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'AeonMaelstromField2',
    DisplayName = 'AeonMaelstromField2',
    BuffType = 'DAMAGEAURA',
    Stacks = 'IGNORE',
    Duration = 3.6,	-- this is unique in that it has a duration -- the buff will be applied every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -75,
            Mult = 1.0,
        },
    },
}

BuffBlueprint { Name = 'AeonMaelstromField3',
    DisplayName = 'AeonMaelstromField3',
    BuffType = 'DAMAGEAURA',
    Stacks = 'IGNORE',
    Duration = 3.6,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -100,
            Mult = 1.0,
        },
    },
}


--- THESE ARE THE STANDARD VETERANCY BUFFS ---

-- VETERANCY BUFFS - UNIT HEALTH
BuffBlueprint { Name = 'VeterancyHealth1',
    BuffType = 'VET_HEALTH',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.04,
        },
    },
}

BuffBlueprint { Name = 'VeterancyHealth2',
    BuffType = 'VET_HEALTH',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.08,
        },
    },
}

BuffBlueprint { Name = 'VeterancyHealth3',
    BuffType = 'VET_HEALTH',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.12,
        },
    },
}

BuffBlueprint { Name = 'VeterancyHealth4',
    BuffType = 'VET_HEALTH',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.16,
        },
    },
}

BuffBlueprint { Name = 'VeterancyHealth5',
    BuffType = 'VET_HEALTH',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.20,
        },
    },
}


-- VETERANCY BUFFS - ENERGY WEAPONS
BuffBlueprint { Name = 'VeterancyEnergyWeapon1',
    BuffType = 'VET_ENERGYWEAPON',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 0.98,
        },
    },
}

BuffBlueprint { Name = 'VeterancyEnergyWeapon2',
    BuffType = 'VET_ENERGYWEAPON',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 0.96,
        },
    },
}

BuffBlueprint { Name = 'VeterancyEnergyWeapon3',
    BuffType = 'VET_ENERGYWEAPON',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 0.94,
        },
    },
}

BuffBlueprint { Name = 'VeterancyEnergyWeapon4',
    BuffType = 'VET_ENERGYWEAPON',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 0.92,
        },
    },
}

BuffBlueprint { Name = 'VeterancyEnergyWeapon5',
    BuffType = 'VET_ENERGYWEAPON',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 0.9,
        },
    },
}

-- VETERANCY BUFFS - UNIT REGEN
-- same as above -- why are they not stacking them ?
-- since 'replace' will override any enhancements
-- this needs to be demonstrated before I consider change
-- from the way I read it -- it will REPLACE the existing value
-- with the new value -- which has been added to the existing value
-- so in that respect I guess they may be working as intended

BuffBlueprint { Name = 'VeterancyRegen1',
    BuffType = 'VET_REGEN',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 1,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyRegen2',
    BuffType = 'VET_REGEN',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 2,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyRegen3',
    BuffType = 'VET_REGEN',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 3,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyRegen4',
    BuffType = 'VET_REGEN',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 4,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyRegen5',
    BuffType = 'VET_REGEN',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 5,
            Mult = 1.0,
        }
    },
}

--- VISION RADIUS DEFAULT BUFFS ---

BuffBlueprint { Name = 'VeterancyVisionRadius1',
    BuffType = 'VET_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        VisionRadius = {
            Add = 1,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyVisionRadius2',
    BuffType = 'VET_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		VisionRadius = {
            Add = 1.5,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyVisionRadius3',
    BuffType = 'VET_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		VisionRadius = {
            Add = 2.5,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyVisionRadius4',
    BuffType = 'VET_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		VisionRadius = {
            Add = 4,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyVisionRadius5',
    BuffType = 'VET_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		VisionRadius = {
            Add = 6,
            Mult = 1.0,
        }
    },
}

--- Water VISION RADIUS DEFAULT BUFFS ---

BuffBlueprint { Name = 'VeterancyWaterVisionRadius1',
    BuffType = 'VET_WATER_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        WaterVisionRadius = {
            Add = 1,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyWaterVisionRadius2',
    BuffType = 'VET_WATER_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		WaterVisionRadius = {
            Add = 1.5,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyWaterVisionRadius3',
    BuffType = 'VET_WATER_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		WaterVisionRadius = {
            Add = 2.5,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyWaterVisionRadius4',
    BuffType = 'VET_WATER_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		WaterVisionRadius = {
            Add = 4,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'VeterancyWaterVisionRadius5',
    BuffType = 'VET_WATER_VISION',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		WaterVisionRadius = {
            Add = 6,
            Mult = 1.0,
        }
    },
}

--- Cheat Buffs for the AI

-- these values get overridden by the buffs created in AIutilities
-- so they can take variable settings from the lobby
-- consider these to be just placeholders
BuffBlueprint { Name = 'CheatBuildRate',
    BuffType = 'BUILDRATECHEAT',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
	    BuildRate = {
			BuffCheckFunction = AdjBuffFuncs.BuildRateBuffCheck,
            Add = 0,
            Mult = 1,
        },
		EnergyMaintenance = {
		    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
			Add = -0,
			Mult = 1.0,
		},
		EnergyActive = {
		    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
			Add = -0,
			Mult = 1.0,
		},
		MassActive = {
		    BuffCheckFunction = AdjBuffFuncs.BuildBuffCheck,
			Add = -0,
			Mult = 1.0,
		}
    },
}

BuffBlueprint { Name = 'CheatIncome',
    BuffType = 'INCOMECHEAT',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyProduction = {
		    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
            Add = 0,
            Mult = 1,
        },
        MassProduction = {
		    BuffCheckFunction = AdjBuffFuncs.MassProductionBuffCheck,
            Add = 0,
            Mult = 1,
        }
    },
}

BuffBlueprint { Name = 'CheatIntel',
	BuffType = 'INTELCHEAT',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
		VisionRadius = {
			Add = 0,
			Mult = 1,
		},
		WaterVisionRadius = {
		    BuffCheckFunction = AdjBuffFuncs.WaterVisionBuffCheck,
			Add = 0,
			Mult = 1,
		},
		RadarRadius = {
		    BuffCheckFunction = AdjBuffFuncs.RadarRadiusBuffCheck,
			Add = 0,
			Mult = 1,
		},
		SonarRadius = {
		    BuffCheckFunction = AdjBuffFuncs.SonarRadiusBuffCheck,
			Add = 0,
			Mult = 1,
		},
		OmniRadius = {
		    BuffCheckFunction = AdjBuffFuncs.OmniRadiusBuffCheck,
			Add = 0,
			Mult = 1,
		}
	},
}

BuffBlueprint { Name = 'CheatCDROmni',
    BuffType = 'COMMANDERCHEAT',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        OmniRadius = {
            Add = 16,
            Mult = 1,
        },
        VisionRadius = {
            Add = 16,
            Mult = 1,
        },
		WaterVisionRadius = {
		    BuffCheckFunction = AdjBuffFuncs.WaterVisionBuffCheck,
			Add = 16,
			Mult = 1,
		},    
    },        
}

BuffBlueprint { Name = 'CheatCDREnergyStorage',
	BuffType = 'STORAGE',
	Stacks = 'STACKS',
	Duration = -1,
	Affects = {
		EnergyStorage = {
		    BuffCheckFunction = AdjBuffFuncs.EnergyStorageBuffCheck,
			Add = 0,
			Mult = 0.01,
		},
	},
}

BuffBlueprint { Name = 'CheatCDRMassStorage',
	BuffType = 'STORAGE',
	Stacks = 'STACKS',
	Duration = -1,
	Affects = {
		MassStorage = {
		    BuffCheckFunction = AdjBuffFuncs.MassStorageBuffCheck,
			Add = 0,
			Mult = 0.01,
		},
	},
}


BuffBlueprint { Name = 'CheatENG',
    BuffType = 'ENGINEERCHEAT',
	ParsedEntityCategory = categories.ENGINEER,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		SpeedMult = {
			Add = 0,
			Mult = 1.1,
		},
        AccelMult = {
            Add = 0,
            Mult = 1.08,
        },
        TurnMult = {
            Add = 0,
            Mult = 1.08,
        },
        VisionRadius = {
            Add = 12,
            Mult = 1,
        },
		WaterVisionRadius = {
			Add = 28,
			Mult = 1,
		},
        OmniRadius = {
            Add = 4,
            Mult = 1,
        }
    },
}

BuffBlueprint { Name = 'CheatMOBILE',
    BuffType = 'MOVEMENTCHEAT',
	ParsedEntityCategory = categories.MOBILE * categories.AIR,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		SpeedMult = {
			Add = 0,
			Mult = 1.06,
		},
        AccelMult = {
            Add = 0,
            Mult = 1.06,
        },
        TurnMult = {
            Add = 0,
            Mult = 1.08,
        }
	},
}

BuffBlueprint { Name = 'CheatALL',
	BuffType = 'OVERALLCHEAT',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
		MaxHealth = {
			Add = 0,
			Mult = 1,
		},
		RegenPercent = {
			Add = 0,
			Mult = 1,
		},
		ShieldRegeneration = {
		    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
			Add = 0,
			Mult = 1,
		},
		ShieldHealth = {
			BuffCheckFunction = AdjBuffFuncs.ShieldHealthBuffCheck,
			Add = 0,
			Mult = 1,
		}
    },
}

BuffBlueprint { Name = 'OutOfFuel',
    BuffType = 'MOVEMENTCHEAT',
	ParsedEntityCategory = categories.MOBILE * categories.AIR,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		SpeedMult = {
			Add = 0,
			Mult = 0.4,
		},
        AccelMult = {
            Add = 0,
            Mult = 0.4,
        },
        TurnMult = {
            Add = 0,
            Mult = 0.25,
        }
	},
}


--- STD ACU Buffs

BuffBlueprint { Name = 'ACU_T2_Engineering',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 3,       -- from 10 to 30
		},
        MaxHealth = {
            Add = 0,
            Mult = 1.35,
        },
        Regen = {
            Add = 0,
            Mult = 3.0,     -- from 10 to 30
        },
	},

}

BuffBlueprint { Name = 'ACU_T3_Engineering',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 9,       -- from 10 to 90
        },
        MaxHealth = {
            Add = 0,
            Mult = 1.65,
        },
        Regen = {
            Add = 0,
            Mult = 6.0,     -- from 10 to 60
        },
    },
}

BuffBlueprint { Name = 'ACU_T4_Engineering',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 15,      -- from 10 to 150
        },
        MaxHealth = {
            Add = 0,
            Mult = 2.0,
        },
		SpeedMult = {
			Add = 0,
			Mult = 1.12,
		},
        Regen = {
            Add = 0,
            Mult = 10.0,     -- from 10 to 100
        },
    },
}


--- Black Ops ACU Buffs --

BuffBlueprint { Name = 'ACU_T2_Imp_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 3,       -- from 10 to 30
		},
		MassProduction = {
			Add = 0,
			Mult = 2,       -- from 2 to 4
		},
		SpeedMult = {
			Add = 0,
			Mult = 1.07,
		},        
		EnergyProduction = {
			Add = 0,
			Mult = 5,       -- from 20 to 100
		},
	},
}

BuffBlueprint { Name = 'ACU_T3_Adv_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 9,       -- from 10 to 90
        },
		EnergyProduction = {
			Add = 0,	    -- from 20 to 500
			Mult = 25,
		},
		MassProduction = {
			Add = 0,
			Mult = 5,       -- from 2 to 10
		},
		SpeedMult = {
			Add = 0,
			Mult = 1.14,
		},
        AccelMult = {
            Add = 0,
            Mult = 1.1,
        },
        TurnMult = {
            Add = 0,
            Mult = 1.1,
        },
        Regen = {
            Add = 0,
            Mult = 1.6,     -- from 16 to 25
        },        
    },
}

BuffBlueprint { Name = 'ACU_T4_Exp_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 16,      -- from 10 to 160
        },
		EnergyProduction = {
			Add = 0,	    -- from 20 to 1500
			Mult = 75,
		},
		MassProduction = {
			Add = 0,
			Mult = 12,      -- from 2 to 24
		},
		SpeedMult = {
			Add = 0,
			Mult = 1.2,
		},
        AccelMult = {
            Add = 0,
            Mult = 1.16,
        },
        TurnMult = {
            Add = 0,
            Mult = 1.16,
        },
        Regen = {
            Add = 0,
            Mult = 3,       -- from 20 to 60
        },
    },
}

BuffBlueprint { Name = 'ACU_T2_Combat_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 2.5,     -- from 10 to 25
        },
        MaxHealth = {
            Add = 0,
            Mult = 1.3, 
        },
		SpeedMult = {
			Add = 0,
			Mult = 0.96,
		},        
        Regen = {
            Add = 0,
            Mult = 1.6,       -- from 16 to 25
        },
    },
}

BuffBlueprint { Name = 'ACU_T3_Combat_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 5,       -- from 10 to 50
        },
        MaxHealth = {
            Add = 0,
            Mult = 1.75,
        },
		SpeedMult = {
			Add = 0,
			Mult = 0.91,
		},
        AccelMult = {
            Add = 0,
            Mult = 0.96,
        },
        TurnMult = {
            Add = 0,
            Mult = 0.96,
        },
        Regen = {
            Add = 0,
            Mult = 3.0,       -- from 20 to 60
        },
		MassProduction = {
			Add = 0,
			Mult = 2,       -- from 2 to 4
		},
		EnergyProduction = {
			Add = 0,
			Mult = 5,       -- from 20 to 100
		},        
    },
}

BuffBlueprint { Name = 'ACU_T4_Combat_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  0,
            Mult = 9,       -- from 10 to 90
        },
        MaxHealth = {
            Add = 0,
            Mult = 2.2,
        },
        Regen = {
            Add = 0,
            Mult = 4.5,       -- from 20 to 90
        },
		SpeedMult = {
			Add = 0,
			Mult = 0.875,
		},
        AccelMult = {
            Add = 0,
            Mult = 0.9,
        },
        TurnMult = {
            Add = 0,
            Mult = 0.9,
        },
		MassProduction = {
			Add = 0,
			Mult = 5,       -- from 2 to 10
		},
		EnergyProduction = {
			Add = 0,        -- from 20 to 500
			Mult = 25,
		},        
    },
}

BuffBlueprint { Name = 'ACU_T2_Intel_Package',
    BuffType = 'ACUINTELLIGENCE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		RadarRadius = {
			Add = 0,
			Mult = 2.5,
		},
        SonarRadius = {
            Add = 0,
            Mult = 2.0,
        },
        VisionRadius = {
            Add = 0,
            Mult = 1.25,
        },
        WaterVisionRadius = {
            Add = 0,
            Mult = 1.25,
        },
    },
}

BuffBlueprint { Name = 'ACU_T3_Intel_Package',
    BuffType = 'ACUINTELLIGENCE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
		RadarRadius = {
			Add = 0,
			Mult = 5.0,
		},
        SonarRadius = {
            Add = 0,
            Mult = 4.0,
        },
		OmniRadius = {
			Add = 0,
			Mult = 4.0,
		},
        VisionRadius = {
            Add = 0,
            Mult = 1.75,
        },
        WaterVisionRadius = {
            Add = 0,
            Mult = 1.75,
        },
    },
}

-- Just a note here - the relationship between RADAR range and power consumption is calculated as follows
-- using Pasternaks Radar range calcuator (this calculation is for the Panopticon - we use 12db gain for other radars and sonars)

-- use a linear gain of 20db (12db if using this for regular radar and sonar ranges)
-- frequency of 3.5GHZ
-- radar cross-section of 1 square metre
-- minimum detectable return signal of 10mw

-- enter the consumption value you'd like to use as the radar output power (in Watts) and press 'Calculate'
-- Take the result (which should be in metres) and multiply for 100 - this is your rough in-game range

-- About OMNI - it's not linear, which is why lower powered systems don't have Omni range
-- We assume that OMNI only happens beyond a certain level of power input (I would suggest 500+)
-- the resultant Omni effect is only about 10% of the radar range at that input, but scales up as input rises
-- It is effectively an 'oversaturation' of such degree that it overcomes typical stealth
-- We really need a scaling formula based on power input to better control that

-- A detailed explanation of this calcuation can be found at http://www.radartutorial.eu/01.basics/The%20Radar%20Range%20Equation.en.html
-- The calculator itself can be found online at https://www.pasternack.com/t-calculator-radar-range.aspx

-- by contrast, for the regular T3 radar systems, I use a lower 12db gain
-- Not all radar systems are aligned with this formula but probably should be for conformity sake
-- many units with 'built in' intel ranges would be specifically powered, and tuned to the unit in question
-- to overcome the various inefficiencies that are incurred by less than optimal antennae configurations

-- Specifically for the PanOpticon
-- as each pair of antenna come online, I move this gain figure up by 1db - eventually reaching
-- a total of 24db linear gain

-- The PanOpticons additional dishes should be though of as 'focusing' agents - with the effectiveness
-- of regular radar adhering to Pasternaks formula, but the OMNI focusing becoming increasingly effective
-- as more are added 

-- The final X-band antenna is a focusing agent for them all (which is why they are a pre-requisite)
-- but it allows such a resolution of the target that it's effectively 'vision'.

-- Just one final note - the values I used as a basis of these calculations are NOT, in any way, related
-- to real world values - but only for use in relation to themselves in the context of the game.  In this
-- regard they work very well for establishing a solid relationship between power consumption and radar range
-- and could be applied backwards thru the lower tier and mobile systems in the game if need be.
  
do
    local array = {
	
        Small_Dish_001 = {RadarRadius = 1.113043478, OmniRadius = 1.050000000, EnergyMaintenance = 1.50 },
          Med_Dish_001 = {RadarRadius = 1.046875000, OmniRadius = 1.063122923, EnergyMaintenance = 1.05 },
		  
        Small_Dish_002 = {RadarRadius = 1.126865671, OmniRadius = 1.050000000, EnergyMaintenance = 1.6267376 },
          Med_Dish_002 = {RadarRadius = 1.052980132, OmniRadius = 1.091269841, EnergyMaintenance = 1.10 },
		  
        Small_Dish_003 = {RadarRadius = 1.132075471, OmniRadius = 1.050000000, EnergyMaintenance = 1.6528925 },
          Med_Dish_003 = {RadarRadius = 1.055555555, OmniRadius = 1.125541125, EnergyMaintenance = 1.15 },
		  
        Small_Dish_004 = {RadarRadius = 1.126315789, OmniRadius = 1.050000000, EnergyMaintenance = 1.5942028 },
          Med_Dish_004 = {RadarRadius = 1.070093457, OmniRadius = 1.172161172, EnergyMaintenance = 1.20 },
		  
        Xband_Dish = {RadarRadius = 1, OmniRadius = 1, EnergyMaintenance = 1}
    }

    for name, data in pairs(array) do

        BuffBlueprint { Name = name .. '_Buff', DisplayName = name .. '_Buff',
                    BuffType = 'PANOPTICONUPGRADE', Stacks = 'ALWAYS', Duration = -1,
                    Affects = {
                        RadarRadius = {Add = 0, Mult = data.RadarRadius},
                        OmniRadius = {Add = 0, Mult = data.OmniRadius},
                        EnergyMaintenance = {Add = 0, Mult = data.EnergyMaintenance},
                    }
        }
    end
end

if __moduleinfo then
    __moduleinfo.auto_reload = true
end
