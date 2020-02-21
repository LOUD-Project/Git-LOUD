#****************************************************************************
#**
#**  File     :  /data/lua/EffectTemplates.lua
#**  Author(s):  Gordon Duclos, Greg Kohne, Matt Vainio, Aaron Lundquist
#**
#**  Summary  :  Generic templates for commonly used effects
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
TableCat = import('/lua/utilities.lua').TableCat
EmtBpPath = '/effects/emitters/'
EmitterTempEmtBpPath = '/effects/emitters/temp/'
local EffectTemplate = import('/lua/EffectTemplates.lua')

EmtBpPathAlt = '/mods/BattlePack/effects/emitters/'

CChronoDampener = {
    EmtBpPathAlt .. 'cybran_chrono_dampener_01_emit.bp',
    EmtBpPathAlt .. 'cybran_chrono_dampener_02_emit.bp',
    EmtBpPathAlt .. 'cybran_chrono_dampener_03_emit.bp',
    EmtBpPathAlt .. 'cybran_chrono_dampener_04_emit.bp',
}

AHighIntensityLaserHitMK2 = {
    EmtBpPathAlt .. 'RedLaser_Emitter01.bp',
    EmtBpPathAlt .. 'RedLaser_Emitter02.bp',
    EmtBpPathAlt .. 'RedLaser_Emitter03.bp',
}

AHighIntensityLaserHitMK3 = {
    EmtBpPathAlt .. 'PinkLaser_Emitter01.bp',
    EmtBpPathAlt .. 'PinkLaser_Emitter02.bp',
    EmtBpPathAlt .. 'PinkLaser_Emitter03.bp',
}

AHighIntensityLaserFlashMK2   = {
    EmtBpPathAlt .. 'redaeon_laser_highintensity_flash_02_emit.bp',
}

AHighIntensityLaserFlashMK3   = {
    EmtBpPathAlt .. 'pinkaeon_laser_highintensity_flash_02_emit.bp',
}


ODisintegratorFxTrails01 = {
	EmtBpPathAlt .. 'EXPCannon_fxtrail_01_emit.bp'
}

OmegaOverChargeProjectileTrails = {
	EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_emit.bp',#swigly#
	EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_01_emit.bp',# other swigly
	EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_02_emit.bp',#main Swigly
}
OmegaOverChargeProjectileFxTrails = {
    EmtBpPathAlt .. 'omega_overcharge_projectile_fxtrail_01_emit.bp',#twisty
    EmtBpPathAlt .. 'omega_overcharge_projectile_fxtrail_02_emit.bp',# other twisty
    EmtBpPathAlt .. 'omega_overcharge_projectile_fxtrail_03_emit.bp',
}
OmegaOverChargeLandHit = {
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_01_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_02_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_03_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_04_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_projectile_hit_04_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_projectile_hit_05_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_projectile_hit_06_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_blast_projectile_hit_01_emit.bp',                  
    EmtBpPath .. 'seraphim_chronotron_cannon_blast_projectile_hit_02_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_blast_projectile_hit_03_emit.bp',
}
OmegaOverChargeUnitHit = {
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_01_emit.bp',#swigly flash
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_02_emit.bp',#dot
    EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_hit_04_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_projectile_hit_05_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_blast_projectile_hit_01_emit.bp',                  
    EmtBpPath .. 'seraphim_chronotron_cannon_blast_projectile_hit_02_emit.bp',
    EmtBpPath .. 'seraphim_chronotron_cannon_blast_projectile_hit_03_emit.bp',
}

