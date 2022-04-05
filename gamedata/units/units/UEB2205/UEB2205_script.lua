local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

UEB2205 = Class(TStructureUnit) {

    UpsideDown = false,

    Weapons = {
         Torpedo = Class(TANTorpedoAngler) {
       },
    },

}

TypeClass = UEB2205