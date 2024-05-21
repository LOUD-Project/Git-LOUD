---  /lua/seraphimprojectiles.lua

local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local MultiPolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile 
local SinglePolyTrailProjectile = import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile

--local OnWaterEntryEmitterProjectile = import('/lua/sim/defaultprojectiles.lua').OnWaterEntryEmitterProjectile
--local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile

local EmitterProjectileOnCreate             = EmitterProjectile.OnCreate 
local MultiPolyTrailProjectileOnCreate      = MultiPolyTrailProjectile.OnCreate
local SinglePolyTrailProjectileOnCreate     = SinglePolyTrailProjectile.OnCreate
local SinglePolyTrailProjectileOnEnterWater = SinglePolyTrailProjectile.OnEnterWater

--local OnWaterEntryEmitterProjectileOnCreate     = OnWaterEntryEmitterProjectile.OnCreate
--local OnWaterEntryEmitterProjectileOnEnterWater = OnWaterEntryEmitterProjectile.OnEnterWater

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateTrail = CreateTrail
local Random = Random
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn

local SetCollisionShape = moho.entity_methods.SetCollisionShape
local StayUnderwater    = moho.projectile_methods.StayUnderwater
local TrackTarget       = moho.projectile_methods.TrackTarget

local TrashBag          = TrashBag
local TrashAdd          = TrashBag.Add
local TrashDestroy      = TrashBag.Destroy

local WaitTicks         = coroutine.yield

local function GetRandomInt( nmin, nmax)
    return LOUDFLOOR(Random() * (nmax - nmin + 1) + nmin)
end

local RandomInt = GetRandomInt
local SetCollisionShape = moho.entity_methods.SetCollisionShape

SIFHuAntiNuke = Class(SinglePolyTrailProjectile) {

    PolyTrail = EffectTemplate.SKhuAntiNukePolyTrail,
    FxTrails = EffectTemplate.SKhuAntiNukeFxTrails,

    FxImpactProjectile = EffectTemplate.SKhuAntiNukeHit,
}

SIFKhuAntiNukeTendril = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.SKhuAntiNukeHitTendrilFxTrails,
}

SIFKhuAntiNukeSmallTendril = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.SKhuAntiNukeHitSmallTendrilFxTrails,
}

SBaseTempProjectile = Class(EmitterProjectile) {
    FxImpactLand = EffectTemplate.AMissileHit01,
    FxImpactNone = EffectTemplate.AMissileHit01,
    FxImpactProjectile = EffectTemplate.ASaintImpact01,
    FxImpactProp = EffectTemplate.AMissileHit01,    

    FxImpactUnit = EffectTemplate.AMissileHit01,    
    FxTrails = EffectTemplate.SShleoCannonProjectileTrails, 
}

SChronatronCannon = Class(MultiPolyTrailProjectile) {

    FxImpactLand = EffectTemplate.SChronotronCannonLandHit,
    FxImpactNone = EffectTemplate.SChronotronCannonHit,
    FxImpactProp = EffectTemplate.SChronotronCannonLandHit,    
    FxImpactUnit = EffectTemplate.SChronotronCannonUnitHit,
    FxImpactWater = EffectTemplate.SChronotronCannonLandHit,
    FxImpactUnderWater = EffectTemplate.SChronotronCannonHit,
    FxTrails = EffectTemplate.SChronotronCannonProjectileFxTrails,
    PolyTrails = EffectTemplate.SChronotronCannonProjectileTrails,
}

SChronatronCannonOverCharge = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.SChronotronCannonOverChargeLandHit,
    FxImpactNone = EffectTemplate.SChronotronCannonOverChargeLandHit,
    FxImpactProp = EffectTemplate.SChronotronCannonOverChargeLandHit,    
    FxImpactUnit = EffectTemplate.SChronotronCannonOverChargeUnitHit,
    FxTrails = EffectTemplate.SChronotronCannonOverChargeProjectileFxTrails,
    PolyTrails = EffectTemplate.SChronotronCannonOverChargeProjectileTrails,
}

