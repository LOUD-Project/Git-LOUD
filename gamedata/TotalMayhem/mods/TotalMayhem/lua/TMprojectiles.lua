local Projectile = import('/lua/sim/projectile.lua').Projectile
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile

local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile

local Explosion = import('/lua/defaultexplosions.lua')
local NullShell = DefaultProjectileFile.NullShell

local EffectTemplate = import('/lua/EffectTemplates.lua')

local DefaultExplosion = import('/lua/defaultexplosions.lua')


local TMEffectTemplate = import('/mods/TotalMayhem/lua/TMEffectTemplates.lua')



#----------------
# Null Shell
#----------------
EXNullShell = Class(Projectile) {}


#-------------------------------------
# 			AEON PROJECTILES
#-------------------------------------

#----------------
# Aeon NovaCat Blue laser
#----------------

AeonBROT3NCNlaserproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        '/mods/TotalMayhem/effects/emitters/novacat_bluelaser_emit.bp',
	},
	PolyTrailOffset = {0,0}, 

    # Hit Effects
    FxImpactUnit = EffectTemplate.CLaserHitUnit01,
    FxImpactProp = EffectTemplate.CLaserHitUnit01,
    FxImpactLand = EffectTemplate.CLaserHitLand01,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Super Heavy Point Defense
#----------------
AeonT3SHPDproj = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxPropHitScale = 2,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxLandHitScale = 2,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 NovaCat Quantum Charge
#----------------
AeonBROT3NCMproj = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_03_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    PolyTrail = '/effects/emitters/quantum_cannon_polytrail_01_emit.bp',
    FxImpactUnit = TMEffectTemplate.AeonQuantumChargeHit01,
    FxUnitHitScale = 1.2,
    FxImpactProp = TMEffectTemplate.AeonQuantumChargeHit01,
    FxPropHitScale = 1.2,
    FxImpactLand = TMEffectTemplate.AeonQuantumChargeHit01,
    FxLandHitScale = 1.2,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 NovaCat Rapid Pulsegun
#----------------
AeonBROT3NCMPproj = Class(SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Rocket Defense
#----------------
AeonBROT3PDROproj = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxUnitHitScale = 1.2,
    FxImpactProp = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxPropHitScale = 1.2,
    FxImpactLand = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxLandHitScale = 1.2,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 1 Experimental Quadrobot maingun
#----------------
AeonBROT1EXM1proj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/aeon_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.AeonT1EXM1MainHit01,
    FxUnitHitScale = 1.2,
    FxImpactProp = TMEffectTemplate.AeonT1EXM1MainHit01,
    FxPropHitScale = 1.2,
    FxImpactLand = TMEffectTemplate.AeonT1EXM1MainHit01,
    FxLandHitScale = 1.2,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Tank Hunter
#----------------
AeonBROT3THproj = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.AeonT3HeavyRocketHit01,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 1 Battle Tank Clawgun
#----------------
AeonBROT1BTCLAWproj = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/aeon_laser_trail_01_emit.bp',
    FxImpactUnit = TMEffectTemplate.AeonClawHit01,
    FxUnitHitScale = 0.35,
    FxImpactProp = TMEffectTemplate.AeonClawHit01,
    FxPropHitScale = 0.35,
    FxImpactLand = TMEffectTemplate.AeonClawHit01,
    FxLandHitScale = 0.35,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Heavy Clawgun
#----------------
AeonHvyClawproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/oblivion_cannon_munition_01_emit.bp'},
    FxImpactUnit = TMEffectTemplate.AeonHvyClawHit01,
    FxUnitHitScale = .65,
    FxImpactProp = TMEffectTemplate.AeonHvyClawHit01,
    FxPropHitScale = .65,
    FxImpactLand = TMEffectTemplate.AeonHvyClawHit01,
    FxLandHitScale = .65,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Anti-Air Missile
#----------------

AeonAAmissile01 = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .5,
    FxImpactUnit = {},
    FxImpactAirUnit = {},
    FxImpactNone = EffectTemplate.AAntiMissileFlareHit,
    FxImpactProjectile = EffectTemplate.AAntiMissileFlareHit,
    FxOnKilled = EffectTemplate.AAntiMissileFlareHit,
    FxUnitHitScale = 1.0,
    FxLandHitScale = 1.0,
    FxWaterHitScale = 1.0,
    FxUnderWaterHitScale = 1.0,
    FxAirUnitHitScale = 1.0,
    FxNoneHitScale = 1.0,
    FxImpactLand = {},
    FxImpactUnderWater = {},
    DestroyOnImpact = false,

    OnImpact = function(self, TargetType, targetEntity)
        EmitterProjectile.OnImpact(self, TargetType, targetEntity)
        if TargetType == 'Terrain' or TargetType == 'Water' or TargetType == 'Prop' then
            if self.Trash then
                self.Trash:Destroy()
            end
            self:Destroy()
        end
    end,
}

