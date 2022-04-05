local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Custom_4D_EffectTemplate = import('/mods/4DC/lua/4D_EffectTemplates.lua')

local VDist3 = VDist3
local WaitTicks = coroutine.yield

local Random = Random

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end

EmtBpPath = '/effects/emitters/'

SCCollisionBeam = Class(CollisionBeam) {
    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxUnitHitScale = 0.3,     
    FxImpactLand = EffectTemplate.DefaultProjectileLandImpact,
    FxLandHitScale = .3,    
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
}

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
    
        local army = self.Army
        
        local size = 1.5 + (Random() * 1.5) 
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        
        while true do
        
            if VDist3( CurrentPosition, LastPosition ) > 0.5 or skipCount > 100 then
            
                CreateSplat( CurrentPosition, GetRandomFloat(0, 6.28), self.SplatTexture, size, size, 100, 80, army )
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitTicks( 4 )
            
            size = 1.2 + (Random() * 1.5)
            
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

VampireGreenLaserCollisionBeam = Class(SCCollisionBeam) {

    TerrainImpactType = 'LargeBeam01',

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 1,

    FxBeam = {'/mods/4DC/effects/Emitters/green_laser_beam_02_emit.bp'},

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
    
        local army = self.Army
        
        local size = 0.25 + (Random() * 0.75) 
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        
        while true do
        
            if VDist3( CurrentPosition, LastPosition ) > 0.5 or skipCount > 100 then
            
                CreateSplat( CurrentPosition, GetRandomFloat(0,6.28), self.SplatTexture, size, size, 100, 25, army )
                LastPosition = CurrentPosition
                skipCount = 1
            else
            
                skipCount = skipCount + self.ScorchSplatDropTime
                
            end

            WaitTicks( 2 )
            size = 0.25 + (Random() * 0.75)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}