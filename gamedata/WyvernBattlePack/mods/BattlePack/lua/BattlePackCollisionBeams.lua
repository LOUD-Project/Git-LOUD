
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Util = import('/lua/utilities.lua')
local BattlePackEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')

-------------------------------
--   Base class that defines supreme commander specific defaults
-------------------------------
SCCollisionBeam = Class(CollisionBeam) {
    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactLand = {},#EffectTemplate.DefaultProjectileLandImpact,
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
    FxImpactProp = {},
    FxImpactShield = {},    
    FxImpactNone = {},
}

-------------------------------
--  NOVACAT BEAMS
-------------------------------

TMNovaCatBlueLaserBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.8,
    FxBeamStartPoint = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxBeam = {'/mods/BattlePack/effects/emitters/novacat_bluelaser_emit.bp'},
    FxBeamEndPoint = BattlePackEffectTemplate.AeonNocaCatBlueLaserHit,
    FxBeamEndPointScale = 0.5,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.25,
    ScorchTime = 30,
}

TMNovaCatGreenLaserBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 1.4,
    FxBeamStartPoint = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxBeam = {'/mods/BattlePack/effects/emitters/novacat_greenlaser_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    FxBeamEndPointScale = 2.0,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.25,
    ScorchTime = 30,
}

-------------------------------
--  Snake BEAMS
-------------------------------

HeavyMicrowaveLaserCollisionBeam01 = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/mods/BattlePack/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,

}
------------------------------------
--   Exaviers Target Painter
------------------------------------

EXCEMPArrayBeam01CollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {'/mods/BattlePack/effects/emitters/excemparraybeam01_emit.bp'},
    FxBeamEndPoint = {},
    FxBeamStartPoint = {},
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,

}

EXCEMPArrayBeam02CollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {'/mods/BattlePack/effects/emitters/excemparraybeam02_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,

}

SeraphimPhasonLaserCollisionBeam = Class(SCCollisionBeam) {
    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {'/mods/BattlePack/effects/emitters/alienphason_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
	FxBeamStartPointScale = 0.25,
    FxBeamEndPointScale = 0.5,

}

ZapperCollisionBeam02 = Class(SCCollisionBeam) {
    FxBeam = {
	    '/mods/BattlePack/effects/emitters/w_u_am01_p_02_polytrails_emit.bp',
    },
    FxBeamEndPoint = {
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_01_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_02_largeflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_03_shockwave_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_04_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_05_smoke_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_06_debris_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_am01_i_u_07_spikeflash_emit.bp',
    },
}

SC2CollosusCollisionBeam = Class(SCCollisionBeam) {
    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {
		'/mods/BattlePack/effects/emitters/w_i_bem01_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_01_groundflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_02_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_03_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_04_plasma_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_06_plasmasmoke_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_07_ring_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_08_topflash_emit.bp',
    },
    FxBeamStartPointScale = 1,
    FxBeamEndPointScale = 0.5,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.5,

}

SC2ACUCollisionBeam = Class(SCCollisionBeam) {
    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {
		'/mods/BattlePack/effects/emitters/w_i_bem02_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_01_groundflash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_02_flash_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_03_sparks_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_04_plasma_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_06_plasmasmoke_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_07_ring_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_bem01_i_u_08_topflash_emit.bp',
    },
    FxBeamStartPointScale = 0.3,
    FxBeamEndPointScale = 0.2,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.5,

}

AAMicrowaveLaserCollisionBeam01 = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/mods/BattlePack/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,

}

StarAdderLaserCollisionBeam02 = Class(SCCollisionBeam) {
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/mods/BattlePack/effects/emitters/microwave_laser_beam_02_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
	FxBeamEndPointScale = 0.2,
}

------------------------------------
--   ORBITAL DEATH LASER COLLISION BEAM
------------------------------------
WyvernLaserWeaponCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 1,
        
    FxBeam = {'/mods/BattlePack/effects/emitters/uef_orbital_death_laser_beam_01_emit.bp'},
    FxBeamEndPoint = {
		'/effects/emitters/uef_orbital_death_laser_end_01_emit.bp',			# big glow
		'/effects/emitters/uef_orbital_death_laser_end_02_emit.bp',			# random bright blueish dots
		'/effects/emitters/uef_orbital_death_laser_end_03_emit.bp',			# darkening lines
		'/effects/emitters/uef_orbital_death_laser_end_04_emit.bp',			# molecular, small details
		'/effects/emitters/uef_orbital_death_laser_end_05_emit.bp',			# rings
		'/effects/emitters/uef_orbital_death_laser_end_06_emit.bp',			# upward sparks
		'/effects/emitters/uef_orbital_death_laser_end_07_emit.bp',			# outward line streaks
		'/effects/emitters/uef_orbital_death_laser_end_08_emit.bp',			# center glow
		'/effects/emitters/uef_orbital_death_laser_end_distort_emit.bp',	# screen distortion
	},
    FxBeamStartPoint = {
		'/effects/emitters/uef_orbital_death_laser_muzzle_01_emit.bp',	# random bright blueish dots
		'/effects/emitters/uef_orbital_death_laser_muzzle_02_emit.bp',	# molecular, small details
		'/effects/emitters/uef_orbital_death_laser_muzzle_03_emit.bp',	# darkening lines
		'/effects/emitters/uef_orbital_death_laser_muzzle_04_emit.bp',	# small downward sparks
		'/effects/emitters/uef_orbital_death_laser_muzzle_05_emit.bp',	# big glow
    },
    FxBeamStartPointScale= 0.5,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 3.5,
    ScorchTime = 20,

}