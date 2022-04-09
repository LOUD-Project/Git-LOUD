local CTorpedoShipProjectile = import('/lua/cybranprojectiles.lua').CTorpedoShipProjectile

local BeenDestroyed = moho.entity_methods.BeenDestroyed

local ForkThread = ForkThread

local WaitSeconds = WaitSeconds

local VDist3 = VDist3

CANTorpedoNanite02 = Class(CTorpedoShipProjectile) {

    TrailDelay = 0,
    
    OnCreate = function(self, inWater)
    
        CTorpedoShipProjectile.OnCreate(self, inWater)
        
        self:ForkThread( self.MovementThread )
    end,   
    
    MovementThread = function(self)
    
        local function GetDistanceToTarget()
            return VDist3( self:GetCurrentTargetPosition(), self:GetPosition() )
        end
    
        while not BeenDestroyed(self) and (GetDistanceToTarget() > 8) do
            WaitSeconds(0.25)
        end
        
        if not BeenDestroyed(self) then
			self:ChangeMaxZigZag(0)
			self:ChangeZigZagFrequency(0)
		end
    end,

    OnEnterWater = function(self)
    
        CTorpedoShipProjectile.OnEnterWater(self)
        
        self.CreateImpactEffects( self, self:GetArmy(), self.FxEnterWater, self.FxSplashScale )
        
        self:StayUnderwater(true)
        self:TrackTarget(true)
        self:SetTurnRate(120)
        self:SetMaxSpeed(18)
        self:SetVelocity(3)
    end,

}

TypeClass = CANTorpedoNanite02