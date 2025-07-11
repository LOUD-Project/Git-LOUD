local EffectTemplate = import('/lua/EffectTemplates.lua')

CLaser06 = Class(import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned =true,

	PolyTrail = '/mods/BattlePack/effects/emitters/w_c_aa01_p_03_polytrail_emit.bp',

    FxImpactUnit = EffectTemplate.CElectronBolterHitUnit01,
    FxImpactProp = EffectTemplate.CElectronBolterHitUnit01,
    FxImpactLand = EffectTemplate.CElectronBolterHitLand01,

}
TypeClass = CLaser06