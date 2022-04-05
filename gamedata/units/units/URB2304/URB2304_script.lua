
local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon

URB2304 = Class(CStructureUnit) {
    Weapons = {
        Missile01 = Class(CAAMissileNaniteWeapon) {},
    },
}

TypeClass = URB2304