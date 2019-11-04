#**  File     :  /lua/AI/CustomAITooltips/CheatOptionsTooltips.lua
#**  Author(s): Michael Robbins aka Sorian
#**  Summary  : Utility File to insert custom AI Tooltips into the game.

Tooltips = {
	########################
	#   Cheat Multiplyer   #
	########################
    ["Lobby_Cheat_Mult"] = {
        title = "Cheat Multiplyer",
        description = "Sets the resource multiplier for the cheating AIs.",
    },
	["lob_CheatMult_0.8"] = {
        title = "0.8",
        description = "AIx Resources -20%. - greatly reduced",
    },	    
	["lob_CheatMult_0.9"] = {
        title = "0.9",
        description = "AIx Resources -10%. - slightly reduced",
    },	
	["lob_CheatMult_1.0"] = {
        title = "1.0",
        description = "AIx Normal Resources.",
    },
	["lob_CheatMult_1.05"] = {
        title = "1.05",
        description = "AIx Resources +5%",
    },
	["lob_CheatMult_1.075"] = {
        title = "1.075",
        description = "AIx Resources +7.5%",
    },
	["lob_CheatMult_1.1"] = {
        title = "1.1",
        description = "AIx Resources +10%",
    },
	["lob_CheatMult_1.125"] = {
        title = "1.125",
        description = "AIx Resources +12.5%",
    },
	["lob_CheatMult_1.15"] = {
        title = "1.150",
        description = "AIx Resources +15%",
    },
	["lob_CheatMult_1.175"] = {
        title = "1.175",
        description = "AIx Resources +17.5%",
    },	
	["lob_CheatMult_1.2"] = {
        title = "1.200",
        description = "AIx Resources +20%.",
    },
	["lob_CheatMult_1.225"] = {
        title = "1.225",
        description = "AIx Resources +22.5%",
    },	
	["lob_CheatMult_1.25"] = {
        title = "1.250",
        description = "AIx Resources +25%.",
    },
	["lob_CheatMult_1.3"] = {
        title = "1.300",
        description = "AIx Resources +30%",
    },
	["lob_CheatMult_1.35"] = {
        title = "1.35",
        description = "AIx Resources +35%",
    },	
	["lob_CheatMult_1.4"] = {
        title = "1.40",
        description = "AIx Resources +40%",
    },
	["lob_CheatMult_1.5"] = {
        title = "1.50",
        description = "AIx Resources +50%",
    },
	["lob_CheatMult_1.75"] = {
        title = "1.75",
        description = "AIx Resources +75%",
    },
	["lob_CheatMult_2.0"] = {
        title = "2.00",
        description = "AIx Resources +100%",
    },

	########################
	#   Build Multiplyer   #
	########################
    ["Lobby_Build_Mult"] = {
        title = "Build Multiplyer",
        description = "Sets the build rate multiplier for the cheating AIs.",
    },
	["lob_BuildMult_0.8"] = {
        title = "0.8",
        description = "AIx Build Rate -20% - slowest.",
    },    
	["lob_BuildMult_0.9"] = {
        title = "0.9",
        description = "AIx Build Rate -10% - slower.",
    },
	["lob_BuildMult_1.0"] = {
        title = "1.0",
        description = "AIx Build Rate - standard",
    },
	["lob_BuildMult_1.05"] = {
        title = "1.050",
        description = "AIx Build Rate +5%",
    },
	["lob_BuildMult_1.075"] = {
        title = "1.075",
        description = "AIx Build Rate +7.5%",
    },
	["lob_BuildMult_1.1"] = {
        title = "1.10",
        description = "AIx Build Rate +10%.",
    },
	["lob_BuildMult_1.125"] = {
        title = "1.125",
        description = "AIx Build Rate +12.5%.",
    },
	["lob_BuildMult_1.15"] = {
        title = "1.150",
        description = "AIx Build Rate +15%",
    },
	["lob_BuildMult_1.175"] = {
        title = "1.175",
        description = "AIx Build Rate +17.5%",
    },	
	["lob_BuildMult_1.2"] = {
        title = "1.200",
        description = "AIx Build Rate +20%.",
    },
	["lob_BuildMult_1.225"] = {
        title = "1.225",
        description = "AIx Build Rate +22.5%",
    },	
	["lob_BuildMult_1.25"] = {
        title = "1.250",
        description = "AIx Build Rate +25%.",
    },
	["lob_BuildMult_1.3"] = {
        title = "1.30",
        description = "AIx Build Rate +30%.",
    },
	["lob_BuildMult_1.35"] = {
        title = "1.35",
        description = "AIx Build Rate +35%",
    },	
	["lob_BuildMult_1.4"] = {
        title = "1.40",
        description = "AIx Build Rate +40%",
    },
	["lob_BuildMult_1.5"] = {
        title = "1.50",
        description = "AIx Build Rate +50%",
    },
	["lob_BuildMult_1.75"] = {
        title = "1.75",
        description = "AIx Build Rate +75%",
    },
	["lob_BuildMult_2.0"] = {
        title = "2.00",
        description = "AIx Build Rate +100%",
    },


	########################
	#	Unit Cap Cheat	   #
	########################
   ["Lobby_Cap_Cheat"] = {
        title = "Unit Cap Setting",
        description = "Sets whether the AIx Commanders have an unlimited unit cap or not.",
    },
	["lob_CapCheat_unlimited"] = {
        title = "Unlimited",
        description = "AIx Commanders have no unit limit.",
    },
	["lob_CapCheat_cheatlevel"] = {
		title = "CheatLevel",
		description = "AIx Commanders unit cap tied to Resource Cheat.",
	},
	["lob_CapCheat_off"] = {
        title = "Off",
        description = "AIx Commanders have the same unit cap as human players.",
    },	

	############################
	#	Unused Start Locations #
	############################
	["Lobby_UnusedResources"] = {
		title = "Unused Start Locations",
		description = "Remove resources near unused Start Locations",
	},
	["lob_UnusedResources_1"] = {
		title = "Keep All",
		description = "Keep all resources at unused Start Locations",
	},
	["lob_UnusedResources_2"] = {
		title = "Keep 50%",
		description = "50% chance that resources will be kept",
	},
	["lob_UnusedResources_3"] = {
		title = "Keep 33%",
		description = "33% chance that resources will be kept",
	},
	["lob_UnusedResources_4"] = {
		title = "Keep 25%",
		description = "25% chance that resources will be kept",
	},
	["lob_UnusedResources_5"] = {
		title = "Keep 20%",
		description = "20% chance that resources will be kept",
	},
	["lob_UnusedResources_10"] = {
		title = "Keep 10%",
		description = "10% chance that resources will be kept",
	},
	["lob_UnusedResources_100"] = {
		title = "Remove All",
		description = "No start location resources will be kept",
	},
	#######################
	#    Missile Options  #
	#######################
	["Lobby_MissileOption"] = {
		title = "Missile Options",
		description = "Allow Nukes & Antinukes to have prebuilt missiles",
	},
	["lob_MissileOption_0"] = {
		title = "Empty",
		description = "All Nukes and Antinukes are empty when built",
	},
	["lob_MissileOption_1"] = {
		title = "One",
		description = "All Nukes and Antinukes come with one missile when built",
	},
	["lob_MissileOption_2"] = {
		title = "Two",
		description = "All Nukes and Antinukes come with two missiles when built",
	},
	
}