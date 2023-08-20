***********************************************
| GAZ_UI Mod
***********************************************
(Formerly Goom's UI mod, aka "GUI")
 
Hi AdmiralZeech here, since Goom is currently not into SCFA anymore, 
I've gotten his permission to take over management of his UI mod.

Because the mod is so complex, I'll be documenting it gradually when I
get the time.  If you cant find something here, try the forum post:

http://forums.gaspowered.com/viewtopic.php?p=414706

---------------- 
|Overview - Options

The various components of GAZ_UI can be toggled on and off via the
menu Options/Interface.  In the various items marked "GUI:".

Here's a short explanation of each item, which gives an overview of
the features of GAZ_UI.

NOTE: There are some options that must be disabled to be compatible with
AngryZealot's AZUI mod.  Do a text search for AZUI in this document.


- GUI: Bigger Strategic Build Icons
Replaces the strategic icons in the build menu with larger images.
Has 3 settings: Off, Simple (larger icons only) and Full (larger icons
with Tech dots).

- GUI: Template Rotation
When placing a structure build template, you can press middle mouse
button to rotate the template.

- GUI: SCU Manager
Allows use of the SCU Manager.  This is a complex feature which I
never use and know nothing about :)

- GUI: Draggable Build Queue
You can drag and drop items in a factory's build queue.

- GUI: Middle Click Avatars
You can middle-click the avatar icons on the right side of the screen,
to select all units in that category.

- GUI: All Race Templates
When creating structure build templates, templates with common
structures like Power Generators will be applied to all factions.
This means you dont need to create the same template for every faction.

- GUI: Single Unit Selected Info
When you have only a single unit selected, that unit's mouse-over
information will be displayed.

- GUI: Single Unit Selected Rings
When you have only a single unit selected, that unit's range rings
will be turned on. (effectively, this options activates "Turn range
rings on selected units" if and only if you have a single unit
selected.)

- GUI: Zoom Pop Distance
This option sets the distance the Zoom Pop hotkey will zoom to.

- GUI: Seperate Idle Builders
When selecting engineers, factories and other builder units, idle
units will be collected into a seperate icon in the selection window.


Additions by norem:

- GUI: Factory Build Queue Templates
Allows creation of Factory Build Queue templates.
When a factory is selected, selecting the Templates tab will change
the "Infinite Build" button into a "Save Template" button.
Alternatively you can use the "Create Build Template (factory)"
hotkey.  All functionality in the Factory Build Template tab is the
same as Structure Build Templates. (you can rename, assign hotkey for
build mode, etc.)


Additions by ghaleon:

- GUI: Display Reclaim Window 
default is disabled.
Will display a small window close to the Economy Bar which details 
the total mass and energy you have reclaimed. 
Note:
It looks horrible, but this will do for now.
Note#2: when enabled will also display up to 8 digits of energy/mass production
as opposed to standard of 6 digits, ie "999999" when your true energy production
is "12574899".

- GUI: Display more Unit Stats
enabled by default
This is based upon Eni's Total Veterancy UI mod and also works in 
conjuction with it.
The unitview window will display hp regeneration rate, shield hp, 
shield regeneration rate and build rate of selected units.
Will now display hp regen rate changes due to upgrades and veterancy.
Commander-type units now also get shield hp displayed.
If a commander-type unit has gained a level up, hp regen rates in brackets 
denote total regen rate gained by veterancy, the other value displays regen rate 
gained by upgrades.
Currently I lack the facility to determine which of the two displayed regen rates 
is in effect, it always is the one which came into effect later.
(Regen rates gained by veterancy and those by upgrades do NOT stack, 
they overwrite each other depending on which came last)
Note:
It could also display storage, but unfortunately I haven't 
found a spot where it does not collide with e.g. the kills counter 
or nuke symbol or something else.
If you don't mind, the code is commented out in Unitview.lua 
and its layout dependencies.
DISABLE THIS FEATURE FOR AZUI COMPATIBILITY


- GUI: Visible Template Names
enabled by default
All template icons will have a small text below them, displaying the 
template name.
DISABLE THIS FEATURE FOR AZUI COMPATIBILITY

- GUI: Template Name Cutoff
The first 7 characters are displayed (default). 
Number of characters omitted can be customized. 
(Needs restart for effects to be visible.)

- GUI: Always Render Custom Names
Default is enabled, when disabled will disable display of custom names.
Unless kept at default this option will be applied at every gamestart.

