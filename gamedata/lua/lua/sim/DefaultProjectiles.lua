---  /lua/defaultprojectiles.lua
---  Script for default projectiles

local Projectile = import('/lua/sim/Projectile.lua').Projectile

local LOUDEMITONENTITY = CreateEmitterOnEntity
local LOUDBEAMEMITONENTITY = CreateBeamEmitterOnEntity
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDTRAIL = CreateTrail


NullShell = Class(Projectile) {}

EmitterProjectile = Class(Projectile) {

    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,

    OnCreate = function(self)

        Projectile.OnCreate(self)
        
        if self.FxTrails then
		
            for i in self.FxTrails do
            
                if self.FxTrailOffset then
                    LOUDEMITONENTITY(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
                else
                    if self.FxTrailScale != 1 then
                        LOUDEMITONENTITY(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale)
                    else
                        LOUDEMITONENTITY(self, self.Army, self.FxTrails[i])
                    end
                end
            end
            
        end
    end,
}

SingleBeamProjectile = Class(EmitterProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',

    OnCreate = function(self)

        EmitterProjectile.OnCreate(self)

        if self.BeamName then
            LOUDBEAMEMITONENTITY( self, -1, self.Army, self.BeamName )
        end
    end,
}

MultiBeamProjectile = Class(EmitterProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},

    OnCreate = function(self)
    
        EmitterProjectile.OnCreate(self)
		
        for _, v in self.Beams do
            LOUDBEAMEMITONENTITY( self, -1, self.Army, v )
        end
    end,
}

SinglePolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',

    OnCreate = function(self)
    
        EmitterProjectile.OnCreate(self)
	
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
    
        EmitterProjectile.OnCreate(self)
		
        if self.PolyTrails then
		
            local NumPolyTrails = LOUDGETN( self.PolyTrails )
            
			local army = self.Army
			
            if self.RandomPolyTrails != 0 then
				
                local index = nil
				
                for i = 1, self.RandomPolyTrails do
                
                    index = LOUDFLOOR( Random( 1, NumPolyTrails))
                    
                    if self.PolyTrailOffset[index] then
                        LOUDTRAIL(self, -1, army, self.PolyTrails[index] ):OffsetEmitter(0, 0, self.PolyTrailOffset[index])
                    else
                        LOUDTRAIL(self, -1, army, self.PolyTrails[index] )
                    end
                    
                end
                
            else
            
                for i = 1, NumPolyTrails do
                
                    if self.PolyTrailOffset[i]  then
                        LOUDTRAIL(self, -1, army, self.PolyTrails[i] ):OffsetEmitter(0, 0, self.PolyTrailOffset[i])
                    else
                        LOUDTRAIL(self, -1, army, self.PolyTrails[i] )
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

    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp','/effects/emitters/anti_torpedo_flare_01_emit.bp','/effects/emitters/anti_torpedo_flare_02_emit.bp' },
    FxTrailScale = 1,

    PolyTrail = false,

    TrailDelay = 3,
	
    EnterWaterSound = 'Torpedo_Enter_Water_01',

    OnCreate = function(self, inWater)
	
        Projectile.OnCreate(self, inWater)
		
        if inWater then
		
            if self.FxTrails then
            
                for i in self.FxTrails do
                
                    if self.FxTrailOffset then
                        LOUDEMITONENTITY(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
                    else
                        if self.FxTrailScale != 1 then
                            LOUDEMITONENTITY(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale)
                        else
                            LOUDEMITONENTITY(self, self.Army, self.FxTrails[i])
                        end
                    end
                end
            end
			
			if self.PolyTrail then
            
                if self.PolyTrailOffset then
                    LOUDTRAIL(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
                else
                    LOUDTRAIL(self, -1, self.Army, self.PolyTrail)
                end
			end
			
		end
    end,

    EnterWaterThread = function(self)
	
        WaitTicks(self.TrailDelay)

        if self.FxTrails then
        
            for i in self.FxTrails do
            
                if self.FxTrailOffset then
                    LOUDEMITONENTITY(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
                else
                    LOUDEMITONENTITY(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale)
                end
            end
        end
		
        if self.PolyTrail then
        
            if self.PolyTrailOffset != 0 then
                LOUDTRAIL(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
            else
                LOUDTRAIL(self, -1, self.Army, self.PolyTrail)
            end
        end
		
    end,

    OnEnterWater = function(self)
	
        Projectile.OnEnterWater(self)
		
        self:TrackTarget(true)
        self:StayUnderwater(true)
		
        self.TTT1 = self:ForkThread( self.EnterWaterThread )
		
    end,

    OnImpact = function(self, TargetType, TargetEntity)
	
        Projectile.OnImpact(self, TargetType, TargetEntity)
		
        KillThread(self.TTT1)
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
