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

BPPPlasmaPPCProjMuzzleFlash = {
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_flash_02_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_flash_03_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_flash_04_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_flash_05_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_flash_06_emit.bp',
    EmtBpPathAlt .. 'PPC_charge_test_01_emit.bp',
}

BPPPlasmaPPCProjChargeMuzzleFlash = {
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_charge_01_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_charge_02_emit.bp',
    EmtBpPath .. 'seraphim_experimental_phasonproj_muzzle_charge_03_emit.bp',
}

UDisruptorArtillery01MuzzleFlash = {
	EmtBpPathAlt .. 'w_u_dra01_l_01_flash_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_02_flashline_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_03_sparks_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_04_plasma_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_05_sideplasma_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_06_flashdetail_emit.bp',
	EmtBpPathAlt .. 'w_u_dra01_l_07_column_emit.bp',	
}

CybranFlameThrowerMuzzleFlash = {
	EmtBpPathAlt ..  'w_c_fthr01_l_01_glow_emit.bp',
	EmtBpPathAlt ..  'w_c_fthr01_l_02_firewisps_emit.bp',
	EmtBpPathAlt ..  'w_c_fthr01_l_03_flatglow_emit.bp',
	EmtBpPathAlt ..  'w_c_fthr01_l_04_sparks_emit.bp',
	EmtBpPathAlt ..  'w_c_fthr01_l_05_right_firewisps_emit.bp',
	EmtBpPathAlt ..  'w_c_fthr01_l_06_left_firewisps_emit.bp',
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
	EmtBpPath .. 'hvyproton_cannon_hit_02_emit.bp',
	EmtBpPathAlt .. 'tm_kamibomb_hit_08_emit.bp', ## White inner ring
}
