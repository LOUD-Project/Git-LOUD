local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')

local EmitterProjectile                  = DefaultProjectileFile.EmitterProjectile
local MultiPolyTrailProjectile           = DefaultProjectileFile.MultiPolyTrailProjectile 
local SingleCompositeEmitterProjectile   = DefaultProjectileFile.SingleCompositeEmitterProjectile

DefaultProjectileFile = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')
local BattlePackEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')


--------------------------
--  TERRAN NAPALM MISSILES
--------------------------
NapalmMissile = Class(SingleCompositeEmitterProjectile) {
    FxInitial = {},
    TrailDelay = 0,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',
    FxImpactUnit = {
        '/mods/BattlePack/effects/emitters/napalm_fire_emit_2.bp',
        '/effects/emitters/napalm_01_emit.bp',
    },
    FxImpactProp = {
        '/mods/BattlePack/effects/emitters/napalm_fire_emit_2.bp',
        '/effects/emitters/napalm_01_emit.bp',
    },
    FxImpactLand = {
        '/mods/BattlePack/effects/emitters/napalm_fire_emit_2.bp',
        '/effects/emitters/napalm_01_emit.bp',
    },
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,

	FxLandHitScale = 2,
    FxPropHitScale = 2,
    FxUnitHitScale = 2,
	FxImpactWaterScale = 2,
}

----------------------
--  NETHER ENERGY BOLT
----------------------
NEnergy = Class(MultiPolyTrailProjectile) {

    FxTrails = {
        '/mods/BattlePack/effects/emitters/plasmaprojectile_trail_03_emit.bp',
        '/mods/BattlePack/effects/emitters/NapalmDistort.bp',
	},

    PolyTrails = BattlePackEffectTemplate.NPlasmaProjectilePolyTrails,
    FxImpactUnit = BattlePackEffectTemplate.NPlasmaProjectileHitUnit01,
    FxImpactProp = BattlePackEffectTemplate.NPlasmaProjectileHitUnit01,
    FxImpactLand = BattlePackEffectTemplate.NPlasmaProjectileHit01,
    FxImpactWater = BattlePackEffectTemplate.NPlasmaProjectileHit01,
    FxImpactShield = BattlePackEffectTemplate.NPlasmaProjectileShieldHit01,
    FxImpactNone = BattlePackEffectTemplate.NPlasmaProjectileShieldHit01,
}

--------------------------
-- Star Adder Flamethrower
--------------------------

Flamethrower = Class(EmitterProjectile) {

    FxTrails = {
        '/mods/BattlePack/effects/emitters/NapalmTrailFX.bp',
        '/mods/BattlePack/effects/emitters/NapalmDistort.bp',
    },
    
    FxImpactTrajectoryAligned = false,

    FxImpactUnit = BattlePackEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactProp = BattlePackEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactLand = BattlePackEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactWater = BattlePackEffectTemplate.NPlasmaFlameThrowerHitWater01,
}
------------------------------------------------------------
-- --Star Adder Missiles - Compliments to Burnie for Effects
------------------------------------------------------------
StarAdderMissiles = Class(MultiPolyTrailProjectile) {

   	FxTrails  = {
        '/mods/BattlePack/effects/emitters/w_u_gau03_p_03_brightglow_emit.bp',
        '/mods/BattlePack/effects/emitters/w_u_gau03_p_04_smoke_emit.bp',
        '/effects/emitters/missile_sam_munition_trail_01_emit.bp',
	},
    
	FxTrailOffset = 0.2,

	PolyTrails  = {
        '/mods/BattlePack/effects/emitters/w_u_gau03_p_01_polytrails_emit.bp',
        '/mods/BattlePack/effects/emitters/w_u_gau03_p_02_polytrails_emit.bp',
	},
    
	PolyTrailOffset = {0.3,0},

    FxImpactUnit        = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactProp        = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactLand        = BattlePackEffectTemplate.BattleMech2RocketHit,
	FxImpactAirUnit     = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactUnderWater  = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactWater       = BattlePackEffectTemplate.BattleMech2RocketHit,
}
