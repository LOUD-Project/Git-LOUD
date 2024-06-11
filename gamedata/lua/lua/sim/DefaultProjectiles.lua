---  /lua/defaultprojectiles.lua
---  Script for default projectiles

local Projectile = import('/lua/sim/Projectile.lua').Projectile

local ProjectileOnCreate        = Projectile.OnCreate
local ProjectileOnEnterWater    = Projectile.OnEnterWater
local ProjectileOnImpact        = Projectile.OnImpact

local LOUDEMITONENTITY          = CreateEmitterOnEntity
local LOUDBEAMEMITONENTITY      = CreateBeamEmitterOnEntity
local LOUDFLOOR                 = math.floor
local LOUDGETN                  = table.getn
local LOUDTRAIL                 = CreateTrail

local TrashBag          = TrashBag
local TrashAdd          = TrashBag.Add
local TrashDestroy      = TrashBag.Destroy

local WaitTicks                 = coroutine.yield


NullShell = Class(Projectile) {}

EmitterProjectile = Class(Projectile) {

    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 0.7,

    OnCreate = function(self)

        ProjectileOnCreate(self)
        
        if self.FxTrails then
        
            local Army = self.Army
            local FxTrails = self.FxTrails
        
            LOUDEMITONENTITY = LOUDEMITONENTITY
		
            for i in FxTrails do
            
                if self.FxTrailOffset then
                    LOUDEMITONENTITY(self, Army, FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
                else
                    if self.FxTrailScale != 1 then
                        LOUDEMITONENTITY(self, Army, FxTrails[i]):ScaleEmitter(self.FxTrailScale)
                    else
                        LOUDEMITONENTITY(self, Army, FxTrails[i])
                    end
                end
            end
        end
    end,
}

local EmitterProjectileOnCreate = EmitterProjectile.OnCreate

SingleBeamProjectile = Class(EmitterProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',

    OnCreate = function(self)

        EmitterProjectileOnCreate(self)

        if self.BeamName then
            LOUDBEAMEMITONENTITY( self, -1, self.Army, self.BeamName )
        end
    end,
}

MultiBeamProjectile = Class(EmitterProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)
        
        LOUDBEAMEMITONENTITY = LOUDBEAMEMITONENTITY
		
        for _, v in self.Beams do
            LOUDBEAMEMITONENTITY( self, -1, self.Army, v )
        end
    end,
}

SinglePolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)
	
        if self.PolyTrail then
        
            if self.PolytrailOffset then
                LOUDTRAIL(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
            else
                LOUDTRAIL(self, -1, self.Army, self.PolyTrail)
            end
        end
    end,
}

MultiPolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrails = {'/effects/emitters/test_missile_trail_emit.bp'},
    
    RandomPolyTrails = 0,

    OnCreate = function(self)
    
        EmitterProjectileOnCreate(self)

        if self.PolyTrails then
		
			local army = self.Army
            local PolyTrails = self.PolyTrails
            local NumPolyTrails = LOUDGETN( PolyTrails )
			
            if self.RandomPolyTrails != 0 then
				
                local index = nil
				
                for i = 1, self.RandomPolyTrails do
                
                    index = LOUDFLOOR( Random( 1, NumPolyTrails))
                    
                    if self.PolyTrailOffset[index] then
                        LOUDTRAIL(self, -1, army, PolyTrails[index] ):OffsetEmitter(0, 0, self.PolyTrailOffset[index])
                    else
                        LOUDTRAIL(self, -1, army, PolyTrails[index] )
                    end
                end
                
            else
            
                for i = 1, NumPolyTrails do
                
                    if self.PolyTrailOffset[i]  then
                        LOUDTRAIL(self, -1, army, PolyTrails[i] ):OffsetEmitter(0, 0, self.PolyTrailOffset[i])
                    else
                        LOUDTRAIL(self, -1, army, PolyTrails[i] )
                    end
                end
            end
        end
    end,
}

