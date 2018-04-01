#****************************************************************************
#**
#**  File     : /cdimage/lua/modules/BlackOpsprojectiles.lua
#**  Author(s): Lt_Hawkeye
#**
#**  Summary  :
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
#------------------------------------------------------------------------
#  Lt_hawkeye's Custom Projectiles
#------------------------------------------------------------------------
local Projectile = import('/lua/sim/projectile.lua').Projectile
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local MultiCompositeEmitterProjectile = DefaultProjectileFile.MultiCompositeEmitterProjectile
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local util = import('/lua/utilities.lua')
local EXEffectTemplate = import('/mods/BlackopsACUs/lua/EXBlackOpsEffectTemplates.lua')

#---------------------------------------------------------------
# Null Shell
#---------------------------------------------------------------
EXNullShell = Class(Projectile) {}

#---------------------------------------------------------------
# PROJECTILE WITH ATTACHED EFFECT EMITTERS
#---------------------------------------------------------------
EXEmitterProjectile = Class(Projectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    FxTrailOffset = 0,

    OnCreate = function(self)
        Projectile.OnCreate(self)
        local army = self:GetArmy()
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
    end,
}

#---------------------------------------------------------------
# BEAM PROJECTILES
#---------------------------------------------------------------
EXSingleBeamProjectile = Class(EXEmitterProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.BeamName then
            CreateBeamEmitterOnEntity( self, -1, self:GetArmy(), self.BeamName )
        end
    end,
}

EXMultiBeamProjectile = Class(EXEmitterProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        local beam = nil
        local army = self:GetArmy()
        for k, v in self.Beams do
            CreateBeamEmitterOnEntity( self, -1, army, v )
        end
    end,
}