ExWifeMainPolyTrail =  EmtBpPathAlt .. 'ExWifeMaincannon_polytrail_01_emit.bp'
ExWifeMainFXTrail01 =  { EmtBpPathAlt .. 'ExWifeMaincannon_fxtrail_01_emit.bp' }
ExWifeMainHitUnit = {
	EmtBpPathAlt .. 'ExWifeMaincannon_hitunit_01_emit.bp',
	EmtBpPathAlt .. 'ExWifeMaincannon_hit_02_emit.bp', 
	EmtBpPathAlt .. 'ExWifeMaincannon_hit_03_emit.bp',  
	EmtBpPathAlt .. 'ExWifeMaincannon_hitunit_04_emit.bp', #shockj effect
	EmtBpPathAlt .. 'ExWifeMaincannon_hitunit_05_emit.bp',  #shock effect
	EmtBpPathAlt .. 'ExWifeMaincannon_hitunit_06_emit.bp', 
	EmtBpPathAlt .. 'ExWifeMaincannon_hitunit_07_emit.bp',
	EmtBpPathAlt .. 'ExWifeMaincannon_hit_08_emit.bp',
	EmtBpPathAlt .. 'ExWifeMaincannon_hit_09_emit.bp',
	EmtBpPathAlt .. 'ExWifeMaincannon_hit_10_emit.bp',
	EmtBpPathAlt .. 'ExWifeMaincannon_hit_distort_emit.bp',
} 

#------------------------------------------------------------------------
#  NOMAD PLASMAFLAMETHROWER-EMITTERS
#------------------------------------------------------------------------


NPlasmaFlameThrowerHitLand01 = {
    EmtBpPathAlt .. 'plasmaflame_flash_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_thick_smoke_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_thin_smoke_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_01_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_02_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_03_emit.bp',
}
NPlasmaFlameThrowerHitWater01 = {
    EmtBpPathAlt .. 'plasmaflame_waterflash_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_water_smoke_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_oilslick_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_lines_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_water_ripples_emit.bp',
    EmtBpPathAlt .. 'plasmaflame_water_dots_emit.bp',    
}

FlameThrowerHitLand01 = {
    EmtBpPathAlt .. 'exflamer_flash_emit.bp',
    EmtBpPathAlt .. 'exflamer_thick_smoke_emit.bp',
    EmtBpPathAlt .. 'exflamer_thin_smoke_emit.bp',
    EmtBpPathAlt .. 'exflamer_01_emit.bp',
    EmtBpPathAlt .. 'exflamer_02_emit.bp',
    EmtBpPathAlt .. 'exflamer_03_emit.bp',
}
FlameThrowerHitWater01 = {
    EmtBpPathAlt .. 'exflamer_waterflash_emit.bp',
    EmtBpPathAlt .. 'exflamer_water_smoke_emit.bp',
    EmtBpPathAlt .. 'exflamer_oilslick_emit.bp',
    EmtBpPathAlt .. 'exflamer_lines_emit.bp',
    EmtBpPathAlt .. 'exflamer_water_ripples_emit.bp',
    EmtBpPathAlt .. 'exflamer_water_dots_emit.bp',    
}

#------------------------------------------------------------------------

SHeavyQuarnonCannonProjectilePolyTrails = {
    EmtBpPathAlt .. 'PPC_projectile_trail_01_emit.bp',
    EmtBpPathAlt .. 'PPC_projectile_trail_02_emit.bp',
    EmtBpPathAlt .. 'PPC_projectile_trail_03_emit.bp',
}

SHeavyQuarnonCannonProjectileFxTrails = {
    EmtBpPathAlt .. 'PPC_fxtrail_01_emit1.bp',
}

AeonNocaCatBlueLaserHit = {
    EmtBpPath .. 'oblivion_cannon_hit_05_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_06_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_07_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_08_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_09_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_10_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_11_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_12_emit.bp',
    EmtBpPath .. 'oblivion_cannon_hit_13_emit.bp',
    EmtBpPath .. 'cybran_corsair_missile_hit_ring.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_01_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_02_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_03_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_04_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_05_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_06_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_07_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_08_emit.bp',
    EmtBpPath .. 'seraphim_khu_anti_nuke_hit_09_emit.bp',
	EmtBpPath .. 'seraphim_heavyquarnon_cannon_frontal_glow_01_emit.bp',
}

