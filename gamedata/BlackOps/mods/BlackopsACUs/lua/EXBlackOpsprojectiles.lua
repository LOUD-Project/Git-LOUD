local Projectile            = import('/lua/sim/projectile.lua').Projectile
local ProjectileOnCreate    = Projectile.OnCreate

local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')

local EmitterProjectile                 = DefaultProjectileFile.EmitterProjectile
local EmitterProjectileOnCreate         = EmitterProjectile.OnCreate
local EmitterProjectileOnImpact         = EmitterProjectile.OnImpact

local OnWaterEntryEmitterProjectile     = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile              = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile         = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile          = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile  = DefaultProjectileFile.SingleCompositeEmitterProjectile
local MultiCompositeEmitterProjectile   = DefaultProjectileFile.MultiCompositeEmitterProjectile

DefaultProjectileFile = nil

--local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
--local Explosion = import('/lua/defaultexplosions.lua')

local EffectTemplate        = import('/lua/EffectTemplates.lua')
local EXEffectTemplate      = import('/mods/BlackopsACUs/lua/EXBlackOpsEffectTemplates.lua')

local GetPosition = moho.entity_methods.GetPosition

local LOUDFLOOR = math.floor
local LOUDGETN = table.getn

local Random = Random

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end

EXEmitterProjectile = Class(Projectile) {

    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,

    OnCreate = function(self)

        ProjectileOnCreate(self)

        for i in self.FxTrails do
            CreateEmitterOnEntity(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
    end,
}

EXSinglePolyTrailProjectile = Class(EXEmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)
        
        if self.PolyTrail then
            CreateTrail(self, -1, self.Army, self.PolyTrail)
        end
        
    end,
}

EXMultiPolyTrailProjectile = Class(EXEmitterProjectile) {

    RandomPolyTrails = 0,

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)
        
        if self.PolyTrails then
        
            local NumPolyTrails = LOUDGETN( self.PolyTrails )
            
            local army = self.Army

            if self.RandomPolyTrails != 0 then
            
                local index = nil
                
                for i = 1, self.RandomPolyTrails do
                
                    index = MATHFLOOR( Random( 1, NumPolyTrails))
                    
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

EXMultiCompositeEmitterProjectile = Class(EXMultiPolyTrailProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},

    RandomPolyTrails = 0,

    OnCreate = function(self)
    
        MultiPolyTrailProjectile.OnCreate(self)

        for k, v in self.Beams do
            CreateBeamEmitterOnEntity( self, -1, self.Army, v )
        end
    end,
}


FlameThrowerProjectile01 = Class(EmitterProjectile) {

    FxTrails = {'/mods/BlackOpsACUs/Effects/Emitters/NapalmTrailFX.bp',},
    FxTrailScale = 0.75,

    FxImpactUnit = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = EXEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = EXEffectTemplate.FlameThrowerHitWater01,
	FxImpactShield = EXEffectTemplate.FlameThrowerHitLand01,

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

UEFACUAntiMatterProjectile01 = Class(EXMultiCompositeEmitterProjectile ) {

    FxTrails = EXEffectTemplate.ACUAntiMatterFx,
	PolyTrail = EXEffectTemplate.ACUAntiMatterPoly,
    
    FxImpactUnit = EXEffectTemplate.ACUAntiMatter01,
    FxImpactProp = EXEffectTemplate.ACUAntiMatter01,
    FxImpactLand = EXEffectTemplate.ACUAntiMatter01,
    FxImpactWater = EXEffectTemplate.ACUAntiMatter01,
	FxImpactShield = EXEffectTemplate.ACUAntiMatter01,

	FxSplatScale = 3,

    FxLandHitScale = 0.3,
    FxPropHitScale = 0.3,
    FxUnitHitScale = 0.3,
    FxWaterHitScale = 0.3,
	FxShieldHitScale = 0.3,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
        local pos = GetPosition(self)

        if targetType == 'Terrain' then
            CreateDecal( pos, GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 100, 30, army )
            CreateDecal( pos, GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo' , '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 100, 30, army )
        end
        
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        
        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
}

UEFACUAntiMatterProjectile02 = Class(EXMultiCompositeEmitterProjectile ) {

    FxTrails = EXEffectTemplate.ACUAntiMatterFx,
	PolyTrail = EXEffectTemplate.ACUAntiMatterPoly,
    
    FxImpactUnit = EXEffectTemplate.ACUAntiMatter01,
    FxImpactProp = EXEffectTemplate.ACUAntiMatter01,
    FxImpactLand = EXEffectTemplate.ACUAntiMatter01,
    FxImpactWater = EXEffectTemplate.ACUAntiMatter01,
	FxImpactShield = EXEffectTemplate.ACUAntiMatter01,

	FxSplatScale = 3.6,
	
    FxLandHitScale = 0.36,
    FxPropHitScale = 0.36,
    FxUnitHitScale = 0.36,
    FxWaterHitScale = 0.36,
	FxShieldHitScale = 0.36,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
        local pos = GetPosition(self)

        if targetType == 'Terrain' then
            CreateDecal( pos, GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 140, 30, army )
            CreateDecal( pos, GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo',  '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 140, 30, army )
        end
        
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        
        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
}

UEFACUAntiMatterProjectile03 = Class(EXMultiCompositeEmitterProjectile ) {

    FxTrails = EXEffectTemplate.ACUAntiMatterFx,
	PolyTrail = EXEffectTemplate.ACUAntiMatterPoly,
    
    FxImpactUnit = EXEffectTemplate.ACUAntiMatter01,
    FxImpactProp = EXEffectTemplate.ACUAntiMatter01,
    FxImpactLand = EXEffectTemplate.ACUAntiMatter01,
    FxImpactWater = EXEffectTemplate.ACUAntiMatter01,
	FxImpactShield = EXEffectTemplate.ACUAntiMatter01,

	FxSplatScale = 4.5,
	
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
        local pos = GetPosition(self)

        if targetType == 'Terrain' then
            CreateDecal( pos, GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 160, 30, army )
            CreateDecal( pos, GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo',  '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 160, 30, army )
        end
        
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        
        EmitterProjectileOnImpact(self, targetType, targetEntity)
    end,
}


UEFACUClusterMIssileProjectile = Class(SinglePolyTrailProjectile) {

    DestroyOnImpact = false,
    FxTrails = EXEffectTemplate.UEFCruiseMissile01Trails,
    FxTrailOffset = -0.3,
	FxTrailScale = 1.5,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
}

UEFACUClusterMIssileProjectile02 = Class(EXEmitterProjectile) {

    DestroyOnImpact = false,
    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
    FxTrailOffset = 0,
	FxTrailScale = 4.5,

    FxImpactUnit = EffectTemplate.TShipGaussCannonHitUnit02,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit02,
}


SeraACUQuantumStormProjectile01 = Class(EmitterProjectile) {

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


SeraRapidCannon01Projectile = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
	FxImpactShield = EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EXEffectTemplate.SeraACURapidCannonPoly,

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

SeraRapidCannon01Projectile02 = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
	FxImpactShield = EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EXEffectTemplate.SeraACURapidCannonPoly02,

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}

SeraRapidCannon01Projectile03 = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
	FxImpactShield = EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EXEffectTemplate.SeraACURapidCannonPoly03,

    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
	FxShieldHitScale = 0.7,
}


