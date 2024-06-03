local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SAAOlarisCannonWeapon = import('/lua/seraphimweapons.lua').SAAOlarisCannonWeapon

XSB3304 = Class(SStructureUnit) {
    Weapons = {
        AAFizz = Class(SAAOlarisCannonWeapon) {},
    },
}
TypeClass = XSB3304