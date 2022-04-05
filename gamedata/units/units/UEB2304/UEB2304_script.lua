local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

UEB2304 = Class(TStructureUnit) {
    Weapons = {
        MissileRack01 = Class(TSAMLauncher) {},
    },
}

TypeClass = UEB2304