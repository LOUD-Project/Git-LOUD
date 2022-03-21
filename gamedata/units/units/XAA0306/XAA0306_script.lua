local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AANTorpedoCluster = import('/lua/aeonweapons.lua').AANTorpedoCluster

XAA0306 = Class(AAirUnit) {

    Weapons = {
	
        Bomb = Class(AANTorpedoCluster) {},
		
    },
	
}

TypeClass = XAA0306