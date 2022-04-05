local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')

local EmitterProjectile = DefaultProjectileFile.EmitterProjectile

local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile 
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile

local EffectTemplate = import('/lua/EffectTemplates.lua')

local Random = Random

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end


local BattlePackEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')

EmtBpPath = '/effects/emitters/'
ModEmitterPath = '/mods/BattlePack/effects/emitters/'

ODisintegratorLaserProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/mods/BattlePack/effects/emitters/EXPCannon_polytrail_04_emit.bp',
		'/mods/BattlePack/effects/emitters/EXPCannon_polytrail_05_emit.bp',
		'/mods/BattlePack/effects/emitters/EXPCannon_polytrail_03_emit.bp',
	},

	FxTrails = BattlePackEffectTemplate.ODisintegratorFxTrails01,  

    FxImpactUnit = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactAirUnit = EffectTemplate.CDisintegratorHitAirUnit01,
    FxImpactProp = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactLand = EffectTemplate.CDisintegratorHitLand01,
}


TShellPhalanxProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = BattlePackEffectTemplate.TPhalanxGunPolyTrails,
    PolyTrailOffset = EffectTemplate.TPhalanxGunPolyTrailsOffsets,
    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactNone = EffectTemplate.FireCloudSml01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,

    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.7,
}


SOmegaCannonOverCharge = Class(MultiPolyTrailProjectile) {

	FxImpactLand = BattlePackEffectTemplate.OmegaOverChargeLandHit,
    FxImpactNone = BattlePackEffectTemplate.OmegaOverChargeLandHit,
    FxImpactProp = BattlePackEffectTemplate.OmegaOverChargeLandHit,    
    FxImpactUnit = BattlePackEffectTemplate.OmegaOverChargeUnitHit,
	FxImpactShield = BattlePackEffectTemplate.OmegaOverChargeLandHit,
    FxLandHitScale = 2,
    FxPropHitScale = 2,
    FxUnitHitScale = 2,
    FxNoneHitScale = 2,
	FxShieldHitScale = 2,
    FxTrails = BattlePackEffectTemplate.OmegaOverChargeProjectileFxTrails,
    PolyTrails = BattlePackEffectTemplate.OmegaOverChargeProjectileTrails,
}

ExWifeMainProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        BattlePackEffectTemplate.ExWifeMainPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },

    PolyTrailScale = 2, 

    FxTrails = BattlePackEffectTemplate.ExWifeMainFXTrail01,
    FxImpactUnit = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactProp = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactLand = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactUnderWater = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactWater = BattlePackEffectTemplate.ExWifeMainHitUnit,

    FxNoneHitScale = 3,
    FxWaterHitScale = 3,
    FxLandHitScale = 3,
    FxUnitHitScale = 3,
}

--------------------------------------------------------------------------
--  TERRAN ALTERNATE PLASMA CANNON PROJECTILES
--------------------------------------------------------------------------
TAlternatePlasmaCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition,
    RandomPolyTrails = 1,

    PolyTrails = EffectTemplate.TPlasmaCannonHeavyPolyTrails,
    FxImpactUnit = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactProp = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactLand = EffectTemplate.TPlasmaCannonHeavyHit01,
}
--------------------------------------------------------------------------
--  TERRAN STINGER MISSILES
--------------------------------------------------------------------------
StingerMissile = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/mods/BattlePack/effects/emitters/air_move_trail_beam_03_emit.bp',},
    FxTrailOffset = 1,
    FxImpactUnit = BattlePackEffectTemplate.UefT3BattletankRocketHit,
    FxUnitHitScale = 0.8,
    FxImpactProp = BattlePackEffectTemplate.UefT3BattletankRocketHit,
    FxPropHitScale = 0.8,
    FxImpactLand = BattlePackEffectTemplate.UefT3BattletankRocketHit,
    FxLandHitScale = 0.8,
    FxImpactUnderWater = BattlePackEffectTemplate.UefT3BattletankRocketHit,
    FxImpactWater = BattlePackEffectTemplate.UefT3BattletankRocketHit,
}

