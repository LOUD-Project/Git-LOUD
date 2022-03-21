local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local DisarmBeamWeapon = import('/lua/sim/defaultweapons.lua').DisarmBeamWeapon

SSB2380 = Class(SStructureUnit) {
    Weapons = {
        MainGun = Class(DisarmBeamWeapon) {},
    },
}
TypeClass = SSB2380
