local TNapalmHvyCarpetBombProjectile = import('/lua/terranprojectiles.lua').TNapalmHvyCarpetBombProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local CreateDecal = CreateDecal 
local LOUDPI = math.pi

TIFNapalmCarpetBomb02 = Class(TNapalmHvyCarpetBombProjectile) {
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local rotation = RandomFloat(0,2*LOUDPI)
			local size = RandomFloat(3.75,5.0)
	        
			CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', size, size, 150, 15, self:GetArmy())
		end	 
		TNapalmHvyCarpetBombProjectile.OnImpact( self, TargetType, targetEntity )
    end,	    
}
TypeClass = TIFNapalmCarpetBomb02
