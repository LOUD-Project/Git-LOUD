
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFInainoStrategicMissileEffect02 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = EffectTemplate.SIFInainoPlumeFxTrails02,
	FxImpactTrajectoryAligned = true,
}
TypeClass = SIFInainoStrategicMissileEffect02
