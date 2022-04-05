local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SAAOlarisCannonWeapon = import('/lua/seraphimweapons.lua').SAAOlarisCannonWeapon

XSL0205 = Class(SLandUnit) {
    Weapons = {
        AAGun = Class(SAAOlarisCannonWeapon) {},
    },
}
TypeClass = XSL0205