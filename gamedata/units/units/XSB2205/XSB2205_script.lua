XSB2205 = Class(import('/lua/seraphimunits.lua').SStructureUnit) {

    Weapons = {
        TorpedoTurrets = Class(import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo) {},
        AjelluTorpedoDefense = Class(import('/lua/seraphimweapons.lua').SDFAjelluAntiTorpedoDefense) {},
		
    },
	
}

TypeClass = XSB2205