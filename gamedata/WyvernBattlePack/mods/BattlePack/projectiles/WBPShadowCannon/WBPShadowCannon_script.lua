local Bolter = import('/lua/cybranprojectiles.lua').CElectronBolterProjectile

WBPShadowCannon = Class(Bolter) {

	FxTrails = {
		'/effects/emitters/electron_bolter_munition_01_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_01_nanotrail_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_02_glow_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_03_distortwake_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_04_debris_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_05_nanoglow_emit.bp',
	},

	PolyTrailScale = 0.8,
	FxTrailScale = 0.8,

	FxImpactUnit = {
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_01_groundflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_02_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_03_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_04_core_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_06_darklines_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_08_plasma_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_09_electricity_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_10_groundring_emit.bp',
    },

    FxImpactLand = {
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_01_groundflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_02_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_03_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_04_core_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_06_darklines_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_08_plasma_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_09_electricity_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_10_groundring_emit.bp',
    },

    FxImpactWater = {
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_01_groundflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_02_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_03_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_04_core_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_06_darklines_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_08_plasma_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_09_electricity_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_10_groundring_emit.bp',
    },

    FxImpactProp = {
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_01_groundflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_02_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_03_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_04_core_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_06_darklines_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_08_plasma_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_09_electricity_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_i_u_10_groundring_emit.bp',
    },

	FxLandHitScale = 0.6,
    FxPropHitScale = 0.45,
    FxUnitHitScale = 0.7,
	FxWatertHitScale = 0.45,
}

TypeClass = WBPShadowCannon

