local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SIFBombZhanaseeWeapon = import('/lua/seraphimweapons.lua').SIFBombZhanaseeWeapon

SSA0211 = Class(SAirUnit) {
    Weapons = {
        Bomb = Class(SIFBombZhanaseeWeapon) {},
    },
}

TypeClass = SSA0211
