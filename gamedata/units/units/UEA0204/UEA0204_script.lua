local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler


UEA0204 = Class(TAirUnit) {

    Weapons = {
	
        Torpedo = Class(TANTorpedoAngler) {},
		
    },
	
}

TypeClass = UEA0204