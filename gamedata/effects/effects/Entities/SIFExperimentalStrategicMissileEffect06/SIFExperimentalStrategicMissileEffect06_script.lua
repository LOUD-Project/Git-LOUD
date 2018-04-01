
local EffectTemplate = import('/lua/EffectTemplates.lua')

SIFExperimentalStrategicMissileEffect06 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = EffectTemplate.SIFExperimentalStrategicMissilePlumeFxTrails05,
}
TypeClass = SIFExperimentalStrategicMissileEffect06

