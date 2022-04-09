---  /lua/terranprojectiles.lua

local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local OnWaterEntryEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').OnWaterEntryEmitterProjectile
local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile
local SinglePolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile
local MultiPolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').SingleCompositeEmitterProjectile

local EffectTemplate = import('/lua/EffectTemplates.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge

local Random = Random

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end

local ForkThread = ForkThread
local DamageArea = DamageArea

local CreateDecal = CreateDecal
local CreateLightParticle = CreateLightParticle
local CreateSplat = CreateSplat
local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateEmitterAtBone = CreateEmitterAtBone

local Random = Random
local SetCollisionShape = moho.entity_methods.SetCollisionShape

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

TFragmentationGrenade= Class(EmitterProjectile) {

    FxImpactUnit = EffectTemplate.THeavyFragmentationGrenadeUnitHit,
    FxImpactLand = EffectTemplate.THeavyFragmentationGrenadeHit,
    FxImpactWater = EffectTemplate.THeavyFragmentationGrenadeHit,
    FxImpactNone = EffectTemplate.THeavyFragmentationGrenadeHit,
    FxImpactProp = EffectTemplate.THeavyFragmentationGrenadeUnitHit,
    FxTrails= EffectTemplate.THeavyFragmentationGrenadeFxTrails,
}

TIFMissileNuke = Class(SingleBeamProjectile) { BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp' }

TIFTacticalNuke = Class(EmitterProjectile) {}

TAAGinsuRapidPulseBeamProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/laserturret_munition_beam_03_emit.bp',
    FxImpactUnit = EffectTemplate.TAAGinsuHitUnit,
    FxImpactProp = EffectTemplate.TAAGinsuHitUnit,
    FxImpactLand = EffectTemplate.TAAGinsuHitLand,
}

TAALightFragmentationProjectile = Class(SingleCompositeEmitterProjectile) {

    BeamName = '/effects/emitters/antiair_munition_beam_01_emit.bp',
    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    FxTrails = {'/effects/emitters/terran_flack_fxtrail_01_emit.bp'},
    FxImpactAirUnit = EffectTemplate.TFragmentationShell01,
    FxImpactNone = EffectTemplate.TFragmentationShell01,
}

TArtilleryAntiMatterProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/antimatter_polytrail_01_emit.bp',

    FxImpactUnit = EffectTemplate.TAntiMatterShellHit01,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit01,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit01,

    FxSplatScale = 8,

    OnImpact = function(self, targetType, targetEntity)
	
        local army = self.Army
        
		local pos = self:GetPosition()
		local rf = (Random() * 6.28)
		
        if targetType == 'Terrain' then
            CreateDecal( pos, rf, 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 50, army )
            CreateDecal( pos, rf, 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 50, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

TArtilleryAntiMatterProjectile02 = Class(TArtilleryAntiMatterProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_07_emit.bp',

    FxImpactUnit = EffectTemplate.TAntiMatterShellHit02,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit02,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit02,

    OnImpact = function(self, targetType, targetEntity)
    
        local army = self.Army
        
        local pos = self:GetPosition()
		local rf = Random() * 6.28
        
        if targetType == 'Terrain' then
            CreateDecal( pos, rf, 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            CreateDecal( pos, rf, 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            self:ShakeCamera(20, 1, 0, 1)
        end

        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

TArtilleryAntiMatterSmallProjectile = Class(TArtilleryAntiMatterProjectile02) {

    FxLandHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxSplatScale = 4,
}

TArtilleryProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
    FxImpactUnit = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactProp = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactLand = EffectTemplate.TPlasmaCannonHeavyHit01,
}

TArtilleryProjectilePolytrail = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactProp = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactLand = EffectTemplate.TPlasmaCannonHeavyHit01,
}

TCannonSeaProjectile = Class(SingleBeamProjectile) { BeamName = '/effects/emitters/cannon_munition_ship_beam_01_emit.bp' }

TCannonTankProjectile = Class(SingleBeamProjectile) { BeamName = '/effects/emitters/cannon_munition_tank_beam_01_emit.bp' }

TDepthChargeProjectile = Class(OnWaterEntryEmitterProjectile) {

    FxInitial = {},
    FxTrails = {'/effects/emitters/torpedo_underwater_wake_01_emit.bp',},
    TrailDelay = 0,

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.TTorpedoHitUnit01,
    FxImpactProp = EffectTemplate.TTorpedoHitUnit01,
    FxImpactUnderWater = EffectTemplate.TTorpedoHitUnit01,
    FxImpactProjectile = EffectTemplate.TTorpedoHitUnit01,

    FxEnterWater= EffectTemplate.WaterSplash01,

    OnCreate = function(self, inWater)
	
        OnWaterEntryEmitterProjectile.OnCreate(self)
		
        self:TrackTarget(false)
		
    end,

    OnEnterWater = function(self)
	
        OnWaterEntryEmitterProjectile.OnEnterWater(self)
		
        local army = self.Army

        for k, v in self.FxEnterWater do
            CreateEmitterAtEntity(self,army,v)
        end

        self:TrackTarget(false)
        self:StayUnderwater(true)
		
    end,

    AddDepthCharge = function(self, tbl)
	
        if not tbl then return end
		
        if not tbl.Radius then return end
		
        self.MyDepthCharge = DepthCharge { Owner = self, Radius = tbl.Radius or 10,}
		
		if not self.Trash then
		
			self.Trash = TrashBag()
			
		end

        TrashAdd( self.Trash, self.MyDepthCharge )
    end,
}

TDFGaussCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,

    FxImpactUnit = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
}

TDFShipGaussCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,

    FxImpactUnit = EffectTemplate.TShipGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit01,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit01,
}

TDFLandGaussCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,

    FxImpactUnit = EffectTemplate.TLandGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TLandGaussCannonHit01,
    FxImpactLand = EffectTemplate.TLandGaussCannonHit01,
    FxTrailOffset = 0,
}

THeavyPlasmaCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition,
    RandomPolyTrails = 1,

    PolyTrails = EffectTemplate.TPlasmaCannonHeavyPolyTrails,
    FxImpactUnit = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactProp = EffectTemplate.TPlasmaCannonHeavyHitUnit01,
    FxImpactLand = EffectTemplate.TPlasmaCannonHeavyHit01,
}

TIFSmallYieldNuclearBombProjectile = Class(EmitterProjectile) {

    FxImpactUnit = EffectTemplate.TSmallYieldNuclearBombHit01,
    FxImpactProp = EffectTemplate.TSmallYieldNuclearBombHit01,
    FxImpactLand = EffectTemplate.TSmallYieldNuclearBombHit01,

    OnImpact = function(self, TargetType, TargetEntity)

        CreateLightParticle( self, -1, self.Army, 2.75, 4, 'sparkle_03', 'ramp_fire_03' )
        
        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_008_albedo', 6, 6, 200, 120, self.Army )
        end
        
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

TLaserBotProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TLaserPolytrail01,

    FxTrails = EffectTemplate.TLaserFxtrail01,
    FxImpactUnit = EffectTemplate.TLaserHitUnit02,
    FxImpactProp = EffectTemplate.TLaserHitUnit02,
    FxImpactLand = EffectTemplate.TLaserHitLand02,
}

TLaserProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/laserturret_munition_beam_02_emit.bp',
    FxImpactUnit = EffectTemplate.TLaserHitUnit01,
    FxImpactProp = EffectTemplate.TLaserHitUnit01,
    FxImpactLand = EffectTemplate.TLaserHitLand01,
}

TMachineGunProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = EffectTemplate.TMachineGunPolyTrail,

    FxImpactUnit = {
		'/effects/emitters/gauss_cannon_muzzle_flash_01_emit.bp',
		'/effects/emitters/flash_05_emit.bp',
	},
    FxImpactProp = {
		'/effects/emitters/gauss_cannon_muzzle_flash_01_emit.bp',
		'/effects/emitters/flash_05_emit.bp',
    },
    FxImpactLand = {
		'/effects/emitters/gauss_cannon_muzzle_flash_01_emit.bp',
		'/effects/emitters/flash_05_flat_emit.bp',
    },
}

