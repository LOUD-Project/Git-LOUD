#****************************************************************************
#**  Author(s):  Exavier Macbeth
#**  Summary  :  BlackOps: Adv Command Unit - UEF ACU
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local Shield = import('/lua/shield.lua').Shield

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local TerranWeaponFile = import('/lua/terranweapons.lua')
local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TIFCruiseMissileLauncher = TerranWeaponFile.TIFCruiseMissileLauncher
local TDFOverchargeWeapon = TerranWeaponFile.TDFOverchargeWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local UEFACUHeavyPlasmaGatlingCannonWeapon = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').UEFACUHeavyPlasmaGatlingCannonWeapon
local Weapons2 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua')
local EXFlameCannonWeapon = Weapons2.HawkGaussCannonWeapon
local UEFACUAntiMatterWeapon = Weapons2.UEFACUAntiMatterWeapon
local PDLaserGrid = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').PDLaserGrid2 
local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

local OldEEL0001 = EEL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

EEL0001 = Hunker.AddHunker(OldEEL0001)

TypeClass = EEL0001