#---------------------------------------------------------------
# POLY-TRAIL PROJECTILES
#---------------------------------------------------------------
EXSinglePolyTrailProjectile = Class(EXEmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',
    PolyTrailOffset = 0,
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrail != '' then
            CreateTrail(self, -1, self:GetArmy(), self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
    end,
}

EXMultiPolyTrailProjectile = Class(EXEmitterProjectile) {

    PolyTrailOffset = {0},
    FxTrails = {},
    RandomPolyTrails = 0,   # Count of how many are selected randomly for PolyTrail table

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrails then
            local NumPolyTrails = table.getn( self.PolyTrails )
            local army = self:GetArmy()

            if self.RandomPolyTrails != 0 then
                local index = nil
                for i = 1, self.RandomPolyTrails do
                    index = math.floor( Random( 1, NumPolyTrails))
                    CreateTrail(self, -1, army, self.PolyTrails[index] ):OffsetEmitter(0, 0, self.PolyTrailOffset[index])
                end
            else
                for i = 1, NumPolyTrails do
                    CreateTrail(self, -1, army, self.PolyTrails[i] ):OffsetEmitter(0, 0, self.PolyTrailOffset[i])
                end
            end
        end
    end,
}


#---------------------------------------------------------------
# COMPOSITE EMITTER PROJECTILES - MULTIPURPOSE PROJECTILES
# - THAT COMBINES BEAMS, POLYTRAILS, AND NORMAL EMITTERS
#---------------------------------------------------------------

# LIGHTWEIGHT VERSION THAT LIMITS USE TO 1 BEAM, 1 POLYTRAIL, AND STANDARD EMITTERS
EXSingleCompositeEmitterProjectile = Class(EXSinglePolyTrailProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',
    FxTrails = {},

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        if self.BeamName != '' then
            CreateBeamEmitterOnEntity( self, -1, self:GetArmy(), self.BeamName )
        end
    end,
}

# HEAVYWEIGHT VERSION, ALLOWS FOR MULTIPLE BEAMS, POLYTRAILS, AND STANDARD EMITTERS
EXMultiCompositeEmitterProjectile = Class(EXMultiPolyTrailProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    PolyTrailOffset = {0},
    RandomPolyTrails = 0,   # Count of how many are selected randomly for PolyTrail table
    FxTrails = {},

    OnCreate = function(self)
        MultiPolyTrailProjectile.OnCreate(self)
        local beam = nil
        local army = self:GetArmy()
        for k, v in self.Beams do
            CreateBeamEmitterOnEntity( self, -1, army, v )
        end
    end,
}

#------------------------------------------------------------------------
#  UEF ACU Flame Thrower
#------------------------------------------------------------------------
FlameThrowerProjectile01 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsACUs/Effects/Emitters/NapalmTrailFX.bp',},
    FxTrailScale = 0.75,
    FxImpactTrajectoryAligned = false,

    # Hit Effects
    FxImpactUnit = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = EXEffectTemplate.FlameThrowerHitWater01,
	FxImpactShield = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactUnderWater = {},

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

#------------------------------------------------------------------------
#  UEF ACU Antimatter Cannon
#------------------------------------------------------------------------
UEFACUAntiMatterProjectile01 = Class(EXMultiCompositeEmitterProjectile ) {
    FxTrails = EXEffectTemplate.ACUAntiMatterFx,
	PolyTrail = EXEffectTemplate.ACUAntiMatterPoly,
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.ACUAntiMatter01,
    FxImpactProp = EXEffectTemplate.ACUAntiMatter01,
    FxImpactLand = EXEffectTemplate.ACUAntiMatter01,
    FxImpactWater = EXEffectTemplate.ACUAntiMatter01,
	FxImpactShield = EXEffectTemplate.ACUAntiMatter01,
    FxImpactUnderWater = {},
	FxSplatScale = 4,

    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        #CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
        if targetType == 'Terrain' then
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            --self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

UEFACUAntiMatterProjectile02 = Class(EXMultiCompositeEmitterProjectile ) {
    FxTrails = EXEffectTemplate.ACUAntiMatterFx,
	PolyTrail = EXEffectTemplate.ACUAntiMatterPoly,
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.ACUAntiMatter01,
    FxImpactProp = EXEffectTemplate.ACUAntiMatter01,
    FxImpactLand = EXEffectTemplate.ACUAntiMatter01,
    FxImpactWater = EXEffectTemplate.ACUAntiMatter01,
	FxImpactShield = EXEffectTemplate.ACUAntiMatter01,
    FxImpactUnderWater = {},
	FxSplatScale = 5.5,
	
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        #CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
        if targetType == 'Terrain' then
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

UEFACUAntiMatterProjectile03 = Class(EXMultiCompositeEmitterProjectile ) {
    FxTrails = EXEffectTemplate.ACUAntiMatterFx,
	PolyTrail = EXEffectTemplate.ACUAntiMatterPoly,
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.ACUAntiMatter01,
    FxImpactProp = EXEffectTemplate.ACUAntiMatter01,
    FxImpactLand = EXEffectTemplate.ACUAntiMatter01,
    FxImpactWater = EXEffectTemplate.ACUAntiMatter01,
	FxImpactShield = EXEffectTemplate.ACUAntiMatter01,
    FxImpactUnderWater = {},
	FxSplatScale = 8,
	
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxUnitHitScale = 1,
    FxWaterHitScale = 1,
	FxShieldHitScale = 1,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        #CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
        if targetType == 'Terrain' then
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            CreateDecal( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

#------------------------------------------------------------------------
#  UEF ACU Cluster Missle Pack
#------------------------------------------------------------------------
UEFACUClusterMIssileProjectile = Class(SinglePolyTrailProjectile) {
    DestroyOnImpact = false,
    FxTrails = EXEffectTemplate.UEFCruiseMissile01Trails,
    FxTrailOffset = -0.3,
	FxTrailScale = 1.5,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactUnderWater = {},
}

UEFACUClusterMIssileProjectile02 = Class(EXEmitterProjectile) {
    DestroyOnImpact = false,
    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
    FxTrailOffset = 0,
	FxTrailScale = 4.5,

    FxImpactUnit = EffectTemplate.TShipGaussCannonHitUnit02,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit02,
    FxImpactUnderWater = {},
}

#------------------------------------------------------------------------
#  Serephim Quantum Storm
#------------------------------------------------------------------------
SeraACUQuantumStormProjectile01 = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = EXEffectTemplate.SeraACUQuantumStormProjectileHitUnit,
    FxImpactProp = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
    FxImpactLand = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
    FxImpactWater = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
	FxImpactShield = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,

    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,

}

SeraACUQuantumStormProjectile02 = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = EXEffectTemplate.SeraACUQuantumStormProjectileHitUnit,
    FxImpactProp = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
    FxImpactLand = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
    FxImpactWater = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
	FxImpactShield = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
	
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,

}

SeraACUQuantumStormProjectile03 = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = EXEffectTemplate.SeraACUQuantumStormProjectileHitUnit,
    FxImpactProp = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
    FxImpactLand = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
    FxImpactWater = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
	FxImpactShield = EXEffectTemplate.SeraACUQuantumStormProjectileHit01,
	
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,

}

#------------------------------------------------------------------------
#  Serephim Rapid Cannon
#------------------------------------------------------------------------
SeraRapidCannon01Projectile = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
	FxImpactShield = EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EXEffectTemplate.SeraACURapidCannonPoly,
    PolyTrailOffset = {0,0,0},

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

#------------------------------------------------------------------------
#  Serephim Rapid Cannon V2
#------------------------------------------------------------------------
SeraRapidCannon01Projectile02 = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
	FxImpactShield = EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EXEffectTemplate.SeraACURapidCannonPoly02,
    PolyTrailOffset = {0,0,0},

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

#------------------------------------------------------------------------
#  Serephim Rapid Cannon V3
#------------------------------------------------------------------------
SeraRapidCannon01Projectile03 = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
	FxImpactShield = EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EXEffectTemplate.SeraACURapidCannonPoly03,
    PolyTrailOffset = {0,0,0},

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

#------------------------------------------------------------------------
#  Cybran EMP Array Detonation
#------------------------------------------------------------------------
EXInvisoProectilechild01 = Class(EXMultiCompositeEmitterProjectile ) {
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit02,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactUnderWater = {},
	FxSplatScale = 4,

    FxLandHitScale = 0.25,
    FxPropHitScale = 0.25,
    FxUnitHitScale = 0.25,
    FxWaterHitScale = 0.25,
	FxShieldHitScale = 0.25,

}

EXInvisoProectile01 = Class(EXInvisoProectilechild01) {
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit01,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactUnderWater = {},
	FxSplatScale = 4,
	
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,


    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        --CreateLightParticle(self, -1, self:GetArmy(), 26, 5, 'sparkle_white_add_08', 'ramp_white_24' )
        --self:CreateProjectile('/effects/entities/SBOZhanaseeBombEffect01/SBOZhanaseeBombEffect01_proj.bp', 0, 0, 0, 0, 10.0, 0):SetCollision(false):SetVelocity(0,10.0, 0)
        --self:CreateProjectile('/effects/entities/SBOZhanaseeBombEffect02/SBOZhanaseeBombEffect02_proj.bp', 0, 0, 0, 0, 0.05, 0):SetCollision(false):SetVelocity(0,0.05, 0)        
		
        local blanketSides = 6
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 0.75
        local blanketVelocity = 6.25

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.25, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EXMultiCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,

}

EXInvisoProectilechild02 = Class(EXMultiCompositeEmitterProjectile ) {
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit02,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactUnderWater = {},
	FxSplatScale = 6,

    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,

}

EXInvisoProectile02 = Class(EXInvisoProectilechild02) {
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit01,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactUnderWater = {},
	FxSplatScale = 6,
	
    FxLandHitScale = 0.75,
    FxPropHitScale = 0.75,
    FxUnitHitScale = 0.75,
    FxWaterHitScale = 0.75,
	FxShieldHitScale = 0.75,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        --CreateLightParticle(self, -1, self:GetArmy(), 26, 5, 'sparkle_white_add_08', 'ramp_white_24' )
        --self:CreateProjectile('/effects/entities/SBOZhanaseeBombEffect01/SBOZhanaseeBombEffect01_proj.bp', 0, 0, 0, 0, 10.0, 0):SetCollision(false):SetVelocity(0,10.0, 0)
        --self:CreateProjectile('/effects/entities/SBOZhanaseeBombEffect02/SBOZhanaseeBombEffect02_proj.bp', 0, 0, 0, 0, 0.05, 0):SetCollision(false):SetVelocity(0,0.05, 0)        
		
        local blanketSides = 9
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 0.75
        local blanketVelocity = 6.25

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.25, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EXMultiCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,

}

EXInvisoProectilechild03 = Class(EXMultiCompositeEmitterProjectile ) {
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit02,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactUnderWater = {},
	FxSplatScale = 8,

    FxLandHitScale = 0.75,
    FxPropHitScale = 0.75,
    FxUnitHitScale = 0.75,
    FxWaterHitScale = 0.75,
	FxShieldHitScale = 0.75,

}

EXInvisoProectile03 = Class(EXInvisoProectilechild03) {
    
    # Hit Effects
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit01,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactUnderWater = {},
	FxSplatScale = 8,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        --CreateLightParticle(self, -1, self:GetArmy(), 26, 5, 'sparkle_white_add_08', 'ramp_white_24' )
        --self:CreateProjectile('/effects/entities/SBOZhanaseeBombEffect01/SBOZhanaseeBombEffect01_proj.bp', 0, 0, 0, 0, 10.0, 0):SetCollision(false):SetVelocity(0,10.0, 0)
        --self:CreateProjectile('/effects/entities/SBOZhanaseeBombEffect02/SBOZhanaseeBombEffect02_proj.bp', 0, 0, 0, 0, 0.05, 0):SetCollision(false):SetVelocity(0,0.05, 0)        
		
        local blanketSides = 12
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 0.75
        local blanketVelocity = 6.25

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EXMultiCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,

}

#------------------------------------------------------------------------
#  Serephim Overcharge Projectile
#------------------------------------------------------------------------

SOmegaCannonOverCharge = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
	FxImpactLand = EXEffectTemplate.OmegaOverChargeLandHit,
    FxImpactNone = EXEffectTemplate.OmegaOverChargeLandHit,
    FxImpactProp = EXEffectTemplate.OmegaOverChargeLandHit,    
    FxImpactUnit = EXEffectTemplate.OmegaOverChargeUnitHit,
	FxImpactShield = EXEffectTemplate.OmegaOverChargeLandHit,
    FxLandHitScale = 4,
    FxPropHitScale = 4,
    FxUnitHitScale = 4,
    FxNoneHitScale = 4,
	FxShieldHitScale = 4,
    FxTrails = EXEffectTemplate.OmegaOverChargeProjectileFxTrails,
    PolyTrails = EXEffectTemplate.OmegaOverChargeProjectileTrails,
    PolyTrailOffset = {0,0,0},
}

#------------------------------------------------------------------------
#  UEF Gatling Projectile V3
#------------------------------------------------------------------------

UEFHeavyPlasmaGatlingCannon03 = Class(SinglePolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
	FxImpactShield = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactUnderWater = {},
    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EXEffectTemplate.UEFHeavyPlasmaGatlingCannon03PolyTrail,
}

#------------------------------------------------------------------------
#  UEF Gattling Projectile V2
#------------------------------------------------------------------------

UEFHeavyPlasmaGatlingCannon01 = Class(SinglePolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
	FxImpactShield = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactUnderWater = {},
    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EXEffectTemplate.UEFHeavyPlasmaGatlingCannon01PolyTrail,
}

#------------------------------------------------------------------------
#  UEF Gatling Projectile V3
#------------------------------------------------------------------------

UEFHeavyPlasmaGatlingCannon02 = Class(SinglePolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
	FxImpactShield = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactUnderWater = {},
    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EXEffectTemplate.UEFHeavyPlasmaGatlingCannon02PolyTrail,
}
