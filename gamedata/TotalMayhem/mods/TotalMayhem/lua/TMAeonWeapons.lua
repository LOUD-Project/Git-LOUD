local WeaponFile = import('/lua/sim/DefaultWeapons.lua')

local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon

local TMCollisionBeamFile = import('/mods/TotalMayhem/lua/TMcollisionbeams.lua')

local EffectTemplate = import('/lua/EffectTemplates.lua')

local TMNovaCatBlueLaserBeam    = TMCollisionBeamFile.TMNovaCatBlueLaserBeam
local TMNovaCatGreenLaserBeam   = TMCollisionBeamFile.TMNovaCatGreenLaserBeam
local TMMizuraBlueLaserBeam     = TMCollisionBeamFile.TMMizuraBlueLaserBeam

TMAnovacatbluelaserweapon   = Class(DefaultBeamWeapon) { BeamType = TMNovaCatBlueLaserBeam,

    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.5,
}

TMAnovacatgreenlaserweapon  = Class(DefaultBeamWeapon) { BeamType = TMNovaCatGreenLaserBeam,

    FxChargeMuzzleFlash = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
    FxUpackingChargeEffects = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
    FxUpackingChargeEffectScale = 0.5,
}

TMAmizurabluelaserweapon    = Class(DefaultBeamWeapon) { BeamType = TMMizuraBlueLaserBeam,

    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.5,
}