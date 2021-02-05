name        = "Supreme Score Board v1.24"
version     = 1.24
uid         = "HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1240"
author      = "HUSSAR"
copyright   = "HUSSAR"
description = "Improves score board and replays. Made by HUSSAR, edited by Tanksy for LOUD."
icon        = "/mods/SupremeScoreBoard/mod_icon.png"
url         = "http://forums.faforever.com/viewtopic.php?f=41&t=10887"
selectable  = true
enabled     = true
ui_only     = true
exclusive   = false
requiresNames = { }
requires    = { }
-- this mod will conflict with all mods that modify score.lua file:
conflicts   = { 
    "9B5F858A-163C-4AF1-B846-A884572E61A5",
    "b0059a8c-d9ab-4c30-adcc-31c16580b59d",
    "c31fafc0-8199-11dd-ad8b-0866200c9a68",
    "b2cde810-15d0-4bfa-af66-ec2d6ecd561b",
    "ecbf6277-24e3-437a-b968-EcoManager-v4",
    "ecbf6277-24e3-437a-b968-EcoManager-v6",
    "ecbf6277-24e3-437a-b968-EcoManager-v5",
    "ecbf6277-24e3-437a-b968-EcoManager-v7",
    "0faf3333-1122-633s-ya-VX0000001000",
    --"89BF1572-9EA8-11DC-1313-635F56D89591",
    "f8d8c95a-71e7-4978-921e-8765beb328e8",
    "HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1100",
	"HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1210",
    "HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1220",
    "HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1230",
    }
before = { }
after = { }

--[[ TODO
 add configuration window for hiding columns, changing font size, background opacity etc.
 add ping info about players (lua/modules/ui/game/connectivity.lua)
 show acu kills and mvp kill ratio  
 group players colors before selecting team color to avoid green team color if two green players are in two teams
--]]