--****************************************************************************
--**
--**  File     :  /data/lua/cybranprojectiles.lua
--**  Author(s): John Comes, Gordon Duclos
--**
--**  Summary  :
--**
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--------------------------------------------------------------------------
--  CYBRAN PROJECILES SCRIPTS
--------------------------------------------------------------------------
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local MultiBeamProjectile = DefaultProjectileFile.MultiBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile 
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local NullShell = DefaultProjectileFile.NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')
local util = import('/lua/utilities.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

local BattlePackEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')

EmtBpPath = '/effects/emitters/'
ModEmitterPath = '/mods/BattlePack/effects/emitters/'

ODisintegratorLaserProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/mods/BattlePack/effects/emitters/EXPCannon_polytrail_04_emit.bp',
		'/mods/BattlePack/effects/emitters/EXPCannon_polytrail_05_emit.bp',
		'/mods/BattlePack/effects/emitters/EXPCannon_polytrail_03_emit.bp',
	},
	PolyTrailOffset = {0,0,0},  
	FxTrails = BattlePackEffectTemplate.ODisintegratorFxTrails01,  
	
    # Hit Effects
    FxImpactUnit = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactAirUnit = EffectTemplate.CDisintegratorHitAirUnit01,
    FxImpactProp = EffectTemplate.CDisintegratorHitUnit01,
    FxImpactLand = EffectTemplate.CDisintegratorHitLand01,
    FxImpactUnderWater = {},
}

------------------------------------------------------------------------
--  TERRAN PHALANX PROJECTILES
--------------------------------------------------------------------------
TShellPhalanxProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = BattlePackEffectTemplate.TPhalanxGunPolyTrails,
    PolyTrailOffset = EffectTemplate.TPhalanxGunPolyTrailsOffsets,
    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactNone = EffectTemplate.FireCloudSml01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,
    FxImpactUnderWater = {},
    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.7,
}

--------------------------------------------------------------------------
--  Serephim Overcharge Projectile
--------------------------------------------------------------------------

SOmegaCannonOverCharge = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
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
    PolyTrailOffset = {0,0,0},
}

ExWifeMainProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        BattlePackEffectTemplate.ExWifeMainPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },
    PolyTrailOffset = {0,0}, 
    PolyTrailScale = 2, 

    FxTrails = BattlePackEffectTemplate.ExWifeMainFXTrail01,
    FxImpactUnit = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactProp = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactLand = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactUnderWater = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxImpactWater = BattlePackEffectTemplate.ExWifeMainHitUnit,
    FxTrailOffset = 0,

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
    PolyTrailOffset = {0,0,0},
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
    FxTrailOffset = 0,
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
    FxImpactUnderWater = {},
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

    # Hit Effects
    FxImpactUnit = BattlePackEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactProp = BattlePackEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactLand = BattlePackEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactWater = BattlePackEffectTemplate.NPlasmaFlameThrowerHitWater01,
    FxImpactUnderWater = {},
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
    FxUnitHitScale = 1.3,
    FxImpactProp = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxPropHitScale = 1.3,
    FxImpactLand = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxLandHitScale = 1,
	FxImpactAirUnit = BattlePackEffectTemplate.BattleMech2RocketHit,
	FxAirHitScale = 1.3,
    FxImpactUnderWater = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxImpactWater = BattlePackEffectTemplate.BattleMech2RocketHit,
    FxWaterHitScale = 1.3,
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
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.TMissileHit02,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.TMissileHit02,
    FxLandHitScale = 1,
	FxImpactAirUnit = EffectTemplate.TMissileHit02,
	FxAirHitScale = 1,
    FxImpactUnderWater = EffectTemplate.TMissileHit02,
    FxImpactWater = EffectTemplate.TMissileHit02,
    FxWaterHitScale = 1,
}
--------------------------------------------------------------------------
--  BlackOps Flamethrower Projectile
--------------------------------------------------------------------------
NapalmProjectile01 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BattlePack/Effects/Emitters/NapalmTrailFX.bp',},
    
    FxImpactTrajectoryAligned = false,

    # Hit Effects
    FxImpactUnit = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BattlePackEffectTemplate.FlameThrowerHitWater01,
    FxImpactUnderWater = {},
}