SLightChronatronCannon = Class(MultiPolyTrailProjectile) {

    FxImpactLand = EffectTemplate.SLightChronotronCannonLandHit,
    FxImpactNone = EffectTemplate.SLightChronotronCannonLandHit,
    FxImpactProp = EffectTemplate.SLightChronotronCannonHit,    
    FxImpactUnit = EffectTemplate.SLightChronotronCannonUnitHit,
    PolyTrails = EffectTemplate.SLightChronotronCannonProjectileTrails,
    PolyTrailOffset = {0,0,0},
    FxTrails = EffectTemplate.SLightChronotronCannonProjectileFxTrails,
    FxImpactWater = EffectTemplate.SLightChronotronCannonLandHit,
    FxImpactUnderWater = EffectTemplate.SLightChronotronCannonHit,
}

SLightChronatronCannonOverCharge = Class(MultiPolyTrailProjectile) {

    FxImpactLand = EffectTemplate.SLightChronotronCannonOverChargeHit,
    FxImpactNone = EffectTemplate.SLightChronotronCannonOverChargeHit,
    FxImpactProp = EffectTemplate.SLightChronotronCannonOverChargeHit,    
    FxImpactUnit = EffectTemplate.SLightChronotronCannonOverChargeHit,
    PolyTrails = EffectTemplate.SLightChronotronCannonOverChargeProjectileTrails,
    FxTrails = EffectTemplate.SLightChronotronCannonOverChargeProjectileFxTrails,
}

SPhasicAutogun = Class(MultiPolyTrailProjectile) {
    FxImpactLand = EffectTemplate.PhasicAutoGunHit,
    FxImpactNone = EffectTemplate.PhasicAutoGunHit,
    FxImpactProp = EffectTemplate.PhasicAutoGunHitUnit,    
    FxImpactUnit = EffectTemplate.PhasicAutoGunHitUnit,
    PolyTrails = EffectTemplate.PhasicAutoGunProjectileTrail,
}

SHeavyPhasicAutogun = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.HeavyPhasicAutoGunHit,
    FxImpactNone = EffectTemplate.HeavyPhasicAutoGunHit,
    FxImpactProp = EffectTemplate.HeavyPhasicAutoGunHitUnit,    
    FxImpactUnit = EffectTemplate.HeavyPhasicAutoGunHitUnit,
    FxImpactWater = EffectTemplate.HeavyPhasicAutoGunHit,
    FxImpactUnderWater = EffectTemplate.HeavyPhasicAutoGunHitUnit,
    PolyTrails = EffectTemplate.HeavyPhasicAutoGunProjectileTrail,
    FxTrails = EffectTemplate.HeavyPhasicAutoGunProjectileTrailGlow,
}

---Adjustment for XSA0203 projectile speed.
SHeavyPhasicAutogun02 = Class(SHeavyPhasicAutogun) {
    PolyTrails = EffectTemplate.HeavyPhasicAutoGunProjectileTrail02,
    FxTrails = EffectTemplate.HeavyPhasicAutoGunProjectileTrailGlow02,
}

SOhCannon = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.OhCannonHit,
    FxImpactNone = EffectTemplate.OhCannonHit,
    FxImpactProp = EffectTemplate.OhCannonHitUnit,    
    FxImpactUnit = EffectTemplate.OhCannonHitUnit,

    PolyTrails = EffectTemplate.OhCannonProjectileTrail,
}

SOhCannon02 = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.OhCannonHit,
    FxImpactNone = EffectTemplate.OhCannonHit,
    FxImpactProp = EffectTemplate.OhCannonHitUnit,    
    FxImpactUnit = EffectTemplate.OhCannonHitUnit,

    PolyTrails = EffectTemplate.OhCannonProjectileTrail02,
}

SShriekerAutoCannon = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.ShriekerCannonHit,
    FxImpactNone = EffectTemplate.ShriekerCannonHit,
    FxImpactProp = EffectTemplate.ShriekerCannonHit,    
    FxImpactUnit = EffectTemplate.ShriekerCannonHitUnit,
    PolyTrails = EffectTemplate.ShriekerCannonPolyTrail,
    FxImpactWater = EffectTemplate.ShriekerCannonHit,
    FxImpactUnderWater = EffectTemplate.ShriekerCannonHit,
}

