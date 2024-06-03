local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

UEB2109 = Class(TStructureUnit) {
    Weapons = {
        Turret01 = Class(TANTorpedoAngler) {},
    },
}

TypeClass = UEB2109

