--[[
Contains the mapping of restriction types to restriction data in the following format:

type = {
    categories = {"cat1", "cat2", etc...},
    name = "name to display in list",
    tooltip = tooltipID,
}
--]]

restrictedUnits = {
	BOB = {
		categories = {"TECH1 +ENGINEER"},
		name = "No Tech 1 engineers",
		tooltip = "Bob",
	},
    T1 = {
        categories = {"TECH1 +MOBILE"},
        name = "<LOC restricted_units_data_0000>No Tech 1 mobile units",
        tooltip = "restricted_units_T1",
    },
    T2 = {
        categories = {"TECH2 +MOBILE"},
        name = "<LOC restricted_units_data_0001>No Tech 2 mobile units",
        tooltip = "restricted_units_T2",
    },
    T3 = {
        categories = {"TECH3 +MOBILE"},
        name = "<LOC restricted_units_data_0002>No Tech 3 mobile units",
        tooltip = "restricted_units_T3",
    },
    EXPERIMENTAL = {
        categories = {"EXPERIMENTAL"},
        name = "<LOC restricted_units_data_0003>No Experimental units",
        tooltip = "restricted_units_experimental",
    },
    NAVAL = {
        categories = {"NAVAL +MOBILE"},
        name = "<LOC restricted_units_data_0004>No Naval mobile units",
        tooltip = "restricted_units_naval",
    },
    LAND = {
        categories = {"LAND +MOBILE"},
        name = "<LOC restricted_units_data_0005>No Land mobile units",
        tooltip = "restricted_units_land",
    },
    AIR = {
        categories = {"AIR +MOBILE"},
        name = "<LOC restricted_units_data_0006>No Air mobile units",
        tooltip = "restricted_units_air",
    },
    UEF = {
        categories = {"UEF"},
        name = "<LOC restricted_units_data_0007>No UEF",
        tooltip = "restricted_units_uef",
    },
    CYBRAN = {
        categories = {"CYBRAN"},
        name = "<LOC restricted_units_data_0008>No Cybran",
        tooltip = "restricted_units_cybran",
    },
    AEON = {
        categories = {"AEON"},
        name = "<LOC restricted_units_data_0009>No Aeon",
        tooltip = "restricted_units_aeon",
    },
    SERAPHIM = {
        categories = {"SERAPHIM"},
        name = "<LOC restricted_units_data_0010>No Seraphim",
        tooltip = "restricted_units_seraphim",
    },
    NUKE = {
        categories = {"uab2305", "ueb2305", "urb2305", "xsb2305", "xsb2401", "xss0302", "xsb4302", "ueb4302", "urb4302", "uab4302", "uas0304", "urs0304", "ues0304" },
        name = "<LOC restricted_units_data_0011>No Nukes",
        tooltip = "restricted_units_nukes",
    },
    GAMEENDERS = {
        categories = {"uab2302", "urb2302", "ueb2302", "xsb2302", "xab1401", "xab2307", "url0401", "xeb2402", "ueb2401", "xsb2401"},
        name = "<LOC restricted_units_data_0012>No Game Enders",
        tooltip = "restricted_units_gameenders",
    },
    BUBBLES = {
        categories = {"uel0307", "ual0307", "xsl0307", "deb4303", "xes0205", "ueb4202", "urb4202", "uab4202", "xsb4202", "ueb4301", "uab4301", "xsb4301", },
        name = "<LOC restricted_units_data_0013>No Bubbles",
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
        categories = {"xab1401", "ueb1104", "ueb1303", "urb1104", "urb1303", "uab1104", "uab1303", "xsb1104", "xsb1303", },
        name = "<LOC restricted_units_data_0019>No Mass Fabrication",
        tooltip = "restricted_units_massfab",
    },
}

sortOrder = {
	"BOB",
    "GAMEENDERS",
    "NUKE",
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
    "AIR",
    "BUBBLES",
    "INTEL",
    "SUPCOM",
    "FABS",
}