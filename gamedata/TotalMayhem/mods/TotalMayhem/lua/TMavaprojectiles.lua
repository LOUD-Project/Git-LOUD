#****************************************************************************
#**
#**  File     : /cdimage/lua/modules/BlackOpsARprojectiles.lua
#**  Author(s): 
#**
#**  Summary  :
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
#------------------------------------------------------------------------
#					
#------------------------------------------------------------------------
local Projectile = import('/lua/sim/projectile.lua').Projectile
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local Explosion = import('/lua/defaultexplosions.lua')
local NullShell = DefaultProjectileFile.NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')
local DefaultExplosion = import('/lua/defaultexplosions.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local util = import('/lua/utilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local TMavaEffectTemplate = import('/mods/TotalMayhem/lua/TMavaEffectTemplates.lua')
local TMEffectTemplate = import('/mods/TotalMayhem/lua/TMEffectTemplates.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local util = import('/lua/utilities.lua')

#----------------
# Null Shell
#----------------
EXNullShell = Class(Projectile) {}


#----------------------------------------------------------------
# 		     PROJECTILES
#----------------------------------------------------------------


#----------------
# Aeon Prototype Pride Mass Destruction Projectile
#----------------
AeonBROAT3PRIDEproj = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/oblivion_cannon_munition_01_emit.bp'},
    FxImpactUnit = TMavaEffectTemplate.PrideHit01,
    FxUnitHitScale = 6.8,
    FxImpactProp = TMavaEffectTemplate.PrideHit01,
    FxPropHitScale = 6.8,
    FxImpactLand = TMavaEffectTemplate.PrideHit01,
    FxLandHitScale = 6.8,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_005_albedo', 45, 45, 850, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# Aeon Prototype Hades ShoulderCannon
#----------------
AeonBROT3HADES2proj = Class(EmitterProjectile) {

    FxImpactUnit = TMavaEffectTemplate.ValiantHit,
    FxUnitHitScale = 2.55,
    FxImpactProp = TMavaEffectTemplate.ValiantHit,
    FxPropHitScale = 2.55,
    FxImpactLand = TMavaEffectTemplate.ValiantHit,
    FxLandHitScale = 2.55,
    FxImpactUnderWater = TMavaEffectTemplate.ValiantHit,
    FxImpactWater = TMavaEffectTemplate.ValiantHit,
    FxWaterHitScale = 2.55,
    FxTrails = EffectTemplate.SZthuthaamArtilleryProjectileFXTrails,
    PolyTrails = EffectTemplate.SZthuthaamArtilleryProjectilePolyTrails, 
    PolyTrailOffset = {0,0},

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_002_albedo', 28, 28, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# Aeon Prototype Hades cannons
#----------------
AeonBROT3HADESproj = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/oblivion_cannon_munition_01_emit.bp'},
    FxImpactUnit = TMavaEffectTemplate.HadesHit01,
    FxUnitHitScale = 2.4,
    FxImpactProp = TMavaEffectTemplate.HadesHit01,
    FxPropHitScale = 2.4,
    FxImpactLand = TMavaEffectTemplate.HadesHit01,
    FxLandHitScale = 2.4,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_001_albedo', 6, 6, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# Aeon Prototype Flying Fortress Small Projectile
#----------------
AeonBROAT3PRIDESMALLproj = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/oblivion_cannon_munition_01_emit.bp'},
    FxImpactUnit = TMavaEffectTemplate.PrideSmallHit01,
    FxUnitHitScale = 2.4,
    FxImpactProp = TMavaEffectTemplate.PrideSmallHit01,
    FxPropHitScale = 2.4,
    FxImpactLand = TMavaEffectTemplate.PrideSmallHit01,
    FxLandHitScale = 2.4,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_001_albedo', 6, 6, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# Aeon Valiant bomb
#----------------
AeonBROAT3BOMBERproj = Class(EmitterProjectile) {

    FxImpactUnit = TMavaEffectTemplate.ValiantHit,
    FxUnitHitScale = 1.55,
    FxImpactProp = TMavaEffectTemplate.ValiantHit,
    FxPropHitScale = 1.55,
    FxImpactLand = TMavaEffectTemplate.ValiantHit,
    FxLandHitScale = 1.55,
    FxImpactUnderWater = TMavaEffectTemplate.ValiantHit,
    FxImpactWater = TMavaEffectTemplate.ValiantHit,
    FxWaterHitScale = 1.55,
    FxTrails = EffectTemplate.SZthuthaamArtilleryProjectileFXTrails,
    PolyTrails = EffectTemplate.SZthuthaamArtilleryProjectilePolyTrails, 
    PolyTrailOffset = {0,0},

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_002_albedo', 15, 15, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# Cybran Eagle-Eye bomb
#----------------
CybBRMAT2ADVBOMBERproj = Class(EmitterProjectile) {

    FxImpactUnit = TMavaEffectTemplate.AvalancheRocketHit,
    FxUnitHitScale = 0.45,
    FxImpactProp = TMavaEffectTemplate.AvalancheRocketHit,
    FxPropHitScale = 0.45,
    FxImpactLand = TMavaEffectTemplate.AvalancheRocketHit,
    FxLandHitScale = 0.45,
    FxImpactUnderWater = TMavaEffectTemplate.AvalancheRocketHit,
    FxImpactWater = TMavaEffectTemplate.AvalancheRocketHit,
    FxWaterHitScale = 0.45,
    FxTrailOffset = -0.5,

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_008_albedo', 5, 5, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# UEF Havoc Bomb
#----------------
UefBRNAT3BOMBERproj = Class(EmitterProjectile) {
    FxTrails = {},
    FxImpactUnit = TMEffectTemplate.UEFDeath02,
    FxImpactProp = TMEffectTemplate.UEFDeath02,
    FxPropHitScale = 1.25,
    FxUnitHitScale = 1.25,
    FxLandHitScale = 1.25,
    FxImpactLand = TMEffectTemplate.UEFDeath02,
    FxImpactUnderWater = {},

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()
        CreateLightParticle( self, -1, army, 2.75, 4, 'sparkle_03', 'ramp_fire_03' )
        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_008_albedo', 12, 12, 550, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        EmitterProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# Aeon Experimental Novacat mk2 Smallguns
#----------------
AeonBROT3NCM2proj = Class(MultiPolyTrailProjectile) {

	PolyTrails  = {
            '/mods/TotalMayhem/effects/emitters/AeonT3NCM2_polytrails_emit.bp',
	},
    FxImpactUnit = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxUnitHitScale = 0.85,
    FxImpactProp = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxPropHitScale = 0.85,
    FxImpactLand = EffectTemplate.SDFExperimentalPhasonProjHit01,
    FxLandHitScale = 0.85,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_007_albedo', 5, 5, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        MultiPolyTrailProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# UEF T1 Advanced Fighter Bomber missiles AA
#----------------
UefBRNAT1ADVFIGproj = Class(SingleBeamProjectile) {
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -0.5,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TShipGaussCannonHit02,
    FxUnitHitScale = 0.55,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
    FxPropHitScale = 0.55,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit02,
    FxLandHitScale = 0.55,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# UEF T2 Fighter missiles AA
#----------------
UefBRNAT2FIGHTERproj = Class(SingleBeamProjectile) {
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -0.5,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TShipGaussCannonHit02,
    FxUnitHitScale = 0.55,
    FxImpactProp = EffectTemplate.TShipGaussCannonHit02,
    FxPropHitScale = 0.55,
    FxImpactLand = EffectTemplate.TShipGaussCannonHit02,
    FxLandHitScale = 0.55,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

#----------------
# Cybran Avalanche Rockets
#----------------
CybBRMT3AVARLproj = Class(SingleBeamProjectile) {
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxTrails = EffectTemplate.TMissileExhaust03,
    FxImpactUnit = TMavaEffectTemplate.AvalancheRocketHit,
    FxUnitHitScale = 1,
    FxImpactProp = TMavaEffectTemplate.AvalancheRocketHit,
    FxPropHitScale = 1,
    FxImpactLand = TMavaEffectTemplate.AvalancheRocketHit,
    FxLandHitScale = 1,
    FxImpactUnderWater = TMavaEffectTemplate.AvalancheRocketHit,
    FxImpactWater = TMavaEffectTemplate.AvalancheRocketHit,
    FxWaterHitScale = 1,
    FxTrailOffset = -0.5,

    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_003_albedo', 18, 18, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        SingleBeamProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# UEF Mayhem mk4 Main Guns
#----------------
UefBRNT3SHBM2proj = Class(MultiPolyTrailProjectile) {
    FxTrails = EffectTemplate.SChronotronCannonProjectileFxTrails,
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxUnitHitScale = 1.2,
    FxImpactProp = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxPropHitScale = 1.2,
    FxImpactLand = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxLandHitScale = 1.2,
    FxImpactUnderWater = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxImpactWater = TMavaEffectTemplate.UEFMayhemMK4hit1,
    OnImpact = function(self, TargetType, TargetEntity)
        local army = self:GetArmy()

        if TargetType == 'Terrain' then
            CreateSplat( self:GetPosition(), 0, 'scorch_004_albedo', 11, 11, 250, 200, army )

            #local blanketSides = 12
            #local blanketAngle = (2*math.pi) / blanketSides
            #local blanketStrength = 1
            #local blanketVelocity = 2.25

            #for i = 0, (blanketSides-1) do
            #    local blanketX = math.sin(i*blanketAngle)
            #    local blanketZ = math.cos(i*blanketAngle)
            #    local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
            #        :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
            #end
        end
        MultiPolyTrailProjectile.OnImpact( self, TargetType, TargetEntity )
    end,
}

#----------------
# UEF Mayhem mk4 EMP weapon
#----------------
UefBRNT3SHBM2EMPproj = Class(MultiPolyTrailProjectile) {
    FxImpactUnit = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxUnitHitScale = 0,
    FxImpactProp = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxPropHitScale = 0,
    FxImpactLand = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxLandHitScale = 0,
    FxImpactUnderWater = TMavaEffectTemplate.UEFMayhemMK4hit1,
    FxImpactWater = TMavaEffectTemplate.UEFMayhemMK4hit1,
}

#----------------
# UEF MAYHEM mk4 new rockets
#----------------
UefBRNT3SHBMNEWRLAproj = Class(SingleBeamProjectile) {
    FxTrailOffset = -0.8,
    FxTrails = EffectTemplate.TMissileExhaust03,
    FxImpactUnit = TMEffectTemplate.UEFmayhemRocketHit,
    FxUnitHitScale = 1.2,
    FxImpactProp = TMEffectTemplate.UEFmayhemRocketHit,
    FxPropHitScale = 1.2,
    FxImpactLand = TMEffectTemplate.UEFmayhemRocketHit,
    FxLandHitScale = 1.2,
    FxImpactUnderWater = TMEffectTemplate.UEFmayhemRocketHit,
    FxImpactWater = TMEffectTemplate.UEFmayhemRocketHit,
}

#----------------
# UEF Tech Experimental MAYHEM new rockets
#----------------
UefBRNT3SHBMNEWRLAproj = Class(SingleBeamProjectile) {
    FxTrailOffset = -0.8,
    FxTrails = EffectTemplate.TMissileExhaust03,
    FxImpactUnit = TMavaEffectTemplate.UEFmayhemRocketHitA,
    FxUnitHitScale = 1.2,
    FxImpactProp = TMavaEffectTemplate.UEFmayhemRocketHitA,
    FxPropHitScale = 1.2,
    FxImpactLand = TMavaEffectTemplate.UEFmayhemRocketHitA,
    FxLandHitScale = 1.2,
    FxImpactUnderWater = TMavaEffectTemplate.UEFmayhemRocketHitA,
    FxImpactWater = TMavaEffectTemplate.UEFmayhemRocketHitA,
}

#----------------
# UEF MAYHEM mk4 new rockets small
#----------------
UefBRNT3SHBMNEWRL2Aproj = Class(SingleBeamProjectile) {
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -0.5,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',
    FxImpactUnit = TMavaEffectTemplate.UEFmayhemRocketHit2A,
    FxUnitHitScale = 0.8,
    FxImpactProp = TMavaEffectTemplate.UEFmayhemRocketHit2A,
    FxPropHitScale = 0.8,
    FxImpactLand = TMavaEffectTemplate.UEFmayhemRocketHit2A,
    FxLandHitScale = 0.8,
    FxImpactUnderWater = TMavaEffectTemplate.UEFmayhemRocketHit2A,
    FxImpactWater = TMavaEffectTemplate.UEFmayhemRocketHit2A,
}
