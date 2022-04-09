local CTorpedoShipProjectile = import('/lua/cybranprojectiles.lua').CTorpedoShipProjectile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local VDist2 = VDist2

CANTorpedoNanite03 = Class(CTorpedoShipProjectile) {

    TrailDelay = 0,
	
    OnCreate = function(self, inWater)
	
        CTorpedoShipProjectile.OnCreate(self, inWater)
		
        if inWater then
		
            self:SetBallisticAcceleration(0)
			
        else
		
            self:SetBallisticAcceleration(-10)
            self:TrackTarget(false)
			
        end
		
    end,   

    OnEnterWater = function(self)
    
        CTorpedoShipProjectile.OnEnterWater(self)

        self.CreateImpactEffects( self, self:GetArmy(), self.FxEnterWater, self.FxSplashScale )
		
        self:SetBallisticAcceleration(0)
        
        self:StayUnderwater(true)
		
        self:TrackTarget(true)
		
        self:SetTurnRate(180)
		
		self:SetAcceleration(1.5)

    end,

}

TypeClass = CANTorpedoNanite03