#----------------
# Aeon T1 Rocket PD
#----------------
AeonBROT1PDROproj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .5,
    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxUnitHitScale = .6,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxPropHitScale = .6,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxLandHitScale = .6,
    FxImpactUnderWater = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxImpactWater = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
}

#----------------
# Aeon T2 Medium Tank rockets
#----------------
AeonBROT2MTRLproj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .5,
    FxImpactUnit = EffectTemplate.ABombHit01,
    FxUnitHitScale = .6,
    FxImpactProp = EffectTemplate.ABombHit01,
    FxPropHitScale = .6,
    FxImpactLand = EffectTemplate.ABombHit01,
    FxLandHitScale = .6,
    FxImpactUnderWater = EffectTemplate.ABombHit01,
    FxImpactWater = EffectTemplate.ABombHit01,
}

#----------------
# Aeon Tech 2 Medium Tank main gun
#----------------
AeonBROT2MTproj = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/aeon_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	PolyTrailOffset = {0,0},

    # Hit Effects
    FxImpactUnit = EffectTemplate.ACommanderOverchargeHit01,
    FxImpactProp = EffectTemplate.ACommanderOverchargeHit01,
    FxImpactLand = EffectTemplate.ACommanderOverchargeHit01,
    FxUnitHitScale = 1,
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 1 Battle Tank main gun
#----------------
AeonBROT1BTproj = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
		'/effects/emitters/aeon_laser_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	PolyTrailOffset = {0,0},

    # Hit Effects
    FxImpactUnit = EffectTemplate.ADisruptorHit01,
    FxImpactProp = EffectTemplate.ADisruptorHit01,
    FxImpactLand = EffectTemplate.ADisruptorHit01,
    FxUnitHitScale = 1,
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Battle Tank main guns
#----------------
AeonBROT3BTproj = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxPropHitScale = 2,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxLandHitScale = 2,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Experimental Cougar main guns
#----------------
AeonBROT3COUGproj = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxTrails = EffectTemplate.ADisruptorMunition01,
    FxImpactUnit = TMEffectTemplate.AeonCougarMainGuns,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.AeonCougarMainGuns,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.AeonCougarMainGuns,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Experimental Enforcer main guns
#----------------
AeonBROT3SHBMproj = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.AIFBallisticMortarTrails01,
    FxTrailScale = 0.5,
    FxImpactUnit = TMEffectTemplate.AeonEnforcerMainGuns,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.AeonEnforcerMainGuns,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.AeonEnforcerMainGuns,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Heavy Tank main guns
#----------------
AeonBROT3HTproj = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 2 Heavy Armored Tank main guns
#----------------
AeonBROT2HTproj = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.TIonizedPlasmaGatlingCannonFxTrails,
    PolyTrails = {},
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 2 Missile Launcher
#----------------
AeonBROT2MLproj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .5,
    FxImpactUnit = EffectTemplate.ACommanderOverchargeHit01,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.ACommanderOverchargeHit01,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.ACommanderOverchargeHit01,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Rocket Battery
#----------------
AeonBROT3MLproj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.AAntiMissileFlare,
    FxTrailScale = .5,
    FxImpactUnit = TMEffectTemplate.AeonT3RocketHit01,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.AeonT3RocketHit01,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.AeonT3RocketHit01,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Aeon Tech 3 Heavy Assault Mech EMP burst
#----------------

AeonBROT3SHBMEMPproj = Class(SinglePolyTrailProjectile) {
    FxImpactUnit = TMEffectTemplate.AeonT3EMPburst,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.AeonT3EMPburst,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.AeonT3EMPburst,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}


