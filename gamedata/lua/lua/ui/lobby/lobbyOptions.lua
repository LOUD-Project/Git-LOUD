--*****************************************************************************
--* File: lua/modules/ui/lobby/lobbyOptions.lua
--* Summary: Lobby options
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

-- options that show up in the team options panel
teamOptions =
{
    {
        default = 1,
        label = "<LOC lobui_0310>Prebuilt Units",
        help = "<LOC lobui_0311>Set whether the game starts with prebuilt units or not",
        key = 'PrebuiltUnits',
        pref = 'Lobby_Prebuilt_Units',
        values = {
            {
                text = "<LOC lobui_0312>Off",
                help = "<LOC lobui_0313>No prebuilt units",
                key = 'Off',
            },
            {
                text = "<LOC lobui_0314>On",
                help = "<LOC lobui_0315>Prebuilt units set",
                key = 'On',
            },
        },
    },
    {
        default = 1,
        label = "<LOC lobui_0088>Spawn",
        help = "<LOC lobui_0089>Determine what positions players spawn on the map",
        key = 'TeamSpawn',
        pref = 'Lobby_Team_Spawn',
        values = {
            {
                text = "<LOC lobui_0090>Random",
                help = "<LOC lobui_0091>Spawn everyone in random locations",
                key = 'random',
            },
            {
                text = "<LOC lobui_0092>Fixed",
                help = "<LOC lobui_0093>Spawn everyone in fixed locations (determined by slot)",
                key = 'fixed',
            },
        },
    },
    {
        default = 1,
        label = "<LOC lobui_0096>Team",
        help = "<LOC lobui_0097>Determines if players may switch teams while in game",
        key = 'TeamLock',
        pref = 'Lobby_Team_Lock',
        values = {
            {
                text = "<LOC lobui_0098>Locked",
                help = "<LOC lobui_0099>Teams are locked once play begins",
                key = 'locked',
            },
            {
                text = "<LOC lobui_0100>Unlocked",
                help = "<LOC lobui_0101>Players may switch teams during play",
                key = 'unlocked',
            },
        },
    },
	{
		default = 1,
		label = "Unused Start Resources",
		help = "Remove Resources near unused Start Positions",
		key = 'UnusedResources',
		pref = 'Lobby_UnusedResources',
		values = {
			{
				text = "Keep All",
				help = "All resources are kept",
				key = '1',
			},
			{
				text = "Keep 50%",
				help = "50% chance that unused resources are kept",
				key = '2',
			},
			{
				text = "Keep 33%",
				help = "33% chance that unused resources are kept",
				key = '3',
			},
			{
				text = "Keep 25%",
				help = "25% chance that unused resources are kept",
				key = '4',
			},
			{
				text = "Keep 20%",
				help = "20% chance that unused resources are kept",
				key = '5',
			},
			{
				text = "Keep 10%",
				help = "10% chance that unused resources are kept",
				key = '10',
			},
			{
				text = "Remove All",
				help = "No start location resources will be kept",
				key = '100',
			},
		},
	},
}

