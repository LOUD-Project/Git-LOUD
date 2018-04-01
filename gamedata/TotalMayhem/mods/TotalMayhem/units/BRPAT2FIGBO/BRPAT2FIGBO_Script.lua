local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit

BRPAT2FIGBO = Class(SAirUnit) {

    Weapons = {
        MainGun = Class(SAALosaareAutoCannonWeapon) {},
    },
}

TypeClass = BRPAT2FIGBO
