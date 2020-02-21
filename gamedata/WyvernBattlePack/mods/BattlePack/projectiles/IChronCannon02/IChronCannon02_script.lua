-----------------------------------------------------------------------------
--  File     : /projectiles/Illuminate/IChronCannon01/IChronCannon01_script.lua
--  Author(s): Matt Vainio, Gordon Duclos
--  Summary  : Chronatron Cannon Projectile script, UIL0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local EffectTemplate = import('/lua/EffectTemplates.lua')
IChronCannon02 = Class(import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned = true,

	FxTrails  = {
		'/mods/BattlePack/effects/emitters/w_i_pla05_p_02_trail_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_pla05_p_03_glow_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_pla05_p_04_distortwake_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_pla05_p_05_debris_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_pla05_p_06_plasma_emit.bp',
	},

        Polytrail = '/mods/BattlePack/effects/emitters/w_i_pla05_p_01_polytrail_emit.bp',

	PolyTrailOffset = 0,

        FxImpactUnit = {
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_01_groundflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_02_cameraflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_04_plasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_06_ring_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_07_glowflicker_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_08_whitesmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_10_dark_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_11_lines_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_12_groundglow_emit.bp',
        },
        FxImpactProp = {
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_01_groundflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_02_cameraflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_04_plasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_06_ring_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_07_glowflicker_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_08_whitesmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_10_dark_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_11_lines_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_12_groundglow_emit.bp',
        },
        FxImpactLand = {
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_01_groundflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_02_cameraflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_04_plasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_06_ring_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_07_glowflicker_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_08_whitesmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_10_dark_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_11_lines_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_12_groundglow_emit.bp',
        },
        FxImpactWater = {
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_01_groundflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_02_cameraflash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_04_plasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_06_ring_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_07_glowflicker_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_08_whitesmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_10_dark_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_11_lines_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_can01_i_u_12_groundglow_emit.bp',
        },

    FxTrailScale = 0.5,
    FxPropHitScale = 0.5,
    FxShieldHitScale = 0.5,
    FxLandHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,

}
TypeClass = IChronCannon02