--**  File     : /cdimage/lua/modules/BlackOpsprojectiles.lua
--**  Author(s): Lt_Hawkeye
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

------------------------------------
--  Lt_hawkeye's Custom Projectiles
------------------------------------
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
local NullShell = DefaultProjectileFile.NullShell

local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local util = import('/lua/utilities.lua')

local LOUDCOS = math.cos
local LOUDDECAL = CreateDecal
local LOUDFLOOR = math.floor
local LOUDPI = math.pi
local LOUDSIN = math.sin
local LOUDTRAIL = CreateTrail
local ForkThread = ForkThread

local CreateEmitterOnEntity = CreateEmitterOnEntity
local CreateBeamEmitterOnEntity = CreateBeamEmitterOnEntity

---------------
-- Null Shell
---------------
EXNullShell = Class(Projectile) {}

-----------------------------------------------------------------
-- PROJECTILE WITH ATTACHED EFFECT EMITTERS
-----------------------------------------------------------------
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

-----------------------------------------------------------------
-- BEAM PROJECTILES
-----------------------------------------------------------------
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

-----------------------------------------------------------------
-- POLY-TRAIL PROJECTILES
-----------------------------------------------------------------
EXSinglePolyTrailProjectile = Class(EXEmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',
    PolyTrailOffset = 0,
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrail != '' then
            LOUDTRAIL(self, -1, self:GetArmy(), self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
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


-----------------------------------------------------------------
-- COMPOSITE EMITTER PROJECTILES - MULTIPURPOSE PROJECTILES
-- - THAT COMBINES BEAMS, POLYTRAILS, AND NORMAL EMITTERS
-----------------------------------------------------------------

-- LIGHTWEIGHT VERSION THAT LIMITS USE TO 1 BEAM, 1 POLYTRAIL, AND STANDARD EMITTERS
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

-- HEAVYWEIGHT VERSION, ALLOWS FOR MULTIPLE BEAMS, POLYTRAILS, AND STANDARD EMITTERS
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

RailGun01Projectile = Class(MultiPolyTrailProjectile) {
	FxImpactWater = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactLand = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactNone = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactProp = BlackOpsEffectTemplate.RailGunCannonUnitHit,    
    FxImpactUnit = BlackOpsEffectTemplate.RailGunCannonUnitHit,   
	
    FxTrails = BlackOpsEffectTemplate.RailGunFxTrails,
    PolyTrails = BlackOpsEffectTemplate.RailGunPolyTrails,
    FxImpactProjectile = {},
    FxImpactUnderWater = {},
   
}

MiniRocketPRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactUnderWater = {},

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}
MiniRocket03PRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -0.25,
    
    BeamName = '/mods/BlackOpsUnleashed/effects/emitters/missile_munition_exhaust_beam_02_emit.bp',
    

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactUnderWater = {},

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}
MiniRocket04PRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    
    BeamName = '/mods/BlackOpsUnleashed/effects/emitters/missile_munition_exhaust_beam_03_emit.bp',
	
	OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}
MiniRocket02Projectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = 0,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    # Hit Effects
    FxImpactUnit = EffectTemplate.CMissileLOAHit01,
    FxImpactLand = EffectTemplate.CMissileLOAHit01,
    FxImpactProp = EffectTemplate.CMissileLOAHit01,
    FxImpactNone = EffectTemplate.CMissileLOAHit01,
    FxImpactUnderWater = {},
    
    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
    
    OnExitWater = function(self)
		EmitterProjectile.OnExitWater(self)
		local army = self:GetArmy()
		for k, v in self.FxExitWaterEmitter do
			CreateEmitterAtBone(self,-2,army,v)
		end
    end,
}

--***********************************************
--                 SeaDragon Projectiles
--***********************************************