SAireauBolter = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.SAireauBolterHit,
    FxImpactNone = EffectTemplate.SAireauBolterHit,
    FxImpactProp = EffectTemplate.SAireauBolterHit,    
    FxImpactUnit = EffectTemplate.SAireauBolterHit,
    FxTrails = EffectTemplate.SAireauBolterProjectileFxTrails,

    PolyTrails = EffectTemplate.SAireauBolterProjectilePolyTrails,    
}

STauCannon = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.STauCannonHit,
    FxImpactNone = EffectTemplate.STauCannonHit,
    FxImpactProp = EffectTemplate.STauCannonHit,    
    FxImpactUnit = EffectTemplate.STauCannonHit,
    FxTrails = EffectTemplate.STauCannonProjectileTrails,

    PolyTrails = EffectTemplate.STauCannonProjectilePolyTrails,
}

SHeavyQuarnonCannon = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.SHeavyQuarnonCannonLandHit,
    FxImpactNone = EffectTemplate.SHeavyQuarnonCannonHit,
    FxImpactProp = EffectTemplate.SHeavyQuarnonCannonHit,    
    FxImpactUnit = EffectTemplate.SHeavyQuarnonCannonUnitHit,
    PolyTrails = EffectTemplate.SHeavyQuarnonCannonProjectilePolyTrails,

    FxTrails = EffectTemplate.SHeavyQuarnonCannonProjectileFxTrails,
    FxImpactWater = EffectTemplate.SHeavyQuarnonCannonWaterHit,
}

SLaanseTacticalMissile = Class(SinglePolyTrailProjectile) {
    FxImpactLand = EffectTemplate.SLaanseMissleHit,
    FxImpactProp = EffectTemplate.SLaanseMissleHitUnit,

    FxImpactUnit = EffectTemplate.SLaanseMissleHitUnit,    
    FxTrails = EffectTemplate.SLaanseMissleExhaust02,
    PolyTrail = EffectTemplate.SLaanseMissleExhaust01,

    OnCreate = function(self)

        SinglePolyTrailProjectileOnCreate(self)
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
    end,
}

SZthuthaamArtilleryShell = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.SZthuthaamArtilleryHit,
	FxImpactWater = EffectTemplate.SZthuthaamArtilleryHit,
    FxImpactNone = EffectTemplate.SZthuthaamArtilleryHit,
    FxImpactProp = EffectTemplate.SZthuthaamArtilleryHit,    
    FxImpactUnit = EffectTemplate.SZthuthaamArtilleryUnitHit,    
    FxTrails = EffectTemplate.SZthuthaamArtilleryProjectileFXTrails,
    PolyTrails = EffectTemplate.SZthuthaamArtilleryProjectilePolyTrails, 
}

SSuthanusArtilleryShell = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
	FxImpactLand = EffectTemplate.SRifterArtilleryHit,
	FxImpactWater = EffectTemplate.SRifterArtilleryWaterHit,
    FxImpactNone = EffectTemplate.SRifterArtilleryHit,

    FxImpactProp = EffectTemplate.SRifterArtilleryHit,    
    FxImpactUnderWater = EffectTemplate.SRifterArtilleryWaterHit,
    FxImpactUnit = EffectTemplate.SRifterArtilleryHit,    
    FxTrails = EffectTemplate.SRifterArtilleryProjectileFxTrails,
    PolyTrail = EffectTemplate.SRifterArtilleryProjectilePolyTrail,
}

SSuthanusMobileArtilleryShell = Class(SinglePolyTrailProjectile) {
	-- This will make ist so that the projectile effects are the in the space of the world 
	FxImpactLand = EffectTemplate.SRifterMobileArtilleryHit,
	FxImpactWater = EffectTemplate.SRifterMobileArtilleryWaterHit,
    FxImpactNone = EffectTemplate.SRifterMobileArtilleryHit,
    FxImpactProp = EffectTemplate.SRifterMobileArtilleryHit,    
    FxImpactUnderWater = EffectTemplate.SRifterMobileArtilleryWaterHit,
    FxImpactUnit = EffectTemplate.SRifterMobileArtilleryHit,    
    FxTrails = EffectTemplate.SRifterMobileArtilleryProjectileFxTrails,
    PolyTrail = EffectTemplate.SRifterArtilleryProjectilePolyTrail,
}

