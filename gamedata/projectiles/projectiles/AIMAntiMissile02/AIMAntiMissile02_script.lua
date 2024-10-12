local AIMFlareProjectile = import('/lua/aeonprojectiles.lua').AIMFlareProjectile

AIMAntiMissile01 = Class(AIMFlareProjectile) {
    OnCreate = function(self)
        AIMFlareProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 0.8)
    end,
}

TypeClass = AIMAntiMissile01

