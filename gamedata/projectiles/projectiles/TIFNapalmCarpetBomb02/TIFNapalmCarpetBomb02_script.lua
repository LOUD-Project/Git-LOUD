local TNapalmHvyCarpetBombProjectile = import('/lua/terranprojectiles.lua').TNapalmHvyCarpetBombProjectile

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local CreateDecal = CreateDecal 

TIFNapalmCarpetBomb02 = Class(TNapalmHvyCarpetBombProjectile) {

    OnImpact = function(self, TargetType, targetEntity)

		if TargetType != 'Water' then 
			local rotation = RandomFloat(0,6.28)
			local size = RandomFloat(3.75,5.0)
	        
			CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', size, size, 150, 15, self:GetArmy())
		end	 

		TNapalmHvyCarpetBombProjectile.OnImpact( self, TargetType, targetEntity )
    end,	    
}
TypeClass = TIFNapalmCarpetBomb02
