--------------------------------------------------------------------------------
--  Summary  :  UEF Torpedo Bomber Script
--------------------------------------------------------------------------------
local TAirUnit = import('/lua/defaultunits.lua').AirUnit
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

SEA0106 = Class(TAirUnit) {
    Weapons = {
        Torpedo = Class(TANTorpedoAngler) {},
    },
}

TypeClass = SEA0106