AeonNovaCatFireEffect01 = {
    EmtBpPath .. 'disintegratorhvy_hit_sparks_01_emit.bp',
    EmtBpPath .. 'cybran_corsair_missile_hit_ring.bp',
}

UefT3BattletankRocketHit = {
	EmtBpPathAlt .. 'gauss_cannon_hit_01a_emit.bp',
	EmtBpPathAlt .. 'gauss_cannon_hit_02a_emit.bp',
	EmtBpPathAlt .. 'gauss_cannon_hit_02b_emit.bp',
	EmtBpPathAlt .. 'landgauss_cannon_hit_02a_emit.bp',
	EmtBpPathAlt .. 'landgauss_cannon_hit_03a_emit.bp',
	EmtBpPathAlt .. 'landgauss_cannon_hit_04a_emit.bp',
	EmtBpPathAlt .. 'ueft3rocket_01_emit.bp',
	EmtBpPathAlt .. 'ueft3rocket_02_emit.bp',
	EmtBpPathAlt .. 'ueft3rocket_03_emit.bp',
	EmtBpPathAlt .. 'ueft3rocket_04_emit.bp',
	EmtBpPathAlt .. 'ueft3rocket_05_emit.bp',
	EmtBpPathAlt .. 'ueft3rocket_06_emit.bp',
}

NPlasmaProjectileMuzzleFlash = {
    	EmtBpPathAlt .. 'plasmaprojectile_muzzle_flash_01_emit.bp',
        EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
	EmtBpPathAlt .. 'plasmaprojectile_hitunit_05_emit.bp',
}

NPlasmaProjectilePolyTrails = {
	EmtBpPathAlt .. 'plasmaprojectile_polytrail_02_emit.bp',
}

NPlasmaProjectileHit02 = {
    EmtBpPathAlt .. 'plasmaprojectile_hit_01_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_hit_02_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_hit_03_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_hit_04_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_hit_05_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_hitunit_05_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_glow_emit.bp',
}
NPlasmaProjectileShieldHit01 = {
    EmtBpPathAlt .. 'plasmaprojectile_hit_03_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_hitunit_05_emit.bp',
    EmtBpPathAlt .. 'plasmaprojectile_glow_emit.bp',
}
NPlasmaProjectileHit03 = {
    EmtBpPathAlt .. 'plasmaprojectile_hitunit_05_emit.bp',
}
NPlasmaProjectileHit04 = {
    EmtBpPathAlt .. 'plasmaprojectile_hitunit_05_emit.bp',
}
NPlasmaProjectileHit01 = TableCat( NPlasmaProjectileHit02, NPlasmaProjectileHit03, NPlasmaProjectileMuzzleFlash )
NPlasmaProjectileHitUnit01 = TableCat( NPlasmaProjectileHit02, NPlasmaProjectileHit04, EffectTemplate.UnitHitShrapnel01 )

#------------------------------------------------------------------------
#  NOMAD FUSION MISSILE EMITTERS
#------------------------------------------------------------------------
NFusionMissileHit01 = {
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_01_emit.bp',
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_02_emit.bp',
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_03_emit.bp',
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_04_emit.bp',
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_concussion_emit.bp',
}

NFusionMissileHit02 = {
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_01_emit.bp',
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_02_emit.bp',
    EmtBpPathAlt .. 'nomad_fusionrocket_hit_03_emit.bp',
}

NFusionMissileParticleTrail = {
	EmtBpPathAlt .. 'nomad_fusionrocket_trail_01_emit.bp', # Red flames
	}

BPPPlasmaPPCProjMuzzleFlash = {
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_flash_01_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_flash_02_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_flash_03_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_flash_04_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_flash_05_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_flash_06_emit.bp',
    EmtBpPathAlt .. 'PPC_charge_test_01_emit.bp',
}

