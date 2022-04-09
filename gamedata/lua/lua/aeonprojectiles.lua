---  /lua/aeonprojectiles.lua

local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local OnWaterEntryEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').OnWaterEntryEmitterProjectile
local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile
local SinglePolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile
local MultiPolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').SingleCompositeEmitterProjectile
local MultiCompositeEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').MultiCompositeEmitterProjectile

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

local CreateScorchMarkSplat = import('defaultexplosions.lua').CreateScorchMarkSplat

local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateTrail = CreateTrail
local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateLightParticle = CreateLightParticle

local DamageArea = DamageArea
local ForkThread = ForkThread

local LOUDINSERT = table.insert

local SetCollisionShape = moho.entity_methods.SetCollisionShape

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local WaitTicks = coroutine.yield

ASaintAntiNuke = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/aeon_missile_trail_02_emit.bp',
    FxTrails = {'/effects/emitters/saint_munition_01_emit.bp'},

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactNone = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
    FxImpactProjectile = EffectTemplate.ASaintImpact01,
}

AIFBallisticMortarProjectile = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.AQuarkBomb01,

    FxImpactUnit =  EffectTemplate.AIFBallisticMortarHit01,
    FxImpactProp =  EffectTemplate.AIFBallisticMortarHit01,
    FxImpactLand =  EffectTemplate.AIFBallisticMortarHit01,
    FxImpactAirUnit =  EffectTemplate.AIFBallisticMortarHit01,
}

AIFBallisticMortarProjectile02 = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.AIFBallisticMortarTrails02,

	FxTrails = EffectTemplate.AIFBallisticMortarFxTrails02,
    FxImpactUnit =  EffectTemplate.AIFBallisticMortarHitUnit02,
    FxImpactProp =  EffectTemplate.AIFBallisticMortarHitUnit02,
    FxImpactLand =  EffectTemplate.AIFBallisticMortarHitLand02,
}

AArtilleryProjectile = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.AIFBallisticMortarTrails01,
    FxTrailScale = 0.75,

    FxImpactUnit =  EffectTemplate.AQuarkBombHitUnit01,
    FxImpactProp =  EffectTemplate.AQuarkBombHitUnit01,
    FxImpactLand =  EffectTemplate.AQuarkBombHitLand01,
    FxImpactAirUnit =  EffectTemplate.AQuarkBombHitAirUnit01,

}

ABeamProjectile = Class(NullShell) {

    FxUnitHitScale = 0.5,
    FxImpactUnit = EffectTemplate.ABeamHitUnit01,
    FxImpactProp = EffectTemplate.ABeamHitUnit01,
    FxImpactLand = EffectTemplate.ABeamHitLand01,
}

AGravitonBombProjectile = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},

    FxImpactUnit = EffectTemplate.ABombHit01,
    FxImpactProp = EffectTemplate.ABombHit01,
    FxImpactLand = EffectTemplate.ABombHit01,
}

ACannonSeaProjectile = Class(SingleBeamProjectile) {
    BeamName = '/effects/emitters/cannon_munition_ship_aeon_beam_01_emit.bp',
}

ACannonTankProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/cannon_munition_ship_aeon_beam_01_emit.bp',

    OnCreate = function(self)
    
        SingleBeamProjectile.OnCreate(self)
		
        if self.PolyTrails then
			
            for _, value in self.PolyTrails do
                CreateTrail( self, -1, self.Army, value)
            end
        end
    end,
}

