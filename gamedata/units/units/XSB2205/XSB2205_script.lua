XSB2205 = Class(import('/lua/seraphimunits.lua').SStructureUnit) {

    Weapons = {

        TorpedoTurret = Class(import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo) {},

        AntiTorpedo = Class(import('/lua/seraphimweapons.lua').SDFAjelluAntiTorpedoDefense) {},
		
    },
	
}

TypeClass = XSB2205