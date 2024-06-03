--**  File     : /cdimage/lua/modules/BlackOpsprojectiles.lua
--**  Author(s): Lt_Hawkeye
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

local Projectile                    = import('/lua/sim/projectile.lua').Projectile
local ProjectileOnCreate            = Projectile.OnCreate

local DefaultProjectileFile         = import('/lua/sim/defaultprojectiles.lua')

local EmitterProjectile                 = DefaultProjectileFile.EmitterProjectile

local EmitterProjectileOnCreate         = EmitterProjectile.OnCreate
local EmitterProjectileOnImpact         = EmitterProjectile.OnImpact

local SingleBeamProjectile              = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile         = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile          = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile  = DefaultProjectileFile.SingleCompositeEmitterProjectile
local NullShell                         = DefaultProjectileFile.NullShell

local EffectTemplate            = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate    = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local LOUDCOS = math.cos
local LOUDDECAL = CreateDecal
local LOUDFLOOR = math.floor

local LOUDSIN = math.sin
local LOUDTRAIL = CreateTrail
local ForkThread = ForkThread

local CreateEmitterOnEntity = CreateEmitterOnEntity
local CreateBeamEmitterOnEntity = CreateBeamEmitterOnEntity

local Random = Random

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end


EXEmitterProjectile                 = Class(Projectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    FxTrailOffset = 0,

    OnCreate = function(self)
    
        ProjectileOnCreate(self)
        
        local army = self.Army
        
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
    end,
}

EXMultiPolyTrailProjectile          = Class(EXEmitterProjectile) {

    PolyTrailOffset = {0},

    RandomPolyTrails = 0,   # Count of how many are selected randomly for PolyTrail table

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)
        
        if self.PolyTrails then
        
            local NumPolyTrails = table.getn( self.PolyTrails )
            
            local army = self.Army

            if self.RandomPolyTrails != 0 then
            
                local index = nil
                
                for i = 1, self.RandomPolyTrails do
                    index = LOUDFLOOR( Random( 1, NumPolyTrails))
                    LOUDTRAIL(self, -1, army, self.PolyTrails[index] ):OffsetEmitter(0, 0, self.PolyTrailOffset[index])
                end
            else
                for i = 1, NumPolyTrails do
                    LOUDTRAIL(self, -1, army, self.PolyTrails[i] ):OffsetEmitter(0, 0, self.PolyTrailOffset[i])
                end
            end
        end
    end,
}

EXMultiCompositeEmitterProjectile   = Class(EXMultiPolyTrailProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},

    RandomPolyTrails = 0,   # Count of how many are selected randomly for PolyTrail table

    OnCreate = function(self)
    
        MultiPolyTrailProjectile.OnCreate(self)
        
        for k, v in self.Beams do
            CreateBeamEmitterOnEntity( self, -1, self.Army, v )
        end
    end,
}


ACUShadowCannonProjectile       = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_01_emit.bp',
		'/mods/BlackOpsUnleashed/effects/emitters/shadowcannon_polytrail_01_emit.bp',
	},

    FxTrails = BlackOpsEffectTemplate.ShadowCannonFXTrail01,

    FxImpactUnit = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactLand = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactUnderWater = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
}

DiskTMD01                       = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_03_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    PolyTrail = '/effects/emitters/quantum_cannon_polytrail_01_emit.bp',

    FxImpactLand = EffectTemplate.ATemporalFizzHit01,
    FxImpactNone= EffectTemplate.ATemporalFizzHit01,
    FxImpactProjectile = EffectTemplate.ATemporalFizzHit01,
    FxImpactProp = EffectTemplate.ATemporalFizzHit01,    
    FxImpactUnit = EffectTemplate.ATemporalFizzHit01,
}

EyeBlast01Projectile            = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactShield = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactLand = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactWater = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
}

