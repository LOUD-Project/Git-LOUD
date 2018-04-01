
local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SAAShleoCannonWeapon = SeraphimWeapons.SAAShleoCannonWeapon

XSA0102 = Class(SAirUnit) {
    Weapons = {
        SonicPulseBattery = Class(SAAShleoCannonWeapon) {},
    },
}

TypeClass = XSA0102