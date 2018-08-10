--   /lua/sim/buffdefinition.lua


-- These first two buffs are from the standard Sera ACU
BuffBlueprint { Name = 'SeraphimACURegenAura',
    DisplayName = 'SeraphimACURegenAura',
    BuffType = 'REGENAURA',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.2,
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
            Mult = 1.4,
            Ceil = 150,
            Floor = 2,
		},
		ShieldRegeneration = {
			Add = 0,
			Mult = 1.1,
		},
		VisionRadius = {
			Add = 0,
			Mult = 1.1,
		},
	},
	Effects = {
		'/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
	},
	EffectsScale = 0.5,
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

-- This buff is for the BO Restoration Field building
BuffBlueprint { Name = 'SeraphimRegenFieldMoo',
    DisplayName = 'SeraphimRegenFieldMoo',
    BuffType = 'REGENAURA',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RegenPercent = {
            Add = 0,
            Mult = 1.5,
            Ceil = 150,
            Floor = 3,
        },
		ShieldRegeneration = {
			Add = 0,
			Mult = 1.1,
		},
		VisionRadius = {
			Add = 0,
			Mult = 1.1,
		},
    },
	Effects = {
		'/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
	},
	EffectsScale = 0.5,
}

-- These are LOUD specific buffs
BuffBlueprint { Name = 'CybranOpticalDisruptionField',
    DisplayName = 'CybranOpticalDisruptionField',
    BuffType = 'DAMAGEAURA',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		VisionRadius = {
			Add = 0,
			Mult = 0.75,
		},
		RadarRadius = {
			Add = 0,
			Mult = 0.65,
		},
		OmniRadius = {
			Add = 0,
			Mult = 0.5,
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
    BuffType = 'OmniRadius',
    Stacks = 'REPLACE',
    Duration = 20.1,
    Affects = {
        OmniRadius = {
            Add = 0,
            Mult = 0.6,
        },
    },
	Effects = {
		'/effects/emitters/jammer_ambient_01_emit.bp',
		'/effects/emitters/jammer_ambient_02_emit.bp',
	},
	EffectsScale = 0.65,	
}

-- This buff is for Aeon Maelstrom Field from BAL0402
-- and the Aeon BO ACU
BuffBlueprint { Name = 'AeonMaelstromField',
    DisplayName = 'AeonMaelstromField',
    BuffType = 'DAMAGEAURA',
    Stacks = 'REPLACE',
    Duration = 1,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -40,
            Mult = 1.0,
        },
    },
	Effects = {
		'/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_01_emit.bp'
	},
	EffectsScale = 0.4,
}

BuffBlueprint { Name = 'AeonMaelstromField2',
    DisplayName = 'AeonMaelstromField2',
    BuffType = 'DAMAGEAURA',
    Stacks = 'REPLACE',
    Duration = 1,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -80,
            Mult = 1.0,
        },
    },
	Effects = {
		'/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_01_emit.bp'
	},
	EffectsScale = 0.65,
}

BuffBlueprint { Name = 'AeonMaelstromField3',
    DisplayName = 'AeonMaelstromField3',
    BuffType = 'DAMAGEAURA',
    Stacks = 'REPLACE',
    Duration = 1,	-- this is unique in that it has a duration -- all this does is tell the buff system to keep applying the buff every second while in the field
    Affects = {
        Health = {
			-- damage enemy units every second
            Add = -120,
            Mult = 1.0,
        },
    },
	Effects = {
		'/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_01_emit.bp'
	},
	EffectsScale = 0.90,
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
    BuffType = 'CHEATBUILDRATE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add = 0,
            Mult = 1.05,
        },
		EnergyMaintenance = {
			Add = -0.20,
			Mult = 1.0,
		},
		EnergyActive = {
			Add = -0.20,
			Mult = 1.0,
		},
		MassActive = {
			Add = -0.20,
			Mult = 1.0,
		}
    },
}

BuffBlueprint { Name = 'CheatIncome',
    BuffType = 'CHEATINCOME',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyProduction = {
            Add = 0,
            Mult = 1.05,
        },
        MassProduction = {
            Add = 0,
            Mult = 1.05,
        }
    },
}

BuffBlueprint { Name = 'CheatIntel',
	BuffType = 'CHEATINTEL',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
		VisionRadius = {
			Add = 0,
			Mult = 1.05,
		},
		WaterVisionRadius = {
			Add = 0,
			Mult = 1.05,
		},
		RadarRadius = {
			Add = 0,
			Mult = 1.05,
		},
		SonarRadius = {
			Add = 0,
			Mult = 1.05,
		},
		OmniRadius = {
			Add = 0,
			Mult = 1.05,
		}
	},
}

BuffBlueprint { Name = 'CheatCDROmni',
    BuffType = 'COMMANDERCHEAT',
	EntityCategory = 'COMMAND',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        OmniRadius = {
            Add = 75,
            Mult = 1.0,
    },

        VisionRadius = {
            Add = 100,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'CheatENG',
    BuffType = 'COMMANDERCHEAT',
	EntityCategory = 'ENGINEER',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		MoveMult = {
			Add = 0,
			Mult = 1.2,
		},
        VisionRadius = {
            Add = 15,
            Mult = 1.0,
        },
		WaterVisionRadius = {
			Add = 30,
			Mult = 1.0,
		},
        OmniRadius = {
            Add = 5,
            Mult = 1.0,
        }
    },
}

BuffBlueprint { Name = 'CheatMOBILE',
    BuffType = 'COMMANDERCHEAT',
	EntityCategory = 'MOBILE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
		MoveMult = {
			Add = 0,
			Mult = 1.05,
		},
	},
}

BuffBlueprint { Name = 'CheatALL',
	BuffType = 'COMMANDERCHEAT',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
		MaxHealth = {
			Add = 0,
			Mult = 1.05,
		},
		RegenPercent = {
			Add = 0,
			Mult = 1.05,
		},
		ShieldRegeneration = {
			Add = 0,
			Mult = 1.05,
		},
		ShieldHealth = {
			Add = 0,
			Mult = 1.05,
		}
    },
}

BuffBlueprint { Name = 'CheatAIRSTAGING',
	BuffType = 'AIRSTAGINGCHEAT',
	EntityCategory = 'AIR,MOBILE',
	Stacks = 'REPLACE',
	Duration = -1,
	Affects = {
		Health = {
			Add = 0,
			Mult = 1.10,
		},
		FuelRatio = {
			Add = 0.05,
			Mult = 1.0,
		}
	},
}

-- BO ACU Buffs
BuffBlueprint { Name = 'ACU_T2_Imp_Eng',
    BuffType = 'ACUBUILDRATE',
	EntityCategory = 'COMMAND',
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
	EntityCategory = 'COMMAND',
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
	EntityCategory = 'COMMAND',
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
	EntityCategory = 'COMMAND',
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
	EntityCategory = 'COMMAND',
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
	EntityCategory = 'COMMAND',
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


__moduleinfo.auto_reload = true
