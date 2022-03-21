local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local ACruiseMissileWeapon = import('/lua/aeonweapons.lua').ACruiseMissileWeapon

BAB2308 = Class(AStructureUnit) {
    Weapons = {
        CruiseMissile = Class(ACruiseMissileWeapon) {},
    },
}
TypeClass = BAB2308
