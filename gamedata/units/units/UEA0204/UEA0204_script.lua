local TAirUnit = import('/lua/terranunits.lua').TAirUnit
local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler


UEA0204 = Class(TAirUnit) {

    Weapons = {
	
        Torpedo = Class(TANTorpedoAngler) {},
		
    },
	
}

TypeClass = UEA0204