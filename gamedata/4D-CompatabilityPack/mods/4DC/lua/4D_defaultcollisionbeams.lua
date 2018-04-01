------------------------------------------------------------------------------
--  File     : /mods/4DC/lua/4D_defaultcollisionbeams.lua
--
--  Author(s): EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  (Weapon Templates by:Exavier Macbeth)
--
--  Copyright © 2010 4DC  All rights reserved.
------------------------------------------------------------------------------

local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Custom_4D_EffectTemplate = import('/mods/4DC/lua/4D_EffectTemplates.lua')
local Util = import('/lua/utilities.lua')
EmtBpPath = '/effects/emitters/'

------------------------------
--   Base class that defines supreme commander specific defaults (Do not delete)
------------------------------
SCCollisionBeam = Class(CollisionBeam) {
    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxUnitHitScale = 0.3,     
    FxImpactLand = EffectTemplate.DefaultProjectileLandImpact,
    FxLandHitScale = .3,    
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
    FxImpactProp = {},
    FxImpactShield = {},    
    FxImpactNone = {},
}

------------------------------
--   Lighting beam for the Seraphem transformable heavy bot
------------------------------

xsl031a_LightningBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.25,
    FxBeamStartPoint = EffectTemplate.SExperimentalUnstablePhasonLaserMuzzle01,
    FxBeam = Custom_4D_EffectTemplate.LightingStrikeBeam,
    FxBeamEndPoint = EffectTemplate.OthuyElectricityStrikeHit,
    FxBeamEndPointScale = .25, 
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.1,

    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread( self.ScorchThread )   
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        SCCollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    OnDisable = function( self )
        SCCollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil   
    end,

    ScorchThread = function(self)
        local army = self:GetArmy()
        local size = 1.5 + (Random() * 1.5) 
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors( CurrentPosition, LastPosition ) > 0.25 or skipCount > 100 then
                CreateSplat( CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army )
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end
                
            WaitSeconds( self.ScorchSplatDropTime )
            size = 1.2 + (Random() * 1.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

------------------------------
--   Green beam for the Cybran Vampire
------------------------------

VampireGreenLaserCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 1,

 --   FxBeamStartPoint = {
 --       '/mods/4DC/effects/Emitters/green_beampoint_02_emit.bp',
 --   },

    FxBeam = {'/mods/4DC/effects/Emitters/green_laser_beam_02_emit.bp'},

 --   FxBeamEndPoint = {
 --       '/mods/4DC/effects/Emitters/green_beampoint_01_emit.bp',
 --   },
 --   FxBeamEndPointScale = 0.5,

    FxImpactUnit = {
        '/mods/4DC/effects/Emitters/green_hit_unit_emit.bp',
        '/mods/4DC/effects/Emitters/green_beam_hit_sparks_emit.bp',
        EmtBpPath .. 'beam_hit_smoke_01_emit.bp',
    },
    FxUnitHitScale = 0.5,

    FxImpactLand = {  
        EmtBpPath .. 'dirtchunks_01_emit.bp',
        EmtBpPath .. 'dust_cloud_05_emit.bp',
        EmtBpPath .. 'beam_hit_smoke_01_emit.bp',
    },
    FxLandHitScale = 0.5,
    
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread( self.ScorchThread )   
            end
        else
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,   
  
    OnDisable = function( self )
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil   
    end,    
    
    ScorchThread = function(self)
        local army = self:GetArmy()
        local size = 0.25 + (Random() * 0.75) 
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors( CurrentPosition, LastPosition ) > 0.25 or skipCount > 100 then
                CreateSplat( CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 25, army )
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end
                
            WaitTicks( self.ScorchSplatDropTime + Random(1, 2) )
            size = 0.25 + (Random() * 0.75)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}