BPPPlasmaPPCProjChargeMuzzleFlash = {
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_charge_01_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_charge_02_emit.bp',
    EmtBpPathAlt .. 'seraphim_experimental_phasonproj_muzzle_charge_03_emit.bp',
}


#------------------------------------------------------------------------
#  GRAVITY CANNON EFFECTS
#------------------------------------------------------------------------
GravityCannonFxTrail = {
    EmtBpPathAlt .. 'Gravity_cannon_projectile_fxtrail_01_emit.bp',
    EmtBpPathAlt .. 'Gravity_cannon_projectile_fxtrail_04_emit.bp',
    EmtBpPathAlt .. 'Gravity_cannon_projectile_fxtrail_05_emit.bp',
}

GravityCannonPolyTrail = {
    EmtBpPathAlt .. 'Gravity_cannon_projectile_polytrail_03_emit.bp',
}


#------------------------------------------------------------------------
#  STINGRAY CANNON EFFECTS
#------------------------------------------------------------------------
NStingrayPolyTrail = {
    EmtBpPathAlt .. 'stingray_polytrail_01_emit.bp',
    EmtBpPathAlt .. 'stingray_polytrail_02_emit.bp',    
}

NStingrayFXTrail = {
	EmtBpPathAlt .. 'stingray_ring_01_emit.bp',
	
}

NStingrayHit01 = {
    EmtBpPathAlt .. 'stingray_hit_01_emit.bp',
    EmtBpPathAlt .. 'stingray_hit_02_emit.bp',
    EmtBpPathAlt .. 'stingray_hit_03_emit.bp', 
    EmtBpPathAlt .. 'stingray_hit_04_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
}

NStingrayCannonFlash = {
    EmtBpPath .. 'gauss_cannon_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'gauss_cannon_muzzle_flash_02_emit.bp',
    EmtBpPathAlt .. 'stingray_muzzle_01_emit.bp',
    EmtBpPathAlt .. 'stingray_muzzle_02_emit.bp',
	EmtBpPathAlt .. 'stingray_muzzle_03_emit.bp',
   # EmtBpPath .. 'gauss_cannon_muzzle_smoke_02_emit.bp',
   # EmtBpPath .. 'cannon_muzzle_smoke_09_emit.bp', 
}

#------------------------------------------------------------------------
#  STINGRAY2 CANNON EFFECTS
#------------------------------------------------------------------------
NStingray2PolyTrail = {
    EmtBpPathAlt .. 'stingray2_polytrail_01_emit.bp',
    EmtBpPathAlt .. 'stingray2_polytrail_02_emit.bp',    
}

NStingray2FXTrail = {
	EmtBpPathAlt .. 'stingray2_ring_01_emit.bp',
	
}

#------------------------------------------------------------------------
#  SC2 FB2 Cannon
#------------------------------------------------------------------------
UDisruptorArtillery01MuzzleFlash = {
	EmtBpPathAlt .. 'w_u_dra01_l_01_flash_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_02_flashline_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_03_sparks_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_04_plasma_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_05_sideplasma_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_06_flashdetail_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_07_column_emit.bp',	
}

Reload01 = {
	EmtBpPathAlt .. 'uux0115_amb_01_reload_emit.bp',
}

SC2UEFACUFxtrail01 = {
          EmtBpPathAlt ..   'w_u_hvg01_p_01_smoke_emit.bp',
          EmtBpPathAlt ..   'w_u_hvg01_p_04_wisps_emit.bp',
          EmtBpPathAlt ..   'w_u_hvg01_p_05_glow_emit.bp',
        }
		
SC2UEFACUPolytrail01 = {
           EmtBpPathAlt ..  'w_u_hvg01_p_03_polytrail_emit.bp',
        }

