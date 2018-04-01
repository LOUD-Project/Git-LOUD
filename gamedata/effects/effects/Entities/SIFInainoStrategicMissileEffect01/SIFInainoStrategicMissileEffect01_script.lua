
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFInainoStrategicMissileEffect01 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = EffectTemplate.SIFInainoPlumeFxTrails01,
	FxImpactTrajectoryAligned = true,
}
TypeClass = SIFInainoStrategicMissileEffect01