ADepthChargeProjectile = Class(OnWaterEntryEmitterProjectile) {

    FxInitial = {},
    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},
    TrailDelay = 0,
    TrackTime = 0,

    FxImpactUnit = EffectTemplate.ADepthChargeHitUnit01,
    FxImpactProp = EffectTemplate.ADepthChargeHitUnit01,
    FxImpactUnderWater = EffectTemplate.ADepthChargeHitUnderWaterUnit01,

    OnCreate = function(self, inWater)
        OnWaterEntryEmitterProjectile.OnCreate(self)
    end,

    OnEnterWater = function(self)
    
        OnWaterEntryEmitterProjectile.OnEnterWater(self)
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0 )
		
        for _, v in self.FxEnterWater do 
            CreateEmitterAtEntity(self, self.Army, v)
        end

    end,

    AddDepthCharge = function(self, tbl)
	
        if not tbl then return end
        if not tbl.Radius then return end
		
        self.MyDepthCharge = DepthCharge { Owner = self, Radius = tbl.Radius or 10 }
		
		if not self.Trash then
			self.Trash = TrashBag()
		end

        TrashAdd( self.Trash, self.MyDepthCharge )
    end,
}

AGravitonProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/graviton_munition_trail_01_emit.bp',},
    FxImpactUnit = EffectTemplate.AGravitonBolterHit01,
    FxImpactLand = EffectTemplate.AGravitonBolterHit01,
    FxImpactProp = EffectTemplate.AGravitonBolterHit01,
    DirectionalImpactEffect = {'/effects/emitters/graviton_bolter_hit_01_emit.bp',},
}

AHighIntensityLaserProjectile = Class(SinglePolyTrailProjectile) {

    FxTrails = {
        '/effects/emitters/aeon_laser_fxtrail_01_emit.bp',
        '/effects/emitters/aeon_laser_fxtrail_02_emit.bp',
    },
    PolyTrail = '/effects/emitters/aeon_laser_trail_01_emit.bp',

    FxImpactUnit = EffectTemplate.AHighIntensityLaserHitUnit01,
    FxImpactProp = EffectTemplate.AHighIntensityLaserHitUnit01,
    FxImpactLand = EffectTemplate.AHighIntensityLaserHitLand01,
}

AIMFlareProjectile = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = 1.0,

    FxImpactNone = EffectTemplate.AAntiMissileFlareHit,
    FxImpactProjectile = EffectTemplate.AAntiMissileFlareHit,
    FxOnKilled = EffectTemplate.AAntiMissileFlareHit,
    FxUnitHitScale = 0.4,
    FxLandHitScale = 0.4,
    FxWaterHitScale = 0.4,
    FxUnderWaterHitScale = 0.4,
    FxAirUnitHitScale = 0.4,
    FxNoneHitScale = 0.4,

    OnImpact = function(self, TargetType, targetEntity)
	
        EmitterProjectile.OnImpact(self, TargetType, targetEntity)
		
        if TargetType == 'Terrain' or TargetType == 'Water' or TargetType == 'Prop' then
            if self.Trash then
                TrashDestroy(self.Trash)
            end
            self:Destroy()
        end
    end,
}

ALaserBotProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/aeon_laser_trail_01_emit.bp',

    FxImpactUnit = EffectTemplate.ALaserBotHitUnit01,
    FxImpactProp = EffectTemplate.ALaserBotHitUnit01,
    FxImpactLand = EffectTemplate.ALaserBotHitLand01,
}

ALaserProjectile = Class(SingleBeamProjectile) {

    BeamName = '/effects/emitters/laserturret_munition_beam_02_emit.bp',

    FxImpactUnit = EffectTemplate.ALaserHitUnit01,
    FxImpactProp = EffectTemplate.ALaserHitUnit01,
    FxImpactLand = EffectTemplate.ALaserHitLand01,
}

AQuadLightLaserProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/aeon_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

    FxImpactUnit = EffectTemplate.ALightLaserHitUnit01,
    FxImpactProp = EffectTemplate.ALightLaserHitUnit01,
    FxImpactLand = EffectTemplate.ALightLaserHit01,
}

ALightLaserProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/aeon_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

    FxImpactUnit = EffectTemplate.ALightLaserHitUnit01,
    FxImpactProp = EffectTemplate.ALightLaserHitUnit01,
    FxImpactLand = EffectTemplate.ALightLaserHit01,

}

ASonicPulsarProjectile = Class(EmitterProjectile){
    FxTrails = EffectTemplate.ASonicPulsarMunition01,
}

AMiasmaProjectile = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.AMiasmaMunition01,
    FxImpactNone = EffectTemplate.AMiasma01,
}

