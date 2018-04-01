local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

local ACruiseMissileWeapon = import('/lua/aeonweapons.lua').ACruiseMissileWeapon

BAB2308 = Class(AStructureUnit) {
    Weapons = {
        CruiseMissile = Class(ACruiseMissileWeapon) {},
    },
}
TypeClass = BAB2308
