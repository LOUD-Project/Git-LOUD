#****************************************************************************
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**  Summary  :  UEF Commander Script
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local EffectTemplate = import('/lua/EffectTemplates.lua')
local OldUAL0001 = UAL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

UAL0001 = Hunker.AddHunker(OldUAL0001)

TypeClass = UAL0001