---  /data/lua/EffectTemplates.lua
---  Generic templates for commonly used effects

local TableCat = import('utilities.lua').TableCat

local EmtBpPath = '/effects/emitters/'
local EmitterTempEmtBpPath = '/effects/emitters/temp/'


WeaponSteam01 = { '/effects/emitters/weapon_mist_01_emit.bp', }

-- Concussion Ring Effects
ConcussionRingSml01 = { '/effects/emitters/destruction_explosion_concussion_ring_02_emit.bp',}
ConcussionRingMed01 = { '/effects/emitters/destruction_explosion_concussion_ring_01_emit.bp',}
ConcussionRingLrg01 = { '/effects/emitters/destruction_explosion_concussion_ring_01_emit.bp',}

-- Fire Cloud Effects
FireCloudSml01 = { '/effects/emitters/fire_cloud_05_emit.bp', '/effects/emitters/fire_cloud_04_emit.bp',}
FireCloudMed01 = { '/effects/emitters/fire_cloud_06_emit.bp', '/effects/emitters/explosion_fire_sparks_01_emit.bp',}

-- FireShadow Faked Flat Particle Effects
FireShadowSml01 = { '/effects/emitters/destruction_explosion_fire_shadow_02_emit.bp',}
FireShadowMed01 = { '/effects/emitters/destruction_explosion_fire_shadow_01_emit.bp',}
FireShadowLrg01 = { '/effects/emitters/destruction_explosion_fire_shadow_01_emit.bp',}

-- Flash Effects
FlashSml01 = { '/effects/emitters/flash_01_emit.bp',}

-- Flare Effects
FlareSml01 = { '/effects/emitters/flare_01_emit.bp',}

-- Smoke Effects
SmokeSml01 = { '/effects/emitters/destruction_explosion_smoke_02_emit.bp',}
SmokeMed01 = { '/effects/emitters/destruction_explosion_smoke_04_emit.bp',}
SmokeLrg01 = { '/effects/emitters/destruction_explosion_smoke_07_emit.bp',}

SmokePlumeLightDensityMed01 = { '/effects/emitters/destruction_explosion_smoke_08_emit.bp',}
SmokePlumeMedDensitySml01 = { '/effects/emitters/destruction_explosion_smoke_06_emit.bp',}
SmokePlumeMedDensitySml02 = { '/effects/emitters/destruction_explosion_smoke_05_emit.bp',}
SmokePlumeMedDensitySml03 = { '/effects/emitters/destruction_explosion_smoke_11_emit.bp',}

-- Wreckage Smoke Effects
DefaultWreckageEffectsSml01 = TableCat( SmokePlumeMedDensitySml01, SmokePlumeMedDensitySml02, SmokePlumeMedDensitySml03 ) 
DefaultWreckageEffectsMed01 = TableCat( SmokePlumeLightDensityMed01, SmokePlumeMedDensitySml02, SmokePlumeMedDensitySml03 )
DefaultWreckageEffectsLrg01 = TableCat( SmokePlumeLightDensityMed01, SmokePlumeMedDensitySml02, SmokePlumeMedDensitySml01, SmokePlumeMedDensitySml02, SmokePlumeMedDensitySml03 )

-- Explosion Debris Effects
ExplosionDebrisSml01 = { '/effects/emitters/destruction_explosion_debris_07_emit.bp', '/effects/emitters/destruction_explosion_debris_08_emit.bp',}
ExplosionDebrisMed01 = { '/effects/emitters/destruction_explosion_debris_11_emit.bp', '/effects/emitters/destruction_explosion_debris_12_emit.bp',}
ExplosionDebrisLrg01 = { '/effects/emitters/destruction_explosion_debris_02_emit.bp', '/effects/emitters/destruction_explosion_debris_03_emit.bp',}

-- Explosion Effects
ExplosionEffectsSml01 = TableCat( FireShadowSml01, FlareSml01, FireCloudSml01, ExplosionDebrisSml01 )
ExplosionEffectsMed01 = TableCat( FireShadowMed01, SmokeMed01, FireCloudMed01, ExplosionDebrisMed01 )
ExplosionEffectsLrg01 = TableCat( FireShadowLrg01, SmokeLrg01, ExplosionDebrisLrg01 )

ExplosionEffectsDefault01 = ExplosionEffectsMed01

DefaultHitExplosion01 = TableCat( FireCloudMed01, FlashSml01, FlareSml01, SmokeSml01 )
DefaultHitExplosion02 = TableCat( FireCloudSml01, FlashSml01, FlareSml01, SmokeSml01 )

ExplosionEffectsLrg02 = { '/effects/emitters/destruction_explosion_flash_04_emit.bp', '/effects/emitters/destruction_explosion_flash_05_emit.bp',}

-- Ambient and Weather Effects
WeatherTwister = {
    '/effects/emitters/weather_twister_01_emit.bp',
    '/effects/emitters/weather_twister_02_emit.bp',
    '/effects/emitters/weather_twister_03_emit.bp',
    '/effects/emitters/weather_twister_04_emit.bp',
}

-- Operation Effects
op_cratersmoke_01 = { '/effects/emitters/op_cratersmoke_01_emit.bp',}
op_waterbubbles_01 = { '/effects/emitters/quarry_water_bubbles_emit.bp',}
op_fire_01 = {
    '/effects/emitters/op_ambient_fire_01_emit.bp',
    '/effects/emitters/op_ambient_fire_02_emit.bp',
    '/effects/emitters/op_ambient_fire_03_emit.bp',
    '/effects/emitters/op_ambient_fire_04_emit.bp',
}

-- Default Projectile Impact Effects
DefaultMissileHit01 = TableCat( FireCloudSml01, FlashSml01, FlareSml01 )

