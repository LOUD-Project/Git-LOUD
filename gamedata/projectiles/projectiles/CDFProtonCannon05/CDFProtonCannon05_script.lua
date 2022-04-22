local CDFHvyProtonCannonProjectile = import('/lua/cybranprojectiles.lua').CDFHvyProtonCannonProjectile

CDFProtonCannon05 = Class(CDFHvyProtonCannonProjectile) {
	OnImpact = function(self, TargetType, TargetEntity) 
		CDFHvyProtonCannonProjectile.OnImpact (self, TargetType, TargetEntity)
	end,
}
TypeClass = CDFProtonCannon05