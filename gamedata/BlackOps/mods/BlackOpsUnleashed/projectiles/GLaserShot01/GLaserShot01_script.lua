
local GLaserProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').GLaserProjectile

GLaser01 = Class(GLaserProjectile) {

	OnImpact = function(self, TargetType, TargetEntity)
	
        self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/GoldLaserBombEffectController01/GoldLaserBombEffectController01_proj.bp', 0, 0, 0, 0, 0, 0):SetCollision(false)
        GLaserProjectile.OnImpact(self, TargetType, TargetEntity) 
		
    end,
}

TypeClass = GLaser01