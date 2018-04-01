
local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit
local SLaanseMissileWeapon = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon
local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon

BSA0310 = Class(SAirUnit) {
    Weapons = {
    	MainTurret = Class(SLaanseMissileWeapon) {},
        LeftTurret = Class(SDFThauCannon) {
        	CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = SDFThauCannon.CreateProjectileAtMuzzle(self, muzzle)
                local data = self:GetBlueprint().DamageToShields
                if proj and not proj:BeenDestroyed() then
                    proj:PassData(data)
                end
            end,
        },
        RightTurret = Class(SDFThauCannon) {
        	CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = SDFThauCannon.CreateProjectileAtMuzzle(self, muzzle)
                local data = self:GetBlueprint().DamageToShields
                if proj and not proj:BeenDestroyed() then
                    proj:PassData(data)
                end
            end,
        },
        CenterTurret = Class(SAALosaareAutoCannonWeapon) {},
    },
}
TypeClass = BSA0310