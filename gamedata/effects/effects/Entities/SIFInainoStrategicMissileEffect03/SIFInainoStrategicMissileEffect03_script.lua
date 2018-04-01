
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFInainoStrategicMissileEffect03 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = EffectTemplate.SIFInainoHitRingProjectileFxTrails01,
}
TypeClass = SIFInainoStrategicMissileEffect03

