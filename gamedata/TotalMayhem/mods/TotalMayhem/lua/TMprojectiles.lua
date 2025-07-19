local Projectile = import('/lua/sim/projectile.lua').Projectile

local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')

local EmitterProjectile                 = DefaultProjectileFile.EmitterProjectile
local SingleBeamProjectile              = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile         = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile          = DefaultProjectileFile.MultiPolyTrailProjectile
local NullShell                         = DefaultProjectileFile.NullShell

local EffectTemplate = import('/lua/EffectTemplates.lua')

local TMEffectTemplate = import('/mods/TotalMayhem/lua/TMEffectTemplates.lua')

AeonBROT1BTproj         = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/aeon_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

    FxImpactUnit = EffectTemplate.ADisruptorHit01,
    FxImpactProp = EffectTemplate.ADisruptorHit01,
    FxImpactLand = EffectTemplate.ADisruptorHit01,
}

AeonBROT1PDROproj       = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .1,
    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxUnitHitScale = .4,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxPropHitScale = .4,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxLandHitScale = .3,

    FxImpactWater = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
}

AeonBROT2MTRLproj       = Class(MultiPolyTrailProjectile) {

    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .33,

    FxImpactUnit = EffectTemplate.ABombHit01,
    FxUnitHitScale = .3,
    FxImpactProp = EffectTemplate.ABombHit01,
    FxPropHitScale = .3,
    FxImpactLand = EffectTemplate.ABombHit01,
    FxLandHitScale = .3,
}

AeonBROT3BTproj         = Class(MultiPolyTrailProjectile) {

    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,

    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxPropHitScale = 2,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxLandHitScale = 2,
}

AeonBROT3HTproj         = Class(MultiPolyTrailProjectile) {

    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,

    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
}

AeonBROT3PDROproj       = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,

    FxImpactUnit = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxUnitHitScale = 0.8,
    FxImpactProp = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxPropHitScale = 0.8,
    FxImpactLand = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxLandHitScale = 0.8,
}

AeonBROT3SHBMproj       = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.AIFBallisticMortarTrails01,
    FxTrailScale = 0.5,
    FxImpactUnit = TMEffectTemplate.AeonEnforcerMainGuns,
    FxImpactProp = TMEffectTemplate.AeonEnforcerMainGuns,
    FxImpactLand = TMEffectTemplate.AeonEnforcerMainGuns,
}

AeonBROT3SHBMEMPproj    = Class(SinglePolyTrailProjectile) {
    FxImpactUnit = TMEffectTemplate.AeonT3EMPburst,
    FxImpactProp = TMEffectTemplate.AeonT3EMPburst,
    FxImpactLand = TMEffectTemplate.AeonT3EMPburst,
}

AeonT3SHPDproj          = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,

    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxPropHitScale = 2,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxLandHitScale = 2,
}


CybBRMST3BOMproj        = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        EffectTemplate.CHvyProtonCannonPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },

    FxTrails = EffectTemplate.CHvyProtonCannonFXTrail01,
    
    FxImpactUnit = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxUnitHitScale = 2,
    FxImpactProp = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxPropHitScale = 1.5,
    FxImpactLand = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxLandHitScale = 1.5,
    FxImpactWater = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxWaterHitScale = 1.5,
}

CybBRMT2HVYproj         = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},

    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    
    FxImpactUnit = TMEffectTemplate.CybranT1BattleTankHit,
    FxUnitHitScale = 0.5,
    FxImpactProp = TMEffectTemplate.CybranT1BattleTankHit,
    FxPropHitScale = 0.5,
    FxImpactLand = TMEffectTemplate.CybranT1BattleTankHit,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = TMEffectTemplate.CybranT1BattleTankHit,
    FxImpactWater = TMEffectTemplate.CybranT1BattleTankHit,
}

CybBRMT2HVY2proj        = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},

    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    
    FxImpactUnit = TMEffectTemplate.CybranT2BattleTankHit,
    FxUnitHitScale = 0.25,
    FxImpactProp = TMEffectTemplate.CybranT2BattleTankHit,
    FxPropHitScale = 0.25,
    FxImpactLand = TMEffectTemplate.CybranT2BattleTankHit,
    FxLandHitScale = 0.25,
    FxImpactUnderWater = TMEffectTemplate.CybranT2BattleTankHit,
    FxImpactWater = TMEffectTemplate.CybranT2BattleTankHit,
    FxWaterHitScale = 0.25,
}

CybBRMT3AVAproj         = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/disintegrator_polytrail_04_emit.bp',
		'/effects/emitters/disintegrator_polytrail_05_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},

	FxTrails = EffectTemplate.CDisintegratorFxTrails01,  
	
    FxImpactUnit = TMEffectTemplate.Beetleprojectilehit01,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.Beetleprojectilehit01,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.Beetleprojectilehit01,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.Beetleprojectilehit01,
    FxImpactWater = TMEffectTemplate.Beetleprojectilehit01,
}

CybBRMT3BTproj          = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
			'/effects/emitters/electron_bolter_trail_02_emit.bp',
			'/effects/emitters/default_polytrail_01_emit.bp',
		},

    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    
    FxImpactUnit = TMEffectTemplate.CybranT3BattleTankHit,
    FxUnitHitScale = 0.65,
    FxImpactProp = TMEffectTemplate.CybranT3BattleTankHit,
    FxPropHitScale = 0.65,
    FxImpactLand = TMEffectTemplate.CybranT3BattleTankHit,
    FxLandHitScale = 0.65,
    FxImpactUnderWater = TMEffectTemplate.CybranT3BattleTankHit,
    FxImpactWater = TMEffectTemplate.CybranT3BattleTankHit,
}