SThunthoArtilleryShell = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.SThunderStormCannonHit,
    FxImpactNone = EffectTemplate.SThunderStormCannonHit,
    FxImpactProp = EffectTemplate.SThunderStormCannonHit,    
    FxImpactUnit = EffectTemplate.SThunderStormCannonHit,    
    FxTrails = EffectTemplate.SThunderStormCannonProjectileTrails,
    PolyTrails = EffectTemplate.SThunderStormCannonProjectilePolyTrails,
}


SThunthoArtilleryShell2 = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.SThunderStormCannonLandHit,
	FxImpactWater= EffectTemplate.SThunderStormCannonLandHit,
    FxImpactNone = EffectTemplate.SThunderStormCannonHit,
    FxImpactProp = EffectTemplate.SThunderStormCannonHit,    
    FxImpactUnit = EffectTemplate.SThunderStormCannonUnitHit,    

    PolyTrails = EffectTemplate.SThunderStormCannonProjectilePolyTrails,
}

SShleoAACannon = Class(EmitterProjectile) {
    FxImpactAirUnit = EffectTemplate.SShleoCannonUnitHit,
    FxImpactLand = EffectTemplate.SShleoCannonLandHit,
    FxImpactWater = EffectTemplate.SShleoCannonLandHit,
    FxImpactNone = EffectTemplate.SShleoCannonHit,
    FxImpactProp = EffectTemplate.SShleoCannonHit,    
    FxImpactUnit = EffectTemplate.SShleoCannonUnitHit,    

    PolyTrails = EffectTemplate.SShleoCannonProjectilePolyTrails,
    
    OnCreate = function(self)

        EmitterProjectileOnCreate(self)
		
        local PolytrailGroup = self.PolyTrails[RandomInt(1, LOUDGETN( self.PolyTrails ))]

        for k, v in PolytrailGroup do
            CreateTrail(self, -1, self.Army, v )
        end
    end,    
}

SOlarisAAArtillery = Class(MultiPolyTrailProjectile) {
    FxImpactAirUnit = EffectTemplate.SOlarisCannonHit,
	FxImpactLand = EffectTemplate.SOlarisCannonHit,
    FxImpactNone = EffectTemplate.SOlarisCannonHit,
    FxImpactProp = EffectTemplate.SOlarisCannonHit,    
    FxImpactUnit = EffectTemplate.SOlarisCannonHit,
    FxTrails = EffectTemplate.SOlarisCannonTrails,
    PolyTrails = EffectTemplate.SOlarisCannonProjectilePolyTrail,

}

SLosaareAAAutoCannon = Class(MultiPolyTrailProjectile) {

	FxImpactLand = EffectTemplate.SLosaareAutoCannonHit,
    FxImpactNone= EffectTemplate.SLosaareAutoCannonHit,
    FxImpactProp = EffectTemplate.SLosaareAutoCannonHit,    
    FxImpactAirUnit = EffectTemplate.SLosaareAutoCannonHit,
    PolyTrails = EffectTemplate.SLosaareAutoCannonProjectileTrail,

}

SLosaareAAAutoCannon02 = Class(SLosaareAAAutoCannon) {

    PolyTrails = EffectTemplate.SLosaareAutoCannonProjectileTrail02,

}

SOtheTacticalBomb= Class(SinglePolyTrailProjectile) {
	FxImpactLand =			EffectTemplate.SOtheBombHit,
    FxImpactNone =			EffectTemplate.SOtheBombHit,

    FxImpactProp =			EffectTemplate.SOtheBombHitUnit,    
    FxImpactUnderWater =	EffectTemplate.SOtheBombHit,
    FxImpactUnit =			EffectTemplate.SOtheBombHitUnit,    
    FxTrails =				EffectTemplate.SOtheBombFxTrails,
    PolyTrail =				EffectTemplate.SOtheBombPolyTrail,
}

