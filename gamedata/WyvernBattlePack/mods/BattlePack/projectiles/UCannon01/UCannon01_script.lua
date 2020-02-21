-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/UCannon01/UCannon01_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Commander Cannon Shell: UCannon01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
UCannon01 = Class(import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned =true,

	Polytrail = {
           '/mods/BattlePack/effects/emitters/w_u_hvg01_p_03_polytrail_emit.bp',
        },
		
		FxTrails = {
        '/mods/BattlePack/effects/emitters/w_u_hvg01_p_01_smoke_emit.bp',
        '/mods/BattlePack/effects/emitters/w_u_hvg01_p_04_wisps_emit.bp',
        '/mods/BattlePack/effects/emitters/w_u_hvg01_p_05_glow_emit.bp',
        },

    FxImpactUnit = {
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_01_flatflash_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_02_flash_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_03_sparks_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_04_halfring_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_05_ring_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_06_firecloud_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_07_fwdsparks_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_08_leftoverglows_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_09_leftoverwisps_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_10_fwdsmoke_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_11_debris_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_12_lines_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_13_leftoversmoke_emit.bp',
        },
    FxImpactProp = {
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_01_flatflash_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_02_flash_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_03_sparks_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_04_halfring_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_05_ring_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_06_firecloud_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_07_fwdsparks_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_08_leftoverglows_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_09_leftoverwisps_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_10_fwdsmoke_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_11_debris_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_12_lines_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_13_leftoversmoke_emit.bp',
        },
    FxImpactLand = {
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_01_flatflash_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_02_flash_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_03_sparks_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_04_halfring_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_05_ring_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_06_firecloud_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_07_fwdsparks_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_08_leftoverglows_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_09_leftoverwisps_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_10_fwdsmoke_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_11_debris_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_12_lines_emit.bp',
           '/mods/BattlePack/effects/emitters/w_u_hvg01_i_u_13_leftoversmoke_emit.bp',
        },
		PolyTrailScale = 0.75, 
		FxTrailScale = 0.75,
    FxPropHitScale = 0.3,
    FxLandHitScale = 0.3,
    FxUnitHitScale = 0.3,
	
	
}
TypeClass = UCannon01