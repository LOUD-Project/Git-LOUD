local ATorpedoCluster = import('/lua/aeonprojectiles.lua').ATorpedoCluster

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateTrail = CreateTrail

AANTorpedoCluster01 = Class(ATorpedoCluster) {

    CountdownLength = 10,
	
    FxEnterWater= {'/effects/emitters/water_splash_plume_01_emit.bp' },

    OnCreate = function(self)
	
		self.CountdownLength = self:GetBlueprint().Physics.Lifetime
		
        ATorpedoCluster.OnCreate(self)
		
        self.HasImpacted = false
		
        self:ForkThread(self.CountdownExplosion)

		CreateTrail(self, -1, self:GetArmy(), import('/lua/EffectTemplates.lua').ATorpedoPolyTrails01)
        
    end,

    CountdownExplosion = function(self)
	
        WaitSeconds(self.CountdownLength)

        if not self.HasImpacted then
		
            self.OnImpact(self, 'Underwater', nil)
			
        end
		
    end,

    OnEnterWater = function(self)
	
        ATorpedoCluster.OnEnterWater(self)
		
        local army = self:GetArmy()
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        for i in self.FxEnterWater do #splash
            CreateEmitterAtEntity(self,army,self.FxEnterWater[i])
        end
		
        self:ForkThread(self.EnterWaterMovementThread)
		
    end,
    
    EnterWaterMovementThread = function(self)
	
        self:SetAcceleration(3.5)
		
        self:TrackTarget(true)
		
        self:StayUnderwater(true)
        self:SetTurnRate(360)
        self:SetStayUpright(false)
		
    end,

    OnLostTarget = function(self)
	
        self:SetMaxSpeed(2)
		
        self:SetAcceleration(-0.6)
		
        self:ForkThread(self.CountdownMovement)
		
    end,

    CountdownMovement = function(self)
	
        WaitSeconds(1)
		
        self:SetMaxSpeed(0)
		
        self:SetAcceleration(0)
		
        self:SetVelocity(0)
		
    end,

    OnImpact = function(self, TargetType, TargetEntity)
	
        self.HasImpacted = true
		
        ATorpedoCluster.OnImpact(self, TargetType, TargetEntity)
		
    end,
}

TypeClass = AANTorpedoCluster01