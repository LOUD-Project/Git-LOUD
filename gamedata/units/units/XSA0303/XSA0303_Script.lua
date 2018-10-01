
local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SAALosaareAutoCannonWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

XSA0303 = Class(SAirUnit) {
    Weapons = {
        AutoCannon1 = Class(SAALosaareAutoCannonWeapon) {},
    },
}

TypeClass = XSA0303