UCannonShell03 = Class(import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile) {

	PolyTrails = {
		'/effects/emitters/weapons/uef/gauss03/projectile/w_u_gau03_p_01_polytrails_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/projectile/w_u_gau03_p_02_polytrails_emit.bp',
	},

	PolyTrailOffset = {0,0},
	
	FxTrails = {
		'/effects/emitters/weapons/uef/gauss03/projectile/w_u_gau03_p_03_brightglow_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/projectile/w_u_gau03_p_04_smoke_emit.bp',
	},

	FXImpact = {
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_01_flatflash_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_02_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_03_flatfirecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_05_sparks_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_06_dirtchunks_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_07_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_08_leftoverfire_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_09_firelines_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/terrain/w_u_gau03_i_t_01_dirtlines_emit.bp',
	},
		
	FxImpactShield = {
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_01_shrapnel_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_02_fire_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_03_sparks_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_05_firelines_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_06_ring_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_07_wisps_emit.bp',
		'/effects/emitters/weapons/uef/shield/impact/large/w_u_s_i_l_08_flash_emit.bp',
	},
		
	FxImpactLand = {
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_01_flatflash_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_02_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_03_flatfirecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_05_sparks_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_06_dirtchunks_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_07_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_08_leftoverfire_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_09_firelines_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/terrain/w_u_gau03_i_t_01_dirtlines_emit.bp',
	},
		
	FxImpactUnit = {
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_01_flatflash_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_02_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_03_flatfirecloud_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_04_smoke_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_05_sparks_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_06_dirtchunks_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_07_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_08_leftoverfire_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/unit/w_u_gau03_i_u_09_firelines_emit.bp',
		'/effects/emitters/weapons/uef/gauss03/impact/terrain/w_u_gau03_i_t_01_dirtlines_emit.bp',
	},
	
	FxImpactWater = {
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_01_flatflash_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_02_flatripple_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_03_shockwave_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_04_splash_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_05_firecore_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_06_waterspray_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_07_mist_emit.bp',
		'/effects/emitters/weapons/generic/water01/medium01/impact/w_g_wat01_m_i_08_leftover_emit.bp',
   },
}
TypeClass = UCannonShell03