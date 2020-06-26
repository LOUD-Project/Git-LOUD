--   /lua/sim/buffdefinition.lua

local AdjBuffFuncs = import('/lua/sim/adjacencybufffunctions.lua')

-- These first two buffs are from the standard Sera ACU
BuffBlueprint { Name = 'SeraphimACURegenAura',
    DisplayName = 'SeraphimACURegenAura',
    BuffType = 'REGENAURA',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.25,
            Ceil = 75,
			Floor = 1,
		},
	},
	Effects = {
		'/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
	},
	EffectsScale = 0.5,
}

BuffBlueprint { Name = 'SeraphimAdvancedACURegenAura',
    DisplayName = 'SeraphimAdvancedACURegenAura',
    BuffType = 'REGENAURA',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.5,
            Ceil = 150,
            Floor = 3,
		},
		ShieldRegeneration = {
		    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
			Add = 0,
			Mult = 1.125,
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
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.5,
            Ceil = 150,
            Floor = 3,
        },
		ShieldRegeneration = {
		    BuffCheckFunction = AdjBuffFuncs.ShieldRegenBuffCheck,
			Add = 0,
			Mult = 1.125,
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

-- These are LOUD specific buffs
BuffBlueprint { Name = 'AIRSTAGING',
	BuffType = 'AIRSTAGING',
	Stacks = 'IGNORE',
	Duration = 3,
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
	EffectsScale = 0.25,
}

BuffBlueprint { Name = 'DarknessOmniNerf',
    DisplayName = 'DarknessOmniNerf',
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

-- This buff is for Aeon Maelstrom Field from BAL0402
-- and the Aeon BO ACU
BuffBlueprint { Name = 'AeonMaelstromField',
    DisplayName = 'AeonMaelstromField',
    BuffType = 'DAMAGEAURA',
    Stacks = 'IGNORE',
    Duration = 3,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -40,
            Mult = 1.0,
        },
    },
	--Effects = {'/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_01_emit.bp'},
	--EffectsScale = 0.4,
}

BuffBlueprint { Name = 'AeonMaelstromField2',
    DisplayName = 'AeonMaelstromField2',
    BuffType = 'DAMAGEAURA',
    Stacks = 'IGNORE',
    Duration = 3,	-- this is unique in that it has a duration -- the buff will be applied every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -80,
            Mult = 1.0,
        },
    },
	--Effects = {'/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_01_emit.bp'},
	--EffectsScale = 0.65,
}

BuffBlueprint { Name = 'AeonMaelstromField3',
    DisplayName = 'AeonMaelstromField3',
    BuffType = 'DAMAGEAURA',
    Stacks = 'IGNORE',
    Duration = 3,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -120,
            Mult = 1.0,
        },
    },
	--Effects = {'/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_01_emit.bp'},
	--EffectsScale = 0.90,
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
			Floor = 15,
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
			Add = 180,
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
			Add = 275,
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
			Add = 120,
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
			Add = 200,
			Mult = 1.0,
		},
		OmniRadius = {
			Add = 60,
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
            Mult = 1.05,
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
            Mult = 1.1,	--1.2,	-- 1.18
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
            Mult = 1.15, 	--1.3,	-- 1.24
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
            Mult = 1.2,	--1.4,	-- 1.28
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
            Mult = 1.25,	--5,	-- 1.3
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


-- Cheat Buffs for the AI

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

BuffBlueprint { Name = 'CheatEnergyStorage',
	BuffType = 'ENERGYSTORAGE',
	Stacks = 'REPLACE',
	Duration = -1,
	Affects = {
		EnergyStorage = {
		    BuffCheckFunction = AdjBuffFuncs.EnergyStorageBuffCheck,
			Add = 0,
			Mult = 1,
		},
	},
}

BuffBlueprint { Name = 'CheatMassStorage',
	BuffType = 'MASSSTORAGE',
	Stacks = 'REPLACE',
	Duration = -1,
	Affects = {
		MassStorage = {
		    BuffCheckFunction = AdjBuffFuncs.MassStorageBuffCheck,
			Add = 0,
			Mult = 1,
		},
	},
}


BuffBlueprint { Name = 'CheatCDROmni',
    BuffType = 'COMMANDERCHEAT',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        OmniRadius = {
            Add = 15,
            Mult = 1,
        },
        VisionRadius = {
            Add = 15,
            Mult = 1,
        },
		WaterVisionRadius = {
		    BuffCheckFunction = AdjBuffFuncs.WaterVisionBuffCheck,
			Add = 15,
			Mult = 1,
		},    
    },        
}

BuffBlueprint { Name = 'CheatENG',
    BuffType = 'ENGINEERCHEAT',
	ParsedEntityCategory = categories.ENGINEER,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		MoveMult = {
			Add = 0,
			Mult = 1.2,
		},
        VisionRadius = {
            Add = 15,
            Mult = 1,
        },
		WaterVisionRadius = {
			Add = 30,
			Mult = 1,
		},
        OmniRadius = {
            Add = 5,
            Mult = 1,
        }
    },
}

