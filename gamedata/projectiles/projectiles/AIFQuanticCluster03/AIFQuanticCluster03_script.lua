local EffectTemplate = import('/lua/EffectTemplates.lua')

AIFQuanticCluster03 = Class(import('/lua/aeonprojectiles.lua').AQuantumCluster) {
    FxTrails     = EffectTemplate.TFragmentationSensorShellTrail,
    FxImpactUnit = EffectTemplate.TFragmentationSensorShellHit,
    FxImpactLand = EffectTemplate.TFragmentationSensorShellHit,
}
TypeClass = AIFQuanticCluster03