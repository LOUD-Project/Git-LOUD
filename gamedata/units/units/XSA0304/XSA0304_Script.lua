local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit

local SIFBombZhanaseeWeapon = import('/lua/seraphimweapons.lua').SIFBombZhanaseeWeapon

XSA0304 = Class(SAirUnit) {
    Weapons = {
        Bomb = Class(SIFBombZhanaseeWeapon) {},
    },
}
TypeClass = XSA0304