DefaultProjectileAirUnitImpact = {
    '/effects/emitters/destruction_unit_hit_flash_01_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
DefaultProjectileLandImpact = {
    '/effects/emitters/projectile_dirt_impact_small_01_emit.bp',
    '/effects/emitters/projectile_dirt_impact_small_02_emit.bp',
    '/effects/emitters/projectile_dirt_impact_small_03_emit.bp',
}
DefaultProjectileLandUnitImpact = {
    '/effects/emitters/destruction_unit_hit_flash_01_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
DefaultProjectileWaterImpact = {
    '/effects/emitters/destruction_water_splash_ripples_01_emit.bp',
    '/effects/emitters/destruction_water_splash_wash_01_emit.bp',
    '/effects/emitters/destruction_water_splash_plume_01_emit.bp',
}
DefaultProjectileUnderWaterImpact = {
    '/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp',
    '/effects/emitters/destruction_underwater_explosion_flash_02_emit.bp',
    '/effects/emitters/destruction_underwater_explosion_splash_01_emit.bp',
}
DustDebrisLand01 = {
    '/effects/emitters/dust_cloud_02_emit.bp',
    '/effects/emitters/dust_cloud_04_emit.bp',
    '/effects/emitters/destruction_explosion_debris_04_emit.bp',
}
GenericDebrisLandImpact01 = {
    '/effects/emitters/dirtchunks_01_emit.bp',
    '/effects/emitters/dust_cloud_05_emit.bp',
}
GenericDebrisTrails01 = { '/effects/emitters/destruction_explosion_debris_trail_01_emit.bp',}

UnitHitShrapnel01 = { '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',}

WaterSplash01 = { 
    '/effects/emitters/water_splash_ripples_ring_01_emit.bp',
    '/effects/emitters/water_splash_plume_01_emit.bp',
}

-- Default Unit Damage Effects
DamageSmoke01 = { '/effects/emitters/destruction_damaged_smoke_01_emit.bp',}
DamageSparks01 = { '/effects/emitters/destruction_damaged_sparks_01_emit.bp',}
DamageFire01 = { '/effects/emitters/destruction_damaged_fire_01_emit.bp', '/effects/emitters/destruction_damaged_fire_distort_01_emit.bp',}
DamageFireSmoke01 = TableCat( DamageSmoke01, DamageFire01 )
DamageStructureSmoke01 = { '/effects/emitters/destruction_damaged_smoke_02_emit.bp',}
DamageStructureFire01 = { '/effects/emitters/destruction_damaged_fire_02_emit.bp', '/effects/emitters/destruction_damaged_fire_03_emit.bp',	'/effects/emitters/destruction_damaged_fire_distort_02_emit.bp',}
DamageStructureSparks01 = { '/effects/emitters/destruction_damaged_sparks_01_emit.bp',}
DamageStructureFireSmoke01 = TableCat( DamageStructureSmoke01, DamageStructureFire01 )

-- Ambient effects
TreeBurning01 = TableCat( DamageFire01 ,{'/effects/emitters/forest_fire_smoke_01_emit.bp'} )

-- Shield Impact effects
AeonShieldHit01 = {	'/effects/emitters/_test_shield_impact_emit.bp',}
CybranShieldHit01 = { '/effects/emitters/_test_shield_impact_emit.bp',}    
UEFShieldHit01 = { '/effects/emitters/_test_shield_impact_emit.bp',}

UEFAntiArtilleryShieldHit01 = {	'/effects/emitters/shield_impact_large_01_emit.bp',}

SeraphimShieldHit01 = {	'/effects/emitters/_test_shield_impact_emit.bp',}

SeraphimSubCommanderGateway01 = { '/effects/emitters/seraphim_gate_01_emit.bp',}
SeraphimSubCommanderGateway02 = { '/effects/emitters/seraphim_gate_04_emit.bp', '/effects/emitters/seraphim_gate_05_emit.bp',}
SeraphimSubCommanderGateway03 = { '/effects/emitters/seraphim_gate_06_emit.bp',}

SeraphimAirStagePlat01 = { '/effects/emitters/seraphim_airstageplat_01_emit.bp',}
SeraphimAirStagePlat02 = { '/effects/emitters/seraphim_airstageplat_02_emit.bp',}

-- Teleport effects
UnitTeleport01 = {
    '/effects/emitters/teleport_ring_01_emit.bp',
    '/effects/emitters/teleport_rising_mist_01_emit.bp',
    '/effects/emitters/_test_commander_gate_explosion_02_emit.bp',
    '/effects/emitters/_test_commander_gate_explosion_04_emit.bp',
    '/effects/emitters/_test_commander_gate_explosion_05_emit.bp',
}

UnitTeleport02 = {
    '/effects/emitters/teleport_timing_01_emit.bp',
    '/effects/emitters/teleport_sparks_01_emit.bp',
    '/effects/emitters/teleport_ground_01_emit.bp',
}

UnitTeleportSteam01 = { '/effects/emitters/teleport_commander_mist_01_emit.bp',}

CommanderTeleport01 = {
    '/effects/emitters/teleport_ring_01_emit.bp',
    '/effects/emitters/teleport_rising_mist_01_emit.bp',
    '/effects/emitters/commander_teleport_01_emit.bp',    
    '/effects/emitters/commander_teleport_02_emit.bp',      
    '/effects/emitters/_test_commander_gate_explosion_02_emit.bp',
}

CommanderQuantumGateInEnergy = {
    '/effects/emitters/energy_stream_01_emit.bp',
    '/effects/emitters/energy_stream_02_emit.bp',     
    '/effects/emitters/energy_stream_03_emit.bp',       
    '/effects/emitters/energy_stream_04_emit.bp',          
    '/effects/emitters/energy_stream_05_emit.bp',     
    '/effects/emitters/energy_stream_sparks_01_emit.bp',     
    '/effects/emitters/energy_rays_01_emit.bp',        
}

CloudFlareEffects01 = {
    '/effects/emitters/quantum_warhead_02_emit.bp',
    '/effects/emitters/quantum_warhead_04_emit.bp',
}

GenericTeleportCharge01 = {
    '/effects/emitters/generic_teleport_charge_01_emit.bp',
    '/effects/emitters/generic_teleport_charge_02_emit.bp',
    '/effects/emitters/generic_teleport_charge_03_emit.bp',
}
GenericTeleportOut01 = {
    '/effects/emitters/generic_teleportout_01_emit.bp',
}
GenericTeleportIn01 = {
    '/effects/emitters/generic_teleportin_01_emit.bp',
    '/effects/emitters/generic_teleportin_02_emit.bp',
    '/effects/emitters/generic_teleportin_03_emit.bp',
}

-- Build Effects
DefaultBuildUnit01 = { '/effects/emitters/default_build_01_emit.bp'}

AeonBuildBeams01 = { '/effects/emitters/aeon_build_beam_01_emit.bp', '/effects/emitters/aeon_build_beam_02_emit.bp',}
AeonBuildBeams02 = { '/effects/emitters/aeon_build_beam_04_emit.bp', '/effects/emitters/aeon_build_beam_05_emit.bp',}

CybranBuildUnitBlink01 = { '/effects/emitters/build_cybran_blink_blue_01_emit.bp'}
CybranBuildFlash01 =  '/effects/emitters/build_cybran_spark_flash_03_emit.bp'
CybranBuildSparks01 =  '/effects/emitters/build_sparks_blue_01_emit.bp' 
CybranFactoryBuildSparksLeft01 = {
    '/effects/emitters/sparks_04_emit.bp',
    '/effects/emitters/build_cybran_spark_flash_02_emit.bp',
}
CybranFactoryBuildSparksRight01 = {
    '/effects/emitters/sparks_03_emit.bp',
    '/effects/emitters/build_cybran_spark_flash_01_emit.bp',
}
CybranUnitBuildSparks01 = {
    '/effects/emitters/build_cybran_sparks_01_emit.bp',
    '/effects/emitters/build_cybran_sparks_02_emit.bp',
--    '/effects/emitters/build_cybran_sparks_03_emit.bp',
}

SeraphimBuildBeams01 = {
    '/effects/emitters/seraphim_build_beam_01_emit.bp',
    '/effects/emitters/seraphim_build_beam_02_emit.bp',
}

-- Reclaim Effects
ReclaimBeams = { '/effects/emitters/reclaim_beam_01_emit.bp',}
ReclaimObjectAOE = { '/effects/emitters/reclaim_01_emit.bp' }
ReclaimObjectEnd = { '/effects/emitters/reclaim_02_emit.bp' }

-- Capture Effects
CaptureBeams = {
    '/effects/emitters/capture_beam_01_emit.bp',
    '/effects/emitters/capture_beam_02_emit.bp',
    '/effects/emitters/capture_beam_03_emit.bp',	
}

-- Upgrade Effects
UpgradeUnitAmbient = { '/effects/emitters/unit_upgrade_ambient_01_emit.bp', '/effects/emitters/unit_upgrade_ambient_02_emit.bp',}
UpgradeBoneAmbient = { '/effects/emitters/unit_upgrade_bone_ambient_01_emit.bp',}

-- Terran Transport Beam Effects
TTransportBeam01 = '/effects/emitters/terran_transport_beam_01_emit.bp'                  -- Unit to Transport beam
TTransportBeam02 = '/effects/emitters/terran_transport_beam_02_emit.bp'                  -- Transport to Unit beam

ACollossusTractorBeam01 = '/effects/emitters/collossus_tractor_beam_01_emit.bp'          -- This is just for the colossus beam and how it will tractor beam stuff.
ACollossusTractorBeamGlow01 = '/effects/emitters/collossus_tractor_beam_glow_01_emit.bp' 
ACollossusTractorBeamGlow02 = '/effects/emitters/collossus_tractor_beam_glow_02_emit.bp' 
ACollossusTractorBeamGlow02 = '/effects/emitters/collossus_tractor_beam_glow_03_emit.bp' 
ACollossusTractorBeamVacuum01 = { '/effects/emitters/collossus_vacuum_grab_01_emit.bp', }

TTransportGlow01 = '/effects/emitters/terran_transport_glow_01_emit.bp'
TTransportGlow02 = '/effects/emitters/terran_transport_glow_02_emit.bp'
TTransportBeam03 = '/effects/emitters/terran_transport_beam_03_emit.bp'                  -- Transport to Unit beam

ACollossusTractorBeamCrush01 = {'/effects/emitters/collossus_crush_explosion_01_emit.bp', '/effects/emitters/collossus_crush_explosion_02_emit.bp',}

-- Sea Unit Environmental Effects
DefaultSeaUnitBackWake01 = {
    '/effects/emitters/water_move_trail_back_01_emit.bp',   
    '/effects/emitters/water_move_trail_back_r_01_emit.bp',
    '/effects/emitters/water_move_trail_back_l_01_emit.bp',
}

DefaultSeaUnitIdle01 = { '/effects/emitters/water_idle_ripples_02_emit.bp',}
DefaultUnderWaterUnitWake01 = { '/effects/emitters/underwater_move_trail_01_emit.bp',}
DefaultUnderWaterIdle01 = { '/effects/emitters/underwater_idle_bubbles_01_emit.bp',}

-- Land Unit Environmental Effects
DustBrownMove01 = { '/effects/emitters/land_move_brown_dust_01_emit.bp',}
FootFall01 = { '/effects/emitters/tt_dirt02_footfall01_01_emit.bp', '/effects/emitters/tt_dirt02_footfall01_02_emit.bp',}

-- AEON UNIT AMBIENT EFFECTS ###
AT1PowerAmbient = { '/effects/emitters/aeon_t1power_ambient_01_emit.bp','/effects/emitters/aeon_t1power_ambient_02_emit.bp',}
AT2MassCollAmbient = {'/effects/emitters/aeon_t2masscoll_ambient_01_emit.bp',}
AT2PowerAmbient = { '/effects/emitters/aeon_t2power_ambient_01_emit.bp', '/effects/emitters/aeon_t2power_ambient_02_emit.bp',}
AT3PowerAmbient = { '/effects/emitters/aeon_t3power_ambient_01_emit.bp', '/effects/emitters/aeon_t3power_ambient_02_emit.bp',}

AQuantumGateAmbient = { '/effects/emitters/aeon_gate_01_emit.bp', '/effects/emitters/aeon_gate_02_emit.bp', '/effects/emitters/aeon_gate_03_emit.bp',}
AResourceGenAmbient = { '/effects/emitters/aeon_rgen_ambient_01_emit.bp', '/effects/emitters/aeon_rgen_ambient_02_emit.bp', '/effects/emitters/aeon_rgen_ambient_03_emit.bp',}
ASacrificeOfTheAeon01 = {
	'/effects/emitters/aeon_sacrifice_01_emit.bp',
	'/effects/emitters/aeon_sacrifice_02_emit.bp',	
	'/effects/emitters/aeon_sacrifice_03_emit.bp',		
}

ASacrificeOfTheAeon02 = {'/effects/emitters/aeon_sacrifice_04_emit.bp',	}

AeonOpWeapDisable = {
    '/effects/emitters/op_aeon_weapdisable_01_emit.bp',
    '/effects/emitters/op_aeon_weapdisable_02_emit.bp',
}

AeonOpHackACU = {
    '/effects/emitters/op_aeon_hackacu_01_emit.bp',
    '/effects/emitters/op_aeon_hackacu_02_emit.bp',
    '/effects/emitters/op_aeon_hackacu_03_emit.bp',
}

-- AEON PROJECTILES ###
AMercyGuidedMissileSplit = {
    '/effects/emitters/aeon_mercy_guided_missile_split_01.bp',
    '/effects/emitters/aeon_mercy_guided_missile_split_02.bp',
}

AMercyGuidedMissileSplitMissileHit = {
    EmtBpPath ..'aeon_mercy_missile_hit_01_emit.bp',
}

AMercyGuidedMissileSplitMissileHitLand = {
    EmtBpPath ..'aeon_mercy_missile_hit_land_01_emit.bp',
    EmtBpPath ..'aeon_mercy_missile_hit_land_02_emit.bp',
}

AMercyGuidedMissileSplitMissileHitUnit = {
    EmtBpPath ..'aeon_mercy_missile_hit_01_emit.bp',
    EmtBpPath ..'aeon_mercy_missile_hit_land_02_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}

AMercyGuidedMissilePolyTrail = '/effects/emitters/aeon_mercy_missile_polytrail_01_emit.bp'

AMercyGuidedMissileFxTrails = {
    '/effects/emitters/aeon_mercy_missile_fxtrail_01_emit.bp',
}

AMercyGuidedMissileExhaustFxTrails = {
    '/effects/emitters/aeon_mercy_missile_thruster_beam_01_emit.bp',
}



AQuasarAntiTorpedoPolyTrails = {
    '/effects/emitters/aeon_quasar_antitorpedo_polytrail_01_emit.bp',
    '/effects/emitters/aeon_quasar_antitorpedo_polytrail_02_emit.bp',
}

AQuasarAntiTorpedoFxTrails= {}

AQuasarAntiTorpedoFlash= {
	'/effects/emitters/aeon_quasar_antitorpedo_flash_01_emit.bp',
}

AQuasarAntiTorpedoHit= {
    '/effects/emitters/aeon_quasar_antitorpedo_hit_01_emit.bp',
    '/effects/emitters/aeon_quasar_antitorpedo_hit_02_emit.bp',
--    '/effects/emitters/aeon_quasar_antitorpedo_hit_03_emit.bp',
--    '/effects/emitters/aeon_quasar_antitorpedo_hit_04_emit.bp',
}

AQuasarAntiTorpedoLandHit= {}

AQuasarAntiTorpedoUnitHit= {
	'/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}


AAntiMissileFlare = {
    '/effects/emitters/aeon_missiled_wisp_01_emit.bp',
    '/effects/emitters/aeon_missiled_wisp_02_emit.bp',
--    '/effects/emitters/aeon_missiled_wisp_04_emit.bp',
}    

AAntiMissileFlareFlash = {
    '/effects/emitters/aeon_missiled_flash_01_emit.bp',
    '/effects/emitters/aeon_missiled_flash_02_emit.bp',
--    '/effects/emitters/aeon_missiled_flash_03_emit.bp',
}
AAntiMissileFlareHit = { 
    '/effects/emitters/aeon_missiled_hit_01_emit.bp',
    '/effects/emitters/aeon_missiled_hit_02_emit.bp',
    '/effects/emitters/aeon_missiled_hit_03_emit.bp',
--    '/effects/emitters/aeon_missiled_hit_04_emit.bp',
}

ABeamHit01 = {
    '/effects/emitters/beam_hit_sparks_01_emit.bp',
--    '/effects/emitters/beam_hit_smoke_01_emit.bp',
}

ABeamHitUnit01 = ABeamHit01
ABeamHitLand01 = ABeamHit01

ABombHit01 = {
    '/effects/emitters/aeon_bomber_hit_01_emit.bp',
    '/effects/emitters/aeon_bomber_hit_02_emit.bp',
    '/effects/emitters/aeon_bomber_hit_03_emit.bp',
--    '/effects/emitters/aeon_bomber_hit_04_emit.bp',
}

AChronoDampener = {
    '/effects/emitters/aeon_chrono_dampener_01_emit.bp',
    '/effects/emitters/aeon_chrono_dampener_02_emit.bp',
    '/effects/emitters/aeon_chrono_dampener_03_emit.bp',
--    '/effects/emitters/aeon_chrono_dampener_04_emit.bp',
}

ACommanderOverchargeFlash01 = {
    '/effects/emitters/aeon_commander_overcharge_flash_01_emit.bp',
    '/effects/emitters/aeon_commander_overcharge_flash_02_emit.bp',
    '/effects/emitters/aeon_commander_overcharge_flash_03_emit.bp',
}

ACommanderOverchargeFXTrail01 = { 
    '/effects/emitters/aeon_commander_overcharge_01_emit.bp', 
    '/effects/emitters/aeon_commander_overcharge_02_emit.bp',
}

ACommanderOverchargeHit01 = { 
    '/effects/emitters/aeon_commander_overcharge_hit_01_emit.bp', 
    '/effects/emitters/aeon_commander_overcharge_hit_02_emit.bp', 
}

ADepthCharge01 = { '/effects/emitters/harmonic_depth_charge_resonance_01_emit.bp',}
ADepthChargeHitUnit01 = DefaultProjectileUnderWaterImpact
ADepthChargeHitUnderWaterUnit01 = TableCat( ADepthCharge01, DefaultProjectileUnderWaterImpact )

ADisruptorCannonMuzzle01 = {
	'/effects/emitters/adisruptor_cannon_muzzle_01_emit.bp',		
}

ADisruptorMunition01 = { 
    '/effects/emitters/adisruptor_cannon_munition_01_emit.bp',
}

ADisruptorHit01 = { 
    '/effects/emitters/adisruptor_hit_01_emit.bp',
}

ADisruptorHitShield = { 
    '/effects/emitters/_test_shield_impact_emit.bp',
}

ASDisruptorCannonMuzzle01 = {
	'/effects/emitters/disruptor_cannon_muzzle_03_emit.bp',		
	'/effects/emitters/disruptor_cannon_muzzle_04_emit.bp', 
	'/effects/emitters/disruptor_cannon_muzzle_05_emit.bp',
--	'/effects/emitters/disruptor_cannon_muzzle_06_emit.bp',		
}

ASDisruptorCannonChargeMuzzle01 = {
    '/effects/emitters/disruptor_cannon_muzzle_01_emit.bp',	
    '/effects/emitters/disruptor_cannon_muzzle_02_emit.bp',
}

ASDisruptorPolytrail01 =  '/effects/emitters/disruptor_cannon_polytrail_01_emit.bp'

ASDisruptorMunition01 = { 
    '/effects/emitters/disruptor_cannon_munition_01_emit.bp',
    '/effects/emitters/disruptor_cannon_munition_02_emit.bp',
    '/effects/emitters/disruptor_cannon_munition_03_emit.bp',
--    '/effects/emitters/disruptor_cannon_munition_04_emit.bp',
}

ASDisruptorHit01 = { 
    '/effects/emitters/disruptor_hit_01_emit.bp',
    '/effects/emitters/disruptor_hit_02_emit.bp',
    '/effects/emitters/disruptor_hit_03_emit.bp',
    '/effects/emitters/disruptor_hit_04_emit.bp',	
--    '/effects/emitters/disruptor_hit_05_emit.bp',
}

ASDisruptorHitUnit01 = { 
    '/effects/emitters/disruptor_hitunit_01_emit.bp',
    '/effects/emitters/disruptor_hitunit_02_emit.bp',
    '/effects/emitters/disruptor_hitunit_03_emit.bp',
--    '/effects/emitters/disruptor_hitunit_04_emit.bp',	
}

ASDisruptorHitShield = { 
    '/effects/emitters/disruptor_hit_shield_emit.bp',
    '/effects/emitters/disruptor_hit_shield_02_emit.bp',	
    '/effects/emitters/disruptor_hit_shield_03_emit.bp',
    '/effects/emitters/disruptor_hit_shield_04_emit.bp',
--    '/effects/emitters/disruptor_hit_shield_05_emit.bp', 
--    '/effects/emitters/disruptor_hit_shield_06_emit.bp',  
}

AHighIntensityLaserHit01 = {
    '/effects/emitters/laserturret_hit_flash_04_emit.bp',
    '/effects/emitters/laserturret_hit_flash_05_emit.bp',
    '/effects/emitters/laserturret_hit_flash_09_emit.bp',
}
AHighIntensityLaserHitUnit01 = TableCat( AHighIntensityLaserHit01, UnitHitShrapnel01 )
AHighIntensityLaserHitLand01 = TableCat( AHighIntensityLaserHit01 )
AHighIntensityLaserFlash01   = {
    #'/effects/emitters/aeon_laser_highintensity_flash_01_emit.bp',
    '/effects/emitters/aeon_laser_highintensity_flash_02_emit.bp',
}

AGravitonBolterHit01 = {
    '/effects/emitters/graviton_bolter_hit_02_emit.bp',
    '/effects/emitters/sparks_07_emit.bp',
}
AGravitonBolterMuzzleFlash01 = {
    '/effects/emitters/graviton_bolter_flash_01_emit.bp',
}

ALaserBotHit01 = {
    '/effects/emitters/laserturret_hit_flash_04_emit.bp',
    '/effects/emitters/laserturret_hit_flash_05_emit.bp',
}

ALaserBotHitUnit01 = TableCat( ALaserBotHit01, UnitHitShrapnel01 )
ALaserBotHitLand01 = TableCat( ALaserBotHit01 )

ALaserHit01 = { '/effects/emitters/laserturret_hit_flash_02_emit.bp',}
ALaserHitUnit01 = TableCat( ALaserHit01, UnitHitShrapnel01 )
ALaserHitLand01 = TableCat( ALaserHit01 )

ALightLaserHit01 = { '/effects/emitters/laserturret_hit_flash_07_emit.bp',}
ALightLaserHit02 = {
    '/effects/emitters/laserturret_hit_flash_07_emit.bp',
    '/effects/emitters/laserturret_hit_flash_08_emit.bp',
}

ALightLaserHitUnit01 = TableCat( ALightLaserHit02, UnitHitShrapnel01 )

ALightMortarHit01 = {
    '/effects/emitters/aeon_light_shell_01_emit.bp',
    '/effects/emitters/aeon_light_shell_02_emit.bp',
    '/effects/emitters/aeon_light_shell_03_emit.bp',
    #'/effects/emitters/aeon_light_shell_05_emit.bp',
}

AIFBallisticMortarHit01 = {
    '/effects/emitters/aeon_light_shell_01_emit.bp',
    '/effects/emitters/aeon_light_shell_02_emit.bp',
    '/effects/emitters/aeon_light_shell_03_emit.bp',
}

AIFBallisticMortarTrails01 = {
    '/effects/emitters/quark_bomb_01_emit.bp',
    '/effects/emitters/quark_bomb_02_emit.bp',
--    '/effects/emitters/quark_bomb_03_emit.bp',
}

AIFBallisticMortarFxTrails02 = {
	'/effects/emitters/aeon_mortar02_fxtrail_01_emit.bp',
	'/effects/emitters/aeon_mortar02_fxtrail_02_emit.bp',
}

AIFBallisticMortarTrails02 = {
	'/effects/emitters/aeon_mortar02_polytrail_01_emit.bp',
	'/effects/emitters/aeon_mortar02_polytrail_02_emit.bp',
}

AIFBallisticMortarFlash02 = {
    '/effects/emitters/aeon_mortar02_flash_01_emit.bp',
    '/effects/emitters/aeon_mortar02_flash_02_emit.bp',
    '/effects/emitters/aeon_mortar02_flash_03_emit.bp',
--    '/effects/emitters/aeon_mortar02_flash_04_emit.bp',
}

AIFBallisticMortarHitUnit02 = {
    '/effects/emitters/aeon_mortar02_shell_01_emit.bp',
    '/effects/emitters/aeon_mortar02_shell_02_emit.bp',
    '/effects/emitters/aeon_mortar02_shell_03_emit.bp',
--    '/effects/emitters/aeon_mortar02_shell_04_emit.bp',
}

AIFBallisticMortarHitLand02 = {
    '/effects/emitters/aeon_mortar02_shell_01_emit.bp',
    '/effects/emitters/aeon_mortar02_shell_02_emit.bp',
    '/effects/emitters/aeon_mortar02_shell_03_emit.bp',
--    '/effects/emitters/aeon_mortar02_shell_04_emit.bp',
}


AMiasmaMunition01 = {
    '/effects/emitters/miasma_munition_trail_01_emit.bp',
}
AMiasmaMunition02 = {
    '/effects/emitters/miasma_cloud_02_emit.bp',
}

AMiasma01 = { 
    '/effects/emitters/miasma_munition_burst_01_emit.bp',
}

AMiasmaField01 = {
    '/effects/emitters/miasma_cloud_01_emit.bp',
}

AMissileHit01 = DefaultMissileHit01

ASerpFlash01 = {
    '/effects/emitters/aeon_serp_flash_01_emit.bp',
    '/effects/emitters/aeon_serp_flash_02_emit.bp',
    '/effects/emitters/aeon_serp_flash_03_emit.bp',
}

AOblivionCannonHit01 = {
    '/effects/emitters/oblivion_cannon_hit_01_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_02_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_03_emit.bp',    
--    '/effects/emitters/oblivion_cannon_hit_04_emit.bp',       
}

AOblivionCannonHit02 = {
    '/effects/emitters/oblivion_cannon_hit_05_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_06_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_07_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_08_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_09_emit.bp',
    '/effects/emitters/oblivion_cannon_hit_10_emit.bp',
--    '/effects/emitters/oblivion_cannon_hit_11_emit.bp',
--    '/effects/emitters/oblivion_cannon_hit_12_emit.bp',
--    '/effects/emitters/oblivion_cannon_hit_13_emit.bp',
}

AOblivionCannonFXTrails02 = {
	'/effects/emitters/oblivion_cannon_munition_03_emit.bp',
	'/effects/emitters/oblivion_cannon_munition_04_emit.bp',
}

AOblivionCannonMuzzleFlash02 = {
	'/effects/emitters/oblivion_cannon_flash_10_emit.bp',
	'/effects/emitters/oblivion_cannon_flash_11_emit.bp',
	'/effects/emitters/oblivion_cannon_flash_12_emit.bp',
--	'/effects/emitters/oblivion_cannon_flash_13_emit.bp',
}

AOblivionCannonChargeMuzzleFlash02 = {
	'/effects/emitters/oblivion_cannon_flash_07_emit.bp',
    '/effects/emitters/oblivion_cannon_flash_08_emit.bp',
    '/effects/emitters/oblivion_cannon_flash_09_emit.bp',
}

AQuantumCannonMuzzle01 = {
    '/effects/emitters/disruptor_cannon_muzzle_01_emit.bp',	 
    '/effects/emitters/quantum_cannon_muzzle_flash_04_emit.bp',	 		
	'/effects/emitters/aeon_light_tank_muzzle_charge_01_emit.bp',	
--	'/effects/emitters/aeon_light_tank_muzzle_charge_02_emit.bp',
}
AQuantumCannonMuzzle02 = {                      
    '/effects/emitters/disruptor_cannon_muzzle_01_emit.bp',	 
    '/effects/emitters/quantum_cannon_muzzle_flash_04_emit.bp',	 		
	'/effects/emitters/quantum_cannon_muzzle_charge_s01_emit.bp',	
	'/effects/emitters/quantum_cannon_muzzle_charge_s02_emit.bp',
}
AQuantumCannonHit01 = {
    '/effects/emitters/quantum_hit_flash_04_emit.bp',
    '/effects/emitters/quantum_hit_flash_05_emit.bp',
    '/effects/emitters/quantum_hit_flash_06_emit.bp',
    '/effects/emitters/quantum_hit_flash_07_emit.bp',
--    '/effects/emitters/quantum_hit_flash_08_emit.bp',
--    '/effects/emitters/quantum_hit_flash_09_emit.bp',
}
AQuantumDisruptor01 = { 
    '/effects/emitters/aeon_commander_disruptor_01_emit.bp', 
    '/effects/emitters/aeon_commander_disruptor_02_emit.bp',
}
AQuantumDisruptorHit01 = { 
    '/effects/emitters/aeon_commander_disruptor_hit_01_emit.bp', 
    '/effects/emitters/aeon_commander_disruptor_hit_02_emit.bp', 
    '/effects/emitters/aeon_commander_disruptor_hit_03_emit.bp',   
}
AQuantumDisplacementHit01 = {
    '/effects/emitters/quantum_displacement_cannon_hit_01_emit.bp',
    '/effects/emitters/quantum_displacement_cannon_hit_02_emit.bp',
}
AQuantumDisplacementTeleport01 = {
    '/effects/emitters/sparks_07_emit.bp',
    '/effects/emitters/teleport_01_emit.bp',
}
AQuarkBomb01 = {
    '/effects/emitters/quark_bomb_01_emit.bp',
    '/effects/emitters/quark_bomb_02_emit.bp',
    '/effects/emitters/sparks_06_emit.bp',
}
AQuarkBomb02 = {                                
    '/effects/emitters/quark_bomb2_01_emit.bp',
    '/effects/emitters/quark_bomb2_02_emit.bp',
    '/effects/emitters/sparks_11_emit.bp',
}
AQuarkBombHit01 = {
    '/effects/emitters/quark_bomb_explosion_03_emit.bp',
    '/effects/emitters/quark_bomb_explosion_04_emit.bp',
    '/effects/emitters/quark_bomb_explosion_05_emit.bp',
--    '/effects/emitters/quark_bomb_explosion_07_emit.bp',
--    '/effects/emitters/quark_bomb_explosion_08_emit.bp',
}
AQuarkBombHit02 = {
    '/effects/emitters/quark_bomb_explosion_03_emit.bp',
    '/effects/emitters/quark_bomb_explosion_06_emit.bp',
}
AQuarkBombHitUnit01 = AQuarkBombHit01
AQuarkBombHitAirUnit01 = AQuarkBombHit02
AQuarkBombHitLand01 = AQuarkBombHit01

APhasonLaserMuzzle01 = {
    '/effects/emitters/phason_laser_muzzle_01_emit.bp',
    '/effects/emitters/phason_laser_muzzle_02_emit.bp',    
}

APhasonLaserImpact01 = {
    '/effects/emitters/phason_laser_end_01_emit.bp',
    '/effects/emitters/phason_laser_end_02_emit.bp',    
}

AReactonCannon01 = {
    '/effects/emitters/flash_06_emit.bp',
    '/effects/emitters/reacton_cannon_hit_03_emit.bp',
    '/effects/emitters/reacton_cannon_hit_04_emit.bp',
    '/effects/emitters/reacton_cannon_hit_05_emit.bp',
--    '/effects/emitters/reacton_cannon_hit_06_emit.bp',
}
AReactonCannon02 = {
    '/effects/emitters/flash_06_emit.bp',
    '/effects/emitters/sparks_10_emit.bp',
    '/effects/emitters/reacton_cannon_hit_01_emit.bp',
--    '/effects/emitters/reacton_cannon_hit_02_emit.bp',
}
AReactonCannonHitUnit01 = AReactonCannon01
AReactonCannonHitUnit02 = AReactonCannon02
AReactonCannonHitLand01 = AReactonCannon01
AReactonCannonHitLand02 = AReactonCannon02

ASaintLaunch01 = 
{
    '/effects/emitters/flash_03_emit.bp', 
    '/effects/emitters/saint_launch_01_emit.bp', 
    '/effects/emitters/saint_launch_02_emit.bp', 
}

ASaintImpact01 = 
{
    '/effects/emitters/flash_03_emit.bp', 
    '/effects/emitters/saint_launch_01_emit.bp', 
    '/effects/emitters/saint_launch_02_emit.bp', 
}

ASonanceWeaponFXTrail01 = {
    '/effects/emitters/aeon_heavy_artillery_trail_02_emit.bp',
    '/effects/emitters/quark_bomb_01_emit.bp',
    '/effects/emitters/quark_bomb_02_emit.bp',
}
ASonanceWeaponFXTrail02 = {                                  
    '/effects/emitters/aeon_heavy_artillery_trail_01_emit.bp',
    '/effects/emitters/quark_bomb2_01_emit.bp',
    '/effects/emitters/quark_bomb2_02_emit.bp',
}
ASonanceWeaponHit02 = {
    '/effects/emitters/aeon_sonance_hit_01_emit.bp',
    '/effects/emitters/aeon_sonance_hit_02_emit.bp',
    '/effects/emitters/aeon_sonance_hit_03_emit.bp',
    '/effects/emitters/aeon_sonance_hit_04_emit.bp',
--    '/effects/emitters/quark_bomb_explosion_08_emit.bp',
}

ASonicPulse01 = { '/effects/emitters/sonic_pulse_hit_flash_01_emit.bp',}
ASonicPulseHitUnit01 = TableCat( ASonicPulse01, UnitHitShrapnel01 )
ASonicPulseHitAirUnit01 = ASonicPulseHitUnit01
ASonicPulseHitLand01 = TableCat( ASonicPulse01 )

ASonicPulsarMunition01 = {
	'/effects/emitters/sonic_pulsar_01_emit.bp', 
}

ATemporalFizzHit01 = {
	'/effects/emitters/temporal_fizz_02_emit.bp',
    '/effects/emitters/temporal_fizz_03_emit.bp',
    '/effects/emitters/temporal_fizz_hit_flash_01_emit.bp',
}

ATorpedoUnitHit01 = {
	'/effects/emitters/aeon_torpedocluster_hit_01_emit.bp',
    '/effects/emitters/aeon_torpedocluster_hit_02_emit.bp',
}

ATorpedoHit_Bubbles = {
	'/effects/emitters/aeon_torpedocluster_hit_03_emit.bp',
	'/effects/emitters/destruction_underwater_explosion_splash_01_emit.bp',
}

ATorpedoUnitHitUnderWater01 = TableCat( ATorpedoUnitHit01, ATorpedoHit_Bubbles )

ATorpedoPolyTrails01 =  '/effects/emitters/aeon_torpedocluster_polytrail_01_emit.bp'

--- CYBRAN UNIT AMBIENT EFFECTS ###
CCivilianBuildingInfectionAmbient = {
    '/effects/emitters/cybran_building01_infect_ambient_01_emit.bp',
    '/effects/emitters/cybran_building01_infect_ambient_02_emit.bp',
    '/effects/emitters/cybran_building01_infect_ambient_03_emit.bp',
}

CBrackmanQAIHackCircuitryEffect01Polytrails01= {
    '/effects/emitters/cybran_brackman_hacking_qai_polytrail_01_emit.bp',
}
CBrackmanQAIHackCircuitryEffect02Polytrails01= {
    '/effects/emitters/cybran_brackman_hacking_qai_polytrail_02_emit.bp',
}
CBrackmanQAIHackCircuitryEffect02Fxtrails01= {
    '/effects/emitters/cybran_brackman_hacking_qai_fxtrail_01_emit.bp',
}
CBrackmanQAIHackCircuitryEffect02Fxtrails02= {
    '/effects/emitters/cybran_brackman_hacking_qai_fxtrail_02_emit.bp',
}
CBrackmanQAIHackCircuitryEffect02Fxtrails03= {
    '/effects/emitters/cybran_brackman_hacking_qai_fxtrail_03_emit.bp',
}
CBrackmanQAIHackCircuitryEffectFxtrailsALL= {
    CBrackmanQAIHackCircuitryEffect02Fxtrails01,
    CBrackmanQAIHackCircuitryEffect02Fxtrails02,
    CBrackmanQAIHackCircuitryEffect02Fxtrails03,
}

CQaiShutdown = {
    '/effects/emitters/cybran_qai_shutdown_ambient_01_emit.bp',
    '/effects/emitters/cybran_qai_shutdown_ambient_02_emit.bp',
    '/effects/emitters/cybran_qai_shutdown_ambient_03_emit.bp',
    '/effects/emitters/cybran_qai_shutdown_ambient_04_emit.bp',
}

CT2PowerAmbient = {
    '/effects/emitters/cybran_t2power_ambient_01_emit.bp',
    '/effects/emitters/cybran_t2power_ambient_01b_emit.bp',
    '/effects/emitters/cybran_t2power_ambient_02_emit.bp',
    '/effects/emitters/cybran_t2power_ambient_02b_emit.bp',
    '/effects/emitters/cybran_t2power_ambient_03_emit.bp',
    '/effects/emitters/cybran_t2power_ambient_03b_emit.bp',
}
CT3PowerAmbient = {
    '/effects/emitters/cybran_t3power_ambient_01_emit.bp',
    '/effects/emitters/cybran_t3power_ambient_01b_emit.bp',
    '/effects/emitters/cybran_t3power_ambient_02_emit.bp',
    '/effects/emitters/cybran_t3power_ambient_02b_emit.bp',
    '/effects/emitters/cybran_t3power_ambient_03_emit.bp',
    '/effects/emitters/cybran_t3power_ambient_03b_emit.bp',
}
CSoothSayerAmbient = {
    '/effects/emitters/cybran_soothsayer_ambient_01_emit.bp',
    '/effects/emitters/cybran_soothsayer_ambient_02_emit.bp',
}

--- CYBRAN PROJECTILES ###
CBrackmanCrabPegPodSplit01 = {
    '/effects/emitters/cybran_brackman_crab_pegpod_split_01_emit.bp',
}
CBrackmanCrabPegPodTrails= {
    '/effects/emitters/cybran_brackman_crab_pegpod_polytrail_01_emit.bp',
}
CBrackmanCrabPeg01 = {
    '/effects/emitters/cybran_nano_dart_hit_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_02_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_03_emit.bp',
    '/effects/emitters/cybran_nano_dart_glow_hit_land_01_emit.bp',
}
CBrackmanCrabPegHit01= {
    '/effects/emitters/cybran_brackman_crab_peg_hit_01_emit.bp',
    '/effects/emitters/cybran_brackman_crab_peg_hit_02_emit.bp',
}
CBrackmanCrabPegAmbient01= {
    '/effects/emitters/cybran_brackman_crab_peg_hit_03_emit.bp',
    '/effects/emitters/cybran_brackman_crab_peg_hit_03_flat_emit.bp',
    '/effects/emitters/cybran_brackman_crab_peg_hit_04_emit.bp',
}
CBrackmanCrabPegTrails= {
    '/effects/emitters/cybran_brackman_crab_peg_polytrail_01_emit.bp',
}

CIridiumRocketProjectile = {
    '/effects/emitters/cybran_nano_dart_hit_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_02_emit.bp',
}

CNanoDartHit01 = {
    '/effects/emitters/cybran_nano_dart_hit_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_02_emit.bp',
}
CNanoDartLandHit01 = {
    '/effects/emitters/cybran_nano_dart_hit_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_02_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_03_emit.bp',
    '/effects/emitters/cybran_nano_dart_glow_hit_land_01_emit.bp',
}
CNanoDartUnitHit01 = {
    '/effects/emitters/cybran_nano_dart_hit_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_02_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_03_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_glow_hit_unit_01_emit.bp',
}

CNanoDartLandHit02 = {
    '/effects/emitters/cybran_nano_dart_hit_03_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_04_emit.bp',
    '/effects/emitters/cybran_nano_dart_glow_hit_land_02_emit.bp',
}
CNanoDartUnitHit02 = {
    '/effects/emitters/cybran_nano_dart_hit_03_emit.bp',
    '/effects/emitters/cybran_nano_dart_hit_04_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
    '/effects/emitters/cybran_nano_dart_glow_hit_unit_02_emit.bp',
}

CNanoDartPolyTrail01= '/effects/emitters/cybran_nano_dart_polytrail_01_emit.bp'

CNanoDartPolyTrail02= '/effects/emitters/cybran_nano_dart_polytrail_02_emit.bp'

CCorsairMissileHit01 = {
    '/effects/emitters/cybran_corsair_missile_hit_01_emit.bp',
}
CCorsairMissileLandHit01 = {
    '/effects/emitters/cybran_corsair_missile_hit_01_emit.bp',
    '/effects/emitters/cybran_corsair_missile_hit_02_emit.bp',
    '/effects/emitters/cybran_corsair_missile_hit_03_emit.bp',
    '/effects/emitters/cybran_corsair_missile_glow_hit_land_01_emit.bp',
    '/effects/emitters/cybran_corsair_missile_glow_hit_land_02_emit.bp',
    '/effects/emitters/cybran_corsair_missile_hit_ring.bp',
}
CCorsairMissileUnitHit01 = {
    '/effects/emitters/cybran_corsair_missile_hit_01_emit.bp',
    '/effects/emitters/cybran_corsair_missile_hit_02_emit.bp',
    '/effects/emitters/cybran_corsair_missile_hit_03_emit.bp',
    '/effects/emitters/cybran_corsair_missile_glow_hit_unit_01_emit.bp',
    '/effects/emitters/cybran_corsair_missile_hit_ring.bp',
    '/effects/emitters/unit_shrapnel_hit_01_emit.bp',
}
CCorsairMissileFxTrails01 = {}
CCorsairMissilePolyTrail01= '/effects/emitters/cybran_corsair_missile_polytrail_01_emit.bp'

CAntiNukeLaunch01 = {
    '/effects/emitters/cybran_antinuke_launch_02_emit.bp',
    '/effects/emitters/cybran_antinuke_launch_03_emit.bp',
    '/effects/emitters/cybran_antinuke_launch_04_emit.bp',
    '/effects/emitters/cybran_antinuke_launch_05_emit.bp',
}

CAntiTorpedoHit01 = {
    '/effects/emitters/anti_torpedo_flare_hit_01_emit.bp',
	'/effects/emitters/anti_torpedo_flare_hit_02_emit.bp',    
	'/effects/emitters/anti_torpedo_flare_hit_03_emit.bp',	
}

CArtilleryFlash01 = {
    '/effects/emitters/proton_artillery_muzzle_01_emit.bp',
	'/effects/emitters/proton_artillery_muzzle_02_emit.bp',
	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
	'/effects/emitters/proton_artillery_muzzle_04_emit.bp',
	'/effects/emitters/proton_artillery_muzzle_05_emit.bp',
	'/effects/emitters/proton_artillery_muzzle_06_emit.bp',
	'/effects/emitters/proton_artillery_muzzle_08_emit.bp',
}
CArtilleryFlash02 = {
	'/effects/emitters/proton_artillery_muzzle_07_emit.bp',
}

CArtilleryHit01 = DefaultHitExplosion01

CBeamHit01 = {
    '/effects/emitters/beam_hit_sparks_01_emit.bp',
    '/effects/emitters/beam_hit_smoke_01_emit.bp',
}
CBeamHitUnit01 = CBeamHit01
CBeamHitLand01 = CBeamHit01

CBombHit01 = {
    '/effects/emitters/bomb_hit_flash_01_emit.bp',
    '/effects/emitters/bomb_hit_fire_01_emit.bp',
    '/effects/emitters/bomb_hit_fire_shadow_01_emit.bp',
}

CCommanderOverchargeFxTrail01 = {
	'/effects/emitters/cybran_commander_overcharge_fxtrail_01_emit.bp',
	'/effects/emitters/cybran_commander_overcharge_fxtrail_02_emit.bp',
}
CCommanderOverchargeHit01 = {
	'/effects/emitters/cybran_commander_overcharge_hit_01_emit.bp',
	'/effects/emitters/cybran_commander_overcharge_hit_02_emit.bp',
	#'/effects/emitters/cybran_commander_overcharge_hit_03_emit.bp',
}

CDisintegratorHit01 = {   
    '/effects/emitters/disintegrator_hit_flash_01_emit.bp',
    '/effects/emitters/disintegrator_hit_flash_02_emit.bp',
    '/effects/emitters/disintegrator_hit_flash_03_emit.bp',
    '/effects/emitters/disintegrator_hit_flash_04_emit.bp',
    '/effects/emitters/disintegrator_hit_flash_05_emit.bp',
--    '/effects/emitters/disintegrator_hit_flash_06_emit.bp',
--    '/effects/emitters/disintegrator_hit_flash_07_emit.bp',
}
CDisintegratorHit02 = { 
	'/effects/emitters/disintegrator_hit_sparks_01_emit.bp',
	'/effects/emitters/disintegrator_hit_flashunit_05_emit.bp',
	'/effects/emitters/disintegrator_hit_flashunit_07_emit.bp',
}
CDisintegratorHit03 = { '/effects/emitters/disintegrator_hit_flash_02_emit.bp',}
CDisintegratorHitUnit01 = TableCat( CDisintegratorHit01, CDisintegratorHit02 )
CDisintegratorHitAirUnit01 = TableCat( CDisintegratorHit03, CDisintegratorHit02 )
CDisintegratorFxTrails01 = {
	'/effects/emitters/disintegrator_fxtrail_01_emit.bp'
}
CDisintegratorHitLand01 = CDisintegratorHit01

CHvyDisintegratorHit01 = {   
    '/effects/emitters/disintegratorhvy_hit_flash_01_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_flash_flat_02_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_flash_flat_03_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_flash_04_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_flash_05_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_flash_flat_06_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_flash_07_emit.bp',
    '/effects/emitters/disintegratorhvy_hit_sparks_01_emit.bp',
--    '/effects/emitters/disintegratorhvy_hit_flash_flat_08_emit.bp',
--    '/effects/emitters/disintegratorhvy_hit_flash_09_emit.bp',
--    '/effects/emitters/disintegratorhvy_hit_flash_distort_emit.bp',
}
CHvyDisintegratorHit02 = { 
	'/effects/emitters/disintegratorhvy_hit_flash_02_emit.bp',	
	'/effects/emitters/disintegratorhvy_hit_flash_03_emit.bp',
	'/effects/emitters/disintegratorhvy_hit_flash_06_emit.bp',
--	'/effects/emitters/disintegratorhvy_hit_flash_08_emit.bp',
}
CHvyDisintegratorHitUnit01 = TableCat( CHvyDisintegratorHit01, CHvyDisintegratorHit02 )
CHvyDisintegratorHitLand01 = CHvyDisintegratorHit01

CDisruptorGroundEffect = {
	'/effects/emitters/cybran_lra_ground_effect_01_emit.bp'
}
CDisruptorVentEffect = {
	'/effects/emitters/cybran_lra_vent_effect_01_emit.bp'
}
CDisruptorMuzzleEffect = {
	'/effects/emitters/cybran_lra_muzzle_effect_01_emit.bp',
	'/effects/emitters/cybran_lra_muzzle_effect_02_emit.bp',
}
CDisruptorCoolDownEffect = {
	'/effects/emitters/cybran_lra_cooldown_effect_01_emit.bp',
	'/effects/emitters/cybran_lra_barrel_effect_01_emit.bp',
}

CElectronBolterMuzzleFlash01 = {
	'/effects/emitters/electron_bolter_flash_01_emit.bp',
	'/effects/emitters/electron_bolter_flash_02_emit.bp',
	'/effects/emitters/electron_bolter_flash_04_emit.bp',
	'/effects/emitters/electron_bolter_flash_05_emit.bp',
--	'/effects/emitters/laserturret_muzzle_flash_01_emit.bp',
}
CElectronBolterMuzzleFlash02 = {
	'/effects/emitters/electron_bolter_flash_03_emit.bp',
    '/effects/emitters/electron_bolter_sparks_01_emit.bp',
}
CElectronBolterHit01 = {
    '/effects/emitters/electron_bolter_hit_02_emit.bp',
    '/effects/emitters/electron_bolter_hit_03_emit.bp',
    '/effects/emitters/electron_bolter_hit_04_emit.bp',
    '/effects/emitters/electron_bolter_hit_flash_01_emit.bp',
--    '/effects/emitters/electron_bolter_hit_flash_03_emit.bp',
}
CElectronBolterHit02 = { 
	'/effects/emitters/electron_bolter_hit_01_emit.bp',
	'/effects/emitters/electron_bolter_hitunit_04_emit.bp',
}
CElectronBolterHit03 = { 
    '/effects/emitters/electron_bolter_hit_flash_02_emit.bp',
    '/effects/emitters/electron_bolter_hit_05_emit.bp',
}
CElectronBolterHitUnit01 = TableCat( CElectronBolterHit01, CElectronBolterHit02, UnitHitShrapnel01 )
CElectronBolterHitLand01 = CElectronBolterHit01
CElectronBolterHitUnit02 = TableCat( CElectronBolterHit01, CElectronBolterHit02, CElectronBolterHit03, UnitHitShrapnel01 )
CElectronBolterHitLand02 = TableCat( CElectronBolterHit01, CElectronBolterHit03 )
CElectronBolterHit03 = {
    '/effects/emitters/electron_bolter_hit_02_emit.bp',
    '/effects/emitters/electron_bolter_hit_flash_01_emit.bp',
}
CElectronBolterHit04 = {
    '/effects/emitters/electron_bolter_hit_02_emit.bp',
    '/effects/emitters/electron_bolter_hit_flash_02_emit.bp',
}

CElectronBurstCloud01 = {
    '/effects/emitters/electron_burst_cloud_gas_01_emit.bp',
    '/effects/emitters/electron_burst_cloud_sparks_01_emit.bp',
    '/effects/emitters/electron_burst_cloud_flash_01_emit.bp',
}

CEMPGrenadeHit01 = {
    '/effects/emitters/cybran_empgrenade_hit_01_emit.bp',
    '/effects/emitters/cybran_empgrenade_hit_02_emit.bp',
    '/effects/emitters/cybran_empgrenade_hit_03_emit.bp',    
}

CIFCruiseMissileLaunchSmoke = {
    '/effects/emitters/cybran_cruise_missile_launch_01_emit.bp',
    '/effects/emitters/cybran_cruise_missile_launch_02_emit.bp',
}

CLaserHit01 = {   
    '/effects/emitters/cybran_laser_hit_flash_01_emit.bp',
    '/effects/emitters/cybran_laser_hit_flash_02_emit.bp',
}
CLaserHit02 = {   
    '/effects/emitters/cybran_laser_hit_flash_01_emit.bp',
    '/effects/emitters/cybran_laser_hit_sparks_01_emit.bp',
}
CLaserHitLand01 = CLaserHit01
CLaserHitUnit01 = TableCat( CLaserHit02, UnitHitShrapnel01 )
CLaserMuzzleFlash01 = {
    '/effects/emitters/laser_muzzle_flash_02_emit.bp',
    '/effects/emitters/default_muzzle_flash_01_emit.bp',
    '/effects/emitters/default_muzzle_flash_02_emit.bp',
}
CLaserMuzzleFlash02 = {
    '/effects/emitters/cybran_laser_muzzle_flash_01_emit.bp',
    '/effects/emitters/cybran_laser_muzzle_flash_02_emit.bp',
}
CLaserMuzzleFlash03 = {
    '/effects/emitters/cybran_laser_muzzle_flash_03_emit.bp',
    '/effects/emitters/cybran_laser_muzzle_flash_04_emit.bp',
}

CMicrowaveLaserMuzzle01 = { 
    '/effects/emitters/microwave_laser_flash_01_emit.bp',
    '/effects/emitters/microwave_laser_muzzle_01_emit.bp',
}
CMicrowaveLaserCharge01 = { 
    '/effects/emitters/microwave_laser_charge_01_emit.bp',
    '/effects/emitters/microwave_laser_charge_02_emit.bp',
}
CMicrowaveLaserEndPoint01 = {
    '/effects/emitters/microwave_laser_end_01_emit.bp',
    '/effects/emitters/microwave_laser_end_02_emit.bp',
    '/effects/emitters/microwave_laser_end_03_emit.bp',
    '/effects/emitters/microwave_laser_end_04_emit.bp',
    '/effects/emitters/microwave_laser_end_05_emit.bp',
--    '/effects/emitters/microwave_laser_end_06_emit.bp',
}

CMissileHit01 = DefaultMissileHit01

CMissileHit02a = {
    '/effects/emitters/cybran_iridium_hit_unit_01_emit.bp',
    '/effects/emitters/cybran_iridium_hit_land_01_emit.bp',
    '/effects/emitters/cybran_iridium_hit_land_02_emit.bp',
    '/effects/emitters/cybran_iridium_hit_ring_01_emit.bp',
}

CMissileHit02b = {
    '/effects/emitters/cybran_corsair_missile_glow_hit_unit_01_emit.bp',
}

CMissileHit02 = TableCat( FireCloudSml01, FlashSml01, FlareSml01, CMissileHit02a )

CMissileLOAHit01 = {
    '/effects/emitters/cybran_missile_hit_01_emit.bp',
    '/effects/emitters/cybran_missile_hit_02_emit.bp',
}


CMolecularResonanceHitUnit01 = {
    '/effects/emitters/cybran_light_artillery_hit_01_emit.bp',
    '/effects/emitters/cybran_light_artillery_hit_02_emit.bp',
}

CMolecularResonanceHitLand01 = {
    '/effects/emitters/dust_cloud_06_emit.bp',
    '/effects/emitters/dirtchunks_01_emit.bp',
    '/effects/emitters/molecular_resonance_cannon_ring_02_emit.bp',
}

--  CYBRAN MOLECULAR RIPPER CANNON EMITTERS
CMolecularRipperFlash01 = {
	'/effects/emitters/molecular_ripper_flash_01_emit.bp',
	'/effects/emitters/molecular_ripper_flash_02_emit.bp',	
	'/effects/emitters/molecular_ripper_charge_01_emit.bp',		
	'/effects/emitters/molecular_ripper_charge_02_emit.bp',
	'/effects/emitters/molecular_cannon_muzzle_flash_01_emit.bp',
	'/effects/emitters/molecular_cannon_muzzle_flash_02_emit.bp',	
}
CMolecularRipperOverChargeFlash01 = {
	'/effects/emitters/molecular_ripper_flash_01_emit.bp',
	'/effects/emitters/molecular_ripper_oc_charge_01_emit.bp',
	'/effects/emitters/molecular_ripper_oc_charge_02_emit.bp',					
	'/effects/emitters/molecular_ripper_oc_charge_03_emit.bp',		
	'/effects/emitters/molecular_cannon_muzzle_flash_01_emit.bp',
	'/effects/emitters/default_muzzle_flash_01_emit.bp',		
	'/effects/emitters/default_muzzle_flash_02_emit.bp'				
}
CMolecularCannon01 = {
	'/effects/emitters/molecular_ripper_01_emit.bp',
	'/effects/emitters/molecular_ripper_02_emit.bp',
	'/effects/emitters/molecular_ripper_03_emit.bp',	
}
CMolecularRipperHit01 = {   
    '/effects/emitters/molecular_ripper_hit_01_emit.bp', 
    '/effects/emitters/molecular_ripper_hit_02_emit.bp',
    '/effects/emitters/molecular_ripper_hit_03_emit.bp',  
    '/effects/emitters/molecular_ripper_hit_04_emit.bp',    
    '/effects/emitters/molecular_ripper_hit_05_emit.bp',        
    '/effects/emitters/molecular_ripper_hit_06_emit.bp',        
    '/effects/emitters/molecular_ripper_hit_07_emit.bp',     
}

CNeutronClusterBombHit01 = {
    '/effects/emitters/neutron_cluster_bomb_hit_01_emit.bp',
    '/effects/emitters/neutron_cluster_bomb_hit_02_emit.bp',
}
CNeutronClusterBombHitUnit01 = CNeutronClusterBombHit01
CNeutronClusterBombHitLand01 = CNeutronClusterBombHit01
CNeutronClusterBombHitWater01 = CNeutronClusterBombHit01

CParticleCannonHit01 = { '/effects/emitters/laserturret_hit_flash_01_emit.bp',}
CParticleCannonHitUnit01 = TableCat( CParticleCannonHit01, UnitHitShrapnel01 )
CParticleCannonHitLand01 = TableCat( CParticleCannonHit01 )

CProtonBombHit01 = {
    '/effects/emitters/proton_bomb_hit_01_emit.bp',
    '/effects/emitters/proton_bomb_hit_02_emit.bp',
}

CHvyProtonCannonMuzzleflash = {
	'/effects/emitters/hvyproton_cannon_muzzle_01_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_02_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_03_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_04_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_05_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_06_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_07_emit.bp',
	'/effects/emitters/hvyproton_cannon_muzzle_08_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_10_emit.bp',
}
CHvyProtonCannonHit01 = {
	'/effects/emitters/hvyproton_cannon_hit_01_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_02_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_03_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_04_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_05_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_07_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_09_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_10_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_distort_emit.bp',
}
CHvyProtonCannonHit02 = {
    '/effects/emitters/hvyproton_cannon_hit_06_emit.bp',
    '/effects/emitters/hvyproton_cannon_hit_08_emit.bp',
}
CHvyProtonCannonHitLand = TableCat( CHvyProtonCannonHit01, CHvyProtonCannonHit02 )
CHvyProtonCannonHitUnit01 = {
	'/effects/emitters/hvyproton_cannon_hitunit_01_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_02_emit.bp', 
	'/effects/emitters/hvyproton_cannon_hit_03_emit.bp',  
	'/effects/emitters/hvyproton_cannon_hitunit_04_emit.bp', 
	'/effects/emitters/hvyproton_cannon_hitunit_05_emit.bp',  
	'/effects/emitters/hvyproton_cannon_hitunit_06_emit.bp', 
	'/effects/emitters/hvyproton_cannon_hitunit_07_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_08_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_09_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_10_emit.bp',
	'/effects/emitters/hvyproton_cannon_hit_distort_emit.bp',
}
CHvyProtonCannonHitUnit = TableCat( CHvyProtonCannonHitUnit01, UnitHitShrapnel01 )
CHvyProtonCannonPolyTrail =  '/effects/emitters/hvyproton_cannon_polytrail_01_emit.bp'
CHvyProtonCannonFXTrail01 =  { '/effects/emitters/hvyproton_cannon_fxtrail_01_emit.bp' }

CProtonCannonHit01 = {
     '/effects/emitters/proton_cannon_hit_01_emit.bp',
}

CProtonCannonPolyTrail =  '/effects/emitters/proton_cannon_polytrail_01_emit.bp'
CProtonCannonPolyTrail02 =  '/effects/emitters/proton_cannon_polytrail_02_emit.bp'
CProtonCannonFXTrail01 =  { '/effects/emitters/proton_cannon_fxtrail_01_emit.bp' }
CProtonCannonFXTrail02 =  { '/effects/emitters/proton_cannon_fxtrail_02_emit.bp' }
CProtonArtilleryPolytrail01 = '/effects/emitters/proton_artillery_polytrail_01_emit.bp'
CProtonArtilleryHit01 = {
    '/effects/emitters/proton_bomb_hit_02_emit.bp',
    '/effects/emitters/proton_artillery_hit_01_emit.bp',    
    '/effects/emitters/proton_artillery_hit_02_emit.bp',        
    '/effects/emitters/proton_artillery_hit_03_emit.bp',            
    '/effects/emitters/shockwave_01_emit.bp',    
}

CTorpedoUnitHit01 = TableCat( DefaultProjectileWaterImpact, DefaultProjectileUnderWaterImpact )

CZealotLaunch01 = {
    '/effects/emitters/muzzle_flash_01_emit.bp',
    '/effects/emitters/zealot_launch_01_emit.bp',
    '/effects/emitters/zealot_launch_02_emit.bp', 
}

CKrilTorpedoLauncherMuzzleFlash01 = {
    '/effects/emitters/muzzle_flash_02_emit.bp',
	'/effects/emitters/muzzle_smoke_01_emit.bp',
}

CMobileKamikazeBombExplosion = {
	'/effects/emitters/cybran_kamibomb_hit_01_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_02_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_03_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_04_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_05_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_06_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_07_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_08_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_09_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_10_emit.bp',
	'/effects/emitters/cybran_kamibomb_hit_11_emit.bp',
}

CMobileKamikazeBombDeathExplosion = {
	'/effects/emitters/cybran_kamibomb_hit_02_emit.bp',  ###Chaf that is thrown about.
	'/effects/emitters/cybran_kamibomb_hit_04_emit.bp',  ###Largest main explosion cloud.
	'/effects/emitters/cybran_kamibomb_hit_05_emit.bp',  ###Darkening.
	'/effects/emitters/cybran_kamibomb_hit_08_emit.bp',  ###Small main core explosion.
	'/effects/emitters/cybran_kamibomb_hit_11_emit.bp',  ###Smoke after the explosion.
	'/effects/emitters/cybran_kamibomb_hit_12_emit.bp',  ###Yellow explosion flash.
	'/effects/emitters/cybran_kamibomb_hit_13_emit.bp',  ###Yellow explosion flash.
}

--- UEF PROJECTILES (previously Terran) ###

-- ANTI-MATTER SHELL EMITTERS
TAntiMatterShellHit01 = {
    '/effects/emitters/antimatter_hit_01_emit.bp',	##	glow	
    '/effects/emitters/antimatter_hit_02_emit.bp',	##	flash	     
    '/effects/emitters/antimatter_hit_03_emit.bp', 	##	sparks
    '/effects/emitters/antimatter_hit_04_emit.bp',	##	plume fire
    '/effects/emitters/antimatter_hit_05_emit.bp',	##	plume dark 
    '/effects/emitters/antimatter_hit_06_emit.bp',	##	base fire
    '/effects/emitters/antimatter_hit_07_emit.bp',	##	base dark 
    '/effects/emitters/antimatter_hit_08_emit.bp',	##	plume smoke
    '/effects/emitters/antimatter_hit_09_emit.bp',	##	base smoke
    '/effects/emitters/antimatter_hit_10_emit.bp',	##	plume highlights
    '/effects/emitters/antimatter_hit_11_emit.bp',	##	base highlights
    '/effects/emitters/antimatter_ring_01_emit.bp',	##	ring14
    '/effects/emitters/antimatter_ring_02_emit.bp',	##	ring11	         
}

TAntiMatterShellHit02 = {
	'/effects/emitters/antimatter_hit_12_emit.bp',	
	'/effects/emitters/antimatter_hit_13_emit.bp',	     
	'/effects/emitters/antimatter_hit_14_emit.bp',   
	'/effects/emitters/antimatter_hit_15_emit.bp',  
	'/effects/emitters/antimatter_hit_16_emit.bp',
	'/effects/emitters/antimatter_ring_03_emit.bp',	
	'/effects/emitters/antimatter_ring_04_emit.bp',	     
	'/effects/emitters/quark_bomb_explosion_06_emit.bp',	    
}

-- APDS EMITTERS
TAPDSHit01 = {
	'/effects/emitters/uef_t2_artillery_hit_01_emit.bp',
	'/effects/emitters/uef_t2_artillery_hit_02_emit.bp',
	'/effects/emitters/uef_t2_artillery_hit_03_emit.bp',
	'/effects/emitters/uef_t2_artillery_hit_04_emit.bp',
	'/effects/emitters/uef_t2_artillery_hit_05_emit.bp',
	'/effects/emitters/uef_t2_artillery_hit_06_emit.bp',
	'/effects/emitters/uef_t2_artillery_hit_07_emit.bp',
}

TAPDSHitUnit01 = TableCat( TAPDSHit01, UnitHitShrapnel01 )

TIFArtilleryMuzzleFlash = {
    '/effects/emitters/cannon_artillery_muzzle_flash_01_emit.bp',
    #'/effects/emitters/cannon_muzzle_smoke_06_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_07_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_10_emit.bp',
    '/effects/emitters/cannon_muzzle_flash_03_emit.bp',
}

-- COMMANDER OVERCHARGE WEAPON EMITTERS
TCommanderOverchargeFlash01 = {
    '/effects/emitters/terran_commander_overcharge_flash_01_emit.bp',
}
TCommanderOverchargeFXTrail01 = {
    '/effects/emitters/terran_commander_overcharge_trail_01_emit.bp',
    '/effects/emitters/terran_commander_overcharge_trail_02_emit.bp',
}
TCommanderOverchargeHit01 = {
    '/effects/emitters/quantum_hit_flash_07_emit.bp',
    '/effects/emitters/terran_commander_overcharge_hit_01_emit.bp',
    '/effects/emitters/terran_commander_overcharge_hit_02_emit.bp',
    '/effects/emitters/terran_commander_overcharge_hit_03_emit.bp',
    '/effects/emitters/terran_commander_overcharge_hit_04_emit.bp',
}

-- FLAK CANNON EMITTERS
TFlakCannonMuzzleFlash01 = {
	'/effects/emitters/cannon_muzzle_flash_05_emit.bp',
	'/effects/emitters/cannon_muzzle_fire_02_emit.bp',
    '/effects/emitters/muzzle_sparks_01_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_09_emit.bp', 		
}
TFragmentationShell01 = {
	'/effects/emitters/fragmentation_shell_phosphor_01_emit.bp',
    '/effects/emitters/fragmentation_shell_hit_flash_01_emit.bp',
    '/effects/emitters/fragmentation_shell_shrapnel_01_emit.bp',
    '/effects/emitters/fragmentation_shell_smoke_01_emit.bp',
    '/effects/emitters/fragmentation_shell_smoke_02_emit.bp',
}

-- FRAGMENTATION SENSOR SHELL EMITTERS
TFragmentationSensorShellFrag = {
    '/effects/emitters/terran_fragmentation_bomb_split_01_emit.bp',
    '/effects/emitters/terran_fragmentation_bomb_split_02_emit.bp',
}
TFragmentationSensorShellHit = {
    #'/effects/emitters/plasma_cannon_hit_01_emit.bp',
    '/effects/emitters/terran_fragmentation_bomb_hit_01_emit.bp',
    '/effects/emitters/terran_fragmentation_bomb_hit_02_emit.bp',
    '/effects/emitters/terran_fragmentation_bomb_hit_03_emit.bp',
    '/effects/emitters/terran_fragmentation_bomb_hit_04_emit.bp',
    '/effects/emitters/terran_fragmentation_bomb_hit_05_emit.bp',
}
TFragmentationSensorShellTrail = {
    '/effects/emitters/mortar_munition_02_emit.bp',
    '/effects/emitters/mortar_munition_02_flare_emit.bp',
}

-- GAUSS CANNON EMITTERS
TGaussCannonFlash = {
    '/effects/emitters/gauss_cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/gauss_cannon_muzzle_flash_02_emit.bp',
    '/effects/emitters/gauss_cannon_muzzle_smoke_02_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_09_emit.bp', 
}
TGaussCannonHit01 = {
    '/effects/emitters/gauss_cannon_hit_01_emit.bp',
    '/effects/emitters/gauss_cannon_hit_02_emit.bp',
    '/effects/emitters/gauss_cannon_hit_03_emit.bp',    
    '/effects/emitters/gauss_cannon_hit_04_emit.bp',
    '/effects/emitters/gauss_cannon_hit_05_emit.bp',
}
TGaussCannonHit02 = {
    '/effects/emitters/gauss_cannon_hit_01_emit.bp',
    '/effects/emitters/gauss_cannon_hit_02_emit.bp',
    '/effects/emitters/gauss_cannon_hit_03_emit.bp',        
    '/effects/emitters/gauss_cannon_hit_04_emit.bp',
    '/effects/emitters/gauss_cannon_hit_05_emit.bp',
}
TGaussCannonHitUnit01 = TableCat( TGaussCannonHit01, UnitHitShrapnel01 )
TGaussCannonHitLand01 = TGaussCannonHit01
TGaussCannonHitUnit02 = TableCat( TGaussCannonHit02, UnitHitShrapnel01 )
TGaussCannonHitLand02 = TGaussCannonHit02
TGaussCannonPolyTrail =  {
    '/effects/emitters/gauss_cannon_polytrail_01_emit.bp',
    '/effects/emitters/gauss_cannon_polytrail_02_emit.bp',    
}

-- adjustments for UES0302
TShipGaussCannonFlash = {
    '/effects/emitters/cannon_muzzle_fire_01_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_03_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_04_emit.bp', 
    #'/effects/emitters/cannon_muzzle_smoke_05_emit.bp',     
    '/effects/emitters/cannon_muzzle_water_shock_01_emit.bp',
    '/effects/emitters/cannon_muzzle_flash_06_emit.bp',    
    '/effects/emitters/cannon_muzzle_flash_07_emit.bp',  
}

TLandGaussCannonFlash = {
    '/effects/emitters/cannon_muzzle_fire_01_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_03_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_04_emit.bp', 
    #'/effects/emitters/cannon_muzzle_smoke_05_emit.bp',     
    #'/effects/emitters/cannon_muzzle_water_shock_01_emit.bp',
    '/effects/emitters/cannon_muzzle_flash_09_emit.bp',    
    '/effects/emitters/cannon_muzzle_flash_08_emit.bp',  
}

TShipGaussCannonHit01 = {
	'/effects/emitters/shipgauss_cannon_hit_01_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_02_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_03_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_04_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_05_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_06_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_07_emit.bp',
	#'/effects/emitters/shipgauss_cannon_hit_08_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_09_emit.bp',
}

TShipGaussCannonHit02 = {
	'/effects/emitters/shipgauss_cannon_hit_01_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_02_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_03_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_10_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_11_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_06_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_07_emit.bp',
	#'/effects/emitters/shipgauss_cannon_hit_08_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_09_emit.bp',
}

TLandGaussCannonHit01 = {
	'/effects/emitters/landgauss_cannon_hit_01_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_02_emit.bp',
	'/effects/emitters/landgauss_cannon_hit_03_emit.bp',
	'/effects/emitters/landgauss_cannon_hit_04_emit.bp',
	'/effects/emitters/landgauss_cannon_hit_05_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_06_emit.bp',
	#'/effects/emitters/shipgauss_cannon_hit_07_emit.bp',
	'/effects/emitters/shipgauss_cannon_hit_09_emit.bp',
}

TShipGaussCannonHitUnit01 = TableCat( TShipGaussCannonHit01, UnitHitShrapnel01 )
TShipGaussCannonHitUnit02 = TableCat( TShipGaussCannonHit02, UnitHitShrapnel01 )
TLandGaussCannonHitUnit01 = TableCat( TLandGaussCannonHit01, UnitHitShrapnel01 )

TAAGinsuHitLand = {
    '/effects/emitters/ginsu_laser_hit_land_01_emit.bp',
}
TAAGinsuHitUnit = {
    '/effects/emitters/ginsu_laser_hit_unit_01_emit.bp',
    '/effects/emitters/laserturret_hit_flash_03_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}

THeavyFragmentationGrenadeMuzzleFlash = {
    '/effects/emitters/terran_fragmentation_grenade_muzzle_flash_01_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_muzzle_flash_02_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_muzzle_flash_03_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_muzzle_flash_04_emit.bp',
}
THeavyFragmentationGrenadeHit = {
    '/effects/emitters/terran_fragmentation_grenade_hit_01_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_02_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_03_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_04_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_05_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_06_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_07_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_08_emit.bp',
}
THeavyFragmentationGrenadeUnitHit = {
    '/effects/emitters/terran_fragmentation_grenade_hit_01_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_02_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_03_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_04_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_05_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_06_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_07_emit.bp',
    '/effects/emitters/terran_fragmentation_grenade_hit_08_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
THeavyFragmentationGrenadeFxTrails = {
    '/effects/emitters/terran_fragmentation_grenade_fxtrail_01_emit.bp',
}
THeavyFragmentationGrenadePolyTrail = '/effects/emitters/default_polytrail_02_emit.bp'

TNapalmHvyCarpetBombHitUnit01 = { 
	'/effects/emitters/flash_01_emit.bp',
}
TNapalmHvyCarpetBombHitLand01 = {
    '/effects/emitters/napalm_hvy_flash_emit.bp',
    '/effects/emitters/napalm_hvy_thick_smoke_emit.bp',
    '/effects/emitters/napalm_hvy_thin_smoke_emit.bp',
    '/effects/emitters/napalm_hvy_01_emit.bp',
    '/effects/emitters/napalm_hvy_02_emit.bp',
    '/effects/emitters/napalm_hvy_03_emit.bp',
}
TNapalmHvyCarpetBombHitWater01 = {
    '/effects/emitters/napalm_hvy_waterflash_emit.bp',
    '/effects/emitters/napalm_hvy_water_smoke_emit.bp',
    '/effects/emitters/napalm_hvy_oilslick_emit.bp',
    '/effects/emitters/napalm_hvy_lines_emit.bp',
    '/effects/emitters/napalm_hvy_water_ripples_emit.bp',
    '/effects/emitters/napalm_hvy_water_dots_emit.bp',    
}

TPlasmaCannonHeavyMuzzleFlash = {
    '/effects/emitters/plasma_cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/plasma_cannon_muzzle_flash_02_emit.bp',
    '/effects/emitters/cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/heavy_plasma_cannon_hitunit_05_emit.bp',
}
TPlasmaCannonHeavyHit02 = {
    '/effects/emitters/heavy_plasma_cannon_hit_01_emit.bp',
    '/effects/emitters/heavy_plasma_cannon_hit_02_emit.bp',
    '/effects/emitters/heavy_plasma_cannon_hit_03_emit.bp',
    '/effects/emitters/heavy_plasma_cannon_hit_04_emit.bp',
    '/effects/emitters/heavy_plasma_cannon_hit_05_emit.bp',
}
TPlasmaCannonHeavyHit03 = {
    '/effects/emitters/heavy_plasma_cannon_hit_05_emit.bp',
}
TPlasmaCannonHeavyHit04 = {
    '/effects/emitters/heavy_plasma_cannon_hitunit_05_emit.bp',
}
TPlasmaCannonHeavyHit01 = TableCat( TPlasmaCannonHeavyHit02, TPlasmaCannonHeavyHit03 )
TPlasmaCannonHeavyHitUnit01 = TableCat( TPlasmaCannonHeavyHit02, TPlasmaCannonHeavyHit04, UnitHitShrapnel01 )

TPlasmaCannonHeavyMunition = {
    '/effects/emitters/plasma_cannon_trail_02_emit.bp',
}
TPlasmaCannonHeavyMunition02 = {
    '/effects/emitters/plasma_cannon_trail_03_emit.bp',
}
TPlasmaCannonHeavyPolyTrails = {
    '/effects/emitters/plasma_cannon_polytrail_01_emit.bp',
    '/effects/emitters/plasma_cannon_polytrail_02_emit.bp',
    '/effects/emitters/plasma_cannon_polytrail_03_emit.bp',
}


THeavyPlasmaGatlingCannonHit = {
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_hit_01_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_hit_02_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_hit_03_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_hit_04_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_hit_05_emit.bp',    
}
THeavyPlasmaGatlingCannonHit02 = {
}
THeavyPlasmaGatlingCannonHitUnit = TableCat( THeavyPlasmaGatlingCannonHit, THeavyPlasmaGatlingCannonHit02, UnitHitShrapnel01 )
THeavyPlasmaGatlingCannonMuzzleFlash = {
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_muzzle_flash_01_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_muzzle_flash_02_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_muzzle_flash_03_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_muzzle_flash_04_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_muzzle_flash_05_emit.bp',
    '/effects/emitters/heavy_plasma_gatling_cannon_laser_muzzle_flash_06_emit.bp',
}
THeavyPlasmaGatlingCannonFxTrails = {
    #'/effects/emitters/heavy_plasma_gatling_cannon_laser_fxtrail_01_emit.bp',
    ##'/effects/emitters/heavy_plasma_gatling_cannon_laser_fxtrail_02_emit.bp',
    ###'/effects/emitters/heavy_plasma_gatling_cannon_laser_fxtrail_03_emit.bp',
}
THeavyPlasmaGatlingCannonPolyTrail = '/effects/emitters/heavy_plasma_gatling_cannon_laser_polytrail_01_emit.bp'

THiroLaserMuzzleFlash = {
    '/effects/emitters/hiro_laser_cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/hiro_laser_cannon_muzzle_flash_02_emit.bp',
}
THiroLaserPolytrail =  '/effects/emitters/hiro_laser_cannon_polytrail_01_emit.bp'
THiroLaserFxtrails =  {
	'/effects/emitters/hiro_laser_cannon_fxtrail_01_emit.bp',
	'/effects/emitters/hiro_laser_cannon_fxtrail_02_emit.bp',
	'/effects/emitters/hiro_laser_cannon_fxtrail_03_emit.bp',
}
THiroLaserHit = {
    '/effects/emitters/hiro_laser_cannon_hit_01_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_02_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_03_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_04_emit.bp',
}
THiroLaserUnitHit = {
    '/effects/emitters/hiro_laser_cannon_hit_01_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_02_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_03_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_04_emit.bp',
    '/effects/emitters/hiro_laser_cannon_land_hit_01_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
THiroLaserLandHit = {
    '/effects/emitters/hiro_laser_cannon_hit_01_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_02_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_03_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_04_emit.bp',
    '/effects/emitters/hiro_laser_cannon_hit_05_emit.bp',
}

TDFHiroGeneratorMuzzle01 = {
    '/effects/emitters/hiro_beam_generator_muzzle_01_emit.bp', 
    '/effects/emitters/hiro_beam_generator_muzzle_02_emit.bp', 
    '/effects/emitters/hiro_beam_generator_muzzle_03_emit.bp', 
    '/effects/emitters/hiro_beam_generator_muzzle_04_emit.bp',
}
TDFHiroGeneratorHitLand = {
    '/effects/emitters/hiro_beam_generator_hit_01_emit.bp',
    '/effects/emitters/hiro_beam_generator_hit_02_emit.bp',
    '/effects/emitters/hiro_beam_generator_hit_03_emit.bp',
    '/effects/emitters/hiro_beam_generator_hit_04_emit.bp',
    '/effects/emitters/hiro_beam_generator_hit_05_emit.bp',
}
TDFHiroGeneratorBeam = {
	'/effects/emitters/hiro_beam_generator_beam_emit.bp',
}

TIonizedPlasmaGatlingCannonHit01 = {
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hit_01_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hit_02_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hit_03_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hit_04_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hit_05_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hit_06_emit.bp',
}
TIonizedPlasmaGatlingCannonHit02 = {
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_land_hit_01_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_land_hit_02_emit.bp',
}
TIonizedPlasmaGatlingCannonHit03 = {
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hitunit_01_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hitunit_03_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_hitunit_06_emit.bp',
}
TIonizedPlasmaGatlingCannonUnitHit = TableCat( TIonizedPlasmaGatlingCannonHit01, TIonizedPlasmaGatlingCannonHit03, UnitHitShrapnel01 )
TIonizedPlasmaGatlingCannonHit = TableCat( TIonizedPlasmaGatlingCannonHit01, TIonizedPlasmaGatlingCannonHit02 )
TIonizedPlasmaGatlingCannonMuzzleFlash = {
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_muzzle_flash_01_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_muzzle_flash_02_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_muzzle_flash_03_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_muzzle_flash_04_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_muzzle_flash_05_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_muzzle_flash_06_emit.bp',
}
TIonizedPlasmaGatlingCannonFxTrails = {
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_fxtrail_01_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_fxtrail_02_emit.bp',
    '/effects/emitters/ionized_plasma_gatling_cannon_laser_fxtrail_03_emit.bp',
}
TIonizedPlasmaGatlingCannonPolyTrail = '/effects/emitters/ionized_plasma_gatling_cannon_laser_polytrail_01_emit.bp'

TMachineGunPolyTrail =  '/effects/emitters/machinegun_polytrail_01_emit.bp'

TAAMissileLaunch = {
    '/effects/emitters/terran_sam_launch_smoke_emit.bp',
    '/effects/emitters/terran_sam_launch_smoke2_emit.bp',
}
TAAMissileLaunchNoBackSmoke = {
    '/effects/emitters/terran_sam_launch_smoke_emit.bp',
}
TMissileExhaust01 = { '/effects/emitters/missile_munition_trail_01_emit.bp',}
TMissileExhaust02 = { '/effects/emitters/missile_munition_trail_02_emit.bp',}
TMissileExhaust03 = { '/effects/emitters/missile_smoke_exhaust_02_emit.bp',}

TMobileMortarMuzzleEffect01 = {
    '/effects/emitters/cannon_muzzle_smoke_02_emit.bp',
    '/effects/emitters/cannon_muzzle_smoke_09_emit.bp',     
    '/effects/emitters/cannon_artillery_fire_01_emit.bp',     
    '/effects/emitters/cannon_artillery_flash_01_emit.bp',      
}

TNapalmCarpetBombHitUnit01 = { 
	'/effects/emitters/flash_01_emit.bp',
}
TNapalmCarpetBombHitLand01 = {
    '/effects/emitters/napalm_flash_emit.bp',
    '/effects/emitters/napalm_thick_smoke_emit.bp',
    #'/effects/emitters/napalm_fire_emit.bp',
    '/effects/emitters/napalm_thin_smoke_emit.bp',
    '/effects/emitters/napalm_01_emit.bp',
    '/effects/emitters/napalm_02_emit.bp',
    '/effects/emitters/napalm_03_emit.bp',
}
TNapalmCarpetBombHitWater01 = {
    '/effects/emitters/napalm_hvy_waterflash_emit.bp',
    '/effects/emitters/napalm_hvy_water_smoke_emit.bp',
    '/effects/emitters/napalm_hvy_oilslick_emit.bp',
    '/effects/emitters/napalm_hvy_lines_emit.bp',
    '/effects/emitters/napalm_hvy_water_ripples_emit.bp',
    '/effects/emitters/napalm_hvy_water_dots_emit.bp',  
}

TNukeRings01 = {
    '/effects/emitters/nuke_concussion_ring_01_emit.bp',
	'/effects/emitters/nuke_concussion_ring_02_emit.bp',
}
TNukeFlavorPlume01 = { '/effects/emitters/nuke_smoke_trail01_emit.bp', }
TNukeGroundConvectionEffects01 = { '/effects/emitters/nuke_mist_01_emit.bp', }
TNukeBaseEffects01 = { '/effects/emitters/nuke_base03_emit.bp', }
TNukeBaseEffects02 = { '/effects/emitters/nuke_base05_emit.bp', }
TNukeHeadEffects01 = { '/effects/emitters/nuke_plume_01_emit.bp', }
TNukeHeadEffects02 = { 
	'/effects/emitters/nuke_head_smoke_03_emit.bp',
	'/effects/emitters/nuke_head_smoke_04_emit.bp',
		
}
TNukeHeadEffects03 = { '/effects/emitters/nuke_head_fire_01_emit.bp', }

TRailGunMuzzleFlash01 = { '/effects/emitters/railgun_flash_02_emit.bp', }
TRailGunMuzzleFlash02 = { '/effects/emitters/muzzle_flash_01_emit.bp', }
TRailGunHitAir01 = {
	'/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
	'/effects/emitters/terran_railgun_hit_air_01_emit.bp',
	'/effects/emitters/terran_railgun_hit_air_02_emit.bp',
	'/effects/emitters/terran_railgun_hit_air_03_emit.bp',
}
TRailGunHitGround01 = {
	'/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
	'/effects/emitters/terran_railgun_hit_ground_01_emit.bp',
	'/effects/emitters/terran_railgun_hit_air_02_emit.bp',
	'/effects/emitters/terran_railgun_hit_ground_03_emit.bp',
}

TRiotGunHit01 = {
     '/effects/emitters/riot_gun_hit_01_emit.bp',
     '/effects/emitters/riot_gun_hit_02_emit.bp',
     '/effects/emitters/riot_gun_hit_03_emit.bp',
}
TRiotGunHitUnit01 = TableCat( TRiotGunHit01, UnitHitShrapnel01 )
TRiotGunHit02 = {
     '/effects/emitters/riot_gun_hit_04_emit.bp',
     '/effects/emitters/riot_gun_hit_05_emit.bp',
     '/effects/emitters/riot_gun_hit_06_emit.bp',
}
TRiotGunHitUnit02 = TableCat( TRiotGunHit02, UnitHitShrapnel01 )
TRiotGunMuzzleFx = {
	'/effects/emitters/riotgun_muzzle_fire_01_emit.bp',
	'/effects/emitters/riotgun_muzzle_flash_01_emit.bp',
	#'/effects/emitters/riotgun_muzzle_smoke_01_emit.bp',
	'/effects/emitters/riotgun_muzzle_sparks_01_emit.bp',
    '/effects/emitters/cannon_muzzle_flash_01_emit.bp',
}
TRiotGunMuzzleFxTank = {
	'/effects/emitters/riotgun_muzzle_fire_01_emit.bp',
	'/effects/emitters/riotgun_muzzle_flash_03_emit.bp',
	#'/effects/emitters/riotgun_muzzle_smoke_01_emit.bp',
	'/effects/emitters/riotgun_muzzle_sparks_02_emit.bp',
    #'/effects/emitters/cannon_muzzle_flash_01_emit.bp',
}
TRiotGunPolyTrails = {
    '/effects/emitters/riot_gun_polytrail_01_emit.bp',
    '/effects/emitters/riot_gun_polytrail_02_emit.bp',
    '/effects/emitters/riot_gun_polytrail_03_emit.bp',
}
TRiotGunPolyTrailsTank = {
    '/effects/emitters/riot_gun_polytrail_tank_01_emit.bp',
    '/effects/emitters/riot_gun_polytrail_tank_02_emit.bp',
    '/effects/emitters/riot_gun_polytrail_tank_03_emit.bp',
}
TRiotGunPolyTrailsEngineer = {
    '/effects/emitters/riot_gun_polytrail_engi_01_emit.bp',
    '/effects/emitters/riot_gun_polytrail_engi_02_emit.bp',
    '/effects/emitters/riot_gun_polytrail_engi_03_emit.bp',
}
TRiotGunPolyTrailsOffsets = {0.05,0.05,0.05}

TRiotGunMunition01 = {
    '/effects/emitters/riotgun_munition_01_emit.bp',
}

TPhalanxGunPolyTrails = {
    '/effects/emitters/phalanx_munition_polytrail_01_emit.bp',
}
TPhalanxGunMuzzleFlash = {
    '/effects/emitters/phalanx_muzzle_flash_01_emit.bp',
    '/effects/emitters/phalanx_muzzle_glow_01_emit.bp',
}
TPhalanxGunShells = {
    '/effects/emitters/phalanx_shells_01_emit.bp',
}
TPhalanxGunPolyTrailsOffsets = {0.05,0.05,0.05}

TPlasmaCannonLightMuzzleFlash = {
    '/effects/emitters/plasma_cannon_muzzle_flash_03_emit.bp',
    '/effects/emitters/plasma_cannon_muzzle_flash_04_emit.bp',    
}
TPlasmaCannonLightHit01 = {
    '/effects/emitters/plasma_cannon_hit_01_emit.bp',
    '/effects/emitters/plasma_cannon_hit_02_emit.bp',
    '/effects/emitters/plasma_cannon_hit_03_emit.bp',
    '/effects/emitters/cannon_muzzle_flash_01_emit.bp',
}
TPlasmaCannonLightHitUnit01 = TPlasmaCannonLightHit01 
TPlasmaCannonLightHitLand01 = TPlasmaCannonLightHit01
TPlasmaCannonLightMunition = {
    '/effects/emitters/plasma_cannon_trail_01_emit.bp',
}
TPlasmaCannonLightPolyTrail = '/effects/emitters/plasma_cannon_polytrail_04_emit.bp'

TPlasmaGatlingCannonMuzzleFlash = {
    '/effects/emitters/terran_gatling_plasma_cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_muzzle_flash_02_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_muzzle_flash_03_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_muzzle_flash_04_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_muzzle_flash_05_emit.bp',
--    '/effects/emitters/terran_gatling_plasma_cannon_muzzle_flash_06_emit.bp',
}
TPlasmaGatlingCannonHit = {
    '/effects/emitters/terran_gatling_plasma_cannon_hit_01_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hit_02_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hit_03_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hit_04_emit.bp',
--    '/effects/emitters/terran_gatling_plasma_cannon_hit_05_emit.bp',
}
TPlasmaGatlingCannonUnitHit = {
    '/effects/emitters/terran_gatling_plasma_cannon_hit_01_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hitunit_01_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hitunit_02_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hitunit_03_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hitunit_04_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_hit_05_emit.bp',
--    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
TPlasmaGatlingCannonFxTrails = {
    '/effects/emitters/terran_gatling_plasma_cannon_trail_01_emit.bp',
}
TPlasmaGatlingCannonPolyTrails = {
    '/effects/emitters/terran_gatling_plasma_cannon_polytrail_01_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_polytrail_02_emit.bp',
    '/effects/emitters/terran_gatling_plasma_cannon_polytrail_03_emit.bp',
}
TPlasmaGatlingCannonPolyTrailsOffsets = {0.05,0.05,0.05}

TSmallYieldNuclearBombHit01 = {
    '/effects/emitters/terran_bomber_bomb_explosion_01_emit.bp',
    #'/effects/emitters/terran_bomber_bomb_explosion_02_emit.bp',
    '/effects/emitters/terran_bomber_bomb_explosion_03_emit.bp',
    '/effects/emitters/terran_bomber_bomb_explosion_05_emit.bp',
    '/effects/emitters/terran_bomber_bomb_explosion_06_emit.bp',
}

TIFCruiseMissileLaunchSmoke = {
    '/effects/emitters/terran_cruise_missile_launch_01_emit.bp',
    '/effects/emitters/terran_cruise_missile_launch_02_emit.bp',
}
TIFCruiseMissileLaunchBuilding = {
    '/effects/emitters/terran_cruise_missile_launch_03_emit.bp',
    '/effects/emitters/terran_cruise_missile_launch_04_emit.bp',
    '/effects/emitters/terran_cruise_missile_launch_05_emit.bp',
}
TIFCruiseMissileLaunchUnderWater = {
    '/effects/emitters/terran_cruise_missile_sublaunch_01_emit.bp',
}
TIFCruiseMissileLaunchExitWater = {
    '/effects/emitters/water_splash_ripples_ring_01_emit.bp',
    '/effects/emitters/water_splash_plume_01_emit.bp',
}

TMissileHit01 = {
    '/effects/emitters/terran_missile_hit_01_emit.bp',
    '/effects/emitters/terran_missile_hit_02_emit.bp',
    '/effects/emitters/terran_missile_hit_03_emit.bp',
    '/effects/emitters/terran_missile_hit_04_emit.bp',
}
TMissileHit02 = {
    '/effects/emitters/terran_missile_hit_01_emit.bp',
    '/effects/emitters/terran_missile_hit_02_emit.bp',
    '/effects/emitters/terran_missile_hit_03_emit.bp',
}

TTorpedoHitUnit01 = TableCat( DefaultProjectileWaterImpact, DefaultProjectileUnderWaterImpact )
TTorpedoHitUnitUnderwater01 = DefaultProjectileUnderWaterImpact

--- ###### SERAPHIM AMBIENTS ######

SerRiftIn_Small = {
    '/effects/emitters/seraphim_rift_in_small_01_emit.bp', 
    '/effects/emitters/seraphim_rift_in_small_02_emit.bp', 
}
SerRiftIn_SmallFlash = {
    '/effects/emitters/seraphim_rift_in_small_03_emit.bp', 
    '/effects/emitters/seraphim_rift_in_small_04_emit.bp', 
}

SerRiftIn_Large = {
    '/effects/emitters/seraphim_rift_in_large_01_emit.bp', 
    '/effects/emitters/seraphim_rift_in_large_02_emit.bp', 
}
SerRiftIn_LargeFlash = {
    '/effects/emitters/seraphim_rift_in_large_03_emit.bp', 
    '/effects/emitters/seraphim_rift_in_large_04_emit.bp', 
}

SAdjacencyAmbient01 = {
    '/effects/emitters/seraphim_adjacency_node_01_emit.bp',    
    '/effects/emitters/seraphim_adjacency_node_02_emit.bp',
--    '/effects/emitters/seraphim_adjacency_node_03_emit.bp',
}

SAdjacencyAmbient02 = {
    '/effects/emitters/seraphim_adjacency_node_01_emit.bp',    
    '/effects/emitters/seraphim_adjacency_node_02_emit.bp',
--    '/effects/emitters/seraphim_adjacency_node_03a_emit.bp',
}

SAdjacencyAmbient03 = {
    '/effects/emitters/seraphim_adjacency_node_01_emit.bp',    
    '/effects/emitters/seraphim_adjacency_node_02_emit.bp',
--    '/effects/emitters/seraphim_adjacency_node_03b_emit.bp',
}

--  SERAPHIM UYA-IYA POWER GENERATOR
ST1PowerAmbient = {
    '/effects/emitters/seraphim_t1_power_ambient_01_emit.bp',
--    '/effects/emitters/seraphim_t1_power_ambient_02_emit.bp',    
}
ST2PowerAmbient = {
    '/effects/emitters/seraphim_t2_power_ambient_01_emit.bp',
--    '/effects/emitters/seraphim_t2_power_ambient_02_emit.bp',    
}
ST3PowerAmbient = {
    '/effects/emitters/seraphim_t3power_ambient_01_emit.bp',
--    '/effects/emitters/seraphim_t3power_ambient_02_emit.bp',
--    '/effects/emitters/seraphim_t3power_ambient_04_emit.bp',
}
OthuyAmbientEmanation = {
    '/effects/emitters/seraphim_othuy_ambient_01_emit.bp',
    '/effects/emitters/seraphim_othuy_ambient_02_emit.bp',
    '/effects/emitters/seraphim_othuy_ambient_03_emit.bp',
    '/effects/emitters/seraphim_othuy_ambient_04_emit.bp',
    '/effects/emitters/seraphim_othuy_ambient_05_emit.bp',
    '/effects/emitters/seraphim_othuy_ambient_06_emit.bp',
}
OthuyElectricityStrikeBeam = {
    '/effects/emitters/seraphim_othuy_beam_01_emit.bp',
}
OthuyElectricityStrikeHit = {
    '/effects/emitters/seraphim_othuy_hit_01_emit.bp',
    '/effects/emitters/seraphim_othuy_hit_02_emit.bp',
    '/effects/emitters/seraphim_othuy_hit_03_emit.bp',
    '/effects/emitters/seraphim_othuy_hit_04_emit.bp',
}
OthuyElectricityStrikeMuzzleFlash = {
    '/effects/emitters/seraphim_othuy_beam_01_emit.bp',
}
SJammerCrystalAmbient = {
    '/effects/emitters/op_quantum_jammer_crystal.bp',
    '/effects/emitters/jammer_ambient_03_emit.bp',
}
SJammerTowerAmbient = {
    '/effects/emitters/op_seraphim_quantum_jammer_tower_emit.bp',
    '/effects/emitters/jammer_ambient_01_emit.bp',
}

SJammerTowerWire1Ambient = '/effects/emitters/op_seraphim_quantum_jammer_tower_wire_01_emit.bp'
SJammerTowerWire2Ambient = '/effects/emitters/op_seraphim_quantum_jammer_tower_wire_02_emit.bp'
SJammerTowerWire3Ambient = '/effects/emitters/op_seraphim_quantum_jammer_tower_wire_03_emit.bp'
SJammerTowerWire4Ambient = '/effects/emitters/op_seraphim_quantum_jammer_tower_wire_04_emit.bp'

--- ###### SERAPHIM PROJECTILES ######

SDFAireauWeaponPolytrails01 = {
    '/effects/emitters/seraphim_aireau_autocannon_polytrail_01_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_polytrail_02_emit.bp', 
    '/effects/emitters/seraphim_aireau_autocannon_polytrail_03_emit.bp',  
}
SDFAireauWeaponMuzzleFlash = {
    '/effects/emitters/seraphim_aireau_autocannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_muzzle_flash_03_emit.bp',
}
SDFAireauWeaponHit01 = {
    '/effects/emitters/seraphim_aireau_autocannon_hit_01_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_hit_02_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_hit_03_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_hit_04_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_hit_05_emit.bp',
}
SDFAireauWeaponHit02 = {
    '/effects/emitters/seraphim_aireau_autocannon_hitunit_04_emit.bp',
    '/effects/emitters/seraphim_aireau_autocannon_hitunit_05_emit.bp',
}
SDFAireauWeaponHitUnit = TableCat( SDFAireauWeaponHit01, SDFAireauWeaponHit02, UnitHitShrapnel01 )

SDFSinnutheWeaponMuzzleFlash = {
    '/effects/emitters/seraphim_sinnuthe_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_muzzle_flash_03_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_muzzle_flash_04_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_muzzle_flash_05_emit.bp',
}
SDFSinnutheWeaponChargeMuzzleFlash = {
    '/effects/emitters/seraphim_sinnuthe_muzzle_charge_01_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_muzzle_charge_02_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_muzzle_charge_03_emit.bp',
}
SDFSinnutheWeaponHit01 = {
    '/effects/emitters/seraphim_sinnuthe_hit_01_emit.bp',    
    '/effects/emitters/seraphim_sinnuthe_hit_02_emit.bp', 
    '/effects/emitters/seraphim_sinnuthe_hit_03_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_hit_05_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_hit_06_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_hit_07_emit.bp',  
    '/effects/emitters/seraphim_sinnuthe_hit_08_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_hit_09_emit.bp',
    '/effects/emitters/seraphim_sinnuthe_hit_10_emit.bp',
}
SDFSinnutheWeaponHit02 = {
    '/effects/emitters/seraphim_sinnuthe_hit_04_emit.bp',
}
SDFSinnutheWeaponHit03 = {
    '/effects/emitters/seraphim_sinnuthe_hitunit_04_emit.bp',
}
SDFSinnutheWeaponHit = TableCat( SDFSinnutheWeaponHit01, SDFSinnutheWeaponHit02 )
SDFSinnutheWeaponHitUnit = TableCat( SDFSinnutheWeaponHit01, SDFSinnutheWeaponHit03, UnitHitShrapnel01 )
SDFSinnutheWeaponFXTrails01 = {
	'/effects/emitters/seraphim_sinnuthe_fxtrails_01_emit.bp',
	'/effects/emitters/seraphim_sinnuthe_fxtrails_02_emit.bp',
	'/effects/emitters/seraphim_sinnuthe_fxtrails_03_emit.bp',
}

SDFExperimentalPhasonProjMuzzleFlash = {
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_flash_03_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_flash_04_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_flash_05_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_flash_06_emit.bp',
}
SDFExperimentalPhasonProjChargeMuzzleFlash = {
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_charge_01_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_charge_02_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_muzzle_charge_03_emit.bp',
}
SDFExperimentalPhasonProjHit01 = {
    '/effects/emitters/seraphim_experimental_phasonproj_hit_01_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_hit_02_emit.bp', 
    '/effects/emitters/seraphim_experimental_phasonproj_hit_03_emit.bp',  
    '/effects/emitters/seraphim_experimental_phasonproj_hit_04_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_hit_05_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_hit_06_emit.bp',
    '/effects/emitters/seraphim_experimental_phasonproj_hit_07_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_hit_08_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_hit_09_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_hit_10_emit.bp',
}
SDFExperimentalPhasonProjHit02 = {
    '/effects/emitters/seraphim_experimental_phasonproj_hitunit_01_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_hitunit_08_emit.bp',
}
SDFExperimentalPhasonProjHitUnit = TableCat( SDFExperimentalPhasonProjHit01, SDFExperimentalPhasonProjHit02, UnitHitShrapnel01 )
SDFExperimentalPhasonProjFXTrails01 = {
	'/effects/emitters/seraphim_experimental_phasonproj_fxtrails_01_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_fxtrails_02_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_fxtrails_03_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_fxtrails_04_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_fxtrails_05_emit.bp',
	'/effects/emitters/seraphim_experimental_phasonproj_fxtrails_06_emit.bp',
}


SDFAjelluAntiTorpedoLaunch01 = {
    '/effects/emitters/seraphim_ajellu_muzzle_flash_01_emit.bp', 
}
SDFAjelluAntiTorpedoPolyTrail01 = {
	'/effects/emitters/seraphim_ajellu_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_ajellu_polytrail_02_emit.bp',
}
SDFAjelluAntiTorpedoHit01 = {
    '/effects/emitters/seraphim_ajellu_hit_01_emit.bp',
    '/effects/emitters/seraphim_ajellu_hit_02_emit.bp',
    '/effects/emitters/seraphim_ajellu_hit_03_emit.bp',
    '/effects/emitters/seraphim_ajellu_hit_04_emit.bp',
}

SIFHuHit01 = DefaultMissileHit01
SIFHuImpact01 = DefaultProjectileAirUnitImpact
SIFHuLaunch01 = {
    '/effects/emitters/saint_launch_01_emit.bp', 
}

SIFInainoPreLaunch01 = {
	'/effects/emitters/seraphim_inaino_prelaunch_01_emit.bp',
	'/effects/emitters/seraphim_inaino_prelaunch_02_emit.bp',
	'/effects/emitters/seraphim_inaino_prelaunch_03_emit.bp',
}
SIFInainoLaunch01 = {
    '/effects/emitters/seraphim_inaino_launch_01_emit.bp',	## glow
    '/effects/emitters/seraphim_inaino_launch_02_emit.bp',	## plasma down
    '/effects/emitters/seraphim_inaino_launch_03_emit.bp',	## flash
    '/effects/emitters/seraphim_inaino_launch_04_emit.bp',	## plasma out
    '/effects/emitters/seraphim_inaino_launch_05_emit.bp',	## rings
}
SIFInainoHit01 = {
    '/effects/emitters/seraphim_inaino_hit_03_emit.bp',			## long glow
    '/effects/emitters/seraphim_inaino_hit_07_emit.bp',			## outer ring sucking in, ground oriented
    '/effects/emitters/seraphim_inaino_hit_08_emit.bp',			## fast flash
    '/effects/emitters/seraphim_inaino_concussion_04_emit.bp',	## ring slow
}
SIFInainoHit02 = {
    '/effects/emitters/seraphim_inaino_hit_01_emit.bp',		## ring alpha oriented
    '/effects/emitters/seraphim_inaino_hit_02_emit.bp',		## ring add oriented
    '/effects/emitters/seraphim_inaino_hit_03_emit.bp',		## long glow oriented
    '/effects/emitters/seraphim_inaino_hit_04_emit.bp',		## blue plasma lines add
    '/effects/emitters/seraphim_inaino_hit_05_emit.bp',		## ring add upwards
    '/effects/emitters/seraphim_inaino_hit_06_emit.bp',		## ring, darkening lines inward
}
SIFInainoDetonate01 = {
    '/effects/emitters/seraphim_inaino_explode_01_emit.bp',		## glow in air
    '/effects/emitters/seraphim_inaino_concussion_01_emit.bp',	## ring
    '/effects/emitters/seraphim_inaino_concussion_02_emit.bp',	## outward lines, faint add
    '/effects/emitters/seraphim_inaino_concussion_03_emit.bp',	## ring slow
    '/effects/emitters/seraphim_inaino_explode_02_emit.bp',		## faint plasma downward
    '/effects/emitters/seraphim_inaino_explode_03_emit.bp',		## vertical plasma, ser7 
	'/effects/emitters/seraphim_inaino_explode_04_emit.bp',		## ring outward add oriented 
	'/effects/emitters/seraphim_inaino_explode_05_emit.bp',		## glow on ground, oriented
    '/effects/emitters/seraphim_inaino_explode_06_emit.bp',		## fast flash in air
    '/effects/emitters/seraphim_inaino_explode_07_emit.bp',		## long glow in air, oriented
    '/effects/emitters/seraphim_inaino_explode_08_emit.bp',		## center plasma, ser7    
}
SIFInainoPlumeFxTrails01 = {
    '/effects/emitters/seraphim_inaino_plume_fxtrails_01_emit.bp',	## bright center
    '/effects/emitters/seraphim_inaino_plume_fxtrails_02_emit.bp',	## faint plasma trails
}
SIFInainoPlumeFxTrails02 = {
    '/effects/emitters/seraphim_inaino_plume_fxtrails_03_emit.bp',	## oriented glows
    '/effects/emitters/seraphim_inaino_plume_fxtrails_04_emit.bp',	## plasma
}
SIFInainoPlumeFxTrails03 = {
    '/effects/emitters/seraphim_inaino_plume_fxtrails_05_emit.bp',	## upwards nuke cloud   
    '/effects/emitters/seraphim_inaino_plume_fxtrails_06_emit.bp',	## upwards nuke cloud highlights 
}
SIFInainoHitRingProjectileFxTrails01 = {
    '/effects/emitters/seraphim_inaino_hitring_fxtrails_01_emit.bp',   
    '/effects/emitters/seraphim_inaino_hitring_fxtrails_02_emit.bp',
}

SIFExperimentalStrategicMissileChargeLaunch01 = {
	'/effects/emitters/seraphim_expnuke_prelaunch_01_emit.bp',	## glowy plasma at bottom
	'/effects/emitters/seraphim_expnuke_prelaunch_02_emit.bp',	## down / right lines 
	'/effects/emitters/seraphim_expnuke_prelaunch_03_emit.bp',	## down / left lines
	'/effects/emitters/seraphim_expnuke_prelaunch_04_emit.bp',	## up lines
	'/effects/emitters/seraphim_expnuke_prelaunch_05_emit.bp',	## down / right upward lines 
	'/effects/emitters/seraphim_expnuke_prelaunch_06_emit.bp',	## down / left upward lines
	'/effects/emitters/seraphim_expnuke_prelaunch_07_emit.bp',	## up upward lines
	'/effects/emitters/seraphim_expnuke_prelaunch_08_emit.bp',	## inward dark lines
	'/effects/emitters/seraphim_expnuke_prelaunch_09_emit.bp',	## blueish glow
}
SIFExperimentalStrategicMissileLaunch01 = {
    '/effects/emitters/seraphim_expnuke_launch_01_emit.bp',	## glow
    '/effects/emitters/seraphim_expnuke_launch_02_emit.bp',	## plasma down
    '/effects/emitters/seraphim_expnuke_launch_03_emit.bp',	## flash
    '/effects/emitters/seraphim_expnuke_launch_04_emit.bp',	## plasma out
    '/effects/emitters/seraphim_expnuke_launch_05_emit.bp',	## rings
    '/effects/emitters/seraphim_expnuke_launch_06_emit.bp',	## plasma rings
    '/effects/emitters/seraphim_expnuke_launch_07_emit.bp',	## fast ring
    '/effects/emitters/seraphim_expnuke_launch_08_emit.bp',	## burn mark
    '/effects/emitters/seraphim_expnuke_launch_09_emit.bp',	## delayed plasma
}
SIFExperimentalStrategicMissileHit01 = {
    '/effects/emitters/seraphim_expnuke_hit_01_emit.bp',			## plasma outward
    '/effects/emitters/seraphim_expnuke_hit_02_emit.bp',			## spiky lines
    '/effects/emitters/seraphim_expnuke_hit_03_emit.bp',			## plasma darkening outward
    '/effects/emitters/seraphim_expnuke_hit_04_emit.bp',			## twirling line buildup
    '/effects/emitters/seraphim_expnuke_detonate_03_emit.bp',	## non oriented glow
    '/effects/emitters/seraphim_expnuke_concussion_01_emit.bp',	## ring fast
    '/effects/emitters/seraphim_expnuke_concussion_02_emit.bp',	## ring slow
}
SIFExperimentalStrategicMissileDetonate01 = {
	'/effects/emitters/seraphim_expnuke_detonate_01_emit.bp',		## upwards plasma darkening
	'/effects/emitters/seraphim_expnuke_detonate_02_emit.bp',		## upwards plasma ser7
	'/effects/emitters/seraphim_expnuke_detonate_03_emit.bp',		## non oriented glow
	'/effects/emitters/seraphim_expnuke_detonate_04_emit.bp',		## oriented glow
    '/effects/emitters/seraphim_expnuke_concussion_01_emit.bp',		## ring fast
}
SIFExperimentalStrategicMissileFxTrails01 = {
    '/effects/emitters/seraphim_inaino_hitring_fxtrails_01_emit.bp',		## clouds 
    '/effects/emitters/seraphim_inaino_hitring_fxtrails_02_emit.bp',		## add clouds
}
SIFExperimentalStrategicMissilePlumeFxTrails01 = {
    '/effects/emitters/seraphim_inaino_plume_fxtrails_05_emit.bp',	## upwards nuke cloud   
    '/effects/emitters/seraphim_inaino_plume_fxtrails_06_emit.bp',	## upwards nuke cloud highlights 
}
SIFExperimentalStrategicMissilePlumeFxTrails02 = {
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_03_emit.bp',	## upwards plasma cloud 
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_04_emit.bp',	## upwards plasma cloud darkening  
}
SIFExperimentalStrategicMissilePlumeFxTrails03 = {
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_05_emit.bp',		## plasma trail 
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_06_emit.bp',		## plasma trail darkening  
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_10_emit.bp',		## bright tip
    #'/effects/emitters/_align_x_emit.bp',
	#'/effects/emitters/_align_y_emit.bp',
	#'/effects/emitters/_align_z_emit.bp',   
}
SIFExperimentalStrategicMissilePlumeFxTrails04 = {
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_07_emit.bp',	## plasma cloud 
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_08_emit.bp',	## plasma cloud 2, ser 07    
}
SIFExperimentalStrategicMissilePlumeFxTrails05 = {
    '/effects/emitters/seraphim_expnuke_plume_fxtrails_09_emit.bp',	## line detail in explosion, fingers.
}
SIFExperimentalStrategicMissilePolyTrails = {
    '/effects/emitters/seraphim_expnuke_polytrail_01_emit.bp',
    '/effects/emitters/seraphim_expnuke_polytrail_02_emit.bp',
    '/effects/emitters/seraphim_expnuke_polytrail_03_emit.bp',
}
SIFExperimentalStrategicMissileFXTrails = {
    '/effects/emitters/seraphim_expnuke_fxtrails_01_emit.bp',
    '/effects/emitters/seraphim_expnuke_fxtrails_02_emit.bp',
}


SZhanaseeMuzzleFlash01 = {
	'/effects/emitters/seraphim_khamaseen_bomb_muzzle_flash_01_emit.bp',
}
SZhanaseeBombFxTrails01 = {
    '/effects/emitters/seraphim_khamaseen_bomb_fxtrails_01_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_fxtrails_02_emit.bp',
}
SZhanaseeBombHit01 = {
    '/effects/emitters/seraphim_khamaseen_bomb_hit_01_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_02_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_04_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_06_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_08_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_09_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_10_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_11_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_12_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_13_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_14_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_15_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_16_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_17_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bomb_hit_18_emit.bp',
}
SZhanaseeBombHitSpiralFxTrails01 = {
    '/effects/emitters/seraphim_khamaseen_bombhitspiral_fxtrails_02_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bombhitspiral_fxtrails_03_emit.bp',
    '/effects/emitters/seraphim_khamaseen_bombhitspiral_fxtrails_04_emit.bp',
}
SZhanaseeBombHitSpiralFxTrails02 = {
    '/effects/emitters/seraphim_khamaseen_bombhitspiral_fxtrails_01_emit.bp',   
}
SZhanaseeBombHitSpiralFxPolyTrails = {
    '/effects/emitters/seraphim_khamaseen_bombhitspiral_polytrail_01_emit.bp',
}

SKhuAntiNukeMuzzleFlash = {
	'/effects/emitters/seraphim_khu_anti_nuke_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_khu_anti_nuke_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_khu_anti_nuke_muzzle_flash_03_emit.bp',
}
SKhuAntiNukeFxTrails = {
    '/effects/emitters/seraphim_khu_anti_nuke_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_fxtrail_02_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_fxtrail_03_emit.bp',
}
SKhuAntiNukeHit= {
    '/effects/emitters/seraphim_khu_anti_nuke_hit_01_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_02_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_03_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_04_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_05_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_06_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_07_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_08_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_09_emit.bp',
}
SKhuAntiNukeHitTendrilFxTrails= {
    ##'/effects/emitters/seraphim_khu_anti_nuke_hit_tendril_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_tendril_fxtrail_02_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_tendril_fxtrail_04_emit.bp',
}
SKhuAntiNukeHitSmallTendrilFxTrails= {
    '/effects/emitters/seraphim_khu_anti_nuke_hit_small_tendril_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_khu_anti_nuke_hit_small_tendril_fxtrail_02_emit.bp',
}
SKhuAntiNukePolyTrail= '/effects/emitters/seraphim_khu_anti_nuke_polytrail_01_emit.bp'

PhasicAutoGunMuzzleFlash = {
	'/effects/emitters/seraphim_phasic_autogun_muzzle_flash_emit.bp',
	'/effects/emitters/seraphim_phasic_autogun_muzzle_flash_02_emit.bp',		
}
PhasicAutoGunProjectileTrail = { 
	'/effects/emitters/seraphim_phasic_autogun_projectile_emit.bp',
	'/effects/emitters/seraphim_phasic_autogun_projectile_02_emit.bp',
}	
PhasicAutoGunHit = {
    '/effects/emitters/seraphim_phasic_autogun_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_phasic_autogun_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_phasic_autogun_projectile_hit_03_emit.bp',
}
PhasicAutoGunHitUnit = {
    '/effects/emitters/seraphim_phasic_autogun_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_phasic_autogun_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_phasic_autogun_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_phasic_autogun_projectile_hitunit_01_emit.bp',
    '/effects/emitters/seraphim_phasic_autogun_projectile_hitunit_03_emit.bp',
}

HeavyPhasicAutoGunMuzzleFlash = {
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash01_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash02_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash03_emit.bp',
}
HeavyPhasicAutoGunTankMuzzleFlash = {
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash04_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_muzzle_flash05_emit.bp',
}
HeavyPhasicAutoGunProjectileTrail = {
	'/effects/emitters/seraphim_heavy_phasic_autogun_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_projectile_polytrail_02_emit.bp',
}	
HeavyPhasicAutoGunProjectileTrail02 = {
	'/effects/emitters/seraphim_heavy_phasic_autogun_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_heavy_phasic_autogun_projectile_polytrail_03_emit.bp',
}
HeavyPhasicAutoGunProjectileTrailGlow = {
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_glow.bp',
}
HeavyPhasicAutoGunProjectileTrailGlow02 = {
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_glow_02.bp',
}
HeavyPhasicAutoGunHit = {
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_05_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_06_emit.bp',    
}
HeavyPhasicAutoGunHitUnit = {
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hitunit_01_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hitunit_02_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hitunit_03_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hitunit_04_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hitunit_05_emit.bp',
    '/effects/emitters/seraphim_heavy_phasic_autogun_projectile_hit_06_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}

OhCannonMuzzleFlash = {
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_emit.bp',	
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_03_emit.bp',
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_04_emit.bp',
}
OhCannonProjectileTrail = {
	'/effects/emitters/seraphim_spectra_cannon_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_spectra_cannon_polytrail_02_emit.bp',
}	
OhCannonFxTrails = {
	'/effects/emitters/seraphim_spectra_cannon_fxtrail_01_emit.bp',
	#'/effects/emitters/seraphim_spectra_cannon_projectile_emit.bp'
}
OhCannonHit = {
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_06_emit.bp',
}
OhCannonHitUnit = {
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_spectra_cannon_projectile_hit_05_emit.bp',
}
OhCannonProjectileTrail02 = {
	'/effects/emitters/seraphim_spectra_cannon_polytrail_03_emit.bp',
	'/effects/emitters/seraphim_spectra_cannon_polytrail_04_emit.bp',
	'/effects/emitters/default_polytrail_03_emit.bp',
}	
OhCannonMuzzleFlash02 = {
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_05_emit.bp',	
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_06_emit.bp',
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_07_emit.bp',
	'/effects/emitters/seraphim_spectra_cannon_muzzle_flash_08_emit.bp',
}

ShriekerCannonMuzzleFlash = {
	'/effects/emitters/seraphim_shrieker_cannon_muzzle_flash_emit.bp', 
	'/effects/emitters/seraphim_shrieker_cannon_muzzle_flash_02_emit.bp', 
	'/effects/emitters/seraphim_shrieker_cannon_muzzle_flash_03_emit.bp', 
}
ShriekerCannonPolyTrail = {
	'/effects/emitters/seraphim_shrieker_cannon_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_shrieker_cannon_projectile_polytrail_02_emit.bp',
	'/effects/emitters/seraphim_shrieker_cannon_projectile_polytrail_03_emit.bp',
}	
ShriekerCannonProjectileTrail = '/effects/emitters/seraphim_shrieker_cannon_projectile_emit.bp'
ShriekerCannonFxTrails= {
	'/effects/emitters/seraphim_shrieker_cannon_projectile_fxtrail_01_emit.bp',
	'/effects/emitters/seraphim_shrieker_cannon_projectile_fxtrail_02_emit.bp',
}
ShriekerCannonHit = {
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hit_04_emit.bp',
}
ShriekerCannonHitUnit = {
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hitunit_01_emit.bp',
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hitunit_02_emit.bp',
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hitunit_03_emit.bp',
    '/effects/emitters/seraphim_shrieker_cannon_projectile_hitunit_04_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}

SChronotronCannonMuzzleCharge = {	
	'/effects/emitters/seraphim_chronotron_cannon_muzzle_flash_01_emit.bp', 		
	'/effects/emitters/seraphim_chronotron_cannon_muzzle_flash_02_emit.bp',
}
SChronotronCannonMuzzle = {
    '/effects/emitters/seraphim_chronotron_cannon_muzzle_flash_03_emit.bp',	
	'/effects/emitters/seraphim_chronotron_cannon_muzzle_flash_04_emit.bp',
	'/effects/emitters/seraphim_chronotron_cannon_muzzle_flash_05_emit.bp',
}
SChronotronCannonProjectileTrails = {
	'/effects/emitters/seraphim_chronotron_cannon_projectile_emit.bp',
	'/effects/emitters/seraphim_chronotron_cannon_projectile_01_emit.bp',
	'/effects/emitters/seraphim_chronotron_cannon_projectile_02_emit.bp',
}
SChronotronCannonProjectileFxTrails = {
    '/effects/emitters/seraphim_chronotron_cannon_projectile_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_fxtrail_02_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_fxtrail_03_emit.bp',
}
SChronotronCannonHit = {
	'/effects/emitters/seraphim_chronotron_cannon_projectile_hit_01_emit.bp',
	##'/effects/emitters/seraphim_chronotron_cannon_projectile_hit_02_emit.bp',
}
SChronotronCannonLandHit = {
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_06_emit.bp',
}
SChronotronCannonUnitHit = {
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
SChronotronCannonOverChargeMuzzle = {
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_muzzle_flash_01_emit.bp',	
	'/effects/emitters/seraphim_chronotron_cannon_overcharge_muzzle_flash_02_emit.bp',		
	'/effects/emitters/seraphim_chronotron_cannon_overcharge_muzzle_flash_03_emit.bp', 		
}
SChronotronCannonOverChargeProjectileTrails = {
	'/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_emit.bp',
	'/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_01_emit.bp',
	'/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_02_emit.bp',
}
SChronotronCannonOverChargeProjectileFxTrails = {
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_fxtrail_02_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_fxtrail_03_emit.bp',
}
SChronotronCannonOverChargeLandHit = {
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_06_emit.bp',
}
SChronotronCannonOverChargeUnitHit = {
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_overcharge_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
SChronatronCannonBlastAttackAOE= {
    '/effects/emitters/seraphim_chronotron_cannon_blast_projectile_hit_01_emit.bp',                  
    '/effects/emitters/seraphim_chronotron_cannon_blast_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_chronotron_cannon_blast_projectile_hit_03_emit.bp', 
}

SLightChronotronCannonMuzzleFlash = {
    EmtBpPath.. 'seraphim_light_chronotron_cannon_muzzle_flash_01_emit.bp',	
	###'/effects/emitters/seraphim_light_chronotron_cannon_muzzle_flash_02_emit.bp',		
	'/effects/emitters/seraphim_light_chronotron_cannon_muzzle_flash_03_emit.bp', 		
}
SLightChronotronCannonMuzzleFlash = {
    '/effects/emitters/seraphim_light_chronotron_cannon_muzzle_flash_01_emit.bp',	
	'/effects/emitters/seraphim_light_chronotron_cannon_muzzle_flash_02_emit.bp',		
	'/effects/emitters/seraphim_light_chronotron_cannon_muzzle_flash_03_emit.bp', 		
}
SLightChronotronCannonProjectileTrails = {
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_emit.bp',
}
SLightChronotronCannonProjectileFxTrails = {
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_fxtrail_02_emit.bp',
}
SLightChronotronCannonHit = {
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_02_emit.bp',
}
SLightChronotronCannonUnitHit = {
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
SLightChronotronCannonLandHit = {
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_01_emit.bp',
    ###'/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_projectile_hit_03_emit.bp',
}
SLightChronotronCannonOverChargeMuzzleFlash = {
    EmtBpPath..  'seraphim_light_chronotron_cannon_overcharge_muzzle_flash_01_emit.bp',	
	'/effects/emitters/seraphim_light_chronotron_cannon_overcharge_muzzle_flash_02_emit.bp',		
	'/effects/emitters/seraphim_light_chronotron_cannon_overcharge_muzzle_flash_03_emit.bp', 		
	'/effects/emitters/seraphim_light_chronotron_cannon_overcharge_muzzle_flash_04_emit.bp', 		
}
SLightChronotronCannonOverChargeProjectileTrails = {
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_emit.bp',
    ##'/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_01_emit.bp',
    ##'/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_02_emit.bp',
}
SLightChronotronCannonOverChargeProjectileFxTrails = {
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_fxtrail_02_emit.bp',
}
SLightChronotronCannonOverChargeHit = {
    
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_hit_05_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_hit_06_emit.bp',
    '/effects/emitters/seraphim_light_chronotron_cannon_overcharge_projectile_hit_07_emit.bp',  
}

SAireauBolterMuzzleFlash = {
    '/effects/emitters/seraphim_aero_bolter_muzzle_flash_emit.bp',		
}
SAireauBolterMuzzleFlash02 = {
    '/effects/emitters/seraphim_aero_bolter_muzzle_flash_emit.bp',		
    '/effects/emitters/seraphim_aero_bolter_muzzle_flash_02_emit.bp',		    
}
SAireauBolterProjectileFxTrails = {
	'/effects/emitters/seraphim_aero_bolter_projectile_fxtrail_01_emit.bp',
}
SAireauBolterProjectilePolyTrails = {
	'/effects/emitters/seraphim_aero_bolter_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_aero_bolter_projectile_polytrail_02_emit.bp',
	'/effects/emitters/seraphim_aero_bolter_projectile_polytrail_03_emit.bp',	
}
SAireauBolterHit = {
    '/effects/emitters/seraphim_aero_bolter_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_aero_bolter_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_aero_bolter_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_aero_bolter_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_aero_bolter_projectile_hit_05_emit.bp',
}

SShleoCannonMuzzleFlash = {
	'/effects/emitters/seraphim_cleo_cannon_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_cleo_cannon_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_cleo_cannon_muzzle_flash_03_emit.bp',
}
SShleoCannonProjectileTrails = {
	'/effects/emitters/seraphim_cleo_cannon_projectile_01_emit.bp',
	#'/effects/emitters/seraphim_cleo_cannon_projectile_02_emit.bp',
}
SShleoCannonProjectilePolyTrails = {
	{
		'/effects/emitters/seraphim_cleo_cannon_projectile_polytrail_01_emit.bp',
		'/effects/emitters/seraphim_cleo_cannon_projectile_polytrail_02_emit.bp',
	},
	{
		'/effects/emitters/seraphim_cleo_cannon_projectile_polytrail_03_emit.bp',
		'/effects/emitters/seraphim_cleo_cannon_projectile_polytrail_04_emit.bp',
	},
	{
		'/effects/emitters/seraphim_cleo_cannon_projectile_polytrail_05_emit.bp',
		'/effects/emitters/seraphim_cleo_cannon_projectile_polytrail_06_emit.bp',
	},

}
SShleoCannonHit = {
    #'/effects/emitters/seraphim_cleo_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_07_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_08_emit.bp',    
}
SShleoCannonUnitHit = {
    #'/effects/emitters/seraphim_cleo_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_06_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_08_emit.bp',    
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
SShleoCannonLandHit = {
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_cleo_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}

SThunderStormCannonMuzzleFlash= {
	'/effects/emitters/seraphim_thunderstorm_artillery_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_thunderstorm_artillery_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_thunderstorm_artillery_muzzle_flash_03_emit.bp',
}
SThunderStormCannonProjectileTrails = {
	'/effects/emitters/seraphim_thunderstorm_artillery_projectile_02_emit.bp',
}
SThunderStormCannonProjectileSplitFx = {
	'/effects/emitters/seraphim_thunderstorm_artillery_projectile_split_01_emit.bp',
}
SThunderStormCannonProjectilePolyTrails = {
	'/effects/emitters/seraphim_thunderstorm_artillery_projectile_trail_01_emit.bp',
	'/effects/emitters/default_polytrail_01_emit.bp',
}	
SThunderStormCannonLightningProjectilePolyTrail = '/effects/emitters/seraphim_thunderstorm_artillery_projectile_trail_02_emit.bp'
SThunderStormCannonHit = {
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_03_emit.bp',
}
SThunderStormCannonUnitHit = {
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_03_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
SThunderStormCannonLandHit = {
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_thunderstorm_artillery_projectile_hit_03_emit.bp',
}

SRifterArtilleryProjectileFxTrails= {
    '/effects/emitters/seraphim_rifter_artillery_projectile_fxtrails_01_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_projectile_fxtrails_02_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_projectile_fxtrails_03_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_projectile_fxtrails_04_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_projectile_fxtrails_05_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_projectile_fxtrails_06_emit.bp',
}
SRifterArtilleryProjectilePolyTrail= '/effects/emitters/seraphim_rifter_mobileartillery_polytrail_01_emit.bp'
SRifterArtilleryHit= {
	'/effects/emitters/seraphim_rifter_artillery_hit_01_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_02_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_03_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_04_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_05_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_06_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_07_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_08_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_09_emit.bp',
}
SRifterArtilleryWaterHit= {
	'/effects/emitters/seraphim_rifter_artillery_hit_01w_emit.bp',
	'/effects/emitters/seraphim_rifter_artillery_hit_02w_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_03w_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_04_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_05w_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_06w_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_07_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_08w_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_hit_09_emit.bp',
}
SRifterArtilleryMuzzleFlash= {
	'/effects/emitters/seraphim_rifter_artillery_muzzle_01_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_muzzle_02_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_muzzle_05_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_muzzle_06_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_muzzle_07_emit.bp',
}
SRifterArtilleryChargeMuzzleFlash= {
    '/effects/emitters/seraphim_rifter_artillery_muzzle_03_emit.bp',
    '/effects/emitters/seraphim_rifter_artillery_muzzle_04_emit.bp',
}

SRifterMobileArtilleryProjectileFxTrails= {
    #'/effects/emitters/seraphim_rifter_mobileartillery_projectile_fxtrails_01_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_projectile_fxtrails_02_emit.bp',
    #'/effects/emitters/seraphim_rifter_mobileartillery_projectile_fxtrails_03_emit.bp',
    #'/effects/emitters/seraphim_rifter_mobileartillery_projectile_fxtrails_04_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_projectile_fxtrails_05_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_projectile_fxtrails_06_emit.bp',
}
SRifterMobileArtilleryHit= {
	'/effects/emitters/seraphim_rifter_mobileartillery_hit_01_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_02_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_03_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_04_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_05_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_06_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_07_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_08_emit.bp',
}
SRifterMobileArtilleryWaterHit= {
	'/effects/emitters/seraphim_rifter_mobileartillery_hit_01w_emit.bp',
	'/effects/emitters/seraphim_rifter_mobileartillery_hit_02w_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_03w_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_04_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_05w_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_06w_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_07_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_hit_08w_emit.bp',
}
SRifterMobileArtilleryChargeMuzzleFlash= {
	'/effects/emitters/seraphim_rifter_mobileartillery_muzzle_01_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_muzzle_02_emit.bp',
}
SRifterMobileArtilleryMuzzleFlash= {
    '/effects/emitters/seraphim_rifter_mobileartillery_muzzle_03_emit.bp',
    '/effects/emitters/seraphim_rifter_mobileartillery_muzzle_04_emit.bp',
}

SZthuthaamArtilleryProjectilePolyTrails= {
	'/effects/emitters/seraphim_reviler_artillery_projectile_polytrail_emit.bp',
	'/effects/emitters/seraphim_reviler_artillery_projectile_polytrail_02_emit.bp',
}
SZthuthaamArtilleryProjectileFXTrails= {
	'/effects/emitters/seraphim_reviler_artillery_projectile_fxtrail_emit.bp',
}		
SZthuthaamArtilleryHit= {
	'/effects/emitters/seraphim_reviler_artillery_hit_01_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_02_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_03_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_04_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_05_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_07_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_08_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_hit_09_emit.bp',
}
SZthuthaamArtilleryHit02= {
	'/effects/emitters/seraphim_reviler_artillery_hit_06_emit.bp',
}	
SZthuthaamArtilleryUnitHit = TableCat( SZthuthaamArtilleryHit, UnitHitShrapnel01, SZthuthaamArtilleryHit02 )
SZthuthaamArtilleryMuzzleFlash= {
	'/effects/emitters/seraphim_reviler_artillery_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_muzzle_flash_05_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_muzzle_flash_07_emit.bp',
}
SZthuthaamArtilleryChargeMuzzleFlash= {
	'/effects/emitters/seraphim_reviler_artillery_muzzle_flash_03_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_muzzle_flash_04_emit.bp',
    '/effects/emitters/seraphim_reviler_artillery_muzzle_flash_06_emit.bp',
}


STauCannonMuzzleFlash= {
	'/effects/emitters/seraphim_tau_cannon_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_muzzle_flash_03_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_muzzle_flash_10_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_muzzle_flash_11_emit.bp',
}
STauCannonProjectileTrails = {
	'/effects/emitters/seraphim_tau_cannon_projectile_01_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_projectile_02_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_projectile_03_emit.bp',	
}
STauCannonProjectilePolyTrails = {
	'/effects/emitters/seraphim_tau_cannon_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_tau_cannon_projectile_polytrail_02_emit.bp',	
}
STauCannonHit = {
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_03_flat_emit.bp',
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/seraphim_tau_cannon_projectile_hit_06_emit.bp',    
}

SHeavyQuarnonCannonMuzzleFlash= {
	'/effects/emitters/seraphim_heavyquarnon_cannon_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_heavyquarnon_cannon_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_heavyquarnon_cannon_muzzle_flash_03_emit.bp',
	'/effects/emitters/seraphim_heavyquarnon_cannon_muzzle_flash_04_emit.bp',
	'/effects/emitters/seraphim_heavyquarnon_cannon_muzzle_flash_05_emit.bp',
	'/effects/emitters/seraphim_heavyquarnon_cannon_frontal_glow_01_emit.bp',
}
SHeavyQuarnonCannonProjectileTrails = {
	'/effects/emitters/seraphim_heavyquarnon_cannon_projectile_01_emit.bp',
	'/effects/emitters/seraphim_heavyquarnon_cannon_projectile_02_emit.bp',
}
SHeavyQuarnonCannonProjectileFxTrails = {
    '/effects/emitters/seraphim_heavyquarnon_cannon_fxtrail_01_emit1.bp',
}
SHeavyQuarnonCannonProjectilePolyTrails = {
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_trail_01_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_trail_02_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_trail_03_emit.bp',
}
SHeavyQuarnonCannonHit = {
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_02_emit.bp',
}
SHeavyQuarnonCannonUnitHit = {
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
SHeavyQuarnonCannonLandHit = {
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_surface_hit_03_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_05_emit.bp',
}
SHeavyQuarnonCannonWaterHit = {
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_surface_hit_01_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_surface_hit_02_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/seraphim_heavyquarnon_cannon_projectile_surface_hit_03_emit.bp',
}

SLosaareAutoCannonMuzzleFlash = {
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_03_emit.bp', 
}
SLosaareAutoCannonMuzzleFlashAirUnit = {
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_04_emit.bp',
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_05_emit.bp',
}
SLosaareAutoCannonMuzzleFlashSeaUnit = {
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_06_emit.bp',
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_07_emit.bp',
    '/effects/emitters/seraphim_losaare_cannon_muzzle_flash_08_emit.bp', 
}
SLosaareAutoCannonProjectileTrail = {
	'/effects/emitters/seraphim_losaare_cannon_projectile_emit.bp',
	'/effects/emitters/seraphim_losaare_cannon_projectile_emit_02.bp',
}
SLosaareAutoCannonProjectileTrail02 = {
	'/effects/emitters/seraphim_losaare_cannon_projectile_emit_03.bp',
	'/effects/emitters/seraphim_losaare_cannon_projectile_emit_04.bp',
}		
SLosaareAutoCannonHit = {
	'/effects/emitters/seraphim_losaare_cannon_projectile_hit_01_emit.bp',
	'/effects/emitters/seraphim_losaare_cannon_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_losaare_cannon_projectile_hit_03_emit.bp',
	'/effects/emitters/seraphim_losaare_cannon_projectile_hit_04_emit.bp',
}

SOlarisCannonMuzzleCharge = {
    '/effects/emitters/seraphim_polarix_cannon_muzzle_charge_01_emit.bp',
}
SOlarisCannonMuzzleFlash01 = {
    '/effects/emitters/seraphim_polarix_cannon_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_muzzle_flash_03_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_muzzle_flash_04_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_muzzle_flash_05_emit.bp',    
}
SOlarisCannonTrails = {
    #'/effects/emitters/seraphim_polarix_cannon_trails_01_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_trails_02_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_trails_03_emit.bp',
    '/effects/emitters/seraphim_polarix_cannon_trails_04_emit.bp',    
}
SOlarisCannonProjectilePolyTrail = {
	'/effects/emitters/seraphim_polarix_cannon_projectile_emit.bp',
	'/effects/emitters/seraphim_polarix_cannon_projectile_02_emit.bp',
}	
SOlarisCannonHit = {
	'/effects/emitters/seraphim_polarix_cannon_projectile_hit_01_emit.bp',
	'/effects/emitters/seraphim_polarix_cannon_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_polarix_cannon_projectile_hit_03_emit.bp',
	'/effects/emitters/seraphim_polarix_cannon_projectile_hit_04_emit.bp',
	'/effects/emitters/seraphim_polarix_cannon_projectile_hit_05_emit.bp',
}


SExperimentalUnstablePhasonLaserMuzzle01 = {
	'/effects/emitters/seraphim_expirimental_laser_charge_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_charge_01_emit.bp', 
}
SChargeExperimentalUnstablePhasonLaser = { 
    '/effects/emitters/seraphim_expirimental_unstable_laser_charge_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_unstable_laser_charge_02_emit.bp',
}
SExperimentalUnstablePhasonLaserHitLand = {
    '/effects/emitters/seraphim_expirimental_unstable_laser_hit_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_unstable_laser_hit_02_emit.bp',
    '/effects/emitters/seraphim_expirimental_unstable_laser_hit_03_emit.bp',
}
SExperimentalUnstablePhasonLaserFxTrails = {
    '/effects/emitters/seraphim_expirimental_unstable_laser_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_unstable_laser_fxtrail_02_emit.bp',
}
SExperimentalUnstablePhasonLaserPolyTrail = '/effects/emitters/seraphim_expirimental_unstable_laser_trail_emit.bp'
SExperimentalUnstablePhasonLaserBeam = {
	'/effects/emitters/seraphim_expirimental_unstable_laser_beam_emit.bp',
}

SExperimentalPhasonLaserMuzzle01 = {
	'/effects/emitters/seraphim_expirimental_laser_muzzle_01_emit.bp',
	'/effects/emitters/seraphim_expirimental_laser_muzzle_02_emit.bp',
	'/effects/emitters/seraphim_expirimental_laser_muzzle_03_emit.bp',
	'/effects/emitters/seraphim_expirimental_laser_muzzle_04_emit.bp',
	'/effects/emitters/phason_laser_muzzle_01_emit.bp',
	
}

SChargeExperimentalPhasonLaser = { 
    '/effects/emitters/seraphim_expirimental_laser_charge_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_charge_02_emit.bp',
}

SExperimentalPhasonLaserHitLand = {
    '/effects/emitters/seraphim_expirimental_laser_hit_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_hit_02_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_hit_03_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_hit_04_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_hit_05_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_hit_06_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_hit_07_emit.bp',
}
SExperimentalPhasonLaserFxTrails = {
    '/effects/emitters/seraphim_expirimental_laser_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_expirimental_laser_fxtrail_02_emit.bp',
}
SExperimentalPhasonLaserPolyTrail = '/effects/emitters/seraphim_expirimental_laser_trail_emit.bp'
SExperimentalPhasonLaserBeam = {
	'/effects/emitters/seraphim_expirimental_laser_beam_emit.bp',
	#'/effects/emitters/seraphim_expirimental_laser_beam_02_emit.bp',
}

SUltraChromaticBeamGeneratorMuzzle01 = {
	'/effects/emitters/seraphim_chromatic_beam_generator_muzzle_01_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_muzzle_02_emit.bp', 
    '/effects/emitters/seraphim_chromatic_beam_generator_muzzle_03_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_muzzle_04_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_muzzle_06_emit.bp',
}
SUltraChromaticBeamGeneratorMuzzle02 = {
	'/effects/emitters/seraphim_chromatic_beam_generator_muzzle_01_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_muzzle_05_emit.bp', 
}
SChargeUltraChromaticBeamGenerator = { 
    '/effects/emitters/seraphim_chromatic_beam_generator_charge_01_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_charge_02_emit.bp',
}
SUltraChromaticBeamGeneratorHitLand = {
    '/effects/emitters/seraphim_chromatic_beam_generator_hit_01_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_hit_02_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_hit_03_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_hit_05_emit.bp',
}
SUltraChromaticBeamGeneratorFxTrails = {
    '/effects/emitters/seraphim_chromatic_beam_generator_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_chromatic_beam_generator_fxtrail_02_emit.bp',
}
SUltraChromaticBeamGeneratorPolyTrail = '/effects/emitters/seraphim_chromatic_beam_generator_trail_emit.bp'
SUltraChromaticBeamGeneratorBeam = {
	'/effects/emitters/seraphim_chromatic_beam_generator_beam_emit.bp',
}

SLaanseMissleMuzzleFlash = { 
	'/effects/emitters/seraphim_lancer_missile_launch_01_emit.bp', 
	'/effects/emitters/seraphim_lancer_missile_launch_02_emit.bp', 
}
SLaanseMissleExhaust01 = '/effects/emitters/seraphim_lancer_missile_exhaust_polytrail_01.bp'
SLaanseMissleExhaust02 = { 
	'/effects/emitters/seraphim_lancer_missile_exhaust_fxtrail_01_emit.bp', 
}
SLaanseMissleHit = {
    '/effects/emitters/seraphim_lancer_missile_hit_01_emit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_02_emit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_03_emit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_04_emit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_05_emit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_06_emit.bp',
}
SLaanseMissleHitUnit = {
    '/effects/emitters/seraphim_lancer_missile_hit_01_unit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_02_unit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_02_flat_unit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_04_unit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_05_unit.bp',
    '/effects/emitters/seraphim_lancer_missile_hit_06_emit.bp',
}

SExperimentalStrategicMissileMuzzleFlash = { 
	'/effects/emitters/seraphim_experimental_missile_launch_01_emit.bp', 
}
SExperimentalStrategicMissileExhaust01 = '/effects/emitters/seraphim_experimental_missile_exhaust_beam_01_emit.bp'
SExperimentalStrategicMissleExhaust02 = { 
	'/effects/emitters/seraphim_experimental_missile_exhaust_fxtrail_01_emit.bp', 
}
SExperimentalStrategicMissileHit = {
    '/effects/emitters/seraphim_experimental_missile_hit_01_emit.bp',
    '/effects/emitters/seraphim_experimental_missile_hit_02_emit.bp',
}

SElectrumMissleDefenseMuzzleFlash = {
    '/effects/emitters/seraphim_electrum_missile_defense_muzzle_flash_01_emit.bp',
    '/effects/emitters/seraphim_electrum_missile_defense_muzzle_flash_02_emit.bp',
    '/effects/emitters/seraphim_electrum_missile_defense_muzzle_flash_03_emit.bp',
}
SElectrumMissleDefenseProjectilePolyTrail = {
	'/effects/emitters/seraphim_electrum_missile_defense_projectile_emit.bp',
	'/effects/emitters/seraphim_electrum_missile_defense_projectile_emit_02.bp',
}
SElectrumMissleDefenseHit = {
    '/effects/emitters/seraphim_electrum_missile_hit_01_emit.bp',
    '/effects/emitters/seraphim_electrum_missile_hit_02_emit.bp',
    '/effects/emitters/seraphim_electrum_missile_hit_03_emit.bp',
    '/effects/emitters/seraphim_electrum_missile_hit_04_emit.bp',
}

SUallTorpedoMuzzleFlash= {
	'/effects/emitters/seraphim_uall_torpedo_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_uall_torpedo_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_uall_torpedo_muzzle_flash_03_emit.bp',
}
SUallTorpedoFxTrails = {
	'/effects/emitters/seraphim_uall_torpedo_projectile_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_uall_torpedo_projectile_fxtrail_02_emit.bp',
    '/effects/emitters/seraphim_uall_torpedo_projectile_fxtrail_03_emit.bp',
}
SUallTorpedoPolyTrail = '/effects/emitters/seraphim_uall_torpedo_projectile_polytrail_01_emit.bp'

SUallTorpedoHit = {
    '/effects/emitters/seraphim_uall_torpedo_projectile_hit_01_emit.bp',
	'/effects/emitters/seraphim_uall_torpedo_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_uall_torpedo_projectile_hit_03_emit.bp',
	'/effects/emitters/seraphim_uall_torpedo_projectile_hit_04_emit.bp',
	'/effects/emitters/seraphim_uall_torpedo_projectile_hit_05_emit.bp',
}

SAnaitTorpedoMuzzleFlash= {
	'/effects/emitters/seraphim_ammit_torpedo_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_ammit_torpedo_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_ammit_torpedo_muzzle_flash_03_emit.bp',
}
SAnaitTorpedoFxTrails = {
	'/effects/emitters/seraphim_ammit_torpedo_projectile_fxtrail_01_emit.bp',
}
SAnaitTorpedoPolyTrails = {
	'/effects/emitters/seraphim_ammit_torpedo_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_ammit_torpedo_projectile_polytrail_02_emit.bp',
}
SAnaitTorpedoHit = {
    '/effects/emitters/seraphim_ammit_torpedo_projectile_hit_01_emit.bp',
	'/effects/emitters/seraphim_ammit_torpedo_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_ammit_torpedo_projectile_hit_03_emit.bp',
}

SHeavyCavitationTorpedoMuzzleFlash = {
	'/effects/emitters/seraphim_heayvcavitation_torpedo_muzzle_flash_01_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_muzzle_flash_02_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_muzzle_flash_03_emit.bp',
}

SHeavyCavitationTorpedoMuzzleFlash02 = {
	'/effects/emitters/seraphim_heayvcavitation_torpedo_muzzle_flash_04_emit.bp',
}

SHeavyCavitationTorpedoFxTrails = '/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_fxtrail_01_emit.bp'

SHeavyCavitationTorpedoFxTrails02 = '/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_fxtrail_02_emit.bp'

SHeavyCavitationTorpedoPolyTrails = {
	'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_polytrail_02_emit.bp',
}

SHeavyCavitationTorpedoHit = {
    '/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_01_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_03_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_04_emit.bp',
	'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_05_emit.bp',
}

SHeavyCavitationTorpedoSplit = {
	'/effects/emitters/seraphim_ajellu_hit_03_emit.bp',
	'/effects/emitters/seraphim_ajellu_hit_04_emit.bp',
}

SOtheBombMuzzleFlash= {
	'/effects/emitters/seraphim_othe_bomb_muzzle_flash_01_emit.bp',
}

SOtheBombFxTrails = {
	'/effects/emitters/seraphim_othe_bomb_projectile_fxtrail_01_emit.bp',
    '/effects/emitters/seraphim_othe_bomb_projectile_fxtrail_02_emit.bp',
}

SOtheBombPolyTrail = '/effects/emitters/seraphim_othe_bomb_projectile_polytrail_01_emit.bp'

SOtheBombHit = {
	'/effects/emitters/seraphim_othe_bomb_projectile_hit_01_flat_emit.bp',
    '/effects/emitters/seraphim_othe_bomb_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_othe_bomb_projectile_hit_03_emit.bp',
	'/effects/emitters/seraphim_othe_bomb_projectile_hit_04_emit.bp',
}

SOtheBombHitUnit = {
    '/effects/emitters/seraphim_othe_bomb_projectile_hit_01_flat_emit.bp',
    '/effects/emitters/seraphim_othe_bomb_projectile_hit_01_emit.bp',
	'/effects/emitters/seraphim_othe_bomb_projectile_hit_02_emit.bp',
	'/effects/emitters/seraphim_othe_bomb_projectile_hit_03_emit.bp',
	'/effects/emitters/seraphim_othe_bomb_projectile_hit_04_emit.bp',
}

SOhwalliBombMuzzleFlash01 = {
	'/effects/emitters/seraphim_ohwalli_strategic_bomb_muzzle_flash_01_emit.bp',
}

SOhwalliBombFxTrails01 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_fxtrails_01_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_fxtrails_02_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_fxtrails_03_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_fxtrails_04_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_fxtrails_05_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_fxtrails_06_emit.bp',
}

SOhwalliBombPolyTrails = {
	'/effects/emitters/seraphim_ohwalli_strategic_bomb_polytrails_01_emit.bp',
	'/effects/emitters/seraphim_ohwalli_strategic_bomb_polytrails_02_emit.bp',
}

SOhwalliBombHit01 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_01_emit.bp',		## ring
    #'/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_02_emit.bp',		## lines
    #'/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_03_emit.bp',		## fast flash
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_04_emit.bp',		## spiky center
    #'/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_06_emit.bp',		## little dots
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_07_emit.bp',		## long glow
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_08_emit.bp',		## blue ser7
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_09_emit.bp',		## darkening
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_10_emit.bp',		## white cloud
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_11_emit.bp',		## distortion
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_12_emit.bp',		## inward lines
}

SOhwalliBombHit02 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_03_emit.bp',		## fast flash
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_14_emit.bp',		## long glow
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_13_emit.bp',		## faint plasma, ser7
}

SOhwalliDetonate01 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_explode_01_emit.bp',		## glow
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_explode_02_emit.bp',		## upwards plasma tall    
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_explode_03_emit.bp',		## upwards plasma short/wide    
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_explode_04_emit.bp',		## upwards plasma top column, thin/tall
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_explode_05_emit.bp',		## upwards lines
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_concussion_01_emit.bp',	## ring
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_concussion_02_emit.bp',	## smaller/slower ring bursts
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_03_emit.bp',		## fast flash
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_14_emit.bp',		## long glow
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_hit_13_emit.bp',		## faint plasma, ser7    
}

SOhwalliBombHitSpiralFxTrails02 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bombhitspiral_fxtrails_01_emit.bp',	## upwards nuke cloud   
    '/effects/emitters/seraphim_ohwalli_strategic_bombhitspiral_fxtrails_02_emit.bp',	## upwards nuke cloud highlights
}

SOhwalliBombHitRingProjectileFxTrails03 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_01_emit.bp',	# Rift Trail head
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_01a_emit.bp',	# Center darkening
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_01b_emit.bp',   # Right rift edge
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_01c_emit.bp',	# Left rift edge
    #'/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_01d_emit.bp',   # Right rift lines
}

SOhwalliBombHitRingProjectileFxTrails04 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_02_emit.bp',    # Rift Trail head
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_02a_emit.bp',	# Center darkening
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_02b_emit.bp',   # Right rift edge   
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_02c_emit.bp',   # Left rift edge   
}

SOhwalliBombHitRingProjectileFxTrails05 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_03_emit.bp',    # Rift Trail head
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_03a_emit.bp',   # Center darkening  
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_03b_emit.bp',	# Right rift edge
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_03c_emit.bp',   # Left rift edge      
}

SOhwalliBombHitRingProjectileFxTrails06 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_04_emit.bp',   
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_ring_fxtrails_06_emit.bp',
}

SOhwalliBombPlumeFxTrails01 = {
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_plume_fxtrails_01_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_plume_fxtrails_02_emit.bp',
    '/effects/emitters/seraphim_ohwalli_strategic_bomb_plume_fxtrails_03_emit.bp',    
}

SDFSniperShotMuzzleFlash = {
    '/effects/emitters/seraphim_sih_muzzleflash_01_emit.bp',
    '/effects/emitters/seraphim_sih_muzzleflash_02_emit.bp',
    '/effects/emitters/seraphim_sih_muzzleflash_03_emit.bp',
    '/effects/emitters/seraphim_sih_muzzleflash_04_emit.bp',
    '/effects/emitters/seraphim_sih_muzzleflash_05_emit.bp',
    '/effects/emitters/seraphim_sih_muzzleflash_06_emit.bp',

}

SDFSniperShotNormalMuzzleFlash = {
    '/effects/emitters/seraphim_sih_muzzleflash_01_emit.bp',
    '/effects/emitters/seraphim_sih_muzzleflash_02_emit.bp',
}

SDFSniperShotNormalHit = {    
    '/effects/emitters/seraphim_sih_projectile_06_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_07_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_08_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_09_emit.bp',
}

SDFSniperShotHit = {
    '/effects/emitters/seraphim_sih_projectile_01_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_02_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_03_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_04_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_05_emit.bp',
}

SDFSniperShotNormalHitUnit = {    
	'/effects/emitters/seraphim_sih_projectile_unit_06_emit.bp',
	'/effects/emitters/seraphim_sih_projectile_unit_07_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_unit_08_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_09_emit.bp',
}

SDFSniperShotHitUnit = {
    '/effects/emitters/seraphim_sih_projectile_unit_01_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_unit_02_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_03_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_unit_04_emit.bp',
    '/effects/emitters/seraphim_sih_projectile_unit_05_emit.bp'
}

SDFSniperShotTrails = {
    '/effects/emitters/seraphim_sih_fxtrail_01_emit.bp',
}

SDFSniperShotNormalPolytrail = {
	'/effects/emitters/seraphim_sih_polytrail_03_emit.bp',
	'/effects/emitters/seraphim_sih_polytrail_04_emit.bp',
}	

SDFSniperShotPolytrail = {
	'/effects/emitters/seraphim_sih_polytrail_01_emit.bp',
	'/effects/emitters/seraphim_sih_polytrail_02_emit.bp',
}


--- ###### AEON PROJECTILES ######

Aeon_QuadLightLaserCannonMuzzleFlash= {
	'/effects/emitters/aeon_dualquantum_cannon_muzzle_flash_emit.bp',
	'/effects/emitters/aeon_dualquantum_cannon_muzzle_flash_emit2.bp', 
}
Aeon_QuadLightLaserCannonProjectilePolyTrails = {
    '/effects/emitters/aeon_dualquantum_cannon_projectile_trail_emit.bp',
}
Aeon_QuadLightLaserCannonProjectileFxTrails = {
	'/effects/emitters/aeon_dualquantum_cannon_projectile_01_emit.bp',
	'/effects/emitters/aeon_dualquantum_cannon_projectile_02_emit.bp',
}
Aeon_QuadLightLaserCannonLandHit = {
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit_land.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit2.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit3.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit4.bp',
--    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit5.bp',
}
Aeon_QuadLightLaserCannonHit = {
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit2.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit3.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit4.bp',
--    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit5.bp',
}
Aeon_QuadLightLaserCannonUnitHit = TableCat (Aeon_QuadLightLaserCannonHit, UnitHitShrapnel01)

Aeon_DualQuantumAutoGunMuzzleFlash= {
	'/effects/emitters/aeon_dualquantum_cannon_muzzle_flash_emit.bp',
	'/effects/emitters/aeon_dualquantum_cannon_muzzle_flash_02_emit.bp', 
	'/effects/emitters/aeon_dualquantum_cannon_muzzle_flash_03_emit.bp',
}
Aeon_DualQuantumAutoGunProjectileTrail = '/effects/emitters/aeon_dualquantum_cannon_projectile_trail_emit.bp'
Aeon_DualQuantumAutoGunProjectile = {
	'/effects/emitters/aeon_dualquantum_cannon_projectile_01_emit.bp',
	'/effects/emitters/aeon_dualquantum_cannon_projectile_02_emit.bp',
}
Aeon_DualQuantumAutoGunFxTrail = {
	'/effects/emitters/aeon_dualquantum_cannon_projectile_fxtrail_emit.bp',
}
Aeon_DualQuantumAutoGunHitLand = {
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_06_emit.bp',
--    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_07_emit.bp',
}
Aeon_DualQuantumAutoGunHit = {
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/aeon_dualquantum_cannon_projectile_hitunit_06_emit.bp',
--    '/effects/emitters/aeon_dualquantum_cannon_projectile_hitunit_07_emit.bp',
}
Aeon_DualQuantumAutoGunHit_Unit = TableCat (Aeon_DualQuantumAutoGunHit, UnitHitShrapnel01)

Aeon_HeavyDisruptorCannonMuzzleCharge= {
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_charge_01_emit.bp',
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_charge_02_emit.bp',
}
Aeon_HeavyDisruptorCannonMuzzleFlash= {
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_flash_emit.bp',
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_flash_02_emit.bp',
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_flash_03_emit.bp',
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_flash_04_emit.bp',
	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_flash_05_emit.bp',
--	'/effects/emitters/aeon_heavydisruptor_cannon_muzzle_flash_06_emit.bp',
}
Aeon_HeavyDisruptorCannonProjectileTrails = {
	'/effects/emitters/aeon_heavydisruptor_cannon_projectile_trail_emit.bp',
}
Aeon_HeavyDisruptorCannonProjectile = {
	###'/effects/emitters/aeon_heavydisruptor_cannon_projectile_01_emit.bp',
	###'/effects/emitters/aeon_heavydisruptor_cannon_projectile_02_emit.bp',
}
Aeon_HeavyDisruptorCannonProjectileFxTrails  = {
	'/effects/emitters/aeon_heavydisruptor_cannon_projectile_01_emit.bp',
}
Aeon_HeavyDisruptorCannonLandHit = {
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_01_emit.bp',
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_02_emit.bp',
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_03_emit.bp',
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_04_emit.bp',
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_05_emit.bp',
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_06_emit.bp',
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_07_emit.bp',
--    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_08_emit.bp',
}
Aeon_HeavyDisruptorCannonHit01 = {
    '/effects/emitters/aeon_heavydisruptor_cannon_projectile_hit_unit_02_emit.bp',
    '/effects/emitters/destruction_unit_hit_shrapnel_01_emit.bp',
}
Aeon_HeavyDisruptorCannonUnitHit = TableCat( Aeon_HeavyDisruptorCannonLandHit, Aeon_HeavyDisruptorCannonHit01 )

Aeon_QuanticClusterChargeMuzzleFlash= {
	'/effects/emitters/aeon_quanticcluster_muzzle_flash_01_emit.bp',
    '/effects/emitters/aeon_quanticcluster_muzzle_flash_02_emit.bp',
}
Aeon_QuanticClusterMuzzleFlash= {
    '/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',	# flat flash glow
    '/effects/emitters/aeon_quanticcluster_muzzle_flash_04_emit.bp',	# expanding ring
    '/effects/emitters/aeon_quanticcluster_muzzle_flash_05_emit.bp',	# flash glow
    '/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',	# straight blue lines, velocity aligned
--    '/effects/emitters/aeon_quanticcluster_muzzle_flash_07_emit.bp',	# dust
--    '/effects/emitters/aeon_quanticcluster_muzzle_flash_08_emit.bp',	# little dot glows
}
Aeon_QuanticClusterFrag01 = {
    '/effects/emitters/aeon_quanticcluster_split_01_emit.bp',
    '/effects/emitters/aeon_quanticcluster_split_02_emit.bp',
    '/effects/emitters/aeon_quanticcluster_split_03_emit.bp',
}
Aeon_QuanticClusterFrag02 = {
    '/effects/emitters/aeon_quanticcluster_split_04_emit.bp',
    '/effects/emitters/aeon_quanticcluster_split_05_emit.bp',
    '/effects/emitters/aeon_quanticcluster_split_06_emit.bp',
}
Aeon_QuanticClusterProjectileTrails = {
	 '/effects/emitters/aeon_quanticcluster_fxtrail_01_emit.bp',
}
Aeon_QuanticClusterProjectileTrails02 = {
	 '/effects/emitters/aeon_quanticcluster_fxtrail_02_emit.bp',
}
Aeon_QuanticClusterProjectilePolyTrail = '/effects/emitters/aeon_quantic_cluster_polytrail_01_emit.bp'
Aeon_QuanticClusterProjectilePolyTrail02 = '/effects/emitters/aeon_quantic_cluster_polytrail_02_emit.bp'
Aeon_QuanticClusterProjectilePolyTrail03 = '/effects/emitters/aeon_quantic_cluster_polytrail_03_emit.bp'
Aeon_QuanticClusterHit = {
	'/effects/emitters/aeon_quanticcluster_hit_01_emit.bp',	# initial flash
	'/effects/emitters/aeon_quanticcluster_hit_02_emit.bp',	# glow
	'/effects/emitters/aeon_quanticcluster_hit_03_emit.bp',	# fast ring
	'/effects/emitters/aeon_quanticcluster_hit_04_emit.bp',	# plasma
	'/effects/emitters/aeon_quanticcluster_hit_05_emit.bp',	# lines
	'/effects/emitters/aeon_quanticcluster_hit_06_emit.bp',	# darkening molecular
	'/effects/emitters/aeon_quanticcluster_hit_07_emit.bp',	# little dot glows
	'/effects/emitters/aeon_quanticcluster_hit_08_emit.bp',	# slow ring
	'/effects/emitters/aeon_quanticcluster_hit_09_emit.bp',	# darkening
	'/effects/emitters/aeon_quanticcluster_hit_10_emit.bp',	# radial rays
}

ALightDisplacementAutocannonMissileMuzzleFlash = { 
	'/effects/emitters/aeon_light_displacement_missile_muzzleflash_01.bp',
}
ALightDisplacementAutocannonMissileExhaust01 = '/effects/emitters/seraphim_lancer_missile_exhaust_polytrail_01.bp'
ALightDisplacementAutocannonMissileExhaust02 = { 
	'/effects/emitters/seraphim_lancer_missile_exhaust_fxtrail_01_emit.bp', 
}
ALightDisplacementAutocannonMissileHit = {
    #'/effects/emitters/seraphim_lancer_missile_hit_01_emit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_02_emit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_03_emit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_04_emit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_05_emit.bp',
     
    '/effects/emitters/aeon_light_displacement_missile_hit_01_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_hit_02_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_hit_03_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_hit_04_emit.bp',
}
ALightDisplacementAutocannonMissileHitUnit = {
    #'/effects/emitters/seraphim_lancer_missile_hit_01_unit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_02_unit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_02_flat_unit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_04_unit.bp',
    #'/effects/emitters/seraphim_lancer_missile_hit_05_unit.bp',
    
    '/effects/emitters/aeon_light_displacement_missile_hit_01_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_hit_03_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_hit_02_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_hit_04_emit.bp',
}
ALightDisplacementAutocannonMissilePolyTrails = {
    '/effects/emitters/aeon_light_displacement_missile_polytrail_01_emit.bp',
    '/effects/emitters/aeon_light_displacement_missile_polytrail_02_emit.bp',
}

--  OLD UN-REFEFENCED EFFECT MAPPINGS
-- FIXME: These don't seem to be used anymore. Double check, and remove references and associated assets. ~gd 6.21.07
TBombHit01 = {
    '/effects/emitters/bomb_hit_flash_01_emit.bp',
    '/effects/emitters/bomb_hit_fire_01_emit.bp',
    '/effects/emitters/bomb_hit_fire_shadow_01_emit.bp',
}
CSGTestAeonGroundFX = {
    '/effects/emitters/_test_aeon_groundfx_emit.bp',
}
CSGTestAeonGroundFXSmall = {
    '/effects/emitters/_test_aeon_groundfx_small_emit.bp',
}
CSGTestAeonGroundFXMedium = {
    '/effects/emitters/_test_aeon_groundfx_medium_emit.bp',
}
CSGTestAeonGroundFXLow = {
    '/effects/emitters/_test_aeon_groundfx_low_emit.bp',
}
CSGTestAeonT2EngineerGroundFX = {
    '/effects/emitters/_test_aeon_t2eng_groundfx01_emit.bp',
    '/effects/emitters/_test_aeon_t2eng_groundfx02_emit.bp',
}

TLaserPolytrail01 = { 
    '/effects/emitters/terran_commander_cannon_polytrail_01_emit.bp',
    '/effects/emitters/terran_commander_cannon_polytrail_02_emit.bp',
    '/effects/emitters/default_polytrail_01_emit.bp',
}
TLaserFxtrail01 = {
	 '/effects/emitters/terran_commander_cannon_fxtrail_01_emit.bp',
}
TLaserMuzzleFlash = { 
    '/effects/emitters/terran_commander_cannon_flash_01_emit.bp',
    '/effects/emitters/terran_commander_cannon_flash_02_emit.bp', 
    '/effects/emitters/terran_commander_cannon_flash_03_emit.bp', 
    '/effects/emitters/terran_commander_cannon_flash_04_emit.bp',
    '/effects/emitters/terran_commander_cannon_flash_05_emit.bp',
}
TLaserHit01 = { '/effects/emitters/laserturret_hit_flash_02_emit.bp',}
TLaserHit02 = { 
    '/effects/emitters/terran_commander_cannon_hit_01_emit.bp',	# outward lines, non facing
    '/effects/emitters/terran_commander_cannon_hit_02_emit.bp',	# fast flash
    '/effects/emitters/terran_commander_cannon_hit_03_emit.bp',	# ground oriented flash, slow
    '/effects/emitters/terran_commander_cannon_hit_04_emit.bp',	# black ground spots
    '/effects/emitters/terran_commander_cannon_hit_05_emit.bp',	# blue wispy   
    '/effects/emitters/terran_commander_cannon_hit_06_emit.bp',	# darkening dot particles
    '/effects/emitters/terran_commander_cannon_hit_07_emit.bp',	# ring
}
TLaserHit03 = { 
    '/effects/emitters/terran_commander_cannon_hitunit_01_emit.bp',	# outward lines, non facing
    '/effects/emitters/terran_commander_cannon_hitunit_02_emit.bp',	# fast flash
    '/effects/emitters/terran_commander_cannon_hitunit_03_emit.bp',	# ground oriented flash, slow
    '/effects/emitters/terran_commander_cannon_hitunit_04_emit.bp',	# black ground spots
    '/effects/emitters/terran_commander_cannon_hit_05_emit.bp',	# blue wispy   
    '/effects/emitters/terran_commander_cannon_hitunit_06_emit.bp',	# darkening dot particles
    '/effects/emitters/terran_commander_cannon_hitunit_07_emit.bp',	# ring
}
TLaserHitUnit01 = TableCat( TLaserHit01, UnitHitShrapnel01 )
TLaserHitLand01 = TableCat( TLaserHit01 )
TLaserHitUnit02 = TableCat( TLaserHit03, UnitHitShrapnel01 )
TLaserHitLand02 = TableCat( TLaserHit02 )


TestExplosion01 = {
    '/effects/emitters/_test_explosion_b1_emit.bp', #lowest layer orange   
    '/effects/emitters/_test_explosion_b2_emit.bp', #top layer smoke   
    '/effects/emitters/_test_explosion_b3_emit.bp', #midlayer orange   
    '/effects/emitters/_test_explosion_b1_flash_emit.bp',    
    '/effects/emitters/_test_explosion_b1_sparks_emit.bp',  
    '/effects/emitters/_test_explosion_b2_dustring_emit.bp',  
    '/effects/emitters/_test_explosion_b2_flare_emit.bp',                             
    '/effects/emitters/_test_explosion_b2_smokemask_emit.bp',       
}

CSGTestEffect = {
    '/effects/emitters/_test_explosion_medium_01_emit.bp',
    '/effects/emitters/_test_explosion_medium_02_emit.bp',
    '/effects/emitters/_test_explosion_medium_03_emit.bp',
    '/effects/emitters/_test_explosion_medium_04_emit.bp',
    '/effects/emitters/_test_explosion_medium_05_emit.bp',
    '/effects/emitters/_test_explosion_medium_06_emit.bp',
}

CSGTestEffect2 = {
    '/effects/emitters/_test_swirl_01b_emit.bp',
    #'/effects/emitters/_test_swirl_02_emit.bp',
    '/effects/emitters/_test_swirl_03_emit.bp',
    '/effects/emitters/_test_swirl_04_emit.bp',
    '/effects/emitters/_test_swirl_05_emit.bp',
    '/effects/emitters/_test_swirl_06_emit.bp',
}
CSGTestSpinner1 = {
    '/effects/emitters/_test_gatecloud_01_emit.bp',
    '/effects/emitters/_test_gatecloud_02_emit.bp',
    '/effects/emitters/_test_gatecloud_03_emit.bp',
}
CSGTestSpinner2 = {
    '/effects/emitters/_test_gatecloud_04_emit.bp',
    '/effects/emitters/_test_gatecloud_05_emit.bp',
}
CSGTestSpinner3 = {
    #'/effects/emitters/_test_gatecloud_06_emit.bp',
    '/effects/emitters/_test_gatecloud_07_emit.bp',
}