AMiasmaProjectile02 = Class(EmitterProjectile) {

	FxTrails = EffectTemplate.AMiasmaMunition02,
	FxImpactLand = EffectTemplate.AMiasmaField01,
    FxImpactUnit = EffectTemplate.AMiasmaField01,
    FxImpactProp = EffectTemplate.AMiasmaField01,
}

AMissileAAProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/aeon_missile_trail_01_emit.bp',

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactAirUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactNone = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
}

AZealot02AAMissileProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/aeon_missile_trail_03_emit.bp',

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactAirUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactNone = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
}

AAALightDisplacementAutocannonMissileProjectile = Class(MultiPolyTrailProjectile) {

    FxImpactUnit = EffectTemplate.ALightDisplacementAutocannonMissileHit,
    FxImpactAirUnit = EffectTemplate.ALightDisplacementAutocannonMissileHitUnit,
    FxImpactProp = EffectTemplate.ALightDisplacementAutocannonMissileHit,
    FxImpactNone = EffectTemplate.ALightDisplacementAutocannonMissileHit,
    FxImpactLand = EffectTemplate.ALightDisplacementAutocannonMissileHit,
    PolyTrails = EffectTemplate.ALightDisplacementAutocannonMissilePolyTrails,
}

AGuidedMissileProjectile = Class(SinglePolyTrailProjectile) {

    FxTrails =  EffectTemplate.AMercyGuidedMissileFxTrails,
	PolyTrail = EffectTemplate.AMercyGuidedMissilePolyTrail,

    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactNone = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
}

AMissileCruiseSubProjectile = Class(EmitterProjectile) {

    FxInitialAtEntityEmitter = {},
    FxUnderWaterTrail = {'/effects/emitters/missile_cruise_munition_underwater_trail_01_emit.bp',},
    FxOnEntityEmitter = {},
    FxExitWaterEmitter = EffectTemplate.DefaultProjectileWaterImpact,
    FxSplashScale = 0.65,
    ExitWaterTicks = 9,
    FxTrailOffset = -0.5,

    FxLaunchTrails = {},

    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
	
    OnCreate = function(self)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0 )
        
        SinglePolyTrailProjectile.OnCreate(self)
    end,
}

AMissileSerpentineProjectile = Class(SingleCompositeEmitterProjectile) {

    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    
    PolyTrailOffset = -0.05,

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
	
    OnCreate = function(self)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0 )
        
        SingleCompositeEmitterProjectile.OnCreate(self)
    end,
}

AMissileSerpentine02Projectile = Class(SingleCompositeEmitterProjectile) {

    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    
    PolyTrailOffset = -0.05,

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
	
    OnCreate = function(self)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0 )
        
        SingleCompositeEmitterProjectile.OnCreate(self)
    end,
}

AOblivionCannonProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/oblivion_cannon_munition_01_emit.bp'},
    FxImpactUnit = EffectTemplate.AOblivionCannonHit01,
    FxImpactProp = EffectTemplate.AOblivionCannonHit01,
    FxImpactLand = EffectTemplate.AOblivionCannonHit01,
    FxImpactWater = EffectTemplate.AOblivionCannonHit01,
}

AOblivionCannonProjectile02 = Class(SinglePolyTrailProjectile) {

	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.AOblivionCannonFXTrails02,
    PolyTrail = EffectTemplate.Aeon_QuanticClusterProjectilePolyTrail,
    FxImpactUnit = EffectTemplate.AOblivionCannonHit02,
    FxImpactProp = EffectTemplate.AOblivionCannonHit02,
    FxImpactLand = EffectTemplate.AOblivionCannonHit02,
    FxImpactWater = EffectTemplate.AOblivionCannonHit02,
}

AQuantumCannonProjectile = Class(SinglePolyTrailProjectile) {

    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_03_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    PolyTrail = '/effects/emitters/quantum_cannon_polytrail_01_emit.bp',
    FxImpactUnit = EffectTemplate.AQuantumCannonHit01,
    FxImpactProp = EffectTemplate.AQuantumCannonHit01,
    FxImpactLand = EffectTemplate.AQuantumCannonHit01,
}

AQuantumDisruptorProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxTrails = EffectTemplate.AQuantumDisruptor01,
    
    FxImpactUnit = EffectTemplate.AQuantumDisruptorHit01,
    FxImpactProp = EffectTemplate.AQuantumDisruptorHit01,
    FxImpactLand = EffectTemplate.AQuantumDisruptorHit01,
}

AAAQuantumDisplacementCannonProjectile = Class(NullShell) {

    PolyTrail = '/effects/emitters/quantum_displacement_cannon_polytrail_01_emit.bp',

    FxImpactUnit = EffectTemplate.AQuantumDisplacementHit01,
    FxImpactProp = EffectTemplate.AQuantumDisplacementHit01,
    FxImpactAirUnit = EffectTemplate.AQuantumDisplacementHit01,
    FxImpactLand = EffectTemplate.AQuantumDisplacementHit01,
    FxImpactNone = EffectTemplate.AQuantumDisplacementHit01,

    FxTeleport = EffectTemplate.AQuantumDisplacementTeleport01,
    FxInvisible = '/effects/emitters/sparks_08_emit.bp',

    OnCreate = function(self)
        NullShell.OnCreate(self)

        self.TrailEmitters = {}

        self.CreateTrailFX(self, self.Army)
        self:ForkThread(self.UpdateThread, self.Army)
    end,

    CreateTrailFX = function(self, army)
		
        if (self.PolyTrail) then
            LOUDINSERT( self.TrailEmitters, CreateTrail(self, -1, army, self.PolyTrail ))
        end
        
        if not self.FxTrails then
            self.FxTrails = {}
        end
        
        for i in self.FxTrails do
            LOUDINSERT( self.TrailEmitters, CreateEmitterOnEntity(self, army, self.FxTrails[i]))
        end
    end,

    CreateTeleportFX = function(self, army)
	
        for i in self.FxTeleport do
            CreateEmitterAtEntity(self, army, self.FxTeleport[i])
        end
        
    end,

    DestroyTrailFX = function(self)
        if self.TrailEmitters then
            for k,v in self.TrailEmitters do
                v:Destroy()
                v = nil
            end
        end
    end,

    UpdateThread = function(self,army)

        WaitTicks(3)
        
        self.DestroyTrailFX(self)
        self.CreateTeleportFX(self, army)
		
        local emit = CreateEmitterOnEntity(self, army, self.FxInvisible)
		
        WaitTicks(45)
        
        emit:Destroy()
        self.CreateTeleportFX(self,army)
        self.CreateTrailFX(self,army)
    end,
}

AQuantumWarheadProjectile = Class(MultiCompositeEmitterProjectile) {

    Beams = {'/effects/emitters/aeon_nuke_exhaust_beam_01_emit.bp',},
    PolyTrails = {'/effects/emitters/aeon_nuke_trail_emit.bp',},

}

AQuarkBombProjectile = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.AQuarkBomb01,
    FxTrailScale = 1,

    FxImpactUnit = EffectTemplate.AQuarkBombHitUnit01,
    FxImpactProp = EffectTemplate.AQuarkBombHitUnit01,
    FxImpactAirUnit = EffectTemplate.AQuarkBombHitAirUnit01,
    FxImpactLand = EffectTemplate.AQuarkBombHitLand01,

    OnImpact = function(self, targetType, targetEntity)
    
        CreateLightParticle( self, -1, self.Army, 26, 6, 'sparkle_white_add_08', 'ramp_white_02' )

        if targetType == 'Terrain' or targetType == 'Prop' then
        
            local pos = self:GetPosition()
            
            CreateScorchMarkSplat( self, 3 )
            
            self.DamageData.DamageAmount = self.DamageData.DamageAmount - 10
            
            DamageRing( self, pos, 0.1, self.DamageData.DamageRadius, 10, 'Fire', false, false )
            DamageArea( self, pos, self.DamageData.DamageRadius - 1, 1, 'Force', true )
            DamageArea( self, pos, self.DamageData.DamageRadius - 1, 1, 'Force', true )            
        end        

        EmitterProjectile.OnImpact( self, targetType, targetEntity )
    end,
}

