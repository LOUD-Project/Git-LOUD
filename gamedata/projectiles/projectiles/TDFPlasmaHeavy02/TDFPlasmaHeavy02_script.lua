local THeavyPlasmaCannonProjectile = import('/lua/terranprojectiles.lua').THeavyPlasmaCannonProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

TDFPlasmaHeavy02 = Class(THeavyPlasmaCannonProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition02,

}
TypeClass = TDFPlasmaHeavy02

