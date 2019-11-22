#****************************************************************************
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**  Summary  :  UEF Commander Script
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local util = import('/lua/utilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local OldUEL0001 = UEL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

UEL0001 = Hunker.AddHunker(OldUEL0001)

TypeClass = UEL0001