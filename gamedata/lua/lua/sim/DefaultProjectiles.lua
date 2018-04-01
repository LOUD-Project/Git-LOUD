---  /lua/defaultprojectiles.lua
---  Script for default projectiles

local Projectile = import('/lua/sim/Projectile.lua').Projectile

local LOUDEMITONENTITY = CreateEmitterOnEntity
local LOUDBEAMEMITONENTITY = CreateBeamEmitterOnEntity
local LOUDTRAIL = CreateTrail

local GetArmy = moho.entity_methods.GetArmy


NullShell = Class(Projectile) {}

EmitterProjectile = Class(Projectile) {

    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    FxTrailOffset = 0,

    OnCreate = function(self)
        Projectile.OnCreate(self)
		
        local army = GetArmy(self)
		
        for i in self.FxTrails do
            LOUDEMITONENTITY(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
    end,
}

SingleBeamProjectile = Class(EmitterProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
		
        if self.BeamName then
            LOUDBEAMEMITONENTITY( self, -1, GetArmy(self), self.BeamName )
        end
    end,
}

MultiBeamProjectile = Class(EmitterProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
		
        for _, v in self.Beams do
            LOUDBEAMEMITONENTITY( self, -1, GetArmy(self), v )
        end
    end,
}

SinglePolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',
    PolyTrailOffset = 0,
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
	
        if self.PolyTrail != '' then
            LOUDTRAIL(self, -1, GetArmy(self), self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
    end,
}

MultiPolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrails = {'/effects/emitters/test_missile_trail_emit.bp'},
    PolyTrailOffset = {0},
    FxTrails = {},
    RandomPolyTrails = 0,   -- Count of how many are selected randomly for PolyTrail table

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
		
        if self.PolyTrails then
		
            local NumPolyTrails = table.getn( self.PolyTrails )
			local army = GetArmy(self)
			
            if self.RandomPolyTrails != 0 then
				
                local index = nil
				
                for i = 1, self.RandomPolyTrails do
                    index = math.floor( Random( 1, NumPolyTrails))
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

-- COMPOSITE EMITTER PROJECTILES - MULTIPURPOSE PROJECTILES
-- THAT COMBINES BEAMS, POLYTRAILS, AND NORMAL EMITTERS

-- LIGHTWEIGHT VERSION THAT LIMITS USE TO 1 BEAM, 1 POLYTRAIL, AND STANDARD EMITTERS
SingleCompositeEmitterProjectile = Class(SinglePolyTrailProjectile) {

    BeamName = '/effects/emitters/default_beam_01_emit.bp',
    FxTrails = {},

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        if self.BeamName != '' then
            LOUDBEAMEMITONENTITY( self, -1, GetArmy(self), self.BeamName )
        end
    end,
}

-- HEAVYWEIGHT VERSION, ALLOWS FOR MULTIPLE BEAMS, POLYTRAILS, AND STANDARD EMITTERS
MultiCompositeEmitterProjectile = Class(MultiPolyTrailProjectile) {

    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    PolyTrails = {'/effects/emitters/test_missile_trail_emit.bp'},
    PolyTrailOffset = {0},
    RandomPolyTrails = 0,   -- Count of how many are selected randomly for PolyTrail table
    FxTrails = {},

    OnCreate = function(self)
        MultiPolyTrailProjectile.OnCreate(self)

        for _, v in self.Beams do
            LOUDBEAMEMITONENTITY( self, -1, GetArmy(self), v )
        end
    end,
}


-- TRAIL ON ENTERING WATER PROJECTILE
OnWaterEntryEmitterProjectile = Class(Projectile) {

    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp','/effects/emitters/anti_torpedo_flare_01_emit.bp','/effects/emitters/anti_torpedo_flare_02_emit.bp' },
    FxTrailScale = 1,
    FxTrailOffset = 0,
    PolyTrail = '',
    PolyTrailOffset = 0,
    TrailDelay = 3,
	
    EnterWaterSound = 'Torpedo_Enter_Water_01',

    OnCreate = function(self, inWater)
	
        Projectile.OnCreate(self, inWater)
		
        if inWater then
		
			local army = GetArmy(self)
			
			for i in self.FxTrails do
				LOUDEMITONENTITY(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
			end
			
			if self.PolyTrail != '' then
				LOUDTRAIL(self, -1, army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
			end
			
		end
		
    end,

    EnterWaterThread = function(self)
	
        WaitTicks(self.TrailDelay)
		
        local army = GetArmy(self)
		
        for i in self.FxTrails do
            LOUDEMITONENTITY(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
		
        if self.PolyTrail != '' then
            LOUDTRAIL(self, -1, army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
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


-- GENERIC DEBRIS PROJECTILE
BaseGenericDebris = Class( EmitterProjectile ){
    FxUnitHitScale = 0.25,
    FxWaterHitScale = 0.25,
    FxUnderWaterHitScale = 0.25,
    FxNoneHitScale = 0.25,
    FxImpactLand = false,
    FxLandHitScale = 0.3,
    FxTrails = false,
    FxTrailScale = 1,
}