GargEMPWarheadProjectile        = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxTrailOffset = -0.5,

    FxLaunchTrails = {},

    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    
    FxImpactUnit = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactShield = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxLandHitScale = 3,
    FxPropHitScale = 3,
    FxUnitHitScale = 3,
    FxShieldHitScale = 3,
    
    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army

        local blanketSides = 12
        local blanketAngle = 6.28 / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2
        
        CreateLightParticle( self, -1, -1, 80, 200, 'flare_lens_add_02', 'ramp_red_10' )

        for i = 0, (blanketSides-1) do
            local blanketX = LOUDSIN(i*blanketAngle)
            local blanketZ = LOUDCOS(i*blanketAngle)
            self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/EffectEMPAmbient01/EffectEMPAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
    
}

GLaserProjectile                = Class(MultiPolyTrailProjectile) {

	FxTrails = BlackOpsEffectTemplate.GoldenTurboLaserShot01FXTrail,  
    PolyTrails = BlackOpsEffectTemplate.GoldenTurboLaserShot01,
}

GoliathTMDProjectile            = Class(MultiPolyTrailProjectile) {

    PolyTrails = BlackOpsEffectTemplate.GoliathTMD01,

    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactNone = EffectTemplate.FireCloudSml01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,

    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.7,
}

MGHeadshotProjectile            = Class(MultiPolyTrailProjectile) {

    PolyTrails = BlackOpsEffectTemplate.MGHeadshotPolytrail01,

    FxTrails = BlackOpsEffectTemplate.MGHeadshotFxtrail01,

	FxImpactLand = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactNone = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactProp = BlackOpsEffectTemplate.MGHeadshotHit01,    
    FxImpactUnit = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
}

MGQAIRocketProjectile           = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/missile_loa_munition_exhaust_beam_01_emit.bp',
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},

    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.MissileUnitHit01,
    FxImpactProp = BlackOpsEffectTemplate.MissileLandHit01,
    FxImpactLand = BlackOpsEffectTemplate.MissileLandHit01,
    
	FxLandHitScale = 0.65,
    FxPropHitScale = 0.65,
    FxUnitHitScale = 0.65,
	FxNoneHitScale = 0.65,
}

MGQAIRocketChildProjectile      = Class(SingleCompositeEmitterProjectile) {

    PolyTrail = '/mods/BlackOpsUnleashed/effects/emitters/mgqai_missile_trail_emit.bp',
    BeamName = '/mods/BlackOpsUnleashed/effects/emitters/mgqai_missle_exhaust_beam_01_emit.bp',

    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.MissileUnitHit01,
    FxImpactProp = BlackOpsEffectTemplate.MissileLandHit01,
    FxImpactLand = BlackOpsEffectTemplate.MissileLandHit01,
    
	FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.6,
	FxNoneHitScale = 0.3,
}

MGQAIPlasmaArtyChildProjectile  = Class(EmitterProjectile) {

    FxTrails = BlackOpsEffectTemplate.MGQAIPlasmaArtyChildFxtrail01,

    FxImpactUnit = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactUnderWater = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,

    OnCreate = function(self, TargetType, TargetEntity)
    
        local projectile = self
		
		SetDamageThread = ForkThread(function(self)
			projectile.DamageData = {
	            DamageRadius = 3,
	            DamageAmount = 20,
	            DoTPulses = 15,
            	DoTTime = 4.5,
	            DamageType = 'Normal',
	            DamageFriendly = true,
	            MetaImpactAmount = nil,
	            MetaImpactRadius = nil,
	        }
			KillThread(self)
		end)
        
		EmitterProjectileOnCreate(self, TargetType, TargetEntity)
	end,
}

MGQAIPlasmaArtyProjectile       = Class(EmitterProjectile) {

    FxTrails = BlackOpsEffectTemplate.MGQAIPlasmaArtyFxtrail01,

    ChildProjectile = '/mods/BlackOpsUnleashed/projectiles/MGQAIPlasmaArtyChild01/MGQAIPlasmaArtyChild01_proj.bp',

    OnCreate = function(self)
        EmitterProjectileOnCreate(self)
        self.Impacted = false
    end,
    
    DoDamage = function(self, instigator, damageData, targetEntity)
        EmitterProjectile.DoDamage(self, instigator, damageData, targetEntity)
    end,
    
    OnImpact = function(self, TargetType, TargetEntity)
        if self.Impacted == false and TargetType != 'Air' then
            self.Impacted = true
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,5),Random(1.5,5))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1,4),Random(1,5),Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,5),-Random(1.5,5))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1.5,5),Random(1,5),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,4),Random(1,5),-Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1.5,4.5),Random(1,5),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,4),Random(1,5),Random(2,4))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,2),Random(1,7),-Random(1,3))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2.5,3.5),Random(2,6),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2,3),Random(2,3),Random(3,5))
            EmitterProjectileOnImpact(self, TargetType, TargetEntity)
        end
    end,
    
    OnImpactDestroy = function( self, TargetType, TargetEntity)
        self:ForkThread( self.DelayedDestroyThread )
    end,

    DelayedDestroyThread = function(self)
        WaitTicks(6)
        self:Destroy()
    end,
}

