local TArtilleryProjectilePolytrail = import('/lua/terranprojectiles.lua').TArtilleryProjectilePolytrail

local EffectTemplate = import('/lua/EffectTemplates.lua')

HellStormArtillery01 = Class(TArtilleryProjectilePolytrail) {

	FxImpactTrajectoryAligned = false,

    PolyTrail = '/effects/emitters/default_polytrail_04_emit.bp',
    FxImpactUnit = EffectTemplate.TAPDSHitUnit01,
    FxImpactLand = EffectTemplate.TAPDSHit01,
	FxLandHitScale = 0.8,
	FxUnitHitScale = 0.8,
}

TypeClass = HellStormArtillery01

