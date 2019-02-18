------------------------------------------------------------------------------
--  File     :  /mods/4DC/lua/4D_projectiles.lua
--
--  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  (Weapon Templates by:Exavier Macbeth)
--
--  Copyright © 2010 4DC  All rights reserved.
------------------------------------------------------------------------------

-------------------------------------------------------------------------
--  PROJECTILES SCRIPTS
-------------------------------------------------------------------------
local Projectile = import('/lua/sim/projectile.lua').Projectile
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local DefaultExplosion = import('/lua/defaultexplosions.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local util = import('/lua/utilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

EmtBpPath = '/effects/emitters/'
MOD_BpPath = '/mods/4DC/effects/emitters/'
Custom_4D_EffectTemplate = import('/mods/4DC/lua/4D_EffectTemplates.lua')

------------------------
--  Rampage Rapid Plasma 
------------------------
Rapid_PlasmaProjectile = Class(EmitterProjectile) {
    FxUnitHitScale = 1.0,
    FxLandHitScale = 1.0,
    FxPropHitScale = 1.0,

    FxTrails = {
        '/effects/emitters/aeon_missiled_wisp_04_emit.bp',
    },
    FxTrailScale = 0.3,

    -- Hit Effects
    FxImpactUnit =  EffectTemplate.AQuarkBombHitUnit01,
    FxImpactProp =  EffectTemplate.AQuarkBombHitUnit01,
    FxImpactLand =  EffectTemplate.AQuarkBombHitLand01,
    FxImpactAirUnit =  EffectTemplate.AQuarkBombHitAirUnit01,
    FxImpactUnderWater = {},
}

----------------------------------------------------
--  Naplam Missile (4th Dimension Custom Projectile)
----------------------------------------------------
NapalmMissileProjectile = Class(SingleCompositeEmitterProjectile) {
    -- Emitter Values
    FxInitial = {},
    TrailDelay = 0,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = 0,
    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',

    -- Hit Effects
    FxImpactUnit = {
        MOD_BpPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactProp = {
        MOD_BpPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactLand = {
        MOD_BpPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactUnderWater = EffectTemplate.WaterSplash01,
}

--------------------------
--  Rampage EMP Overcharge
--------------------------
Over_ChargeProjectile = Class(MultiPolyTrailProjectile) {
    FxUnitHitScale = 1,
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxAirHitScale = 1,
    PolyTrails = {
        '/effects/emitters/laserturret_munition_trail_01_emit.bp',
        '/effects/emitters/default_polytrail_06_emit.bp',
    },
    PolyTrailOffset = {0,0},
    BeamName = '/effects/emitters/laserturret_munition_beam_03_emit.bp',
    FxImpactUnit = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactProp = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactLand = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactAirUnit = EffectTemplate.TCommanderOverchargeHit01,
    FxImpactUnderWater = {},
}

--------------------------------------------------------------------
--  AEON ARROW MISSILE PROJECTILES (4th Dimension Custom Projectile)
--------------------------------------------------------------------
ArrowMissileProjectile = Class(SingleCompositeEmitterProjectile) {
    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxUnitHitScale = 3.0,
    FxLandHitScale = 3.0,
    FxWaterHitScale = 3.0,
    FxUnderWaterHitScale = 2.5,
    FxAirUnitHitScale = 3.0,
    FxNoneHitScale = 3.0,    
    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
    FxImpactUnderWater = {},
    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        SingleCompositeEmitterProjectile.OnCreate(self)
    end,
}

--------------------------------------------------------------------
--  AEON LASER PHALANX PROJECTILES (4th Dimension Custom Projectile)
--------------------------------------------------------------------
LaserPhalanxProjectile = Class(MultiPolyTrailProjectile) {

	PolyTrails = {
  	'/effects/emitters/disintegrator_polytrail_04_emit.bp',
  	'/effects/emitters/disintegrator_polytrail_05_emit.bp',
  	'/effects/emitters/default_polytrail_03_emit.bp',
 	},
 	
    -- offset is needed for proj to hit the missiles 
    PolyTrailOffset = EffectTemplate.TPhalanxGunPolyTrailsOffsets,
    FxTrailScale = 0.25,
    FxImpactUnit = {},
    FxImpactProp = {},
    FxImpactNone = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},
    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.5,
}

-----------------------------------------------------
--  BFG PROJECTILES (4th Dimension Custom Projectile)
-----------------------------------------------------

BFGProjectile = Class(EmitterProjectile) { 
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxTrailScale = 0.75,
    FxImpactUnit =  EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxUnitHitScale = 0.75,
    FxImpactProp =  EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxLandHitScale = 0.75,
    FxImpactLand =  EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxPropHitScale = 0.75,    
}