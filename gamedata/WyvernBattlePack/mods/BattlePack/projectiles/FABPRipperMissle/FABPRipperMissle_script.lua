#
# Terran Nuke Missile
#
local TIFSmallYieldNuclearBombProjectile = import('/lua/terranprojectiles.lua').TArtilleryAntiMatterProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

FABPRipperMissle = Class(TIFSmallYieldNuclearBombProjectile) {

    FxTrails = EffectTemplate.TMissileExhaust01,
	FxLandHitScale = 0.4,
    FxUnitHitScale = 0.4,
}

TypeClass = FABPRipperMissle