--------------------------------------------------------------------------
--  TERRAN NAPALM MISSILES
--------------------------------------------------------------------------
NapalmMissile = Class(SingleCompositeEmitterProjectile) {
    FxInitial = {},
    TrailDelay = 0,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',
    FxImpactUnit = {
        ModEmitterPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactProp = {
        ModEmitterPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactLand = {
        ModEmitterPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,

	FxLandHitScale = 2,
    FxPropHitScale = 2,
    FxUnitHitScale = 2,
	FxImpactWaterScale = 2,
}

--------------------------------------------------------------------------
--  NETHER ENERGY BOLT
--------------------------------------------------------------------------
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

--------------------------------------------------------------------------
-- Star Adder Flamethrower
--------------------------------------------------------------------------

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
--------------------------------------------------------------------------
-- --Star Adder Missiles - Compliments to Burnie for Effects
--------------------------------------------------------------------------
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

    FxImpactUnit = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactProp = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactLand = BattlePackEffectTemplate.BattleMech2RocketHit,
	FxImpactAirUnit = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactUnderWater = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactWater = BattlePackEffectTemplate.BattleMech2RocketHit,
}
--------------------------------------------------------------------------
-- --Star Adder Missiles - Compliments to Burnie for Effects
--------------------------------------------------------------------------
StarAdderMissilesAir = Class(MultiPolyTrailProjectile) {
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

    FxImpactUnit = EffectTemplate.TMissileHit02,
    FxImpactProp = EffectTemplate.TMissileHit02,
    FxImpactLand = EffectTemplate.TMissileHit02,
	FxImpactAirUnit = EffectTemplate.TMissileHit02,
    FxImpactUnderWater = EffectTemplate.TMissileHit02,
    FxImpactWater = EffectTemplate.TMissileHit02,
}

NapalmProjectile01 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BattlePack/Effects/Emitters/NapalmTrailFX.bp',},

    FxImpactUnit = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BattlePackEffectTemplate.FlameThrowerHitWater01,
}

NapalmProjectile02 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BattlePack/Effects/Emitters/NapalmTrailFX.bp',},
	FxTrailScale = 0.4,

    FxImpactUnit = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BattlePackEffectTemplate.FlameThrowerHitWater01,
}

GattlingRound = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    FxImpactUnit = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
}

--------------------------------------------------------------------------
-- Nomad Missile Stuff
--------------------------------------------------------------------------

StagedMissile = Class(SingleCompositeEmitterProjectile) {

    # a missile that goes through a few states. Useful to make a missile track or not track a target

    OnCreate = function(self, inWater)
        SingleCompositeEmitterProjectile.OnCreate(self)

        local stages = self:GetBlueprint().Physics.Stages
        if stages and stages[1] then
            self:ForkThread( self.StageThread, 1 )
        end
    end,

    StageThread = function(self, stage)
        local bp = self:GetBlueprint().Physics

        if bp.StageBelowHeight[stage] or bp.StageAboveHeight[stage] then
            # if a height is specified for the next stage then keep polling our height until the condition is met
            local height = bp.StageBelowHeight[stage] or bp.StageAboveHeight[stage] or -1
            local below = (bp.StageBelowHeight[stage] != nil and bp.StageBelowHeight[stage] > 0)
            if height > 0 then
                local pos = self:GetPosition()
                while (below and pos[2] > height) or (not below and pos[2] < height) do
                    WaitTicks(1)
                    pos = self:GetPosition()
                end
            end
        end

        # wait some more if a delay is specified
        local delay = bp.StageDelay[stage] or 10
        if delay > 0 then
            WaitTicks( delay )
        end

        self:ApplyStageChanges( stage )
        self:OnStageActivated( stage )

        if bp.Stages[ stage + 1 ] then
            self:StageThread( stage + 1 )
        end
    end,

    ApplyStageChanges = function(self, stage)
        local bp = self:GetBlueprint().Physics
        self:TrackTarget( bp.TrackTargetSInStage[ stage ] or bp.TrackTarget )
        self:TrackTarget( bp.TrackTargetSInStage[ stage ] or bp.TrackTarget )
        self:SetTurnRate( bp.TurnRateSInStage[ stage ] or bp.TurnRate )
        self:SetMaxSpeed( bp.MaxSpeedSInStage[ stage ] or bp.MaxSpeed )
        self:SetAcceleration( bp.AccelerationSInStage[ stage ] or bp.Acceleration )
        self:ChangeMaxZigZag( bp.MaxZigZagSInStage[ stage ] or bp.MaxZigZag )
        self:ChangeZigZagFrequency( bp.ZigZagFrequencySInStage[ stage ] or bp.ZigZagFrequency )
    end,

    OnStageActivated = function(self, stage)
    end,
}



