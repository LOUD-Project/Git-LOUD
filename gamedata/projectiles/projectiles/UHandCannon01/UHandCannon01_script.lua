-----------------------------------------------------------------------------
--  File     :  /projectiles/uhandcannon01/uhandcannon01_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist
--  Summary  :  SC2 UEF Hand Cannon: UHandCannon01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/DefaultProjectiles.lua').EmitterProjectile

UHandCannon01 = Class(Projectile) { 
	FxImpactTrajectoryAligned = true,
	
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(13,18)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', 'Albedo', scale, scale, 150, 15, self:GetArmy(), 5)
		end	 
		Projectile.OnImpact( self, TargetType, targetEntity )
    end,
	
	FxTrails = {
		'/effects/emitters/weapons/uef/handcannon01/projectile/w_u_hcn01_p_01_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/projectile/w_u_hcn01_p_02_brightglow_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/projectile/w_u_hcn01_p_06_glow_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/projectile/w_u_hcn01_p_08_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/projectile/w_u_hcn01_p_09_smoketrail_emit.bp',
	},
	
	FxImpactProp = {
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_01_flashflat_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_02_glow_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_03_glowhalf_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_04_sparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_05_halfring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_06_ring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_07_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_08_fwdsparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_09_leftoverglows_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_10_leftoverwisps_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_11_darkring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_12_fwdsmoke_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_13_debris_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_14_lines_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_15_fastdirt_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_16_distortring_emit.bp',
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
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_01_flashflat_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_02_glow_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_03_glowhalf_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_04_sparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_05_halfring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_06_ring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_07_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_08_fwdsparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_09_leftoverglows_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_10_leftoverwisps_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_11_darkring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_12_fwdsmoke_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_13_debris_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_14_lines_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_15_fastdirt_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_16_distortring_emit.bp',
	},
	FxImpactUnit = {
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_01_flashflat_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_02_glow_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_03_glowhalf_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_04_sparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_05_halfring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_06_ring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_07_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_08_fwdsparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_09_leftoverglows_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_10_leftoverwisps_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_11_darkring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_12_fwdsmoke_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_13_debris_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_14_lines_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_15_fastdirt_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_16_distortring_emit.bp',
	},
	FxImpactUnitAir = {
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_01_flashflat_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_02_glow_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_03_glowhalf_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_04_sparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_05_halfring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_06_ring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_07_firecloud_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_08_fwdsparks_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_09_leftoverglows_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_10_leftoverwisps_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_11_darkring_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_12_fwdsmoke_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_13_debris_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_14_lines_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_15_fastdirt_emit.bp',
		'/effects/emitters/weapons/uef/handcannon01/impact/unit/w_u_hcn01_i_u_16_distortring_emit.bp',
	},
	FxImpactWater = {
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_01_flatflash_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_02_flatripple_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_03_shockwave_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_04_splash_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_05_firecore_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_06_waterspray_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_07_mist_emit.bp',
		'/effects/emitters/weapons/generic/water01/large01/impact/w_g_wat01_l_i_08_leftover_emit.bp',
	},
    FxTrailsScale = 0.6,
    FxPropHitScale = 0.6,
    FxShieldHitScale = 0.6,
    FxLandHitScale = 0.6,
    FxUnitHitScale = 0.6,
    FxWaterHitScale = 0.6,

}
TypeClass = UHandCannon01