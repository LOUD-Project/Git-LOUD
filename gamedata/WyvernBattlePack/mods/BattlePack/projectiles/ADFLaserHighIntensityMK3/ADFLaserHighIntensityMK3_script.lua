--
-- Aeon laser 'bolt'
--
local AHighIntensityLaserProjectile = import('/lua/aeonprojectiles.lua').AHighIntensityLaserProjectile
local BPEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')
ADFLaserHighIntensityMK3 = Class(AHighIntensityLaserProjectile) {
    FxTrails = {
        '/mods/BattlePack/effects/emitters/pinkaeon_laser_fxtrail_01_emit.bp',
        '/mods/BattlePack/effects/emitters/pinkaeon_laser_fxtrail_02_emit.bp',
    },
    PolyTrail = '/mods/BattlePack/effects/emitters/pinkaeon_laser_trail_01_emit.bp',

    # Hit Effects
    FxImpactUnit = BPEffectTemplate.AHighIntensityLaserHitMK3,
    FxImpactProp = BPEffectTemplate.AHighIntensityLaserHitMK3,
    FxImpactLand = BPEffectTemplate.AHighIntensityLaserHitMK3,
    FxImpactUnderWater = {},

    FxMuzzleFlash = BPEffectTemplate.AHighIntensityLaserFlashMK3,
}

TypeClass = ADFLaserHighIntensityMK3