#---------------------------------------
# 			CYBRAN PROJECTILES
#---------------------------------------

#----------------
# Cybran Tech 2 Battle Mech Rockets (T2 Hippo / Immortal)
#----------------
CybranBMRocketProjectile = Class(SingleCompositeEmitterProjectile) {
    FxTrails = {},
	PolyTrail = '/effects/emitters/cybran_iridium_missile_polytrail_01_emit.bp',    
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.CHvyDisintegratorHit02,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.CHvyDisintegratorHit02,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.CHvyDisintegratorHit02,
    FxLandHitScale = 1,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Cybran Tech 1 Battle Tank Rockets
#----------------
CybBRMT1BTRLproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},
	PolyTrailOffset = {0,0},  
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    FxImpactUnit = EffectTemplate.CMissileHit02a,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.CMissileHit02a,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.CMissileHit02a,
    FxLandHitScale = 1,
    FxImpactUnderWater = EffectTemplate.CMissileHit02a,
    FxImpactWater = EffectTemplate.CMissileHit02a,
    FxWaterHitScale = 1,
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech 1 Experimental LaserBot
#----------------

CybBRMT1EXM1proj = Class(SingleCompositeEmitterProjectile) {
    FxTrails = {},
	PolyTrail = '/effects/emitters/cybran_iridium_missile_polytrail_01_emit.bp',    
    BeamName = '/effects/emitters/rocket_iridium_exhaust_beam_01_emit.bp',
    FxImpactUnit = TMEffectTemplate.CLaserBotHit01,
    FxUnitHitScale = 1.3,
    FxImpactProp = TMEffectTemplate.CLaserBotHit01,
    FxPropHitScale = 1.3,
    FxImpactLand = TMEffectTemplate.CLaserBotHit01,
    FxLandHitScale = 1.3,
    FxImpactUnderWater = TMEffectTemplate.CLaserBotHit01,
    FxImpactWater = TMEffectTemplate.CLaserBotHit01,
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech T1 Improved PD
#----------------

CybBRMT2HVYproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},
	PolyTrailOffset = {0,0},  
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    
    FxImpactUnit = TMEffectTemplate.CybranT1BattleTankHit,
    FxUnitHitScale = 0.5,
    FxImpactProp = TMEffectTemplate.CybranT1BattleTankHit,
    FxPropHitScale = 0.5,
    FxImpactLand = TMEffectTemplate.CybranT1BattleTankHit,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = TMEffectTemplate.CybranT1BattleTankHit,
    FxImpactWater = TMEffectTemplate.CybranT1BattleTankHit,
    FxTrailOffset = 0,
}

#----------------
# NULLWEAPON
#----------------

CybNULLWEAPONproj = Class(NullShell) {
    # Hit Effects
    FxImpactUnit = {},
    FxImpactAirUnit = {},
    FxImpactProp = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},
}

#----------------
# Cybran Tech 2 Heavy Tank Cannon 2
#----------------

CybBRMT2HVY2proj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},
	PolyTrailOffset = {0,0},  
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
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech 3 Dervish / Battle Tank main gun
#----------------
CybBRMT3BTproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
			'/effects/emitters/electron_bolter_trail_02_emit.bp',
			'/effects/emitters/default_polytrail_01_emit.bp',
		},
		PolyTrailOffset = {0,0},  
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    
    FxImpactUnit = TMEffectTemplate.CybranT3BattleTankHit,
    FxUnitHitScale = 0.65,
    FxImpactProp = TMEffectTemplate.CybranT3BattleTankHit,
    FxPropHitScale = 0.65,
    FxImpactLand = TMEffectTemplate.CybranT3BattleTankHit,
    FxLandHitScale = 0.65,
    FxImpactUnderWater = TMEffectTemplate.CybranT3BattleTankHit,
    FxImpactWater = TMEffectTemplate.CybranT3BattleTankHit,
    FxTrailOffset = 0,
}

