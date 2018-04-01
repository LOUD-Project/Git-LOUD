#****************************************************************************
#**  File     :  lua/modules/ui/help/tooltips.lua
#**  Author(s):  Ted Snook
#**
#**  Summary  :  Strings and images for the tooltips System
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************



do

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 

local OldTooltips = Tooltips
Tooltips = table.merged(OldTooltips, __DMSI.__DMod_Custom_Tooltips)

end
