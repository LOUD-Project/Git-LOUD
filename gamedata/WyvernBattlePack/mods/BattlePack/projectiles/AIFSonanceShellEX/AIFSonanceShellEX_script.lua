--
-- Aeon Artillery Projectile
--
local AArtilleryProjectile = import('/lua/aeonprojectiles.lua').AArtilleryProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

AIFSonanceShellEX = Class(AArtilleryProjectile) {
    PolyTrail = '/effects/emitters/aeon_sonicgun_trail_emit.bp',
    
    FxTrails = EffectTemplate.ASonanceWeaponFXTrail01,
    
    FxImpactUnit =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactProp =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactLand =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactWater = EffectTemplate.ASonanceWeaponHit02,

    FxTrailScale = 1.5,
    FxPropHitScale = 1,
    FxWaterHitScale = 1,
    FxLandHitScale = 1,
    FxUnitHitScale = 1,

}

TypeClass = AIFSonanceShellEX