SAnaitTorpedo = Class(MultiPolyTrailProjectile) {
    FxImpactUnderWater =	EffectTemplate.SAnaitTorpedoHit,
    FxUnderWaterHitScale =	1,
    FxImpactUnit =			EffectTemplate.SAnaitTorpedoHit,    
    FxImpactNone =			EffectTemplate.SAnaitTorpedoHit,
    FxTrails =				EffectTemplate.SAnaitTorpedoFxTrails,
    PolyTrails =			EffectTemplate.SAnaitTorpedoPolyTrails,
    
    OnCreate = function(self, inWater)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        MultiPolyTrailProjectileOnCreate(self, inWater)
    end,
}

SHeavyCavitationTorpedo = Class(MultiPolyTrailProjectile) {

	FxImpactLand =			EffectTemplate.SHeavyCavitationTorpedoHit,
    FxImpactUnit =			EffectTemplate.SHeavyCavitationTorpedoHit,    

    FxTrails =				EffectTemplate.SUallTorpedoFxTrails,
    PolyTrails =			EffectTemplate.SHeavyCavitationTorpedoPolyTrails,

    OnCreate = function(self, inWater)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        MultiPolyTrailProjectileOnCreate(self, inWater)
    end,
}

SUallCavitationTorpedo = Class(SinglePolyTrailProjectile) {

    FxImpactUnderWater =	EffectTemplate.SUallTorpedoHit,

    FxUnderWaterHitScale =	1,

    FxTrails =				EffectTemplate.SUallTorpedoFxTrails,
    PolyTrail =				EffectTemplate.SUallTorpedoPolyTrail,
    
    OnCreate = function(self, inWater)
    
        if not inWater then
        
            self:TrackTarget(false)
        
        end
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 1.0)
        
        SinglePolyTrailProjectileOnCreate(self, inWater)
    end,
    
    OnEnterWater = function(self)

        self:ForkThread(self.EngageTracking)
        
        SinglePolyTrailProjectileOnEnterWater(self)
    end,
    
    EngageTracking = function(self)
    
        WaitTicks(2)
        
        self:TrackTarget(true)
    end,

}

SIFInainoStrategicMissile = Class(EmitterProjectile) {

	ExitWaterTicks = 9,
	FxExitWaterEmitter = EffectTemplate.DefaultProjectileWaterImpact,
    FxInitialAtEntityEmitter = {},

    FxLaunchTrails = {},
    FxOnEntityEmitter = {},
    FxSplashScale = 0.65,
    FxTrailOffset = -0.5,
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    FxUnderWaterTrail = {'/effects/emitters/missile_cruise_munition_underwater_trail_01_emit.bp',},
}

SExperimentalStrategicMissile = Class(MultiPolyTrailProjectile) {

	ExitWaterTicks = 9,
	FxExitWaterEmitter = EffectTemplate.DefaultProjectileWaterImpact,
    FxInitialAtEntityEmitter = {},

    FxLaunchTrails = {},
    FxOnEntityEmitter = {},
    FxSplashScale = 0.65,
    FxTrails = EffectTemplate.SIFExperimentalStrategicMissileFXTrails,
    PolyTrails = EffectTemplate.SIFExperimentalStrategicMissilePolyTrails,

    FxUnderWaterTrail = {'/effects/emitters/missile_cruise_munition_underwater_trail_01_emit.bp',},
}

SIMAntiMissile01 = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.SElectrumMissleDefenseHit,
    FxImpactNone= EffectTemplate.SElectrumMissleDefenseHit,
    FxImpactProjectile = EffectTemplate.SElectrumMissleDefenseHit,
    FxImpactProp = EffectTemplate.SElectrumMissleDefenseHit,    
    FxImpactUnit = EffectTemplate.SElectrumMissleDefenseHit,
    PolyTrails = EffectTemplate.SElectrumMissleDefenseProjectilePolyTrail,
}

SExperimentalStrategicBomb = Class(SBaseTempProjectile) {}

SIFNukeWaveTendril = Class(EmitterProjectile) {}

SIFNukeSpiralTendril = Class(EmitterProjectile) {}

SEnergyLaser = Class(SBaseTempProjectile) {}