ARailGunProjectile = Class(EmitterProjectile) {

    FxTrails = {'/effects/emitters/railgun_munition_trail_02_emit.bp',
        '/effects/emitters/railgun_munition_trail_01_emit.bp'},
    FxTrailScale = 0,

}

AReactonCannonProjectile = Class(EmitterProjectile) {

    FxTrails = {
        '/effects/emitters/reacton_cannon_fxtrail_01_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_02_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_03_emit.bp',
    },

    FxImpactUnit = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactProp = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactLand = EffectTemplate.AReactonCannonHitLand01,
}

AReactonCannonAOEProjectile = Class(EmitterProjectile) {

    FxTrails = {
        '/effects/emitters/reacton_cannon_fxtrail_01_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_02_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_03_emit.bp',
    },

    FxImpactUnit = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactProp = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactLand = EffectTemplate.AReactonCannonHitLand02,
}

ADisruptorProjectile = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxTrails = EffectTemplate.ADisruptorMunition01,

    FxImpactUnit = EffectTemplate.ADisruptorHit01,
    FxImpactProp = EffectTemplate.ADisruptorHit01,
    FxImpactLand = EffectTemplate.ADisruptorHit01,
    FxImpactShield = EffectTemplate.ADisruptorHitShield,
}

AShieldDisruptorProjectile = Class(SinglePolyTrailProjectile) {

	PolyTrail = EffectTemplate.ASDisruptorPolytrail01,
    FxTrails = EffectTemplate.ASDisruptorMunition01,

    FxImpactUnit = EffectTemplate.ASDisruptorHitUnit01,
    FxImpactProp = EffectTemplate.ASDisruptorHitUnit01,
    FxImpactLand = EffectTemplate.ASDisruptorHit01,
    FxImpactShield = EffectTemplate.ASDisruptorHitShield,
}

ARocketProjectile = Class(EmitterProjectile) {

    FxInitial = {},
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_cybran_01_emit.bp',},
    FxTrailOffset = 0.5,

    FxImpactUnit = EffectTemplate.AMissileHit01,
    FxImpactProp = EffectTemplate.AMissileHit01,
    FxImpactLand = EffectTemplate.AMissileHit01,
}

ASonicPulseProjectile = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/sonic_pulse_munition_polytrail_01_emit.bp',

    FxImpactAirUnit = EffectTemplate.ASonicPulseHitAirUnit01,
    FxImpactUnit = EffectTemplate.ASonicPulseHitUnit01,
    FxImpactProp = EffectTemplate.ASonicPulseHitUnit01,
    FxImpactLand = EffectTemplate.ASonicPulseHitLand01,
}

-- Custom version of the sonic pulse battery projectile for flying units
ASonicPulseProjectile02 = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/sonic_pulse_munition_polytrail_02_emit.bp',

    FxImpactAirUnit = EffectTemplate.ASonicPulseHitAirUnit01,
    FxImpactUnit = EffectTemplate.ASonicPulseHitUnit01,
    FxImpactProp = EffectTemplate.ASonicPulseHitUnit01,
    FxImpactLand = EffectTemplate.ASonicPulseHitLand01,
}

ATemporalFizzAAProjectile = Class(SingleCompositeEmitterProjectile) {

    BeamName = '/effects/emitters/temporal_fizz_munition_beam_01_emit.bp',
    PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxImpactUnit = EffectTemplate.ATemporalFizzHit01,
    FxImpactAirUnit = EffectTemplate.ATemporalFizzHit01,
    FxImpactNone = EffectTemplate.ATemporalFizzHit01,
}

ATorpedoShipProjectile = Class(OnWaterEntryEmitterProjectile) {

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
		
        -- if we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(true)
            self:OnEnterWater(self)
        else
            self:TrackTarget(false)
        end
    end,
    
    OnEnterWater = function(self)
    
        OnWaterEntryEmitterProjectile.OnEnterWater(self)
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0 )
    end,    
}

