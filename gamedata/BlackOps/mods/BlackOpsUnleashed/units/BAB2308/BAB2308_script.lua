local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

BAB2308 = Class(AStructureUnit) {

    Weapons = {
        CruiseMissile = Class(import('/lua/aeonweapons.lua').ACruiseMissileWeapon) {},
    },
}

TypeClass = BAB2308
