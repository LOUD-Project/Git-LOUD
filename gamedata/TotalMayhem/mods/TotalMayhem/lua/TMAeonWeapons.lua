local WeaponFile = import('/lua/sim/DefaultWeapons.lua')

local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon

local TMCollisionBeamFile = import('/mods/TotalMayhem/lua/TMcollisionbeams.lua')

local EffectTemplate = import('/lua/EffectTemplates.lua')

local TMNovaCatBlueLaserBeam = TMCollisionBeamFile.TMNovaCatBlueLaserBeam
local TMNovaCatGreenLaserBeam = TMCollisionBeamFile.TMNovaCatGreenLaserBeam
local TMMizuraBlueLaserBeam = TMCollisionBeamFile.TMMizuraBlueLaserBeam

TMAnovacatbluelaserweapon = Class(DefaultBeamWeapon) {
    BeamType = TMCollisionBeamFile.TMNovaCatBlueLaserBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.5,
}

TMAnovacatgreenlaserweapon = Class(DefaultBeamWeapon) {
    BeamType = TMCollisionBeamFile.TMNovaCatGreenLaserBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
    FxUpackingChargeEffects = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
    FxUpackingChargeEffectScale = 0.5,
}

TMAmizurabluelaserweapon = Class(DefaultBeamWeapon) {
    BeamType = TMCollisionBeamFile.TMMizuraBlueLaserBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.5,
}