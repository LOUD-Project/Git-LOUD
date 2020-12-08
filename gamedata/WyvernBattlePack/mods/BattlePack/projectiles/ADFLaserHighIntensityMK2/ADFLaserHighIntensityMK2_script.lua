--
-- Aeon laser 'bolt'
--
local AHighIntensityLaserProjectile = import('/lua/aeonprojectiles.lua').AHighIntensityLaserProjectile
local BPEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')
ADFLaserHighIntensityMK2 = Class(AHighIntensityLaserProjectile) {
    FxTrails = {
        '/mods/BattlePack/effects/emitters/redaeon_laser_fxtrail_01_emit.bp',
        '/mods/BattlePack/effects/emitters/redaeon_laser_fxtrail_02_emit.bp',
    },
    PolyTrail = '/mods/BattlePack/effects/emitters/redaeon_laser_trail_01_emit.bp',

    # Hit Effects
    FxImpactUnit = BPEffectTemplate.AHighIntensityLaserHitMK2,
    FxImpactProp = BPEffectTemplate.AHighIntensityLaserHitMK2,
    FxImpactLand = BPEffectTemplate.AHighIntensityLaserHitMK2,
    FxImpactUnderWater = {},

    FxMuzzleFlash = BPEffectTemplate.AHighIntensityLaserFlashMK2,
}

TypeClass = ADFLaserHighIntensityMK2