#----------------
# Cybran Experimental MadCat main gun
#----------------
CybMadCatMolecular = Class(MultiPolyTrailProjectile) {
    PolyTrail = '/effects/emitters/default_polytrail_03_emit.bp',
    FxTrails = EffectTemplate.CMolecularCannon01,
    FxImpactUnit = TMEffectTemplate.CybranT2BattleTankHit,
    FxUnitHitScale = 0.35,
    FxImpactProp = TMEffectTemplate.CybranT2BattleTankHit,
    FxPropHitScale = 0.35,
    FxImpactLand = TMEffectTemplate.CybranT2BattleTankHit,
    FxLandHitScale = 0.35,
    FxImpactUnderWater = TMEffectTemplate.CybranT2BattleTankHit,
    FxImpactWater = TMEffectTemplate.CybranT2BattleTankHit,
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech 3 Rockets ( Mastadon, Pavestone, Dervish, Vulture)
#----------------
CybranRocketproj = Class(MultiPolyTrailProjectile) {
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
		FxTrailOffset = 0,
}

#----------------
# Cybran Tech 3 Heavy Rockets (Rocket Battery / Avalance - RD / MadCat / MadBolo / Mayhem / Some other units i forgot)
#----------------
CybranHeavyRocketproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = TMEffectTemplate.CybranHeavyRocketTrail,
		PolyTrailOffset = TMEffectTemplate.CybranRocketHeavyTrailOffset,  
		FxTrails = TMEffectTemplate.CybranHeavyRocketFXTrail,
		FxTrailScale = 0.7,
    
    FxImpactUnit = TMEffectTemplate.CybranHeavyRocketHit,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.CybranHeavyRocketHit,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.CybranHeavyRocketHit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.CybranHeavyRocketHit,
    FxImpactWater = TMEffectTemplate.CybranHeavyRocketHit,
    FxWaterHitScale = 0.7,
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech 3 Point Defense Proton Gun
#----------------
CybBRMT3PDproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_02_emit.bp',
		'/effects/emitters/default_polytrail_01_emit.bp',
	},
	PolyTrailOffset = {0,0},  
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    
    FxImpactUnit = TMEffectTemplate.CybranHeavyProtonGunHit,
    FxUnitHitScale = 0.5,
    FxImpactProp = TMEffectTemplate.CybranHeavyProtonGunHit,
    FxPropHitScale = 0.5,
    FxImpactLand = TMEffectTemplate.CybranHeavyProtonGunHit,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = TMEffectTemplate.CybranHeavyProtonGunHit,
    FxImpactWater = TMEffectTemplate.CybranHeavyProtonGunHit,
    FxWaterHitScale = 0.5,
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech 3 Bombardment Ship
#----------------
CybBRMST3BOMproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        EffectTemplate.CHvyProtonCannonPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },
    PolyTrailOffset = {0,0}, 

    FxTrails = EffectTemplate.CHvyProtonCannonFXTrail01,
    
    FxImpactUnit = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxUnitHitScale = 2,
    FxImpactProp = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxPropHitScale = 2,
    FxImpactLand = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxLandHitScale = 2,
    FxImpactUnderWater = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxImpactWater = TMEffectTemplate.CYBRANHEAVYPROTONARTILLERYHIT01,
    FxWaterHitScale = 2,
    FxTrailOffset = 0,
}

#----------------
# Cybran Tech 3 Beetle Guns (Avalance)
#----------------
CybBRMT3AVAproj = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/disintegrator_polytrail_04_emit.bp',
		'/effects/emitters/disintegrator_polytrail_05_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	PolyTrailOffset = {0,0,0},  
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

#--------------------------------
# 			UEF PROJECTILES
#--------------------------------


#----------------
# UEF Tech 1 Battle Tank rockets
#----------------
UefBRNT1BTRLproj = Class(MultiPolyTrailProjectile) {
    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = -0.5,
    FxImpactUnit = EffectTemplate.TGaussCannonHitLand01,
    FxUnitHitScale = .5,
    FxImpactProp = EffectTemplate.TGaussCannonHitLand01,
    FxPropHitScale = .5,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
    FxLandHitScale = .5,
    FxImpactUnderWater = EffectTemplate.TGaussCannonHitLand01,
    FxImpactWater = EffectTemplate.TGaussCannonHitLand01,
    FxWaterHitScale = .5,
}

