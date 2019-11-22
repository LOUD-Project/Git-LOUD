#****************************************************************************
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**  Summary  :  UEF Commander Script
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local EffectTemplate = import('/lua/EffectTemplates.lua')
local OldURL0001 = URL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

URL0001 = Hunker.AddHunker(OldURL0001)

TypeClass = URL0001