NapalmProjectile02 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BattlePack/Effects/Emitters/NapalmTrailFX.bp',},
	FxTrailScale = 0.4,
    
    FxImpactTrajectoryAligned = false,

    # Hit Effects
    FxImpactUnit = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BattlePackEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BattlePackEffectTemplate.FlameThrowerHitWater01,
    FxImpactUnderWater = {},
}
--------------------------------------------------------------------------
-- Star Adder MachineGun
--------------------------------------------------------------------------
GattlingRound = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
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
    FxImpactNone = {}, #NomadEffectTemplate.NFusionMissileHit01,
    FxImpactUnderWater = {},

    SetTMDcanShootDown = function(self)
        # probably also requires 'TACTICAL' in proj category
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        # create decal
        local ok = (TargetType != 'Water' and TargetType != 'Shield' and TargetType != 'Air' and TargetType != 'UnitAir')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(4.5, 6.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
        StagedMissile.OnImpact( self, TargetType, TargetEntity )
    end,

    OnLostTarget = function(self)
        self:Destroy()
    end,
}

--------------------------------------------------------------------------
-- Gravity Cannon 01
--------------------------------------------------------------------------
GravityCannon01Projectile = Class(MultiPolyTrailProjectile) {
    FxTrails = BattlePackEffectTemplate.GravityCannonFxTrail,
    PolyTrails = BattlePackEffectTemplate.GravityCannonPolyTrail,
    PolyTrailOffset = {0,0,0,0,0},
    FxImpactUnit = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

--------------------------------------------------------------------------
-- Stingray Cannon
--------------------------------------------------------------------------

Stingray = Class(MultiPolyTrailProjectile) {
    FxTrails = BattlePackEffectTemplate.NStingrayFXTrail,
    PolyTrails = BattlePackEffectTemplate.NStingrayPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactProp = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactLand = BattlePackEffectTemplate.NStingrayHit01,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

--------------------------------------------------------------------------
-- Green Stingray Cannon for Rommel
--------------------------------------------------------------------------

Stingray2 = Class(MultiPolyTrailProjectile) {
    FxTrails = BattlePackEffectTemplate.NStingray2FXTrail,
    PolyTrails = BattlePackEffectTemplate.NStingray2PolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactProp = BattlePackEffectTemplate.NStingrayHit01,
    FxImpactLand = BattlePackEffectTemplate.NStingrayHit01,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

-------------------------------------------------------------------------
--  TERRAN UEL0403 Magma Cannon (4DC Custom Projectile)
-------------------------------------------------------------------------
TBalrogMagmaCannon = Class(MultiPolyTrailProjectile) {
    FxImpactWater = BattlePackEffectTemplate.TMagmaCannonHit,
    FxImpactLand = BattlePackEffectTemplate.TMagmaCannonHit,
    FxImpactNone = BattlePackEffectTemplate.TMagmaCannonHit,
    FxImpactProp = BattlePackEffectTemplate.TMagmaCannonUnitHit,    
    FxImpactUnit = BattlePackEffectTemplate.TMagmaCannonUnitHit,    
    FxTrails = BattlePackEffectTemplate.TMagmaCannonFxTrails,  
    -- Using MultPolyTrail:
    PolyTrails = BattlePackEffectTemplate.TMagmaCannonPolyTrails,
    PolyTrailOffset = {0,-1.55}, 
    FxImpactProjectile = {},
    FxImpactUnderWater = {},       
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
    FxImpactProjectile = {},
    FxImpactUnderWater = {},
	
	OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        #CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
        if targetType == 'Terrain' then
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0,2*math.pi), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0,2*math.pi), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

--------------------------------------------------------------------------
-- Lightning Cannon Child
--------------------------------------------------------------------------

SeraHeavyLightningCannonChildProjectile = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactLand = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactNone = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactProp = EffectTemplate.SDFExperimentalPhasonProjHit01,    
    FxImpactUnit = EffectTemplate.SDFExperimentalPhasonProjHitUnit,
    FxOnKilled = EffectTemplate.SDFExperimentalPhasonProjHitUnit,
}