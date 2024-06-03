local AArtilleryProjectile = import('/lua/aeonprojectiles.lua').AArtilleryProjectile

local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

local CreateDecal = CreateDecal

AIFSonanceShell02 = Class(AArtilleryProjectile) {
    
    FxTrails = EffectTemplate.ASonanceWeaponFXTrail02,
    
    FxImpactUnit =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactProp =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactLand =  EffectTemplate.ASonanceWeaponHit02,
    
    OnImpact = function(self, TargetType, targetEntity)
	
		if TargetType != 'Shield' and TargetType != 'Water' and TargetType != 'UnitAir' then
			local rotation = RandomFloat(0,6.28)
        
			CreateDecal(self:GetPosition(), rotation, 'crater_radial01_normals', '', 'Alpha Normals', 5, 5, 100, 0, self:GetArmy())
			CreateDecal(self:GetPosition(), rotation, 'crater_radial01_albedo', '', 'Albedo', 6, 6, 100, 0, self:GetArmy())
 
		end
		
        AArtilleryProjectile.OnImpact( self, TargetType, targetEntity )
    end,
}

TypeClass = AIFSonanceShell02