MiniRocket03PRojectile          = Class(SingleBeamProjectile) {

    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -0.25,
    
    BeamName = '/mods/BlackOpsUnleashed/effects/emitters/missile_munition_exhaust_beam_02_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,

    OnImpact = function(self, targetType, targetEntity)

        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

}

MIRVChild01Projectile           = Class(SingleCompositeEmitterProjectile) {
    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxImpactProp = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxImpactLand = BlackOpsEffectTemplate.Aeon_MirvHit,
}

NapalmProjectile01              = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsUnleashed/Effects/Emitters/NapalmTrailFX.bp',},

    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
}

NapalmProjectile02              = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsUnleashed/Effects/Emitters/NapalmTrailFX.bp',},
   	FxTrailScale = 0.5,

    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,

    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxNoneHitScale = 0.5,
}

NovaStunProjectile              = Class(NullShell) {

	FxImpactUnit = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxUnitHitScale = 0.4,

    FxImpactWater = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxWaterHitScale = 0.4,

    FxImpactLand = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxLandHitScale = 0.4,

    OnImpact = function(self, targetType, targetEntity)

        local Angle = 1.256
        local Velocity = 1

        for i = 0, 4 do

            local X = LOUDSIN(i*Angle)
            local Z = LOUDCOS(i*Angle)

            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', X, 0.5, Z, X, 0, Z):SetVelocity(Velocity):SetAcceleration(-0.5)
        end

        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
    
}

RaiderCannonProjectile          = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/reacton_cannon_fxtrail_01_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_02_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_03_emit.bp',
        '/mods/BlackOpsUnleashed/effects/emitters/raider_cannon_01_emit.bp',
        '/mods/BlackOpsUnleashed/effects/emitters/raider_cannon_02_emit.bp',
    },
    PolyTrail = '/effects/emitters/aeon_commander_overcharge_trail_01_emit.bp',

    FxImpactUnit = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactProp = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactLand = EffectTemplate.AReactonCannonHitLand01,
}

RailGun01Projectile             = Class(MultiPolyTrailProjectile) {
	FxImpactWater = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactLand = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactNone = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactProp = BlackOpsEffectTemplate.RailGunCannonUnitHit,    
    FxImpactUnit = BlackOpsEffectTemplate.RailGunCannonUnitHit,   
	
    FxTrails = BlackOpsEffectTemplate.RailGunFxTrails,
    PolyTrails = BlackOpsEffectTemplate.RailGunPolyTrails,
   
}

RapierNapalmShellProjectile     = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_07_emit.bp',

    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,

    FxLandHitScale = 0.8,
    FxUnitHitScale = 0.8,
    FxPropHitScale = 0.8,
    FxWaterHitScale = 0.8,	
}

RedTurbolaserProjectile         = Class(MultiPolyTrailProjectile) {

	FxTrails = {},  
    PolyTrails = BlackOpsEffectTemplate.RedTurboLaser01,
	
    FxImpactUnit = EffectTemplate.TLandGaussCannonHit01,
    FxImpactProp = EffectTemplate.TLandGaussCannonHit01,
    FxImpactAirUnit = EffectTemplate.TLandGaussCannonHit01,
    FxImpactLand = EffectTemplate.TLandGaussCannonHit01,
}

