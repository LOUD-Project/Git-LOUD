##****************************************************************************
#**  File     :  lua/modules/ui/help/unitdescriptions.lua
#**  Author(s):  Ted Snook
#**
#**  Summary  :  Strings and images for the unit rollover System
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************


do

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 

local OldDescription = Description
Description = table.merged(OldDescription, __DMSI.__DMod_Custom_Descriptions)

end
