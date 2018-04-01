local AAirUnit = import('/lua/aeonunits.lua').AAirUnit

local AANTorpedoCluster = import('/lua/aeonweapons.lua').AANTorpedoCluster

XAA0306 = Class(AAirUnit) {

    Weapons = {
	
        Bomb = Class(AANTorpedoCluster) {},
		
    },
	
}

TypeClass = XAA0306