local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local ACruiseMissileWeapon = import('/lua/aeonweapons.lua').ACruiseMissileWeapon

UAB2108 = Class(AStructureUnit) {
    Weapons = {
        CruiseMissile = Class(ACruiseMissileWeapon) {},
    },
}
TypeClass = UAB2108
