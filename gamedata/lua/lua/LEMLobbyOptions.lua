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
        categories = {"uaa0101","uaa0302","uea0101","uea0302","ura0101","ura0302","xsa0101","xsa0302","sea0201","sra0201","ssa0201","saa0201" },
        name = "No Air Scouts",
        tooltip = "restricted_units_air_scouts",
    },

    AIRFIGHTERS = {
		categories = {"brpat2figbo","uaa0102","uea0102","ura0102","xsa0102","xaa0202","dea0202","dra0202","xsa0202","uaa0303","uea0303","ura0303","xsa0303","sra0313","sea0313","ssa0313"},
		name = "No Air Fighters",
		tooltip = "restricted_units_air_fighters",
    },
	
    AIRBOMBERS = {
		categories = {"BOMBER"},
		name = "No Bombers",
		tooltip = "restricted_units_air_bombers",
    },
	
    AIRGUNSHIPS = {
		categories = {"GROUNDATTACK"},
		name = "No Air Gunships",
		tooltip = "restricted_units_air_gunships",
    },
    
    AIRTORPEDOBOMBERS = {
        categories = {"TORPEDOBOMBER"},
        name = "No Torpedo Bombers",
        tooltip = "restricted_units_air_torpedobombers",
    },
	
    AIRTRANSPORTS = {
		categories = {"TRANSPORTFOCUS"},
		name = "No Air Transports",
		tooltip = "restricted_units_air_transports",
    },

    AIREXPERIMENTALS = {
		categories = {"bea0402", "bea0403", "ura0401", "xsa0402", "bra0409", "lea0401", "uaa0310","saa0306","wra0401","sea0401"},
		name = "No Air Experimentals",
		tooltip = "restricted_units_air_experimentals",
    },
	
	TACTICALMISSILELAUNCHERS = {
		categories = { 'uab2108', 'ueb2108', 'urb2108', 'xsb2108', 'bab2308', },
		name = "No Tactical Missile structures",
		tooltip = "restricted_units_tactical",
	},
	
    NUKE = {
        categories = {"uab2305", "ueb2305", "urb2305", "xsb2305", "xsb2401", "uas0304", "ues0304", "urs0304", "xss0302", "uab4302", "ueb4302", "urb4302", "xsb4302", "sal0321", "sel0321", "srl0321", "ssl0321" },
        name = "<LOC restricted_units_data_0011>No Nukes, Anti-nukes or Nuke submarines",
        tooltip = "restricted_units_nukes",
    },
	
	TACTICALARTILLERY = {
		categories = { "lab2320", "leb2320", "lrb2320", "lsb2320" },
		name = "No T3 Barrage Artillery",
		tooltip = "restricted_units_T3_Tactical_artillery",
	},

    STRATEGICARTILLERY = {
        categories = { "uab2302","ueb2302","urb2302","xsb2302" },
        name = "No T3 Strategic Artillery",
        tooltip = "restricted_units_T3_Strategic_artillery",
    },
	
	EXPERIMENTALARTILLERY = {
		categories = { "xab2307", "ueb2401", "url0401", "seb2404", "ssb2404" },
		name = "No Experimental Artillery",
		tooltip = "restricted_units_exp_artillery",
	},

    SHIELDS = {
        categories = {"uel0307", "ual0307", "xsl0307", "xes0205", "ueb4202", "urb4202", "uab4202", "xsb4202", "ueb4301", "uab4301", "xsb4301","seb4401","ssb4401","ualx0401","uabssg01","uebssg01","urbssg01","xsbssg01" },
        name = "<LOC restricted_units_data_0013>No Shield Units",
        tooltip = "restricted_units_bubbles",
    },
    
    SUPPORTCOMMANDERS = {
        categories = {"ual0301","uel0301","url0301","xsl0301"},
        name = "No Support Commanders - SACU",
        tooltip = "restricted_units_supcom",
    },
	
    INTEL = {
        categories = {"OMNI", "uab3101", "uab3201", "ueb3101", "ueb3201", "urb3101", "urb3201", "xsb3101", "xsb3201", "uab3102", "uab3202", "ueb3102", "ueb3202", "urb3102", "urb3202", "xsb3102", "xsb3202", "xab3301", "xrb3301", "ues0305", "uas0305", "urs0305","seb3404" },
        name = "<LOC restricted_units_data_0014>No Intel Structures",
        tooltip = "restricted_units_intel",
    },

    FABS = {
        categories = {"ueb1104", "ueb1303", "urb1104", "urb1303", "uab1104", "uab1303", "xsb1104", "xsb1303", "xab1401","seb1401","srb1401","ssb1401" },
        name = "<LOC restricted_units_data_0019>No Mass Fabrication",
        tooltip = "restricted_units_massfab",
    },

    ALTAIR = {
		categories = {"baa0309","bra0309","bsa0309","saa0306","bsa0310","saa0314","sea0314","sra0306","sra0314","ssa0305","ssa0306","ssa0314","uaa0304","uea0304","uea0305","uea0305","ura0304","xaa0305","xea0306","xra0305","xsa0304","brpat3gunship","sea0310","sea0313","sea0314","saa0314","sra0313","sra0314","ssa0314" },
		name = "Alternative Air - T3 limited to Scouts, Fighters and Torpedo Bombers",
		tooltip = "T3_Scouts_fighters_and_T_Bombers_only",
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