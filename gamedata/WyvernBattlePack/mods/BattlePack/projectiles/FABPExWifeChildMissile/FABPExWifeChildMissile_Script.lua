#
# Cybran "Loa" Tactical Missile, structure unit and sub launched variant of this projectile,
# with a higher arc and distance based adjusting trajectory. Splits into child projectile 
# if it takes enough damage.
#
local EffectTemplate = import('/lua/EffectTemplates.lua')
local CLOATacticalMissileProjectile = import('/lua/cybranprojectiles.lua').CLOATacticalMissileProjectile

FABPExWifeChildMissile = Class(CLOATacticalMissileProjectile) {
    FxTrails     = EffectTemplate.TFragmentationSensorShellTrail,
    FxImpactUnit = EffectTemplate.TFragmentationSensorShellHit,
    FxImpactLand = EffectTemplate.TFragmentationSensorShellHit,
}
TypeClass = FABPExWifeChildMissile

