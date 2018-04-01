
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFExperimentalStrategicMissileEffect02 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = EffectTemplate.SIFExperimentalStrategicMissileFxTrails01,
}
TypeClass = SIFExperimentalStrategicMissileEffect02

