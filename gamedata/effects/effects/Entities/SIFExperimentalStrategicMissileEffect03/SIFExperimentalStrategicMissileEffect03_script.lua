
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFExperimentalStrategicMissileEffect03 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = EffectTemplate.SIFExperimentalStrategicMissilePlumeFxTrails02,
}
TypeClass = SIFExperimentalStrategicMissileEffect03
