
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFExperimentalStrategicMissileEffect05 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = EffectTemplate.SIFExperimentalStrategicMissilePlumeFxTrails04,
}
TypeClass = SIFExperimentalStrategicMissileEffect05

