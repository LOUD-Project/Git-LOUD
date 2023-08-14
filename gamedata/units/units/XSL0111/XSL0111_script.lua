local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SLaanseMissileWeapon = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon

XSL0111 = Class(SLandUnit) {

    Weapons = {
        MissileRack = Class(SLaanseMissileWeapon) {},
    },
}
TypeClass = XSL0111