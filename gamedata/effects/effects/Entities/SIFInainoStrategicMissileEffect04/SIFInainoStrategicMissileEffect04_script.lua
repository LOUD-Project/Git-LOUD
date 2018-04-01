
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFInainoStrategicMissileEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = EffectTemplate.SIFInainoPlumeFxTrails03,
}
TypeClass = SIFInainoStrategicMissileEffect04