SeraLightningCannonChild        = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactLand = EffectTemplate.SHeavyQuarnonCannonLandHit,
    FxImpactNone = EffectTemplate.SHeavyQuarnonCannonHit,
    FxImpactProp = EffectTemplate.SHeavyQuarnonCannonHit,    
    FxImpactUnit = EffectTemplate.SHeavyQuarnonCannonUnitHit,
    FxOnKilled = EffectTemplate.SHeavyQuarnonCannonUnitHit,
}

ShadowCannonProjectile          = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/mods/BlackOpsUnleashed/effects/emitters/shadowcannon_polytrail_01_emit.bp',
	},

    FxTrails = BlackOpsEffectTemplate.ShadowCannonFXTrail01,
	FxTrailScale = 0.5,

    FxImpactUnit = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
}

SOmegaCannonOverCharge          = Class(MultiPolyTrailProjectile) {

	FxImpactTrajectoryAligned = false,
	FxImpactLand = BlackOpsEffectTemplate.OmegaOverChargeLandHit,
    FxImpactNone = BlackOpsEffectTemplate.OmegaOverChargeLandHit,
    FxImpactProp = BlackOpsEffectTemplate.OmegaOverChargeLandHit,    
    FxImpactUnit = BlackOpsEffectTemplate.OmegaOverChargeUnitHit,
    FxLandHitScale = 4,
    FxPropHitScale = 4,
    FxUnitHitScale = 4,
    FxNoneHitScale = 4,
    FxTrails = BlackOpsEffectTemplate.OmegaOverChargeProjectileFxTrails,
    PolyTrails = BlackOpsEffectTemplate.OmegaOverChargeProjectileTrails,
}

TAAHeavyFragmentationProjectile = Class(SingleCompositeEmitterProjectile) {
    BeamName = '/effects/emitters/antiair_munition_beam_01_emit.bp',
    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    FxTrails = {'/effects/emitters/terran_flack_fxtrail_01_emit.bp'},
    FxImpactAirUnit = BlackOpsEffectTemplate.THeavyFragmentationShell01,
    FxImpactNone = BlackOpsEffectTemplate.THeavyFragmentationShell01,

    FxAirHitScale = 1.5,
    FxNoneHitScale = 1.5,
}