SC2UEFACUHitUnit02 = {
           EmtBpPathAlt ..  'w_u_hvg01_i_u_01_flatflash_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_02_flash_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_03_sparks_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_04_halfring_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_05_ring_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_06_firecloud_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_07_fwdsparks_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_08_leftoverglows_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_09_leftoverwisps_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_10_fwdsmoke_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_11_debris_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_12_lines_emit.bp',
           EmtBpPathAlt ..  'w_u_hvg01_i_u_13_leftoversmoke_emit.bp',
        }
		
SC2ACUMuzzleFlash = {
            EmtBpPathAlt ..  'w_u_hvg01_l_01_flash_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_02_largeflash_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_03_firecloud_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_04_shockwave_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_05_flashline_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_06_leftoverplasma_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_07_leftoversmoke_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_08_inwardfirecloud_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_09_sparks_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_10_flashdetail_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_11_dots_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_12_flareflash_emit.bp',
            EmtBpPathAlt ..  'w_u_hvg01_l_13_leftoverline_emit.bp',
        }
		
SC2DisruptorMuzzleFlash02 = {
			EmtBpPathAlt ..  'w_i_pla05_l_01_flash_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_02_flashline_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_03_flashlong_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_04_endflash_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_05_plasmaflash_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_06_sparkle_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_09_distortring_emit.bp',
}

SC2DisruptorChargeMuzzleFlash02 = {
			EmtBpPathAlt ..  'w_i_pla05_l_07_preplasma_emit.bp',
			EmtBpPathAlt ..  'w_i_pla05_l_08_preglow_emit.bp',
}

CybranFlameThrowerMuzzleFlash = {
						EmtBpPathAlt ..  'w_c_fthr01_l_01_glow_emit.bp',
						EmtBpPathAlt ..  'w_c_fthr01_l_02_firewisps_emit.bp',
						EmtBpPathAlt ..  'w_c_fthr01_l_03_flatglow_emit.bp',
						EmtBpPathAlt ..  'w_c_fthr01_l_04_sparks_emit.bp',
						EmtBpPathAlt ..  'w_c_fthr01_l_05_right_firewisps_emit.bp',
						EmtBpPathAlt ..  'w_c_fthr01_l_06_left_firewisps_emit.bp',
}

CybranT2BattleTankHit = {
    EmtBpPathAlt .. 'tmcybrant2battletankhit_distort_emit.bp',
    EmtBpPathAlt .. 'tmcybrant2battletankhit_01_emit.bp', ## Exploding flames
	EmtBpPathAlt .. 'tmcybrant2battletankhit_02_emit.bp', ## Red glow
	EmtBpPathAlt .. 'tmcybrant2battletankhit_03_emit.bp', ## white sparks flying opposite direction of impact
	EmtBpPathAlt .. 'tmcybrant2battletankhit_04_emit.bp', ## dirt flying
	EmtBpPathAlt .. 'tmcybrant2battletankhit_05_emit.bp', ## ring
	EmtBpPathAlt .. 'tmcybrant2battletankhit_06_emit.bp', ## white glow in middle
	EmtBpPathAlt .. 'tmcybrant2battletankhit_07_emit.bp', ## black dots on ground
	EmtBpPathAlt .. 'tmcybrant2battletankhit_08_emit.bp', ## white exploding glow in middle
	EmtBpPathAlt .. 'tmcybrant2battletankhit_09_emit.bp', ## black exploding dots in middle
}

CannonGunShells = {
    EmtBpPathAlt .. 'cannon_shells_01_emit.bp',
}

