#****************************************************************************
#**  Author(s):  Exavier Macbeth
#**  Summary  :  BlackOps: Adv Command Unit - Aeon ACU
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')
local ADFDisruptorCannonWeapon = AWeapons.ADFDisruptorCannonWeapon
local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Weapon = import('/lua/sim/Weapon.lua').Weapon
local ADFOverchargeWeapon = AWeapons.ADFOverchargeWeapon
local ADFChronoDampener = AWeapons.ADFChronoDampener
local Buff = import('/lua/sim/Buff.lua')
local CSoothSayerAmbient = import('/lua/EffectTemplates.lua').CSoothSayerAmbient
local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon
local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon
local ADFPhasonLaser = import('/lua/aeonweapons.lua').ADFPhasonLaser
local AeonACUPhasonLaser = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').AeonACUPhasonLaser 
local AIFQuasarAntiTorpedoWeapon = AWeapons.AIFQuasarAntiTorpedoWeapon
local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01 
local AAMWillOWisp = import('/lua/aeonweapons.lua').AAMWillOWisp
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker


local EXQuantumMaelstromWeapon = Class(Weapon) {

    OnFire = function(self)
        local blueprint = self:GetBlueprint()
        DamageArea(self.unit, self.unit:GetPosition(), blueprint.DamageRadius,
                   blueprint.Damage, blueprint.DamageType, blueprint.DamageFriendly)
    end,
}

local OldEAL0001 = EAL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

EAL0001 = Hunker.AddHunker(OldEAL0001)

TypeClass = EAL0001