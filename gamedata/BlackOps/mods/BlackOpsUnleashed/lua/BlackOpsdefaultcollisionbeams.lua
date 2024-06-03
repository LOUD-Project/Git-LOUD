local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local LOUDENTITY = EntityCategoryContains

HawkCollisionBeam = Class(CollisionBeam) {

    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
}

MartyrMicrowaveLaserCollisionBeam01 = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.25,
}

MiniQuantumBeamGeneratorCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 0.2,

    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/mini_quantum_generator_beam_01_emit.bp'},
    FxBeamEndPoint = {
		'/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
	},   
    FxBeamEndPointScale = 0.2,
    FxBeamStartPoint = {
		'/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },   
    FxBeamStartPointScale = 0.2,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.5,

}

SuperQuantumBeamGeneratorCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 1,

    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/super_quantum_generator_beam_01_emit.bp'},
    FxBeamEndPoint = {
		'/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
        '/effects/emitters/quantum_generator_end_05_emit.bp',
        '/effects/emitters/quantum_generator_end_06_emit.bp',
	},   
    FxBeamEndPointScale = 0.6,
    FxBeamStartPoint = {
		'/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },   
    FxBeamStartPointScale = 0.6,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.5,

}

MiniPhasonLaserCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.5,
    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/mini_phason_laser_beam_01_emit.bp'},
    FxBeamStartPointScale = 0.2,
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    FxBeamEndPointScale = 0.4,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.25,

}

MiniMicrowaveLaserCollisionBeam01 = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.2,
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamEndPointScale = 0.2,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 1.25,

}

HawkTractorClawCollisionBeam = Class(HawkCollisionBeam) {
    
    FxBeam = {EffectTemplate.TTransportBeam01},
    FxBeamEndPoint = {EffectTemplate.TTransportGlow01},
    FxBeamEndPointScale = 1.0,
    FxBeamStartPoint = { EffectTemplate.TTransportGlow01 },
}

JuggLaserCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 0.02,

    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/jugg_laser_beam_01_emit.bp'},
    FxBeamEndPoint = {
		'/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
	},   
    FxBeamEndPointScale = 0.02,
    FxBeamStartPoint = {
		'/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },   
    FxBeamStartPointScale = 0.02,
}

RailLaserCollisionBeam01 = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.2,
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/rail_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamEndPointScale = 0.2,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.25,
    
    OnImpactDestroy = function( self, targetType, targetEntity )

        if targetEntity and not IsUnit(targetEntity) then
            RailLaserCollisionBeam01.OnImpactDestroy(self, targetType, targetEntity)
            return
        end
   
        if self.counter then
    
            if self.counter >= 3 then
                RailLaserCollisionBeam01.OnImpactDestroy(self, targetType, targetEntity)
                return
            else
                self.counter = self.counter + 1
            end
        else
            self.counter = 1
		end
        
   		if targetEntity then
			self.lastimpact = targetEntity:GetEntityId() #remember what was hit last
		end
	end,
}

EMCHPRFDisruptorBeam = Class(HawkCollisionBeam) {

	TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.3,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.3,
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/manticore_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamEndPointScale = 0.3,
    
    OnImpact = function(self, impactType, targetEntity) 

		if targetEntity then 
        
			if LOUDENTITY(categories.TECH1, targetEntity) then
				targetEntity:SetStunned(0.2)
			elseif LOUDENTITY(categories.TECH2, targetEntity) then
				targetEntity:SetStunned(0.2)
			elseif LOUDENTITY(categories.TECH3, targetEntity) and not LOUDENTITY(categories.SUBCOMMANDER, targetEntity) then
				targetEntity:SetStunned(0.2)
			end
		end

		HawkCollisionBeam.OnImpact(self, impactType, targetEntity)
	end, 
}

TDFGoliathCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
	
    TerrainImpactScale = 0.4,
	
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_beam_01_emit.bp'},
	
    FxBeamEndPointScale = 0.4,	
    FxBeamEndPoint = {
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_end_01_emit.bp',			# big glow
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_end_02_emit.bp',			# random bright blueish dots
		'/effects/emitters/uef_orbital_death_laser_end_03_emit.bp',								# darkening lines
		'/effects/emitters/uef_orbital_death_laser_end_04_emit.bp',								# molecular, small details
		'/effects/emitters/uef_orbital_death_laser_end_05_emit.bp',								# rings
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_end_06_emit.bp',			# upward sparks
		'/effects/emitters/uef_orbital_death_laser_end_07_emit.bp',								# outward line streaks
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_end_08_emit.bp',			# center glow
		'/effects/emitters/uef_orbital_death_laser_end_distort_emit.bp',						# screen distortion
	},
	
    FxBeamStartPointScale = 0.4,
    FxBeamStartPoint = {
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_muzzle_01_emit.bp',	# random bright blueish dots
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_muzzle_02_emit.bp',	# molecular, small details
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_muzzle_03_emit.bp',	# darkening lines
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_muzzle_04_emit.bp',	# small downward sparks
		'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_muzzle_05_emit.bp',	# big glow
    },

    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.6,
    ScorchTime = 40,
}

MGAALaserCollisionBeam = Class(HawkCollisionBeam) {

    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/aa_cannon_beam_01_emit.bp'	},
    FxBeamEndPoint = {
		'/effects/emitters/particle_cannon_end_01_emit.bp',
		'/effects/emitters/particle_cannon_end_02_emit.bp',
	},
    FxBeamEndPointScale = 1,
}

GoldenLaserCollisionBeam01 = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxBeamStartPoint = BlackOpsEffectTemplate.GLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_beam_01_emit.bp'},
    FxBeamEndPoint = BlackOpsEffectTemplate.GLaserEndPoint01,
    FxBeamEndPointScale = 0.2,

}

YenaothaExperimentalLaserCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,

    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,

    FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/goliath_death_laser_beam_01_emit.bp'},  ---EffectTemplate.SExperimentalPhasonLaserBeam,

    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,
    FxBeamEndPointScale = 0.5,

    SplatTexture = 'scorch_004_albedo',
    ScorchSize = 3,

}

YenaothaExperimentalLaser02CollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,
	FxBeamStartPointScale = 0.2,
    FxBeam = BlackOpsEffectTemplate.SExperimentalDronePhasonLaserBeam,
    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,
	FxBeamEndPointScale = 0.2,

    SplatTexture = 'scorch_004_albedo',
    ScorchSize = 3.6,

}

YenaothaExperimentalChargeLaserCollisionBeam = Class(HawkCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,
	FxBeamStartPointScale = 0.5,
    FxBeam = BlackOpsEffectTemplate.SExperimentalChargePhasonLaserBeam,
    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,
	FxBeamEndPointScale = 0.5,
}