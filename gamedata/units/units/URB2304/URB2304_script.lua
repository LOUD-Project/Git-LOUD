
local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon

URB2304 = Class(CStructureUnit) {
    Weapons = {
        Missile01 = Class(CAAMissileNaniteWeapon) {},
    },
}

TypeClass = URB2304