SeaDragonShell = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    -- Hit Effects
    FxImpactUnit = EffectTemplate.CMolecularResonanceHitUnit01,
    FxUnitHitScale = 1.4,
    FxImpactProp = EffectTemplate.CMolecularResonanceHitUnit01,
    FxPropHitScale = 1.4,    
    FxImpactLand = EffectTemplate.CMolecularResonanceHitUnit01,
    FxLandHitScale = 1.4,
    FxImpactUnderWater = {},
	
    DestroyOnImpact = false,

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        self.Impacted = false
    end,

    DelayedDestroyThread = function(self)
        WaitSeconds( 0.3 )
        self.CreateImpactEffects( self, self:GetArmy(), self.FxImpactUnit, self.FxUnitHitScale )
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

XCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        BlackOpsEffectTemplate.XCannonPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },
    PolyTrailOffset = {0,0}, 

    FxTrails = BlackOpsEffectTemplate.XCannonFXTrail01,

    FxImpactUnit = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactProp = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactLand = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,
    FxTrailOffset = 0,
    FxLandHitScale = 0.8,
    FxPropHitScale = 0.8,
    FxUnitHitScale = 0.8,
    FxUnderWaterHitScale = 0.8,
    FxWaterHitScale = 0.8,
}
--------------------------------------------------------------
--				Bismark Projectiles
-------------------------------------------------------------
ZCannon01Projectile = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.ZCannonPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.ZCannonFxtrail01,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactLand = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.ZCannonHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
    FxSplatScale = 9,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        if targetType == 'Terrain' then
            LOUDDECAL( self:GetPosition(), util.GetRandomFloat(0,2*LOUDPI), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 50, army )
            LOUDDECAL( self:GetPosition(), util.GetRandomFloat(0,2*LOUDPI), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 50, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

--------------------------------------------------------------------------
--  Cybran Dumb MISSILE PROJECTILES
--------------------------------------------------------------------------
DumbRocketProjectile = Class(SingleBeamProjectile) {
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    #FxTrailScale = 1,
--	PolyTrail = EffectTemplate.CCorsairMissilePolyTrail01,    
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    #BeamScale = 0.25,
    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}

DumbRocketProjectile02 = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}
--------------------------------------------------------------------------
--
--  Scorp Laser
--
--------------------------------------------------------------------------

ScorpPulseLaser = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        EffectTemplate.CHvyProtonCannonPolyTrail,
        '/effects/emitters/electron_bolter_trail_01_emit.bp',
        #'/effects/emitters/default_polytrail_01_emit.bp',
    },
    PolyTrailScale = 0.5,
    PolyTrailOffset = {0,0}, 

    #FxTrails = EffectTemplate.CHvyProtonCannonFXTrail01,
    #PolyTrail = EffectTemplate.CHvyProtonCannonPolyTrail,
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
    FxTrailOffset = 0,
}
--------------------------------------------------------------------------
--  AEON MIRV MISSILE PROJECTILES
--------------------------------------------------------------------------
MIRVChild01Projectile = Class(SingleCompositeEmitterProjectile) {
    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxImpactProp = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxImpactLand = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxUnitHitScale = 1,
    FxImpactUnderWater = {},
    
    
}
--------------------------------------------------------------
--				Aira Projectiles
-------------------------------------------------------------
SonicWaveProjectile = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.WaveCannonPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.WaveCannonFxtrail01,

    # Hit Effects
    FxImpactUnit = EffectTemplate.AGravitonBolterHit01,
    FxImpactProp = EffectTemplate.AGravitonBolterHit01,
    FxImpactLand = EffectTemplate.AGravitonBolterHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},

}
--------------------------------------------------------------
--				Seraphim Lambda Projectiles
-------------------------------------------------------------
EyeBlast01Projectile = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactShield = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactLand = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactWater = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
}

--------------------------------------------------------------
--				Seraphim LPD Projectiles
-------------------------------------------------------------
SeraHeavyLightningCannonChildProjectile = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactLand = EffectTemplate.SHeavyQuarnonCannonLandHit,
    FxImpactNone = EffectTemplate.SHeavyQuarnonCannonHit,
    FxImpactProp = EffectTemplate.SHeavyQuarnonCannonHit,    
    FxImpactUnit = EffectTemplate.SHeavyQuarnonCannonUnitHit,
    FxOnKilled = EffectTemplate.SHeavyQuarnonCannonUnitHit,
}