#----------------
# UEF Tech 3 Battle Tank main gun
#----------------
UefBRNT3BTproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UefT3BattletankHit,
    FxUnitHitScale = 1.0,
    FxImpactProp = TMEffectTemplate.UefT3BattletankHit,
    FxPropHitScale = 1.0,
    FxImpactLand = TMEffectTemplate.UefT3BattletankHit,
    FxLandHitScale = 1.0,
    FxImpactUnderWater = TMEffectTemplate.UefT3BattletankHit,
    FxImpactWater = TMEffectTemplate.UefT3BattletankHit,
}

#----------------
# UEF Tech 1 Battle Tank main gun
#----------------
UefBRNT1BTproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UefT1BattleTankHit,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.UefT1BattleTankHit,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.UefT1BattleTankHit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.UefT1BattleTankHit,
    FxImpactWater = TMEffectTemplate.UefT1BattleTankHit,
}

#----------------
# UEF Tech 2 Heavy Tank main gun
#----------------
UefBRNT2HTproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UefT2BattleTankHit,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UefT2BattleTankHit,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UefT2BattleTankHit,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UefT2BattleTankHit,
    FxImpactWater = TMEffectTemplate.UefT2BattleTankHit,
}

#----------------
# UEF Tech 1 Medium Tank main gun
#----------------
UefBRNT1MTproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UefT1MedTankHit,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.UefT1MedTankHit,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.UefT1MedTankHit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.UefT1MedTankHit,
    FxImpactWater = TMEffectTemplate.UefT1MedTankHit,
}

#----------------
# UEF Tech 3 Armored Battle Bot Main guns
#----------------
UefBRNT3ABBproj = Class(MultiPolyTrailProjectile) {
	FxImpactLand = TMEffectTemplate.UEFArmoredBattleBotHit,
    FxImpactNone = TMEffectTemplate.UEFArmoredBattleBotHit,
    FxImpactProp = TMEffectTemplate.UEFArmoredBattleBotHit,    
    FxImpactUnit = TMEffectTemplate.UEFArmoredBattleBotHit,
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxUnitHitScale = 1,
    FxTrails = TMEffectTemplate.UEFArmoredBattleBotTrails,
    PolyTrailOffset = {0,0},    
    PolyTrails = TMEffectTemplate.UEFArmoredBattleBotPolyTrails,
}

#----------------
# UEF experimental Blood Asp gun
#----------------
UefBRNT3BLASPproj = Class(SingleBeamProjectile) {
    BeamName = '/effects/emitters/laserturret_munition_beam_03_emit.bp',
    FxImpactUnit = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxImpactWater = TMEffectTemplate.UEFHighExplosiveShellHit01,
}

#----------------
# UEF Tech 3 Battle Tank rockets
#----------------
UefBRNT3BTRLproj = Class(MultiPolyTrailProjectile) {
    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = -0.0,
    FxImpactUnit = TMEffectTemplate.UefT3BattletankRocketHit,
    FxUnitHitScale = 0.7,
    FxImpactProp = TMEffectTemplate.UefT3BattletankRocketHit,
    FxPropHitScale = 0.7,
    FxImpactLand = TMEffectTemplate.UefT3BattletankRocketHit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = TMEffectTemplate.UefT3BattletankRocketHit,
    FxImpactWater = TMEffectTemplate.UefT3BattletankRocketHit,
}

#----------------
# UEF Tech 1 Experimental Assault Tank
#----------------
UefBRNT1EXM1proj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UEFHighExplosiveShellHit01,	
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UEFHighExplosiveShellHit01,
    FxImpactWater = TMEffectTemplate.UEFHighExplosiveShellHit01,
}

#----------------
# UEF Tech 3 Ultra Heavy Battle Mech Rockets
#----------------
UefBRNT3SHBMproj = Class(MultiPolyTrailProjectile) {
    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = -0.5,
    FxImpactUnit = TMEffectTemplate.UEFHighExplosiveShellHit02,
    FxUnitHitScale = 0.5,
    FxImpactProp = TMEffectTemplate.UEFHighExplosiveShellHit02,
    FxPropHitScale = 0.5,
    FxImpactLand = TMEffectTemplate.UEFHighExplosiveShellHit02,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = TMEffectTemplate.UEFHighExplosiveShellHit02,
    FxImpactWater = TMEffectTemplate.UEFHighExplosiveShellHit02,
}

