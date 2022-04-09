local ADepthChargeProjectile = import('/lua/aeonprojectiles.lua').ADepthChargeProjectile

local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local CreateEmitterAtEntity = CreateEmitterAtEntity

AANDepthCharge03 = Class(ADepthChargeProjectile) {

    FxEnterWater= { '/effects/emitters/water_splash_plume_01_emit.bp' },

    OnCreate = function(self)
	
        ADepthChargeProjectile.OnCreate(self)
		
        self.HasImpacted = false

    end,

    CountdownExplosion = function(self)
	
        WaitSeconds(self.CountdownLength)

        if not self.HasImpacted then
            self.OnImpact(self, 'Underwater', nil)
        end
		
    end,

    OnEnterWater = function(self)
    
        ADepthChargeProjectile.OnEnterWater(self)

        local army = self:GetArmy()

        self:SetAcceleration(1.5)
		
        self:TrackTarget(true)
        self:StayUnderwater(true)
		
        self:SetTurnRate(540)
        self:SetVelocityAlign(true)
		
        self:SetStayUpright(false)
		
        self:ForkThread(self.EnterWaterMovementThread)
		
    end,
    
    EnterWaterMovementThread = function(self)
	
        WaitTicks(1)
        self:SetVelocity(0.5)
		
    end,

    OnLostTarget = function(self)
	
        self:SetMaxSpeed(2)
        self:SetAcceleration(-0.6)
		
        self:ForkThread(self.CountdownMovement)
		
    end,

    CountdownMovement = function(self)
	
        WaitSeconds(2)
		
        self:SetMaxSpeed(0)
        self:SetAcceleration(0)
        self:SetVelocity(0)
		
    end,

    OnImpact = function(self, TargetType, TargetEntity)
	
        #LOG('Projectile impacted with: ' .. TargetType)
		
        self.HasImpacted = true
		
        --local pos = self:GetPosition()
		
        --local spec = { X = pos[1], Z = pos[3], Radius = 30, LifeTime = 10, Omni = false, Vision = false, Army = self:GetArmy() }
		
        --local vizEntity = VizMarker(spec)
		
        ADepthChargeProjectile.OnImpact(self, TargetType, TargetEntity)
		
    end,
}

TypeClass = AANDepthCharge03