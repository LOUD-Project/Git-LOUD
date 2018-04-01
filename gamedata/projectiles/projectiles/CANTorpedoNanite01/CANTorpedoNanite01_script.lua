local CTorpedoSubProjectile = import('/lua/cybranprojectiles.lua').CTorpedoSubProjectile

CANTorpedoNanite01 = Class(CTorpedoSubProjectile) {

	OnCreate = function(self, inWater)
	
        CTorpedoSubProjectile.OnCreate(self, inWater)
		
        if inWater then
		
            self:SetBallisticAcceleration(0)
			
        else
		
            self:SetBallisticAcceleration(-10)
            self:TrackTarget(false)
			
        end
		
    end,
    
    OnEnterWater = function(self)
	
        CTorpedoSubProjectile.OnEnterWater(self)
		
        self:SetBallisticAcceleration(0)

        self:TrackTarget(true)
		
    end,
	
}

TypeClass = CANTorpedoNanite01