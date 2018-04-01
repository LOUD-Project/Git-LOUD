#****************************************************************************
#**
#**  File     :  /cdimage/lua/modules/BlackOpsweapons.lua
#**  Author(s):  Lt_hawkeye
#**
#**  Summary  :  
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local WeaponFile = import('/lua/sim/defaultweapons.lua')
local CollisionBeams = import('/lua/defaultcollisionbeams.lua')
local CollisionBeamFile = import('/lua/defaultcollisionbeams.lua')
local KamikazeWeapon = WeaponFile.KamikazeWeapon
local BareBonesWeapon = WeaponFile.BareBonesWeapon
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon
local GinsuCollisionBeam = CollisionBeams.GinsuCollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local QuantumBeamGeneratorCollisionBeam = CollisionBeamFile.QuantumBeamGeneratorCollisionBeam
local PhasonLaserCollisionBeam = CollisionBeamFile.PhasonLaserCollisionBeam
local MicrowaveLaserCollisionBeam01 = CollisionBeamFile.MicrowaveLaserCollisionBeam01
local EXCollisionBeamFile = import('/mods/BlackOpsACUs/lua/EXBlackOpsdefaultcollisionbeams.lua')
local EXEffectTemplate = import('/mods/BlackopsACUs/lua/EXBlackOpsEffectTemplates.lua')


HawkNapalmWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TGaussCannonFlash,
}

HawkGaussCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TGaussCannonFlash,
}

UEFACUAntiMatterWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EXEffectTemplate.ACUAntiMatterMuzzle,
}

PDLaserGrid = Class(DefaultBeamWeapon) {
    BeamType = EXCollisionBeamFile.PDLaserCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},

    FxUpackingChargeEffects = {},#'/effects/emitters/quantum_generator_charge_01_emit.bp'},
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
        local army = self.unit:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in self.FxUpackingChargeEffects do
            for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale):ScaleEmitter(0.05)
            end
        end
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

EXCEMPArrayBeam01 = Class(DefaultBeamWeapon) {
    BeamType = EXCollisionBeamFile.EXCEMPArrayBeam01CollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},

}

EXCEMPArrayBeam02 = Class(DefaultBeamWeapon) {
    BeamType = EXCollisionBeamFile.EXCEMPArrayBeam02CollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},

}

EXCEMPArrayBeam03 = Class(DefaultBeamWeapon) {
    BeamType = EXCollisionBeamFile.EXCEMPArrayBeam03CollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},

}

PDLaserGrid2 = Class(DefaultBeamWeapon) {
    BeamType = EXCollisionBeamFile.PDLaser2CollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

UEFACUHeavyPlasmaGatlingCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EXEffectTemplate.UEFACUHeavyPlasmaGatlingCannonMuzzleFlash,
	FxMuzzleFlashScale = 0.35,
}

AeonACUPhasonLaser = Class(DefaultBeamWeapon) {
    BeamType = EXCollisionBeamFile.AeonACUPhasonLaserCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.33,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

SeraACURapidWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SDFAireauWeaponMuzzleFlash,
	FxMuzzleFlashScale = 0.33,
}

SeraACUBigBallWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SDFSinnutheWeaponMuzzleFlash,
    FxChargeMuzzleFlash = EffectTemplate.SDFSinnutheWeaponChargeMuzzleFlash,
	FxChargeMuzzleFlashScale = 0.33,
	FxMuzzleFlashScale = 0.33,
}
