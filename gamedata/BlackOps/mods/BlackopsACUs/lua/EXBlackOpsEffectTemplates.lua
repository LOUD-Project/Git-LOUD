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
EXBlackopsBpPath = '/mods/BlackopsACUs/effects/emitters/'

#------------------------------------------------------------------------
#  UEF ACU Flame Thrower
#------------------------------------------------------------------------
FlameThrowerHitLand01 = {
    EXBlackopsBpPath .. 'exflamer_flash_emit.bp',
    EXBlackopsBpPath .. 'exflamer_thick_smoke_emit.bp',
    EXBlackopsBpPath .. 'exflamer_thin_smoke_emit.bp',
    EXBlackopsBpPath .. 'exflamer_01_emit.bp',
    EXBlackopsBpPath .. 'exflamer_02_emit.bp',
    EXBlackopsBpPath .. 'exflamer_03_emit.bp',
}
FlameThrowerHitWater01 = {
    EXBlackopsBpPath .. 'exflamer_waterflash_emit.bp',
    EXBlackopsBpPath .. 'exflamer_water_smoke_emit.bp',
    EXBlackopsBpPath .. 'exflamer_oilslick_emit.bp',
    EXBlackopsBpPath .. 'exflamer_lines_emit.bp',
    EXBlackopsBpPath .. 'exflamer_water_ripples_emit.bp',
    EXBlackopsBpPath .. 'exflamer_water_dots_emit.bp',    
}

#------------------------------------------------------------------------
#  UEF ACU Anti Matter Cannon
#------------------------------------------------------------------------
ACUAntiMatterPoly = {
    EXBlackopsBpPath .. 'examc_polytrail_01_emit.bp',

}
ACUAntiMatterFx = {
    EXBlackopsBpPath .. 'examc_fxtrail_01_emit.bp',
    EXBlackopsBpPath .. 'examc_fxtrail_02_emit.bp',
    EXBlackopsBpPath .. 'examc_fxtrail_03_emit.bp',
    EXBlackopsBpPath .. 'examc_fxtrail_04_emit.bp',
    EXBlackopsBpPath .. 'examc_fxtrail_05_emit.bp',
}
ACUAntiMatterMuzzle = {
    EXBlackopsBpPath .. 'examc_muzzle_flash_01_emit.bp',
    EXBlackopsBpPath .. 'examc_muzzle_flash_02_emit.bp',
    EXBlackopsBpPath .. 'examc_muzzle_flash_03_emit.bp',
    EXBlackopsBpPath .. 'examc_muzzle_flash_04_emit.bp',
    EXBlackopsBpPath .. 'examc_muzzle_flash_05_emit.bp',
    EXBlackopsBpPath .. 'examc_muzzle_flash_06_emit.bp',
    EXBlackopsBpPath .. 'examc_muzzle_flash_07_emit.bp',
}
ACUAntiMatter01 = {
    EXBlackopsBpPath .. 'examc_flash_01_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_01_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_02_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_03_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_04_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_05_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_07_emit.bp',
    EXBlackopsBpPath .. 'examc_hit_08_emit.bp',
    EXBlackopsBpPath .. 'examc_ring_01_emit.bp',
    EXBlackopsBpPath .. 'examc_ring_02_emit.bp',
    EXBlackopsBpPath .. 'examc_ring_03_emit.bp',
    EXBlackopsBpPath .. 'examc_ring_04_emit.bp',
    EXBlackopsBpPath .. 'examc_shoackwave_01_emit.bp',

}

#------------------------------------------------------------------------
#  UEF ACU Gattling Cannon
#------------------------------------------------------------------------

UEFACUHeavyPlasmaGatlingCannonMuzzleFlash = {
    EmtBpPath .. 'heavy_plasma_gatling_cannon_laser_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'heavy_plasma_gatling_cannon_laser_muzzle_flash_02_emit.bp',
    EmtBpPath .. 'heavy_plasma_gatling_cannon_laser_muzzle_flash_03_emit.bp',
    EmtBpPath .. 'heavy_plasma_gatling_cannon_laser_muzzle_flash_05_emit.bp',
    EmtBpPath .. 'heavy_plasma_gatling_cannon_laser_muzzle_flash_06_emit.bp',
}

#------------------------------------------------------------------------
#  Serephim Quantum Storm
#------------------------------------------------------------------------
SeraACUQuantumStormProjectileHit01 = {
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_01_emit.bp',#small blue flash
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_02_emit.bp', #flash
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_03_emit.bp',  #shockwave
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_04_emit.bp',#dark glow
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_05_emit.bp',#blue glow
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_06_emit.bp',#blue shockwave
    EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_07_emit.bp',#blue Spikes
	EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_08_emit.bp',#dark mist
	EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_09_emit.bp',#blue sparks
	EXBlackopsBpPath .. 'seraphim_experimental_phasonproj_hit_10_emit.bp',#lightning
}

SeraACUQuantumStormProjectileHit02 = {
    EmtBpPath .. 'seraphim_experimental_phasonproj_hitunit_01_emit.bp',
	EmtBpPath .. 'seraphim_experimental_phasonproj_hitunit_08_emit.bp',
}

SeraACUQuantumStormProjectileHitUnit = TableCat( SeraACUQuantumStormProjectileHit01, SeraACUQuantumStormProjectileHit02 )

#------------------------------------------------------------------------
#  Serephim Rapid Cannon
#------------------------------------------------------------------------
SeraACURapidCannonPoly = {
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_01_emit.bp',
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_02_emit.bp',
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_03_emit.bp',
}

SeraACURapidCannonPoly02 = {
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_04_emit.bp',
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_05_emit.bp',
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_06_emit.bp',
}