ATorpedoSubProjectile = Class(OnWaterEntryEmitterProjectile) {

    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},

    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,

    FxNoneHitScale = 1,
	
    OnCreate = function(self, inWater)
	
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0 )
        
        EmitterProjectile.OnCreate(self, inWater)
		
    end,
}

QuasarAntiTorpedoChargeSubProjectile = Class(MultiPolyTrailProjectile) {

    FxImpactLand = EffectTemplate.AQuasarAntiTorpedoHit,
    FxUnitHitScale = 1.25,
    FxImpactUnit = EffectTemplate.AQuasarAntiTorpedoHit,
    FxImpactProp = EffectTemplate.AQuasarAntiTorpedoHit,
    FxImpactUnderWater = EffectTemplate.AQuasarAntiTorpedoHit,
    FxImpactProjectileUnderWater = EffectTemplate.AQuasarAntiTorpedoHit,
    FxNoneHitScale = 1,
    FxImpactNone = EffectTemplate.AQuasarAntiTorpedoHit,
    PolyTrails= EffectTemplate.AQuasarAntiTorpedoPolyTrails,
}

ABaseTempProjectile = Class(SinglePolyTrailProjectile) {

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

AQuantumAutogun = Class(SinglePolyTrailProjectile) {

	FxImpactLand = EffectTemplate.Aeon_DualQuantumAutoGunHitLand,
    FxImpactNone = EffectTemplate.Aeon_DualQuantumAutoGunHit,
    FxImpactProp = EffectTemplate.Aeon_DualQuantumAutoGunHit_Unit,  
    FxImpactWater = EffectTemplate.Aeon_DualQuantumAutoGunHitLand,   
    FxImpactUnit = EffectTemplate.Aeon_DualQuantumAutoGunHit_Unit,    
    
    PolyTrail = EffectTemplate.Aeon_DualQuantumAutoGunProjectileTrail, 
    FxTrails = EffectTemplate.Aeon_DualQuantumAutoGunFxTrail,
}

AHeavyDisruptorCannonShell = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.Aeon_HeavyDisruptorCannonLandHit,
    FxImpactNone = EffectTemplate.Aeon_HeavyDisruptorCannonLandHit,
	FxImpactProp = EffectTemplate.Aeon_HeavyDisruptorCannonLandHit,    
    FxImpactUnit = EffectTemplate.Aeon_HeavyDisruptorCannonUnitHit,    

    FxTrails = EffectTemplate.Aeon_HeavyDisruptorCannonProjectileFxTrails,
    PolyTrails = EffectTemplate.Aeon_HeavyDisruptorCannonProjectileTrails, 
}

ATorpedoCluster = Class(ATorpedoShipProjectile) {

    FxInitial = {},

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
}

AQuantumCluster = Class(ABaseTempProjectile) {}

ALightDisplacementAutoCannon = Class(ABaseTempProjectile) {}

AArtilleryFragmentationSensorShellProjectile = Class(SinglePolyTrailProjectile) {

    FxTrails = EffectTemplate.Aeon_QuanticClusterProjectileTrails,
    PolyTrail = EffectTemplate.Aeon_QuanticClusterProjectilePolyTrail,
    FxImpactLand = EffectTemplate.Aeon_QuanticClusterHit,
    FxLandHitScale = 0.5,
}

AArtilleryFragmentationSensorShellProjectile02 = Class(AArtilleryFragmentationSensorShellProjectile) {

	FxTrails = EffectTemplate.Aeon_QuanticClusterProjectileTrails02,
    PolyTrail = EffectTemplate.Aeon_QuanticClusterProjectilePolyTrail02,
}

AArtilleryFragmentationSensorShellProjectile03 = Class(AArtilleryFragmentationSensorShellProjectile) {

    PolyTrail = EffectTemplate.Aeon_QuanticClusterProjectilePolyTrail03,
}