SZhanaseeBombProjectile = Class(EmitterProjectile) {
    FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SZhanaseeBombFxTrails01,
	FxImpactUnit = EffectTemplate.SZhanaseeBombHit01,
    FxImpactProp = EffectTemplate.SZhanaseeBombHit01,
    FxImpactAirUnit = EffectTemplate.SZhanaseeBombHit01,
    FxImpactLand = EffectTemplate.SZhanaseeBombHit01,
}

SAAHotheFlareProjectile = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,

    FxImpactNone = EffectTemplate.AAntiMissileFlareHit,
    FxImpactProjectile = EffectTemplate.AAntiMissileFlareHit,
    FxOnKilled = EffectTemplate.AAntiMissileFlareHit,
    FxUnitHitScale = 0.4,
    FxLandHitScale = 0.4,
    FxWaterHitScale = 0.4,
    FxUnderWaterHitScale = 0.4,
    FxAirUnitHitScale = 0.4,
    FxNoneHitScale = 0.4,

    -- We only destroy when we hit the ground/water.
    OnImpact = function(self, TargetType, targetEntity)
        if type == 'Terrain' or type == 'Water' then
			EmitterProjectile.OnImpact(self, TargetType, targetEntity)
			if TargetType == 'Terrain' or TargetType == 'Water' or TargetType == 'Prop' then
				if self.Trash then
					self.Trash:Destroy()
				end
				self:Destroy()
			end
		end
    end,
}

SOhwalliStrategicBombProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.SOhwalliBombFxTrails01,
    PolyTrails = EffectTemplate.SOhwalliBombPolyTrails, 
}

SAnjelluTorpedoDefenseProjectile = Class(SinglePolyTrailProjectile) {

    FxImpactUnderWater =	EffectTemplate.SUallTorpedoHit,

    FxUnderWaterHitScale =	0.5,

    FxTrails =	false,  --			EffectTemplate.SUallTorpedoFxTrails,
    PolyTrail = 			EffectTemplate.SUallTorpedoPolyTrail,
    
    OnCreate = function(self, inWater)
    
        SetCollisionShape( self, 'Sphere', 0, 0, 0, 0.7)
        
        SinglePolyTrailProjectileOnCreate(self, inWater)
    end,

}

SDFSniperShotNormal = Class(MultiPolyTrailProjectile) {
    FxImpactLand = EffectTemplate.SDFSniperShotNormalHit,
    FxImpactNone = EffectTemplate.SDFSniperShotNormalHit,

    FxImpactProp = EffectTemplate.SDFSniperShotNormalHitUnit,    

    FxImpactUnit = EffectTemplate.SDFSniperShotNormalHitUnit,    

    PolyTrails = EffectTemplate.SDFSniperShotNormalPolytrail,    
}

SDFSniperShot = Class(MultiPolyTrailProjectile) {
    FxImpactLand = EffectTemplate.SDFSniperShotHit,
    FxImpactNone = EffectTemplate.SDFSniperShotHit,

    FxImpactProp = EffectTemplate.SDFSniperShotHitUnit,    

    FxImpactUnit = EffectTemplate.SDFSniperShotHitUnit,    
    FxTrails = EffectTemplate.SDFSniperShotTrails,
    PolyTrails = EffectTemplate.SDFSniperShotPolytrail,  
}

SDFExperimentalPhasonProjectile = Class(EmitterProjectile) {

    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = EffectTemplate.SDFExperimentalPhasonProjHitUnit,
    FxImpactProp = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactLand = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactWater = EffectTemplate.SDFExperimentalPhasonProjHit01,
}

SDFSinnuntheWeaponProjectile = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.SDFSinnutheWeaponFXTrails01,
    FxImpactUnit = EffectTemplate.SDFSinnutheWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFSinnutheWeaponHit,
    FxImpactLand = EffectTemplate.SDFSinnutheWeaponHit,
    FxImpactWater = EffectTemplate.SDFSinnutheWeaponHit,
}

SDFAireauProjectile = Class(MultiPolyTrailProjectile) {
    FxImpactNone = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactUnit = EffectTemplate.SDFAireauWeaponHitUnit,
    FxImpactProp = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactLand = EffectTemplate.SDFAireauWeaponHit01,
    FxImpactWater= EffectTemplate.SDFAireauWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = EffectTemplate.SDFAireauWeaponPolytrails01,
}
