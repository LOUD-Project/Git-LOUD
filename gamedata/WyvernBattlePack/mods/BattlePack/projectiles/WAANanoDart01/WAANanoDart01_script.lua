--
-- Cybran Anti Air Projectile
--

CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile03

CAANanoDart02 = Class(CAANanoDartProjectile) {

    OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
    end,
}

TypeClass = CAANanoDart02
