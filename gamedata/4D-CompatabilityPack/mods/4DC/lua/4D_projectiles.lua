--local Projectile = import('/lua/sim/projectile.lua').Projectile

local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')

local EmitterProjectile                 = DefaultProjectileFile.EmitterProjectile
local MultiPolyTrailProjectile          = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile  = DefaultProjectileFile.SingleCompositeEmitterProjectile

DefaultProjectileFile = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')

ArrowMissileProjectile = Class(SingleCompositeEmitterProjectile) {

    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxAirUnitHitScale = 3.0,

    FxImpactUnit = EffectTemplate.AMissileHit01,

    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        SingleCompositeEmitterProjectile.OnCreate(self)
    end,
}

BFGProjectile = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxTrailScale = 0.75,

    FxImpactUnit =  EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxUnitHitScale = 0.75,
    FxImpactProp =  EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxLandHitScale = 0.3,
    FxImpactLand =  EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxPropHitScale = 0.3,    
}

LaserPhalanxProjectile = Class(MultiPolyTrailProjectile) {

	PolyTrails = {
  	'/effects/emitters/disintegrator_polytrail_04_emit.bp',
  	'/effects/emitters/disintegrator_polytrail_05_emit.bp',
  	'/effects/emitters/default_polytrail_03_emit.bp',
 	},
 	
    -- offset is needed for proj to hit the missiles 
    PolyTrailOffset = EffectTemplate.TPhalanxGunPolyTrailsOffsets,
    FxTrailScale = 0.25,

    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.5,
}

Over_ChargeProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
        '/effects/emitters/laserturret_munition_trail_01_emit.bp',
        '/effects/emitters/default_polytrail_06_emit.bp',
    },

    BeamName = '/effects/emitters/laserturret_munition_beam_03_emit.bp',
    FxImpactUnit = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactProp = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactLand = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactAirUnit = EffectTemplate.TCommanderOverchargeHit01,

}
