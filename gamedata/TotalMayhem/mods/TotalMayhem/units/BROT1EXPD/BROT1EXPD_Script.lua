local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TMAmizurabluelaserweapon = import('/mods/TotalMayhem/lua/TMAeonWeapons.lua').TMAmizurabluelaserweapon

BROT1EXPD = Class(TStructureUnit) {
    Weapons = {
        laserblue = Class(TMAmizurabluelaserweapon) {},
    },
}

TypeClass = BROT1EXPD