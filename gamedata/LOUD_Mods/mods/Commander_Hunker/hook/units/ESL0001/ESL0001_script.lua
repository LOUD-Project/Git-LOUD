#****************************************************************************
#**  Author(s):  Exavier Macbeth
#**  Summary  :  BlackOps: Adv Command Unit - Serephim ACU
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local Buff = import('/lua/sim/Buff.lua')

local SWeapons = import('/lua/seraphimweapons.lua')
local SDFChronotronCannonWeapon = SWeapons.SDFChronotronCannonWeapon
local SDFChronotronOverChargeCannonWeapon = SWeapons.SDFChronotronCannonOverChargeWeapon
local SIFCommanderDeathWeapon = SWeapons.SIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local SIFLaanseTacticalMissileLauncher = SWeapons.SIFLaanseTacticalMissileLauncher
local AIUtils = import('/lua/ai/aiutilities.lua')
local SDFAireauWeapon = SWeapons.SDFAireauWeapon
local SDFSinnuntheWeapon = SWeapons.SDFSinnuntheWeapon
local SANUallCavitationTorpedo = SWeapons.SANUallCavitationTorpedo
local SeraACURapidWeapon = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').SeraACURapidWeapon 
local SeraACUBigBallWeapon = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').SeraACUBigBallWeapon 
local SAAOlarisCannonWeapon = SWeapons.SAAOlarisCannonWeapon

# Setup as RemoteViewing child unit rather than SWalkingLandUnit
local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing
SWalkingLandUnit = RemoteViewing( SWalkingLandUnit ) 

local OldESL0001 = ESL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

ESL0001 = Hunker.AddHunker(OldESL0001)

TypeClass = ESL0001