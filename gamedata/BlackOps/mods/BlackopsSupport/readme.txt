Blackops Global Icon Support Mod
v2.0

This mod is a global script that scans the /mods/ folder based on what the active mods are. For each detected active mod it tables each unitID & mod path. From there whenever the game fails to detect an icon it does a check aginst the tabled data for a matching unitID and then sets the icon based on the mods location.

The catch is even though it can map to the /mods/modname/ folder it still uses the games default folder structure after that which means the mod developers will need to make sure their icons are located in the correct place for this file to recognize them.

Proper Icon Locations are:
/mods/modname/textures/ui/common/icons/units/
/mods/modname/textures/ui/common/game/aeon-enhancements
/mods/modname/textures/ui/common/game/cybran-enhancements
/mods/modname/textures/ui/common/game/seraphim-enhancements
/mods/modname/textures/ui/common/game/uef-enhancements

Icons Currently Supported:
-Construction Icons (Icons shown in Factory/Build menus)
-Unit Select Icons (General icon shown when single or multiple units selected)
-Hover Over Unit Icons (Icon showed in unit detail popup)
-Targetting Icon (Icon shown on mousover to see what a unit is shooting at)
-Avatar Icons (Commander's Idle Icon)
-Commander Upgrades (Icons shown for commander upgrades)
-Control Group (ctrl+#) Icons

MOD REQUIREMENTS FOR FUNCTIONAILITY
1) Icons in the proper folders as listed above.
2) unitIDs for custom units MUST be only 7 characters long and end with _unit.bp or the script will ignore them. (So format #######_unit.bp)
3) Recommended removal of any previous icon code used by mod such as Goom's Build Icons. This is just to prevent possible issues with pointing to the right folder structure.

COMPATABILITY:
So far I have had a chance to run only limited tests with the mods I tend to use the most. By design this mod should not interfear with the icon systems used by other mods with the exception of possibly overwritting their changes and causing those mods to loose their icons. It depends on how they are programmed.

Notes: Yes htis originally started as trying to make better icon support for Blackops projects until DeadMG rewrote my original script to be soo much better.

-----===== Credits =====-----
Exavier Macbeth
Initial Code, Debugging, & Tweaking

DeadMG
Core Functions & Basic Hooking