- GUI: Force Render Enemy Lifebars
Default is disabled, when enabled will force display enemy lifebars.
Unless kept at default this option will be applied at every gamestart.

- GUI: Auto Rename Replays
Default is enabled. 
Auto renames the current Replay once you exit to the Score screen. 
will work for localized versions of fa, too.
Follows following naming scheme:
"year"."month"."day"-"hour"."minute" "mapname"
mapname will be shortened to 15 characters, examples:
090206-2243 Fields of Isis
090206-2257 Gentleman's Reef
other naming schmes may be supported in future revisions.

- GUI: Improved Unit deselection
Reduce the number of selected units by shift(-1) or ctrl(-5) or ctrl+shift(-10) 
right-click in group selection. Enabled by default



Additions by Thygrrr:

- GUI: Smart Economy Indicators

    * when mass stores above 80% and rising, income indicator begins 
      flashing bright white, if expenses are higher than income and usage 
      efficiency is above 80%, mass income indicator remains green, it's yellow
      till 50%, and red below that.
    * when energy stores below 20%, energy indicator begins flashing bright white,
      before that, if below 50% and sinking, it turns red from yellow, and is 
      green above 100%.
    * when zero expense, displays infinite instead of 100%
    * percentile "efficiency" display goes to more than 100%. it was bad and 
      wrong it was ever capped, because it's an important metric.
    * percentile values (not absolute values) are filtered, meaning they change 
      smoothly over time. This is expecially good when reclaiming stuff an 
      wondering about your overall efficiency.
    * edit: the old style economy warnings (glowing underlay) now coincide with 
      the new flashing effect.

(zeech: It's pretty confusing - I think the point is to keep your mass and
energy at about 100% efficiency, no higher or lower. 
You can switch between percentage and absolute +/- by clicking on the number 
in your mass/energy panel. 
Check the GAZ_UI thread Page 5 for more details and screenshots.)




---------------- 
|Overview - Hotkeys

- Bindable hotkeys
By pressing F1, you can access the hotkey window.  GAZ_UI allows you
to bind your own hotkeys!

Some notes:
Although its possible to bind a function to multiple keys, only one
key will be displayed in the F1 window.

The Hotkeys are saved to your Game.prefs file, which you can find at:
\Documents and Settings\[YOUR USER NAME]\Local Settings
\Application Data\Gas Powered Games\Supreme Commander Forged Alliance

It's sometimes easier to directly edit that file to manage your
hotkeys. BE SURE TO BACK THE FILE UP TO *ANOTHER LOCATION* BEFORE
MODIFYING IT!  This is for semi-advanced users only!



---------------- 
|New Hotkeys

GAZ_UI also adds some additional hotkeys, which you may find useful:
The format for each entry below is:

------------------
- The "internal name" which is used by Game.prefs
"The name listed in the F1 Menu"
An explanation of the key.
------------------

- toggle_repeat_build
"Toggle factory repeat build"
Toggles the "Infinite Build" button on factories.

- zoom_pop
"One-key zoom-pop"
The hotkey for the zoompop feature.

- toggle_all
"Toggle all unit abilities"
Toggles all toggleable functions on the selected units. This is a
handy key since most units only have 1 toggleable function
anyways. (eg. shield generators, mass fabricators, etc.)
Alternatively there are individual hotkeys below:

- toggle_shield "Toggle unit shield"
- toggle_weapon "Toggle unit weapon"
- toggle_jamming "Toggle unit jamming"
- toggle_intel "Toggle unit intel"
- toggle_production "Toggle unit production"
- toggle_stealth "Toggle unit stealth"
- toggle_generic "Toggle unit generic"
- toggle_special "Toggle unit special"
- toggle_cloak "Toggle unit cloak"
- toggle_cloakjammingstealth 
"Toggle all counter-intelligence abilities"
- toggle_intelshield "Toggle intel and shield"
- teleport "Teleport"

- military_overlay 
"Show all weapon ranges"
Toggles a SupCom-style "military overlay", where weapon ranges of all
units are displayed.

- intel_overlay
"Show all intel ranges"
Toggles a SupCom-style "intel overlay", where intel ranges of all
units are displayed.

- select_all_idle_eng_onscreen
"Select idle engineers on screen"
Selects all idle engineers of all tech levels that are onscreen.

- scu_upgrade_marker "Place SCU auto-upgrade marker"
- select_all_similar_units "Select all similarly upgraded units"
These are for the SCU Manager.  I think it selects all SCUs that are
similarly upgraded.  I dont use it.