BattleMech2RocketHit = {
    EmtBpPathAlt .. 'bm2rockethit_01_emit.bp',
    EmtBpPathAlt .. 'bm2rockethit_02_emit.bp',
    EmtBpPathAlt .. 'bm2rockethit_03_emit.bp',
    EmtBpPathAlt .. 'bm2rockethit_04_emit.bp',
    EmtBpPathAlt .. 'bm2rockethit_05_emit.bp',
	EmtBpPathAlt .. 'bm2rockethit_06_emit.bp', ## ring
	EmtBpPathAlt .. 'bm2rockethit_07_emit.bp', ## Ring effect
	EmtBpPathAlt .. 'bm2rockethit_08_emit.bp', ## Yellow Afterglow
	EmtBpPathAlt .. 'bm2rockethit_09_emit.bp', ## Red glow explosion with smoke
	EmtBpPathAlt .. 'bm2rockethit_10_emit.bp', ## Exploding flames
	EmtBpPathAlt .. 'bm2rockethit_11_emit.bp', ## Cool exploding flames!!!
    EmtBpPathAlt .. 'bm2rockethit_12_emit.bp', ## white glow
	EmtBpPathAlt .. 'tm_kamibomb_hit_05_emit.bp', ## Red glow
	EmtBpPathAlt .. 'tmcybrant2battletankhit_07_emit.bp', ## black dots on ground
	EmtBpPathAlt .. 'hvyproton_cannon_hit_02_emit.bp',
    EmtBpPathAlt .. 'tmcybrant3battletankhit_distort_emit.bp',
	EmtBpPathAlt .. 'tm_kamibomb_hit_08_emit.bp', ## White inner ring


}

	-------------------------------------------------------------------------
	--  TERRAN MAGMA CANNON EMITTERS:  Hacked by Ebola Soup for Magma Cannon from Ionized Plasma Gatling Cannon
	-------------------------------------------------------------------------
	TMagmaCannonHit01 = { 
	    EmtBpPath .. 'napalm_hvy_thick_smoke_emit.bp',
	    EmtBpPath .. 'napalm_hvy_01_emit.bp',
	    EmtBpPathAlt .. 'balrog_proton_bomb_hit_01_emit.bp',
	    EmtBpPathAlt .. 'balrog_antimatter_hit_01_emit.bp',		
	    EmtBpPath .. 'antimatter_hit_02_emit.bp',	    	     
	    EmtBpPathAlt .. 'balrog_antimatter_hit_06_emit.bp',	
	    EmtBpPath .. 'antimatter_hit_07_emit.bp',	    
	    EmtBpPath .. 'antimatter_hit_09_emit.bp',	     
	    EmtBpPath .. 'antimatter_hit_11_emit.bp',	    
	    EmtBpPath .. 'antimatter_ring_04_emit.bp',	    	
	}
	TMagmaCannonHit02 = { 
	    EmtBpPath .. 'antimatter_hit_09_emit.bp',	   
	}
	TMagmaCannonHit03 = { 
	    EmtBpPath .. 'antimatter_hit_03_emit.bp', 	
	    EmtBpPath .. 'explosion_fire_sparks_01_emit.bp',
	    EmtBpPath .. 'flash_01_emit.bp',
	    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
	}
	TMagmaCannonUnitHit = TableCat( TMagmaCannonHit01, TMagmaCannonHit03 )
	TMagmaCannonHit = TableCat( TMagmaCannonHit01, TMagmaCannonHit02 )
	TMagmaCannonMuzzleFlash = {
	    EmtBpPathAlt .. 'balrog_magma_cannon_muzzle_flash_01_emit.bp',
	    EmtBpPathAlt .. 'balrog_magma_cannon_muzzle_flash_02_emit.bp',
	}
	TMagmaCannonFxTrails = {
	    EmtBpPathAlt .. 'balrog_magma_projectile_fxtrail_01_emit.bp', 
	}
	TMagmaCannonPolyTrails = {
	    EmtBpPathAlt .. 'balrog_missile_smoke_polytrail_01_emit.bp', 
	    EmtBpPathAlt .. 'balrog_missile_smoke_polytrail_02_emit.bp', 
	}
	
#------------------------------------------------------------------------
#  TERRAN PHALANX GUN EMITTERS
#------------------------------------------------------------------------
TPhalanxGunPolyTrails = {
    EmtBpPathAlt .. 'phalanx_munition_polytrail_02_emit.bp',
}