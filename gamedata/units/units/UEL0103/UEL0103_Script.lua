local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TIFHighBallisticMortarWeapon = import('/lua/terranweapons.lua').TIFHighBallisticMortarWeapon

UEL0103 = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(TIFHighBallisticMortarWeapon) {
                
                CreateProjectileAtMuzzle = function(self, muzzle)
                    local proj = TIFHighBallisticMortarWeapon.CreateProjectileAtMuzzle(self, muzzle)
                    local bp = self:GetBlueprint()
                    local data = {
                        Radius = bp.CameraVisionRadius or 5,
                        Lifetime = bp.CameraLifetime or 5,
                        Army = self.unit:GetArmy(),
                    }
                    if proj and not proj:BeenDestroyed() then
                        proj:PassData(data)
                    end
                end,
            },
    },
}

TypeClass = UEL0103