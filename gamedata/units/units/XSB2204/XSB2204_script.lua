local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SAAOlarisCannonWeapon = import('/lua/seraphimweapons.lua').SAAOlarisCannonWeapon

XSB2204 = Class(SStructureUnit) {
    Weapons = {
        AAFizz = Class(SAAOlarisCannonWeapon) {},
    },
}
TypeClass = XSB2204