--------------------------------------------------------------------------
--  CYBRAN SUB LAUNCHED TORPEDO
--------------------------------------------------------------------------
AssaultTorpedoSubProjectile = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/torpedo_underwater_wake_02_emit.bp',},

    # Hit Effects
    FxImpactUnit = EffectTemplate.CTorpedoUnitHit01,
    FxImpactProp = EffectTemplate.CTorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.CTorpedoUnitHit01,    
    FxImpactLand = EffectTemplate.CTorpedoUnitHit01,
    FxLandHitScale = 4,
    FxPropHitScale = 4,
    FxUnitHitScale = 4,
    FxNoneHitScale = 4,
    FxImpactNone = {},
}

ShadowCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		--'/mods/BlackOpsUnleashed/effects/emitters/shadow_bolter_trail_01_emit.bp',
		'/mods/BlackOpsUnleashed/effects/emitters/shadowcannon_polytrail_01_emit.bp',
	},
    PolyTrailOffset = {0,0}, 

    FxTrails = BlackOpsEffectTemplate.ShadowCannonFXTrail01,
	FxTrailScale = 0.5,
    #PolyTrail = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactUnit = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    FxTrailOffset = 0,
}

HellFireMissileProjectile = Class(SingleCompositeEmitterProjectile) {
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    FxTrailScale = 0.25,
--	PolyTrail = EffectTemplate.CCorsairMissilePolyTrail01,    
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
    FxImpactUnderWater = {},
}

ACUShadowCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
		'/effects/emitters/electron_bolter_trail_01_emit.bp',
		'/mods/BlackOpsUnleashed/effects/emitters/shadowcannon_polytrail_01_emit.bp',
	},
    PolyTrailOffset = {0,0}, 

    FxTrails = BlackOpsEffectTemplate.ShadowCannonFXTrail01,
    #PolyTrail = EffectTemplate.CHvyProtonCannonPolyTrail,
    FxImpactUnit = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactLand = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactUnderWater = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    FxTrailOffset = 0,
}

--------------------------------------------------------------------------
--  TERRAN Heavy GAUSS CANNON PROJECTILES
--------------------------------------------------------------------------
HawkGaussCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

--------------------------------------------------------------------------
--  AEON ARTILLERY PROJECTILES
--------------------------------------------------------------------------
WraithProjectile = Class(SinglePolyTrailProjectile) {
	FxImpactLand = BlackOpsEffectTemplate.WraithCannonHit01,
    FxImpactNone = BlackOpsEffectTemplate.WraithCannonHit01,
	FxImpactProp = BlackOpsEffectTemplate.WraithCannonHit01,    
    FxImpactUnit = BlackOpsEffectTemplate.WraithCannonHit01,    
    FxImpactUnderWater = {},
    FxImpactProjectile = {},
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    PolyTrail = BlackOpsEffectTemplate.WraithPolytrail01,
    FxTrails = BlackOpsEffectTemplate.WraithMunition01,
}


--------------------------------------------------------------------------
--
--  Fire test
--
--------------------------------------------------------------------------

Juggfire01 = Class(MultiPolyTrailProjectile) {
	PolyTrails = BlackOpsEffectTemplate.HGaussCannonPolyTrail,
    FxTrails = {
		'/mods/BlackOpsUnleashed/effects/emitters/Juggfire01_emit.bp',
		'/effects/emitters/napalm_hvy_thin_smoke_emit.bp',
--		'/effects/emitters/napalm_hvy_thick_smoke_emit.bp',
--		'/effects/emitters/napalm_hvy_03_emit.bp',
	},
	PolyTrailOffset = {0,0,0},    

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxImpactUnderWater = {},
--    FxTrails = {},
    FxTrailOffset = 0,
}