UEFACUAntiMatterProjectile01    = Class(EXMultiCompositeEmitterProjectile ) {
    PolyTrails = BlackOpsEffectTemplate.ZCannonPolytrail02,

    FxTrails = BlackOpsEffectTemplate.ZCannonFxtrail02,
    
    FxImpactUnit = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactProp = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactLand = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactWater = BlackOpsEffectTemplate.ACUAntiMatter01,

	FxSplatScale = 8,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army

        if targetType == 'Terrain' then
            LOUDDECAL( self:GetPosition(), GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            LOUDDECAL( self:GetPosition(), GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        
        local pos = self:GetPosition()
        
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        
        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
}

WraithProjectile                = Class(SinglePolyTrailProjectile) {
	FxImpactLand = BlackOpsEffectTemplate.WraithCannonHit01,
    FxImpactNone = BlackOpsEffectTemplate.WraithCannonHit01,
	FxImpactProp = BlackOpsEffectTemplate.WraithCannonHit01,    
    FxImpactUnit = BlackOpsEffectTemplate.WraithCannonHit01,    

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    PolyTrail = BlackOpsEffectTemplate.WraithPolytrail01,
    FxTrails = BlackOpsEffectTemplate.WraithMunition01,
}

XCannonProjectile               = Class(MultiPolyTrailProjectile) {

    PolyTrails = { BlackOpsEffectTemplate.XCannonPolyTrail,'/effects/emitters/default_polytrail_01_emit.bp'},

    FxTrails = BlackOpsEffectTemplate.XCannonFXTrail01,

    FxImpactUnit = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactProp = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactLand = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,
    FxLandHitScale = 0.8,
    FxPropHitScale = 0.8,
    FxUnitHitScale = 0.8,
    FxUnderWaterHitScale = 0.8,
    FxWaterHitScale = 0.8,
}

ZCannon01Projectile             = Class(MultiPolyTrailProjectile) {

    PolyTrails = BlackOpsEffectTemplate.ZCannonPolytrail01,

    FxTrails = BlackOpsEffectTemplate.ZCannonFxtrail01,

    FxImpactUnit = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactLand = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.ZCannonHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,

    FxSplatScale = 9,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
        
        if targetType == 'Terrain' then
            LOUDDECAL( self:GetPosition(), GetRandomFloat(0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 50, army )
            LOUDDECAL( self:GetPosition(), GetRandomFloat(0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 50, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        
        local pos = self:GetPosition()
        
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        
        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
}

--[[

EXSinglePolyTrailProjectile = Class(EXEmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',
    PolyTrailOffset = 0,

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)
        
        if self.PolyTrail then
            LOUDTRAIL(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
    end,
}

AMTorpedoShipProjectile = Class(OnWaterEntryEmitterProjectile) {
    FxInitial = {},
    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    TrailDelay = 0,
    TrackTime = 0,

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactProjectile = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxKilled = EffectTemplate.ATorpedoUnitHit01,

    OnCreate = function(self,inWater)
    
        OnWaterEntryEmitterProjectile.OnCreate(self,inWater)
        
        --# if we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(false)
            self:OnEnterWater(self)
        else
            self:TrackTarget(true)
        end
    end, 
}

AMTorpedoCluster = Class(SingleCompositeEmitterProjectile) {
    FxInitial = {},

    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    FxTrailScale = 1,
    TrailDelay = 0,
    TrackTime = 0,

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.ATorpedoUnitHitUnderWater01,
    FxImpactProjectile = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.ATorpedoUnitHitUnderWater01,
    FxKilled = EffectTemplate.ATorpedoUnitHit01,
    
    OnCreate = function(self,inWater)
    
        SingleCompositeEmitterProjectile.OnCreate(self,inWater)
        
        -- if we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(false)
            self:OnEnterWater(self)
        else
            self:TrackTarget(true)
        end
    end, 
}

AssaultTorpedoSubProjectile = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/torpedo_underwater_wake_02_emit.bp',},

    FxImpactUnit = EffectTemplate.CTorpedoUnitHit01,
    FxImpactProp = EffectTemplate.CTorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.CTorpedoUnitHit01,    
    FxImpactLand = EffectTemplate.CTorpedoUnitHit01,
    FxLandHitScale = 4,
    FxPropHitScale = 4,
    FxUnitHitScale = 4,
    FxNoneHitScale = 4,
}

CitadelHVM01Projectile = Class(EmitterProjectile) {

    FxInitial = {},
    TrailDelay = 0.3,
    FxTrails = BlackOpsEffectTemplate.CitadelHVM01Trails,
    FxTrailOffset = -0.3,
	FxTrailScale = 4,

    FxImpactUnit = EffectTemplate.TMissileHit02,
    FxImpactAirUnit = EffectTemplate.TMissileHit02,
    FxImpactProp = EffectTemplate.TMissileHit02,    
    FxImpactLand = EffectTemplate.TMissileHit02,
}

DumbRocketProjectile = Class(SingleBeamProjectile) {

    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
}

DumbRocketProjectile02 = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
    
    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
}

GoldAAProjectile = Class(SinglePolyTrailProjectile) {

    FxTrails =  BlackOpsEffectTemplate.GoldAAFxTrails,
	PolyTrail = BlackOpsEffectTemplate.GoldAAPolyTrail,

    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactAirUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactNone = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
}

HellFireMissileProjectile = Class(SingleCompositeEmitterProjectile) {
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    FxTrailScale = 0.25,

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
}

HawkGaussCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
}

Juggfire01 = Class(MultiPolyTrailProjectile) {
	PolyTrails = BlackOpsEffectTemplate.HGaussCannonPolyTrail,
    FxTrails = {
		'/mods/BlackOpsUnleashed/effects/emitters/Juggfire01_emit.bp',
		'/effects/emitters/napalm_hvy_thin_smoke_emit.bp',
	},

    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
}

MGQAILaserHeavyProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        '/effects/emitters/electron_bolter_trail_01_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

	FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
	
    FxImpactUnit = EffectTemplate.CLaserHitUnit01,
    FxImpactProp = EffectTemplate.CLaserHitUnit01,
    FxImpactLand = EffectTemplate.CLaserHitLand01,
}

MiniRocketPRojectile = Class(SingleBeamProjectile) {

    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,

    OnImpact = function(self, targetType, targetEntity)

        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

}

MiniRocket04PRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    
    BeamName = '/mods/BlackOpsUnleashed/effects/emitters/missile_munition_exhaust_beam_03_emit.bp',
	
	OnImpact = function(self, targetType, targetEntity)

        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

}

MiniRocket02Projectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = 0,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    -- Hit Effects
    FxImpactUnit = EffectTemplate.CMissileLOAHit01,
    FxImpactLand = EffectTemplate.CMissileLOAHit01,
    FxImpactProp = EffectTemplate.CMissileLOAHit01,
    FxImpactNone = EffectTemplate.CMissileLOAHit01,

    OnExitWater = function(self)
		EmitterProjectile.OnExitWater(self)
        
		for k, v in self.FxExitWaterEmitter do
			CreateEmitterAtBone(self, -2, self.Army, v)
		end
    end,
}

ShieldTauCannonProjectile = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.STauCannonHit,
    FxImpactNone = EffectTemplate.STauCannonHit,
    FxImpactProp = EffectTemplate.STauCannonHit,    
    FxImpactUnit = EffectTemplate.STauCannonHit,
    FxImpactShield = EffectTemplate.ADisruptorHitShield,
    FxTrails = EffectTemplate.STauCannonProjectileTrails,
    PolyTrails = EffectTemplate.STauCannonProjectilePolyTrails,
}

