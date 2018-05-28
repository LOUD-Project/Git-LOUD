#****************************************************************************
#**  Author(s):  Exavier Macbeth
#**  Summary  :  BlackOps: Adv Command Unit - Cybran ACU
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local CWeapons = import('/lua/cybranweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

#local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CDFOverchargeWeapon = CWeapons.CDFOverchargeWeapon
local CANTorpedoLauncherWeapon = CWeapons.CANTorpedoLauncherWeapon
local Entity = import('/lua/sim/Entity.lua').Entity
local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01 
local EXCEMPArrayBeam02 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam02 
local EXCEMPArrayBeam03 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam03 
local RocketPack = import('/lua/cybranweapons.lua').CDFRocketIridiumWeapon02

local OldERL0001 = ERL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

ERL0001 = Hunker.AddHunker(OldERL0001)


TypeClass = ERL0001
