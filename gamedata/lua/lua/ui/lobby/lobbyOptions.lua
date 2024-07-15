--*****************************************************************************
--* File: lua/modules/ui/lobby/lobbyOptions.lua
--* Summary: Lobby options
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

teamOptions = {

    {
        default = 2,
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
        label = "Evenly Distributed Random Factions",
        help = 'Promote a more even spread of factions among players which choose to receive theirs randomly.',
        key = 'EvenFactions',
        pref = 'Lobby_Even_Factions',
        values = {
            {
                text = "<LOC lobui_0312>Off",
                help = "No manipulation of randomness during random faction selection.",
                key = 'off',
            },
            {
                text = "<LOC lobui_0314>On",
                help = "Faction randomization will be more evenly spread.",
                key = 'on',
            },
        },
    },

}

globalOpts = {

    {
        default = 3,
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
        default = '800',
        label = "Unit Cap",
        help = "Set the maximum number of units that can be in play by one player",
        key = 'UnitCap',
        pref = 'Lobby_Gen_Cap',
        type = 'edit',
        valid = '^%d+$',
    },

    {
        default = 1,
        label = "User Spawn/Cheat Menu",
        help = "Enable spawn/cheat menu",
        key = 'CheatsEnabled',
        pref = 'Lobby_Gen_CheatsEnabled',
        values = {
            {
                text = "<LOC _Off>Off",
                help = "<LOC lobui_0210>Spawn/Cheat Menu disabled",
                key = 'false',
            },
            {
                text = "<LOC _On>On",
                help = "<LOC lobui_0211>Spawn/Cheats Menu enabled",
                key = 'true',
            },
        },
    },

    {
        default = 2,
        label = "User Timeouts",
        help = "The number of timeouts each player can request",
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
        default = 1,
        label = "<LOC lobui_0120>Victory Condition",
        help = "<LOC lobui_0121>Determines how a victory can be achieved",
        key = 'Victory',
        pref = 'Lobby_Gen_Victory',
        values = {
			{
				text = "<LOC lobui_0130>Advanced Assassination",
				help = "<LOC lobui_0131>A player is defeated when the Commander and all Support Commanders are destroyed.",
				key = 'decapitation',
			},
            {
                text = "<LOC lobui_0124>Supremacy",
                help = "<LOC lobui_0125>A player is defeated when all engineers, factories and any unit that can build an engineer are destroyed.",
                key = 'domination',
            },
            {
                text = "<LOC lobui_0126>Annihilation",
                help = "<LOC lobui_0127>A player is defeated when all structures (except walls) and all units are destroyed.",
                key = 'eradication',
            },
            {
                text = "<LOC lobui_0128>Sandbox",
                help = "<LOC lobui_0129>No player can ever be defeated.",
                key = 'sandbox',
            },
            {
                text = "<LOC lobui_0122>Assassination",
                help = "<LOC lobui_0123>A player is defeated when the Commander is destroyed.",
                key = 'demoralization',
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

advGameOptions = {

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
        default = 1,
        label = "Relocate Starting Resources",
        help = "Initial mass & hydrocarbon points are relocated to suit AI needs.",
        key = 'RelocateResources',
        pref = 'Lobby_RelocateResources',
        values = {
            {
                text = 'On',
                help = "Mass and hydrocarbon points at ALL starting positions are relocated.",
                key = 'on',
            },
            {
                text = 'Off',
                help = "Mass and hydrocarbon points at HUMAN starting positions are NOT relocated.",
                key = 'off',
            },
        }
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

advAIOptions = {

    {
        default = '30',
        label = "ACT Feedback Cheat Interval",
        help = "If an AI is affected by ACT Feedback, this is the time period in seconds between possible changes to its cheat multiplier. Increase for better performance.",
        key = "ACTRatioInterval",
        pref = 'Lobby_ACT_Ratio_Interval',
        type = 'edit',
        valid = '^%d+$',
    },

    {
        default = '1',
        label = "ACT Feedback Cheat Scale",
        help = "If an AI is affected by ACT Feedback, this is the scale which affects the multiplier increase. At 1, the cheat will increase by a max of 0.5.",
        key = "ACTRatioScale",
        pref = 'Lobby_ACT_Ratio_Scale',
        type = 'edit',
        valid = {
            '^%d+$',
            '^%d+%.%d+$',
        },
    },

    {
        default = '5',
        label = "ACT Timed Cheat Start Delay",
        help = "If an AI is affected by ACT Timed cheats, this is the delay in minutes before any changes start happening.",
        key = "ACTStartDelay",
        pref = 'Lobby_ACT_Start_Delay',
        type = 'edit',
        valid = '^%d+$',
    },

    {
        default = '5',
        label = "ACT Timed Cheat Delay",
        help = "If an AI is affected by ACT Timed cheats, this is the delay in minutes between each cheat rate adjustment.",
        key = "ACTTimeDelay",
        pref = 'Lobby_ACT_Time_Delay',
        type = 'edit',
        valid = '^%d+$',
    },

    {
        default = '0.02',
        label = "ACT Timed Cheat Amount",
        help = "If an AI is affected by ACT Timed cheats, this is how much the cheat will change at each interval. Can be negative.",
        key = "ACTTimeAmount",
        pref = 'Lobby_ACT_Time_Amount',
        type = 'edit',
        valid = {
            '^%d+$',
            '^%d+%.%d+$',
            '^%-%d+$',
            '^%-%d+%.%d+$',
        },
    },

    {
        default = '2',
        label = "ACT Timed Cheat Limit",
        help = "If an AI is affected by ACT Timed cheats, the cheat multiplier cannot exceed this value.",
        key = "ACTTimeCap",
        pref = 'Lobby_ACT_Time_Cap',
        type = 'edit',
        valid = {
            '^%d+$',
            '^%d+%.%d+$',
        },

    },

    {
        default = 1,
        label = "AI Shares Resources",
        help = "Set if AI players share resources with their allies.",
        key = 'AIResourceSharing',
        pref = 'Lobby_AI_Resource_Sharing',
        values = {
            {
                text = "On",
                help = "AI players will always share resources with their allies.",
                key = 'on',
            },
            {
                text = "With AI Only",
                help = "AI players will share resources with allies, but only if all of their allies are also AI.",
                key = 'aiOnly',
            },
            {
                text = "Off",
                help = "AI players will never share resources with their allies.",
                key = 'off',
            },
        },
    },

    {   default = 2,
        label = "AI Unit Cap",
        help = "Set the Unit Cap limit for the AIs.",
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
                help = "AI Unit Cap modified by cheat setting",
                key = 'cheatlevel',
            },
            {
                text = "Normal",
                help = "AI has same unit cap as humans",
                key = 'off',
            },
        },
    },

    {
        default = 1,
        label = "AI Uses Faction Color",
        help = "Set whether AI players get assigned the color of their faction after the game starts.",
        key = 'AIFactionColor',
        pref = 'Lobby_AI_Faction_Color',
        values = {
            {
                text = "Off",
                help = "AI players will use the colors assigned to them in the lobby.",
                key = 'off',
            },
            {
                text = "On",
                help = "AI players will get assigned their faction's colour after the game starts.",
                key = 'on',
            },
        },

    },

}
