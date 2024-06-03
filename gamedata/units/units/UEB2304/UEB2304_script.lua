local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

UEB2304 = Class(TStructureUnit) {
    Weapons = {
        AAMissileRack = Class(TSAMLauncher) {},
    },
}

TypeClass = UEB2304