SingleCompositeEmitterProjectile = Class(SinglePolyTrailProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',

    OnCreate = function(self)
    
        SinglePolyTrailProjectile.OnCreate(self)
        
        if self.BeamName != '' then
            LOUDBEAMEMITONENTITY( self, -1, self.Army, self.BeamName )
        end
    end,
}

MultiCompositeEmitterProjectile = Class(MultiPolyTrailProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    PolyTrails = {'/effects/emitters/test_missile_trail_emit.bp'},

    RandomPolyTrails = 0,   -- Count of how many are selected randomly for PolyTrail table

    OnCreate = function(self)
    
        MultiPolyTrailProjectile.OnCreate(self)

        for _, v in self.Beams do
            LOUDBEAMEMITONENTITY( self, -1, self.Army, v )
        end
    end,
}

OnWaterEntryEmitterProjectile = Class(Projectile) {

    FxTrails = {'/effects/emitters/anti_torpedo_flare_01_emit.bp' },
    FxTrailScale = 0.4,

    PolyTrail = false,

    TrailDelay = 3,

    OnCreate = function(self, inWater)
	
        ProjectileOnCreate(self, inWater)
		
        if inWater then
       
            self:ForkThread( self.InWaterEffects )
			
		end
        
    end,

    InWaterEffects = function(self, Army, FxTrails, PolyTrail)
	
        WaitTicks(self.TrailDelay)

        if FxTrails then
        
            LOUDEMITONENTITY = LOUDEMITONENTITY
        
            for i in FxTrails do
            
                if self.FxTrailOffset then
                    TrashAdd( self.Trash, LOUDEMITONENTITY(self, Army, FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset))
                else
                    TrashAdd( self.Trash, LOUDEMITONENTITY(self, Army, FxTrails[i]):ScaleEmitter(self.FxTrailScale))
                end
            end
        end
		
        if PolyTrail then
        
            if self.PolyTrailOffset != 0 then
                TrashAdd( self.Trash, LOUDTRAIL(self, -1, Army, PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset))
            else
                TrashAdd( self.Trash, LOUDTRAIL(self, -1, Army, PolyTrail))
            end
        end
		
    end,

    OnEnterWater = function(self)

        -- this should create the audio event
        ProjectileOnEnterWater(self)
		
        self:TrackTarget(true)
        self:StayUnderwater(true)

        local Army = self.Army
        
        local FxEnterWater  = self.FxEnterWater or false
        local FxTrails      = self.FxTrails or false
        local PolyTrail     = self.PolyTrail or false
		
        if FxEnterWater then
        
            for k, v in FxEnterWater do
                CreateEmitterAtEntity(self, Army, v):ScaleEmitter(self.FxSplashScale or 1)
			end
        end

        -- this should create inwater effects
        self:ForkThread( self.InWaterEffects, Army, FxTrails, PolyTrail )
		
    end,
    
    OnExitWater = function(self)

        -- this should create the audio event
        Projectile.OnExitWater(self)

        local Army = self.Army
        
        local FxEnterWater  = self.FxEnterWater or false
		
        if FxEnterWater then
        
            for k, v in FxEnterWater do
                CreateEmitterAtEntity(self, Army, v):ScaleEmitter(self.FxSplashScale or 1)
			end
        end
	    
        -- this should kill any inwater effects
        TrashDestroy( self.Trash )
	    
    end,

    OnImpact = function(self, TargetType, TargetEntity)
	
        ProjectileOnImpact(self, TargetType, TargetEntity)
        
        TrashDestroy( self.Trash )

    end,
	
}

BaseGenericDebris = Class( EmitterProjectile ){
    FxUnitHitScale = 0.25,
    FxWaterHitScale = 0.25,
    FxUnderWaterHitScale = 0.25,
    FxNoneHitScale = 0.25,

    FxLandHitScale = 0.3,

    FxTrailScale = 1,
}