#----------------
# UEF Tech 2 Experimental Point Defense
#----------------
UefBRNT2EPDproj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition,
    RandomPolyTrails = 1,
    PolyTrailOffset = {0,0,0},
    PolyTrails = EffectTemplate.TPlasmaCannonHeavyPolyTrails,
    FxImpactUnit = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UefT2EPDPlasmaHit01,
    FxImpactWater = TMEffectTemplate.UefT2EPDPlasmaHit01,
}

#----------------
# UEF Tech 3 Super Heavy Point Defense
#----------------
UefBRNT3SHPDproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UefT3SHPDGaussHit01,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UefT3SHPDGaussHit01,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UefT3SHPDGaussHit01,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UefT3SHPDGaussHit01,
    FxImpactWater = TMEffectTemplate.UefT3SHPDGaussHit01,
}

#----------------
# UEF Experimental Mobile Fortress Main Guns
#----------------
UefBRNT3MOBproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMEffectTemplate.UefMobileFortressGunhit,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UefMobileFortressGunhit,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UefMobileFortressGunhit,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UefMobileFortressGunhit,
    FxImpactWater = TMEffectTemplate.UefMobileFortressGunhit,
}

#----------------
# UEF Tech 2 Heavy Tank rockets
#----------------
UefBRNT2HTRLproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxUnitHitScale = 0.5,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxPropHitScale = 0.5,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = EffectTemplate.TShipGaussCannonHit02,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
}

#----------------
# UEF Tech 2 Medium Tank rockets
#----------------
UefBRNT2MTRLproj = Class(MultiPolyTrailProjectile) {
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

#----------------
# UEF Tech 3 Heavy Rockets (Rocket Battery)
#----------------
UefBRNT3MLproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = TMEffectTemplate.UEFHighExplosiveRocketHit,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UEFHighExplosiveRocketHit,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UEFHighExplosiveRocketHit,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UEFHighExplosiveRocketHit,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
}

#----------------
# UEF Tech 3 Rocket Defense
#----------------
UefBRNT3PDROproj = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = TMEffectTemplate.UEFHEAVYROCKET02,
    FxUnitHitScale = 1,
    FxImpactProp = TMEffectTemplate.UEFHEAVYROCKET02,
    FxPropHitScale = 1,
    FxImpactLand = TMEffectTemplate.UEFHEAVYROCKET02,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMEffectTemplate.UEFHEAVYROCKET02,
    FxImpactWater = TMEffectTemplate.UEFHEAVYROCKET02,
    FxWaterHitScale = 1,
}

#----------------
# UEF Tech 3 Battle Mech main gun
#----------------
UefBRNT3WKproj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.TPlasmaCannonHeavyMunition,
    RandomPolyTrails = 1,
    PolyTrailOffset = {0,0,0},
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

#----------------
# UEF Tech 3 Battle Mech rockets
#----------------
UefBRNT3WKRLproj = Class(MultiPolyTrailProjectile) {
    FxInitial = {},
    TrailDelay = 1,
    FxTrails = {'/effects/emitters/missile_sam_munition_trail_01_emit.bp',},
    FxTrailOffset = -0.5,
    FxImpactUnit = EffectTemplate.TShipGaussCannonHit02,
    FxUnitHitScale = 0.8,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
    FxPropHitScale = 0.7,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit02,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = EffectTemplate.TShipGaussCannonHit02,
    FxImpactWater = EffectTemplate.TShipGaussCannonHit02,
}



#----------------
#DEATH EXPLOSIONS
#----------------

#----------------
# Cybran Tech 3 Rocket Defense
#----------------
CybBRMT1Dproj = Class(NullShell) {
    FxImpactUnit = EffectTemplate.CMobileKamikazeBombExplosion,
    FxUnitHitScale = 1,
    FxImpactProp = EffectTemplate.CMobileKamikazeBombExplosion,
    FxPropHitScale = 1,
    FxImpactLand = EffectTemplate.CMobileKamikazeBombExplosion,
    FxLandHitScale = 1,
    FxImpactUnderWater = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactWater = EffectTemplate.CMobileKamikazeBombExplosion,
    FxWaterHitScale = 1,
    FxTrailOffset = 0,
}



