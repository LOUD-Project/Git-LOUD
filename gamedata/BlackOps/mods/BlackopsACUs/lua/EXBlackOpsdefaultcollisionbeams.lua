local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')

local EXEffectTemplate = import('/mods/BlackopsACUs/lua/EXBlackOpsEffectTemplates.lua')

local CreateLightParticle = CreateLightParticle
local CreateProjectile = moho.entity_methods.CreateProjectile


SCCollisionBeam = Class(CollisionBeam) {

    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,

    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
}

PDLaserCollisionBeam = Class(SCCollisionBeam) {

    FxBeam = {'/mods/BlackOpsACUs/effects/emitters/em_pdlaser_beam_01_emit.bp'},
    
    FxBeamEndPoint = {
		'/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
	},
    FxBeamStartPoint = {
		'/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.5,
}

EXCEMPArrayBeam01CollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {'/mods/BlackOpsACUs/effects/emitters/excemparraybeam01_emit.bp'},
    FxBeamEndPoint = false,
    FxBeamStartPoint = false,
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.5,
}

EXCEMPArrayBeam02CollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {'/mods/BlackOpsACUs/effects/emitters/excemparraybeam02_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.5,
}

EXCEMPArrayBeam03CollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {'/mods/BlackOpsACUs/effects/emitters/excemparraybeam01_emit.bp'},
    FxBeamEndPoint = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxBeamStartPoint = false,
    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 1,
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.5,
	
    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
        
        CreateLightParticle(self, -1, self.Army, 26, 5, 'sparkle_white_add_08', 'ramp_white_24' )
        
        CreateProjectile( self, '/effects/entities/SBOZhanaseeBombEffect01/SBOZhanaseeBombEffect01_proj.bp', 0, 0, 0, 0, 10.0, 0):SetCollision(false):SetVelocity(0,10.0, 0)
        CreateProjectile( self,'/effects/entities/SBOZhanaseeBombEffect02/SBOZhanaseeBombEffect02_proj.bp', 0, 0, 0, 0, 0.05, 0):SetCollision(false):SetVelocity(0,0.05, 0)        
		
        local blanketAngle = 6.28 / 12

        for i = 0, 11 do
        
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            
            CreateProjectile( self, '/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity( 6.25 ):SetAcceleration(-0.3)
        end

        SCCollisionBeam.OnImpact(self, targetType, targetEntity)
    end,
}

PDLaser2CollisionBeam = Class(CollisionBeam) {
    FxBeamStartPoint = EffectTemplate.TDFHiroGeneratorMuzzle01,
    FxBeam = EffectTemplate.TDFHiroGeneratorBeam,
    FxBeamEndPoint = EffectTemplate.TDFHiroGeneratorHitLand,
    SplatTexture = 'czar_mark01_albedo',

	FxBeamStartPointScale = 0.75,
    FxBeamEndPointScale = 0.75,
}

AeonACUPhasonLaserCollisionBeam = Class(SCCollisionBeam) {

    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {'/mods/BlackopsACUs/effects/emitters/exphason_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    
    SplatTexture = 'czar_mark01_albedo',
    ScorchSize = 0.4,

	FxBeamStartPointScale = 0.25,
    FxBeamEndPointScale = 0.5,
}
