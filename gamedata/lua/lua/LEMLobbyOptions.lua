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
        name = "<LOC restricted_units_data_0003>No Experimental/Tech 4",
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

    AMPHIB = {
        categories = {"AMPHIBIOUS"},
        name = "<LOC restricted_units_data_0032>No Amphibious",
        tooltip = "restricted_units_amphib",
    },

    HOVER = {
        categories = {"HOVER"},
        name = "<LOC restricted_units_data_0033>No Hover",
        tooltip = "restricted_units_hover",
    },
	
    AIRSCOUTS = {
        categories = {"saa0201", "sea0201", "sea0310", "sra0201", "ssa0201", "uaa0101", "uaa0302", "uea0101", "uea0302", "ura0101", "ura0302", "xsa0101", "xsa0302"},
        name = "<LOC restricted_units_data_0020>No Air Scouts",
        tooltip = "restricted_units_air_scouts",
    },

    AIRFIGHTERS = {
		categories = {"brpat2figbo", "dea0202", "dra0202", "lea0401","saa0313", "sea0313", "sra0313", "ssa0313", "uaa0102", "uaa0303", "uea0102", "uea0303", "ura0102", "ura0303", "xaa0202", "xsa0102", "xsa0202", "xsa0303"},
		name = "<LOC restricted_units_data_0021>No Air Fighters",
		tooltip = "restricted_units_air_fighters",
    },
	
    AIRBOMBERS = {
		categories = {"BOMBER"},
		name = "<LOC restricted_units_data_0022>No Air Bombers",
		tooltip = "restricted_units_air_bombers",
    },
	
    AIRTORPEDOBOMBERS = {
        categories = {"TORPEDOBOMBER"},
        name = "<LOC restricted_units_data_0023>No Torpedo Bombers",
        tooltip = "restricted_units_air_torpedobombers",
    },
	
    AIRGUNSHIPS = {
		categories = {"GROUNDATTACK"},
		name = "<LOC restricted_units_data_0024>No Air Gunships",
		tooltip = "restricted_units_air_gunships",
    },
    
    AIRTRANSPORTS = {
		categories = {"TRANSPORTFOCUS"},
		name = "<LOC restricted_units_data_0025>No Air Transports",
		tooltip = "restricted_units_air_transports",
    },

    AIREXPERIMENTALS = {
		categories = {"bea0402", "bea0403", "bra0409", "lea0401", "saa0306", "sea0401", "uaa0310", "ura0401", "wra0401", "xsa0402"},
		name = "<LOC restricted_units_data_0026>No Air Experimentals",
		tooltip = "restricted_units_air_experimentals",
    },
	
	TACTICALMISSILELAUNCHERS = {
		categories = {"bab2308", "uab2108", "ueb2108", "urb2108", "xsb2108"},
		name = "<LOC restricted_units_data_0027>No TMLs",
		tooltip = "restricted_units_tml",
	},
	
    TACTICALARTILLERY = {
		categories = {"lab2320", "leb2320", "lrb2320", "lsb2320"},
		name = "<LOC restricted_units_data_0028>No T3 Barrage Artillery",
		tooltip = "restricted_units_T3_tactical_artillery",
	},

    STRATEGICARTILLERY = {
        categories = {"uab2302", "ueb2302", "urb2302", "xsb2302"},
        name = "<LOC restricted_units_data_0029>No T3 Strategic Artillery",
        tooltip = "restricted_units_T3_strategic_artillery",
    },
	
	EXPERIMENTALARTILLERY = {
		categories = {"seb2404", "ssb2404", "ueb2401", "url0401", "xab2307"},
		name = "<LOC restricted_units_data_0030>No Experimental/T4 Artillery",
		tooltip = "restricted_units_exp_artillery",
	},

    NUKE = {
        categories = {"sal0321", "sel0321", "srl0321", "ssl0321", "uab2305", "uab4302", "ueb2305", "ueb4302", "urb2305", "urb4302", "xsb2305", "xsb2401", "xsb4302", "uas0304", "urs0304"},
        name = "<LOC restricted_units_data_0011>No Nukes",
        tooltip = "restricted_units_nukes",
    },
	
	SHIELDS = {
        categories = {"sab4401", "seb4303", "seb4401", "srb4401", "ssb4401", "uab4202", "uab4301", "uabssg01", "ual0307", "ual0308", "ualx401", "ueb4202", "ueb4301", "uebssg01", "uel0307", "uel0308", "urb4202", "urb4207", "urbssg01", "wrl0207", "xes0205", "xsb4202", "xsb4301", "xsbssg01", "xsl0307"},
        name = "<LOC restricted_units_data_0013>No Dedicated Shield Generators",
        tooltip = "restricted_units_shields",
    },
    
    SUPPORTCOMMANDERS = {
        categories = {"SUBCOMMANDER"},
        name = "<LOC restricted_units_data_0015>No Support Commanders (SACUs)",
        tooltip = "restricted_units_sacu",
    },
	
    INTEL = {
        categories = {"OMNI", "seb3303", "sel0324", "ssb3301", "uab3101", "uab3102", "uab3201", "uab3202", "uas0305", "ueb3101", "ueb3102", "ueb3201", "ueb3202", "ues0305", "urb3101", "urb3102", "urb3201", "urb3202", "urs0305", "xab3301", "xrb3301", "xsb3101", "xsb3102", "xsb3201", "xsb3202", "xss0305"},
        name = "<LOC restricted_units_data_0014>No Intel Structures",
        tooltip = "restricted_units_intel",
    },

    FABS = {
        categories = {"MASSFABRICATION"},
        name = "<LOC restricted_units_data_0019>No Mass Fabrication",
        tooltip = "restricted_units_massfab",
    },

    ALTAIR = {
        categories = {"baa0309", "bra0309", "brpat3gunship", "bsa0309", "bsa0310","saa0313", "saa0314", "sea0310", "sea0313", "sea0314", "sra0306", "sra0313", "sra0314", "sra0315", "ssa0305", "ssa0306", "ssa0313", "ssa0314", "uaa0304", "uea0304", "uea0305", "ura0304", "xaa0305", "xea0306", "xra0305", "xsa0304"},
		name = "<LOC restricted_units_data_0031>T3 Alternative Air Production",
		tooltip = "restricted_units_altair",
    },

