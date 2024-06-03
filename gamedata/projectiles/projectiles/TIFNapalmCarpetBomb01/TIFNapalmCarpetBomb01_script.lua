local TNapalmCarpetBombProjectile = import('/lua/terranprojectiles.lua').TNapalmCarpetBombProjectile

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local CreateDecal = CreateDecal

TIFNapalmCarpetBomb01 = Class(TNapalmCarpetBombProjectile) {

    OnImpact = function(self, TargetType, targetEntity)

		if TargetType != 'Water' then 
			local rotation = RandomFloat(0,6.28)
			local size = RandomFloat(2.1,3.5)
	        
			CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', size, size, 150, 15, self:GetArmy())
		end	 

		TNapalmCarpetBombProjectile.OnImpact( self, TargetType, targetEntity )
    end,
}

TypeClass = TIFNapalmCarpetBomb01
