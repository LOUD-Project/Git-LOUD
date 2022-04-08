SSS0306 = Class(import('/lua/defaultunits.lua').MobileUnit) {

    Weapons = {
        TorpedoTurrets = Class(import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo) {},
        AjelluTorpedoDefense = Class(import('/lua/seraphimweapons.lua').SDFAjelluAntiTorpedoDefense) {},
    },
	
}

TypeClass = SSS0306