--------------------------------------------------------------------------
--  Flamethrower Projectile
--------------------------------------------------------------------------
NapalmProjectile01 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsUnleashed/Effects/Emitters/NapalmTrailFX.bp',},
    
    FxImpactTrajectoryAligned = false,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxImpactUnderWater = {},
}
NapalmProjectile02 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsUnleashed/Effects/Emitters/NapalmTrailFX.bp',},
   	FxTrailScale = 0.5,
    
    FxImpactTrajectoryAligned = false,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxNoneHitScale = 0.5,
}

--------------------------------------------------------------------------
--  AEON ABOVE WATER LAUNCHED TORPEDO
--------------------------------------------------------------------------
AMTorpedoShipProjectile = Class(OnWaterEntryEmitterProjectile) {
    FxInitial = {},
    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    TrailDelay = 0,
    TrackTime = 0,

    FxUnitHitScale = 1.25,
    FxImpactLand = {},
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactProjectile = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxKilled = EffectTemplate.ATorpedoUnitHit01,
    FxImpactNone = {},

    OnCreate = function(self,inWater)
        OnWaterEntryEmitterProjectile.OnCreate(self,inWater)
        # if we are starting in the water then immediately switch to tracking in water
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
--    FxTrails = {'/effects/emitters/serpentine_missile_trail_emit.bp',},
    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    FxTrailScale = 1,
    TrailDelay = 0,
    TrackTime = 0,

    FxUnitHitScale = 1.25,
    FxImpactLand = {},
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.ATorpedoUnitHitUnderWater01,
    FxImpactProjectile = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.ATorpedoUnitHitUnderWater01,
    FxKilled = EffectTemplate.ATorpedoUnitHit01,
    FxImpactNone = {},
    
     OnCreate = function(self,inWater)
        SingleCompositeEmitterProjectile.OnCreate(self,inWater)
        # if we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(false)
            self:OnEnterWater(self)
        else
            self:TrackTarget(true)
        end
    end, 
}




--------------------------------------------------------------------------
--  AEON GUIDED AA PROJECTILES
--------------------------------------------------------------------------
GoldAAProjectile = Class(SinglePolyTrailProjectile) {
    FxTrails =  BlackOpsEffectTemplate.GoldAAFxTrails,
	PolyTrail = BlackOpsEffectTemplate.GoldAAPolyTrail,  ###'/effects/emitters/aeon_missile_trail_02_emit.bp',    

    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactAirUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactNone = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxImpactUnderWater = {},
}
--------------------------------------------------------------------------
--  SERAPHIM TAU CANNON
--------------------------------------------------------------------------
ShieldTauCannonProjectile = Class(MultiPolyTrailProjectile) {
	FxImpactLand = EffectTemplate.STauCannonHit,
    FxImpactNone = EffectTemplate.STauCannonHit,
    FxImpactProp = EffectTemplate.STauCannonHit,    
    FxImpactUnit = EffectTemplate.STauCannonHit,
    FxImpactShield = EffectTemplate.ADisruptorHitShield,
    FxTrails = EffectTemplate.STauCannonProjectileTrails,
    PolyTrailOffset = {0,0},    
    PolyTrails = EffectTemplate.STauCannonProjectilePolyTrails,
}

SOmegaCannonOverCharge = Class(MultiPolyTrailProjectile) {
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
    PolyTrailOffset = {0,0,0},
}
------------------------------------------------------------------------
--  SERAPHIM LAANSE TACTICAL MISSILE
--------------------------------------------------------------------------
SLaanseTacticalMissile = Class(SinglePolyTrailProjectile) {
    FxImpactLand = EffectTemplate.SLaanseMissleHit,
    FxImpactProp = EffectTemplate.SLaanseMissleHitUnit,
    FxImpactUnderWater = {},
    FxImpactUnit = EffectTemplate.SLaanseMissleHitUnit,    
    FxTrails = EffectTemplate.SLaanseMissleExhaust02,
    PolyTrail = EffectTemplate.SLaanseMissleExhaust01,


}
--------------------------------------------------------------------------
--  MGAI PROJECTILES
--------------------------------------------------------------------------
MGHeadshotProjectile = Class(MultiPolyTrailProjectile) {
	FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.MGHeadshotPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.MGHeadshotFxtrail01,

    # Hit Effects
	FxImpactLand = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactNone = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactProp = BlackOpsEffectTemplate.MGHeadshotHit01,    
    FxImpactUnit = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}

