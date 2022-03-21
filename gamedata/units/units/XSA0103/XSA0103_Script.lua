local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SDFBombOtheWeapon = import('/lua/seraphimweapons.lua').SDFBombOtheWeapon

XSA0103 = Class(SAirUnit) {
    Weapons = {
        Bomb = Class(SDFBombOtheWeapon) {},
    },
}

TypeClass = XSA0103