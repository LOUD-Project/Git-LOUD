local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

UEB2205 = Class(TStructureUnit) {

    UpsideDown = false,

    Weapons = {
         Torpedo = Class(TANTorpedoAngler) {
       },
    },

}

TypeClass = UEB2205