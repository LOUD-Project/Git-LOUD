---  /lua/defaultcollisionbeams.lua
---  Summary  :  Default definitions collision beams

local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')

SCCollisionBeam = Class(CollisionBeam) {

    FxImpactUnit        = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactWater       = EffectTemplate.WaterSplash01,
    FxImpactUnderWater  = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit     = EffectTemplate.DefaultProjectileAirUnitImpact,
}

GinsuCollisionBeam = Class(SCCollisionBeam) {

    FxBeam          = {'/effects/emitters/riot_gun_beam_01_emit.bp','/effects/emitters/riot_gun_beam_02_emit.bp'},
    FxBeamEndPoint  = {'/effects/emitters/sparks_02_emit.bp',},

    FxImpactUnit    = {'/effects/emitters/riotgun_hit_flash_01_emit.bp',},
    FxUnitHitScale  = 0.125,
    FxImpactLand    = {'/effects/emitters/destruction_land_hit_puff_01_emit.bp','/effects/emitters/destruction_explosion_flash_01_emit.bp'},
    FxLandHitScale  = 0.1625,
}

ParticleCannonCollisionBeam = Class(SCCollisionBeam) {

    FxBeam = {'/effects/emitters/particle_cannon_beam_01_emit.bp','/effects/emitters/particle_cannon_beam_02_emit.bp'},
    FxBeamEndPoint = {'/effects/emitters/particle_cannon_end_01_emit.bp','/effects/emitters/particle_cannon_end_02_emit.bp'},
    FxBeamEndPointScale = 1,
}

ZapperCollisionBeam = Class(CollisionBeam) {

    FxBeam = {'/effects/emitters/zapper_beam_01_emit.bp'},
    FxBeamEndPoint = {'/effects/emitters/cannon_muzzle_flash_01_emit.bp','/effects/emitters/sparks_07_emit.bp'},


    OnCollisionCheck = function( self, other )
    
        if LOUDENTITY( categories.TACTICAL, other ) and not (self.Army == other.Army) then
        
            SetCollisionShape( other, 'none' )
            other:SetVelocity( 0 )
            other:SetDrawScale( 0.1 )

            other:Destroy()            
            
            return true
        else
            return false
        end

    end,   
}

--   QUANTUM BEAM GENERATOR COLLISION BEAM
QuantumBeamGeneratorCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam02',

    FxBeam = {'/effects/emitters/quantum_generator_beam_01_emit.bp'},
    FxBeamEndPoint = {
		'/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
        '/effects/emitters/quantum_generator_end_05_emit.bp',
        '/effects/emitters/quantum_generator_end_06_emit.bp',
	},
    FxBeamStartPoint = {
		'/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 2.5,

}

DisruptorBeamCollisionBeam = Class(SCCollisionBeam) {
    
    FxBeam = {'/effects/emitters/disruptor_beam_01_emit.bp'},
    FxBeamEndPoint = { 
        '/effects/emitters/aeon_commander_disruptor_hit_01_emit.bp', 
        '/effects/emitters/aeon_commander_disruptor_hit_02_emit.bp', 
    },
    FxBeamEndPointScale = 1.0,
    
    FxBeamStartPoint = { 
        '/effects/emitters/aeon_commander_disruptor_flash_01_emit.bp', 
        '/effects/emitters/aeon_commander_disruptor_flash_02_emit.bp', 
    },
}

MicrowaveLaserCollisionBeam01 = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',

    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/effects/emitters/microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.1,

}

MicrowaveLaserCollisionBeam02 = Class(MicrowaveLaserCollisionBeam01) {

    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/effects/emitters/microwave_laser_beam_02_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
}

PhasonLaserCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',

    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {'/effects/emitters/phason_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,

    FxLandHitScale  = 0.1625,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.1,

}

--   QUANTUM BEAM GENERATOR COLLISION BEAM
ExperimentalPhasonLaserCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,

    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,
    FxBeam = EffectTemplate.SExperimentalPhasonLaserBeam,
    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,

    SplatTexture = 'scorch_004_albedo',
    ScorchSize = 3,
    
    CreateBeamEffects = function(self)
    
        SCCollisionBeam.CreateBeamEffects(self)
        
        local army = self.Sync.army
        
        for _, v in EffectTemplate.SExperimentalPhasonLaserBeam do

			local fxBeam = CreateBeamEntityToEntity(self, 0, self, 1, army, v )
            
            self.BeamEffectsBag[self.BeamEffectsBagCounter] = fxBeam
            self.BeamEffectsBagCounter = self.BeamEffectsBagCounter + 1

        end

    end, 
}

UnstablePhasonLaserCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,

    FxBeamStartPoint = EffectTemplate.SExperimentalUnstablePhasonLaserMuzzle01,
    FxBeam = EffectTemplate.OthuyElectricityStrikeBeam,
    FxBeamEndPoint = EffectTemplate.OthuyElectricityStrikeHit,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.1,

}

--- This is for a ship and a point defense.
UltraChromaticBeamGeneratorCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,

    FxBeamStartPoint = EffectTemplate.SUltraChromaticBeamGeneratorMuzzle01,
    FxBeam = EffectTemplate.SUltraChromaticBeamGeneratorBeam,
    FxBeamEndPoint = EffectTemplate.SUltraChromaticBeamGeneratorHitLand,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.75,

}

--- This is for a ship and a point defense. (adjustment for ship muzzleflash)
UltraChromaticBeamGeneratorCollisionBeam02 = Class(UltraChromaticBeamGeneratorCollisionBeam) {

	FxBeamStartPoint = EffectTemplate.SUltraChromaticBeamGeneratorMuzzle02,

    FxImpactWater = EffectTemplate.WaterSplash01,
    FxWaterHitScale = 0.3,
}

TractorClawCollisionBeam = Class(CollisionBeam) {
    
    FxBeam = {EffectTemplate.ACollossusTractorBeam01},
    FxBeamEndPoint = {EffectTemplate.ACollossusTractorBeamGlow02},
    FxBeamEndPointScale = 1.0,
    FxBeamStartPoint = { EffectTemplate.ACollossusTractorBeamGlow01 },
}

---  HIRO LASER COLLISION BEAM
TDFHiroCollisionBeam = Class(CollisionBeam) {

    TerrainImpactType = 'LargeBeam01',

    FxBeamStartPoint = EffectTemplate.TDFHiroGeneratorMuzzle01,
    FxBeam = EffectTemplate.TDFHiroGeneratorBeam,
    FxBeamEndPoint = EffectTemplate.TDFHiroGeneratorHitLand,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.75,

}

---   ORBITAL DEATH LASER COLLISION BEAM
OrbitalDeathLaserCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam02',

    FxBeam = {'/effects/emitters/uef_orbital_death_laser_beam_01_emit.bp'},
	
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
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 2.5,
    ScorchTime = 18
 
}