CybranHeavyRocketproj   = Class(MultiPolyTrailProjectile) {
    PolyTrails = TMEffectTemplate.CybranHeavyRocketTrail,
		PolyTrailOffset = TMEffectTemplate.CybranRocketHeavyTrailOffset,  
		FxTrails = TMEffectTemplate.CybranHeavyRocketFXTrail,
		FxTrailScale = 0.55,
    
    FxImpactUnit = TMEffectTemplate.CybranHeavyRocketHit,
    FxUnitHitScale = 0.55,
    FxImpactProp = TMEffectTemplate.CybranHeavyRocketHit,
    FxPropHitScale = 0.5,
    FxImpactLand = TMEffectTemplate.CybranHeavyRocketHit,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = TMEffectTemplate.CybranHeavyRocketHit,
    FxImpactWater = TMEffectTemplate.CybranHeavyRocketHit,
    FxWaterHitScale = 0.4,
}

CybranRocketproj        = Class(MultiPolyTrailProjectile) {
    PolyTrails = TMEffectTemplate.CybranRocketTrail,
    PolyTrailOffset = TMEffectTemplate.CybranRocketTrailOffset, 
    FxTrails = TMEffectTemplate.CybranRocketFXTrail,
		FxTrailScale = 0.3,
    
    FxImpactUnit = TMEffectTemplate.CybranRocketHit,
    FxUnitHitScale = 0.75,
    FxImpactProp = TMEffectTemplate.CybranRocketHit,
    FxPropHitScale = 0.75,
    FxImpactLand = TMEffectTemplate.CybranRocketHit,
    FxLandHitScale = 0.75,
    FxImpactUnderWater = TMEffectTemplate.CybranRocketHit,
    FxImpactWater = TMEffectTemplate.CybranRocketHit,
    FxWaterHitScale = 0.75,
}


UefBRNT1MTproj          = Class(MultiPolyTrailProjectile) {

    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,

    FxImpactUnit = TMEffectTemplate.UefT1MedTankHit,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.UefT1MedTankHit,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.UefT1MedTankHit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.UefT1MedTankHit,
    FxImpactWater = TMEffectTemplate.UefT1MedTankHit,
}

UefBRNT2EPDproj         = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition,
    RandomPolyTrails = 1,

    PolyTrails = EffectTemplate.TPlasmaCannonHeavyPolyTrails,
    FxImpactUnit = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxImpactProp = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxImpactLand = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxImpactUnderWater = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxImpactWater = TMEffectTemplate.UefT2EPDPlasmaHit01,
}

UefBRNT2MTRLproj        = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxUnitHitScale = 0.5,
    FxImpactProp = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxPropHitScale = 0.5,
    FxImpactLand = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
}

UefBRNT3ABBproj         = Class(MultiPolyTrailProjectile) {
	FxImpactLand = TMEffectTemplate.UEFArmoredBattleBotHit,
    FxImpactNone = TMEffectTemplate.UEFArmoredBattleBotHit,
    FxImpactProp = TMEffectTemplate.UEFArmoredBattleBotHit,    
    FxImpactUnit = TMEffectTemplate.UEFArmoredBattleBotHit,
    FxTrails = TMEffectTemplate.UEFArmoredBattleBotTrails,

    PolyTrails = TMEffectTemplate.UEFArmoredBattleBotPolyTrails,
}

UefBRNT3BLASPproj       = Class(SingleBeamProjectile) {
    BeamName = '/effects/emitters/laserturret_munition_beam_03_emit.bp',
    FxImpactUnit = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxImpactProp = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxImpactLand = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxImpactUnderWater = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxImpactWater = TMEffectTemplate.UEFHighExplosiveShellHit01,
}

UefBRNT3BTproj          = Class(MultiPolyTrailProjectile) {
    
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,

    FxImpactUnit = TMEffectTemplate.UefT3BattletankHit,
    FxImpactProp = TMEffectTemplate.UefT3BattletankHit,
    FxImpactLand = TMEffectTemplate.UefT3BattletankHit,
    FxImpactUnderWater = TMEffectTemplate.UefT3BattletankHit,
    FxImpactWater = TMEffectTemplate.UefT3BattletankHit,
}

UefBRNT3BTRLproj        = Class(MultiPolyTrailProjectile) {
    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},

    FxImpactUnit = TMEffectTemplate.UefT3BattletankRocketHit,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.UefT3BattletankRocketHit,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.UefT3BattletankRocketHit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.UefT3BattletankRocketHit,
    FxImpactWater = TMEffectTemplate.UefT3BattletankRocketHit,
}

UefBRNT3PDROproj        = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = TMEffectTemplate.UEFHEAVYROCKET02,
    FxImpactProp = TMEffectTemplate.UEFHEAVYROCKET02,
    FxImpactLand = TMEffectTemplate.UEFHEAVYROCKET02,
    FxImpactUnderWater = TMEffectTemplate.UEFHEAVYROCKET02,
    FxImpactWater = TMEffectTemplate.UEFHEAVYROCKET02,
}

UefBRNT3WKproj          = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition,
    RandomPolyTrails = 1,

    PolyTrails = EffectTemplate.TPlasmaCannonHeavyPolyTrails,
    FxImpactUnit = TMEffectTemplate.UEFHeavyMechHit01,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.UEFHeavyMechHit01,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.UEFHeavyMechHit01,
    FxLandHitScale = 0.6,
    FxImpactUnderWater = TMEffectTemplate.UEFHeavyMechHit01,
    FxImpactWater = TMEffectTemplate.UEFHeavyMechHit01,
    FxWaterHitScale = 0.5,
}
