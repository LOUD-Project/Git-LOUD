UCannonShell02 = Class(import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile) {

	FxImpactUnit = {
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_01_flatflash_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_02_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_03_flatfirecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_05_sparks_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_06_dirtchunks_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_07_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_08_leftoverfire_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_09_firelines_emit.bp',
		'/effects/emitters/units/general/event/death/destruction_unit_hit_shrapnel_01_emit.bp',
	},
	FxImpactProp = {
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_01_flatflash_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_02_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_03_flatfirecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_05_sparks_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_06_dirtchunks_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_07_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_08_leftoverfire_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_09_firelines_emit.bp',
		'/effects/emitters/units/general/event/death/destruction_unit_hit_shrapnel_01_emit.bp',
	},
	FxImpactShield = {
		'/effects/emitters/weapons/uef/shield/impact/small/w_u_s_i_s_01_shrapnel_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/small/w_u_s_i_s_02_smoke_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/small/w_u_s_i_s_03_sparks_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/small/w_u_s_i_s_04_fire_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/small/w_u_s_i_s_05_firelines_emit.bp',
	},
	
	FxImpactLand = {
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_01_flatflash_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_02_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_03_flatfirecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_05_sparks_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_06_dirtchunks_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_07_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_08_leftoverfire_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/unit/w_u_gau01_i_u_09_firelines_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/impact/terrain/w_u_gau01_i_t_01_dirtlines_emit.bp',
	},
	
	FxImpactWater = {
		'/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_01_flatflash_emit.bp',
		'/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_02_flatripple_emit.bp',
		'/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_03_splash_emit.bp',
		'/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_04_waterspray_emit.bp',
		'/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_05_mist_emit.bp',
		'/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_06_leftover_emit.bp',
	},
	
	PolyTrails  = {
		'/effects/emitters/weapons/uef/gauss01/projectile/w_u_gau01_p_01_polytrails_emit.bp',
		'/effects/emitters/weapons/uef/gauss01/projectile/w_u_gau01_p_02_polytrails_emit.bp',
	},

	PolyTrailOffset = {0,0},

}
TypeClass = UCannonShell02