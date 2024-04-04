local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

UEB2205 = Class(TStructureUnit) {

    Weapons = {
        TorpedoLauncher = Class(TANTorpedoAngler) {},
    },

}

TypeClass = UEB2205