BuffBlueprint { Name = 'CheatMOBILE',
    BuffType = 'MOVEMENTCHEAT',
	ParsedEntityCategory = categories.MOBILE,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		MoveMult = {
			Add = 0,
			Mult = 1,
		},
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

-- STD ACU Buffs
BuffBlueprint { Name = 'ACU_T2_Engineering',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  20,
            Mult = 1,
		},
        MaxHealth = {
            Add = 3000,
            Mult = 1.0,
        },
        Regen = {
            Add = 20,
            Mult = 1.0,
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
            Add =  80,
            Mult = 1,
        },
        MaxHealth = {
            Add = 6000,
            Mult = 1.0,
        },
        Regen = {
            Add = 35,
            Mult = 1.0,
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
            Add =  110,
            Mult = 1,
        },
		MoveMult = {
			Add = 0,
			Mult = 1.1,
		},
        MaxHealth = {
            Add = 10000,
            Mult = 1.0,
        },
        Regen = {
            Add = 50,
            Mult = 1.0,
        },
    },
}

-- BO ACU Buffs
BuffBlueprint { Name = 'ACU_T2_Imp_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND,
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  15,
            Mult = 1,
		},
		MassProduction = {
			Add = 2,
			Mult = 1,
		},
		EnergyProduction = {
			Add = 0,	-- works strangely - actually will add 80 power taking it to 100 - was 11.5 taking Bob to 250
			Mult = 5,
		},
	},
}

BuffBlueprint { Name = 'ACU_T3_Adv_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND, --'COMMAND',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  65,
            Mult = 1,
        },
		MassProduction = {
			Add = 7,
			Mult = 1,
		},
		EnergyProduction = {
			Add = 0,	-- will add 400 power taking it to 500 - was 74 and took Bob to 1500
			Mult = 25,
		},
    },
}

BuffBlueprint { Name = 'ACU_T4_Exp_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND, --'COMMAND',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  200,
            Mult = 1,
        },
		MassProduction = {
			Add = 13,
			Mult = 1,
		},
		EnergyProduction = {
			Add = 0,	-- will add 1230 power taking it to 1500 - was 114,
			Mult = 75,
		},
		MoveMult = {
			Add = 0,
			Mult = 1.1,
		},
    },
}

BuffBlueprint { Name = 'ACU_T2_Combat_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND, --'COMMAND',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  10,
            Mult = 1,
        },
        MaxHealth = {
            Add = 10000,
            Mult = 1,
        },
        Regen = {
            Add = 15,
            Mult = 1,
        },
    },
}

BuffBlueprint { Name = 'ACU_T3_Combat_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedEntityCategory = categories.COMMAND, --'COMMAND',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  35,
            Mult = 1,
        },
        MaxHealth = {
            Add = 30000,
            Mult = 1.0,
        },
        Regen = {
            Add = 50,
            Mult = 1,
        },
    },
}

BuffBlueprint { Name = 'ACU_T4_Combat_Eng',
    BuffType = 'ACUBUILDRATE',
	ParsedParsedEntityCategory = categories.COMMAND, --'COMMAND',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add =  80,
            Mult = 1,
        },
        MaxHealth = {
            Add = 60000,
            Mult = 1.0,
        },
        Regen = {
            Add = 90,
            Mult = 1,
        },
		MoveMult = {
			Add = 0,
			Mult = 1.1,
		},
    },
}

-- Just a note here - the relationship between RADAR range and power consumption is calculated
-- using Pasternaks Radar range calcuator - using a gain of 20db at 10GHZ
-- and a radar cross-section of 1 square metre with a return strength of 10 versus the power input

-- A detailed explanation of this calcuation can be found at http://www.radartutorial.eu/01.basics/The%20Radar%20Range%20Equation.en.html
-- The calculator itself can be found online at https://www.pasternack.com/t-calculator-radar-range.aspx

-- by contrast, for the regular T3 radar systems, I use a lower 12db gain.   All smaller radar systems
-- are NOT aligned with this formula but probably should be for conformity sake

-- as each pair of antenna come online, I move this gain figure up be 1db - eventually reaching
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

    for name, data in array do
        BuffBlueprint {
            Name = name .. '_Buff', DisplayName = name .. '_Buff',
            BuffType = 'PANOPTICONUPGRADE', Stacks = 'ALWAYS', Duration = -1,
            Affects = {
                RadarRadius = {Add = 0, Mult = data.RadarRadius},
                OmniRadius = {Add = 0, Mult = data.OmniRadius},
                EnergyMaintenance = {Add = 0, Mult = data.EnergyMaintenance},
            }
        }
    end
end

__moduleinfo.auto_reload = true
