local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit

BRPAT2FIGBO = Class(SAirUnit) {

    Weapons = {
        MainGun = Class(SAALosaareAutoCannonWeapon) {},
    },
}

TypeClass = BRPAT2FIGBO
