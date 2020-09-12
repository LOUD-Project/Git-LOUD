#**  File     :  /lua/AI/CustomAITooltips/CheatOptionsTooltips.lua
#**  Author(s): Michael Robbins aka Sorian
#**  Summary  : Utility File to insert custom AI Tooltips into the game.

Tooltips = {

	########################
	#	Unit Cap Cheat	   #
	########################
   ["Lobby_Cap_Cheat"] = {
        title = "Unit Cap Setting",
        description = "Sets if AI players have normal unit caps, enhanced unit caps (by AI multiplier) or an unlimited unit cap.",
    },
	["lob_CapCheat_unlimited"] = {
        title = "Unlimited",
        description = "AI players have no unit limit.",
    },
	["lob_CapCheat_cheatlevel"] = {
		title = "CheatLevel",
		description = "AI players get a normal unit cap modified by the AI Multiplier.",
	},
	["lob_CapCheat_off"] = {
        title = "Off",
        description = "AI players have the same unit cap as human players.",
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