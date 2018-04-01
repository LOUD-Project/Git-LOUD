#
# Aeon Artillery Projectile
#
local MGHeadshotProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').MGHeadshotProjectile

AeonTeleHarb01 = Class(MGHeadshotProjectile) {

	OnImpact = function(self, targetType, targetEntity)
		MGHeadshotProjectile.OnImpact(self, targetType, targetEntity)
		local myBlueprint = self:GetBlueprint()
		self:PlaySound(myBlueprint.Audio.CommanderArrival)
		self:CreateProjectile( '/mods/BlackOpsUnleashed/effects/entities/AeonUnitTeleporter01/AeonUnitTeleporter01_proj.bp', 0, 1, 0, nil, nil, nil):SetCollision(false)
		--local position = self:GetPosition()
        --local spiritUnit1 = CreateUnitHPR('UAL0303', self:GetArmy(), position[1], position[2], position[3], 0, 0, 0)
    end,

}

TypeClass = AeonTeleHarb01