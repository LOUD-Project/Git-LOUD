-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uhandcannon01/uhandcannon01_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist
--  Summary  :  SC2 UEF Hand Cannon: UHandCannon01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
UDisruptorArtillery01 = Class(import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned =true,

        FxTrails = {
            '/mods/BattlePack/effects/emitters/w_u_dra01_p_01_glow_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_p_04_wisps_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_p_05_waves_emit.bp',
        },

    PolyTrails = {
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_02_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_03_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_06_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_07_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_08_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_09_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_02_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_09_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_06_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_03_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_08_polytrail_emit.bp',
                '/mods/BattlePack/effects/emitters/w_u_dra01_p_07_polytrail_emit.bp',
        },

	PolyTrailOffset = {0,0,0,0,0,0,0,0,0,0,0,0},

        FxImpactUnit = {
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_01_flatflash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_02_flash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_03_sparks_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_04_plasma_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_05_shockwaves_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_06_lines_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_07_groundsmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_08_debris_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_09_smoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_10_lingersmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_11_stunrings_emit.bp',
        },
        FxImpactLand = {
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_01_flatflash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_02_flash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_03_sparks_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_04_plasma_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_05_shockwaves_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_06_lines_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_07_groundsmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_08_debris_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_09_smoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_10_lingersmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_11_stunrings_emit.bp',
        },
        FxImpactWater = {
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_01_flatflash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_02_flash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_03_sparks_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_04_plasma_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_05_shockwaves_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_06_lines_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_07_groundsmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_08_debris_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_09_smoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_10_lingersmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_11_stunrings_emit.bp',
        },
        FxImpactProp = {
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_01_flatflash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_02_flash_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_03_sparks_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_04_plasma_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_05_shockwaves_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_06_lines_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_07_groundsmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_08_debris_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_09_smoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_10_lingersmoke_emit.bp',
            '/mods/BattlePack/effects/emitters/w_u_dra01_i_u_11_stunrings_emit.bp',
        },

    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxImpactUnderWater = {},
    FxSplatScale = 0.5,

}
TypeClass = UDisruptorArtillery01