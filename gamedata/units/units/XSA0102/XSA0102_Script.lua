local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon

XSA0102 = Class(SAirUnit) {
    Weapons = {
        SonicPulseBattery = Class(SAAShleoCannonWeapon) {},
    },
}

TypeClass = XSA0102