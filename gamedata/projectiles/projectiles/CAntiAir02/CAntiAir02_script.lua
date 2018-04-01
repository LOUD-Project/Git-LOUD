-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cantiair02/cantiair02_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran AntiAir: CAntiAir02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

CAntiAir02 = Class(import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned =true,
	FxImpactAirUnit = {
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_02_flash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_03_sparks_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_04_glows_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_05_whitesmoke_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_06_lines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_07_redlines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_09_redsmoke_emit.bp',
	},
	FxImpactProp  = {
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_02_flash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_03_sparks_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_04_glows_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_05_whitesmoke_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_06_lines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_07_redlines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_09_redsmoke_emit.bp',
	},
	FxImpactShield  = {
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/shield/impact/small/w_c_s_i_s_01_flash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/shield/impact/small/w_c_s_i_s_02_sparks_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/shield/impact/small/w_c_s_i_s_03_whitesmoke_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/shield/impact/small/w_c_s_i_s_04_lines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/shield/impact/small/w_c_s_i_s_05_glowflicker_emit.bp',
	},
	FxImpactLand  = {
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_02_flash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_03_sparks_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_04_glows_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_05_whitesmoke_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_06_lines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_07_redlines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_09_redsmoke_emit.bp',
	},
	FxImpactUnit  = {
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_02_flash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_03_sparks_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_04_glows_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_05_whitesmoke_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_06_lines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_07_redlines_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/laser01/impact/unit/w_c_las01_i_u_09_redsmoke_emit.bp',
	},
	FxImpactWater  = {
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_01_flatflash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_02_flatripple_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_03_splash_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_04_waterspray_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_05_mist_emit.bp',
		'/mods/TEX Enhancement Pack/effects/emitters/weapons/generic/water01/small01/impact/w_g_wat01_s_i_06_leftover_emit.bp',
	},

	PolyTrail = '/mods/TEX Enhancement Pack/effects/emitters/weapons/cybran/antiair01/projectile/w_c_aa01_p_03_polytrail_emit.bp',
}
TypeClass = CAntiAir02