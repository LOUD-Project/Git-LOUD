#
# AEON TECH 3 ENGINEER
#

local AConstructionUnit = import('/lua/aeonunits.lua').AConstructionUnit

SAL0319 = Class(AConstructionUnit) {

    OnCreate = function( self ) 
        AConstructionUnit.OnCreate(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer) 
	
        AConstructionUnit.OnStopBeingBuilt(self,builder,layer)
		
        for i = 1, 3 do
           CreateRotator(self, 'Tube00' .. i , 'x', nil, 0, 45, -45)
           CreateRotator(self, 'Tube00' .. i , 'y', nil, 0, 45, -45)
           CreateRotator(self, 'Tube00' .. i , 'z', nil, 0, 45, -45)
        end 

    end,  

    OnShieldEnabled = function(self)
	
        AConstructionUnit.OnShieldEnabled(self)

		if not self.ShieldEffectsBag[1] then
		
			self.ShieldEffectsBag[1] = { CreateAttachedEmitter( self, 0, self:GetArmy(), '/effects/emitters/aeon_shield_generator_t3_03_emit.bp' ):ScaleEmitter(0.25):OffsetEmitter(0,-.8,0) }
			
		end
		
    end,
   
    OnShieldDisabled = function(self)
	
        AConstructionUnit.OnShieldDisabled(self)
		
        if self.ShieldEffectsBag[1] then
		
            self.ShieldEffectsBag[1]:Destroy()
			
            self.ShieldEffectsBag = nil
			
        end
		
    end,
}

TypeClass = SAL0319