MGQAIRocketProjectile = Class(SingleBeamProjectile) {
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
    FxImpactUnderWater = {},

    
}

MGQAIRocketChildProjectile = Class(SingleCompositeEmitterProjectile) {
    PolyTrail = '/mods/BlackOpsUnleashed/effects/emitters/mgqai_missile_trail_emit.bp',
    BeamName = '/mods/BlackOpsUnleashed/effects/emitters/mgqai_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.MissileUnitHit01,
    FxImpactProp = BlackOpsEffectTemplate.MissileLandHit01,
    FxImpactLand = BlackOpsEffectTemplate.MissileLandHit01,
	FxLandHitScale = 0.65,
    FxPropHitScale = 0.65,
    FxUnitHitScale = 0.65,
	FxNoneHitScale = 0.65,
    FxImpactUnderWater = {},

    
}

MGQAIPlasmaArtyChildProjectile = Class(EmitterProjectile) {
    #PolyTrail = BlackOpsEffectTemplate.MGQAIPlasmaArtyPolytrail01,
    FxTrails = BlackOpsEffectTemplate.MGQAIPlasmaArtyChildFxtrail01,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactUnderWater = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactUnderWater = {},
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
		EmitterProjectile.OnCreate(self, TargetType, TargetEntity)
	end,

}

MGQAIPlasmaArtyProjectile = Class(EmitterProjectile) {
    #PolyTrail = BlackOpsEffectTemplate.MGQAIPlasmaArtyPolytrail01,
    FxTrails = BlackOpsEffectTemplate.MGQAIPlasmaArtyFxtrail01,

    # Hit Effects
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},

    ChildProjectile = '/mods/BlackOpsUnleashed/projectiles/MGQAIPlasmaArtyChild01/MGQAIPlasmaArtyChild01_proj.bp',

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
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
            EmitterProjectile.OnImpact(self, TargetType, TargetEntity)
        end
    end,
    
    # Overiding Destruction
    OnImpactDestroy = function( self, TargetType, TargetEntity)
        self:ForkThread( self.DelayedDestroyThread )
    end,

    DelayedDestroyThread = function(self)
        WaitSeconds( 0.5 )
        self:Destroy()
    end,
}

MGQAILaserHeavyProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        '/effects/emitters/electron_bolter_trail_01_emit.bp',
		'/effects/emitters/default_polytrail_03_emit.bp',
	},
	PolyTrailOffset = {0,0}, 
	FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
	
    # Hit Effects
    FxImpactUnit = EffectTemplate.CLaserHitUnit01,
    FxImpactProp = EffectTemplate.CLaserHitUnit01,
    FxImpactLand = EffectTemplate.CLaserHitLand01,
    FxImpactUnderWater = {},
}