SeraACURapidCannonPoly03 = {
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_07_emit.bp',
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_08_emit.bp',
    EXBlackopsBpPath .. 'seraphim_aireau_autocannon_polytrail_09_emit.bp',
}

#------------------------------------------------------------------------
#  Cybran EMP Array
#------------------------------------------------------------------------
CybranACUEMPArrayHit01 = {
    EXBlackopsBpPath .. 'exemp_flash_01_emit.bp',
    EXBlackopsBpPath .. 'exemp_flash_02_emit.bp',
    EXBlackopsBpPath .. 'exemp_flash_03_emit.bp',
    EXBlackopsBpPath .. 'exemp_hit_01_emit.bp',
    EXBlackopsBpPath .. 'exemp_hit_02_emit.bp',
    EXBlackopsBpPath .. 'exemp_hit_03_emit.bp',
    EXBlackopsBpPath .. 'exemp_hit_04_emit.bp',
    EXBlackopsBpPath .. 'exemp_hit_05_emit.bp',
    EXBlackopsBpPath .. 'exemp_hit_06_emit.bp',
    EXBlackopsBpPath .. 'exemp_implosion_01_emit.bp',
    EXBlackopsBpPath .. 'exemp_shockwave_01_emit.bp',
    EXBlackopsBpPath .. 'exemp_shockwave_02_emit.bp',
    EXBlackopsBpPath .. 'exemp_shockwave_03_emit.bp',
    EXBlackopsBpPath .. 'exemp_shockwave_07_emit.bp',
}

CybranACUEMPArrayHit02 = {
    EXBlackopsBpPath .. 'exemp_shockwave_04_emit.bp',
    EXBlackopsBpPath .. 'exemp_shockwave_05_emit.bp',
}

#------------------------------------------------------------------------
#  Seraphim Overcharge Projectile
#------------------------------------------------------------------------
OmegaOverChargeProjectileTrails = {
	EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_emit.bp',#swigly#
	EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_01_emit.bp',# other swigly
	EmtBpPath .. 'seraphim_chronotron_cannon_overcharge_projectile_02_emit.bp',#main Swigly
}
OmegaOverChargeProjectileFxTrails = {
    EXBlackopsBpPath .. 'omega_overcharge_projectile_fxtrail_01_emit.bp',#twisty
    EXBlackopsBpPath .. 'omega_overcharge_projectile_fxtrail_02_emit.bp',# other twisty
    EXBlackopsBpPath .. 'omega_overcharge_projectile_fxtrail_03_emit.bp',
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

#------------------------------------------------------------------------
#  UEF Gatling Projectiles
#------------------------------------------------------------------------
UEFHeavyPlasmaGatlingCannon03PolyTrail = EXBlackopsBpPath .. 'exgc_l1upgrade_polytrail_01_emit.bp'

UEFHeavyPlasmaGatlingCannon01PolyTrail = EXBlackopsBpPath .. 'exgc_l2upgrade_polytrail_01_emit.bp'

UEFHeavyPlasmaGatlingCannon02PolyTrail = EXBlackopsBpPath .. 'exgc_l3upgrade_polytrail_01_emit.bp'

#------------------------------------------------------------------------
#  Lambda Effects
#------------------------------------------------------------------------
EXLambdaRedirector = {
    EXBlackopsBpPath .. 'lambda_distortion_01.bp',
    EXBlackopsBpPath .. 'lambda_redirect_bright_01.bp',
    EXBlackopsBpPath .. 'lambda_redirect_bright_01.bp',
    EXBlackopsBpPath .. 'lambda_redirect_bright_02.bp',
    EXBlackopsBpPath .. 'lambda_redirect_bright_02.bp',
    EXBlackopsBpPath .. 'lambda_redirect_bright_03.bp',
    EXBlackopsBpPath .. 'lambda_distortion_01.bp',
}

EXLambdaDestoyer = {
    EXBlackopsBpPath .. 'lambda_distortion_01.bp',
    EXBlackopsBpPath .. 'lambda_destroy_dark_01.bp',
    EXBlackopsBpPath .. 'lambda_destroy_dark_02.bp',
    #EXBlackopsBpPath .. 'lambda_destroy_dark_03a.bp',
    EXBlackopsBpPath .. 'lambda_destroy_dark_03b.bp',
    EXBlackopsBpPath .. 'lambda_destroy_dark_04.bp',
    EXBlackopsBpPath .. 'lambda_destroy_bright_01.bp',
    EXBlackopsBpPath .. 'lambda_destroy_bright_01.bp',
    EXBlackopsBpPath .. 'lambda_distortion_01.bp',
}

#-----------------------------
#   UEF Cruise Missile 01
#-----------------------------
UEFCruiseMissile01Trails = {
    EmtBpPath .. 'missile_sam_munition_trail_01_emit.bp',
    #EmtBpPath .. 'missile_sam_munition_trail_01_emit.bp',
    #EmtBpPath .. 'nuke_munition_launch_trail_04_emit.bp',
    #EmtBpPath .. 'nuke_munition_launch_trail_06_emit.bp',
    #EmtBpPath .. 'missile_munition_trail_01_emit.bp',
    EmtBpPath .. 'missile_munition_trail_02_emit.bp',
    #EmtBpPath .. 'missile_smoke_exhaust_02_emit.bp',
}

#-----------------------------
#   Sat Death
#-----------------------------
SatDeathSmoke = { EXBlackopsBpPath .. 'sat_death_smoke_emit.bp',}
SatDamageFire01 = {
	EmtBpPath .. 'destruction_damaged_fire_01_emit.bp',
	EmtBpPath .. 'destruction_damaged_fire_distort_01_emit.bp',
}
SatDeathEffectsPackage = TableCat( SatDeathSmoke, SatDamageFire01 )
