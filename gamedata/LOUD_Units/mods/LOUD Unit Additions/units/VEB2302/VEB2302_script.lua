local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

VEB2302 = Class(TStructureUnit) {

    Weapons = {
       MissileRack01 = Class(TSAMLauncher) {},
    },

}

TypeClass = VEB2302