-- this is a bizarre and silly restriction as the game can't really function without them in any real sense --
--[[	
    NOENGINEERS = {
		categories = {"ual0105", "ual0208", "ual0309", "uel0105", "uel0208", "uel0309", "url0105", "url0208", "url0309", "xsl0105", "xsl0208", "xsl0309", "xel0209", },
		name = "No T1, T2, T3 Engineers",
		tooltip = "restricted_units_engineers",
    },
--]]
}

GPGsortOrder = {
    "T1",
    "T2",
    "T3",
    "EXPERIMENTAL",
    "NAVAL",
    "LAND",
    "AMPHIB",
    "HOVER",
	"AIRSCOUTS",
	"AIRFIGHTERS",
	"AIRBOMBERS",
    "AIRTORPEDOBOMBERS",
	"AIRGUNSHIPS",
	"AIRTRANSPORTS",
    "AIREXPERIMENTALS",	
	"TACTICALMISSILELAUNCHERS",
    "TACTICALARTILLERY",
    "STRATEGICARTILLERY",
    "EXPERIMENTALARTILLERY",
    "NUKE",
    "SHIELDS",
    "SUPPORTCOMMANDERS",
    "INTEL",
    "FABS",
    "ALTAIR",
}

GPGOptions = {}

versionstrings = {
	us = 'Version :',
	es = 'Versi\195\179n :',
	fr = 'Version :',
	it = 'Versione :',
	gr = 'Version :',
}