ScorpPulseLaser = Class(MultiPolyTrailProjectile) {

    PolyTrails = {EffectTemplate.CHvyProtonCannonPolyTrail,'/effects/emitters/electron_bolter_trail_01_emit.bp'},
    PolyTrailScale = 0.5,

    FxImpactUnit = EffectTemplate.CHvyProtonCannonHitUnit,
    FxUnitHitScale = 0.5,
    FxImpactProp = EffectTemplate.CHvyProtonCannonHitUnit,
    FxPropHitScale = 0.5,
    FxImpactLand = EffectTemplate.CHvyProtonCannonHitLand,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxUnderWarerHitScale = 0.5,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,
    FxWaterHitScale = 0.5,
}

SonicWaveProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = BlackOpsEffectTemplate.WaveCannonPolytrail01,

    FxTrails = BlackOpsEffectTemplate.WaveCannonFxtrail01,

    FxImpactUnit = EffectTemplate.AGravitonBolterHit01,
    FxImpactProp = EffectTemplate.AGravitonBolterHit01,
    FxImpactLand = EffectTemplate.AGravitonBolterHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
}

SeaDragonShell = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    FxImpactUnit = EffectTemplate.CMolecularResonanceHitUnit01,
    FxUnitHitScale = 1.4,
    FxImpactProp = EffectTemplate.CMolecularResonanceHitUnit01,
    FxPropHitScale = 1.4,    
    FxImpactLand = EffectTemplate.CMolecularResonanceHitUnit01,
    FxLandHitScale = 1.4,
	
    DestroyOnImpact = false,

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        self.Impacted = false
    end,

    DelayedDestroyThread = function(self)
        WaitTicks(4)
        self.CreateImpactEffects( self, self.Army, self.FxImpactUnit, self.FxUnitHitScale )
        self:Destroy()
    end,

    OnImpact = function(self, TargetType, TargetEntity)
	
        if self.Impacted == false then
		
            self.Impacted = true
			
            if TargetType == 'Terrain' then
                SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
                self:ForkThread( self.DelayedDestroyThread )
            else
                SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
                self:Destroy()
            end
        end
    end,
}

SLaanseTacticalMissile = Class(SinglePolyTrailProjectile) {

    FxImpactLand = EffectTemplate.SLaanseMissleHit,
    FxImpactProp = EffectTemplate.SLaanseMissleHitUnit,

    FxImpactUnit = EffectTemplate.SLaanseMissleHitUnit,    
    FxTrails = EffectTemplate.SLaanseMissleExhaust02,
    PolyTrail = EffectTemplate.SLaanseMissleExhaust01,
}

}


--]]