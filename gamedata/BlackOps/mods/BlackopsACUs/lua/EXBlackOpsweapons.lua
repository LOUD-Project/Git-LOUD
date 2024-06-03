--**  File     :  /cdimage/lua/modules/BlackOpsweapons.lua
--**  Author(s):  Lt_hawkeye
--**  Summary  :  
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

local WeaponFile            = import('/lua/sim/defaultweapons.lua')
--local CollisionBeams        = import('/lua/defaultcollisionbeams.lua')
--local CollisionBeamFile     = import('/lua/defaultcollisionbeams.lua')

local DefaultProjectileWeapon   = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon         = WeaponFile.DefaultBeamWeapon

WeaponFile = nil

local EffectTemplate        = import('/lua/EffectTemplates.lua')

local EXCollisionBeamFile   = import('/mods/BlackOpsACUs/lua/EXBlackOpsdefaultcollisionbeams.lua')
local EXEffectTemplate      = import('/mods/BlackopsACUs/lua/EXBlackOpsEffectTemplates.lua')


AeonACUPhasonLaser                  = Class(DefaultBeamWeapon) { BeamType = EXCollisionBeamFile.AeonACUPhasonLaserCollisionBeam,
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

EXCEMPArrayBeam01                   = Class(DefaultBeamWeapon) { BeamType = EXCollisionBeamFile.EXCEMPArrayBeam01CollisionBeam }

PDLaserGrid                         = Class(DefaultBeamWeapon) { BeamType = EXCollisionBeamFile.PDLaserCollisionBeam,

    FxUpackingChargeEffects = {},
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

PDLaserGrid2                        = Class(DefaultBeamWeapon) { BeamType = EXCollisionBeamFile.PDLaser2CollisionBeam,

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

UEFACUAntiMatterWeapon              = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EXEffectTemplate.ACUAntiMatterMuzzle }

UEFACUFlamerWeapon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TGaussCannonFlash }

UEFACUHeavyPlasmaGatlingCannonWeapon = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EXEffectTemplate.UEFACUHeavyPlasmaGatlingCannonMuzzleFlash,
	FxMuzzleFlashScale = 0.35,
}

SeraACURapidWeapon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.SDFAireauWeaponMuzzleFlash,
	FxMuzzleFlashScale = 0.33,
}

SeraACUBigBallWeapon                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.SDFSinnutheWeaponMuzzleFlash,
    FxChargeMuzzleFlash = EffectTemplate.SDFSinnutheWeaponChargeMuzzleFlash,
	FxChargeMuzzleFlashScale = 0.33,
	FxMuzzleFlashScale = 0.33,
}