FusionMissile = Class(StagedMissile) {

    FxTrails = BattlePackEffectTemplate.NFusionMissileParticleTrail,
    PolyTrail = BattlePackEffectTemplate.NPlasmaProjectilePolyTrails[1],
    BeamName = '/mods/BattlePack/effects/Emitters/nomad_rocket_exhaust_beam_01.bp',

    FxImpactUnit = BattlePackEffectTemplate.NFusionMissileHit01,
    FxImpactAirUnit = BattlePackEffectTemplate.NFusionMissileHit01,
    FxImpactProp = BattlePackEffectTemplate.NFusionMissileHit01,    
    FxImpactLand = BattlePackEffectTemplate.NFusionMissileHit01,

    SetTMDcanShootDown = function(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        
        local ok = (TargetType != 'Water' and TargetType != 'Shield' and TargetType != 'Air' and TargetType != 'UnitAir')
        
        if ok then 
        
            local rotation = GetRandomFloat( 6.28 )
            local size = GetRandomFloat(4.5, 6.5)
            local life = Random(40, 60)
            
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end
        
        StagedMissile.OnImpact( self, TargetType, TargetEntity )
    end,

    OnLostTarget = function(self)
        self:Destroy()
    end,
}


GravityCannon01Projectile = Class(MultiPolyTrailProjectile) {

    FxTrails = BattlePackEffectTemplate.GravityCannonFxTrail,
    PolyTrails = BattlePackEffectTemplate.GravityCannonPolyTrail,

    FxImpactUnit = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
}

Stingray = Class(MultiPolyTrailProjectile) {

    FxTrails = BattlePackEffectTemplate.NStingrayFXTrail,
    PolyTrails = BattlePackEffectTemplate.NStingrayPolyTrail,

    FxImpactUnit = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactProp = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactLand = BattlePackEffectTemplate.NStingrayHit01,
}

Stingray2 = Class(MultiPolyTrailProjectile) {

    FxTrails = BattlePackEffectTemplate.NStingray2FXTrail,
    PolyTrails = BattlePackEffectTemplate.NStingray2PolyTrail,

    FxImpactUnit = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactProp = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactLand = BattlePackEffectTemplate.NStingrayHit01,
}

TBalrogMagmaCannon = Class(MultiPolyTrailProjectile) {

    FxImpactWater = BattlePackEffectTemplate.TMagmaCannonHit,
    FxImpactLand = BattlePackEffectTemplate.TMagmaCannonHit,
    FxImpactNone = BattlePackEffectTemplate.TMagmaCannonHit,
    FxImpactProp = BattlePackEffectTemplate.TMagmaCannonUnitHit,    
    FxImpactUnit = BattlePackEffectTemplate.TMagmaCannonUnitHit,    
    FxTrails = BattlePackEffectTemplate.TMagmaCannonFxTrails,  

    PolyTrails = BattlePackEffectTemplate.TMagmaCannonPolyTrails,
    PolyTrailOffset = {0,-1.55}, 

    -- Adjusting scale for testing...remove and fix projectile if sizing desired
    FxTrailScale = 1.25,
}

DragoniteMainCannon = Class(SinglePolyTrailProjectile) {

    FxImpactWater = EffectTemplate.TAntiMatterShellHit02,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit02,
    FxImpactNone = EffectTemplate.TAntiMatterShellHit02,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit02,    
    FxImpactUnit = EffectTemplate.TAntiMatterShellHit02,    
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrail = EffectTemplate.TIonizedPlasmaGatlingCannonPolyTrail,
	PolyTrailScale = 2, 
	FxTrailScale = 2,
	FxSplatScale = 4,

}

SeraHeavyLightningCannonChildProjectile = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactLand = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactNone = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactProp = EffectTemplate.SDFExperimentalPhasonProjHit01,    
    FxImpactUnit = EffectTemplate.SDFExperimentalPhasonProjHitUnit,
    FxOnKilled = EffectTemplate.SDFExperimentalPhasonProjHitUnit,
}