globalOpts = {
	{   default = 4,
        label = "AIx Cheat Multiplier",
        help = "Set the resource multiplier for the cheating AIs.",
        key = 'CheatMult',
        pref = 'Lobby_Cheat_Mult',
        values = {
            {
                text = "0.9",
                help = "Resources -10% - slow",
                key = '0.9',
            },			
            {
                text = "1.0",
                help = "Standard Resources",
                key = '1.0',
            },
            {
                text = "1.05",
                help = "AIx Resources +5%",
                key = '1.05',
            },
            {
                text = "1.075",
                help = "AIx Resources +7.5%",
                key = '1.075',
            },
            {
                text = "1.10",
                help = "AIx Resources +10%",
                key = '1.1',
            },
            {
                text = "1.125",
                help = "AIx Resources +12.5%",
                key = '1.125',
            },			
            {
                text = "1.150",
                help = "AIx Resources +15%",
                key = '1.15',
            },
            {
                text = "1.175",
                help = "AIx Resources +17.5%",
                key = '1.175',
            },			
            {
                text = "1.200",
                help = "AIx Resources +20%",
                key = '1.2',
            },
            {
                text = "1.225",
                help = "AIx Resources +22.5%",
                key = '1.225',
            },			
            {   text = "1.250",
                help = "AIx Resources +25%",
                key = '1.25',
            },
            {
                text = "1.300",
                help = "AIx Resources +30%",
                key = '1.3',
            },
            {
                text = "1.35",
                help = "AIx Resources +35%",
                key = '1.35',
            },
            {
                text = "1.40",
                help = "AIx Resources +40%",
                key = '1.4',
            },
            {
                text = "1.50",
                help = "AIx Resources +50%",
                key = '1.5',
            },
            {
                text = "1.75",
                help = "AIx Resources +75%",
                key = '1.75',
            },
            {
                text = "2.00",
                help = "AIx Resources +100%",
                key = '2.0',
            },

        },
	},
	{   default = 4,
        label = "AIx Build Multiplier",
        help = "Set the build rate multiplier for the cheating AIs.",
        key = 'BuildMult',
        pref = 'Lobby_Build_Mult',
        values = {
            {
                text = "0.9",
                help = "AIx Build Rate -10%",
                key = '0.9',
            },
            {
                text = "1.0",
                help = "AIx Build Rate Normal",
                key = '1.0',
            },
            {
                text = "1.050",
                help = "AIx Build Rate +5%",
                key = '1.05',
            },
            {
                text = "1.075",
                help = "AIx Build Rate +7.5%",
                key = '1.075',
            },
            {
                text = "1.10",
                help = "AIx Build Rate +10%",
                key = '1.1',
            },
            {
                text = "1.125",
                help = "AIx Build Rate +12.5%",
                key = '1.125',
            },
            {
                text = "1.150",
                help = "AIx Build Rate +15%",
                key = '1.15',
            },
            {
                text = "1.175",
                help = "AIx Build Rate +17.5%",
                key = '1.175',
            },			
            {
                text = "1.200",
                help = "AIx Build Rate +20%",
                key = '1.2',
            },
            {
                text = "1.225",
                help = "AIx Build Rate +22.5%",
                key = '1.225',
            },			
            {
                text = "1.250",
                help = "AIx Build Rate +25%",
                key = '1.25',
            },
            {
                text = "1.30",
                help = "AIx Build Rate +30%",
                key = '1.3',
            },
            {
                text = "1.35",
                help = "AIx Build Rate +35%",
                key = '1.35',
            },			
            {
                text = "1.40",
                help = "AIx Build Rate +40%",
                key = '1.4',
            },
            {
                text = "1.50",
                help = "AIx Build Rate +50%",
                key = '1.5',
            },
            {
                text = "1.75",
                help = "AIx Build Rate +75%",
                key = '1.75',
            },
            {
                text = "2.00",
                help = "AIx Build Rate +100%",
                key = '2.0',
            },
        },
	},

    {
        default = 12,
        label = "Unit Cap",
        help = "Set the maximum number of units that can be in play by one player",
        key = 'UnitCap',
        pref = 'Lobby_Gen_Cap',
        values = {
            {
                text = "250",
                help = "250 units per player may be in play",
                key = '250',
            },
            {
                text = "300",
                help = "300 units per player may be in play",
                key = '300',
            },
            {
                text = "350",
                help = "350 units per player may be in play",
                key = '350',
            },			
            {
                text = "400",
                help = "400 units per player may be in play",
                key = '400',
            },
            {
                text = "450",
                help = "450 units per player may be in play",
                key = '450',
            },			
            {
                text = "500",
                help = "500 units per player may be in play",
                key = '500',
            },
            {
                text = "550",
                help = "550 units per player may be in play",
                key = '550',
            },
            {
                text = "600",
                help = "600 units per player may be in play",
                key = '600',
            },			
            {
                text = "650",
                help = "650 units per player may be in play",
                key = '650',
            },
            {
                text = "700",
                help = "700 units per player may be in play",
                key = '700',
            },			
            {
                text = "750",
                help = "750 units per player may be in play",
                key = '750',
            },
            {
                text = "800",
                help = "800 units per player may be in play",
                key = '800',
            },			
            {
                text = "875",
                help = "875 units per player may be in play",
                key = '875',
            },
            {
                text = "1000",
                help = "1000 units per player may be in play",
                key = '1000',
            },
            {
                text = "1250",
                help = "1250 units per player may be in play",
                key = '1250',
            },
            {
                text = "1500",
                help = "1500 units per player may be in play",
                key = '1500',
            },
			{
				text = "2000",
				help = "2000 units per player may be in play",
				key = '2000',
			},
			{
				text = "4000",
				help = "4000 units per player may be in play",
				key = '4000',
			},			
        },
    },
	{   default = 2,
        label = "Unit Cap AI",
        help = "Set the Unit Cap limit for cheating AIs.",
        key = 'CapCheat',
        pref = 'Lobby_Cap_Cheat',
        values = {
            {
                text = "Unlimited",
                help = "AI ignores unit cap",
                key = 'unlimited',
            },
			{
				text = "Enhanced",
				help = "AI Unit Cap tied to Resource Cheat level",
				key = 'cheatlevel',
			},
            {
                text = "Off",
                help = "AI has same unit cap as humans",
                key = 'off',
            },
        },
	},

    {
        default = 1,
        label = "<LOC lobui_0208>Cheating",
        help = "<LOC lobui_0209>Enable cheat codes",
        key = 'CheatsEnabled',
        pref = 'Lobby_Gen_CheatsEnabled',
        values = {
            {
                text = "<LOC _Off>Off",
                help = "<LOC lobui_0210>Cheats disabled",
                key = 'false',
            },
            {
                text = "<LOC _On>On",
                help = "<LOC lobui_0211>Cheats enabled",
                key = 'true',
            },
        },
    },
    {
        default = 1,
        label = "<LOC lobui_0291>Civilians",
        help = "<LOC lobui_0292>Set how civilian units are used",
        key = 'CivilianAlliance',
        pref = 'Lobby_Gen_Civilians',
        values = {
            {
                text = "<LOC lobui_0293>Enemy",
                help = "<LOC lobui_0294>Civilians are enemies of players",
                key = 'enemy',
            },
            {
                text = "<LOC lobui_0295>Neutral",
                help = "<LOC lobui_0296>Civilians are neutral to players",
                key = 'neutral',
            },
            {
                text = "<LOC lobui_0297>None",
                help = "<LOC lobui_0298>No Civilians on the battlefield",
                key = 'removed',
            },
        },
    },
    {
        default = 1,
        label = "<LOC lobui_0112>Fog of War",
        help = "<LOC lobui_0113>Set up how fog of war will be visualized",
        key = 'FogOfWar',
        pref = 'Lobby_Gen_Fog',
        values = {
            {
                text = "<LOC lobui_0114>Explored",
                help = "<LOC lobui_0115>Terrain revealed, but units still need recon data",
                key = 'explored',
            },
            {
                text = "<LOC lobui_0118>None",
                help = "<LOC lobui_0119>All terrain and units visible",
                key = 'none',
            },
        },
    },
    {
        default = 1,
        label = "<LOC lobui_0258>Game Speed",
        help = "<LOC lobui_0259>Set the game speed",
        key = 'GameSpeed',
        pref = 'Lobby_Gen_GameSpeed',
        values = {
            {
                text = "<LOC lobui_0260>Normal",
                help = "<LOC lobui_0261>Fixed at the normal game speed (+0)",
                key = 'normal',
            },
            {
                text = "<LOC lobui_0262>Fast",
                help = "<LOC lobui_0263>Fixed at a fast game speed (+4)",
                key = 'fast',
            },
            {
                text = "<LOC lobui_0264>Adjustable",
                help = "<LOC lobui_0265>Adjustable in-game",
                key = 'adjustable',
            },
        },
    },
    {
        default = 1,
        label = "<LOC lobui_0316>No Rush Option",
        help = "<LOC lobui_0317>Enforce No Rush rules for a certain period of time",
        key = 'NoRushOption',
        pref = 'Lobby_NoRushOption',
        values = {
            {
                text = "<LOC lobui_0318>Off",
                help = "<LOC lobui_0319>Rules not enforced",
                key = 'Off',
            },
            {
                text = "<LOC lobui_0320>5",
                help = "<LOC lobui_0321>Rules enforced for 5 mins",
                key = '5',
            },
            {
                text = "<LOC lobui_0322>10",
                help = "<LOC lobui_0323>Rules enforced for 10 mins",
                key = '10',
            },
            {
                text = "<LOC lobui_0324>20",
                help = "<LOC lobui_0325>Rules enforced for 20 mins",
                key = '20',
            },
        },
    },
    {
        default = 1,
        label = "PreBuilt Missile Option",
        help = "Options for Missiles (TAC, Nukes & AntiNukes)",
        key = 'MissileOption',
        pref = 'Lobby_MissileOption',
        values = {
            {
                text = "Zero",
                help = "All Counted Missile systems have 0 prebuilt missiles.",
                key = '0',
            },
            {
                text = "1",
                help = "All Counted Missile systems have 1 prebuilt missile.",
                key = '1',
            },
            {
                text = "2",
                help = "All Counted Missile systems have 2 prebuilt missiles.",
                key = '2',
            },
        },
    },
    {
        default = 2,
        label = "<LOC lobui_0242>Timeouts",
        help = "<LOC lobui_0243>Sets the number of timeouts each player can request",
        key = 'Timeouts',
        pref = 'Lobby_Gen_Timeouts',
        mponly = true,
        values = {
            {
                text = "<LOC lobui_0244>None",
                help = "<LOC lobui_0245>No timeouts are allowed",
                key = '0',
            },
            {
                text = "<LOC lobui_0246>Three",
                help = "<LOC lobui_0247>Each player has three timeouts",
                key = '3',
            },
            {
                text = "<LOC lobui_0248>Infinite",
                help = "<LOC lobui_0249>There is no limit on timeouts",
                key = '-1',
            },
        },
    },

    {
        default = 2,
        label = "<LOC lobui_0120>Victory Condition",
        help = "<LOC lobui_0121>Determines how a victory can be achieved",
        key = 'Victory',
        pref = 'Lobby_Gen_Victory',
        values = {
			{	
				text = "Advanced Assassination",
				help = "Game ends when Commander and all SubCommanders are destroyed",
				key = 'decapitation',
			},
            {
                text = "<LOC lobui_0122>Assassination",
                help = "Game ends when the Commander is destroyed",
                key = 'demoralization',
            },
            {
                text = "<LOC lobui_0124>Supremacy",
                help = "<LOC lobui_0125>Game ends when all structures, Commanders and engineers are destroyed",
                key = 'domination',
            },
            {
                text = "<LOC lobui_0126>Annihilation",
                help = "<LOC lobui_0127>Game ends when all units are destroyed",
                key = 'eradication',
            },
            {
                text = "<LOC lobui_0128>Sandbox",
                help = "<LOC lobui_0129>Game never ends - you must end game manually",
                key = 'sandbox',
            },
        },
    },
    {
        default = 1,
        label = "Victory Time Limit Setting",
        help = "How long a game will continue",
        key = 'TimeLimitSetting',
        pref = 'Lobby_Gen_TimeLimitSetting',
        values = {
			{
				text = "No Time Limit",
				help = "Game has no specific time limit - use only Victory Condition",
				key = '0',
			},
			{	
				text = "90 Minutes (1.5 Hours)",
				help = "Game ends at 1.5 Hours or when Commander and all SubCommanders are destroyed",
				key = '90',
			},
			{	
				text = "120 Minutes (2 Hours)",
				help = "Game ends at 2 Hours or when Commander and all SubCommanders are destroyed",
				key = '120',
			},
			{	
				text = "150 Minutes (2.5 Hours)",
				help = "Game ends at 2.5 Hours or when Commander and all SubCommanders are destroyed",
				key = '150',
			},
			{	
				text = "180 Minutes (3 Hours)",
				help = "Game ends at 3 Hours or when Commander and all SubCommanders are destroyed",
				key = '180',
			},
			{	
				text = "210 Minutes (3.5 Hours)",
				help = "Game ends at 3.5 Hours or when Commander and all SubCommanders are destroyed",
				key = '210',
			},
			{	
				text = "240 Minutes (4 Hours)",
				help = "Game ends at 4 Hours or when Commander and all SubCommanders are destroyed",
				key = '240',
			},
        },
    },		

}
