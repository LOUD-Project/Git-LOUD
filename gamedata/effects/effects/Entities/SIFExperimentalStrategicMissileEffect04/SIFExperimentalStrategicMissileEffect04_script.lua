
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFExperimentalStrategicMissileEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = EffectTemplate.SIFExperimentalStrategicMissilePlumeFxTrails03,
}
TypeClass = SIFExperimentalStrategicMissileEffect04