EXInvisoProectilechild01 = Class(EXMultiCompositeEmitterProjectile ) {
    
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit02,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit02,

	FxSplatScale = 4,

    FxLandHitScale = 0.25,
    FxPropHitScale = 0.25,
    FxUnitHitScale = 0.25,
    FxWaterHitScale = 0.25,
	FxShieldHitScale = 0.25,
}

EXInvisoProectile01 = Class(EXInvisoProectilechild01) {
    
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit01,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit01,

	FxSplatScale = 4,
	
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
		
        local blanketSides = 6
        local blanketAngle = 6.28 / blanketSides
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
    
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit02,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit02,

	FxSplatScale = 6,

    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
	FxShieldHitScale = 0.5,
}

EXInvisoProectile02 = Class(EXInvisoProectilechild02) {
    
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit01,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit01,

	FxSplatScale = 6,
	
    FxLandHitScale = 0.75,
    FxPropHitScale = 0.75,
    FxUnitHitScale = 0.75,
    FxWaterHitScale = 0.75,
	FxShieldHitScale = 0.75,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
		
        local blanketSides = 9
        local blanketAngle = 6.28 / blanketSides
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
    
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit02,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit02,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit02,

	FxSplatScale = 8,

    FxLandHitScale = 0.75,
    FxPropHitScale = 0.75,
    FxUnitHitScale = 0.75,
    FxWaterHitScale = 0.75,
	FxShieldHitScale = 0.75,

}

EXInvisoProectile03 = Class(EXInvisoProectilechild03) {
    
    FxImpactUnit = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactProp = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactLand = EXEffectTemplate.CybranACUEMPArrayHit01,
    FxImpactWater = EXEffectTemplate.CybranACUEMPArrayHit01,
	FxImpactShield = EXEffectTemplate.CybranACUEMPArrayHit01,

	FxSplatScale = 8,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
		
        local blanketSides = 12
        local blanketAngle = 6.28 / blanketSides
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


SOmegaCannonOverCharge = Class(MultiPolyTrailProjectile) {

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
}


UEFHeavyPlasmaGatlingCannon01 = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
	FxImpactShield = EffectTemplate.THeavyPlasmaGatlingCannonHit,

    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EXEffectTemplate.UEFHeavyPlasmaGatlingCannon01PolyTrail,
}

UEFHeavyPlasmaGatlingCannon02 = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
	FxImpactShield = EffectTemplate.THeavyPlasmaGatlingCannonHit,

    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EXEffectTemplate.UEFHeavyPlasmaGatlingCannon02PolyTrail,
}

UEFHeavyPlasmaGatlingCannon03 = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
	FxImpactShield = EffectTemplate.THeavyPlasmaGatlingCannonHit,

    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EXEffectTemplate.UEFHeavyPlasmaGatlingCannon03PolyTrail,
}
