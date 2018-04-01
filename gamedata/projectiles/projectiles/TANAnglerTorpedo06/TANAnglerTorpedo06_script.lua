local TTorpedoShipProjectile = import('/lua/terranprojectiles.lua').TTorpedoShipProjectile

local CreateEmitterAtEntity = CreateEmitterAtEntity

TANAnglerTorpedo06 = Class(TTorpedoShipProjectile) {

    OnEnterWater = function(self)
	
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
		
        local army = self:GetArmy()

        for k, v in self.FxEnterWater do #splash
            CreateEmitterAtEntity(self,army,v)
        end
		
		self:SetVelocity(2)
		
		self:SetAcceleration(1.5)
		
        self:TrackTarget(true)
        self:StayUnderwater(true)
        self:SetTurnRate(240)
        self:SetMaxSpeed(10)
		
    end,

}

TypeClass = TANAnglerTorpedo06