--------------------------------------------------------------------------
--  AEON RAIDER CANNON PROJECTILES
--------------------------------------------------------------------------
RaiderCannonProjectile = Class(SinglePolyTrailProjectile) {
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

TAAHeavyFragmentationProjectile = Class(SingleCompositeEmitterProjectile) {
    BeamName = '/effects/emitters/antiair_munition_beam_01_emit.bp',
    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
    PolyTrailOffset = 0,
    FxTrails = {'/effects/emitters/terran_flack_fxtrail_01_emit.bp'},
    FxImpactAirUnit = BlackOpsEffectTemplate.THeavyFragmentationShell01,
    FxImpactNone = BlackOpsEffectTemplate.THeavyFragmentationShell01,
    FxImpactUnderWater = {},
    FxAirHitScale = 1.5,
    FxNoneHitScale = 1.5,
}





--------------------------------------------------------------------------
--  UEF ACU Antimatter Cannon
--------------------------------------------------------------------------
UEFACUAntiMatterProjectile01 = Class(EXMultiCompositeEmitterProjectile ) {
    PolyTrails = BlackOpsEffectTemplate.ZCannonPolytrail02,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.ZCannonFxtrail02,
    
    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactProp = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactLand = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactWater = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactUnderWater = {},
	FxSplatScale = 8,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        #CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
        if targetType == 'Terrain' then
            LOUDDECAL( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army )
            LOUDDECAL( self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army )
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

--------------------------------------------------------------------------
--  AEON Disk TMD Projectile
--------------------------------------------------------------------------
DiskTMD01 = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_03_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    PolyTrail = '/effects/emitters/quantum_cannon_polytrail_01_emit.bp',

-- Hit Effects
    FxImpactLand = EffectTemplate.ATemporalFizzHit01,
    FxImpactNone= EffectTemplate.ATemporalFizzHit01,
    FxImpactProjectile = EffectTemplate.ATemporalFizzHit01,
    FxImpactProp = EffectTemplate.ATemporalFizzHit01,    
    FxImpactUnit = EffectTemplate.ATemporalFizzHit01,
    FxImpactUnderWater = {},

   
}

NovaStunProjectile = Class(NullShell) {
	FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.MGHeadshotPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.MGHeadshotFxtrail01,

    # Hit Effects
	FxImpactUnit = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.NovaCannonHitUnit,
    #FxLandHitScale = 1.5,
    #FxPropHitScale = 1.5,
    #FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()

        local blanketSides = 12
        local blanketAngle = (2*LOUDPI) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2

        for i = 0, (blanketSides-1) do
            local blanketX = LOUDSIN(i*blanketAngle)
            local blanketZ = LOUDCOS(i*blanketAngle)
            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
    
}

GLaserProjectile = Class(MultiPolyTrailProjectile) {

	FxTrails = BlackOpsEffectTemplate.GoldenTurboLaserShot01FXTrail,  
    PolyTrails = BlackOpsEffectTemplate.GoldenTurboLaserShot01,

    # Hit Effects
	#FxImpactUnit = BlackOpsEffectTemplate.NovaCannonHitUnit,
    #FxImpactProp = BlackOpsEffectTemplate.NovaCannonHitUnit,
    #FxImpactLand = BlackOpsEffectTemplate.NovaCannonHitUnit,
    #FxImpactUnderWater = BlackOpsEffectTemplate.NovaCannonHitUnit,
    #FxImpactWater = BlackOpsEffectTemplate.NovaCannonHitUnit,
    #FxLandHitScale = 1.5,
    #FxPropHitScale = 1.5,
    #FxUnitHitScale = 1.5,
    #FxImpactUnderWater = {},
    
}
--------------------------------------------------------------------------
--  Garg Weapons
--------------------------------------------------------------------------
RedTurbolaserProjectile = Class(MultiPolyTrailProjectile) {

	FxTrails = {},  
    PolyTrails = BlackOpsEffectTemplate.RedTurboLaser01,
	

    # Hit Effects
    FxImpactUnit = EffectTemplate.TLandGaussCannonHit01,
                        FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.TLandGaussCannonHit01,
                        FxPropHitScale = 2,
    FxImpactAirUnit = EffectTemplate.TLandGaussCannonHit01,
                    FxAirUnitHitScale = 2,
    FxImpactLand = EffectTemplate.TLandGaussCannonHit01,
                        FxLandHitScale = 2,
    FxImpactUnderWater = {},
}

GargEMPWarheadProjectile = Class(SingleBeamProjectile) {
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxTrailOffset = -0.5,

    # LAUNCH TRAILS
    FxLaunchTrails = {},

    # TRAILS
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},

    # Hit Effects
    
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
    FxImpactUnderWater = {},
    
    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()

        local blanketSides = 12
        local blanketAngle = (2*LOUDPI) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2
        CreateLightParticle( self, -1, -1, 80, 200, 'flare_lens_add_02', 'ramp_red_10' )

        for i = 0, (blanketSides-1) do
            local blanketX = LOUDSIN(i*blanketAngle)
            local blanketZ = LOUDCOS(i*blanketAngle)
            self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/EffectEMPAmbient01/EffectEMPAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
    
}



