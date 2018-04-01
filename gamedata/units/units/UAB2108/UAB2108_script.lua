
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
local ACruiseMissileWeapon = import('/lua/aeonweapons.lua').ACruiseMissileWeapon

UAB2108 = Class(AStructureUnit) {
    Weapons = {
        CruiseMissile = Class(ACruiseMissileWeapon) {},
    },
}
TypeClass = UAB2108
