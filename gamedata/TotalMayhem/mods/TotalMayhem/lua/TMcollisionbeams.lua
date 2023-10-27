local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TMEffectTemplate = import('/mods/TotalMayhem/lua/TMEffectTemplates.lua')

TMCollisionBeam = Class(CollisionBeam) {

    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
}

TMNovaCatBlueLaserBeam = Class(TMCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.6,
    FxBeamStartPoint = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxBeam = {'/mods/TotalMayhem/effects/emitters/novacat_bluelaser_emit.bp'},
    FxBeamEndPoint = TMEffectTemplate.AeonNocaCatBlueLaserHit,
    FxBeamEndPointScale = 0.4,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.4,
    ScorchTime = 30,
}

TMNovaCatGreenLaserBeam = Class(TMCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 1.0,
    FxBeamStartPoint = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxBeam = {'/mods/TotalMayhem/effects/emitters/novacat_greenlaser_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    FxBeamEndPointScale = 0.8,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.4,
    ScorchTime = 30,
}

TMMizuraBlueLaserBeam = Class(TMCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.8,
    FxBeamStartPoint = EffectTemplate.ASDisruptorCannonMuzzle01,
    FxBeam = {'/mods/TotalMayhem/effects/emitters/mizura_bluelaser_emit.bp'},
    FxBeamEndPoint = TMEffectTemplate.AeonNocaCatBlueLaserHit,
    FxBeamEndPointScale = 0.07,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.4,
    ScorchTime = 30,
}