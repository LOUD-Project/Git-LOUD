local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SLaanseMissileWeapon = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon

XSB2108 = Class(SStructureUnit) {
    Weapons = {
        CruiseMissile = Class(SLaanseMissileWeapon) {},
    },
}
TypeClass = XSB2108
