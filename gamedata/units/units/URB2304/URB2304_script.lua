local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CAAMissileNaniteWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

URB2304 = Class(CStructureUnit) {

    Weapons = {
        AAMissileRack = Class(CAAMissileNaniteWeapon) {},
    },
}

TypeClass = URB2304