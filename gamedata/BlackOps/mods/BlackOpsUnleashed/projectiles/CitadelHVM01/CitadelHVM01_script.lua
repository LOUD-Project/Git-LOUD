
local CitadelHVM01Projectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').CitadelHVM01Projectile

CitadelHVM01 = Class(CitadelHVM01Projectile) {

	OnImpact = function(self, TargetType, TargetEntity)
        if EntityCategoryContains(categories.EXPERIMENTAL, TargetEntity) then
			self.DamageData.DamageAmount = self:GetLauncher():GetBlueprint().ExperimentalDamage.DamageAmount
		end
        CitadelHVM01Projectile.OnImpact(self, TargetType, TargetEntity) 
    end,
}

TypeClass = CitadelHVM01

