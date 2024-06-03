local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AANTorpedoCluster = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

XAA0306 = Class(AAirUnit) {

    Weapons = {
        ClusterTorpedo = Class(AANTorpedoCluster) { FxMuzzleFlash = false },
    },
	
}

TypeClass = XAA0306