- select_next_land_factory "Select next land factory"
- select_next_air_factory "Select next air factory"
- select_next_naval_factory "Select next naval factory"
Pressing these keys multiple times will go through your factories one
by one.

- toggle_selectedinfo
"Toggle single unit selected info"
Toggles the "single unit selected info" feature.  May be useful to get
rid of the window temporarily to clear up your view.

- toggle_selectedrings
"Toggle single unit selected rings"
Toggles the "single unit selected rings" feature.

- select_inview_idle_mex
"Select onscreen idle mass extractors."
Select all idle mass extractors in view.

- select_all_mex
"Select all mass extractors."
Selects all your mass extractors everywhere.

- select_nearest_idle_lt_mex
"Select nearest onscreen lowest tech idle mass extractor."
Select a mass extractor that is: 
In view, Nearest to the cursor, Lowest tech level of all mexes in view, Idle.

- acu_select_cg "Select ACU (control group)"
- acu_append_cg "Append ACU to selection (control group)"
Selects the ACU in different sort of way. I'm not sure what it does
exactly, I'll find out in the next version of this document.

- select_nearest_idle_eng_not_acu
"Select nearest idle engineer (not ACU)"
Selects the nearest idle engineer. Different from the other key
because it will not select the ACU ever.

- add_nearest_idle_engineers_seq
"Select/Add nearest idle engineers"
Pressing this key multiple times will add nearby idle engineers to
your selection one by one.

- cycle_idle_factories
"Cycle through idle factories"
Pressing this key multiple times will select idle factories one by
one.

- cycle_unit_types_in_sel
"Cycle through unit types in selection (Land, Sea, Air)"
Filter your current selection to a single class of unit (air, land,
sea). It will remember your selection so you can press this key
multiple times to cycle through the types.

- create_template_factory
"Create build template (Factory)"
If a factory with a build queue is selected, it will create a factory
queue template from it.


Some other keys that are self-explanatory:
- toggle_tab_display "Toggle options tab"
- toggle_mdf_panel "Toggle MFD panel"
- show_enemy_life "Show enemy life bars"
- show_network_stats "Show network stats window"
added by ghaleon:
- select_all_air_exp "Select all Air Experimentals" 
- select_all_air_factories "Select all Air Factories" 
- select_all_antinavy_subs "Select all anti-Navy Submarines" 
- select_all_battleships "Select all Battleships" 
- select_all_land_directfire "Select all Land Direct-Fire units" 
- select_all_land_exp "Select all Land Experimentals" 
- select_all_land_factories "Select all Land Factories" 
- select_all_land_indirectfire "Select all Land Indirect-Fire units" 
- select_all_naval_factories "Select all Naval Factories" 
- select_all_stationdrones "Select all Drones" 
- select_all_t1_engineers "Select all T1 Engineers" 
- select_all_t2_podstations "Select all T2 Engineering Podstations" 
- select_all_tml "Select all TML"
- select_anti_air_fighters "Select all Air Fighters" 
- select_gunships "Select all Gunships" 

- Render_SelectionSet_Names "Toggles display of group names"
- Render_Custom_Names "Toggles display of custom names"
- Render_Unit_Bars "Toggle display of names and bars of any kind"
- Render_Icons "Toggle display of Strategic Icons"
- Always_Render_Strategic_Icons "Toggle strategic icon cutoff"
- Kill_Selected_Units "Immediately kill selected units"
- Kill_All "Immediately kill all of your units"
- Show_Bandwidth_Usage "Show bandwith usage window"


-------------------------------
Compatibility notes
-------------------------------

ghaleon: AZUI will not work while template names and detailed unit view are enabled, nothing I can do about that, sorry.


------------------ 
| The End

This mod is mainly for my own comfort and use, so it's provided "As
is".  However, if you have a feature request and have a good reason
for it, tell me and I'll think about it. (sorry if my attitude is
less professional than Goom's, its better than nothing innit? ;)

Of course, Bug Reports are always welcome.

Special thanks to Goom for the very excellent original GUI mod.
Special thanks to norem for Factory Build Queues and also some of the
hotkeys.
Special thanks to ghaleon for his many additional modules listed above,
and also for doing all the work integrating them into v6 :)
Special thanks to Thygrrr for the smart economy indicators, and nicer
Strat Build Icons.


Bye-Be!  
-AdmiralZeech
