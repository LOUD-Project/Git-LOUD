GPGrestrictedUnits = {

-- Just some notes here about categories
-- Apparently, unlike category filtering elsewhere in the code, you cannot
-- specify cocatenated categories - you can only use base categories - or specific unit ids

    T1 = {
        categories = {"TECH1"},
        name = "<LOC restricted_units_data_0000>No Tech 1",
        tooltip = "restricted_units_T1",
    },
	
    T2 = {
        categories = {"TECH2"},
        name = "<LOC restricted_units_data_0001>No Tech 2",
        tooltip = "restricted_units_T2",
    },
	
    T3 = {
        categories = {"TECH3"},
        name = "<LOC restricted_units_data_0002>No Tech 3",
        tooltip = "restricted_units_T3",
    },
	
    EXPERIMENTAL = {
        categories = {"EXPERIMENTAL"},
        name = "<LOC restricted_units_data_0003>No Experimental",
        tooltip = "restricted_units_experimental",
    },
	
    NAVAL = {
        categories = {"NAVAL"},
        name = "<LOC restricted_units_data_0004>No Naval",
        tooltip = "restricted_units_naval",
    },
	
    LAND = {
        categories = {"LAND"},
        name = "<LOC restricted_units_data_0005>No Land",
        tooltip = "restricted_units_land",
    },
	
    AIRSCOUTS = {
        categories = {"uaa0101","uaa0302","uea0101","uea0302","ura0101","ura0302","xsa0101","xsa0302" },
        name = "No Air Scouts",
        tooltip = "restricted_units_air_scouts",
    },

    AIRFIGHTERS = {
		categories = {"brpat2figbo","uaa0102","uea0102","ura0102","xsa0102","xaa0202","dea0202","dra0202","xsa0202","uaa0303","uea0303","ura0303","xsa0303"},
		name = "No Air Fighters",
		tooltip = "restricted_units_air_fighters",
    },
	
    AIRBOMBERS = {
		categories = {"BOMBER","TORPEDOBOMBER"},
		name = "No Air Bombers or Torpedo Bombers",
		tooltip = "restricted_units_air_bombers",
    },
	
    AIRGUNSHIPS = {
		categories = {"GROUNDATTACK"},
		name = "No Air Gunships",
		tooltip = "restricted_units_air_gunships",
    },
	
    AIRTRANSPORTS = {
		categories = {"TRANSPORTFOCUS"},
		name = "No Air Transports",
		tooltip = "restricted_units_air_transports",
    },

    AIREXPERIMENTALS = {
		categories = {"bea0402", "bea0403", "ura0401", "xsa0402", "bra0409", "tcau0401", "uaa0310",},
		name = "No Air Experimentals",
		tooltip = "restricted_units_air_experimentals",
    },
	
	TACTICALMISSILELAUNCHERS = {
		categories = { 'uab2108', 'ueb2108', 'urb2108', 'xsb2108', 'bab2308', },
		name = "No Tactical Missile structures",
		tooltip = "restricted_units_tactical",
	},
	
    NUKE = {
        categories = {"uab2305", "ueb2305", "urb2305", "xsb2305", "xsb2401", "uas0304", "ues0304", "urs0304", "xss0302" },
        name = "<LOC restricted_units_data_0011>No Nukes",
        tooltip = "restricted_units_nukes",
    },
	
	HEAVYARTILLERY = {
		categories = { "uab2302","ueb2302","urb2302","xsb2302" },
		name = "No T3 Artillery",
		tooltip = "restricted_units_T3_artillery",
	},
	
	EXPERIMENTALARTILLERY = {
		categories = { "xab2307", "ueb2401", "url0401" },
		name = "No Experimental Artillery",
		tooltip = "restricted_units_exp_artillery",
	},
	
    GAMEENDERS = {
        categories = { "uas0304", "ues0304", "urs0304", "uab2302", "xss0302", "urb2302", "ueb2302", "xsb2302", },
        name = "<LOC restricted_units_data_0012>No Game Enders",
        tooltip = "restricted_units_gameenders",
    },
	
    SHIELDS = {
        categories = {"uel0307", "ual0307", "xsl0307", "xes0205", "ueb4202", "urb4202", "uab4202", "xsb4202", "ueb4301", "uab4301", "xsb4301", },
        name = "<LOC restricted_units_data_0013>No Shield Units",
        tooltip = "restricted_units_bubbles",
    },
	
    INTEL = {
        categories = {"OMNI", "uab3101", "uab3201", "ueb3101", "ueb3201", "urb3101", "urb3201", "xsb3101", "xsb3201", "uab3102", "uab3202", "ueb3102", "ueb3202", "urb3102", "urb3202", "xsb3102", "xsb3202", "xab3301", "xrb3301", "ues0305", "uas0305", "urs0305", },
        name = "<LOC restricted_units_data_0014>No Intel Structures",
        tooltip = "restricted_units_intel",
    },
	
    SUPCOM = {
        categories = {"SUBCOMMANDER", },
        name = "<LOC restricted_units_data_0015>No Support Commanders",
        tooltip = "restricted_units_supcom",
    },
	
    FABS = {
        categories = {"ueb1104", "ueb1303", "urb1104", "urb1303", "uab1104", "uab1303", "xsb1104", "xsb1303", },
        name = "<LOC restricted_units_data_0019>No Mass Fabrication",
        tooltip = "restricted_units_massfab",
    },
	
    NOENGINEERS = {
		categories = {"ual0105", "ual0208", "ual0309", "uel0105", "uel0208", "uel0309", "url0105", "url0208", "url0309", "xsl0105", "xsl0208", "xsl0309", "xel0209", },
		name = "No T1, T2, T3 Engineers",
		tooltip = "restricted_units_engineers",
    },

}

GPGsortOrder = {
    "UEF",
    "CYBRAN",
    "AEON",
    "SERAPHIM",
    "T1",
    "T2",
    "T3",
    "EXPERIMENTAL",
    "NAVAL",
    "LAND",
	"AIRSCOUTS",
	"AIRFIGHTERS",
	"AIRBOMBERS",
	"AIRGUNSHIPS",
	"AIRTRANSPORTS",
    "AIREXPERIMENTALS",	
	"TACTICALMISSILELAUNCHERS",
    "NUKE",
	"HEAVYARTILLERY",
	"EXPERIMENTALARTILLERY",
    "GAMEENDERS",
    "BUBBLES",
    "INTEL",
    "SUPCOM",
    "FABS",
    "NOENGINEERS",

}

GPGOptions = {}

versionstrings = {
	us = 'Version :',
	es = 'Versi\195\179n :',
	fr = 'Version :',
	it = 'Versione :',
	gr = 'Version :',
}