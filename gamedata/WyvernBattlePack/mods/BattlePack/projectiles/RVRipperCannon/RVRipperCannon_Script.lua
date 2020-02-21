-----------------------------------------------------------------------------
--  File     : /projectiles/Cybran/CNanobot01/CNanobot01_Script.lua
--  Author(s): Aaron Lundquist
--  Summary  : SC2 Cybran Nanobot Weapon: CNanobot01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
RVRipperCannon = Class(import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2SinglePolyTrailProjectile) {

        FxTrails = {
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_01_nanotrail_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_02_glow_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_03_distortwake_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_04_debris_emit.bp',
		'/mods/BattlePack/effects/emitters/w_c_nan01_p_05_nanoglow_emit.bp',
        },

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

    FxTrailScale = 0.75,
    FxLandHitScale = 0.4,
    FxPropHitScale = 0.4,
    FxUnitHitScale = 0.4,
    FxImpactUnderWater = {},
    FxSplatScale = 0.4,

}
TypeClass = RVRipperCannon