--------------------------------------------------------------------------
--  Cybran Hailfire Projectiles
--------------------------------------------------------------------------
CybranHailfire01ChildProjectile = Class(SinglePolyTrailProjectile) {
    --FxTrails = {},
    PolyTrail = '/effects/emitters/default_polytrail_05_emit.bp',
    FxTrails = BlackOpsEffectTemplate.CybranHailfire02FXTrails,
    FxTrailOffset = -0.3,
	FxTrailScale = 0.005,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,    
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,

    # No damage dealt by this child.
    --DoDamage = function(self, instigator, damageData, targetEntity)
    --end,
}

CybranHailfire02Projectile = Class(SinglePolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.CybranHailfire01FXTrails,
    --PolyTrail = '/effects/emitters/default_polytrail_05_emit.bp',
    FxTrailOffset = -0.3,
	FxTrailScale = 0.05,
    FxImpactTrajectoryAligned = false,

    PolyTrail = EffectTemplate.CNanoDartPolyTrail01,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,    
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,
}
CybranHailfire04Projectile = Class(SinglePolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.CybranHailfire03FXTrails,
    --PolyTrail = '/effects/emitters/default_polytrail_05_emit.bp',
    FxTrailOffset = -0.3,
	FxTrailScale = 0.05,
    FxImpactTrajectoryAligned = false,

    PolyTrail = EffectTemplate.CNanoDartPolyTrail01,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,    
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,
}

CybranHailfire03Projectile = Class(SinglePolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.CybranHailfire01FXTrails,
    --PolyTrail = '/effects/emitters/default_polytrail_05_emit.bp',
    FxTrailOffset = -0.3,
	FxTrailScale = 0.05,
    FxImpactTrajectoryAligned = false,

    PolyTrail = EffectTemplate.CNanoDartPolyTrail01,

    # Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,    
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2.2,
    FxUnitHitScale = 2.2,
    FxPropHitScale = 2.2,
    FxWaterHitScale = 2.2,
}

RapierNapalmShellProjectile = Class(SinglePolyTrailProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_07_emit.bp',

    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 0.8,
    FxUnitHitScale = 0.8,
    FxPropHitScale = 0.8,
    FxWaterHitScale = 0.8,	
}

GoliathTMDProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = BlackOpsEffectTemplate.GoliathTMD01,

    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactNone = EffectTemplate.FireCloudSml01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,
    FxImpactUnderWater = {},
    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.7,
}

CitadelHVM01Projectile = Class(EmitterProjectile) {
-- Emitter Values
    FxInitial = {},
    TrailDelay = 0.3,
    FxTrails = BlackOpsEffectTemplate.CitadelHVM01Trails,
    FxTrailOffset = -0.3,
	FxTrailScale = 4,

    FxAirUnitHitScale = 1,
    FxLandHitScale = 1,
    FxUnitHitScale = 1,
    FxPropHitScale = 1,
    FxImpactUnit = EffectTemplate.TMissileHit02,
    FxImpactAirUnit = EffectTemplate.TMissileHit02,
    FxImpactProp = EffectTemplate.TMissileHit02,    
    FxImpactLand = EffectTemplate.TMissileHit02,
    FxImpactUnderWater = {},
}
--UEFACUClusterMIssileProjectile02 = Class(EXEmitterProjectile) {
--    DestroyOnImpact = false,
--    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
--    FxTrailOffset = 0,
--	FxTrailScale = 4.5,

--    FxImpactUnit = EffectTemplate.TShipGaussCannonHitUnit02,
 --   FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
  --  FxImpactLand = EffectTemplate.TShipGaussCannonHit02,
--    FxImpactUnderWater = {},
--}