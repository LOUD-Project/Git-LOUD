local AArtilleryFragmentationSensorShellProjectile = import('/lua/aeonprojectiles.lua').AArtilleryFragmentationSensorShellProjectile03

local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

local CreateDecal = CreateDecal

AIFFragmentationSensorShell03 = Class(AArtilleryFragmentationSensorShellProjectile) {

    OnImpact = function(self, TargetType, targetEntity)
		-- if hitting ground create the splat on the ground
		if TargetType == 'Terrain' then
		
			local rotation = RandomFloat(0,2*math.pi)
			local size = RandomFloat(2.25,3.75)
        
			CreateDecal(self:GetPosition(), rotation, 'scorch_004_albedo', '', 'Albedo', size, size, 180, 15, self:GetArmy())
		end
 
        AArtilleryFragmentationSensorShellProjectile.OnImpact( self, TargetType, targetEntity )
    end,	
}
TypeClass = AIFFragmentationSensorShell03