TMissileAAProjectile = Class(EmitterProjectile) {

    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = -0.5,

    FxAirUnitHitScale = 0.4,
    FxLandHitScale = 0.4,
    FxUnitHitScale = 0.4,
    FxPropHitScale = 0.4,
    FxImpactUnit = EffectTemplate.TMissileHit02,
    FxImpactAirUnit = EffectTemplate.TMissileHit02,
    FxImpactProp = EffectTemplate.TMissileHit02,    
    FxImpactLand = EffectTemplate.TMissileHit02,
}

TAntiNukeInterceptorProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_02_emit.bp',
    FxTrails = EffectTemplate.TMissileExhaust03,

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProjectile = EffectTemplate.TMissileHit01,
    FxProjectileHitScale = 5,
}

TMissileCruiseProjectile = Class(SingleBeamProjectile) {

    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,

    OnImpact = function(self, targetType, targetEntity)
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,
--[[
    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
    
        local emit = nil
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
--]]    
}

TMissileCruiseProjectile02 = Class(SingleBeamProjectile) {

    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TShipGaussCannonHitUnit02,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit02,

    OnImpact = function(self, targetType, targetEntity)
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,
--[[
    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
    
        local emit = nil
        
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        for k, v in EffectTable do
        
            emit = CreateEmitterAtEntity(self,army,v)
            
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
--]]    
}

TMissileCruiseSubProjectile = Class(SingleBeamProjectile) {

    FxExitWaterEmitter = EffectTemplate.TIFCruiseMissileLaunchExitWater,
    FxTrailOffset = -0.35,

    FxTrails = EffectTemplate.TMissileExhaust02,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,

    OnExitWater = function(self)
    
		EmitterProjectile.OnExitWater(self)
		
		for k, v in self.FxExitWaterEmitter do
			CreateEmitterAtBone(self, -2, self.Army, v)
		end
    end,
}

TMissileProjectile = Class(SingleBeamProjectile) {

    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
}

TNapalmCarpetBombProjectile = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
}

TNapalmHvyCarpetBombProjectile = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
}

TPlasmaCannonProjectile = Class(SinglePolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonLightMunition,

    PolyTrail = EffectTemplate.TPlasmaCannonLightPolyTrail,
    FxImpactUnit = EffectTemplate.TPlasmaCannonLightHitUnit01,
    FxImpactProp = EffectTemplate.TPlasmaCannonLightHitUnit01,
    FxImpactLand = EffectTemplate.TPlasmaCannonLightHitLand01,
}

TRailGunProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/railgun_polytrail_01_emit.bp',
    FxTrailScale = 1,

    FxImpactUnit = EffectTemplate.TRailGunHitGround01,
    FxImpactProp = EffectTemplate.TRailGunHitGround01,
	FxImpactAirUnit = EffectTemplate.TRailGunHitAir01,
}

TShellPhalanxProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TPhalanxGunPolyTrails,
    PolyTrailOffset = EffectTemplate.TPhalanxGunPolyTrailsOffsets,
    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactNone = EffectTemplate.FireCloudSml01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,

    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.7,
}

TShellRiotProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TRiotGunPolyTrails,
    PolyTrailOffset = EffectTemplate.TRiotGunPolyTrailsOffsets,
    FxTrails = EffectTemplate.TRiotGunMunition01,
    RandomPolyTrails = 1,
    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,
}

TShellRiotProjectileLand = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TRiotGunPolyTrailsTank,
    PolyTrailOffset = EffectTemplate.TRiotGunPolyTrailsOffsets,

    RandomPolyTrails = 1,
    FxImpactUnit = EffectTemplate.TRiotGunHitUnit02,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit02,
    FxImpactLand = EffectTemplate.TRiotGunHit02,
}

TShellRiotProjectileLand02 = Class(TShellRiotProjectileLand) { PolyTrails = EffectTemplate.TRiotGunPolyTrailsEngineer }

