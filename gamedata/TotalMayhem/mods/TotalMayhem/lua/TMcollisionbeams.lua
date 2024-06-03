local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TMEffectTemplate = import('/mods/TotalMayhem/lua/TMEffectTemplates.lua')

TMCollisionBeam = Class(CollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,

    FxImpactUnit        = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactWater       = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactAirUnit     = EffectTemplate.DefaultProjectileAirUnitImpact,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.4,
    ScorchTime = 30,
}

TMNovaCatBlueLaserBeam = Class(TMCollisionBeam) {

    FxBeamStartPointScale = 0.6,
    FxBeamStartPoint = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxBeam = {'/mods/TotalMayhem/effects/emitters/novacat_bluelaser_emit.bp'},
    FxBeamEndPoint = TMEffectTemplate.AeonNocaCatBlueLaserHit,
    FxBeamEndPointScale = 0.25,
}

TMNovaCatGreenLaserBeam = Class(TMCollisionBeam) {

    FxBeamStartPointScale = 1.0,
    FxBeamStartPoint = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxBeam = {'/mods/TotalMayhem/effects/emitters/novacat_greenlaser_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    FxBeamEndPointScale = 0.25,
}

TMMizuraBlueLaserBeam = Class(TMCollisionBeam) {

    FxBeamStartPointScale = 0.8,
    FxBeamStartPoint = EffectTemplate.ASDisruptorCannonMuzzle01,
    FxBeam = {'/mods/TotalMayhem/effects/emitters/mizura_bluelaser_emit.bp'},
    FxBeamEndPoint = TMEffectTemplate.AeonNocaCatBlueLaserHit,
    FxBeamEndPointScale = 0.25,
}