TTorpedoShipProjectile = Class(OnWaterEntryEmitterProjectile) {

    FxInitial = {},
    FxTrails = {'/effects/emitters/torpedo_underwater_wake_01_emit.bp',},
    TrailDelay = 0,

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.TTorpedoHitUnit01,
    FxImpactProp = EffectTemplate.TTorpedoHitUnit01,
    FxImpactUnderWater = EffectTemplate.TTorpedoHitUnitUnderwater01,
    FxEnterWater= EffectTemplate.WaterSplash01,

    OnCreate = function(self, inWater)
        OnWaterEntryEmitterProjectile.OnCreate(self)
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(true)
            self:OnEnterWater(self)
        end
    end,

    OnEnterWater = function(self)
        OnWaterEntryEmitterProjectile.OnEnterWater(self)
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)

        for k, v in self.FxEnterWater do
            CreateEmitterAtEntity(self, self.Army, v)
        end
        
        self:TrackTarget(true)
        self:StayUnderwater(true)
        self:SetTurnRate(120)
        self:SetMaxSpeed(18)
        self:ForkThread(self.MovementThread)
    end,
    
    MovementThread = function(self)
        WaitTicks(1)
        self:SetVelocity(3)
    end,
}

TTorpedoSubProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.TTorpedoHitUnit01,
    FxImpactProp = EffectTemplate.TTorpedoHitUnit01,
    FxImpactUnderWater = EffectTemplate.TTorpedoHitUnit01,

    OnCreate = function(self, inWater)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        EmitterProjectile.OnCreate(self, inWater)
    end,
}

TBaseTempProjectile = Class(SinglePolyTrailProjectile) {

    FxImpactLand = EffectTemplate.AMissileHit01,
    FxImpactNone = EffectTemplate.AMissileHit01,
    FxImpactProjectile = EffectTemplate.ASaintImpact01,
    FxImpactProp = EffectTemplate.AMissileHit01,    

    FxImpactUnit = EffectTemplate.AMissileHit01,    
    FxTrails = {
        '/effects/emitters/aeon_laser_fxtrail_01_emit.bp',
        '/effects/emitters/aeon_laser_fxtrail_02_emit.bp',
    },
    PolyTrail = '/effects/emitters/aeon_laser_trail_01_emit.bp',    
}

TGatlingPlasmaCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrailOffset = EffectTemplate.TPlasmaGatlingCannonPolyTrailsOffsets,
    FxImpactNone = EffectTemplate.TPlasmaGatlingCannonUnitHit,
    FxImpactUnit = EffectTemplate.TPlasmaGatlingCannonUnitHit,
    FxImpactProp = EffectTemplate.TPlasmaGatlingCannonUnitHit,
    FxImpactLand = EffectTemplate.TPlasmaGatlingCannonHit,
    FxImpactWater= EffectTemplate.TPlasmaGatlingCannonHit,
    RandomPolyTrails = 1,
    
    PolyTrails = EffectTemplate.TPlasmaGatlingCannonPolyTrails,
}

TIonizedPlasmaGatlingCannon = Class(SinglePolyTrailProjectile) {

    FxImpactWater = EffectTemplate.TIonizedPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit,
    FxImpactNone = EffectTemplate.TIonizedPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonUnitHit,    
    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonUnitHit,    
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrail = EffectTemplate.TIonizedPlasmaGatlingCannonPolyTrail,
}

THeavyPlasmaGatlingCannon = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactProp = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactWater = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxImpactLand = EffectTemplate.THeavyPlasmaGatlingCannonHit,
    FxTrails = EffectTemplate.THeavyPlasmaGatlingCannonFxTrails,
    PolyTrail = EffectTemplate.THeavyPlasmaGatlingCannonPolyTrail,
}

THiroLaser = Class(SinglePolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.THiroLaserUnitHit,
    FxImpactProp = EffectTemplate.THiroLaserHit,
    FxImpactLand = EffectTemplate.THiroLaserLandHit,
    FxImpactWater = EffectTemplate.THiroLaserLandHit,
    
    FxTrails = EffectTemplate.THiroLaserFxtrails,
    PolyTrail = EffectTemplate.THiroLaserPolytrail,
}
